import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:rgnets_fdk/features/issues/data/models/health_counts_model.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_notice_model.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_counts.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';

part 'health_notices_summary_model.freezed.dart';
part 'health_notices_summary_model.g.dart';

@freezed
class HealthNoticesSummaryModel with _$HealthNoticesSummaryModel {
  const factory HealthNoticesSummaryModel({
    @Default([]) List<HealthNoticeModel> notices,
    @Default(HealthCountsModel()) HealthCountsModel counts,
  }) = _HealthNoticesSummaryModel;

  const HealthNoticesSummaryModel._();

  factory HealthNoticesSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$HealthNoticesSummaryModelFromJson(json);

  List<HealthNotice> toNoticeEntities() =>
      notices.map((n) => n.toEntity()).toList();

  HealthCounts toCountsEntity() => counts.toEntity();
}
