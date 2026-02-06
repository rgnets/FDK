import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/typed_device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_status_payload.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_local_data_source.dart';

// ARCHITECTURE NOTE (M1): This service imports from features/ layer, violating
// Clean Architecture (core should not depend on features). This is a known
// pattern across the codebase (16 core files import from features). Moving this
// service alone would create inconsistency. A holistic architecture refactoring
// using dependency inversion (abstract interfaces in core, implementations in
// features) is the recommended approach for a future dedicated sprint.
class WebSocketDataSyncService {
  WebSocketDataSyncService({
    required WebSocketService socketService,
    required APLocalDataSource apLocalDataSource,
    required ONTLocalDataSource ontLocalDataSource,
    required SwitchLocalDataSource switchLocalDataSource,
    required WLANLocalDataSource wlanLocalDataSource,
    required RoomLocalDataSource roomLocalDataSource,
    required CacheManager cacheManager,
    required StorageService storageService,
    Logger? logger,
  }) : _socketService = socketService,
       _apLocalDataSource = apLocalDataSource,
       _ontLocalDataSource = ontLocalDataSource,
       _switchLocalDataSource = switchLocalDataSource,
       _wlanLocalDataSource = wlanLocalDataSource,
       _roomLocalDataSource = roomLocalDataSource,
       _cacheManager = cacheManager,
       _storageService = storageService,
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
  final APLocalDataSource _apLocalDataSource;
  final ONTLocalDataSource _ontLocalDataSource;
  final SwitchLocalDataSource _switchLocalDataSource;
  final WLANLocalDataSource _wlanLocalDataSource;
  final RoomLocalDataSource _roomLocalDataSource;
  final CacheManager _cacheManager;
  final StorageService _storageService;
  final Logger _logger;

  StreamSubscription<SocketMessage>? _messageSub;
  StreamSubscription<SocketConnectionState>? _stateSub;
  bool _started = false;

  /// ID-to-Type index for routing device lookups
  final Map<String, String> _idToTypeIndex = {};

  final Map<String, List<RoomModel>> _roomSnapshots = {};
  final Set<String> _pendingSnapshots = {};
  Completer<void>? _initialSyncCompleter;
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
    _roomSnapshots.clear();
    _initialSyncCompleter = null;
  }

  Future<void> dispose() async {
    await stop();
    await _eventController.close();
    _apLocalDataSource.dispose();
    _ontLocalDataSource.dispose();
    _switchLocalDataSource.dispose();
    _wlanLocalDataSource.dispose();
  }

  /// Returns true if sync completed successfully, false if it timed out.
  Future<bool> syncInitialData({
    Duration timeout = const Duration(seconds: 45),
  }) async {
    await start();
    _pendingSnapshots
      ..clear()
      ..addAll(_deviceResources)
      ..addAll(_roomResources);
    _pendingRoomCache = null;

    _initialSyncCompleter = Completer<void>();
    _requestSnapshots();

    var timedOut = false;
    await _initialSyncCompleter!.future.timeout(
      timeout,
      onTimeout: () {
        _logger.w(
          'WebSocketDataSync: Initial sync timed out after ${timeout.inSeconds}s. '
          'Pending: $_pendingSnapshots',
        );
        timedOut = true;
      },
    );

    // Flush all typed caches to storage (may be partial on timeout)
    await _flushAllDeviceCaches();

    // Wait for any pending room cache operations
    if (_pendingRoomCache != null) {
      _logger.i('WebSocketDataSync: Waiting for room cache to complete');
      await _pendingRoomCache!.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.w('WebSocketDataSync: Room cache timed out');
          timedOut = true;
        },
      );
    }
    _logger.i(
      'WebSocketDataSync: Cache operations completed${timedOut ? ' (partial - timed out)' : ''}',
    );
    return !timedOut;
  }

  /// Flush all typed device caches to storage
  Future<void> _flushAllDeviceCaches() async {
    await Future.wait([
      _apLocalDataSource.flushNow(),
      _ontLocalDataSource.flushNow(),
      _switchLocalDataSource.flushNow(),
      _wlanLocalDataSource.flushNow(),
    ]);
    await _persistIdToTypeIndex();
  }

  /// Persist the ID-to-Type index to storage
  Future<void> _persistIdToTypeIndex() async {
    await _storageService.setString(
      DeviceModelSealed.idTypeIndexKey,
      json.encode(_idToTypeIndex),
    );
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
    try {
      _socketService.send({
        'command': 'message',
        'identifier': _channelIdentifier(),
        'data': payload,
      });
    } on StateError catch (e) {
      _logger.w('WebSocketDataSync: Subscribe send failed (connection closed): $e');
    }
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
    try {
      _socketService.send({
        'command': 'message',
        'identifier': _channelIdentifier(),
        'data': payload,
      });
    } on StateError catch (e) {
      _logger.w('WebSocketDataSync: Snapshot request failed (connection closed): $e');
    }
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
    // Backend (RxgWebsocketCrudService) uses 'data' key for response arrays
    if (payload['data'] is List) {
      return (payload['data'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    // Fallback for legacy or alternative response formats
    if (payload['results'] is List) {
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
    // Handle summary (all types at once)
    if (resourceType == null) {
      _handleMixedDeviceSnapshot(items);
      return;
    }

    // Route to specific typed cache based on resource type
    final deviceType = DeviceModelSealed.getDeviceTypeFromResourceType(resourceType);
    if (deviceType == null) {
      _logger.w('WebSocketDataSync: Unknown resource type: $resourceType');
      return;
    }

    switch (deviceType) {
      case DeviceModelSealed.typeAccessPoint:
        _cacheAPDevices(items);
      case DeviceModelSealed.typeONT:
        _cacheONTDevices(items);
      case DeviceModelSealed.typeSwitch:
        _cacheSwitchDevices(items);
      case DeviceModelSealed.typeWLAN:
        _cacheWLANDevices(items);
    }
  }

  /// Handle a mixed snapshot containing multiple device types
  void _handleMixedDeviceSnapshot(List<Map<String, dynamic>> items) {
    final apItems = <Map<String, dynamic>>[];
    final ontItems = <Map<String, dynamic>>[];
    final switchItems = <Map<String, dynamic>>[];
    final wlanItems = <Map<String, dynamic>>[];

    for (final item in items) {
      final type = item['type']?.toString() ?? item['device_type']?.toString();
      switch (type) {
        case DeviceModelSealed.typeAccessPoint:
          apItems.add(item);
        case DeviceModelSealed.typeONT:
          ontItems.add(item);
        case DeviceModelSealed.typeSwitch:
          switchItems.add(item);
        case DeviceModelSealed.typeWLAN:
          wlanItems.add(item);
        default:
          _logger.w('WebSocketDataSync: Unknown device type in summary: $type');
      }
    }

    if (apItems.isNotEmpty) _cacheAPDevices(apItems);
    if (ontItems.isNotEmpty) _cacheONTDevices(ontItems);
    if (switchItems.isNotEmpty) _cacheSwitchDevices(switchItems);
    if (wlanItems.isNotEmpty) _cacheWLANDevices(wlanItems);
  }

  void _cacheAPDevices(List<Map<String, dynamic>> items) {
    final models = <APModel>[];
    for (final item in items) {
      try {
        final normalized = _normalizeToAPModel(item);
        models.add(normalized);
        _idToTypeIndex[normalized.id] = DeviceModelSealed.typeAccessPoint;
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse AP: $e');
      }
    }
    // Always cache to clear stale data when snapshot is empty
    unawaited(_apLocalDataSource.cacheDevices(models).catchError((Object e) {
      _logger.e('WebSocketDataSync: Failed to cache APs: $e');
    }));
    _logger.d('WebSocketDataSync: Cached ${models.length} APs');
    if (models.isNotEmpty) {
      _emitDevicesCached(models.length);
    }
  }

  void _cacheONTDevices(List<Map<String, dynamic>> items) {
    final models = <ONTModel>[];
    for (final item in items) {
      try {
        final normalized = _normalizeToONTModel(item);
        models.add(normalized);
        _idToTypeIndex[normalized.id] = DeviceModelSealed.typeONT;
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse ONT: $e');
      }
    }
    // Always cache to clear stale data when snapshot is empty
    unawaited(_ontLocalDataSource.cacheDevices(models).catchError((Object e) {
      _logger.e('WebSocketDataSync: Failed to cache ONTs: $e');
    }));
    _logger.d('WebSocketDataSync: Cached ${models.length} ONTs');
    if (models.isNotEmpty) {
      _emitDevicesCached(models.length);
    }
  }

  void _cacheSwitchDevices(List<Map<String, dynamic>> items) {
    final models = <SwitchModel>[];
    for (final item in items) {
      try {
        final normalized = _normalizeToSwitchModel(item);
        models.add(normalized);
        _idToTypeIndex[normalized.id] = DeviceModelSealed.typeSwitch;
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse Switch: $e');
      }
    }
    // Always cache to clear stale data when snapshot is empty
    unawaited(_switchLocalDataSource.cacheDevices(models).catchError((Object e) {
      _logger.e('WebSocketDataSync: Failed to cache Switches: $e');
    }));
    _logger.d('WebSocketDataSync: Cached ${models.length} Switches');
    if (models.isNotEmpty) {
      _emitDevicesCached(models.length);
    }
  }

  void _cacheWLANDevices(List<Map<String, dynamic>> items) {
    final models = <WLANModel>[];
    for (final item in items) {
      try {
        final normalized = _normalizeToWLANModel(item);
        models.add(normalized);
        _idToTypeIndex[normalized.id] = DeviceModelSealed.typeWLAN;
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse WLAN: $e');
      }
    }
    // Always cache to clear stale data when snapshot is empty
    unawaited(_wlanLocalDataSource.cacheDevices(models).catchError((Object e) {
      _logger.e('WebSocketDataSync: Failed to cache WLANs: $e');
    }));
    _logger.d('WebSocketDataSync: Cached ${models.length} WLANs');
    if (models.isNotEmpty) {
      _emitDevicesCached(models.length);
    }
  }

  void _emitDevicesCached(int count) {
    final cacheKey = DeviceFieldSets.getCacheKey(
      'devices_list',
      DeviceFieldSets.listFields,
    );
    _cacheManager.invalidate(cacheKey);
    _eventController.add(WebSocketDataSyncEvent.devicesCached(count: count));
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
      _chainRoomCache(models);
      return;
    }

    _roomSnapshots[resourceType] = models;
    if (_roomResources.every(_roomSnapshots.containsKey)) {
      final combined = <RoomModel>[];
      for (final entry in _roomResources) {
        combined.addAll(_roomSnapshots[entry] ?? const []);
      }
      _chainRoomCache(combined);
    }
  }

  /// Chains a new room cache operation onto any pending one, preventing
  /// the race condition where _pendingRoomCache gets overwritten while
  /// syncInitialData is awaiting the previous future.
  void _chainRoomCache(List<RoomModel> rooms) {
    final previous = _pendingRoomCache ?? Future<void>.value();
    _pendingRoomCache = previous.then((_) => _cacheRooms(rooms)).catchError((Object e) {
      _logger.e('WebSocketDataSync: Failed to cache rooms: $e');
    });
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

  // ============================================================================
  // Type-Specific Normalization Methods
  // ============================================================================

  APModel _normalizeToAPModel(Map<String, dynamic> data) {
    return APModel(
      id: (data['id'] ?? '').toString(),
      name: data['name']?.toString() ?? 'Unknown AP',
      status: _determineStatus(data),
      pmsRoomId: _extractPmsRoomId(data),
      ipAddress: data['ip']?.toString(),
      macAddress: data['mac']?.toString(),
      location: _extractLocation(data),
      model: data['model']?.toString(),
      serialNumber: data['serial_number']?.toString(),
      firmware: data['firmware']?.toString() ?? data['version']?.toString(),
      note: data['note']?.toString(),
      images: _extractImages(data),
      metadata: data,
      connectionState: data['connection_state']?.toString(),
      signalStrength: data['signal_strength'] as int?,
      connectedClients: data['connected_clients'] as int?,
      ssid: data['ssid']?.toString(),
      channel: data['channel'] as int?,
      maxClients: data['max_clients'] as int?,
      currentUpload: (data['current_upload'] as num?)?.toDouble(),
      currentDownload: (data['current_download'] as num?)?.toDouble(),
      onboardingStatus: data['ap_onboarding_status'] != null
          ? OnboardingStatusPayload.fromJson(
              data['ap_onboarding_status'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  ONTModel _normalizeToONTModel(Map<String, dynamic> data) {
    return ONTModel(
      id: (data['id'] ?? '').toString(),
      name: data['name']?.toString() ?? 'Unknown ONT',
      status: _determineStatus(data),
      pmsRoomId: _extractPmsRoomId(data),
      ipAddress: data['ip']?.toString(),
      macAddress: data['mac']?.toString(),
      location: _extractLocation(data),
      model: data['model']?.toString(),
      serialNumber: data['serial_number']?.toString(),
      firmware: data['firmware']?.toString() ?? data['version']?.toString(),
      note: data['note']?.toString(),
      images: _extractImages(data),
      metadata: data,
      isRegistered: data['is_registered'] as bool?,
      switchPort: data['switch_port'] as Map<String, dynamic>?,
      onboardingStatus: data['ont_onboarding_status'] != null
          ? OnboardingStatusPayload.fromJson(
              data['ont_onboarding_status'] as Map<String, dynamic>,
            )
          : null,
      ports: (data['ont_ports'] as List<dynamic>?)?.cast<Map<String, dynamic>>(),
      uptime: data['uptime']?.toString(),
      phase: data['phase']?.toString(),
    );
  }

  SwitchModel _normalizeToSwitchModel(Map<String, dynamic> data) {
    return SwitchModel(
      id: (data['id'] ?? '').toString(),
      name: data['name']?.toString() ?? 'Unknown Switch',
      status: _determineStatus(data),
      pmsRoomId: _extractPmsRoomId(data),
      ipAddress: data['ip']?.toString() ?? data['host']?.toString(),
      macAddress: data['mac']?.toString(),
      location: _extractLocation(data),
      model: data['model']?.toString(),
      serialNumber: data['serial_number']?.toString(),
      firmware: data['firmware']?.toString() ?? data['version']?.toString(),
      note: data['note']?.toString(),
      images: _extractImages(data),
      metadata: data,
      host: data['host']?.toString(),
      ports: (data['switch_ports'] as List<dynamic>?)?.cast<Map<String, dynamic>>(),
      cpuUsage: data['cpu_usage'] as int?,
      memoryUsage: data['memory_usage'] as int?,
      temperature: data['temperature'] as int?,
    );
  }

  WLANModel _normalizeToWLANModel(Map<String, dynamic> data) {
    return WLANModel(
      id: (data['id'] ?? '').toString(),
      name: data['name']?.toString() ?? 'Unknown WLAN',
      status: _determineStatus(data),
      pmsRoomId: _extractPmsRoomId(data),
      ipAddress: data['ip']?.toString(),
      macAddress: data['mac']?.toString(),
      location: _extractLocation(data),
      model: data['model']?.toString(),
      serialNumber: data['serial_number']?.toString(),
      firmware: data['firmware']?.toString() ?? data['version']?.toString(),
      note: data['note']?.toString(),
      images: _extractImages(data),
      metadata: data,
      controllerType: data['controller_type']?.toString(),
      managedAPs: data['managed_aps'] as int?,
      vlan: data['vlan'] as int?,
      totalUpload: data['total_upload'] as int?,
      totalDownload: data['total_download'] as int?,
      packetLoss: (data['packet_loss'] as num?)?.toDouble(),
      latency: data['latency'] as int?,
      restartCount: data['restart_count'] as int?,
    );
  }

  String _determineStatus(Map<String, dynamic> device) {
    // Backend uses 'online' boolean field (AccessPoint.online)
    final onlineFlag = device['online'] as bool?;
    if (onlineFlag != null) {
      return onlineFlag ? 'online' : 'offline';
    }

    // Fallback: check string 'status' field
    final statusStr = device['status']?.toString().toLowerCase();
    if (statusStr == 'online' || statusStr == 'offline') {
      return statusStr!;
    }

    // Derive status from last_seen_at/last_seen timestamp (produces 'warning')
    if (device['last_seen_at'] != null || device['last_seen'] != null || device['updated_at'] != null) {
      try {
        final lastSeenStr = (device['last_seen_at'] ?? device['last_seen'] ?? device['updated_at'])
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
      } on Exception catch (e) {
        // Date parsing failed - fallback to unknown status
        _logger.d('WebSocketDataSync: Failed to parse device status date: $e');
      }
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
    // Try direct pms_room_id field first
    final directId = deviceMap['pms_room_id'];
    if (directId != null) {
      if (directId is int) {
        return directId;
      }
      if (directId is String) {
        final parsed = int.tryParse(directId);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    // Try nested pms_room.id
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
    // Backend uses 'images' key (has_many_base64_attached :images)
    const imageKeys = [
      'images',
      'image', // Fallback for singular image field
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

    void addDevices(List<dynamic>? list, {String prefix = ''}) {
      if (list == null) {
        return;
      }
      for (final entry in list) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        final id = entry['id'];
        if (id != null) {
          deviceIds.add('$prefix$id');
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

    void addSwitchPortDevices(List<dynamic>? list) {
      if (list == null) {
        return;
      }
      for (final entry in list) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        final switchDevice = entry['switch_device'];
        final switchDeviceId = switchDevice is Map<String, dynamic>
            ? switchDevice['id']
            : entry['switch_device_id'];
        final id = switchDeviceId ?? entry['id'];
        if (id != null) {
          deviceIds.add('sw_$id');
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
    final switchPorts = roomData['switch_ports'];
    if (switchPorts is List && switchPorts.isNotEmpty) {
      addSwitchPortDevices(switchPorts);
    } else {
      addDevices(roomData['switch_devices'] as List<dynamic>?, prefix: 'sw_');
    }
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
