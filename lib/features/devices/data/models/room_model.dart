import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/core/utils/room_id_parser.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

@freezed
class RoomModel with _$RoomModel {
  const factory RoomModel({
    @JsonKey(fromJson: parseRoomId) required int id,
    required String name,
    String? building,
    String? floor,
    String? number,
    @JsonKey(name: 'device_ids') List<String>? deviceIds,
    Map<String, dynamic>? metadata,
  }) = _RoomModel;

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    // The rXg's PmsRoom record stores the room label in a column named `room`,
    // not `name`. Snapshots for HABTM associations (e.g. `switch_devices`'
    // `pms_rooms` list) come through as `{id, room}` whereas singular AP /
    // ONT room nests come through as `{id, name}`. Normalize so both shapes
    // parse via the same freezed-generated factory.
    if (json['name'] == null && json['room'] != null) {
      final normalized = Map<String, dynamic>.from(json)
        ..['name'] = json['room'];
      return _$RoomModelFromJson(normalized);
    }
    return _$RoomModelFromJson(json);
  }

  const RoomModel._();
}

extension RoomModelX on RoomModel {
  Room toEntity() {
    return Room(
      id: id,
      name: name,
      building: building,
      floor: floor,
      number: number,
      deviceIds: deviceIds,
      metadata: metadata,
      description: metadata?['description'] as String?,
      location: metadata?['location'] as String?,
      createdAt: _parseDate(metadata?['createdAt'] ?? metadata?['created_at']),
      updatedAt: _parseDate(metadata?['updatedAt'] ?? metadata?['updated_at']),
    );
  }
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// The only raw-room keys the app actually reads: the entity promotes
/// description/location/created/updated in [RoomModelX.toEntity], and the room
/// detail screen shows area/capacity/department/last-maintenance. Everything
/// else in the raw rXg PmsRoom record is unused.
const Set<String> kRoomMetadataKeysToKeep = {
  'description',
  'location',
  'created_at',
  'createdAt',
  'updated_at',
  'updatedAt',
  'area_sqft',
  'capacity',
  'department',
  'last_maintenance',
};

/// Keep only the room metadata keys the app consumes (see
/// [kRoomMetadataKeysToKeep]), dropping the rest of the raw rXg record. This
/// keeps the cached room payload tiny so persisting the room cache is fast —
/// the room equivalent of the device models carrying only typed fields.
Map<String, dynamic>? slimRoomMetadata(Map<String, dynamic>? raw) {
  if (raw == null) return null;
  final slim = <String, dynamic>{};
  for (final key in kRoomMetadataKeysToKeep) {
    final value = raw[key];
    if (value != null) slim[key] = value;
  }
  return slim.isEmpty ? null : slim;
}
