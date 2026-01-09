import 'dart:async';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/models/websocket_events.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/rooms/data/models/room_model.dart';
import 'package:rgnets_fdk/features/rooms/domain/entities/room.dart';

/// Routes raw WebSocket messages to typed events.
///
/// Parses raw [SocketMessage] objects **once** and emits strongly-typed
/// [WebSocketEvent] objects. Consumers can use `.when()` for O(1) dispatch.
class WebSocketMessageRouter {
  WebSocketMessageRouter({
    required WebSocketService socketService,
    Logger? logger,
  })  : _socketService = socketService,
        _logger = logger ?? Logger();

  final WebSocketService _socketService;
  final Logger _logger;

  final _eventController = StreamController<WebSocketEvent>.broadcast();
  final _deviceEventController = StreamController<DeviceEvent>.broadcast();
  final _roomEventController = StreamController<RoomEvent>.broadcast();
  final _notificationEventController =
      StreamController<NotificationEvent>.broadcast();
  final _syncEventController = StreamController<SyncEvent>.broadcast();
  final _connectionEventController =
      StreamController<ConnectionEvent>.broadcast();

  StreamSubscription<SocketMessage>? _messageSubscription;
  StreamSubscription<SocketConnectionState>? _connectionSubscription;
  bool _isStarted = false;

  /// All WebSocket events (union type)
  Stream<WebSocketEvent> get events => _eventController.stream;

  /// Device-specific events only
  Stream<DeviceEvent> get deviceEvents => _deviceEventController.stream;

  /// Room-specific events only
  Stream<RoomEvent> get roomEvents => _roomEventController.stream;

  /// Notification-specific events only
  Stream<NotificationEvent> get notificationEvents =>
      _notificationEventController.stream;

  /// Sync-specific events only
  Stream<SyncEvent> get syncEvents => _syncEventController.stream;

  /// Connection-specific events only
  Stream<ConnectionEvent> get connectionEvents =>
      _connectionEventController.stream;

  /// Whether the router is currently listening to WebSocket messages
  bool get isRunning => _isStarted;

  /// Start listening to WebSocket messages and routing them
  void start() {
    if (_isStarted) return;
    _isStarted = true;

    _messageSubscription = _socketService.messages.listen(_handleMessage);
    _connectionSubscription =
        _socketService.connectionState.listen(_handleConnectionState);

    _logger.d('WebSocketMessageRouter: Started');
  }

  /// Stop listening to WebSocket messages
  Future<void> stop() async {
    if (!_isStarted) return;
    _isStarted = false;

    await _messageSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _messageSubscription = null;
    _connectionSubscription = null;

    _logger.d('WebSocketMessageRouter: Stopped');
  }

  /// Dispose all resources
  Future<void> dispose() async {
    await stop();
    await Future.wait([
      _eventController.close(),
      _deviceEventController.close(),
      _roomEventController.close(),
      _notificationEventController.close(),
      _syncEventController.close(),
      _connectionEventController.close(),
    ]);
  }

  void _handleConnectionState(SocketConnectionState state) {
    final event = switch (state) {
      SocketConnectionState.connected => const ConnectionEvent.connected(),
      SocketConnectionState.disconnected =>
        const ConnectionEvent.disconnected(),
      SocketConnectionState.connecting =>
        const ConnectionEvent.reconnecting(0),
      SocketConnectionState.reconnecting =>
        const ConnectionEvent.reconnecting(1),
    };

    _connectionEventController.add(event);
    _eventController.add(WebSocketEvent.connection(event));
  }

  void _handleMessage(SocketMessage message) {
    try {
      final event = _parseToTypedEvent(message);
      if (event != null) {
        _eventController.add(event);
        _routeToSpecificStream(event);
      }
    } catch (e, stack) {
      _logger.e(
        'WebSocketMessageRouter: Failed to parse message type=${message.type}',
        error: e,
        stackTrace: stack,
      );
    }
  }

  void _routeToSpecificStream(WebSocketEvent event) {
    event.when(
      device: _deviceEventController.add,
      room: _roomEventController.add,
      notification: _notificationEventController.add,
      sync: _syncEventController.add,
      connection: _connectionEventController.add,
      unknown: (_, __) {},
    );
  }

  WebSocketEvent? _parseToTypedEvent(SocketMessage message) {
    final type = message.type.toLowerCase();
    final payload = message.payload;

    // Device events
    if (type.startsWith('device.') || _isDeviceResourceType(type)) {
      final deviceEvent = _parseDeviceEvent(type, payload);
      if (deviceEvent != null) {
        return WebSocketEvent.device(deviceEvent);
      }
    }

    // Room events
    if (type.startsWith('room.') || type.startsWith('pms_room')) {
      final roomEvent = _parseRoomEvent(type, payload);
      if (roomEvent != null) {
        return WebSocketEvent.room(roomEvent);
      }
    }

    // Notification events
    if (type.startsWith('notification.')) {
      final notificationEvent = _parseNotificationEvent(type, payload);
      if (notificationEvent != null) {
        return WebSocketEvent.notification(notificationEvent);
      }
    }

    // Sync events
    if (type.startsWith('sync.')) {
      final syncEvent = _parseSyncEvent(type, payload);
      if (syncEvent != null) {
        return WebSocketEvent.sync(syncEvent);
      }
    }

    // Handle summary/snapshot messages
    if (type == 'devices.summary') {
      return _parseDevicesSummary(payload);
    }
    if (type == 'rooms.summary') {
      return _parseRoomsSummary(payload);
    }

    // Skip heartbeat/ping messages silently
    if (type == 'system.heartbeat' || type == 'ping' || type == 'pong') {
      return null;
    }

    // Unknown message type - emit for debugging
    _logger.d('WebSocketMessageRouter: Unknown message type: $type');
    return WebSocketEvent.unknown(type: type, payload: payload);
  }

  bool _isDeviceResourceType(String type) {
    return type == 'access_points' ||
        type == 'media_converters' ||
        type == 'switch_devices' ||
        type == 'wlan_devices';
  }

  DeviceEvent? _parseDeviceEvent(String type, Map<String, dynamic> payload) {
    // Handle resource-type snapshot messages
    if (_isDeviceResourceType(type)) {
      final devices = _extractDevicesFromPayload(payload, type);
      if (devices.isNotEmpty) {
        return DeviceEvent.batchUpdate(devices);
      }
      return null;
    }

    // Handle explicit device events
    return switch (type) {
      'device.created' => _parseDeviceCreated(payload),
      'device.updated' => _parseDeviceUpdated(payload),
      'device.deleted' => DeviceEvent.deleted(payload['id']?.toString() ?? ''),
      'device.status_changed' => _parseDeviceStatusChanged(payload),
      _ => null,
    };
  }

  DeviceEvent? _parseDeviceCreated(Map<String, dynamic> payload) {
    final device = _parseDevice(payload);
    return device != null ? DeviceEvent.created(device) : null;
  }

  DeviceEvent? _parseDeviceUpdated(Map<String, dynamic> payload) {
    final device = _parseDevice(payload);
    return device != null ? DeviceEvent.updated(device) : null;
  }

  DeviceEvent _parseDeviceStatusChanged(Map<String, dynamic> payload) {
    return DeviceEvent.statusChanged(
      id: payload['id']?.toString() ?? '',
      status: payload['status']?.toString() ?? 'unknown',
      online: payload['online'] as bool?,
      lastSeen: payload['last_seen'] != null
          ? DateTime.tryParse(payload['last_seen'].toString())
          : null,
    );
  }

  Device? _parseDevice(Map<String, dynamic> payload) {
    try {
      // Try parsing as DeviceModel first (handles normalization)
      if (payload.containsKey('id') && payload.containsKey('type')) {
        final model = DeviceModel.fromJson(payload);
        return model.toEntity();
      }
      return null;
    } catch (e) {
      _logger.w('WebSocketMessageRouter: Failed to parse device: $e');
      return null;
    }
  }

  List<Device> _extractDevicesFromPayload(
    Map<String, dynamic> payload,
    String resourceType,
  ) {
    final List<dynamic>? items = payload['results'] as List<dynamic>? ??
        payload['data'] as List<dynamic>? ??
        payload['items'] as List<dynamic>?;

    if (items == null) return [];

    final devices = <Device>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;

      try {
        final normalized = _normalizeDeviceData(item, resourceType);
        if (normalized != null) {
          final model = DeviceModel.fromJson(normalized);
          devices.add(model.toEntity());
        }
      } catch (e) {
        _logger.w('WebSocketMessageRouter: Failed to parse device item: $e');
      }
    }
    return devices;
  }

  Map<String, dynamic>? _normalizeDeviceData(
    Map<String, dynamic> data,
    String resourceType,
  ) {
    // Already normalized
    if (data.containsKey('type') &&
        data.containsKey('status') &&
        data.containsKey('id')) {
      return Map<String, dynamic>.from(data)..['id'] = data['id'].toString();
    }

    final idValue = data['id']?.toString() ?? '';

    return switch (resourceType) {
      'access_points' => _buildDeviceJson(
          data,
          id: 'ap_$idValue',
          type: 'access_point',
          defaultName: 'AP-$idValue',
        ),
      'media_converters' => _buildDeviceJson(
          data,
          id: 'ont_$idValue',
          type: 'ont',
          defaultName: 'ONT-$idValue',
        ),
      'switch_devices' => _buildDeviceJson(
          data,
          id: 'sw_$idValue',
          type: 'switch',
          defaultName: 'Switch-$idValue',
        ),
      'wlan_devices' => _buildDeviceJson(
          data,
          id: 'wlan_$idValue',
          type: 'wlan_controller',
          defaultName: 'WLAN-$idValue',
        ),
      _ => null,
    };
  }

  Map<String, dynamic> _buildDeviceJson(
    Map<String, dynamic> data, {
    required String id,
    required String type,
    required String defaultName,
  }) {
    return {
      'id': id,
      'name': data['name'] ?? data['nickname'] ?? defaultName,
      'type': type,
      'status': _determineStatus(data),
      'mac_address': data['mac'] ?? data['mac_address'] ?? '',
      'ip_address': data['ip'] ?? data['ip_address'] ?? data['host'] ?? '',
      'model': data['model'] ?? data['device'] ?? '',
      'serial_number': data['serial_number'] ?? '',
      'location': _extractLocation(data),
      'last_seen': data['last_seen'] ?? data['updated_at'],
      'metadata': data,
    };
  }

  String _determineStatus(Map<String, dynamic> data) {
    final onlineFlag = data['online'] as bool?;
    if (onlineFlag != null) {
      return onlineFlag ? 'online' : 'offline';
    }

    final status = data['status']?.toString().toLowerCase();
    if (status == 'online' || status == 'offline') {
      return status!;
    }

    final activeFlag = data['active'] as bool?;
    if (activeFlag != null) {
      return activeFlag ? 'online' : 'offline';
    }

    return 'unknown';
  }

  String _extractLocation(Map<String, dynamic> data) {
    if (data['pms_room'] is Map<String, dynamic>) {
      final pmsRoom = data['pms_room'] as Map<String, dynamic>;
      final name = pmsRoom['name']?.toString();
      if (name != null && name.isNotEmpty) return name;
    }
    return data['location']?.toString() ??
        data['room']?.toString() ??
        data['zone']?.toString() ??
        '';
  }

  RoomEvent? _parseRoomEvent(String type, Map<String, dynamic> payload) {
    return switch (type) {
      'room.created' || 'pms_room.created' => _parseRoomCreated(payload),
      'room.updated' || 'pms_room.updated' => _parseRoomUpdated(payload),
      'room.deleted' || 'pms_room.deleted' =>
        RoomEvent.deleted(payload['id']?.toString() ?? ''),
      'pms_rooms' => _parseRoomsBatch(payload),
      _ => null,
    };
  }

  RoomEvent? _parseRoomCreated(Map<String, dynamic> payload) {
    final room = _parseRoom(payload);
    return room != null ? RoomEvent.created(room) : null;
  }

  RoomEvent? _parseRoomUpdated(Map<String, dynamic> payload) {
    final room = _parseRoom(payload);
    return room != null ? RoomEvent.updated(room) : null;
  }

  RoomEvent? _parseRoomsBatch(Map<String, dynamic> payload) {
    final rooms = _extractRoomsFromPayload(payload);
    if (rooms.isNotEmpty) {
      return RoomEvent.batchUpdate(rooms);
    }
    return null;
  }

  Room? _parseRoom(Map<String, dynamic> payload) {
    try {
      final model = RoomModel.fromJson(payload);
      return model.toEntity();
    } catch (e) {
      _logger.w('WebSocketMessageRouter: Failed to parse room: $e');
      return null;
    }
  }

  List<Room> _extractRoomsFromPayload(Map<String, dynamic> payload) {
    final List<dynamic>? items = payload['results'] as List<dynamic>? ??
        payload['data'] as List<dynamic>? ??
        payload['items'] as List<dynamic>?;

    if (items == null) return [];

    final rooms = <Room>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;

      try {
        final model = RoomModel.fromJson(item);
        rooms.add(model.toEntity());
      } catch (e) {
        _logger.w('WebSocketMessageRouter: Failed to parse room item: $e');
      }
    }
    return rooms;
  }

  NotificationEvent? _parseNotificationEvent(
    String type,
    Map<String, dynamic> payload,
  ) {
    return switch (type) {
      'notification.new' || 'notification.received' => NotificationEvent.received(
          id: payload['id']?.toString() ?? '',
          title: payload['title']?.toString() ?? '',
          message: payload['message']?.toString() ?? '',
          type: payload['type']?.toString() ?? 'info',
          priority: payload['priority']?.toString() ?? 'low',
          deviceId: payload['device_id']?.toString(),
          location: payload['location']?.toString(),
          metadata: payload['metadata'] as Map<String, dynamic>?,
        ),
      'notification.read' =>
        NotificationEvent.read(payload['id']?.toString() ?? ''),
      'notification.cleared' => const NotificationEvent.cleared(),
      _ => null,
    };
  }

  SyncEvent? _parseSyncEvent(String type, Map<String, dynamic> payload) {
    return switch (type) {
      'sync.started' => const SyncEvent.started(),
      'sync.completed' => SyncEvent.completed(
          deviceCount: payload['device_count'] as int? ?? 0,
          roomCount: payload['room_count'] as int? ?? 0,
        ),
      'sync.failed' => SyncEvent.failed(payload['error']?.toString() ?? ''),
      'sync.delta' => _parseSyncDelta(payload),
      _ => null,
    };
  }

  SyncEvent _parseSyncDelta(Map<String, dynamic> payload) {
    final updatedDevices = <Device>[];
    final updatedRooms = <Room>[];

    if (payload['devices'] is List) {
      for (final item in payload['devices'] as List) {
        if (item is Map<String, dynamic>) {
          final device = _parseDevice(item);
          if (device != null) updatedDevices.add(device);
        }
      }
    }

    if (payload['rooms'] is List) {
      for (final item in payload['rooms'] as List) {
        if (item is Map<String, dynamic>) {
          final room = _parseRoom(item);
          if (room != null) updatedRooms.add(room);
        }
      }
    }

    return SyncEvent.delta(
      updatedDevices: updatedDevices.isNotEmpty ? updatedDevices : null,
      updatedRooms: updatedRooms.isNotEmpty ? updatedRooms : null,
      deletedDeviceIds: (payload['deleted_device_ids'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      deletedRoomIds: (payload['deleted_room_ids'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  WebSocketEvent? _parseDevicesSummary(Map<String, dynamic> payload) {
    final devices = _extractDevicesFromPayload(payload, 'devices.summary');
    if (devices.isNotEmpty) {
      return WebSocketEvent.device(DeviceEvent.snapshot(devices));
    }
    return null;
  }

  WebSocketEvent? _parseRoomsSummary(Map<String, dynamic> payload) {
    final rooms = _extractRoomsFromPayload(payload);
    if (rooms.isNotEmpty) {
      return WebSocketEvent.room(RoomEvent.snapshot(rooms));
    }
    return null;
  }
}
