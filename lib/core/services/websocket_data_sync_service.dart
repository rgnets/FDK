import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/device_normalizer.dart';
import 'package:rgnets_fdk/core/services/room_data_processor.dart';
import 'package:rgnets_fdk/core/services/snapshot_request_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/typed_device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_local_data_source.dart';

/// Orchestrates WebSocket-driven data synchronization for devices and rooms.
///
/// This service coordinates:
/// - Lifecycle management (start/stop/dispose)
/// - WebSocket message routing
/// - Cache coordination across 4 typed device caches
/// - Event broadcasting for UI refresh
///
/// Data processing is delegated to:
/// - [DeviceNormalizer] for device JSON normalization
/// - [RoomDataProcessor] for room model building
/// - [SnapshotRequestService] for WebSocket requests
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
  })  : _socketService = socketService,
        _apLocalDataSource = apLocalDataSource,
        _ontLocalDataSource = ontLocalDataSource,
        _switchLocalDataSource = switchLocalDataSource,
        _wlanLocalDataSource = wlanLocalDataSource,
        _roomLocalDataSource = roomLocalDataSource,
        _cacheManager = cacheManager,
        _storageService = storageService,
        _logger = logger ?? Logger(),
        _deviceNormalizer = DeviceNormalizer(),
        _roomProcessor = RoomDataProcessor(),
        _snapshotService = SnapshotRequestService(
          webSocketService: socketService,
          logger: logger,
        );

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

  // Delegated services
  final DeviceNormalizer _deviceNormalizer;
  final RoomDataProcessor _roomProcessor;
  final SnapshotRequestService _snapshotService;

  StreamSubscription<SocketConnectionState>? _stateSub;
  bool _started = false;

  /// ID-to-Type index for routing device lookups
  final Map<String, String> _idToTypeIndex = {};

  final Map<String, List<RoomModel>> _roomSnapshots = {};
  Future<void>? _pendingRoomCache;
  final _eventController = StreamController<WebSocketDataSyncEvent>.broadcast();

  bool get isRunning => _started;
  Stream<WebSocketDataSyncEvent> get events => _eventController.stream;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    // Deliberately NOT subscribing to inbound WS messages: full inventory is
    // loaded over REST (via InventoryReseedService), and this service does not
    // process `action=updated` deltas. Listening here only risked an unrelated
    // WS `index` response (e.g. the scanner's targeted 10-row device lookup)
    // being applied as a full snapshot and clobbering the typed SQLite cache.
    _stateSub = _socketService.connectionState.listen(_handleConnectionState);

    if (_socketService.isConnected) {
      _requestSnapshots();
    }
  }

  Future<void> stop() async {
    _started = false;
    await _stateSub?.cancel();
    _stateSub = null;
    _roomSnapshots.clear();
  }

  Future<void> dispose() async {
    await stop();
    await _eventController.close();
    _apLocalDataSource.dispose();
    _ontLocalDataSource.dispose();
    _switchLocalDataSource.dispose();
    _wlanLocalDataSource.dispose();
  }

  /// Ensure the service is started and subscribed for live deltas. Full
  /// inventory is no longer pulled over WS `index` snapshots (that storm
  /// saturated the rXg gRPC pool); the typed SQLite caches are seeded over
  /// REST by [InventoryReseedService] via [applyRestDeviceSnapshot] /
  /// [applyRestRoomSnapshot]. This method therefore just subscribes and
  /// returns — callers that need a full refresh trigger the reseed coordinator.
  ///
  /// [timeout] is retained for API compatibility with existing callers.
  Future<void> syncInitialData({
    Duration timeout = const Duration(seconds: 45),
  }) async {
    await start();
  }

  /// Apply a REST-fetched full snapshot of one device resource into the typed
  /// SQLite caches (the device repository's offline/cold-start fallback).
  /// Driven by [InventoryReseedService]; call [flushTypedCaches] once after a
  /// batch to persist.
  Future<void> applyRestDeviceSnapshot(
    String resourceType,
    List<Map<String, dynamic>> items,
  ) async {
    await start();
    _handleDeviceSnapshot(items, resourceType: resourceType);
  }

  /// Apply a REST-fetched full snapshot of rooms into the room SQLite cache.
  Future<void> applyRestRoomSnapshot(List<Map<String, dynamic>> items) async {
    await start();
    _handleRoomSnapshot(items, resourceType: 'pms_rooms');
  }

  /// Persist the typed device caches to SQLite and await any pending room
  /// cache write. Call once after a batch of REST snapshot applies.
  Future<void> flushTypedCaches() async {
    await _flushAllDeviceCaches();
    final pendingRoom = _pendingRoomCache;
    if (pendingRoom != null) {
      await pendingRoom.timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            _logger.w('WebSocketDataSync: Room cache flush timed out'),
      );
    }
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
      _logger.d('WebSocketDataSync: Socket not connected, skipping subscribe');
      return;
    }

    // Subscribe for live deltas only. Full inventory is loaded over REST by
    // the reseed coordinator (off the gRPC path); WS `index` snapshot requests
    // were removed because they saturated the rXg gRPC pool and starved write
    // actions like register_ap_device.
    for (final resource in _deviceResources) {
      _snapshotService.sendSubscribe(resource);
    }
    for (final resource in _roomResources) {
      _snapshotService.sendSubscribe(resource);
    }
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
    final deviceType =
        DeviceModelSealed.getDeviceTypeFromResourceType(resourceType);
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

    if (apItems.isNotEmpty) {
      _cacheAPDevices(apItems);
    }
    if (ontItems.isNotEmpty) {
      _cacheONTDevices(ontItems);
    }
    if (switchItems.isNotEmpty) {
      _cacheSwitchDevices(switchItems);
    }
    if (wlanItems.isNotEmpty) {
      _cacheWLANDevices(wlanItems);
    }
  }

  void _cacheAPDevices(List<Map<String, dynamic>> items) {
    final models = <APModel>[];
    for (final item in items) {
      try {
        final normalized = _deviceNormalizer.normalizeToAP(item);
        models.add(normalized);
        _idToTypeIndex[normalized.id] = DeviceModelSealed.typeAccessPoint;
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse AP: $e');
      }
    }
    // Always cache to clear stale data when snapshot is empty
    unawaited(
      _apLocalDataSource.cacheDevices(models).catchError((Object e, StackTrace st) {
        _logger.e('WebSocketDataSync: Failed to cache APs: $e');
      }),
    );
    _logger.d('WebSocketDataSync: Cached ${models.length} APs');
    if (models.isNotEmpty) {
      _emitDevicesCached(models.length);
    }
  }

  void _cacheONTDevices(List<Map<String, dynamic>> items) {
    final models = <ONTModel>[];
    for (final item in items) {
      try {
        final normalized = _deviceNormalizer.normalizeToONT(item);
        models.add(normalized);
        _idToTypeIndex[normalized.id] = DeviceModelSealed.typeONT;
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse ONT: $e');
      }
    }
    // Always cache to clear stale data when snapshot is empty
    unawaited(
      _ontLocalDataSource.cacheDevices(models).catchError((Object e, StackTrace st) {
        _logger.e('WebSocketDataSync: Failed to cache ONTs: $e');
      }),
    );
    _logger.d('WebSocketDataSync: Cached ${models.length} ONTs');
    if (models.isNotEmpty) {
      _emitDevicesCached(models.length);
    }
  }

  void _cacheSwitchDevices(List<Map<String, dynamic>> items) {
    final models = <SwitchModel>[];
    for (final item in items) {
      try {
        final normalized = _deviceNormalizer.normalizeToSwitch(item);
        models.add(normalized);
        _idToTypeIndex[normalized.id] = DeviceModelSealed.typeSwitch;
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse Switch: $e');
      }
    }
    // Always cache to clear stale data when snapshot is empty
    unawaited(
      _switchLocalDataSource.cacheDevices(models).catchError((Object e, StackTrace st) {
        _logger.e('WebSocketDataSync: Failed to cache Switches: $e');
      }),
    );
    _logger.d('WebSocketDataSync: Cached ${models.length} Switches');
    if (models.isNotEmpty) {
      _emitDevicesCached(models.length);
    }
  }

  void _cacheWLANDevices(List<Map<String, dynamic>> items) {
    final models = <WLANModel>[];
    for (final item in items) {
      try {
        final normalized = _deviceNormalizer.normalizeToWLAN(item);
        models.add(normalized);
        _idToTypeIndex[normalized.id] = DeviceModelSealed.typeWLAN;
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse WLAN: $e');
      }
    }
    // Always cache to clear stale data when snapshot is empty
    unawaited(
      _wlanLocalDataSource.cacheDevices(models).catchError((Object e, StackTrace st) {
        _logger.e('WebSocketDataSync: Failed to cache WLANs: $e');
      }),
    );
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
    var deviceLessCount = 0;
    for (final item in items) {
      final RoomModel model;
      try {
        model = _roomProcessor.buildRoomModel(item);
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse room: $e');
        continue;
      }
      // Hide rooms with no devices (linked sub-rooms carry no devices).
      if (model.deviceIds == null || model.deviceIds!.isEmpty) {
        deviceLessCount++;
        continue;
      }
      models.add(model);
    }
    _logger.i(
      'WebSocketDataSync: room snapshot ${items.length} total, '
      '$deviceLessCount device-less filtered, ${models.length} kept',
    );

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
