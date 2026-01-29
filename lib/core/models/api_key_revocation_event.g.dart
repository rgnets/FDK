// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_revocation_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiKeyRevocationEventImpl _$$ApiKeyRevocationEventImplFromJson(
        Map<String, dynamic> json) =>
    _$ApiKeyRevocationEventImpl(
      reason: json['reason'] as String,
      message: json['message'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ApiKeyRevocationEventImplToJson(
    _$ApiKeyRevocationEventImpl instance) {
  final val = <String, dynamic>{
    'reason': instance.reason,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('message', instance.message);
  writeNotNull('timestamp', instance.timestamp?.toIso8601String());
  return val;
}
