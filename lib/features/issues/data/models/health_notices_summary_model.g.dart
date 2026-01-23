// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_notices_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthNoticesSummaryModelImpl _$$HealthNoticesSummaryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthNoticesSummaryModelImpl(
      notices: (json['notices'] as List<dynamic>?)
              ?.map(
                  (e) => HealthNoticeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      counts: json['counts'] == null
          ? const HealthCountsModel()
          : HealthCountsModel.fromJson(json['counts'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$HealthNoticesSummaryModelImplToJson(
        _$HealthNoticesSummaryModelImpl instance) =>
    <String, dynamic>{
      'notices': instance.notices.map((e) => e.toJson()).toList(),
      'counts': instance.counts.toJson(),
    };
