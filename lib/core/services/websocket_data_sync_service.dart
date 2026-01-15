import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/notification_generation_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';
import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_local_data_source.dart';

class WebSocketDataSyncService {
  WebSocketDataSyncService({
    required WebSocketService socketService,
    required DeviceLocalDataSource deviceLocalDataSource,
    required RoomLocalDataSource roomLocalDataSource,
    required NotificationGenerationService notificationService,
    required CacheManager cacheManager,
    Logger? logger,
  }) : _socketService = socketService,
       _deviceLocalDataSource = deviceLocalDataSource,
       _roomLocalDataSource = roomLocalDataSource,
       _notificationService = notificationService,
       _cacheManager = cacheManager,
       _logger = logger ?? Logger();

  static const String _channelName = 'RxgChannel';
  static const List<String> _deviceResources = [
    'access_points',
    'media_converters',
    'switch_devices',
    'wlan_devices',
  ];
  static const List<String> _roomResources = ['pms_rooms'];

  final WebSocketService _socketService;
  final DeviceLocalDataSource _deviceLocalDataSource;
  final RoomLocalDataSource _roomLocalDataSource;
  final NotificationGenerationService _notificationService;
  final CacheManager _cacheManager;
  final Logger _logger;

  StreamSubscription<SocketMessage>? _messageSub;
  StreamSubscription<SocketConnectionState>? _stateSub;
  bool _started = false;

  final Map<String, List<DeviceModel>> _deviceSnapshots = {};
  final Map<String, List<RoomModel>> _roomSnapshots = {};
  final Set<String> _pendingSnapshots = {};
  Completer<void>? _initialSyncCompleter;
  Future<void>? _pendingDeviceCache;
  Future<void>? _pendingRoomCache;
  final _eventController = StreamController<WebSocketDataSyncEvent>.broadcast();

  bool get isRunning => _started;
  Stream<WebSocketDataSyncEvent> get events => _eventController.stream;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    _messageSub = _socketService.messages.listen(_handleMessage);
    _stateSub = _socketService.connectionState.listen(_handleConnectionState);

    if (_socketService.isConnected) {
      _requestSnapshots();
    }
  }

  Future<void> stop() async {
    _started = false;
    await _messageSub?.cancel();
    await _stateSub?.cancel();
    _messageSub = null;
    _stateSub = null;
    _pendingSnapshots.clear();
    _deviceSnapshots.clear();
    _roomSnapshots.clear();
    _initialSyncCompleter = null;
  }

  Future<void> dispose() async {
    await stop();
    await _eventController.close();
  }

  Future<void> syncInitialData({
    Duration timeout = const Duration(seconds: 45),
  }) async {
    await start();
    _pendingSnapshots
      ..clear()
      ..addAll(_deviceResources)
      ..addAll(_roomResources);
    _pendingDeviceCache = null;
    _pendingRoomCache = null;

    _initialSyncCompleter = Completer<void>();
    _requestSnapshots();

    await _initialSyncCompleter!.future.timeout(
      timeout,
      onTimeout: () {
        _logger.w('WebSocketDataSync: Initial sync timed out');
        return;
      },
    );

    // Wait for any pending cache operations to complete
    final pendingCaches = <Future<void>>[];
    if (_pendingDeviceCache != null) {
      pendingCaches.add(_pendingDeviceCache!);
    }
    if (_pendingRoomCache != null) {
      pendingCaches.add(_pendingRoomCache!);
    }
    if (pendingCaches.isNotEmpty) {
      _logger.i('WebSocketDataSync: Waiting for cache operations to complete');
      await Future.wait(pendingCaches).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.w('WebSocketDataSync: Cache operations timed out');
          return [];
        },
      );
      _logger.i('WebSocketDataSync: Cache operations completed');
    }
  }

  void _handleConnectionState(SocketConnectionState state) {
    if (state == SocketConnectionState.connected) {
      _logger.i('WebSocketDataSync: Socket connected, requesting snapshots');
      _requestSnapshots();
    }
  }

  void _requestSnapshots() {
    if (!_socketService.isConnected) {
      _logger.d('WebSocketDataSync: Socket not connected, skipping snapshot');
      return;
    }

    for (final resource in _deviceResources) {
      _sendSubscribe(resource);
      _sendSnapshotRequest(resource);
    }

    for (final resource in _roomResources) {
      _sendSubscribe(resource);
      _sendSnapshotRequest(resource);
    }
  }

  void _sendSubscribe(String resourceType) {
    final payload = jsonEncode({
      'action': 'subscribe_to_resource',
      'resource_type': resourceType,
    });
    _socketService.send({
      'command': 'message',
      'identifier': _channelIdentifier(),
      'data': payload,
    });
  }

  void _sendSnapshotRequest(String resourceType) {
    final requestId = 'snapshot-$resourceType-${DateTime.now().millisecondsSinceEpoch}';
    final payload = jsonEncode({
      'action': 'resource_action',
      'resource_type': resourceType,
      'crud_action': 'index',
      'page': 1,
      'page_size': 10000,
      'request_id': requestId,
    });
    _socketService.send({
      'command': 'message',
      'identifier': _channelIdentifier(),
      'data': payload,
    });
  }

  String _channelIdentifier() => jsonEncode(const {'channel': _channelName});

  void _handleMessage(SocketMessage message) {
    final resourceType = _resolveResourceType(message);
    if (resourceType == null) {
      return;
    }

    final snapshotItems = _extractSnapshotItems(message);
    if (snapshotItems == null) {
      return;
    }

    if (resourceType == 'devices.summary') {
      _handleDeviceSnapshot(snapshotItems, resourceType: null);
      _pendingSnapshots.removeAll(_deviceResources);
      _markSnapshotHandled();
      return;
    }

    if (resourceType == 'rooms.summary') {
      _handleRoomSnapshot(snapshotItems, resourceType: null);
      _pendingSnapshots.removeAll(_roomResources);
      _markSnapshotHandled();
      return;
    }

    if (_deviceResources.contains(resourceType)) {
      _handleDeviceSnapshot(snapshotItems, resourceType: resourceType);
      _pendingSnapshots.remove(resourceType);
      _markSnapshotHandled();
      return;
    }

    if (_roomResources.contains(resourceType)) {
      _handleRoomSnapshot(snapshotItems, resourceType: resourceType);
      _pendingSnapshots.remove(resourceType);
      _markSnapshotHandled();
    }
  }

  String? _resolveResourceType(SocketMessage message) {
    final payload = message.payload;
    final resourceType = payload['resource_type']?.toString();
    if (resourceType != null && resourceType.isNotEmpty) {
      return resourceType;
    }
    if (message.type == 'devices.summary') {
      return 'devices.summary';
    }
    if (message.type == 'rooms.summary') {
      return 'rooms.summary';
    }
    return null;
  }

  List<Map<String, dynamic>>? _extractSnapshotItems(SocketMessage message) {
    final payload = message.payload;
    if (payload['results'] is List) {
      return (payload['results'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (payload['data'] is List) {
      return (payload['data'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (payload['items'] is List) {
      return (payload['items'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (payload['results'] is List<dynamic>) {
      return (payload['results'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return null;
  }

  void _handleDeviceSnapshot(
    List<Map<String, dynamic>> items, {
    required String? resourceType,
  }) {
    final models = <DeviceModel>[];
    for (final item in items) {
      final normalized = _normalizeDeviceJson(item, resourceType: resourceType);
      if (normalized == null) {
        continue;
      }
      try {
        models.add(DeviceModel.fromJson(normalized));
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse device: $e');
      }
    }

    if (resourceType == null) {
      _deviceSnapshots
        ..clear()
        ..['devices.summary'] = models;
      _pendingDeviceCache = _cacheDevices(models);
      unawaited(_pendingDeviceCache);
      return;
    }

    _deviceSnapshots[resourceType] = models;
    if (_deviceResources.every(_deviceSnapshots.containsKey)) {
      final combined = <DeviceModel>[];
      for (final entry in _deviceResources) {
        combined.addAll(_deviceSnapshots[entry] ?? const []);
      }
      _pendingDeviceCache = _cacheDevices(combined);
      unawaited(_pendingDeviceCache);
    }
  }

  Future<void> _cacheDevices(List<DeviceModel> devices) async {
    _logger.i('WebSocketDataSync: Caching ${devices.length} devices');
    await _deviceLocalDataSource.cacheDevices(devices);
    final cacheKey = DeviceFieldSets.getCacheKey(
      'devices_list',
      DeviceFieldSets.listFields,
    );
    _cacheManager.invalidate(cacheKey);
    _notificationService.generateFromDevices(
      devices.map((model) => model.toEntity()).toList(),
    );
    _eventController.add(
      WebSocketDataSyncEvent.devicesCached(count: devices.length),
    );
  }

  void _handleRoomSnapshot(
    List<Map<String, dynamic>> items, {
    required String? resourceType,
  }) {
    final models = <RoomModel>[];
    for (final item in items) {
      try {
        models.add(_buildRoomModel(item));
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse room: $e');
      }
    }

    if (resourceType == null) {
      _roomSnapshots
        ..clear()
        ..['rooms.summary'] = models;
      _pendingRoomCache = _cacheRooms(models);
      unawaited(_pendingRoomCache);
      return;
    }

    _roomSnapshots[resourceType] = models;
    if (_roomResources.every(_roomSnapshots.containsKey)) {
      final combined = <RoomModel>[];
      for (final entry in _roomResources) {
        combined.addAll(_roomSnapshots[entry] ?? const []);
      }
      _pendingRoomCache = _cacheRooms(combined);
      unawaited(_pendingRoomCache);
    }
  }

  Future<void> _cacheRooms(List<RoomModel> rooms) async {
    _logger.i('WebSocketDataSync: Caching ${rooms.length} rooms');
    await _roomLocalDataSource.cacheRooms(rooms);
    _eventController.add(
      WebSocketDataSyncEvent.roomsCached(count: rooms.length),
    );
  }

  void _markSnapshotHandled() {
    if (_pendingSnapshots.isNotEmpty) {
      return;
    }
    if (_initialSyncCompleter != null &&
        !_initialSyncCompleter!.isCompleted) {
      _initialSyncCompleter!.complete();
    }
  }

  Map<String, dynamic>? _normalizeDeviceJson(
    Map<String, dynamic> data, {
    required String? resourceType,
  }) {
    if (data.containsKey('type') &&
        data.containsKey('status') &&
        data.containsKey('id')) {
      final normalized = Map<String, dynamic>.from(data);
      normalized['id'] = normalized['id'].toString();
      // Ensure hn_counts and health_notices are present even for pre-normalized data
      normalized['hn_counts'] ??= {
        'total': 0,
        'fatal': 0,
        'critical': 0,
        'warning': 0,
        'notice': 0,
      };
      normalized['health_notices'] ??= <Map<String, dynamic>>[];
      // Debug logging
      if (data['hn_counts'] != null) {
        _logger.d('Pre-normalized device ${data['name'] ?? data['id']}: hn_counts=${data['hn_counts']}');
      }
      return normalized;
    }

    final idValue = data['id']?.toString() ?? '';
    switch (resourceType) {
      case 'access_points':
        return _buildDeviceJson(
          data,
          id: 'ap_$idValue',
          type: 'access_point',
          defaultName: 'AP-$idValue',
        );
      case 'media_converters':
        return _buildDeviceJson(
          data,
          id: 'ont_$idValue',
          type: 'ont',
          defaultName: 'ONT-$idValue',
        );
      case 'switch_devices':
        return _buildDeviceJson(
          data,
          id: 'sw_$idValue',
          type: 'switch',
          defaultName: 'Switch-$idValue',
        );
      case 'wlan_devices':
        return _buildDeviceJson(
          data,
          id: 'wlan_$idValue',
          type: 'wlan_controller',
          defaultName: 'WLAN-$idValue',
        );
      default:
        return null;
    }
  }

  Map<String, dynamic> _buildDeviceJson(
    Map<String, dynamic> data, {
    required String id,
    required String type,
    required String defaultName,
  }) {
    // Debug: Log raw device data keys to diagnose missing hn_counts/health_notices
    final hasHnCounts = data['hn_counts'] != null;
    final hasHealthNotices = data['health_notices'] != null;

    // Always log first device of each type to see what backend sends
    _logger.i('RAW DEVICE DATA [$type]: keys=${data.keys.toList()}, hn_counts=$hasHnCounts, health_notices=$hasHealthNotices');
    if (hasHnCounts) {
      _logger.i('  hn_counts value: ${data['hn_counts']}');
    }
    if (hasHealthNotices) {
      _logger.i('  health_notices value: ${data['health_notices']}');
    }

    return {
      'id': id,
      'name': data['name'] ?? data['nickname'] ?? defaultName,
      'type': type,
      'status': _determineStatus(data),
      'pms_room_id': _extractPmsRoomId(data),
      'mac_address': data['mac'] ?? data['mac_address'] ?? '',
      'ip_address': data['ip'] ?? data['ip_address'] ?? data['host'] ?? '',
      'model': data['model'] ?? data['device'] ?? '',
      'serial_number': data['serial_number'] ?? '',
      'location': _extractLocation(data),
      'last_seen': data['last_seen'] ?? data['updated_at'],
      'images': _extractImages(data),
      'metadata': {
        ...data,
        // Ensure hn_counts and health_notices are in metadata for provider access
        'hn_counts': data['hn_counts'] ?? {
          'total': 0,
          'fatal': 0,
          'critical': 0,
          'warning': 0,
          'notice': 0,
        },
        'health_notices': data['health_notices'] ?? <Map<String, dynamic>>[],
      },
      'health_notices': data['health_notices'] ?? <Map<String, dynamic>>[],
      'hn_counts': data['hn_counts'] ?? {
        'total': 0,
        'fatal': 0,
        'critical': 0,
        'warning': 0,
        'notice': 0,
      },
    };
  }

  String _determineStatus(Map<String, dynamic> device) {
    final onlineFlag = device['online'] as bool?;
    final activeFlag = device['active'] as bool?;

    if (onlineFlag != null) {
      return onlineFlag ? 'online' : 'offline';
    }
    if (device['status']?.toString().toLowerCase() == 'online') {
      return 'online';
    }
    if (device['status']?.toString().toLowerCase() == 'offline') {
      return 'offline';
    }
    if (activeFlag != null) {
      return activeFlag ? 'online' : 'offline';
    }

    if (device['last_seen'] != null || device['updated_at'] != null) {
      try {
        final lastSeenStr = (device['last_seen'] ?? device['updated_at'])
            .toString();
        final lastSeen = DateTime.parse(lastSeenStr);
        final now = DateTime.now();
        final difference = now.difference(lastSeen);
        if (difference.inMinutes < 5) {
          return 'online';
        } else if (difference.inHours < 1) {
          return 'warning';
        } else {
          return 'offline';
        }
      } on Exception catch (_) {}
    }

    return 'unknown';
  }

  String _extractLocation(Map<String, dynamic> deviceMap) {
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      final pmsRoomName = pmsRoom['name']?.toString();
      if (pmsRoomName != null && pmsRoomName.isNotEmpty) {
        return pmsRoomName;
      }
    }
    return deviceMap['location']?.toString() ??
        deviceMap['room']?.toString() ??
        deviceMap['zone']?.toString() ??
        deviceMap['room_id']?.toString() ??
        '';
  }

  int? _extractPmsRoomId(Map<String, dynamic> deviceMap) {
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      final idValue = pmsRoom['id'];
      if (idValue is int) {
        return idValue;
      }
      if (idValue is String) {
        return int.tryParse(idValue);
      }
    }
    return null;
  }

  List<String>? _extractImages(Map<String, dynamic> deviceMap) {
    final imageKeys = [
      'images',
      'image',
      'image_url',
      'imageUrl',
      'photos',
      'photo',
      'photo_url',
      'photoUrl',
      'device_images',
      'device_image',
    ];

    for (final key in imageKeys) {
      final value = deviceMap[key];
      if (value == null) continue;

      if (value is List && value.isNotEmpty) {
        final urls = value
            .map((e) {
              if (e is String) return e;
              if (e is Map) {
                return e['url']?.toString() ?? e['src']?.toString();
              }
              return e?.toString();
            })
            .where((e) => e != null && e.isNotEmpty)
            .cast<String>()
            .toList();
        if (urls.isNotEmpty) return urls;
      }

      if (value is String && value.isNotEmpty) {
        return [value];
      }

      if (value is Map) {
        final url = value['url']?.toString() ?? value['src']?.toString();
        if (url != null && url.isNotEmpty) {
          return [url];
        }
      }
    }

    return null;
  }

  RoomModel _buildRoomModel(Map<String, dynamic> roomData) {
    final displayName = _buildRoomDisplayName(roomData);
    final rawId = roomData['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
    return RoomModel(
      id: id,
      name: displayName,
      deviceIds: _extractRoomDeviceIds(roomData),
      metadata: roomData,
    );
  }

  String _buildRoomDisplayName(Map<String, dynamic> roomData) {
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

  List<String> _extractRoomDeviceIds(Map<String, dynamic> roomData) {
    final deviceIds = <String>{};
    final roomId = roomData['id']?.toString();
    if (roomId == null) {
      return [];
    }

    void addDevices(List<dynamic>? list, {String? prefix}) {
      if (list == null) {
        return;
      }
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

class WebSocketDataSyncEvent {

  factory WebSocketDataSyncEvent.devicesCached({required int count}) =>
      WebSocketDataSyncEvent._(
        type: WebSocketDataSyncEventType.devicesCached,
        count: count,
      );

  factory WebSocketDataSyncEvent.roomsCached({required int count}) =>
      WebSocketDataSyncEvent._(
        type: WebSocketDataSyncEventType.roomsCached,
        count: count,
      );
  const WebSocketDataSyncEvent._({
    required this.type,
    required this.count,
  });

  final WebSocketDataSyncEventType type;
  final int count;
}

enum WebSocketDataSyncEventType {
  devicesCached,
  roomsCached,
}
