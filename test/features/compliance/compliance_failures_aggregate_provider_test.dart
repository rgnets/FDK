import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_failure.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_feed_state.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_failures_aggregate_provider.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_providers.dart';

ComplianceFailure _failure(int id, String name, String rule) =>
    ComplianceFailure(
      deviceType: 'access_point',
      deviceId: id,
      deviceName: name,
      reason: 'r',
      ruleName: rule,
      ruleId: rule.hashCode & 0x7FFFFFFF,
      checkedAt: DateTime.utc(2026, 5, 13),
    );

ProviderContainer _withFeeds({
  required AsyncValue<ComplianceFeedState> images,
  required AsyncValue<ComplianceFeedState> speed,
}) {
  return ProviderContainer(
    overrides: [
      complianceFeedProvider(ComplianceNames.imagesRule).overrideWith(
        (ref) => Stream.value(images.value!),
      ),
      complianceFeedProvider(ComplianceNames.speedTestRule).overrideWith(
        (ref) => Stream.value(speed.value!),
      ),
    ],
  );
}

void main() {
  group('complianceFailuresAggregateProvider', () {
    test('flattens both feeds when both are in failures state', () async {
      final container = _withFeeds(
        images: AsyncValue.data(ComplianceFeedState.failures([
          _failure(1, 'AP-1', ComplianceNames.imagesRule),
        ])),
        speed: AsyncValue.data(ComplianceFeedState.failures([
          _failure(2, 'AP-2', ComplianceNames.speedTestRule),
        ])),
      );
      addTearDown(container.dispose);

      // Resolve the stream value.
      await container.read(
          complianceFeedProvider(ComplianceNames.imagesRule).future);
      await container.read(
          complianceFeedProvider(ComplianceNames.speedTestRule).future);

      final out = container.read(complianceFailuresAggregateProvider);
      expect(out.map((f) => f.deviceId).toSet(), {1, 2});
    });

    test('returns empty when both feeds are compliant', () async {
      final container = _withFeeds(
        images: const AsyncValue.data(ComplianceFeedState.compliant()),
        speed: const AsyncValue.data(ComplianceFeedState.compliant()),
      );
      addTearDown(container.dispose);

      await container.read(
          complianceFeedProvider(ComplianceNames.imagesRule).future);
      await container.read(
          complianceFeedProvider(ComplianceNames.speedTestRule).future);

      expect(container.read(complianceFailuresAggregateProvider), isEmpty);
    });

    test('returns failures from images only when speed is unknown', () async {
      final container = _withFeeds(
        images: AsyncValue.data(ComplianceFeedState.failures([
          _failure(1, 'AP-1', ComplianceNames.imagesRule),
        ])),
        speed: const AsyncValue.data(ComplianceFeedState.unknown()),
      );
      addTearDown(container.dispose);

      await container.read(
          complianceFeedProvider(ComplianceNames.imagesRule).future);
      await container.read(
          complianceFeedProvider(ComplianceNames.speedTestRule).future);

      final out = container.read(complianceFailuresAggregateProvider);
      expect(out.map((f) => f.deviceId), [1]);
    });
  });
}
