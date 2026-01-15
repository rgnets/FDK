import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:rgnets_fdk/features/issues/domain/entities/health_counts.dart';

part 'health_counts_model.freezed.dart';
part 'health_counts_model.g.dart';

@freezed
class HealthCountsModel with _$HealthCountsModel {
  const factory HealthCountsModel({
    @Default(0) int total,
    @Default(0) int fatal,
    @Default(0) int critical,
    @Default(0) int warning,
    @Default(0) int notice,
  }) = _HealthCountsModel;

  factory HealthCountsModel.fromJson(Map<String, dynamic> json) =>
      _$HealthCountsModelFromJson(json);
}

extension HealthCountsModelX on HealthCountsModel {
  HealthCounts toEntity() {
    return HealthCounts(
      total: total,
      fatal: fatal,
      critical: critical,
      warning: warning,
      notice: notice,
    );
  }
}
