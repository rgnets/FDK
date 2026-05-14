import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';

/// One repository instance per rule (e.g. "FDK Missing Installation Images").
///
/// Responsibilities (per spec TR-4, TR-9):
/// - Bootstrap initial state from the REST snapshot endpoint.
/// - Subscribe to the WS snapshot cache and emit fresh state on each delta
///   that matches `(ruleId, fleetNodeId)`. Newer `checked_at` wins.
/// - Trigger the matching manual notification action and return the outcome.
///
/// IDs (ruleId, actionId, fleetNodeId) come from the provider layer rather
/// than from inside the repository — keeps the repository pure with respect
/// to its identity rather than coupling it to the lookup REST endpoint.
abstract class ComplianceRepository {
  /// Loads the current snapshot once. Emits `unknown` if RXG hasn't been
  /// seeded yet or the check has never run.
  Future<ComplianceFeedState> bootstrap();

  /// Stream of state changes. The first event mirrors [bootstrap]; subsequent
  /// events come from WS snapshot updates. The stream's lifetime is bound to
  /// the provider that owns the repository instance — call [dispose] on
  /// teardown.
  Stream<ComplianceFeedState> watch();

  /// POSTs the manual notification action. The 200 response only confirms the
  /// `NotificationEvent` was queued; the actual snapshot update arrives later
  /// via [watch]. Caller is responsible for the TR-9 retry timer.
  Future<TriggerOutcome> triggerRecheck();

  /// Pushes an `error` feed state through the watch stream, propagating a
  /// trigger-time failure (401 / network) that the [watch] stream wouldn't
  /// otherwise have seen — `triggerRecheck` returns a `TriggerOutcome` but
  /// nothing in the WS path mirrors that into a feed event. B3 / FM-7.
  ///
  /// Suppressed if the repository already holds a strictly newer snapshot
  /// (the api_key signing recent broadcasts is still valid, etc).
  void emitTriggerError(TriggerOutcome outcome);

  /// The most recent `checked_at` the repository has observed (via bootstrap
  /// or WS delta). The retry scheduler reads this to decide whether the post-
  /// trigger snapshot already advanced past the baseline (TR-9). Null until
  /// the first snapshot has been seen.
  DateTime? get latestKnownCheckedAt;

  /// Releases any subscriptions. Safe to call multiple times.
  void dispose();
}
