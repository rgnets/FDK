// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomModelImpl _$$RoomModelImplFromJson(Map<String, dynamic> json) =>
    _$RoomModelImpl(
      id: parseRoomId(json['id']),
      name: json['name'] as String,
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      number: json['number'] as String?,
      deviceIds: (json['device_ids'] as List<dynamic>?)?.cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$RoomModelImplToJson(_$RoomModelImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('building', instance.building);
  writeNotNull('floor', instance.floor);
  writeNotNull('number', instance.number);
  writeNotNull('device_ids', instance.deviceIds);
  writeNotNull('metadata', instance.metadata);
  return val;
}
