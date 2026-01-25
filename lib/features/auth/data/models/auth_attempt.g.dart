// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_attempt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthAttemptImpl _$$AuthAttemptImplFromJson(Map<String, dynamic> json) =>
    _$AuthAttemptImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      fqdn: json['fqdn'] as String? ?? '',
      login: json['login'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      siteName: json['site_name'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$AuthAttemptImplToJson(_$AuthAttemptImpl instance) {
  final val = <String, dynamic>{
    'timestamp': instance.timestamp.toIso8601String(),
    'fqdn': instance.fqdn,
    'login': instance.login,
    'success': instance.success,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('site_name', instance.siteName);
  writeNotNull('message', instance.message);
  return val;
}
