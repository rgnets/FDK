// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomModelImpl _$$RoomModelImplFromJson(Map<String, dynamic> json) =>
    _$RoomModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      building: json['building'] as String?,
      floor: json['floor'] as String?,
      number: json['number'] as String?,
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
  return val;
}
