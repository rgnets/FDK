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
  const RoomRemoteDataSourceImpl({
    required this.apiService,
  });

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
      ..i('RoomRemoteDataSource: API Base URL: ${EnvironmentConfig.apiBaseUrl}');

    final allRooms = <RoomModel>[];

    // Fetch all rooms with page_size=0 (no pagination)
    _logger.d('RoomRemoteDataSource: Fetching /api/pms_rooms.json?page_size=0...');
    final response = await apiService.get<dynamic>(
      '/api/pms_rooms.json?page_size=0',
    );

    if (response.data != null) {
      // Handle both response formats
      List<dynamic> results;
      
      if (response.data is List) {
        // Direct list response when page_size=0
        results = response.data as List<dynamic>;
        _logger.d('RoomRemoteDataSource: Got direct List with ${results.length} rooms');
      } else if (response.data is Map && response.data['results'] != null) {
        // Map with results field (shouldn't happen with page_size=0 but handle it)
        results = response.data['results'] as List<dynamic>;
        _logger.d('RoomRemoteDataSource: Got Map with results field containing ${results.length} rooms');
      } else {
        _logger.e('RoomRemoteDataSource: Unexpected response format: ${response.data.runtimeType}');
        throw Exception('Unexpected API response format');
      }

      // Process all room results
      for (final json in results) {
        final roomData = json as Map<String, dynamic>;
        
        // Build display name from room and property
        final roomNumber = roomData['room']?.toString();
        final propertyName = roomData['pms_property']?['name']?.toString();
        
        // Format as "(Building) Room" if we have both
        final displayName = propertyName != null && roomNumber != null
            ? '($propertyName) $roomNumber'
            : roomNumber ?? 'Room ${roomData['id']}';
        
        allRooms.add(RoomModel(
          id: roomData['id']?.toString() ?? '',
          name: displayName,
          deviceIds: _extractDeviceIds(roomData),
          metadata: roomData,
        ));
      }
    }

    if (allRooms.isEmpty) {
      _logger.w('RoomRemoteDataSource: No rooms returned from API');
      throw Exception('No rooms available from API');
    }

    _logger.i('RoomRemoteDataSource: Successfully fetched ${allRooms.length} total rooms from API');
    return allRooms;
  }

  @override
  Future<RoomModel> getRoom(String id) async {
    _logger.i('RoomRemoteDataSource: Fetching room $id from API');
    
    final response = await apiService.get<Map<String, dynamic>>('/api/pms_rooms/$id.json');

    if (response.data != null) {
      final roomData = response.data!;
      
      // Build display name from room and property
      final roomNumber = roomData['room']?.toString();
      final propertyName = roomData['pms_property']?['name']?.toString();
      
      // Format as "(Building) Room" if we have both
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

  /// Extract device IDs from room data following the established logic
  List<String> _extractDeviceIds(Map<String, dynamic> roomData) {
    final deviceIds = <String>{}; // Use Set to prevent duplicates
    final roomId = roomData['id']?.toString();

    if (roomId == null) {
      LoggerService.warning('Room ID is null, cannot extract devices', tag: 'RoomRemoteDataSource');
      return [];
    }

    // Log the room data structure to understand what we're working with
    LoggerService.logRoomDataStructure(roomId, roomData);

    // Track total devices in response for comparison
    var totalDevicesInResponse = 0;

    // Extract access point IDs from the access_points array
    // TRUST THE API - it returns the correct devices for each room
    if (roomData['access_points'] != null && roomData['access_points'] is List) {
      final apList = roomData['access_points'] as List;
      totalDevicesInResponse += apList.length;

      for (final ap in apList) {
        if (ap is Map && ap['id'] != null) {
          // Simply add all access points returned by the API
          deviceIds.add(ap['id'].toString());
        }
      }
    }

    // Extract media converter (ONT) IDs from the media_converters array
    // TRUST THE API - it returns the correct devices for each room
    if (roomData['media_converters'] != null && roomData['media_converters'] is List) {
      final mcList = roomData['media_converters'] as List;
      totalDevicesInResponse += mcList.length;

      for (final mc in mcList) {
        if (mc is Map && mc['id'] != null) {
          // Simply add all media converters returned by the API
          deviceIds.add(mc['id'].toString());
        }
      }
    }

    // Note: switch_ports are ports, not switches themselves
    // We should NOT include switch_ports as they are not devices
    // The actual switch devices come from switch_devices endpoint

    // Also check infrastructure_devices if present
    // TRUST THE API - it returns the correct devices for each room
    if (roomData['infrastructure_devices'] != null && roomData['infrastructure_devices'] is List) {
      final deviceList = roomData['infrastructure_devices'] as List;
      totalDevicesInResponse += deviceList.length;

      for (final device in deviceList) {
        if (device is Map && device['id'] != null) {
          // Simply add all infrastructure devices returned by the API
          deviceIds.add(device['id'].toString());
        }
      }
    }

    // Log extraction results
    final extractedList = deviceIds.toList();
    LoggerService.logDeviceExtraction(roomId, extractedList, totalInResponse: totalDevicesInResponse);

    return extractedList;
  }
}