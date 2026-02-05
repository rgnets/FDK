// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_counts_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthCountsModelImpl _$$HealthCountsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthCountsModelImpl(
      total: (json['total'] as num?)?.toInt() ?? 0,
      fatal: (json['fatal'] as num?)?.toInt() ?? 0,
      critical: (json['critical'] as num?)?.toInt() ?? 0,
      warning: (json['warning'] as num?)?.toInt() ?? 0,
      notice: (json['notice'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$HealthCountsModelImplToJson(
        _$HealthCountsModelImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'fatal': instance.fatal,
      'critical': instance.critical,
      'warning': instance.warning,
      'notice': instance.notice,
    };
