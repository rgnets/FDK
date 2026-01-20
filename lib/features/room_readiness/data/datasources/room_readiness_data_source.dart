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

    final metrics = <RoomReadinessMetrics>[];

    for (final roomData in rooms) {
      try {
        final metric = _computeRoomMetrics(roomData, deviceModels);
        metrics.add(metric);
        _metricsCache[metric.roomId] = metric;
      } catch (e) {
        _logger.e('RoomReadinessWebSocketDataSource: Error computing metrics for room: $e');
      }
    }

    _lastCacheUpdate = DateTime.now();

    // Emit a full refresh update
    if (metrics.isNotEmpty) {
      _updateController.add(
        RoomReadinessUpdate.create(
          roomId: 0,
          metrics: metrics.first,
          type: RoomReadinessUpdateType.fullRefresh,
        ),
      );
    }

    return metrics;
  }

  RoomReadinessMetrics _computeRoomMetrics(
    Map<String, dynamic> roomData,
    List deviceModels,
  ) {
    final roomId = _parseRoomId(roomData['id']);
    final roomName = _buildRoomName(roomData);

    // Extract device references from room data
    final deviceRefs = _extractDeviceReferences(roomData);
    final totalDevices = deviceRefs.length;

    if (totalDevices == 0) {
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

    for (final ref in deviceRefs) {
      final device = _findDevice(ref, deviceModels);
      if (device == null) {
        // Device reference exists but device not found - critical issue
        issues.add(
          Issue(
            id: 'missing_device_${ref['type']}_${ref['id']}',
            code: 'DEVICE_MISSING',
            title: 'Device Not Found',
            description: 'Referenced device ${ref['type']} ${ref['id']} not found',
            severity: IssueSeverity.critical,
            category: IssueCategory.connectivity,
            detectedAt: DateTime.now(),
            metadata: {
              'deviceId': ref['id'],
              'deviceType': ref['type'],
            },
          ),
        );
        offlineDevices++;
        continue;
      }

      // Check device status
      final isOnline = _isDeviceOnline(device);
      if (isOnline) {
        onlineDevices++;
      } else {
        offlineDevices++;
        issues.add(
          Issue.deviceOffline(
            deviceId: _parseDeviceId(device),
            deviceName: _getDeviceName(device),
            deviceType: ref['type'] as String? ?? 'Device',
          ),
        );
      }

      // Check for other device issues
      final deviceIssues = _detectDeviceIssues(device, ref['type'] as String?);
      issues.addAll(deviceIssues);
    }

    // Determine room status
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
    // For DeviceModel objects
    try {
      final id = device.id;
      if (id is String) {
        // Extract numeric part from prefixed IDs like 'ap_123'
        final match = RegExp(r'\d+').firstMatch(id);
        return int.tryParse(match?.group(0) ?? '') ?? 0;
      }
    } catch (_) {}
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

  dynamic _findDevice(Map<String, dynamic> ref, List deviceModels) {
    final refId = ref['id']?.toString();
    final refType = ref['type'] as String?;
    if (refId == null) return null;

    // Build expected device ID with prefix
    final prefix = switch (refType) {
      'AP' => 'ap_',
      'ONT' => 'ont_',
      'Switch' => 'sw_',
      _ => '',
    };
    final prefixedId = '$prefix$refId';

    for (final device in deviceModels) {
      try {
        final deviceId = device.id as String?;
        if (deviceId == prefixedId || deviceId == refId) {
          return device;
        }
      } catch (_) {
        // Handle case where device is a Map
        if (device is Map<String, dynamic>) {
          if (device['id']?.toString() == refId) {
            return device;
          }
        }
      }
    }

    // Also check in the reference data itself (inline device data)
    final refData = ref['data'];
    if (refData is Map<String, dynamic> && refData.containsKey('online')) {
      return refData;
    }

    return null;
  }

  bool _isDeviceOnline(dynamic device) {
    if (device is Map<String, dynamic>) {
      return device['online'] == true;
    }
    try {
      return device.status?.toLowerCase() == 'online';
    } catch (_) {
      return false;
    }
  }

  List<Issue> _detectDeviceIssues(dynamic device, String? deviceType) {
    final issues = <Issue>[];

    // Check onboarding status
    try {
      final onboardingStatus = _getOnboardingStatus(device, deviceType);
      if (onboardingStatus != null && !_isOnboardingComplete(onboardingStatus, deviceType)) {
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
    } catch (_) {}
    return null;
  }

  bool _isOnboardingComplete(dynamic status, String? deviceType) {
    final stage = _getOnboardingStage(status);
    // AP success is stage 6, ONT success is stage 5
    final successStage = deviceType == 'AP' ? 6 : 5;
    return stage >= successStage;
  }

  int _getOnboardingStage(dynamic status) {
    if (status is Map<String, dynamic>) {
      return status['stage'] as int? ?? 0;
    }
    if (status is int) return status;
    return 0;
  }

  RoomStatus _determineRoomStatus({
    required int totalDevices,
    required int onlineDevices,
    required List<Issue> issues,
  }) {
    if (totalDevices == 0) {
      return RoomStatus.empty;
    }

    // Check for critical issues
    final hasCritical = issues.any((i) => i.severity == IssueSeverity.critical);
    if (hasCritical) {
      return RoomStatus.down;
    }

    // Check for any non-critical issues
    if (issues.isNotEmpty) {
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
