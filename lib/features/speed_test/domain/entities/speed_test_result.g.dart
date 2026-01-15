// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speed_test_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpeedTestResultImpl _$$SpeedTestResultImplFromJson(
        Map<String, dynamic> json) =>
    _$SpeedTestResultImpl(
      downloadSpeed: (json['download_speed'] as num).toDouble(),
      uploadSpeed: (json['upload_speed'] as num).toDouble(),
      latency: (json['latency'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      hasError: json['has_error'] as bool? ?? false,
      errorMessage: json['error_message'] as String?,
      localIpAddress: json['local_ip_address'] as String?,
      serverHost: json['server_host'] as String?,
    );

Map<String, dynamic> _$$SpeedTestResultImplToJson(
    _$SpeedTestResultImpl instance) {
  final val = <String, dynamic>{
    'download_speed': instance.downloadSpeed,
    'upload_speed': instance.uploadSpeed,
    'latency': instance.latency,
    'timestamp': instance.timestamp.toIso8601String(),
    'has_error': instance.hasError,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('error_message', instance.errorMessage);
  writeNotNull('local_ip_address', instance.localIpAddress);
  writeNotNull('server_host', instance.serverHost);
  return val;
}
