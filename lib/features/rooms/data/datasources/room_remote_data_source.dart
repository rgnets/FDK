import 'dart:async';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/services/api_service.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/performance_monitor_service.dart';
import 'package:rgnets_fdk/features/rooms/data/models/room_model.dart';

abstract class RoomRemoteDataSource {
  Future<List<RoomModel>> getRooms();
  Future<RoomModel> getRoom(String id);
  Future<RoomModel> createRoom(RoomModel room);
  Future<RoomModel> updateRoom(RoomModel room);
  Future<void> deleteRoom(String id);
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  const RoomRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;
  static final _logger = Logger();

  @override
  Future<List<RoomModel>> getRooms() async {
    return PerformanceMonitorService.instance.trackFuture(
      'RoomRemoteDataSource.getRooms',
      _getRoomsImpl,
      metadata: {'environment': EnvironmentConfig.name},
    );
  }

  Future<List<RoomModel>> _getRoomsImpl() async {
    _logger
      ..i('RoomRemoteDataSource: Fetching ALL PMS rooms from API (page_size=0)')
      ..i('RoomRemoteDataSource: Environment is ${EnvironmentConfig.name}')
      ..i(
        'RoomRemoteDataSource: API Base URL: ${EnvironmentConfig.apiBaseUrl}',
      );

    final allRooms = <RoomModel>[];

    // Fetch all rooms with page_size=0 (no pagination)
    _logger.d(
      'RoomRemoteDataSource: Fetching /api/pms_rooms.json?page_size=0...',
    );
    final response = await apiService.get<dynamic>(
      '/api/pms_rooms.json?page_size=0',
    );

    final data = response.data;
    if (data != null) {
      final results = _extractResults(data);
      for (final json in results) {
        final roomData = json as Map<String, dynamic>;
        final displayName = _buildDisplayName(roomData);

        allRooms.add(
          RoomModel(
            id: roomData['id']?.toString() ?? '',
            name: displayName,
            deviceIds: _extractDeviceIds(roomData),
            metadata: roomData,
          ),
        );
      }
    }

    if (allRooms.isEmpty) {
      _logger.w('RoomRemoteDataSource: No rooms returned from API');
      throw Exception('No rooms available from API');
    }

    _logger.i(
      'RoomRemoteDataSource: Successfully fetched ${allRooms.length} total rooms from API',
    );
    return allRooms;
  }

  @override
  Future<RoomModel> getRoom(String id) async {
    _logger.i('RoomRemoteDataSource: Fetching room $id from API');

    final response = await apiService.get<Map<String, dynamic>>(
      '/api/pms_rooms/$id.json',
    );

    if (response.data != null) {
      final roomData = response.data!;
      final displayName = _buildDisplayName(roomData);

      return RoomModel(
        id: roomData['id']?.toString() ?? '',
        name: displayName,
        deviceIds: _extractDeviceIds(roomData),
        metadata: roomData,
      );
    }

    throw Exception('Room $id not found');
  }

  @override
  Future<RoomModel> createRoom(RoomModel room) async {
    // TODO(api): Implement when API supports room creation
    throw UnimplementedError('Room creation not yet supported by API');
  }

  @override
  Future<RoomModel> updateRoom(RoomModel room) async {
    // TODO(api): Implement when API supports room updates
    throw UnimplementedError('Room updates not yet supported by API');
  }

  @override
  Future<void> deleteRoom(String id) async {
    // TODO(api): Implement when API supports room deletion
    throw UnimplementedError('Room deletion not yet supported by API');
  }

  List<dynamic> _extractResults(dynamic data) {
    if (data is List<dynamic>) {
      _logger.d(
        'RoomRemoteDataSource: Got direct List with ${data.length} rooms',
      );
      return data;
    }
    if (data is Map<String, dynamic>) {
      final results = data['results'];
      if (results is List<dynamic>) {
        _logger.d(
          'RoomRemoteDataSource: Got Map with results field containing ${results.length} rooms',
        );
        return results;
      }
    }
    _logger.e(
      'RoomRemoteDataSource: Unexpected response format: ${data.runtimeType}',
    );
    throw Exception('Unexpected API response format');
  }

  String _buildDisplayName(Map<String, dynamic> roomData) {
    final roomNumber = roomData['room']?.toString();
    final pmsProperty = roomData['pms_property'];
    final propertyName = pmsProperty is Map<String, dynamic>
        ? pmsProperty['name']?.toString()
        : null;
    if (propertyName != null && roomNumber != null) {
      return '($propertyName) $roomNumber';
    }
    return roomNumber ?? 'Room ${roomData['id']}';
  }

  /// Extract device IDs from room data following the established logic
  List<String> _extractDeviceIds(Map<String, dynamic> roomData) {
    final deviceIds = <String>{}; // Use Set to prevent duplicates
    final roomId = roomData['id']?.toString();

    if (roomId == null) {
      LoggerService.warning(
        'Room ID is null, cannot extract devices',
        tag: 'RoomRemoteDataSource',
      );
      return [];
    }

    // Log the room data structure to understand what we're working with
    LoggerService.logRoomDataStructure(roomId, roomData);

    // Track total devices in response for comparison
    var totalDevicesInResponse = 0;

    void addDevices(List<dynamic>? list, {String? prefix}) {
      if (list == null) {
        return;
      }
      totalDevicesInResponse += list.length;

      for (final entry in list) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        final id = entry['id'];
        if (id != null) {
          deviceIds.add(prefix != null ? '$prefix$id' : id.toString());
        }

        final nested = entry['devices'];
        if (nested is List<dynamic>) {
          totalDevicesInResponse += nested.length;
          for (final device in nested) {
            if (device is Map<String, dynamic>) {
              final nestedId = device['id'];
              if (nestedId != null) {
                deviceIds.add(nestedId.toString());
              }
            }
          }
        }
      }
    }

    addDevices(roomData['access_points'] as List<dynamic>?, prefix: 'ap_');
    addDevices(roomData['media_converters'] as List<dynamic>?, prefix: 'ont_');
    addDevices(roomData['switch_devices'] as List<dynamic>?, prefix: 'sw_');
    addDevices(roomData['wlan_devices'] as List<dynamic>?, prefix: 'wlan_');

    // Note: switch_ports are ports, not switches themselves. Those should not
    // be added. The real switch devices come from switch_devices above.

    addDevices(roomData['infrastructure_devices'] as List<dynamic>?);

    final routerStats = roomData['router_stats'];
    if (routerStats is Map<String, dynamic>) {
      final routerDevices = routerStats['devices'];
      if (routerDevices is Map<String, dynamic>) {
        addDevices(routerDevices['recent'] as List<dynamic>?);
      }
    }

    // Log extraction results
    final extractedList = deviceIds.toList();
    LoggerService.logDeviceExtraction(
      roomId,
      extractedList,
      totalInResponse: totalDevicesInResponse,
    );

    return extractedList;
  }
}
