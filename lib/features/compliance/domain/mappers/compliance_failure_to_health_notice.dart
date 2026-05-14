import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_failure.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';

HealthNotice complianceFailureToHealthNotice(ComplianceFailure failure) {
  return HealthNotice(
    id: _syntheticId(failure),
    name: 'compliance_${_slugify(failure.ruleName)}_${failure.deviceId}',
    severity: HealthNoticeSeverity.notice,
    shortMessage: failure.reason,
    longMessage: '${failure.ruleName}: ${failure.reason}',
    createdAt: failure.checkedAt,
    deviceId: _fdkDeviceId(failure),
    deviceName: failure.deviceName,
    deviceType: failure.deviceType,
  );
}

/// Maps the rxg's `device_type` + raw integer id to the FDK's prefixed
/// device id form (`ap_<n>`, `ont_<n>`, `sw_<n>`, `wlan_<n>`) that the
/// `/devices/:id` route and device cache use as the lookup key. Without
/// this, tapping a synthetic compliance notice routes to a bare integer
/// path and the device detail screen reports "device not found".
String _fdkDeviceId(ComplianceFailure failure) {
  final prefix = switch (failure.deviceType) {
    'access_point' => 'ap_',
    'media_converter' => 'ont_',
    'switch' || 'switch_device' => 'sw_',
    'wlan_controller' || 'wlan_device' => 'wlan_',
    _ => '',
  };
  return '$prefix${failure.deviceId}';
}

List<HealthNotice> complianceFailuresToHealthNotices(
  Iterable<ComplianceFailure> failures,
) =>
    failures.map(complianceFailureToHealthNotice).toList();

int _syntheticId(ComplianceFailure failure) {
  final ruleHash = failure.ruleName.hashCode & 0x7FFFFFFF;
  return -((ruleHash % 100000) * 100000 + (failure.deviceId % 100000) + 1);
}

String _slugify(String input) =>
    input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
