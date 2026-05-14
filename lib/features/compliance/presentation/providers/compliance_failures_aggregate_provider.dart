import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_failure.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_providers.dart';

/// Flattens the two compliance feeds (images + speed-test) into a single
/// list of [ComplianceFailure]. Returns an empty list whenever a feed is
/// loading, errored, compliant, unknown, or indeterminate — only the
/// `failures` variant contributes rows. Per-rule status surfaces
/// (unknown / indeterminate / loading / error) intentionally render
/// nothing visually (see the user-override note in
/// `room_readiness_provider.dart` and `room_readiness_data_source.dart`).
///
/// Consumed by the room-readiness notifier to attach `Issue.missingImages`
/// / `Issue.missingSpeedTest` per AP id. See spec B5 / TR-7: no new UI
/// surface; the failures land on the same room-readiness widgets the mock
/// data source has used for development.
final complianceFailuresAggregateProvider =
    Provider<List<ComplianceFailure>>((ref) {
  final out = <ComplianceFailure>[];
  for (final ruleName in const [
    ComplianceNames.imagesRule,
    ComplianceNames.speedTestRule,
  ]) {
    final state = ref.watch(complianceFeedProvider(ruleName));
    final label = state.when(
      data: (feed) => feed.maybeWhen(
        unknown: () => 'unknown',
        loading: () => 'loading',
        compliant: () => 'compliant',
        failures: (list) {
          out.addAll(list);
          return 'failures(${list.length})';
        },
        indeterminate: () => 'indeterminate',
        error: (m) => 'error($m)',
        orElse: () => 'orElse',
      ),
      loading: () => 'AsyncLoading',
      error: (e, _) => 'AsyncError($e)',
    );
    LoggerService.debug(
      'aggregate[$ruleName] → $label',
      tag: 'ComplianceAggregate',
    );
  }
  return out;
});
