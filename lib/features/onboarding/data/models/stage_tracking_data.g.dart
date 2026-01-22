// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_tracking_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StageTrackingDataImpl _$$StageTrackingDataImplFromJson(
        Map<String, dynamic> json) =>
    _$StageTrackingDataImpl(
      stage: (json['stage'] as num).toInt(),
      maxStages: (json['max_stages'] as num).toInt(),
      enteredAt: DateTime.parse(json['entered_at'] as String),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$$StageTrackingDataImplToJson(
        _$StageTrackingDataImpl instance) =>
    <String, dynamic>{
      'stage': instance.stage,
      'max_stages': instance.maxStages,
      'entered_at': instance.enteredAt.toIso8601String(),
      'last_updated': instance.lastUpdated.toIso8601String(),
    };
