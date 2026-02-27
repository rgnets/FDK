import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/device_normalizer.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
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

  StreamSubscription<SocketMessage>? _messageSub;
  StreamSubscription<SocketConnectionState>? _stateSub;
  bool _started = false;

  /// ID-to-Type index for routing device lookups
  final Map<String, String> _idToTypeIndex = {};

  /// Switch device ID → room ID index built from port ID overlap.
  Map<int, int> _switchToRoomIndex = {};

  /// Port ID → switch raw int ID, built from switch devices' embedded ports.
  /// Used to correlate room-embedded port IDs back to their parent switch.
  Map<int, int> _portToSwitchIndex = {};

  List<Map<String, dynamic>>? _lastSwitchSnapshotItems;
  List<Map<String, dynamic>> _lastRoomSnapshotItems = [];

  final Map<String, List<RoomModel>> _roomSnapshots = {};
  final Set<String> _pendingSnapshots = {};
  Completer<void>? _initialSyncCompleter;
  Future<void>? _pendingRoomCache;
  final _eventController = StreamController<WebSocketDataSyncEvent>.broadcast();

  /// Debounce timer for device cache events.
  /// Collapses rapid AP/ONT/Switch/WLAN caching into a single event.
  Timer? _deviceCacheDebounce;
  int _pendingDeviceCount = 0;

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
    _deviceCacheDebounce?.cancel();
    await _eventController.close();
    _apLocalDataSource.dispose();
    _ontLocalDataSource.dispose();
    _switchLocalDataSource.dispose();
    _wlanLocalDataSource.dispose();
  }

  Future<void> syncInitialData({
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

    await _initialSyncCompleter!.future.timeout(
      timeout,
      onTimeout: () {
        _logger.w('WebSocketDataSync: Initial sync timed out');
        return;
      },
    );

    // Flush all typed caches to storage
    await _flushAllDeviceCaches();

    // Wait for any pending room cache operations
    if (_pendingRoomCache != null) {
      _logger.i('WebSocketDataSync: Waiting for room cache to complete');
      await _pendingRoomCache!.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _logger.w('WebSocketDataSync: Room cache timed out');
        },
      );
    }
    _logger.i('WebSocketDataSync: Cache operations completed');
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
      _snapshotService
        ..sendSubscribe(resource)
        ..sendSnapshotRequest(resource);
    }

    for (final resource in _roomResources) {
      _snapshotService
        ..sendSubscribe(resource)
        ..sendSnapshotRequest(resource);
    }

  }

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
      return;
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

  int? _parseIntId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  /// Build switch device ID → room ID index from raw room items.
  ///
  /// Strategy: rooms embed switch_ports as [{id, name}] — only the port's own
  /// ID, no switch device FK. Switch devices embed the same ports with the same
  /// IDs. We use [_portToSwitchIndex] (portId → switchId) built from switch
  /// device snapshots to look up which switch owns each room-embedded port.
  void _rebuildSwitchToRoomIndex(List<Map<String, dynamic>> items) {
    final index = <int, int>{};
    for (final room in items) {
      final roomId = _parseIntId(room['id']);
      if (roomId == null) continue;

      final switchPorts = room['switch_ports'];
      if (switchPorts is List && switchPorts.isNotEmpty) {
        for (final entry in switchPorts) {
          if (entry is! Map<String, dynamic>) continue;

          // Try direct FK first (future-proof if server ever embeds it)
          final sw = entry['switch_device'];
          final directId = _parseIntId(
            sw is Map<String, dynamic> ? sw['id'] : entry['switch_device_id'],
          );
          if (directId != null) {
            index[directId] = roomId;
            continue;
          }

          // Primary: look up port ID in switch-device-embedded ports index
          final portId = _parseIntId(entry['id']);
          if (portId != null) {
            final swId = _portToSwitchIndex[portId];
            if (swId != null) {
              index[swId] = roomId;
            }
          }
        }
      } else {
        // Fallback: room directly embeds switch_devices list
        final switchDevices = room['switch_devices'];
        if (switchDevices is List) {
          for (final entry in switchDevices) {
            if (entry is! Map<String, dynamic>) continue;
            final swId = _parseIntId(entry['id']);
            if (swId != null) index[swId] = roomId;
          }
        }
      }
    }
    _switchToRoomIndex = index;
    _logger.i(
      'WebSocketDataSync: Built switch→room index '
      '(rooms=${items.length}, mappings=${index.length}, '
      'portIndex=${_portToSwitchIndex.length})',
    );
  }

  bool _shouldBackfillSwitchRooms(List<Map<String, dynamic>> items) {
    if (_switchToRoomIndex.isEmpty) return false;
    for (final item in items) {
      if (item['pms_room_id'] != null) {
        continue;
      }
      final swId = _parseIntId(item['id']);
      if (swId != null && _switchToRoomIndex.containsKey(swId)) {
        return true;
      }
    }
    return false;
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
    unawaited(_apLocalDataSource.cacheDevices(models));
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
    unawaited(_ontLocalDataSource.cacheDevices(models));
    _logger.d('WebSocketDataSync: Cached ${models.length} ONTs');
    if (models.isNotEmpty) {
      _emitDevicesCached(models.length);
    }
  }

  void _cacheSwitchDevices(List<Map<String, dynamic>> items) {
    LoggerService.info(
      '🔌 [SWITCH-PORT] _cacheSwitchDevices called — ${items.length} items',
      tag: 'SwitchPort',
    );
    if (items.isNotEmpty) {
      LoggerService.info(
        '🔌 [SWITCH-PORT] First switch raw keys: ${items.first.keys.toList()}',
        tag: 'SwitchPort',
      );
      final rawPorts = items.first['switch_ports'];
      LoggerService.info(
        '🔌 [SWITCH-PORT] First switch embedded switch_ports: '
        '${rawPorts == null ? "NULL" : (rawPorts is List ? "${rawPorts.length} ports → $rawPorts" : rawPorts.runtimeType)}',
        tag: 'SwitchPort',
      );
    }

    // Build portId → switchRawId from each switch device's embedded ports.
    // Room snapshots only embed port {id, name} — this index lets us look up
    // the owning switch from that port ID.
    var switchesWithPorts = 0;
    for (final item in items) {
      final swRawId = _parseIntId(item['id']);
      if (swRawId == null) continue;
      final ports = item['switch_ports'];
      if (ports is List && ports.isNotEmpty) {
        switchesWithPorts++;
        for (final port in ports) {
          if (port is! Map<String, dynamic>) continue;
          final portId = _parseIntId(port['id']);
          if (portId != null) _portToSwitchIndex[portId] = swRawId;
        }
      }
    }

    // Diagnostic: show whether switch devices embed their ports
    if (items.isNotEmpty) {
      final firstItem = items.first;
      _logger.i(
        'WebSocketDataSync: Switch devices snapshot diagnostics '
        '(total=${items.length}, withEmbeddedPorts=$switchesWithPorts, '
        'portIndexSize=${_portToSwitchIndex.length}, '
        'firstItemKeys=${firstItem.keys.toList()})',
      );
    }

    // If rooms arrived before switches, the switchToRoom index was built with
    // an empty portToSwitch index. Rebuild it now that we have port data.
    if (_lastRoomSnapshotItems.isNotEmpty && _switchToRoomIndex.isEmpty) {
      _rebuildSwitchToRoomIndex(_lastRoomSnapshotItems);
    }

    final models = <SwitchModel>[];
    var injected = 0;
    var missingMapping = 0;
    var invalidIds = 0;
    for (final item in items) {
      try {
        // Back-populate pms_room_id from room index if missing
        if (item['pms_room_id'] == null && _switchToRoomIndex.isNotEmpty) {
          final swId = _parseIntId(item['id']);
          if (swId != null) {
            final roomId = _switchToRoomIndex[swId];
            if (roomId != null) {
              item['pms_room_id'] = roomId;
              injected++;
            } else {
              missingMapping++;
            }
          } else {
            invalidIds++;
          }
        }
        final normalized = _deviceNormalizer.normalizeToSwitch(item);
        models.add(normalized);
        _idToTypeIndex[normalized.id] = DeviceModelSealed.typeSwitch;
      } on Exception catch (e) {
        _logger.w('WebSocketDataSync: Failed to parse Switch: $e');
      }
    }
    _lastSwitchSnapshotItems =
        items.map((item) => Map<String, dynamic>.from(item)).toList();
    if (injected > 0 ||
        (missingMapping > 0 && _switchToRoomIndex.isNotEmpty) ||
        invalidIds > 0) {
      _logger.i(
        'WebSocketDataSync: Switch backfill summary '
        '(items=${items.length}, injected=$injected, '
        'missingMap=$missingMapping, invalidIds=$invalidIds, '
        'index=${_switchToRoomIndex.length})',
      );
    }
    // Always cache to clear stale data when snapshot is empty
    unawaited(_switchLocalDataSource.cacheDevices(models));
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
    unawaited(_wlanLocalDataSource.cacheDevices(models));
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

    // Debounce: accumulate counts and fire a single event after 600ms of quiet.
    // This collapses rapid AP/ONT/Switch/WLAN caching into one provider refresh.
    _pendingDeviceCount += count;
    _deviceCacheDebounce?.cancel();
    _deviceCacheDebounce = Timer(const Duration(milliseconds: 600), () {
      _logger.i(
        'WebSocketDataSync: Emitting debounced devicesCached '
        '(total=$_pendingDeviceCount)',
      );
      _eventController.add(
        WebSocketDataSyncEvent.devicesCached(count: _pendingDeviceCount),
      );
      _pendingDeviceCount = 0;
    });
  }

  void _handleRoomSnapshot(
    List<Map<String, dynamic>> items, {
    required String? resourceType,
  }) {
    // Save raw items so _cacheSwitchDevices can rebuild the index if switches
    // arrive after rooms (when _portToSwitchIndex was empty at room-arrival time).
    _lastRoomSnapshotItems = List<Map<String, dynamic>>.from(items);

    // Rebuild switch→room index from raw room data before converting to models
    _rebuildSwitchToRoomIndex(items);
    final lastSwitchItems = _lastSwitchSnapshotItems;
    if (lastSwitchItems != null &&
        lastSwitchItems.isNotEmpty &&
        _shouldBackfillSwitchRooms(lastSwitchItems)) {
      _logger.i(
        'WebSocketDataSync: Re-caching switches after room snapshot '
        '(switchItems=${lastSwitchItems.length}, index=${_switchToRoomIndex.length})',
      );
      _cacheSwitchDevices(lastSwitchItems);
    } else if (lastSwitchItems == null || lastSwitchItems.isEmpty) {
      _logger.i(
        'WebSocketDataSync: No cached switch snapshot to backfill after rooms',
      );
    }

    final models = <RoomModel>[];
    for (final item in items) {
      try {
        models.add(_roomProcessor.buildRoomModel(item));
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
