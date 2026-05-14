import 'dart:async';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_compliance_cache_service.dart';
import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';
import 'package:rgnets_fdk/features/compliance/data/models/compliance_check_result_model.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';
import 'package:rgnets_fdk/features/compliance/domain/repositories/compliance_repository.dart';

/// Concrete repository tied to a single `(ruleId, actionId, fleetNodeId)`
/// triple. Spec refs: TR-4 (state merge), TR-9 (trigger semantics), FM-9
/// (200 doesn't mean check-done — provider polls snapshot via [watch]).
class ComplianceRepositoryImpl implements ComplianceRepository {
  ComplianceRepositoryImpl({
    required this.ruleName,
    required this.ruleId,
    required this.actionId,
    required this.fleetNode,
    required ComplianceRestDataSource rest,
    required WebSocketComplianceCacheService cache,
  })  : _rest = rest,
        _cache = cache;

  /// Display name of the compliance rule, used to stamp parsed failures.
  final String ruleName;
  final int ruleId;
  final int actionId;
  /// Status-bearing local node identity. Only `standalone` enables the
  /// "accept missing fleet_node_id in payload" fallback (TR-4 / FM-7 fix).
  final LocalFleetNodeResult fleetNode;
  int? get fleetNodeId => fleetNode.id;

  final ComplianceRestDataSource _rest;
  final WebSocketComplianceCacheService _cache;

  final _stateController =
      StreamController<ComplianceFeedState>.broadcast();
  void Function(List<Map<String, dynamic>>)? _wsCallback;
  ComplianceFeedState _lastEmitted = const ComplianceFeedState.loading();
  DateTime? _latestKnownCheckedAt;
  bool _autoTriggered = false;

  @override
  DateTime? get latestKnownCheckedAt => _latestKnownCheckedAt;

  @override
  Future<ComplianceFeedState> bootstrap() async {
    // Register the WS listener BEFORE the REST round-trip so any broadcast
    // arriving during bootstrap is captured. Also replay the current cache
    // contents — the cache only fans out new upserts on register, but on a
    // cold start it may already hold rows from a snapshot burst received
    // before this repository existed. Closes the codex final blocker #4
    // bootstrap/watch race.
    _ensureSubscribed();
    _handleWsDelta(_cache.getCached());

    final result = await _rest.bootstrapResult(
      ruleId: ruleId,
      ruleName: ruleName,
      fleetNodeId: fleetNodeId,
    );

    switch (result.status) {
      case BootstrapStatus.found:
        // REST snapshot wins only if it's strictly newer than what the WS
        // replay already gave us. Older or equal REST data is ignored.
        final ts = result.snapshot!.checkedAt;
        if (_latestKnownCheckedAt == null || ts.isAfter(_latestKnownCheckedAt!)) {
          _emit(result.snapshot!.toFeedState(ruleName: ruleName), checkedAt: ts);
        }
        break;
      case BootstrapStatus.absent:
        // Don't downgrade a WS-replayed state to `unknown` — if we already
        // have a snapshot from cache replay, that's still the truth. Only
        // surface `unknown` when we have nothing else.
        if (_lastEmitted == const ComplianceFeedState.loading()) {
          _emit(const ComplianceFeedState.unknown());
        }
        // Rule is seeded but never produced a result row yet (hourly job
        // hasn't run; no manual trigger fired). Fire the recheck once so
        // failures populate without waiting for the scheduled tick. This
        // is a session-scoped one-shot; subsequent rechecks remain user-
        // initiated (photo upload / speed-test submit / pull-to-refresh).
        if (!_autoTriggered) {
          _autoTriggered = true;
          unawaited(_fireInitialTrigger());
        }
        break;
      case BootstrapStatus.unauthorized:
        // Auth failure is authoritative even over a cached snapshot — the
        // session is in a bad state and the user needs to see it. But if
        // a fresher WS broadcast arrived showing the snapshot is current,
        // suppress (the api_key is fine if it's signing recent broadcasts).
        if (_latestKnownCheckedAt == null) {
          _emit(const ComplianceFeedState.error('authentication failed'));
        }
        break;
      case BootstrapStatus.networkError:
        // Same reasoning as auth: don't blank out a freshly-replayed state.
        if (_lastEmitted == const ComplianceFeedState.loading()) {
          _emit(const ComplianceFeedState.error('network unreachable'));
        }
        break;
    }
    return _lastEmitted;
  }

  @override
  Stream<ComplianceFeedState> watch() {
    _ensureSubscribed();
    return _stateController.stream;
  }

  /// Idempotent: registers the cache callback exactly once. Both [bootstrap]
  /// and [watch] call this so a WS delta arriving between bootstrap and
  /// watch isn't lost.
  void _ensureSubscribed() {
    if (_wsCallback != null) return;
    _wsCallback = _handleWsDelta;
    _cache.onResultData(_wsCallback!);
  }

  /// Handles each WS snapshot fan-out: filters by `(rule_id, fleet_node_id)`,
  /// picks the newest matching row, drops older-than-known deltas, emits the
  /// mapped feed state. All exceptions are swallowed — see the catch at the
  /// bottom for the rationale (a malformed broadcast must not break the
  /// stream).
  ///
  /// Filter semantics match [ComplianceRestDataSource.bootstrapResult] —
  /// rows with `payload.fleet_node_id == null` are always accepted (the rxg
  /// writes null for results produced by checks running on the local rxg
  /// itself; those are always "for us"). See the bootstrapResult doc-comment
  /// for the full rationale and slice-4 history.
  void _handleWsDelta(List<Map<String, dynamic>> items) {
    try {
      ComplianceCheckResultModel? best;
      for (final raw in items) {
        // The rxg's `rest_framework` serializer excludes belongs_to FK
        // columns (`compliance_rule_id`) from the broadcast payload — the
        // same exclusion that affects REST. Look for the rule id in the
        // nested association object first, then fall back to the FK key
        // (in case the WS serializer differs from the REST one).
        final nested = raw['compliance_rule'];
        final payloadRuleId = nested is Map<String, dynamic>
            ? nested['id']
            : raw['compliance_rule_id'];
        if (payloadRuleId != null && payloadRuleId != ruleId) continue;
        final payloadNodeId = raw['fleet_node_id'];
        if (payloadNodeId != null &&
            fleetNodeId != null &&
            payloadNodeId != fleetNodeId) {
          continue; // delegated to a different node
        }
        // Patch rule id into the row so tryFromJson succeeds even when the
        // serializer omitted the FK column.
        final patched = {...raw, 'compliance_rule_id': ruleId};
        final model = ComplianceCheckResultModel.tryFromJson(patched);
        if (model == null) continue;
        if (best == null || model.checkedAt.isAfter(best.checkedAt)) {
          best = model;
        }
      }
      if (best == null) return;
      // Drop deltas older-or-equal to what we already showed.
      if (_latestKnownCheckedAt != null &&
          !best.checkedAt.isAfter(_latestKnownCheckedAt!)) {
        return;
      }
      _emit(best.toFeedState(ruleName: ruleName), checkedAt: best.checkedAt);
    } catch (_) {
      // Defensive: any unexpected error in the cache callback must not bubble
      // and break the stream. tryFromJson handles known shape surprises; this
      // guards against anything else.
    }
  }

  @override
  Future<TriggerOutcome> triggerRecheck() async {
    final outcome = await _rest.triggerNotificationAction(actionId);
    if (outcome == TriggerOutcome.queued) {
      // WS broadcast for compliance_check_results isn't always delivered
      // (observed on real rxgs: trigger lands, DelayedJob runs the script,
      // result row gets written, but no WS push reaches the FDK). Fall
      // back to a delayed REST refetch so the newly-created row gets
      // picked up. 8s gives the DelayedJob runner time to execute the
      // recheck script and write the result.
      Timer(const Duration(seconds: 8), _refetchAfterTrigger);
    }
    return outcome;
  }

  Future<void> _fireInitialTrigger() async {
    final outcome = await triggerRecheck();
    LoggerService.debug(
      'initial trigger for $ruleName → $outcome',
      tag: 'ComplianceRepository',
    );
  }

  Future<void> _refetchAfterTrigger() async {
    if (_stateController.isClosed) return;
    final result = await _rest.bootstrapResult(
      ruleId: ruleId,
      ruleName: ruleName,
      fleetNodeId: fleetNodeId,
      allowMissingFleetNode: fleetNode.allowMissingFleetNode,
    );
    if (result.status == BootstrapStatus.found && result.snapshot != null) {
      final ts = result.snapshot!.checkedAt;
      if (_latestKnownCheckedAt == null ||
          ts.isAfter(_latestKnownCheckedAt!)) {
        _emit(result.snapshot!.toFeedState(ruleName: ruleName),
            checkedAt: ts);
      }
    }
  }

  @override
  void emitTriggerError(TriggerOutcome outcome) {
    // Only the two failure paths surface as feed errors. `queued` is the
    // happy path; `notFound` indicates stale lookup, which the trigger
    // wiring already handles by invalidating the lookup provider (the next
    // bootstrap re-resolves; no UI error needed for that transient).
    switch (outcome) {
      case TriggerOutcome.unauthorized:
        _emit(const ComplianceFeedState.error('authentication failed'));
        break;
      case TriggerOutcome.networkError:
        // Suppress if a fresh snapshot recently advanced — broadcasts arriving
        // means the connection isn't actually dead and the user shouldn't see
        // a spurious error banner. The threshold (30s) matches the retry
        // window so a fresh-enough snapshot covers the trigger failure.
        final latest = _latestKnownCheckedAt;
        if (latest != null &&
            DateTime.now().toUtc().difference(latest).inSeconds < 30) {
          return;
        }
        _emit(const ComplianceFeedState.error('network unreachable'));
        break;
      case TriggerOutcome.queued:
      case TriggerOutcome.notFound:
        return;
    }
  }

  @override
  void dispose() {
    if (_wsCallback != null) {
      _cache.removeResultDataCallback(_wsCallback!);
      _wsCallback = null;
    }
    _stateController.close();
  }

  void _emit(ComplianceFeedState state, {DateTime? checkedAt}) {
    if (checkedAt != null) _latestKnownCheckedAt = checkedAt;
    if (state == _lastEmitted) return;
    _lastEmitted = state;
    if (!_stateController.isClosed) _stateController.add(state);
  }
}
