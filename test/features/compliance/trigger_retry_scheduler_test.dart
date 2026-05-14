import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';
import 'package:rgnets_fdk/features/compliance/domain/repositories/compliance_repository.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_providers.dart';

/// In-memory repo that counts trigger calls and lets the test drive
/// `latestKnownCheckedAt`. Bypasses HTTP entirely.
class _FakeRepo implements ComplianceRepository {
  _FakeRepo();
  final List<DateTime> triggers = [];
  final List<TriggerOutcome> emittedErrors = [];
  DateTime? _latest;
  TriggerOutcome outcome = TriggerOutcome.queued;

  void advanceSnapshot(DateTime at) => _latest = at;

  @override
  Future<ComplianceFeedState> bootstrap() async =>
      const ComplianceFeedState.unknown();

  @override
  Stream<ComplianceFeedState> watch() =>
      const Stream<ComplianceFeedState>.empty();

  @override
  Future<TriggerOutcome> triggerRecheck() async {
    triggers.add(DateTime.now());
    return outcome;
  }

  @override
  void emitTriggerError(TriggerOutcome outcome) {
    emittedErrors.add(outcome);
  }

  @override
  DateTime? get latestKnownCheckedAt => _latest;

  @override
  void dispose() {}
}

ProviderContainer _containerWith(_FakeRepo repo, {Duration? retryDelay}) {
  return ProviderContainer(overrides: [
    complianceRepositoryProvider(ComplianceNames.imagesRule)
        .overrideWith((ref) async => repo),
    if (retryDelay != null)
      triggerRetrySchedulerProvider.overrideWith((ref) {
        final s = TriggerRetryScheduler(ref, retryDelay: retryDelay);
        ref.onDispose(s.dispose);
        return s;
      }),
  ]);
}

void main() {
  group('TriggerRetryScheduler — TR-9', () {
    test('first fire(): one initial POST + schedules a retry timer', () async {
      final repo = _FakeRepo();
      final container = _containerWith(repo, retryDelay: const Duration(seconds: 1));
      addTearDown(container.dispose);
      final scheduler = container.read(triggerRetrySchedulerProvider);

      final outcome = await scheduler.fire(ComplianceNames.imagesRule);
      expect(outcome, TriggerOutcome.queued);
      expect(repo.triggers, hasLength(1));
    });

    test('TR-9 baseline reset: 3 fires within 30s schedule a single retry from the LAST fire', () async {
      fakeAsync((async) {
        final repo = _FakeRepo();
        final container = _containerWith(repo, retryDelay: const Duration(seconds: 30));
        addTearDown(container.dispose);
        final scheduler = container.read(triggerRetrySchedulerProvider);

        // t=0: first fire → initial POST + retry scheduled for t=30.
        scheduler.fire(ComplianceNames.imagesRule);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(1));

        // t=5: second fire → initial POST, baseline + timer reset, retry now t=35.
        async.elapse(const Duration(seconds: 4)); // t=5
        scheduler.fire(ComplianceNames.imagesRule);
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(2));

        // t=10: third fire → initial POST, baseline + timer reset again, retry now t=40.
        async.elapse(const Duration(seconds: 5)); // t=10
        scheduler.fire(ComplianceNames.imagesRule);
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(3));

        // Advance to just past t=30 — the original retry window. Per TR-9 the
        // baseline + timer reset on every fire, so NO retry has fired yet.
        async.elapse(const Duration(seconds: 21)); // t=31
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(3),
            reason: 'retry should NOT fire at t=30 — last fire was at t=10 so timer reset to t=40');

        // Advance past t=40 — the retry window from the LAST fire.
        async.elapse(const Duration(seconds: 10)); // t=41
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(4),
            reason: 'exactly ONE retry, fired at t=40 (last_fire + retryDelay)');

        // Confirm only that single retry — no further retries from earlier fires.
        async.elapse(const Duration(seconds: 60));
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(4),
            reason: 'TR-9: still one pending retry per window, not three');
      });
    });

    test('retry suppressed when fresher snapshot arrived during window', () async {
      fakeAsync((async) {
        final repo = _FakeRepo();
        final container = _containerWith(repo, retryDelay: const Duration(seconds: 30));
        addTearDown(container.dispose);
        final scheduler = container.read(triggerRetrySchedulerProvider);

        scheduler.fire(ComplianceNames.imagesRule);
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(1));

        // Snapshot advances past baseline (which was null → now()).
        repo.advanceSnapshot(DateTime.now().add(const Duration(seconds: 1)));

        async.elapse(const Duration(seconds: 31));
        async.flushMicrotasks();

        // No retry was needed — fresher snapshot already arrived.
        expect(repo.triggers, hasLength(1));
      });
    });

    test('baseline-null edge case: if no snapshot ever arrives, retry fires once', () async {
      fakeAsync((async) {
        final repo = _FakeRepo(); // latestKnownCheckedAt stays null
        final container = _containerWith(repo, retryDelay: const Duration(seconds: 30));
        addTearDown(container.dispose);
        final scheduler = container.read(triggerRetrySchedulerProvider);

        scheduler.fire(ComplianceNames.imagesRule);
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(1));

        async.elapse(const Duration(seconds: 31));
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(2),
            reason: 'baseline = now() when null; no fresher snapshot → retry fires');

        // No further retries scheduled by the retry itself.
        async.elapse(const Duration(seconds: 60));
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(2));
      });
    });

    test('notFound outcome does not enqueue a retry', () async {
      fakeAsync((async) {
        final repo = _FakeRepo()..outcome = TriggerOutcome.notFound;
        final container = _containerWith(repo, retryDelay: const Duration(seconds: 30));
        addTearDown(container.dispose);
        final scheduler = container.read(triggerRetrySchedulerProvider);

        scheduler.fire(ComplianceNames.imagesRule);
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 31));
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(1),
            reason: '404/403 → no retry; lookup is invalidated instead');
      });
    });

    test('fire() with no repo (lookup unresolved) returns notFound', () async {
      final container = ProviderContainer(overrides: [
        complianceRepositoryProvider(ComplianceNames.imagesRule)
            .overrideWith((ref) async => null),
      ]);
      addTearDown(container.dispose);
      final scheduler = container.read(triggerRetrySchedulerProvider);
      expect(await scheduler.fire(ComplianceNames.imagesRule),
          TriggerOutcome.notFound);
    });
  });

  group('TriggerRetryScheduler — B3 / FM-7 error propagation', () {
    test('unauthorized outcome propagates through emitTriggerError', () async {
      final repo = _FakeRepo()..outcome = TriggerOutcome.unauthorized;
      final container = _containerWith(repo, retryDelay: const Duration(seconds: 1));
      addTearDown(container.dispose);
      final scheduler = container.read(triggerRetrySchedulerProvider);

      final outcome = await scheduler.fire(ComplianceNames.imagesRule);
      expect(outcome, TriggerOutcome.unauthorized);
      expect(repo.emittedErrors, [TriggerOutcome.unauthorized],
          reason: 'unauthorized must reach the feed via emitTriggerError');
    });

    test('networkError outcome propagates through emitTriggerError', () async {
      final repo = _FakeRepo()..outcome = TriggerOutcome.networkError;
      final container = _containerWith(repo, retryDelay: const Duration(seconds: 1));
      addTearDown(container.dispose);
      final scheduler = container.read(triggerRetrySchedulerProvider);

      await scheduler.fire(ComplianceNames.imagesRule);
      expect(repo.emittedErrors, [TriggerOutcome.networkError]);
    });

    test('queued outcome does NOT emit a trigger error', () async {
      final repo = _FakeRepo(); // default queued
      final container = _containerWith(repo, retryDelay: const Duration(seconds: 1));
      addTearDown(container.dispose);
      final scheduler = container.read(triggerRetrySchedulerProvider);

      await scheduler.fire(ComplianceNames.imagesRule);
      expect(repo.emittedErrors, isEmpty,
          reason: 'happy path stays silent — only the bootstrap/WS feed updates');
    });

    test('notFound outcome does NOT emit a trigger error (lookup invalidated instead)', () async {
      final repo = _FakeRepo()..outcome = TriggerOutcome.notFound;
      final container = _containerWith(repo, retryDelay: const Duration(seconds: 1));
      addTearDown(container.dispose);
      final scheduler = container.read(triggerRetrySchedulerProvider);

      await scheduler.fire(ComplianceNames.imagesRule);
      expect(repo.emittedErrors, isEmpty,
          reason: 'notFound is handled by invalidating the lookup, not surfacing an error banner');
    });

    test('retry-time auth failure also surfaces through emitTriggerError', () async {
      fakeAsync((async) {
        final repo = _FakeRepo(); // queued initially → retry scheduled
        final container = _containerWith(repo, retryDelay: const Duration(seconds: 30));
        addTearDown(container.dispose);
        final scheduler = container.read(triggerRetrySchedulerProvider);

        scheduler.fire(ComplianceNames.imagesRule);
        async.flushMicrotasks();
        // Flip the outcome BEFORE the retry fires (e.g. api_key expired
        // 25s into the retry window).
        repo.outcome = TriggerOutcome.unauthorized;
        async.elapse(const Duration(seconds: 31));
        async.flushMicrotasks();
        expect(repo.triggers, hasLength(2));
        expect(repo.emittedErrors, [TriggerOutcome.unauthorized]);
      });
    });
  });
}
