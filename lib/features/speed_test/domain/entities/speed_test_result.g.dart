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
      id: (json['id'] as num?)?.toInt(),
      speedTestId: (json['speed_test_id'] as num?)?.toInt(),
      pmsRoomId: (json['pms_room_id'] as num?)?.toInt(),
      roomType: json['room_type'] as String?,
      accessPointId: (json['access_point_id'] as num?)?.toInt(),
      testedViaAccessPointId:
          (json['tested_via_access_point_id'] as num?)?.toInt(),
      testedViaMediaConverterId:
          (json['tested_via_media_converter_id'] as num?)?.toInt(),
      uplinkId: (json['uplink_id'] as num?)?.toInt(),
      isApplicable: json['is_applicable'] as bool? ?? true,
      passed: json['passed'] as bool?,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
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
  writeNotNull('id', instance.id);
  writeNotNull('speed_test_id', instance.speedTestId);
  writeNotNull('pms_room_id', instance.pmsRoomId);
  writeNotNull('room_type', instance.roomType);
  writeNotNull('access_point_id', instance.accessPointId);
  writeNotNull('tested_via_access_point_id', instance.testedViaAccessPointId);
  writeNotNull(
      'tested_via_media_converter_id', instance.testedViaMediaConverterId);
  writeNotNull('uplink_id', instance.uplinkId);
  val['is_applicable'] = instance.isApplicable;
  writeNotNull('passed', instance.passed);
  writeNotNull('completed_at', instance.completedAt?.toIso8601String());
  return val;
}
