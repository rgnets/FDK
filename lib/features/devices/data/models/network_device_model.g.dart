// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_device_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ONTDeviceImpl _$$ONTDeviceImplFromJson(Map<String, dynamic> json) =>
    _$ONTDeviceImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      online: json['online'] as bool,
      note: json['note'] as String?,
      model: json['model'] as String?,
      version: json['version'] as String?,
      serialNumber: json['serial_number'] as String?,
      phase: json['phase'] as String?,
      mac: json['mac'] as String?,
      ip: json['ip'] as String?,
      isRegistered: json['is_registered'] as bool?,
      pmsRoom: json['pms_room'] as Map<String, dynamic>?,
      uptime: json['uptime'] as String?,
      switchPort: json['switch_port'] as Map<String, dynamic>?,
      onboardingStatus: json['ont_onboarding_status'] as Map<String, dynamic>?,
      ports: (json['ont_ports'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      images: json['images'] as List<dynamic>? ?? const [],
      $type: json['device_type'] as String?,
    );

Map<String, dynamic> _$$ONTDeviceImplToJson(_$ONTDeviceImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'online': instance.online,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('note', instance.note);
  writeNotNull('model', instance.model);
  writeNotNull('version', instance.version);
  writeNotNull('serial_number', instance.serialNumber);
  writeNotNull('phase', instance.phase);
  writeNotNull('mac', instance.mac);
  writeNotNull('ip', instance.ip);
  writeNotNull('is_registered', instance.isRegistered);
  writeNotNull('pms_room', instance.pmsRoom);
  writeNotNull('uptime', instance.uptime);
  writeNotNull('switch_port', instance.switchPort);
  writeNotNull('ont_onboarding_status', instance.onboardingStatus);
  val['ont_ports'] = instance.ports;
  val['images'] = instance.images;
  val['device_type'] = instance.$type;
  return val;
}

_$APDeviceImpl _$$APDeviceImplFromJson(Map<String, dynamic> json) =>
    _$APDeviceImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      online: json['online'] as bool,
      note: json['note'] as String?,
      model: json['model'] as String?,
      version: json['version'] as String?,
      serialNumber: json['serial_number'] as String?,
      phase: json['phase'] as String?,
      mac: json['mac'] as String?,
      ip: json['ip'] as String?,
      uptime: json['uptime'] as String?,
      connectionState: json['connection_state'] as String?,
      pmsRoom: json['pms_room'] as Map<String, dynamic>?,
      onboardingStatus: json['ap_onboarding_status'] as Map<String, dynamic>?,
      images: json['images'] as List<dynamic>? ?? const [],
      $type: json['device_type'] as String?,
    );

Map<String, dynamic> _$$APDeviceImplToJson(_$APDeviceImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'online': instance.online,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('note', instance.note);
  writeNotNull('model', instance.model);
  writeNotNull('version', instance.version);
  writeNotNull('serial_number', instance.serialNumber);
  writeNotNull('phase', instance.phase);
  writeNotNull('mac', instance.mac);
  writeNotNull('ip', instance.ip);
  writeNotNull('uptime', instance.uptime);
  writeNotNull('connection_state', instance.connectionState);
  writeNotNull('pms_room', instance.pmsRoom);
  writeNotNull('ap_onboarding_status', instance.onboardingStatus);
  val['images'] = instance.images;
  val['device_type'] = instance.$type;
  return val;
}

_$SwitchDeviceImpl _$$SwitchDeviceImplFromJson(Map<String, dynamic> json) =>
    _$SwitchDeviceImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      online: json['online'] as bool,
      note: json['note'] as String?,
      model: json['model'] as String?,
      version: json['version'] as String?,
      serialNumber: json['serial_number'] as String?,
      phase: json['phase'] as String?,
      mac: json['mac'] as String?,
      host: json['host'] as String?,
      ipAddress: json['ip_address'] as String?,
      ports: (json['switch_ports'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      lastConfigSync: json['last_config_sync_at'] == null
          ? null
          : DateTime.parse(json['last_config_sync_at'] as String),
      lastConfigSyncAttempt: json['last_config_sync_attempt_at'] == null
          ? null
          : DateTime.parse(json['last_config_sync_attempt_at'] as String),
      images: json['images'] as List<dynamic>? ?? const [],
      $type: json['device_type'] as String?,
    );

Map<String, dynamic> _$$SwitchDeviceImplToJson(_$SwitchDeviceImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'online': instance.online,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('note', instance.note);
  writeNotNull('model', instance.model);
  writeNotNull('version', instance.version);
  writeNotNull('serial_number', instance.serialNumber);
  writeNotNull('phase', instance.phase);
  writeNotNull('mac', instance.mac);
  writeNotNull('host', instance.host);
  writeNotNull('ip_address', instance.ipAddress);
  val['switch_ports'] = instance.ports;
  writeNotNull(
      'last_config_sync_at', instance.lastConfigSync?.toIso8601String());
  writeNotNull('last_config_sync_attempt_at',
      instance.lastConfigSyncAttempt?.toIso8601String());
  val['images'] = instance.images;
  val['device_type'] = instance.$type;
  return val;
}
