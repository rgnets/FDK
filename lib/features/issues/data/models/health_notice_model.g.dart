// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_notice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthNoticeModelImpl _$$HealthNoticeModelImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthNoticeModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      severity: json['severity'] as String,
      shortMessage: json['short_message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      longMessage: json['long_message'] as String?,
      curedAt: json['cured_at'] == null
          ? null
          : DateTime.parse(json['cured_at'] as String),
      deviceId: json['device_id'] as String?,
      deviceName: json['device_name'] as String?,
      roomName: json['room_name'] as String?,
    );

Map<String, dynamic> _$$HealthNoticeModelImplToJson(
    _$HealthNoticeModelImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'severity': instance.severity,
    'short_message': instance.shortMessage,
    'created_at': instance.createdAt.toIso8601String(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('long_message', instance.longMessage);
  writeNotNull('cured_at', instance.curedAt?.toIso8601String());
  writeNotNull('device_id', instance.deviceId);
  writeNotNull('device_name', instance.deviceName);
  writeNotNull('room_name', instance.roomName);
  return val;
}
