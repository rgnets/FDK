// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speed_test_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpeedTestResultImpl _$$SpeedTestResultImplFromJson(
        Map<String, dynamic> json) =>
    _$SpeedTestResultImpl(
      id: (json['id'] as num?)?.toInt(),
      speedTestId: (json['speed_test_id'] as num?)?.toInt(),
      testType: json['test_type'] as String?,
      source: json['source'] as String?,
      destination: json['destination'] as String?,
      port: (json['port'] as num?)?.toInt(),
      iperfProtocol: json['iperf_protocol'] as String?,
      downloadMbps: (json['download_mbps'] as num?)?.toDouble(),
      uploadMbps: (json['upload_mbps'] as num?)?.toDouble(),
      rtt: (json['rtt'] as num?)?.toDouble(),
      jitter: (json['jitter'] as num?)?.toDouble(),
      packetLoss: (json['packet_loss'] as num?)?.toDouble(),
      passed: json['passed'] as bool? ?? false,
      isApplicable: json['is_applicable'] as bool? ?? true,
      initiatedAt: json['initiated_at'] == null
          ? null
          : DateTime.parse(json['initiated_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      raw: json['raw'] as String?,
      imageUrl: json['image_url'] as String?,
      accessPointId: (json['access_point_id'] as num?)?.toInt(),
      testedViaAccessPointId:
          (json['tested_via_access_point_id'] as num?)?.toInt(),
      testedViaAccessPointRadioId:
          (json['tested_via_access_point_radio_id'] as num?)?.toInt(),
      testedViaMediaConverterId:
          (json['tested_via_media_converter_id'] as num?)?.toInt(),
      uplinkId: (json['uplink_id'] as num?)?.toInt(),
      wlanId: (json['wlan_id'] as num?)?.toInt(),
      pmsRoomId: (json['pms_room_id'] as num?)?.toInt(),
      roomType: json['room_type'] as String?,
      adminId: (json['admin_id'] as num?)?.toInt(),
      note: json['note'] as String?,
      scratch: json['scratch'] as String?,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      hasError: json['has_error'] as bool? ?? false,
      errorMessage: json['error_message'] as String?,
      localIpAddress: json['local_ip_address'] as String?,
      serverHost: json['server_host'] as String?,
    );

Map<String, dynamic> _$$SpeedTestResultImplToJson(
    _$SpeedTestResultImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('speed_test_id', instance.speedTestId);
  writeNotNull('test_type', instance.testType);
  writeNotNull('source', instance.source);
  writeNotNull('destination', instance.destination);
  writeNotNull('port', instance.port);
  writeNotNull('iperf_protocol', instance.iperfProtocol);
  writeNotNull('download_mbps', instance.downloadMbps);
  writeNotNull('upload_mbps', instance.uploadMbps);
  writeNotNull('rtt', instance.rtt);
  writeNotNull('jitter', instance.jitter);
  writeNotNull('packet_loss', instance.packetLoss);
  val['passed'] = instance.passed;
  val['is_applicable'] = instance.isApplicable;
  writeNotNull('initiated_at', instance.initiatedAt?.toIso8601String());
  writeNotNull('completed_at', instance.completedAt?.toIso8601String());
  writeNotNull('raw', instance.raw);
  writeNotNull('image_url', instance.imageUrl);
  writeNotNull('access_point_id', instance.accessPointId);
  writeNotNull('tested_via_access_point_id', instance.testedViaAccessPointId);
  writeNotNull(
      'tested_via_access_point_radio_id', instance.testedViaAccessPointRadioId);
  writeNotNull(
      'tested_via_media_converter_id', instance.testedViaMediaConverterId);
  writeNotNull('uplink_id', instance.uplinkId);
  writeNotNull('wlan_id', instance.wlanId);
  writeNotNull('pms_room_id', instance.pmsRoomId);
  writeNotNull('room_type', instance.roomType);
  writeNotNull('admin_id', instance.adminId);
  writeNotNull('note', instance.note);
  writeNotNull('scratch', instance.scratch);
  writeNotNull('created_by', instance.createdBy);
  writeNotNull('updated_by', instance.updatedBy);
  writeNotNull('created_at', instance.createdAt?.toIso8601String());
  writeNotNull('updated_at', instance.updatedAt?.toIso8601String());
  val['has_error'] = instance.hasError;
  writeNotNull('error_message', instance.errorMessage);
  writeNotNull('local_ip_address', instance.localIpAddress);
  writeNotNull('server_host', instance.serverHost);
  return val;
}
