import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_failures_aggregate_provider.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_providers.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/issue.dart';

/// Identifies a device for the compliance-issue lookup: the numeric rXg id plus
/// the resource type ('access_point', 'ont', …) as carried by
/// [complianceFailuresAggregateProvider]'s ComplianceFailure rows.
typedef DeviceComplianceKey = ({int deviceId, String deviceType});

/// Issues for a SINGLE device, derived from the backend compliance feeds — the
/// same `ComplianceFailure` rows the room-readiness view consumes — filtered to
/// this device. Reuses the exact room mapping:
///   - [ComplianceNames.imagesRule]    -> [Issue.missingImages]
///   - [ComplianceNames.speedTestRule] -> [Issue.missingSpeedTest]
/// Sorted critical-first. Empty when the device has no compliance failures.
final deviceComplianceIssuesProvider =
    Provider.family<List<Issue>, DeviceComplianceKey>((ref, key) {
  final failures = ref.watch(complianceFailuresAggregateProvider);

  final issues = <Issue>[];
  for (final f in failures) {
    if (f.deviceId != key.deviceId || f.deviceType != key.deviceType) {
      continue;
    }
    if (f.ruleName == ComplianceNames.imagesRule) {
      issues.add(Issue.missingImages(
        deviceId: f.deviceId,
        deviceName: f.deviceName,
        deviceType: _shortType(f.deviceType),
        detectedAt: f.checkedAt,
      ));
    } else if (f.ruleName == ComplianceNames.speedTestRule) {
      issues.add(Issue.missingSpeedTest(
        deviceId: f.deviceId,
        deviceName: f.deviceName,
        detectedAt: f.checkedAt,
      ));
    }
  }

  issues.sort((a, b) => a.severity.index.compareTo(b.severity.index));
  return issues;
});

/// rXg resource type -> short label used in [Issue] titles.
String _shortType(String complianceType) {
  switch (complianceType) {
    case 'access_point':
      return 'AP';
    case 'ont':
    case 'media_converter':
      return 'ONT';
    default:
      return complianceType;
  }
}
