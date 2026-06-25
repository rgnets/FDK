import 'dart:async';

import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/issue.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';

/// Abstract interface for room readiness data source.
abstract class RoomReadinessDataSource {
  /// Get readiness metrics for all rooms.
  Future<List<RoomReadinessMetrics>> getAllRoomReadiness();

  /// Get readiness metrics for a specific room by ID.
  Future<RoomReadinessMetrics?> getRoomReadinessById(int roomId);

  /// Get the overall readiness percentage across all non-empty rooms.
  double getOverallReadinessPercentage();

  /// Get rooms filtered by status.
  List<RoomReadinessMetrics> getRoomsByStatus(RoomStatus status);

  /// Stream of room readiness updates.
  Stream<RoomReadinessUpdate> get readinessUpdates;

  /// Refresh room readiness data.
  Future<void> refresh();

  /// Dispose resources.
  void dispose();
}

/// WebSocket-based data source for room readiness.
/// Computes room readiness from cached room and device data.
class RoomReadinessWebSocketDataSource implements RoomReadinessDataSource {
  RoomReadinessWebSocketDataSource({
    required WebSocketCacheIntegration webSocketCacheIntegration,
    Logger? logger,
  })  : _cacheIntegration = webSocketCacheIntegration,
        _logger = logger ?? Logger() {
    _initialize();
  }

  final WebSocketCacheIntegration _cacheIntegration;
  final Logger _logger;

  /// Cached room readiness metrics.
  final Map<int, RoomReadinessMetrics> _metricsCache = {};

  /// Cache validity duration.
  static const _cacheValidityDuration = Duration(seconds: 30);

  /// Last cache update time.
  DateTime? _lastCacheUpdate;

  /// Stream controller for readiness updates.
  final _updateController =
      StreamController<RoomReadinessUpdate>.broadcast();

  WebSocketService get _webSocketService => _cacheIntegration.webSocketService;

  void _initialize() {
    _logger.i('RoomReadinessWebSocketDataSource: Initializing');

    // Listen to cache updates to invalidate our metrics cache
    _cacheIntegration.lastUpdate.addListener(_onCacheUpdate);
    _cacheIntegration.lastDeviceUpdate.addListener(_onCacheUpdate);
  }

  void _onCacheUpdate() {
    _logger.d('RoomReadinessWebSocketDataSource: Cache updated, invalidating metrics');
    _invalidateCache();
  }

  void _invalidateCache() {
    _metricsCache.clear();
    _lastCacheUpdate = null;
  }

  bool get _isCacheValid {
    if (_lastCacheUpdate == null || _metricsCache.isEmpty) {
      return false;
    }
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidityDuration;
  }

  @override
  Future<List<RoomReadinessMetrics>> getAllRoomReadiness() async {
    _logger.i('RoomReadinessWebSocketDataSource: getAllRoomReadiness() called');

    // Return from cache if valid
    if (_isCacheValid) {
      _logger.i(
        'RoomReadinessWebSocketDataSource: Returning ${_metricsCache.length} metrics from cache',
      );
      return _metricsCache.values.toList();
    }

    // Get room and device data from cache integration
    final rooms = _cacheIntegration.getCachedRooms();
    final devices = _cacheIntegration.getAllCachedDeviceModels();

    _logger.i(
      'RoomReadinessWebSocketDataSource: Got ${rooms.length} rooms and ${devices.length} devices from cache',
    );

    if (rooms.isEmpty) {
      // Request room data if not available
      if (_webSocketService.isConnected) {
        _logger.i('RoomReadinessWebSocketDataSource: Requesting room snapshot');
        _cacheIntegration.requestResourceSnapshot('pms_rooms');

        // Wait for data with timeout
        const maxWaitTime = Duration(seconds: 10);
        const pollInterval = Duration(milliseconds: 500);
        var elapsed = Duration.zero;

        while (elapsed < maxWaitTime) {
          await Future<void>.delayed(pollInterval);
          elapsed += pollInterval;

          final cachedRooms = _cacheIntegration.getCachedRooms();
          if (cachedRooms.isNotEmpty) {
            _logger.i(
              'RoomReadinessWebSocketDataSource: Got ${cachedRooms.length} rooms after ${elapsed.inMilliseconds}ms',
            );
            return _computeMetrics(
              cachedRooms,
              _cacheIntegration.getAllCachedDeviceModels(),
            );
          }
        }
      }

      _logger.w('RoomReadinessWebSocketDataSource: No room data available');
      return [];
    }

    return _computeMetrics(rooms, devices);
  }

  List<RoomReadinessMetrics> _computeMetrics(
    List<Map<String, dynamic>> rooms,
    List deviceModels,
  ) {
    _logger.i('RoomReadinessWebSocketDataSource: Computing metrics for ${rooms.length} rooms');

    // Build device lookup map ONCE for O(1) lookups instead of O(n) per room
    final deviceLookup = _buildDeviceLookupMap(deviceModels);
    _logger.i('RoomReadinessWebSocketDataSource: Built device lookup map with ${deviceLookup.length} entries');

    final metrics = <RoomReadinessMetrics>[];

    for (final roomData in rooms) {
      try {
        final metric = _computeRoomMetrics(roomData, deviceLookup);
        metrics.add(metric);
        _metricsCache[metric.roomId] = metric;
      } catch (e) {
        _logger.e('RoomReadinessWebSocketDataSource: Error computing metrics for room: $e');
      }
    }

    _lastCacheUpdate = DateTime.now();

    // Emit a full refresh update with ALL room metrics
    if (metrics.isNotEmpty) {
      _updateController.add(
        RoomReadinessUpdate.fullRefresh(allMetrics: metrics),
      );
    }

    return metrics;
  }

  /// Build a lookup map from device models for O(1) lookups.
  /// Keys include both raw IDs and prefixed IDs (e.g., "123" and "ap_123").
  Map<String, dynamic> _buildDeviceLookupMap(List<dynamic> deviceModels) {
    final lookup = <String, dynamic>{};

    for (final device in deviceModels) {
      try {
        final deviceId = device.id as String?;
        if (deviceId != null) {
          lookup[deviceId] = device;
          // Also add without prefix for flexible matching
          final rawId = _extractRawId(deviceId);
          if (rawId != deviceId) {
            lookup[rawId] = device;
          }
        }
      } catch (_) {
        // Handle Map-based devices
        if (device is Map<String, dynamic>) {
          final id = device['id']?.toString();
          if (id != null) {
            lookup[id] = device;
          }
        }
      }
    }

    return lookup;
  }

  /// Extract raw numeric ID from prefixed ID (e.g., "ap_123" -> "123").
  String _extractRawId(String deviceId) {
    final prefixes = ['ap_', 'ont_', 'sw_'];
    for (final prefix in prefixes) {
      if (deviceId.startsWith(prefix)) {
        return deviceId.substring(prefix.length);
      }
    }
    return deviceId;
  }

  RoomReadinessMetrics _computeRoomMetrics(
    Map<String, dynamic> roomData,
    Map<String, dynamic> deviceLookup,
  ) {
    final roomId = _parseRoomId(roomData['id']);
    final roomName = _buildRoomName(roomData);

    // DEBUG: Log room data structure
    _logger.i('DEBUG ROOM $roomId ($roomName): roomData keys = ${roomData.keys.toList()}');
    _logger.i('DEBUG ROOM $roomId: access_points = ${roomData['access_points']}');
    _logger.i('DEBUG ROOM $roomId: media_converters = ${roomData['media_converters']}');
    _logger.i('DEBUG ROOM $roomId: switch_ports = ${roomData['switch_ports']}');
    _logger.i('DEBUG ROOM $roomId: deviceLookup size = ${deviceLookup.length}');

    // Extract device references from room data
    final deviceRefs = _extractDeviceReferences(roomData);
    if (deviceRefs.isEmpty) {
      return RoomReadinessMetrics(
        roomId: roomId,
        roomName: roomName,
        status: RoomStatus.empty,
        totalDevices: 0,
        onlineDevices: 0,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: DateTime.now(),
      );
    }

    // Find matching devices and compute status
    var onlineDevices = 0;
    var offlineDevices = 0;
    final issues = <Issue>[];
    // AP rxg primary keys present in this room. Used by the room-readiness
    // notifier to attach compliance failures (Issue.missingImages /
    // Issue.missingSpeedTest), matched by AP id.
    final accessPointIds = <int>[];
    // ONT (MediaConverter) rxg primary keys present in this room. Used by the
    // notifier to attach per-ONT compliance failures (e.g. ONT missing images),
    // matched by ONT id.
    final ontDeviceIds = <int>[];

    for (final ref in deviceRefs) {
      final isAp = ref['type'] == 'AP';

      // Room membership is authoritative from the LIVE device cache's
      // pms_room_id — for EVERY device type, not just APs — NOT the embedded
      // pms_room snapshot (access_points / media_converters / switch_ports),
      // which goes stale when a device is reassigned/removed and leaves "ghost"
      // entries in a room it no longer belongs to. Look the device up in the
      // cache and skip it unless the cache still places it in this room. This
      // keeps the issue list consistent with the room's actual device list
      // (_getDevicesForRoom, which filters the same way: pmsRoomId == room.id).
      // Without this gate, stale ONT/Switch references produced phantom
      // "Device Not Found" / offline issues for rooms with no associated devices.
      final device = isAp
          ? (deviceLookup['ap_${ref['id']}'] ?? deviceLookup['${ref['id']}'])
          : _findDevice(ref, deviceLookup);
      if (device == null || _devicePmsRoomId(device) != roomId) {
        continue;
      }

      if (isAp) {
        final apId = _parseDeviceId(device);
        if (apId != 0) {
          accessPointIds.add(apId);
        }
      } else if (ref['type'] == 'ONT') {
        final ontId = _parseDeviceId(device);
        if (ontId != 0) {
          ontDeviceIds.add(ontId);
        }
      }

      // Device offline is calculated by the app (the compliance tool doesn't
      // cover it), but RELIABLY: only flag a device that is EXPLICITLY offline.
      // A device whose online state is unknown or stale is treated as online and
      // NOT flagged — that false positive turned rooms with online devices orange.
      if (_isDeviceExplicitlyOffline(device)) {
        offlineDevices++;
        issues.add(
          Issue.deviceOffline(
            deviceId: _parseDeviceId(device),
            deviceName: _getDeviceName(device),
            deviceType: ref['type'] as String? ?? 'Device',
          ),
        );
      } else {
        onlineDevices++;
      }

      // Check for other device issues
      final deviceIssues = _detectDeviceIssues(device, ref['type'] as String?);
      issues.addAll(deviceIssues);
    }

    // Count only the devices the live cache actually places in this room, so
    // stale ghosts don't inflate the total (which would force the room partial).
    final totalDevices = onlineDevices + offlineDevices;

    final status = _determineRoomStatus(
      totalDevices: totalDevices,
      onlineDevices: onlineDevices,
      issues: issues,
    );

    return RoomReadinessMetrics(
      roomId: roomId,
      roomName: roomName,
      status: status,
      totalDevices: totalDevices,
      onlineDevices: onlineDevices,
      offlineDevices: offlineDevices,
      issues: issues,
      lastUpdated: DateTime.now(),
      accessPointIds: accessPointIds,
      ontDeviceIds: ontDeviceIds,
    );
  }

  int _parseRoomId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  int _parseDeviceId(dynamic device) {
    if (device is Map<String, dynamic>) {
      final id = device['id'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id) ?? 0;
    }
    // For DeviceModel objects - try dynamic access
    try {
      final id = device.id;
      if (id is String) {
        // Extract numeric part from prefixed IDs like 'ap_123'
        final match = RegExp(r'\d+').firstMatch(id);
        return int.tryParse(match?.group(0) ?? '') ?? 0;
      }
    } catch (_) {
      // Expected: device may not have .id property - fallback to 0
    }
    return 0;
  }

  String _getDeviceName(dynamic device) {
    if (device is Map<String, dynamic>) {
      return device['name']?.toString() ?? 'Unknown Device';
    }
    try {
      return device.name as String? ?? 'Unknown Device';
    } catch (_) {
      return 'Unknown Device';
    }
  }

  String _buildRoomName(Map<String, dynamic> roomData) {
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

  List<Map<String, dynamic>> _extractDeviceReferences(
    Map<String, dynamic> roomData,
  ) {
    final refs = <Map<String, dynamic>>[];

    void addRefs(dynamic list, String type) {
      if (list is! List) return;
      for (final item in list) {
        if (item is Map<String, dynamic> && item['id'] != null) {
          refs.add({'id': item['id'], 'type': type, 'data': item});
        }
      }
    }

    void addSwitchPortRefs(dynamic list) {
      if (list is! List) return;
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final switchDevice = item['switch_device'];
        final switchDeviceId = switchDevice is Map<String, dynamic>
            ? switchDevice['id']
            : item['switch_device_id'];
        final refId = switchDeviceId ?? item['id'];
        if (refId == null) continue;
        refs.add({'id': refId, 'type': 'Switch', 'data': switchDevice ?? item});
      }
    }

    addRefs(roomData['access_points'], 'AP');
    addRefs(roomData['media_converters'], 'ONT');
    final switchPorts = roomData['switch_ports'];
    if (switchPorts is List && switchPorts.isNotEmpty) {
      addSwitchPortRefs(switchPorts);
    } else {
      addSwitchPortRefs(roomData['switch_devices']);
    }

    return refs;
  }

  /// Find a device using O(1) map lookup instead of O(n) list search.
  dynamic _findDevice(Map<String, dynamic> ref, Map<String, dynamic> deviceLookup) {
    final refId = ref['id']?.toString();
    final refType = ref['type'] as String?;
    if (refId == null) {
      _logger.w('DEBUG _findDevice: refId is null for ref=$ref');
      return null;
    }

    // Build expected device ID with prefix
    final prefix = switch (refType) {
      'AP' => 'ap_',
      'ONT' => 'ont_',
      'Switch' => 'sw_',
      _ => '',
    };
    final prefixedId = '$prefix$refId';

    _logger.d('DEBUG _findDevice: Looking for refId=$refId prefixedId=$prefixedId');

    // O(1) lookup - try prefixed ID first, then raw ID
    var device = deviceLookup[prefixedId];
    if (device != null) {
      _logger.d('DEBUG _findDevice: MATCH FOUND via prefixedId=$prefixedId');
      return device;
    }

    device = deviceLookup[refId];
    if (device != null) {
      _logger.d('DEBUG _findDevice: MATCH FOUND via refId=$refId');
      return device;
    }

    // Also check in the reference data itself (inline device data)
    final refData = ref['data'];
    if (refData is Map<String, dynamic> && refData.containsKey('online')) {
      _logger.d('DEBUG _findDevice: Using inline refData with online=${refData['online']}');
      return refData;
    }

    _logger.w('DEBUG _findDevice: NO MATCH for refId=$refId prefixedId=$prefixedId');
    return null;
  }

  /// The device's live `pms_room_id` (the room it currently belongs to), used
  /// to verify AP membership against the authoritative device cache rather than
  /// a stale embedded room snapshot. Returns null when unknown.
  int? _devicePmsRoomId(dynamic device) {
    try {
      final r = device.pmsRoomId;
      if (r is int) return r;
      if (r is String) return int.tryParse(r);
    } catch (_) {
      // Not a device model — fall through to map handling.
    }
    if (device is Map<String, dynamic>) {
      final r = device['pms_room_id'];
      if (r is int) return r;
      if (r is String) return int.tryParse(r);
    }
    return null;
  }

  /// True only when the device is EXPLICITLY offline. A device whose online
  /// state is unknown/absent (a stale embedded room association, or an
  /// `unknown` status) is NOT treated as offline — flagging those produced
  /// false "offline" issues that turned rooms with online devices orange.
  bool _isDeviceExplicitlyOffline(dynamic device) {
    if (device is Map<String, dynamic>) {
      return device['online'] == false;
    }
    try {
      return device.status?.toLowerCase() == 'offline';
    } catch (_) {
      return false;
    }
  }

  List<Issue> _detectDeviceIssues(dynamic device, String? deviceType) {
    final issues = <Issue>[];

    // Check onboarding status
    try {
      final onboardingStatus = _getOnboardingStatus(device, deviceType);
      if (onboardingStatus != null) {
        if (!_isOnboardingComplete(onboardingStatus, deviceType)) {
          final deviceId = _parseDeviceId(device);
          final deviceName = _getDeviceName(device);
          final currentStage = _getOnboardingStage(onboardingStatus);
          final totalStages = deviceType == 'AP' ? 6 : 5;

          if (currentStage < totalStages) {
            issues.add(
              Issue.onboardingIncomplete(
                deviceId: deviceId,
                deviceName: deviceName,
                deviceType: deviceType ?? 'Device',
                currentStage: currentStage,
                totalStages: totalStages,
              ),
            );
          }
        } else {
          // Onboarding stage is complete, but the status may still carry an
          // `error` (e.g. an online, approved AP missing its CSR/Cert in the
          // DB). The stage-only completeness check misses these; surface them
          // as a warning so the room drops below 100%, matching the FE portal.
          final error = _getOnboardingError(onboardingStatus);
          if (error != null && error.isNotEmpty) {
            issues.add(
              Issue.onboardingError(
                deviceId: _parseDeviceId(device),
                deviceName: _getDeviceName(device),
                deviceType: deviceType ?? 'Device',
                error: error,
              ),
            );
          }
        }
      }
    } catch (e) {
      _logger.w('RoomReadinessWebSocketDataSource: Error detecting onboarding issues: $e');
    }

    return issues;
  }

  dynamic _getOnboardingStatus(dynamic device, String? deviceType) {
    if (device is Map<String, dynamic>) {
      if (deviceType == 'AP') {
        return device['ap_onboarding_status'];
      } else if (deviceType == 'ONT') {
        return device['ont_onboarding_status'];
      }
    }
    try {
      if (deviceType == 'AP') {
        return device.apOnboardingStatus;
      } else if (deviceType == 'ONT') {
        return device.ontOnboardingStatus;
      }
    } catch (_) {
      // Expected: device may not have onboarding status property
    }
    return null;
  }

  bool _isOnboardingComplete(dynamic status, String? deviceType) {
    final stage = _getOnboardingStage(status);
    // Both AP and ONT success is stage 6
    final successStage = 6;
    return stage >= successStage;
  }

  int _getOnboardingStage(dynamic status) {
    if (status is Map<String, dynamic>) {
      return status['stage'] as int? ?? 0;
    }
    if (status is int) return status;
    return 0;
  }

  /// The `error` string from an onboarding status (e.g. "CSR and Cert missing
  /// from DB"), read from either the raw WebSocket map or a typed payload.
  /// Returns null when absent or not a string.
  String? _getOnboardingError(dynamic status) {
    if (status is Map<String, dynamic>) {
      final e = status['error'];
      return e is String ? e : null;
    }
    try {
      final e = status.error;
      return e is String ? e : null;
    } catch (_) {
      return null;
    }
  }

  RoomStatus _determineRoomStatus({
    required int totalDevices,
    required int onlineDevices,
    required List<Issue> issues,
  }) {
    if (totalDevices == 0) {
      return RoomStatus.empty;
    }

    // Check for device-missing issues (always DOWN - device expected but not found)
    final hasMissingDevice = issues.any((i) => i.code == 'DEVICE_MISSING');
    if (hasMissingDevice) {
      return RoomStatus.down;
    }

    // DOWN only if ALL devices are offline
    if (onlineDevices == 0) {
      return RoomStatus.down;
    }

    // PARTIAL if some devices offline OR any issues exist
    if (onlineDevices < totalDevices || issues.isNotEmpty) {
      return RoomStatus.partial;
    }

    return RoomStatus.ready;
  }

  @override
  Future<RoomReadinessMetrics?> getRoomReadinessById(int roomId) async {
    _logger.i('RoomReadinessWebSocketDataSource: getRoomReadinessById($roomId) called');

    // Check cache first
    if (_isCacheValid && _metricsCache.containsKey(roomId)) {
      return _metricsCache[roomId];
    }

    // Compute all metrics and return the requested one
    final allMetrics = await getAllRoomReadiness();
    return allMetrics.where((m) => m.roomId == roomId).firstOrNull;
  }

  @override
  double getOverallReadinessPercentage() {
    if (_metricsCache.isEmpty) {
      return 0.0;
    }

    // Exclude empty rooms
    final nonEmptyRooms =
        _metricsCache.values.where((m) => m.status != RoomStatus.empty).toList();

    if (nonEmptyRooms.isEmpty) {
      return 0.0;
    }

    final readyRooms = nonEmptyRooms.where((m) => m.status == RoomStatus.ready).length;
    return (readyRooms / nonEmptyRooms.length) * 100;
  }

  @override
  List<RoomReadinessMetrics> getRoomsByStatus(RoomStatus status) {
    return _metricsCache.values.where((m) => m.status == status).toList();
  }

  @override
  Stream<RoomReadinessUpdate> get readinessUpdates => _updateController.stream;

  @override
  Future<void> refresh() async {
    _logger.i('RoomReadinessWebSocketDataSource: refresh() called');
    _invalidateCache();

    if (_webSocketService.isConnected) {
      _cacheIntegration.requestResourceSnapshot('pms_rooms');
      _cacheIntegration.requestFullSnapshots();
    }

    await getAllRoomReadiness();
  }

  @override
  void dispose() {
    _logger.i('RoomReadinessWebSocketDataSource: dispose() called');
    _cacheIntegration.lastUpdate.removeListener(_onCacheUpdate);
    _cacheIntegration.lastDeviceUpdate.removeListener(_onCacheUpdate);
    _updateController.close();
  }
}
