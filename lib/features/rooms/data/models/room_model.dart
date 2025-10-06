import 'package:equatable/equatable.dart';

import 'package:rgnets_fdk/features/rooms/domain/entities/room.dart';

/// Model representing a room/location
class RoomModel extends Equatable {
  
  const RoomModel({
    required this.id,
    required this.name,
    this.roomNumber,
    this.deviceIds,
    this.metadata,
  });
  
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      roomNumber: json['room_number'] as String? ?? json['name'] as String,
      deviceIds: (json['device_ids'] as List?)?.cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  final String id;
  final String name;
  final String? roomNumber;
  final List<String>? deviceIds;
  final Map<String, dynamic>? metadata;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'room_number': roomNumber,
      'device_ids': deviceIds,
      'metadata': metadata,
    };
  }
  
  @override
  List<Object?> get props => [
    id,
    name,
    roomNumber,
    deviceIds,
    metadata,
  ];
}

extension RoomModelX on RoomModel {
  Room toEntity() {
    return Room(
      id: id,
      name: name,
      roomNumber: roomNumber,
      deviceIds: deviceIds,
      metadata: metadata,
    );
  }
}
