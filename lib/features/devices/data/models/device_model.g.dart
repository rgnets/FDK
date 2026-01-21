// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceModelImpl _$$DeviceModelImplFromJson(Map<String, dynamic> json) =>
    _$DeviceModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      pmsRoom: json['pms_room'] == null
          ? null
          : RoomModel.fromJson(json['pms_room'] as Map<String, dynamic>),
      pmsRoomId: (json['pms_room_id'] as num?)?.toInt(),
      ipAddress: json['ip_address'] as String?,
      macAddress: json['mac_address'] as String?,
      location: json['location'] as String?,
      lastSeen: json['last_seen'] == null
          ? null
          : DateTime.parse(json['last_seen'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      model: json['model'] as String?,
      serialNumber: json['serial_number'] as String?,
      firmware: json['firmware'] as String?,
      signalStrength: (json['signal_strength'] as num?)?.toInt(),
      uptime: (json['uptime'] as num?)?.toInt(),
      connectedClients: (json['connected_clients'] as num?)?.toInt(),
      vlan: (json['vlan'] as num?)?.toInt(),
      ssid: json['ssid'] as String?,
      channel: (json['channel'] as num?)?.toInt(),
      totalUpload: (json['total_upload'] as num?)?.toInt(),
      totalDownload: (json['total_download'] as num?)?.toInt(),
      currentUpload: (json['current_upload'] as num?)?.toDouble(),
      currentDownload: (json['current_download'] as num?)?.toDouble(),
      packetLoss: (json['packet_loss'] as num?)?.toDouble(),
      latency: (json['latency'] as num?)?.toInt(),
      cpuUsage: (json['cpu_usage'] as num?)?.toInt(),
      memoryUsage: (json['memory_usage'] as num?)?.toInt(),
      temperature: (json['temperature'] as num?)?.toInt(),
      restartCount: (json['restart_count'] as num?)?.toInt(),
      maxClients: (json['max_clients'] as num?)?.toInt(),
      note: json['note'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      healthNotices: (json['health_notices'] as List<dynamic>?)
          ?.map((e) => HealthNoticeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hnCounts: json['hn_counts'] == null
          ? null
          : HealthCountsModel.fromJson(
              json['hn_counts'] as Map<String, dynamic>),
      phase: json['phase'] as String?,
    );

Map<String, dynamic> _$$DeviceModelImplToJson(_$DeviceModelImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'type': instance.type,
    'status': instance.status,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('pms_room', instance.pmsRoom?.toJson());
  writeNotNull('pms_room_id', instance.pmsRoomId);
  writeNotNull('ip_address', instance.ipAddress);
  writeNotNull('mac_address', instance.macAddress);
  writeNotNull('location', instance.location);
  writeNotNull('last_seen', instance.lastSeen?.toIso8601String());
  writeNotNull('metadata', instance.metadata);
  writeNotNull('model', instance.model);
  writeNotNull('serial_number', instance.serialNumber);
  writeNotNull('firmware', instance.firmware);
  writeNotNull('signal_strength', instance.signalStrength);
  writeNotNull('uptime', instance.uptime);
  writeNotNull('connected_clients', instance.connectedClients);
  writeNotNull('vlan', instance.vlan);
  writeNotNull('ssid', instance.ssid);
  writeNotNull('channel', instance.channel);
  writeNotNull('total_upload', instance.totalUpload);
  writeNotNull('total_download', instance.totalDownload);
  writeNotNull('current_upload', instance.currentUpload);
  writeNotNull('current_download', instance.currentDownload);
  writeNotNull('packet_loss', instance.packetLoss);
  writeNotNull('latency', instance.latency);
  writeNotNull('cpu_usage', instance.cpuUsage);
  writeNotNull('memory_usage', instance.memoryUsage);
  writeNotNull('temperature', instance.temperature);
  writeNotNull('restart_count', instance.restartCount);
  writeNotNull('max_clients', instance.maxClients);
  writeNotNull('note', instance.note);
  writeNotNull('images', instance.images);
  writeNotNull('health_notices',
      instance.healthNotices?.map((e) => e.toJson()).toList());
  writeNotNull('hn_counts', instance.hnCounts?.toJson());
  writeNotNull('phase', instance.phase);
  return val;
}
