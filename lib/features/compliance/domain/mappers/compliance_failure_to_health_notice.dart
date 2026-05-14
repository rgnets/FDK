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
    deviceId: failure.deviceId.toString(),
    deviceName: failure.deviceName,
    deviceType: failure.deviceType,
  );
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
