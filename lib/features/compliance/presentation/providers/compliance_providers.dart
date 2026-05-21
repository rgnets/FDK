import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/core/services/image_upload_event_bus.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart'
    as auth;
import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';
import 'package:rgnets_fdk/features/compliance/data/repositories/compliance_repository_impl.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';
import 'package:rgnets_fdk/features/compliance/domain/repositories/compliance_repository.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';

/// Names of the compliance artifacts seeded by the YAML config template.
/// MUST match the YAML entries verbatim — natural-key lookup depends on it.
class ComplianceNames {
  ComplianceNames._();

  static const String imagesRule = 'FDK Missing Installation Images';
  static const String speedTestRule = 'FDK APs Failed Speed Test';
}

/// Per-rule lookup state. Carries the typed discriminated rule lookup so
/// the feed provider can map each failure mode to the right
/// `ComplianceFeedState` (FM-7 / B3):
///   - `LookupFound` → proceed (`isResolved == true`).
///   - `LookupUnauthorized` → feed `error("authentication failed")`.
///   - `LookupNetworkError` → feed `error("network unreachable")`,
///     retain last good state.
///   - `LookupMissing` → feed `unknown`.
class ComplianceLookup {
  const ComplianceLookup({this.rule = const LookupMissing()});
  final LookupResult rule;

  int? get ruleId => rule is LookupFound ? (rule as LookupFound).id : null;

  bool get isResolved => rule is LookupFound;
  bool get isUnauthorized => rule is LookupUnauthorized;
  bool get isNetworkError =>
      !isUnauthorized && rule is LookupNetworkError;
}

/// Builds a configured [ComplianceRestDataSource] from current site URL +
/// secure-stored api_key. Returns null when either is missing OR when
/// the user isn't authenticated. The auth-status gate is critical: the
/// storage layer is updated by the auth flow but cleared lazily on
/// sign-out, so a sign-out followed by a fast sign-in can briefly read
/// the prior site's siteUrl + token from storage and rebuild a data
/// source pointed at the prior rxg. Gating on `authStatusProvider`
/// forces this provider to invalidate whenever auth state transitions,
/// so it only ever resolves once auth has actually settled on the new
/// site. The underlying HTTP client is closed on provider dispose.
final complianceRestDataSourceProvider =
    FutureProvider<ComplianceRestDataSource?>((ref) async {
  final authStatus = ref.watch(auth.authStatusProvider);
  if (authStatus?.isAuthenticated != true) return null;
  final storage = ref.watch(storageServiceProvider);
  final secure = ref.watch(secureStorageServiceProvider);
  final siteUrl = storage.siteUrl;
  if (siteUrl == null || siteUrl.isEmpty) return null;
  final apiKey = await secure.getToken();
  if (apiKey == null || apiKey.isEmpty) return null;
  final ds = ComplianceRestDataSource(siteUrl: siteUrl, apiKey: apiKey);
  ref.onDispose(ds.close);
  return ds;
});

/// Local fleet_node discovery with explicit status. The status drives the
/// repository's safe-fallback decision: only [LocalFleetNodeStatus.standalone]
/// should allow snapshot rows with a missing/null `fleet_node_id`. The
/// `unknown` status (lookup failed) must NOT enable that fallback.
final localFleetNodeProvider =
    FutureProvider<LocalFleetNodeResult>((ref) async {
  final rest = await ref.watch(complianceRestDataSourceProvider.future);
  if (rest == null) {
    return const LocalFleetNodeResult(LocalFleetNodeStatus.unknown);
  }
  return rest.discoverLocalFleetNode();
});

/// Per-rule lookup. Keyed by [ruleName] so the two rules don't share state.
/// Invalidate this provider on trigger 422 to force a fresh lookup (FM-7).
final complianceLookupProvider =
    FutureProvider.family<ComplianceLookup, String>((ref, ruleName) async {
  final rest = await ref.watch(complianceRestDataSourceProvider.future);
  if (rest == null) {
    LoggerService.warning(
      'lookup[$ruleName]: rest datasource is null (no siteUrl/api_key)',
      tag: 'ComplianceLookup',
    );
    return const ComplianceLookup();
  }
  final result = await rest.lookupRuleId(ruleName);
  LoggerService.debug(
    'lookup[$ruleName]: rule=${result.runtimeType}',
    tag: 'ComplianceLookup',
  );
  return ComplianceLookup(rule: result);
});

/// Builds a [ComplianceRepository] bound to one rule. Returns null while
/// dependencies are unresolved (lookup pending / failed). autoDispose keeps
/// each consumer's lifetime tight to the screen.
final complianceRepositoryProvider =
    FutureProvider.family.autoDispose<ComplianceRepository?, String>(
        (ref, ruleName) async {
  final lookup = await ref.watch(complianceLookupProvider(ruleName).future);
  final fleetNode = await ref.watch(localFleetNodeProvider.future);
  final rest = await ref.watch(complianceRestDataSourceProvider.future);
  if (!lookup.isResolved || rest == null) return null;
  // Discovery failure means we can't safely filter snapshot streams by
  // fleet_node — refuse to build the repository. The feed provider maps
  // this to ComplianceFeedState.error("installation status unavailable")
  // via the null path in B3 below, then transitions back to a fresh state
  // when the user retries (FM-7 / codex v2 blocker #2).
  if (!fleetNode.isResolved) return null;

  final cache = ref
      .watch(webSocketCacheIntegrationProvider)
      .complianceCacheService;
  final repo = ComplianceRepositoryImpl(
    ruleName: ruleName,
    ruleId: lookup.ruleId!,
    fleetNode: fleetNode,
    rest: rest,
    cache: cache,
  );
  ref.onDispose(repo.dispose);
  return repo;
});

/// Streams [ComplianceFeedState] for the named rule.
///
/// Loading → bootstrap → WS deltas. The pre-repository checks distinguish
/// the four lookup failure modes (FM-4 / FM-7 / B3):
///   - `LookupUnauthorized` (either component) → `error("authentication
///     failed")`. Auth is the most actionable signal so it wins over the
///     other failure types.
///   - `LookupNetworkError` (either component, no auth failure) →
///     `error("network unreachable")`. The repository would have served a
///     stale-but-good last-emitted state here, but at the feed level we
///     don't have one yet — surface the network error so the user can
///     retry.
///   - `LookupMissing` (either component) after one cache invalidation
///     retry → `unknown` ("seed template not applied yet").
///   - Both `LookupFound` → build the repository, bootstrap, watch.
///
/// Cache invalidation retry on `LookupMissing` covers the post-trigger
/// 403 case: the user's recheck POST returns 403 because the action ID is
/// stale; the wiring invalidates the lookup; we re-resolve once before
/// surfacing `unknown`.
final complianceFeedProvider =
    StreamProvider.family.autoDispose<ComplianceFeedState, String>(
  (ref, ruleName) async* {
    yield const ComplianceFeedState.loading();

    final rest = await ref.watch(complianceRestDataSourceProvider.future);
    if (rest == null) {
      yield const ComplianceFeedState.error('authentication failed');
      return;
    }
    final fleetNode = await ref.watch(localFleetNodeProvider.future);
    if (!fleetNode.isResolved) {
      yield const ComplianceFeedState.error('network unreachable');
      return;
    }

    final lookup =
        await ref.watch(complianceLookupProvider(ruleName).future);
    // Order matters: unauthorized > network > missing.
    if (lookup.isUnauthorized) {
      yield const ComplianceFeedState.error('authentication failed');
      return;
    }
    if (lookup.isNetworkError) {
      yield const ComplianceFeedState.error('network unreachable');
      return;
    }
    if (!lookup.isResolved) {
      // LookupMissing is the steady state on rxgs that don't have the FDK
      // compliance template applied (e.g. older versions, customer sites).
      // The previous "invalidate + refetch on missing" logic created an
      // infinite retry loop on such rxgs — every rebuild fired two HTTP
      // calls per rule, and at 767 devices the cascade hit the rxg's 429
      // rate limit and dropped the WS. Stale-action-id invalidation (the
      // 403 path) is the trigger scheduler's responsibility, not ours.
      yield const ComplianceFeedState.unknown();
      return;
    }
    {
      if (lookup.isNetworkError) {
        yield const ComplianceFeedState.error('network unreachable');
        return;
      }
      if (!lookup.isResolved) {
        yield const ComplianceFeedState.unknown();
        return;
      }
    }

    final repo = await ref.watch(complianceRepositoryProvider(ruleName).future);
    if (repo == null) {
      // Belt-and-suspenders: any consistency gap between the checks above
      // and repository construction should still produce an error (not a
      // silent "compliant").
      yield const ComplianceFeedState.error('installation status unavailable');
      return;
    }
    final initial = await repo.bootstrap();
    yield initial;
    yield* repo.watch();
  },
);

/// TR-9 retry scheduler. **One pending retry per rule per window.**
///
/// Lifecycle of a window:
///   1. First [fire] starts the retry timer with a captured baseline
///      (the repository's `latestKnownCheckedAt` at trigger time, or
///      a "now()" sentinel if bootstrap hasn't completed yet).
///   2. Subsequent [fire] calls in the same window send their own initial
///      POST (the spec says "one initial POST" per user action), and the
///      pending retry's baseline + timer are RESET to the latest action
///      (spec TR-9: "later actions reset the baseline but don't multiply
///      retries"). Still one pending retry per rule per window.
///   3. When the timer fires, the scheduler reads `latestKnownCheckedAt`
///      again and only sends the retry if the snapshot hasn't advanced
///      past the captured baseline.
///
/// M3 guard: between fire() and the timer firing, we hold an open
/// `ProviderSubscription` on the repository provider so it isn't
/// auto-disposed while a retry is pending. That subscription is closed
/// when the retry runs (or is replaced/cancelled), restoring normal
/// autoDispose behavior. This sidesteps `_ref.exists` returning false
/// for short-lived consumers (the original M3 fix had that failure mode
/// in tests).
///
/// The 30s default can be shortened via [retryDelay] for tests.
class TriggerRetryScheduler {
  TriggerRetryScheduler(
    this._ref, {
    this.retryDelay = const Duration(seconds: 30),
  });

  final Ref _ref;
  final Duration retryDelay;
  final Map<String, _RetryState> _pending = {};
  bool _disposed = false;

  Future<TriggerOutcome> fire(String ruleName) async {
    final repo =
        await _ref.read(complianceRepositoryProvider(ruleName).future);
    if (repo == null) return TriggerOutcome.notFound;

    final outcome = await repo.triggerRecheck();
    switch (outcome) {
      case TriggerOutcome.queued:
        _resetRetry(ruleName, repo);
        break;
      case TriggerOutcome.notFound:
        // Action ID likely stale; invalidate the lookup so the next fire path
        // re-fetches. (FM-7.) The feed provider will surface `unknown` on the
        // next bootstrap if the seed is genuinely missing — no error banner
        // needed for this transient.
        _ref.invalidate(complianceLookupProvider(ruleName));
        break;
      case TriggerOutcome.unauthorized:
      case TriggerOutcome.networkError:
        // B3 / FM-7: surface auth/network failures observed at trigger time
        // through the feed stream so the UI can react. The WS path would
        // otherwise never see this failure mode (200 from the
        // notification-action POST is the only thing the WS cache hears
        // about). Repository decides whether to suppress (e.g., a fresh
        // snapshot arrived 5 seconds ago).
        repo.emitTriggerError(outcome);
        break;
    }
    return outcome;
  }

  /// Update the pending retry's baseline + timer to the latest fire. One
  /// pending retry per rule (TR-9), but the baseline reflects the most
  /// recent user action so the retry fires only if no snapshot has arrived
  /// since the LATEST trigger.
  void _resetRetry(String ruleName, ComplianceRepository repo) {
    if (_disposed) return;
    _pending[ruleName]?.cancel();
    final baseline = repo.latestKnownCheckedAt ?? DateTime.now().toUtc();
    // Hold the repo provider alive while the retry is pending. Without
    // this, autoDispose tears it down between `fire()` returning and the
    // timer firing, so the retry callback would either silently no-op
    // (if guarded with `_ref.exists`) or re-instantiate a phantom repo
    // for a vanished consumer (the original race gemini flagged).
    final keepAlive = _ref.listen<AsyncValue<ComplianceRepository?>>(
      complianceRepositoryProvider(ruleName),
      (_, __) {},
    );
    final timer = Timer(retryDelay, () => _runRetry(ruleName, baseline));
    _pending[ruleName] = _RetryState(timer, baseline, keepAlive);
  }

  Future<void> _runRetry(String ruleName, DateTime baseline) async {
    final state = _pending.remove(ruleName);
    try {
      if (_disposed) return;
      final repo =
          await _ref.read(complianceRepositoryProvider(ruleName).future);
      if (repo == null) return;
      final fresher = repo.latestKnownCheckedAt;
      if (fresher != null && fresher.isAfter(baseline)) {
        return; // snapshot already advanced
      }
      LoggerService.info(
        'TriggerRetryScheduler: firing retry for $ruleName (no fresher snapshot)',
        tag: 'TriggerRetryScheduler',
      );
      final outcome = await repo.triggerRecheck();
      // Mirror the same error propagation as `fire()`. If the retry surfaces
      // an auth/network failure that the initial fire didn't, the feed
      // should reflect it.
      if (outcome == TriggerOutcome.unauthorized ||
          outcome == TriggerOutcome.networkError) {
        repo.emitTriggerError(outcome);
      }
    } finally {
      // Release the keep-alive once the retry has run (or been skipped).
      state?.keepAlive.close();
    }
  }

  void dispose() {
    _disposed = true;
    for (final s in _pending.values) {
      s.cancel();
    }
    _pending.clear();
  }
}

class _RetryState {
  _RetryState(this.timer, this.baseline, this.keepAlive);
  final Timer timer;
  final DateTime baseline;
  final ProviderSubscription<AsyncValue<ComplianceRepository?>> keepAlive;

  void cancel() {
    timer.cancel();
    keepAlive.close();
  }
}

/// Family-flavored provider so tests can override the retry delay without
/// touching production. The unit `family` parameter is unused beyond enabling
/// the override pattern.
final triggerRetrySchedulerProvider =
    Provider<TriggerRetryScheduler>((ref) {
  final scheduler = TriggerRetryScheduler(ref);
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

/// Subscribes to the photo-upload event bus and the WS speed-test-result
/// cache, firing the matching recheck trigger on each successful push.
///
/// - Photo upload of an AccessPoint → fire images recheck (spec TR-3).
/// - New speed_test_result for an AP → fire speed-test recheck.
///
/// Per spec TR-3 we only trigger after AP-scoped events. Other device types
/// are out of scope.
class ComplianceTriggerWiring {
  ComplianceTriggerWiring(this._ref);
  final Ref _ref;
  StreamSubscription<ImageUploadEvent>? _imageSub;
  /// AP-scoped speed-test result count last observed. `null` means we have
  /// never seen a callback yet — the first one establishes the baseline
  /// WITHOUT firing, regardless of whether it's empty (cache not yet
  /// hydrated) or non-empty (cache hydration delivering historical results).
  /// Subsequent callbacks fire when the count grew, which corresponds to a
  /// new FDK submission.
  ///
  /// This pattern handles BOTH timing orderings of `start()` vs. WS cache
  /// hydration — early activation (`main.dart` post-auth, before hydration)
  /// AND late activation (panel-build, after hydration). Earlier attempts
  /// to seed from `getCachedSpeedTestResults()` at start() time only worked
  /// for the late case.
  int? _lastApScopedResultCount;
  void Function(List<dynamic>)? _speedTestCallback;

  /// Starts both subscriptions. Invoked from
  /// [complianceTriggerWiringProvider]'s body so the wiring is live as soon
  /// as the provider is read by the app shell.
  void start() {
    final scheduler = _ref.read(triggerRetrySchedulerProvider);

    _imageSub = ImageUploadEventBus().imageUploaded.listen((event) {
      if (event.deviceType != DeviceTypes.accessPoint) return;
      scheduler.fire(ComplianceNames.imagesRule);
    });

    // Hook the speed-test cache. We count only AP-scoped results (those
    // with a non-null `tested_via_access_point_id` OR `access_point_id`).
    // The images rule covers ONTs separately; the speed-test rule we wire
    // here is AP-only per spec TR-3.
    //
    // First callback establishes the baseline silently (whether the cache
    // delivers a non-empty hydration snapshot or starts empty doesn't
    // matter — we just record the count). Subsequent callbacks fire when
    // the count grew, which corresponds to a fresh FDK submission.
    final speedTestCache = _ref
        .read(webSocketCacheIntegrationProvider)
        .speedTestCacheService;
    _speedTestCallback = (results) {
      final newCount = _countApScoped(results);
      final previous = _lastApScopedResultCount;
      // A *decrease* (cache clear on sign-out, row deletion, fleet
      // reconnect) is the only way `newCount < previous`. Treat it as a
      // baseline reset: the NEXT callback re-establishes the baseline
      // silently, so a fresh hydration after sign-out doesn't masquerade
      // as a new FDK submission. Closes the sign-out-then-sign-in
      // regression codex caught in the v5 review.
      if (previous != null && newCount < previous) {
        _lastApScopedResultCount = null;
        return;
      }
      _lastApScopedResultCount = newCount;
      if (previous != null && newCount > previous) {
        scheduler.fire(ComplianceNames.speedTestRule);
      }
    };
    speedTestCache.onSpeedTestResultData(_speedTestCallback!);
  }

  static int _countApScoped(List<dynamic> results) {
    var count = 0;
    for (final r in results) {
      // Dynamic access tolerates differences between the WS list payload
      // (List<SpeedTestResult>) and any future change to the cache shape.
      try {
        final apId =
            (r as dynamic).accessPointId ?? (r as dynamic).testedViaAccessPointId;
        if (apId != null) count++;
      } catch (_) {
        // Skip non-conforming entries silently — better than crashing the
        // callback for one bad row.
      }
    }
    return count;
  }

  void stop() {
    _imageSub?.cancel();
    _imageSub = null;
    if (_speedTestCallback != null) {
      _ref
          .read(webSocketCacheIntegrationProvider)
          .speedTestCacheService
          .removeSpeedTestResultCallback(_speedTestCallback!);
      _speedTestCallback = null;
    }
  }
}

/// Auto-starts the wiring on first read. Auto-stops when the provider is
/// disposed (typically app shutdown).
final complianceTriggerWiringProvider =
    Provider<ComplianceTriggerWiring>((ref) {
  final wiring = ComplianceTriggerWiring(ref);
  wiring.start();
  ref.onDispose(wiring.stop);
  return wiring;
});
