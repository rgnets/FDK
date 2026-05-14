import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/secure_http_client.dart';
import 'package:rgnets_fdk/core/utils/log_redaction.dart' as log_redaction;
import 'package:rgnets_fdk/features/compliance/data/models/compliance_check_result_model.dart';

/// Status-bearing fleet-node discovery result. Distinguishes "I know the
/// local node id" from "this rxg looks like a standalone (single fleet_node
/// row)" from "the lookup failed and we're flying blind." The third case
/// MUST disable any rule-only fallback — accepting any-node snapshots on a
/// fleet manager with a failed discovery would surface the wrong node's
/// data in FDK.
enum LocalFleetNodeStatus { known, standalone, unknown }

class LocalFleetNodeResult {
  const LocalFleetNodeResult(this.status, [this.id]);
  final LocalFleetNodeStatus status;
  final int? id;

  /// True only when the discovery was successful AND there's a specific id we
  /// can use to filter. Both `known` and `standalone` are "safe to accept
  /// non-matching fleet_node payloads," but with different semantics: `known`
  /// matches the id strictly, `standalone` matches by rule only.
  bool get isResolved => status != LocalFleetNodeStatus.unknown;

  /// Whether the repository may accept snapshot rows whose `fleet_node_id`
  /// is missing/null in the wire payload. True only on confirmed standalone
  /// or fully-known-and-matching cases — never when discovery itself failed.
  bool get allowMissingFleetNode =>
      status == LocalFleetNodeStatus.standalone;
}

/// Outcome of a snapshot bootstrap fetch.
///
/// Distinguishes the four cases the provider needs to translate into FDK
/// state (FM-7):
///   - [found]   — snapshot present; .snapshot is non-null.
///   - [absent]  — endpoint reachable + 200 but no row matches → `unknown`.
///   - [unauthorized] — 401 from RXG → `error("authentication failed")`.
///   - [networkError] — any other failure (5xx, timeout, exception) →
///     `error("network unreachable")`; provider retains last good state.
enum BootstrapStatus { found, absent, unauthorized, networkError }

class BootstrapResult {
  const BootstrapResult(this.status, [this.snapshot]);
  final BootstrapStatus status;
  final ComplianceCheckResultModel? snapshot;

  bool get isError =>
      status == BootstrapStatus.unauthorized ||
      status == BootstrapStatus.networkError;
}

/// Discriminated result of a name → id lookup against the RXG REST API.
///
/// Replaces the prior `Future<int?>` contract, which collapsed four very
/// different failure modes into the same `null`. The provider layer needs
/// to distinguish them to satisfy spec FM-7:
///   - [LookupFound]        — `name` matched a row; `id` is the rxg PK.
///   - [LookupMissing]      — endpoint reachable, no row matched (or 403/
///                            404 from the resource itself; both indicate
///                            "seed not applied yet").
///   - [LookupUnauthorized] — 401 from rxg; api_key is bad or expired.
///   - [LookupNetworkError] — timeout, socket exception, 5xx, malformed
///                            body. Carries a redacted error message.
sealed class LookupResult {
  const LookupResult();
}

class LookupFound extends LookupResult {
  const LookupFound(this.id);
  final int id;
}

class LookupMissing extends LookupResult {
  const LookupMissing();
}

class LookupUnauthorized extends LookupResult {
  const LookupUnauthorized();
}

class LookupNetworkError extends LookupResult {
  const LookupNetworkError(this.message);
  final String message;
}

/// Outcome of a manual notification-action trigger.
///
/// The HTTP 200 from `/admin/notification_actions/:id/trigger.json` means the
/// `NotificationEvent` was queued, not that the underlying compliance check
/// completed. The provider layer is responsible for watching for a fresher
/// snapshot to actually flip UI state. See spec FM-9 / TR-9.
enum TriggerOutcome {
  queued,
  /// Either the action ID isn't valid for the connected RXG or the action's
  /// `event_type` is not in `API_TRIGGERABLE` (`%w[manual periodic]`). The
  /// admin scaffold returns 403 for both cases; FDK treats them identically.
  notFound,
  unauthorized,
  networkError,
}

/// REST datasource for the compliance feature.
///
/// All endpoints surfaced here are the spec's TR-10 commitments. If A3
/// validation against a live RXG reveals different shapes / paths, update
/// the spec and adjust this file before the rest of the FDK layer relies
/// on assumptions baked in here.
///
/// All log lines that touch URLs run through [scrubUrlForLog] to satisfy
/// spec FM-8: the `?api_key=…` query parameter must never reach a log sink.
class ComplianceRestDataSource {
  ComplianceRestDataSource({
    required String siteUrl,
    required this.apiKey,
    http.Client? client,
  })  : siteUrl = _normalizeSiteUrl(siteUrl),
        // Default to the app's certificate-aware singleton client so self-
        // signed rxg certs are accepted via [CertificateValidator]. Tests
        // override with `MockClient`.
        _client = client ?? SecureHttpClient.getClient(),
        _ownsClient = client == null;

  final String siteUrl;
  final String apiKey;
  final http.Client _client;
  // Tracks whether this datasource provided its own client (true) vs. was
  // given an external one (false). Currently only consulted by [close()]
  // through documentation — kept on the class so future ownership models
  // (e.g. a non-singleton injected client) can use it without changing the
  // ctor surface.
  // ignore: unused_field
  final bool _ownsClient;

  static const _tag = 'ComplianceRestDataSource';
  static const _timeout = Duration(seconds: 10);

  /// Strips any scheme prefix and trailing slash from the configured
  /// `siteUrl`. Matches `RestImageUploadService._normalizeSiteUrl` — the
  /// storage layer persists `siteUrl` as `https://$fqdn`, so consumers that
  /// re-prepend `https://` need to strip it first to avoid building URLs
  /// like `https://https://example/...`.
  static String _normalizeSiteUrl(String url) {
    var normalized = url;
    if (normalized.startsWith('https://')) {
      normalized = normalized.substring(8);
    } else if (normalized.startsWith('http://')) {
      normalized = normalized.substring(7);
    }
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  Uri _api(String path) => Uri.parse('https://$siteUrl/api/$path?api_key=$apiKey');
  Uri _admin(String path) =>
      Uri.parse('https://$siteUrl/admin/$path?api_key=$apiKey');

  /// Backwards-compatible alias for the shared URL scrubber. Kept on the
  /// class so existing call sites (and tests that read the static) still
  /// compile after the helper was lifted to `lib/core/utils/log_redaction.dart`.
  /// Prefer `log_redaction.scrubUrlForLog` for new code.
  static String scrubUrlForLog(Uri uri) =>
      log_redaction.scrubUrlForLog(uri) ?? uri.toString();

  /// Looks up a `ComplianceRule` by its `name` (natural key in RXG).
  ///
  /// The auto-routed REST API at `/api/compliance_rules.json` returns a list
  /// (response shape verified during Deliverable A.3). We filter client-side
  /// because no `?name=…` server-side filter is guaranteed to exist on the
  /// REST resource. Returns a typed [LookupResult] so the provider layer
  /// can distinguish "seed not applied" from "401 / network" (FM-7).
  Future<LookupResult> lookupRuleId(String name) async {
    final uri = _api('compliance_rules.json');
    return _lookupIdByName(uri: uri, name: name);
  }

  /// Looks up a `NotificationAction` by its `name`.
  Future<LookupResult> lookupNotificationActionId(String name) async {
    final uri = _api('notification_actions.json');
    return _lookupIdByName(uri: uri, name: name);
  }

  /// Returns the local fleet_node identity along with its status, so
  /// callers can distinguish three cases (see [LocalFleetNodeStatus]):
  ///   - exactly one row in the list → `standalone`
  ///   - a row with `is_self: true` / `local: true` → `known(id)`
  ///   - multiple rows, none self-marked → `known(first.id)` with a warning
  ///   - any failure (non-200, exception, malformed) → `unknown`
  Future<LocalFleetNodeResult> discoverLocalFleetNode() async {
    final uri = _api('fleet_nodes.json');
    LoggerService.debug('GET ${scrubUrlForLog(uri)}', tag: _tag);
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } catch (e) {
      LoggerService.error('fleet_nodes lookup failed (scrubbed): ${_safeError(e)}',
          tag: _tag);
      return const LocalFleetNodeResult(LocalFleetNodeStatus.unknown);
    }
    if (response.statusCode != 200) {
      LoggerService.warning(
        'fleet_nodes lookup returned ${response.statusCode}',
        tag: _tag,
      );
      return const LocalFleetNodeResult(LocalFleetNodeStatus.unknown);
    }
    final List<dynamic>? list;
    try {
      list = _extractList(jsonDecode(response.body));
    } catch (e) {
      LoggerService.warning(
        'fleet_nodes parse failed (scrubbed): ${_safeError(e)} body=${response.body}',
        tag: _tag,
      );
      return const LocalFleetNodeResult(LocalFleetNodeStatus.unknown);
    }
    if (list == null) {
      LoggerService.warning(
        'fleet_nodes unrecognized body shape, treating as unknown. body=${response.body}',
        tag: _tag,
      );
      return const LocalFleetNodeResult(LocalFleetNodeStatus.unknown);
    }
    if (list.isEmpty) {
      // A standalone rxg may have zero fleet_node rows. Treat that as
      // standalone with no specific id so the compliance feed accepts
      // rows whose `fleet_node_id` is null.
      LoggerService.warning(
        'fleet_nodes returned empty list, treating as standalone (no id)',
        tag: _tag,
      );
      return const LocalFleetNodeResult(
          LocalFleetNodeStatus.standalone);
    }
    // Exactly one row → standalone.
    if (list.length == 1) {
      final row = list.first;
      final id = row is Map<String, dynamic> && row['id'] is int
          ? row['id'] as int
          : null;
      return LocalFleetNodeResult(LocalFleetNodeStatus.standalone, id);
    }
    // Multiple rows: prefer the one self-marked.
    for (final row in list) {
      if (row is! Map<String, dynamic>) continue;
      if ((row['is_self'] == true || row['local'] == true) && row['id'] is int) {
        return LocalFleetNodeResult(LocalFleetNodeStatus.known, row['id'] as int);
      }
    }
    // No self-marked row in a multi-row response — log loudly; we still pick
    // the first id so something works, but the provider should treat
    // `known(first)` cautiously. The repository will strict-match on this id,
    // which matches what the FDK is actually attached to in 99% of cases.
    LoggerService.warning(
      'fleet_nodes returned ${list.length} rows without a self-marker; using first',
      tag: _tag,
    );
    for (final row in list) {
      if (row is Map<String, dynamic> && row['id'] is int) {
        return LocalFleetNodeResult(LocalFleetNodeStatus.known, row['id'] as int);
      }
    }
    return const LocalFleetNodeResult(LocalFleetNodeStatus.unknown);
  }

  /// Legacy thin wrapper used by tests; new callers should use
  /// [discoverLocalFleetNode] for the status-bearing result.
  Future<int?> discoverLocalFleetNodeId() async =>
      (await discoverLocalFleetNode()).id;

  /// Fetches the current snapshot for `(ruleId, fleetNodeId)`.
  ///
  /// Returns a [BootstrapResult] that carries enough information for the
  /// provider to distinguish "seed missing" (`absent` → `unknown`) from
  /// "auth/network failure" (`unauthorized`/`networkError` → `error`). FM-7.
  ///
  /// Filter semantics for `fleet_node_id` (slice-4 data-bug fix):
  ///   - `fleetNodeId == null` (discovery couldn't pin a local id) → no
  ///     filter on payload `fleet_node_id`.
  ///   - `fleetNodeId != null` and payload matches → accept.
  ///   - `fleetNodeId != null` and payload is non-null and differs → reject
  ///     (delegated fleet result for a different node).
  ///   - `fleetNodeId != null` and payload is `null` → **always accept**.
  ///     RXG writes `null` in `fleet_node_id` for results produced by
  ///     compliance checks that ran on the local rxg itself (vs. delegated
  ///     across a fleet). Those results are always "for us." The previous
  ///     `allowMissingFleetNode` flag (controlled by discovery status) was
  ///     too narrow — `discoverLocalFleetNode` returns `known` whenever a
  ///     row in `/api/fleet_nodes.json` is self-marked, including on rxgs
  ///     that still write `null` to `compliance_check_results.fleet_node_id`
  ///     (the user's reported bug surface: 2 admin-view failure rows ignored
  ///     by FDK, surfacing as `unknown`).
  ///
  /// The `allowMissingFleetNode` parameter is retained as a no-op for
  /// source-compat (callers still pass it) but is no longer consulted —
  /// the null payload case is unconditionally accepted.
  Future<BootstrapResult> bootstrapResult({
    required int ruleId,
    required String ruleName,
    int? fleetNodeId,
    // ignore: avoid_unused_constructor_parameters
    bool allowMissingFleetNode = false,
  }) async {
    // Server-side filter is essential: the paginated endpoint returns 30
    // rows per page and on rxgs with many compliance rules the latest-30
    // may not contain any rows for our specific rule.
    //
    // We filter by `compliance_rule.name` (the join sub-field) rather than
    // `compliance_rule_id`. The rest_framework gem's default
    // `Utils.fields_for` excludes belongs_to foreign keys from the
    // filterable field list, so `?compliance_rule_id=N` is silently
    // dropped. The association sub-fields (id + label field "name") *are*
    // filterable through the dotted path, so `?compliance_rule.name=…`
    // works. Filtering by name also avoids hard-coding a rule_id that
    // varies per rxg.
    final uri = Uri.parse(
        'https://$siteUrl/api/compliance_check_results.json'
        '?api_key=${Uri.encodeQueryComponent(apiKey)}'
        '&compliance_rule.name=${Uri.encodeQueryComponent(ruleName)}');
    LoggerService.debug('GET ${scrubUrlForLog(uri)}', tag: _tag);
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      LoggerService.warning('snapshot bootstrap timed out', tag: _tag);
      return const BootstrapResult(BootstrapStatus.networkError);
    } catch (e) {
      LoggerService.error('snapshot bootstrap failed (scrubbed): ${_safeError(e)}',
          tag: _tag);
      return const BootstrapResult(BootstrapStatus.networkError);
    }
    if (response.statusCode == 401) {
      return const BootstrapResult(BootstrapStatus.unauthorized);
    }
    if (response.statusCode != 200) {
      LoggerService.warning(
        'snapshot bootstrap returned ${response.statusCode}',
        tag: _tag,
      );
      return const BootstrapResult(BootstrapStatus.networkError);
    }

    // A malformed 200 body must not escape as an exception — surface as
    // networkError per the documented contract.
    final List<dynamic>? list;
    try {
      list = _extractList(jsonDecode(response.body));
    } catch (e) {
      LoggerService.warning(
        'snapshot bootstrap parse failed (scrubbed): ${_safeError(e)}',
        tag: _tag);
      return const BootstrapResult(BootstrapStatus.networkError);
    }
    if (list == null) return const BootstrapResult(BootstrapStatus.absent);

    // Server already filtered by compliance_rule.name, so every row in
    // `list` is for our rule. We can't double-check client-side because the
    // rest_framework serializer excludes `belongs_to` foreign keys from
    // the JSON payload (same `Utils.fields_for` logic that excludes them
    // from filterable fields). The server-side filter is authoritative.
    ComplianceCheckResultModel? best;
    var nodeRejectCount = 0;
    var payloadNullCount = 0;
    var accepted = 0;
    for (final raw in list) {
      if (raw is! Map<String, dynamic>) continue;
      final payloadNodeId = raw['fleet_node_id'];
      if (payloadNodeId == null) {
        payloadNullCount++;
        // Always accept null — see method doc-comment.
      } else if (fleetNodeId != null && payloadNodeId != fleetNodeId) {
        nodeRejectCount++;
        continue;
      }
      // tryFromJson expects compliance_rule_id; synthesise it from the
      // ruleId arg since the server omits the FK column.
      final patched = {...raw, 'compliance_rule_id': ruleId};
      final candidate = ComplianceCheckResultModel.tryFromJson(patched);
      if (candidate == null) continue;
      accepted++;
      if (best == null || candidate.checkedAt.isAfter(best.checkedAt)) {
        best = candidate;
      }
    }
    final ruleMatchCount = list.length;
    if (best != null) {
      final preview = best.failures.take(2).map((e) {
        final s = e.toString();
        return s.length > 200 ? '${s.substring(0, 200)}…' : s;
      }).toList();
      LoggerService.debug(
        'bootstrapResult[rule=$ruleId]: best.compliant=${best.compliant} '
        'failures.count=${best.failures.length} preview=$preview',
        tag: _tag,
      );
    }
    LoggerService.debug(
      'bootstrapResult[rule=$ruleId, node=$fleetNodeId]: '
      'rows=${list.length} ruleMatches=$ruleMatchCount '
      'payloadNull=$payloadNullCount nodeRejected=$nodeRejectCount '
      'accepted=$accepted',
      tag: _tag,
    );
    if (best == null) return const BootstrapResult(BootstrapStatus.absent);
    return BootstrapResult(BootstrapStatus.found, best);
  }

  /// Fires a manual notification_action. Returns a [TriggerOutcome] so the
  /// provider layer can map distinct errors to distinct UI states (FM-7).
  ///
  /// 200 → [TriggerOutcome.queued] (NotificationEvent created; DelayedJob
  /// will run the recheck script, which itself rate-limits at 30s).
  /// 403 / 404 → [TriggerOutcome.notFound] (admin scaffold returns 403 when
  /// the action is missing OR its event_type isn't in `API_TRIGGERABLE`;
  /// 404 can come from missing route).
  /// 401 → [TriggerOutcome.unauthorized].
  /// Network/timeout → [TriggerOutcome.networkError].
  Future<TriggerOutcome> triggerNotificationAction(int actionId) async {
    final uri = _admin('notification_actions/$actionId/trigger.json');
    LoggerService.debug('POST ${scrubUrlForLog(uri)}', tag: _tag);
    try {
      final response = await _client.post(uri).timeout(_timeout);
      switch (response.statusCode) {
        case 200:
          return TriggerOutcome.queued;
        case 401:
          return TriggerOutcome.unauthorized;
        case 403:
        case 404:
          return TriggerOutcome.notFound;
        default:
          LoggerService.warning(
            'unexpected trigger response status ${response.statusCode}',
            tag: _tag,
          );
          return TriggerOutcome.networkError;
      }
    } on TimeoutException {
      LoggerService.warning('trigger timed out', tag: _tag);
      return TriggerOutcome.networkError;
    } catch (e) {
      LoggerService.error('trigger failed (scrubbed): ${_safeError(e)}',
          tag: _tag);
      return TriggerOutcome.networkError;
    }
  }

  /// FM-8: exception messages can include the request URI (and thus api_key)
  /// when thrown by `http`/`dio` clients. Delegates to the shared scrubber so
  /// new layers get the same redaction without re-importing or re-copying.
  static String _safeError(Object e) => log_redaction.scrubErrorForLog(e);

  /// Discriminated lookup. Maps each HTTP failure mode to the matching
  /// [LookupResult] subtype:
  ///   - 200 + matching row → [LookupFound]
  ///   - 200 + no row, OR 403/404 → [LookupMissing] (seed not applied yet)
  ///   - 401 → [LookupUnauthorized]
  ///   - other non-200 / timeout / socket exception / parse failure →
  ///     [LookupNetworkError] with a scrubbed message.
  Future<LookupResult> _lookupIdByName(
      {required Uri uri, required String name}) async {
    LoggerService.debug('GET ${log_redaction.scrubUrlForLog(uri)}', tag: _tag);
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException catch (e) {
      LoggerService.warning('lookup ${uri.path} timed out', tag: _tag);
      return LookupNetworkError(_safeError(e));
    } on SocketException catch (e) {
      LoggerService.error('lookup socket error (scrubbed): ${_safeError(e)}',
          tag: _tag);
      return LookupNetworkError(_safeError(e));
    } catch (e) {
      LoggerService.error('lookup failed (scrubbed): ${_safeError(e)}',
          tag: _tag);
      return LookupNetworkError(_safeError(e));
    }
    switch (response.statusCode) {
      case 200:
        break;
      case 401:
        return const LookupUnauthorized();
      case 403:
      case 404:
        // Both 403 and 404 from the lookup resource indicate "the named
        // record isn't present / not accessible" — treat as missing rather
        // than auth failure. The provider invalidates the lookup cache once
        // before surfacing `unknown`.
        return const LookupMissing();
      default:
        LoggerService.warning(
          'lookup ${uri.path} returned ${response.statusCode}',
          tag: _tag,
        );
        return LookupNetworkError('HTTP ${response.statusCode}');
    }
    final List<dynamic>? list;
    try {
      list = _extractList(jsonDecode(response.body));
    } catch (e) {
      LoggerService.warning(
        'lookup ${uri.path} parse failed (scrubbed): ${_safeError(e)}',
        tag: _tag,
      );
      return LookupNetworkError(_safeError(e));
    }
    if (list == null) {
      LoggerService.warning(
        'lookup ${uri.path} unrecognized body shape; bodyLen=${response.body.length}',
        tag: _tag,
      );
      return LookupNetworkError('unrecognized body shape');
    }
    for (final raw in list) {
      if (raw is! Map<String, dynamic>) continue;
      if (raw['name'] == name) {
        final id = raw['id'];
        if (id is int) return LookupFound(id);
      }
    }
    LoggerService.warning(
      'lookup ${uri.path}: no row matched name="$name" (rows=${list.length})',
      tag: _tag,
    );
    return const LookupMissing();
  }

  /// Intentionally a no-op when the datasource is wired to the
  /// [SecureHttpClient] singleton (the production path — `_ownsClient` is
  /// true but the singleton is shared across the app). Test-injected clients
  /// (`_ownsClient == false`) are disposed by the test itself.
  ///
  /// Kept on the class so the provider's `ref.onDispose(ds.close)` has a
  /// stable hook in case a future ownership model lets the datasource hold
  /// a non-singleton client.
  void close() {
    // No-op by design; see doc comment.
  }

  /// RXG REST resources return one of three shapes:
  ///   - bare array `[...]`
  ///   - `{"records": [...]}`
  ///   - `{"results": [...], "count":..., "page":..., ...}` (paginated)
  /// Returns `null` if none match.
  List<dynamic>? _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final records = body['records'];
      if (records is List) return records;
      final results = body['results'];
      if (results is List) return results;
    }
    return null;
  }
}
