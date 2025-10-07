import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/features/rooms/data/models/room_model.dart';

abstract class RoomMockDataSource {
  Future<List<RoomModel>> getRooms();
  Future<RoomModel> getRoom(String id);
  Future<RoomModel> createRoom(RoomModel room);
  Future<RoomModel> updateRoom(RoomModel room);
  Future<void> deleteRoom(String id);
}

class RoomMockDataSourceImpl implements RoomMockDataSource {
  const RoomMockDataSourceImpl({required this.mockDataService});

  final MockDataService mockDataService;
  static final _logger = Logger();

  @override
  Future<List<RoomModel>> getRooms() async {
    _logger.i('RoomMockDataSource: Using mock data for development');

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Use JSON like production does for consistency
    final pmsRoomsJson = mockDataService.getMockPmsRoomsJson();
    final results = pmsRoomsJson['results'] as List<dynamic>;

    _logger.i(
      'RoomMockDataSource: Parsing ${results.length} mock rooms from JSON',
    );

    return results.map((json) {
      final roomData = json as Map<String, dynamic>;

      // Parse exactly like RemoteDataSource does
      final roomNumber = roomData['room']?.toString();
      final pmsProperty = roomData['pms_property'] as Map<String, dynamic>?;
      final propertyName = pmsProperty?['name']?.toString();

      // Build display name from room and property
      final displayName = propertyName != null && roomNumber != null
          ? '($propertyName) $roomNumber'
          : roomNumber ?? 'Room ${roomData['id']}';

      return RoomModel(
        id: roomData['id']?.toString() ?? '',
        name: displayName,
        deviceIds: _extractDeviceIds(roomData),
        metadata: roomData,
      );
    }).toList();
  }

  @override
  Future<RoomModel> getRoom(String id) async {
    _logger.i('RoomMockDataSource: Getting mock room $id');

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Use JSON like production does for consistency
    final pmsRoomsJson = mockDataService.getMockPmsRoomsJson();
    final results = (pmsRoomsJson['results'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final roomData = results.firstWhere(
      (room) => room['id'].toString() == id,
      orElse: () => throw Exception('Room with ID "$id" not found'),
    );

    // Parse exactly like RemoteDataSource does
    final roomNumber = roomData['room']?.toString();
    final pmsProperty = roomData['pms_property'];
    final propertyName = pmsProperty is Map<String, dynamic>
        ? pmsProperty['name']?.toString()
        : null;

    // Build display name from room and property
    final displayName = propertyName != null && roomNumber != null
        ? '($propertyName) $roomNumber'
        : roomNumber ?? 'Room ${roomData['id']}';

    return RoomModel(
      id: roomData['id']?.toString() ?? '',
      name: displayName,
      deviceIds: _extractDeviceIds(roomData),
      metadata: roomData,
    );
  }

  @override
  Future<RoomModel> createRoom(RoomModel room) async {
    _logger.i('RoomMockDataSource: Mock creating room ${room.name}');

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // In a real mock implementation, you might add it to an in-memory store
    // For now, just return the room with a generated ID if needed
    final updatedRoom = RoomModel(
      id: room.id.isNotEmpty
          ? room.id
          : 'mock_${DateTime.now().millisecondsSinceEpoch}',
      name: room.name,
      deviceIds: room.deviceIds,
      metadata: {
        ...?room.metadata,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );

    return updatedRoom;
  }

  @override
  Future<RoomModel> updateRoom(RoomModel room) async {
    _logger.i('RoomMockDataSource: Mock updating room ${room.id}');

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 350));

    // Return the room with updated metadata
    return RoomModel(
      id: room.id,
      name: room.name,
      deviceIds: room.deviceIds,
      metadata: {
        ...?room.metadata,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<void> deleteRoom(String id) async {
    _logger.i('RoomMockDataSource: Mock deleting room $id');

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 250));

    // In a real mock implementation, you might remove it from an in-memory store
    // For now, just log the action
    _logger.i('RoomMockDataSource: Mock deletion of room $id completed');
  }

  /// Extract device IDs from room data
  List<String> _extractDeviceIds(Map<String, dynamic> roomData) {
    final deviceIds = <String>{};

    // Extract access points
    if (roomData['access_points'] != null &&
        roomData['access_points'] is List) {
      final apList = roomData['access_points'] as List;
      for (final ap in apList) {
        if (ap is Map && ap['id'] != null) {
          deviceIds.add(ap['id'].toString());
        }
      }
    }

    // Extract media converters
    if (roomData['media_converters'] != null &&
        roomData['media_converters'] is List) {
      final mcList = roomData['media_converters'] as List;
      for (final mc in mcList) {
        if (mc is Map && mc['id'] != null) {
          deviceIds.add(mc['id'].toString());
        }
      }
    }

    return deviceIds.toList();
  }
}
