import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/compliance/data/datasources/compliance_rest_data_source.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';
import 'package:rgnets_fdk/features/compliance/domain/repositories/compliance_repository.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_providers.dart';

/// Counts trigger fires per rule. Used to verify the room-readiness
/// pull-to-refresh wiring fires exactly one initial POST per rule (M1).
class _CountingRepo implements ComplianceRepository {
  _CountingRepo();
  int triggers = 0;

  @override
  Future<ComplianceFeedState> bootstrap() async =>
      const ComplianceFeedState.unknown();

  @override
  Stream<ComplianceFeedState> watch() =>
      const Stream<ComplianceFeedState>.empty();

  @override
  Future<TriggerOutcome> triggerRecheck() async {
    triggers++;
    return TriggerOutcome.queued;
  }

  @override
  void emitTriggerError(TriggerOutcome outcome) {}

  @override
  DateTime? get latestKnownCheckedAt => null;

  @override
  void dispose() {}
}

/// Minimal widget that mirrors the `onRefresh` closure on
/// `RoomReadinessScreen` line 81. We test the wiring in isolation rather
/// than pumping the full screen (which requires a deep set of provider
/// overrides for the readiness repository graph).
class _PullToRefreshHarness extends ConsumerWidget {
  const _PullToRefreshHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final scheduler = ref.read(triggerRetrySchedulerProvider);
          await Future.wait<void>([
            scheduler.fire(ComplianceNames.imagesRule),
            scheduler.fire(ComplianceNames.speedTestRule),
          ]);
        },
        child: ListView(
          // ensure the indicator can drag-trigger
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 600, child: Center(child: Text('content'))),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
      'M1: pull-to-refresh fires exactly one initial POST per compliance rule',
      (tester) async {
    final imagesRepo = _CountingRepo();
    final speedTestRepo = _CountingRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          complianceRepositoryProvider(ComplianceNames.imagesRule)
              .overrideWith((ref) async => imagesRepo),
          complianceRepositoryProvider(ComplianceNames.speedTestRule)
              .overrideWith((ref) async => speedTestRepo),
        ],
        child: const MaterialApp(home: _PullToRefreshHarness()),
      ),
    );
    await tester.pumpAndSettle();

    // Simulate the pull-to-refresh gesture.
    await tester.fling(find.text('content'), const Offset(0, 400), 1500);
    await tester.pumpAndSettle();

    expect(imagesRepo.triggers, 1,
        reason:
            'pull-to-refresh must fire exactly one initial POST for the images rule');
    expect(speedTestRepo.triggers, 1,
        reason:
            'pull-to-refresh must fire exactly one initial POST for the speed-test rule');
  });
}
