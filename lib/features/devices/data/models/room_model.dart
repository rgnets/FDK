import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

@freezed
class RoomModel with _$RoomModel {
  const factory RoomModel({
    required int id,
    required String name,
    String? building,
    String? floor,
    String? number,
  }) = _RoomModel;

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

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
    );
  }
}