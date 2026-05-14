import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_failure.dart';

part 'compliance_feed_state.freezed.dart';

@freezed
class ComplianceFeedState with _$ComplianceFeedState {
  const factory ComplianceFeedState.unknown() = _Unknown;
  const factory ComplianceFeedState.loading() = _Loading;
  const factory ComplianceFeedState.compliant() = _Compliant;
  const factory ComplianceFeedState.failures(List<ComplianceFailure> items) =
      _Failures;
  const factory ComplianceFeedState.indeterminate() = _Indeterminate;
  const factory ComplianceFeedState.error(String message) = _Error;
}
