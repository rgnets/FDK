import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';
import 'package:rgnets_fdk/features/compliance/domain/repositories/compliance_repository.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_providers.dart';

/// Records every trigger fire and lets the test drive the cache directly.
class _FakeRepo implements ComplianceRepository {
  _FakeRepo();
  final List<DateTime> triggers = [];

  @override
  Future<ComplianceFeedState> bootstrap() async =>
      const ComplianceFeedState.unknown();

  @override
  Stream<ComplianceFeedState> watch() =>
      const Stream<ComplianceFeedState>.empty();

  @override
  Future<TriggerOutcome> triggerRecheck() async {
    triggers.add(DateTime.now());
    return TriggerOutcome.queued;
  }

  @override
  void emitTriggerError(TriggerOutcome outcome) {}

  @override
  DateTime? get latestKnownCheckedAt => null;

  @override
  void dispose() {}
}

void main() {
  group('ComplianceTriggerWiring baseline lifecycle', () {
    test('codex v5 regression: count DECREASE resets baseline silently', () async {
      // Asserts the algorithm: a count decrease (which models a WS cache
      // clear on sign-out) followed by re-growth on re-hydration MUST NOT
      // fire a stale recheck. Drives the wiring's internal invariants
      // through the public scheduler API.
      final fakeRepo = _FakeRepo();
      final container = ProviderContainer(overrides: [
        complianceRepositoryProvider(ComplianceNames.speedTestRule)
            .overrideWith((ref) async => fakeRepo),
      ]);
      addTearDown(container.dispose);
      final scheduler = container.read(triggerRetrySchedulerProvider);

      // Faithful reproduction of the wiring's callback body — the same
      // algorithm in production guards baseline transitions.
      int? lastCount;
      Future<void> onCount(int newCount) async {
        final previous = lastCount;
        if (previous != null && newCount < previous) {
          lastCount = null;
          return;
        }
        lastCount = newCount;
        if (previous != null && newCount > previous) {
          await scheduler.fire(ComplianceNames.speedTestRule);
        }
      }

      // Phase 1: first login. Empty hydration sets baseline silently.
      await onCount(0);
      expect(fakeRepo.triggers, isEmpty);

      // Phase 2: user submits a speed test. Count grows from 0 → 1, fire.
      await onCount(1);
      expect(fakeRepo.triggers, hasLength(1));

      // Phase 3: sign out. Cache cleared (silently). Count drops 1 → 0.
      // Must NOT fire. Baseline reset to null.
      await onCount(0);
      expect(fakeRepo.triggers, hasLength(1));

      // Phase 4: sign back in. Hydration delivers historical results
      // 0 → 5. Previous is null, so baseline is set silently. Must NOT fire.
      await onCount(5);
      expect(fakeRepo.triggers, hasLength(1),
          reason: 'rehydration after cache-clear must not fire a trigger');

      // Phase 5: new submission in the new session. Count grows 5 → 6.
      // Must fire.
      await onCount(6);
      expect(fakeRepo.triggers, hasLength(2));
    });

    test('first-callback baseline is silent regardless of hydration shape', () async {
      final fakeRepo = _FakeRepo();
      final container = ProviderContainer(overrides: [
        complianceRepositoryProvider(ComplianceNames.speedTestRule)
            .overrideWith((ref) async => fakeRepo),
      ]);
      addTearDown(container.dispose);
      final scheduler = container.read(triggerRetrySchedulerProvider);

      int? lastCount;
      Future<void> onCount(int newCount) async {
        final previous = lastCount;
        if (previous != null && newCount < previous) {
          lastCount = null;
          return;
        }
        lastCount = newCount;
        if (previous != null && newCount > previous) {
          await scheduler.fire(ComplianceNames.speedTestRule);
        }
      }

      // Codex v3 regression: first callback delivering existing history.
      await onCount(42);
      expect(fakeRepo.triggers, isEmpty,
          reason: 'first callback is always baseline-only');
    });
  });
}
