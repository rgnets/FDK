// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_model_sealed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$APModelImpl _$$APModelImplFromJson(Map<String, dynamic> json) =>
    _$APModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
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
      connectionState: json['connection_state'] as String?,
      signalStrength: (json['signal_strength'] as num?)?.toInt(),
      connectedClients: (json['connected_clients'] as num?)?.toInt(),
      ssid: json['ssid'] as String?,
      channel: (json['channel'] as num?)?.toInt(),
      maxClients: (json['max_clients'] as num?)?.toInt(),
      currentUpload: (json['current_upload'] as num?)?.toDouble(),
      currentDownload: (json['current_download'] as num?)?.toDouble(),
      onboardingStatus: json['ap_onboarding_status'] == null
          ? null
          : OnboardingStatusPayload.fromJson(
              json['ap_onboarding_status'] as Map<String, dynamic>),
      $type: json['device_type'] as String?,
    );

Map<String, dynamic> _$$APModelImplToJson(_$APModelImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
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
  writeNotNull('note', instance.note);
  writeNotNull('images', instance.images);
  writeNotNull('health_notices',
      instance.healthNotices?.map((e) => e.toJson()).toList());
  writeNotNull('hn_counts', instance.hnCounts?.toJson());
  writeNotNull('connection_state', instance.connectionState);
  writeNotNull('signal_strength', instance.signalStrength);
  writeNotNull('connected_clients', instance.connectedClients);
  writeNotNull('ssid', instance.ssid);
  writeNotNull('channel', instance.channel);
  writeNotNull('max_clients', instance.maxClients);
  writeNotNull('current_upload', instance.currentUpload);
  writeNotNull('current_download', instance.currentDownload);
  writeNotNull('ap_onboarding_status', instance.onboardingStatus?.toJson());
  val['device_type'] = instance.$type;
  return val;
}

_$ONTModelImpl _$$ONTModelImplFromJson(Map<String, dynamic> json) =>
    _$ONTModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
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
      isRegistered: json['is_registered'] as bool?,
      switchPort: json['switch_port'] as Map<String, dynamic>?,
      onboardingStatus: json['ont_onboarding_status'] == null
          ? null
          : OnboardingStatusPayload.fromJson(
              json['ont_onboarding_status'] as Map<String, dynamic>),
      ports: (json['ont_ports'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      uptime: json['uptime'] as String?,
      phase: json['phase'] as String?,
      $type: json['device_type'] as String?,
    );

Map<String, dynamic> _$$ONTModelImplToJson(_$ONTModelImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
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
  writeNotNull('note', instance.note);
  writeNotNull('images', instance.images);
  writeNotNull('health_notices',
      instance.healthNotices?.map((e) => e.toJson()).toList());
  writeNotNull('hn_counts', instance.hnCounts?.toJson());
  writeNotNull('is_registered', instance.isRegistered);
  writeNotNull('switch_port', instance.switchPort);
  writeNotNull('ont_onboarding_status', instance.onboardingStatus?.toJson());
  writeNotNull('ont_ports', instance.ports);
  writeNotNull('uptime', instance.uptime);
  writeNotNull('phase', instance.phase);
  val['device_type'] = instance.$type;
  return val;
}

_$SwitchModelImpl _$$SwitchModelImplFromJson(Map<String, dynamic> json) =>
    _$SwitchModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
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
      host: json['host'] as String?,
      ports: (json['switch_ports'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      lastConfigSync: json['last_config_sync_at'] == null
          ? null
          : DateTime.parse(json['last_config_sync_at'] as String),
      lastConfigSyncAttempt: json['last_config_sync_attempt_at'] == null
          ? null
          : DateTime.parse(json['last_config_sync_attempt_at'] as String),
      cpuUsage: (json['cpu_usage'] as num?)?.toInt(),
      memoryUsage: (json['memory_usage'] as num?)?.toInt(),
      temperature: (json['temperature'] as num?)?.toInt(),
      $type: json['device_type'] as String?,
    );

Map<String, dynamic> _$$SwitchModelImplToJson(_$SwitchModelImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
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
  writeNotNull('note', instance.note);
  writeNotNull('images', instance.images);
  writeNotNull('health_notices',
      instance.healthNotices?.map((e) => e.toJson()).toList());
  writeNotNull('hn_counts', instance.hnCounts?.toJson());
  writeNotNull('host', instance.host);
  writeNotNull('switch_ports', instance.ports);
  writeNotNull(
      'last_config_sync_at', instance.lastConfigSync?.toIso8601String());
  writeNotNull('last_config_sync_attempt_at',
      instance.lastConfigSyncAttempt?.toIso8601String());
  writeNotNull('cpu_usage', instance.cpuUsage);
  writeNotNull('memory_usage', instance.memoryUsage);
  writeNotNull('temperature', instance.temperature);
  val['device_type'] = instance.$type;
  return val;
}

_$WLANModelImpl _$$WLANModelImplFromJson(Map<String, dynamic> json) =>
    _$WLANModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
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
      controllerType: json['controller_type'] as String?,
      managedAPs: (json['managed_aps'] as num?)?.toInt(),
      vlan: (json['vlan'] as num?)?.toInt(),
      totalUpload: (json['total_upload'] as num?)?.toInt(),
      totalDownload: (json['total_download'] as num?)?.toInt(),
      packetLoss: (json['packet_loss'] as num?)?.toDouble(),
      latency: (json['latency'] as num?)?.toInt(),
      restartCount: (json['restart_count'] as num?)?.toInt(),
      $type: json['device_type'] as String?,
    );

Map<String, dynamic> _$$WLANModelImplToJson(_$WLANModelImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
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
  writeNotNull('note', instance.note);
  writeNotNull('images', instance.images);
  writeNotNull('health_notices',
      instance.healthNotices?.map((e) => e.toJson()).toList());
  writeNotNull('hn_counts', instance.hnCounts?.toJson());
  writeNotNull('controller_type', instance.controllerType);
  writeNotNull('managed_aps', instance.managedAPs);
  writeNotNull('vlan', instance.vlan);
  writeNotNull('total_upload', instance.totalUpload);
  writeNotNull('total_download', instance.totalDownload);
  writeNotNull('packet_loss', instance.packetLoss);
  writeNotNull('latency', instance.latency);
  writeNotNull('restart_count', instance.restartCount);
  val['device_type'] = instance.$type;
  return val;
}
