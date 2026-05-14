import 'package:freezed_annotation/freezed_annotation.dart';

part 'compliance_failure.freezed.dart';

@freezed
class ComplianceFailure with _$ComplianceFailure {
  const factory ComplianceFailure({
    required String deviceType,
    required int deviceId,
    required String deviceName,
    required String reason,
    required String ruleName,
    required int ruleId,
    required DateTime checkedAt,
  }) = _ComplianceFailure;
}
