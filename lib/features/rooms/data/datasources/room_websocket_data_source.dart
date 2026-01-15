import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/utils/room_id_parser.dart';
import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';

/// Abstract interface for room data source (WebSocket-based).
abstract class RoomDataSource {
  Future<List<RoomModel>> getRooms();
  Future<RoomModel> getRoom(String id);
  Future<RoomModel> createRoom(RoomModel room);
  Future<RoomModel> updateRoom(RoomModel room);
  Future<void> deleteRoom(String id);
}

/// WebSocket-based data source for fetching rooms.
/// Replaces RoomRemoteDataSource with a WebSocket-backed implementation.
class RoomWebSocketDataSource implements RoomDataSource {
  RoomWebSocketDataSource({
    required WebSocketCacheIntegration webSocketCacheIntegration,
    Logger? logger,
  })  : _cacheIntegration = webSocketCacheIntegration,
        _logger = logger ?? Logger();

  final WebSocketCacheIntegration _cacheIntegration;
  final Logger _logger;

  static const String _roomResourceType = 'pms_rooms';

  WebSocketService get _webSocketService => _cacheIntegration.webSocketService;

  @override
  Future<List<RoomModel>> getRooms() async {
    _logger.i('RoomWebSocketDataSource: getRooms() called');

    // First try to get from cache
    final cachedRooms = _cacheIntegration.getCachedRooms();
    if (cachedRooms.isNotEmpty) {
      _logger.i(
        'RoomWebSocketDataSource: Returning ${cachedRooms.length} rooms from cache',
      );
      return cachedRooms.map(_mapToRoomModel).toList();
    }

    // If cache is empty, request snapshot and wait for data
    _logger.i('RoomWebSocketDataSource: Cache empty, requesting snapshot');

    if (!_webSocketService.isConnected) {
      _logger.w('RoomWebSocketDataSource: WebSocket not connected');
      return [];
    }

    // Request room snapshot
    _cacheIntegration.requestResourceSnapshot(_roomResourceType);

    // Wait a bit for data to arrive (with timeout)
    const maxWaitTime = Duration(seconds: 10);
    const pollInterval = Duration(milliseconds: 500);
    var elapsed = Duration.zero;

    while (elapsed < maxWaitTime) {
      await Future<void>.delayed(pollInterval);
      elapsed += pollInterval;

      final rooms = _cacheIntegration.getCachedRooms();
      if (rooms.isNotEmpty) {
        _logger.i(
          'RoomWebSocketDataSource: Got ${rooms.length} rooms after ${elapsed.inMilliseconds}ms',
        );
        return rooms.map(_mapToRoomModel).toList();
      }
    }

    _logger.w('RoomWebSocketDataSource: Timeout waiting for room data');
    return [];
  }

  @override
  Future<RoomModel> getRoom(String id) async {
    _logger.i('RoomWebSocketDataSource: getRoom($id) called');

    // First try to find in cache
    final cachedRooms = _cacheIntegration.getCachedRooms();
    final cached = cachedRooms
        .where((r) => r['id']?.toString() == id)
        .map(_mapToRoomModel)
        .firstOrNull;

    if (cached != null) {
      _logger.i('RoomWebSocketDataSource: Found room $id in cache');
      return cached;
    }

    // If WebSocket not connected, we can't fetch - throw so repository can use cache fallback
    if (!_webSocketService.isConnected) {
      _logger.w('RoomWebSocketDataSource: WebSocket not connected, room $id not in cache');
      throw Exception('Room not in cache and WebSocket not connected');
    }

    // Request specific room via WebSocket
    try {
      final response = await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: _roomResourceType,
        additionalData: {
          'crud_action': 'show',
          'id': id,
        },
        timeout: const Duration(seconds: 15),
      );

      final roomData = _extractRoomData(response.payload, response.raw);
      if (roomData != null) {
        return _mapToRoomModel(roomData);
      }

      throw Exception('Room not found: $id');
    } on Exception catch (e) {
      _logger.e('RoomWebSocketDataSource: Failed to get room $id: $e');
      throw Exception('Failed to get room: $e');
    }
  }

  @override
  Future<RoomModel> createRoom(RoomModel room) async {
    _logger.i('RoomWebSocketDataSource: createRoom() called');
    // Room creation not typically supported via WebSocket
    throw UnimplementedError('Room creation not yet supported via WebSocket');
  }

  @override
  Future<RoomModel> updateRoom(RoomModel room) async {
    _logger.i('RoomWebSocketDataSource: updateRoom(${room.id}) called');
    // Room updates not typically supported via WebSocket
    throw UnimplementedError('Room updates not yet supported via WebSocket');
  }

  @override
  Future<void> deleteRoom(String id) async {
    _logger.i('RoomWebSocketDataSource: deleteRoom($id) called');
    // Room deletion not typically supported via WebSocket
    throw UnimplementedError('Room deletion not yet supported via WebSocket');
  }

  Map<String, dynamic>? _extractRoomData(
    Map<String, dynamic> payload,
    Map<String, dynamic>? raw,
  ) {
    if (payload.containsKey('id')) return payload;
    if (payload['data'] is Map<String, dynamic>) {
      return payload['data'] as Map<String, dynamic>;
    }
    if (raw != null && raw['data'] is Map<String, dynamic>) {
      return raw['data'] as Map<String, dynamic>;
    }
    return null;
  }

  RoomModel _mapToRoomModel(Map<String, dynamic> roomData) {
    final displayName = _buildDisplayName(roomData);
    final roomNumber = roomData['room']?.toString();
    return RoomModel(
      id: parseRoomId(roomData['id']),
      name: displayName,
      number: roomNumber,
      deviceIds: _extractDeviceIds(roomData),
      metadata: roomData,
    );
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

  List<String> _extractDeviceIds(Map<String, dynamic> roomData) {
    final deviceIds = <String>{};

    void addDevices(List<dynamic>? list, {String? prefix}) {
      if (list == null) return;
      for (final entry in list) {
        if (entry is! Map<String, dynamic>) continue;
        final id = entry['id'];
        if (id != null) {
          deviceIds.add(prefix != null ? '$prefix$id' : id.toString());
        }

        final nested = entry['devices'];
        if (nested is List<dynamic>) {
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
    addDevices(roomData['infrastructure_devices'] as List<dynamic>?);

    final routerStats = roomData['router_stats'];
    if (routerStats is Map<String, dynamic>) {
      final routerDevices = routerStats['devices'];
      if (routerDevices is Map<String, dynamic>) {
        addDevices(routerDevices['recent'] as List<dynamic>?);
      }
    }

    return deviceIds.toList();
  }

}
