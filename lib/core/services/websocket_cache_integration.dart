import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

<<<<<<< HEAD
import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/services/device_update_event_bus.dart';
=======
import 'package:rgnets_fdk/core/services/ap_uplink_service.dart';
>>>>>>> 3bdf0aa (Uplink added)
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/utils/image_url_normalizer.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_counts_model.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_notice_model.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_status_payload.dart';

/// Callback type for when device data is received via WebSocket.
typedef DeviceDataCallback = void Function(
  String resourceType,
  List<Map<String, dynamic>> devices,
);

/// Keeps device and room caches in sync with WebSocket messages.
/// Similar to ATT-FE-Tool's WebSocketCacheIntegration.
class WebSocketCacheIntegration {
  WebSocketCacheIntegration({
    required WebSocketService webSocketService,
    String? imageBaseUrl,
    Logger? logger,
    DeviceUpdateEventBus? deviceUpdateEventBus,
  })  : _webSocketService = webSocketService,
        _imageBaseUrl = imageBaseUrl,
<<<<<<< HEAD
        _logger = logger ?? Logger(),
        _deviceUpdateEventBus = deviceUpdateEventBus;
=======
        _logger = logger ?? Logger() {
    _apUplinkCache = <int, APUplinkInfo>{};
    _apUplinkService = APUplinkService(
      webSocketService: _webSocketService,
      logger: _logger,
      cache: _apUplinkCache,
    );
  }
>>>>>>> 3bdf0aa (Uplink added)

  final WebSocketService _webSocketService;
  final String? _imageBaseUrl;
  final Logger _logger;
<<<<<<< HEAD
  final DeviceUpdateEventBus? _deviceUpdateEventBus;
=======
  late final Map<int, APUplinkInfo> _apUplinkCache;
  late final APUplinkService _apUplinkService;
>>>>>>> 3bdf0aa (Uplink added)

  /// Device resource types to subscribe to.
  static const List<String> _deviceResourceTypes = [
    'access_points',
    'switch_devices',
    'media_converters',
  ];

  /// Room resource type.
  static const String _roomResourceType = 'pms_rooms';

  /// All resource types (devices + rooms).
  static const List<String> _resourceTypes = [
    'access_points',
    'switch_devices',
    'media_converters',
    'pms_rooms',
  ];

  final ValueNotifier<DateTime?> lastUpdate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> lastDeviceUpdate = ValueNotifier<DateTime?>(null);

  StreamSubscription<SocketMessage>? _messageSub;
  StreamSubscription<SocketConnectionState>? _connectionSub;

  bool _initialized = false;
  bool _snapshotInFlight = false;
  bool _needsSnapshot = true;
  bool _channelConfirmed = false;
  bool _channelSubscribeSent = false;
  bool _resourcesSubscribed = false;
  final Set<String> _pendingSnapshots = {};
  final Set<String> _requestedSnapshots = {};
  final Set<String> _confirmedResources = {};
  final Map<String, _SnapshotAccumulator> _snapshotAccumulators = {};
  final Map<String, Timer> _snapshotFlushTimers = {};
  static const Duration _snapshotMergeWindow = Duration(seconds: 2);
  static const Duration _snapshotFlushDelay = Duration(milliseconds: 500);

  /// Callbacks for when device data is received.
  final List<DeviceDataCallback> _deviceDataCallbacks = [];

  /// Cached device data by resource type.
  final Map<String, List<Map<String, dynamic>>> _deviceCache = {};

  /// Cached room data.
  final List<Map<String, dynamic>> _roomCache = [];

  /// Callbacks for when room data is received.
  final List<void Function(List<Map<String, dynamic>>)> _roomDataCallbacks = [];

  /// Register a callback for device data updates.
  void onDeviceData(DeviceDataCallback callback) {
    _deviceDataCallbacks.add(callback);
  }

  /// Register a callback for room data updates.
  void onRoomData(void Function(List<Map<String, dynamic>>) callback) {
    _roomDataCallbacks.add(callback);
  }

  /// Get cached rooms.
  List<Map<String, dynamic>> getCachedRooms() {
    return List.unmodifiable(_roomCache);
  }

  /// Check if we have cached room data.
  bool get hasRoomCache => _roomCache.isNotEmpty;

  /// Check if we have cached device data.
  bool get hasDeviceCache => _deviceCache.values.any((list) => list.isNotEmpty);

<<<<<<< HEAD
=======
  /// Check if we have cached speed test config data.
  bool get hasSpeedTestConfigCache => _speedTestConfigCache.isNotEmpty;

  /// Check if we have cached speed test result data.
  bool get hasSpeedTestResultCache => _speedTestResultCache.isNotEmpty;

  /// Get cached AP uplink info for a specific access point.
  APUplinkInfo? getCachedAPUplink(int apId) {
    return _apUplinkCache[apId];
  }

  /// Get AP uplink info, fetching and caching if needed.
  Future<APUplinkInfo?> getAPUplinkInfo(int apId) {
    return _apUplinkService.getAPUplinkPortDetail(apId);
  }

  /// Fetch AP uplink detail (3-step lookup) and update cache.
  Future<APUplinkInfo?> fetchAPUplinkDetail(int apId) {
    return _apUplinkService.fetchAPUplinkDetail(apId);
  }

  /// Register a callback for speed test config data updates.
  void onSpeedTestConfigData(void Function(List<SpeedTestConfig>) callback) {
    _speedTestConfigCallbacks.add(callback);
  }

  /// Register a callback for speed test result data updates.
  void onSpeedTestResultData(void Function(List<SpeedTestResult>) callback) {
    _speedTestResultCallbacks.add(callback);
  }

  /// Get cached speed test configs as domain entities.
  List<SpeedTestConfig> getCachedSpeedTestConfigs() {
    return _speedTestConfigCache.map((json) {
      try {
        return SpeedTestConfig.fromJson(json);
      } catch (e) {
        _logger.w('Failed to parse speed test config: $e');
        return null;
      }
    }).whereType<SpeedTestConfig>().toList();
  }

  /// Get cached speed test results as domain entities.
  List<SpeedTestResult> getCachedSpeedTestResults() {
    var parseFailures = 0;
    final results = _speedTestResultCache.map((json) {
      try {
        return SpeedTestResult.fromJsonWithValidation(json);
      } catch (e) {
        parseFailures++;
        LoggerService.warning(
          'Failed to parse speed test result id=${json['id']}: $e',
          tag: 'SpeedTestCache',
        );
        return null;
      }
    }).whereType<SpeedTestResult>().toList();

    if (parseFailures > 0) {
      LoggerService.warning(
        'Parse failures: $parseFailures out of ${_speedTestResultCache.length} raw results',
        tag: 'SpeedTestCache',
      );
    }

    return results;
  }

  /// Get cached speed test results for a specific access point.
  List<SpeedTestResult> getSpeedTestResultsForAccessPointId(int accessPointId) {
    // Debug: Log raw cache size
    LoggerService.info(
      'Raw cache has ${_speedTestResultCache.length} items, looking for accessPointId=$accessPointId',
      tag: 'SpeedTestCache',
    );

    // Log first few raw items to see tested_via_access_point_id values
    for (var i = 0; i < _speedTestResultCache.length && i < 5; i++) {
      final raw = _speedTestResultCache[i];
      // Check both the direct ID field and the nested association object
      final directId = raw['tested_via_access_point_id'];
      final nestedObj = raw['tested_via_access_point'];
      final nestedId = nestedObj is Map ? nestedObj['id'] : null;
      LoggerService.info(
        'RawCache[$i]: id=${raw['id']}, direct_id=$directId, nested_id=$nestedId',
        tag: 'SpeedTestCache',
      );
    }

    final results = getCachedSpeedTestResults();
    if (results.isEmpty) {
      LoggerService.info(
        'Parsed results is empty',
        tag: 'SpeedTestCache',
      );
      return [];
    }

    LoggerService.info(
      'Parsed ${results.length} results from cache',
      tag: 'SpeedTestCache',
    );

    // Log parsed results with their testedViaAccessPointId values
    final apIdSet = results
        .map((r) => r.testedViaAccessPointId)
        .where((id) => id != null)
        .toSet();
    LoggerService.info(
      'Unique testedViaAccessPointId values after parsing: $apIdSet',
      tag: 'SpeedTestCache',
    );

    final filtered = results
        .where((result) => result.testedViaAccessPointId == accessPointId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    LoggerService.info(
      'Found ${filtered.length} results for accessPointId=$accessPointId',
      tag: 'SpeedTestCache',
    );

    return filtered;
  }

  /// Get the adhoc speed test config (first config with "adhoc" in name, or first config if none match).
  SpeedTestConfig? getAdhocSpeedTestConfig() {
    final configs = getCachedSpeedTestConfigs();
    if (configs.isEmpty) return null;

    // Try to find a config with "adhoc" in the name
    final adhocConfig = configs.where(
      (c) => c.name?.toLowerCase().contains('adhoc') ?? false,
    ).firstOrNull;

    // Return adhoc config if found, otherwise return first config
    return adhocConfig ?? configs.first;
  }

  /// Get a speed test config by its ID.
  SpeedTestConfig? getSpeedTestConfigById(int? configId) {
    if (configId == null) {
      return null;
    }

    final configs = getCachedSpeedTestConfigs();
    return configs.where((c) => c.id == configId).firstOrNull;
  }

  /// Get cached speed test results for a specific device.
  /// Filters results by tested_via_access_point_id (AP) or
  /// tested_via_media_converter_id (ONT).
  ///
  /// [deviceId] can be prefixed ("ap_123") or unprefixed ("123").
  /// [deviceType] optional - if provided, used to determine which field to match.
  ///   Should be "access_point" or "ont" (matches DeviceTypes constants).
  List<SpeedTestResult> getSpeedTestResultsForDevice(
    String deviceId, {
    String? deviceType,
  }) {
    final results = getCachedSpeedTestResults();
    if (results.isEmpty) return [];

    // Try to extract device type and numeric ID from prefixed deviceId (e.g., "ap_123")
    String? extractedType;
    int? numericId;

    final parts = deviceId.split('_');
    if (parts.length >= 2) {
      // Prefixed format: "ap_123" or "ont_456"
      extractedType = parts[0].toLowerCase();
      numericId = int.tryParse(parts.sublist(1).join('_'));
    } else {
      // Unprefixed format: just "123"
      numericId = int.tryParse(deviceId);
    }

    if (numericId == null) return [];

    // Determine the effective device type
    // Priority: extracted from ID > passed deviceType parameter
    String? effectiveType = extractedType;
    if (effectiveType == null && deviceType != null) {
      // Map DeviceTypes constants to our internal types
      if (deviceType == 'access_point') {
        effectiveType = 'ap';
      } else if (deviceType == 'ont') {
        effectiveType = 'ont';
      }
    }

    if (effectiveType == null) {
      _logger.w(
        'getSpeedTestResultsForDevice: Cannot determine device type for $deviceId',
      );
      return [];
    }

    _logger.i(
      'getSpeedTestResultsForDevice: Searching for $effectiveType device with numericId=$numericId '
      'in ${results.length} cached results (raw cache: ${_speedTestResultCache.length})',
    );

    // Log first few raw results to see what's actually in the cache
    for (var i = 0; i < _speedTestResultCache.length && i < 3; i++) {
      final raw = _speedTestResultCache[i];
      _logger.i(
        'RawResult[$i]: id=${raw['id']}, access_point_id=${raw['access_point_id']}, '
        'tested_via_access_point_id=${raw['tested_via_access_point_id']}, '
        'tested_via_media_converter_id=${raw['tested_via_media_converter_id']}',
      );
    }

    // Log first few parsed results for debugging
    for (var i = 0; i < results.length && i < 3; i++) {
      final r = results[i];
      _logger.i(
        'ParsedResult[$i]: id=${r.id}, accessPointId=${r.accessPointId}, '
        'testedViaAccessPointId=${r.testedViaAccessPointId}, '
        'testedViaMediaConverterId=${r.testedViaMediaConverterId}',
      );
    }

    // Filter results based on device type
    return results.where((result) {
      if (effectiveType == 'ap') {
        // For access points, check tested_via_access_point_id only
        return result.testedViaAccessPointId == numericId;
      } else if (effectiveType == 'ont') {
        // For ONTs (media converters), check tested_via_media_converter_id
        return result.testedViaMediaConverterId == numericId;
      }
      return false;
    }).toList()
      // Sort by timestamp descending (most recent first)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get the most recent speed test result for a specific device.
  SpeedTestResult? getLatestSpeedTestResultForDevice(
    String deviceId, {
    String? deviceType,
  }) {
    final results = getSpeedTestResultsForDevice(deviceId, deviceType: deviceType);
    return results.isNotEmpty ? results.first : null;
  }

  /// Create an adhoc speed test result and send via WebSocket.
  /// Returns true if successful, false otherwise.
  ///
  /// If [deviceId] is provided (format: "ap_123" or "ont_456"), the appropriate
  /// device field (access_point_id or tested_via_media_converter_id) will be set.
  Future<bool> createAdhocSpeedTestResult({
    required double downloadSpeed,
    required double uploadSpeed,
    required double latency,
    String? source,
    String? destination,
    int? port,
    String? protocol,
    bool? passed,
    String? deviceId,
  }) async {
    // Find the adhoc config to get its ID
    final adhocConfig = getAdhocSpeedTestConfig();
    if (adhocConfig?.id == null) {
      _logger.w('WebSocketCacheIntegration: No adhoc config found for result submission');
      return false;
    }

    if (!_webSocketService.isConnected) {
      _logger.w('WebSocketCacheIntegration: Cannot submit result - WebSocket not connected');
      return false;
    }

    try {
      _logger.i(
        'WebSocketCacheIntegration: Submitting adhoc speed test result - '
        'configId=${adhocConfig!.id}, download=$downloadSpeed, upload=$uploadSpeed, deviceId=$deviceId',
      );

      // Parse deviceId to extract type and numeric ID for device association
      int? accessPointId;
      int? testedViaMediaConverterId;
      if (deviceId != null) {
        final parts = deviceId.split('_');
        if (parts.length >= 2) {
          final deviceType = parts[0].toLowerCase();
          final numericId = int.tryParse(parts.sublist(1).join('_'));
          if (numericId != null) {
            if (deviceType == 'ap') {
              accessPointId = numericId;
            } else if (deviceType == 'ont') {
              testedViaMediaConverterId = numericId;
            }
          }
        }
      }

      // Send CREATE request via ActionCable WebSocket
      final response = await _webSocketService.requestActionCable(
        action: 'create_resource',
        resourceType: _speedTestResultResourceType,
        additionalData: {
          'params': {
            'speed_test_id': adhocConfig.id,
            'download_mbps': downloadSpeed,
            'upload_mbps': uploadSpeed,
            'rtt': latency,
            'completed_at': DateTime.now().toIso8601String(),
            'test_type': 'iperf3',
            if (source != null) 'source': source,
            if (destination != null) 'destination': destination,
            if (port != null) 'port': port,
            if (protocol != null) 'iperf_protocol': protocol,
            if (passed != null) 'passed': passed,
            if (accessPointId != null) 'access_point_id': accessPointId,
            if (testedViaMediaConverterId != null) 'tested_via_media_converter_id': testedViaMediaConverterId,
          },
        },
        timeout: const Duration(seconds: 15),
      );

      final hasError = response.payload['error'] != null;
      if (hasError) {
        _logger.e(
          'WebSocketCacheIntegration: Failed to submit result - ${response.payload['error']}',
        );
        return false;
      }

      _logger.i('WebSocketCacheIntegration: Adhoc speed test result submitted successfully');
      return true;
    } catch (e) {
      _logger.e('WebSocketCacheIntegration: Error submitting adhoc result: $e');
      return false;
    }
  }

  /// Update an existing speed test result for a specific device.
  /// Finds the existing result by device ID (AP or ONT) and updates it.
  /// Returns true if successful, false otherwise.
  ///
  /// [deviceId] format: "ap_123" or "ont_456"
  Future<bool> updateDeviceSpeedTestResult({
    required String deviceId,
    required double downloadSpeed,
    required double uploadSpeed,
    required double latency,
    String? source,
    String? destination,
    int? port,
    String? protocol,
    bool? passed,
  }) async {
    if (!_webSocketService.isConnected) {
      _logger.w('WebSocketCacheIntegration: Cannot update result - WebSocket not connected');
      return false;
    }

    // Find existing result for this device
    final existingResult = getLatestSpeedTestResultForDevice(deviceId);
    if (existingResult == null || existingResult.id == null) {
      _logger.w(
        'WebSocketCacheIntegration: No existing speed test result found for device $deviceId',
      );
      return false;
    }

    try {
      _logger.i(
        'WebSocketCacheIntegration: Updating speed test result ${existingResult.id} for device $deviceId - '
        'download=$downloadSpeed, upload=$uploadSpeed',
      );

      // Send UPDATE request via ActionCable WebSocket
      final response = await _webSocketService.requestActionCable(
        action: 'update_resource',
        resourceType: _speedTestResultResourceType,
        additionalData: {
          'id': existingResult.id,
          'params': {
            'download_mbps': downloadSpeed,
            'upload_mbps': uploadSpeed,
            'rtt': latency,
            'completed_at': DateTime.now().toIso8601String(),
            if (source != null) 'source': source,
            if (destination != null) 'destination': destination,
            if (port != null) 'port': port,
            if (protocol != null) 'iperf_protocol': protocol,
            if (passed != null) 'passed': passed,
          },
        },
        timeout: const Duration(seconds: 15),
      );

      final hasError = response.payload['error'] != null;
      if (hasError) {
        _logger.e(
          'WebSocketCacheIntegration: Failed to update result - ${response.payload['error']}',
        );
        return false;
      }

      _logger.i(
        'WebSocketCacheIntegration: Speed test result ${existingResult.id} updated successfully',
      );
      return true;
    } catch (e) {
      _logger.e('WebSocketCacheIntegration: Error updating device result: $e');
      return false;
    }
  }

  /// Get cached speed test configs as raw JSON maps.
  List<Map<String, dynamic>> getCachedSpeedTestConfigsRaw() {
    return List.unmodifiable(_speedTestConfigCache);
  }

  /// Get cached speed test results as raw JSON maps.
  List<Map<String, dynamic>> getCachedSpeedTestResultsRaw() {
    return List.unmodifiable(_speedTestResultCache);
  }

  /// Update a single speed test result in the cache.
  /// This is useful after updating a result via the API to keep the cache in sync.
  /// Merges new data with existing cache entry to preserve fields the server may not return.
  void updateSpeedTestResultInCache(SpeedTestResult result) {
    if (result.id == null) {
      LoggerService.warning(
        'Cannot update speed test result in cache without id',
        tag: 'SpeedTestCache',
      );
      return;
    }

    final newJson = result.toJson();
    final index = _speedTestResultCache.indexWhere((item) => item['id'] == result.id);

    if (index >= 0) {
      // Merge new data with existing cache entry to preserve fields like pms_room_id
      // that the server may not return in the update response
      final existingJson = Map<String, dynamic>.from(_speedTestResultCache[index])
        ..addAll(newJson);
      _speedTestResultCache[index] = existingJson;
      LoggerService.info(
        'Updated speed test result ${result.id} in cache (merged with existing)',
        tag: 'SpeedTestCache',
      );
    } else {
      _speedTestResultCache.add(newJson);
      LoggerService.info(
        'Added speed test result ${result.id} to cache',
        tag: 'SpeedTestCache',
      );
    }
    _bumpLastUpdate();
  }

>>>>>>> 3bdf0aa (Uplink added)
  /// Get cached devices by resource type.
  List<Map<String, dynamic>>? getCachedDevices(String resourceType) {
    return _deviceCache[resourceType];
  }

  /// Get all cached devices as DeviceModelSealed.
  List<DeviceModelSealed> getAllCachedDeviceModels() {
    final allDevices = <DeviceModelSealed>[];

    for (final entry in _deviceCache.entries) {
      final resourceType = entry.key;
      final devices = entry.value;

      for (final deviceMap in devices) {
        try {
          final model = _mapToDeviceModel(resourceType, deviceMap);
          if (model != null) {
            allDevices.add(model);
          }
        } catch (e) {
          _logger.w('Failed to map device: $e');
        }
      }
    }

    return allDevices;
  }

  DeviceModelSealed? _mapToDeviceModel(
    String resourceType,
    Map<String, dynamic> deviceMap,
  ) {
    try {
      // Extract health notice counts if present
      final hnCounts = _extractHealthCounts(deviceMap);
      final healthNotices = _extractHealthNotices(deviceMap);

      // Debug: Log onboarding status fields
      if (resourceType == 'access_points') {
        final hasOnboarding = deviceMap['ap_onboarding_status'] != null;
        LoggerService.debug(
          'ONBOARDING: AP ${deviceMap['name']} (${deviceMap['id']}) - '
          'has ap_onboarding_status: $hasOnboarding',
          tag: 'WebSocket',
        );
        if (hasOnboarding) {
          LoggerService.info(
            'ONBOARDING: AP data: ${deviceMap['ap_onboarding_status']}',
            tag: 'WebSocket',
          );
        }
      }
      if (resourceType == 'media_converters') {
        final hasOnboarding = deviceMap['ont_onboarding_status'] != null;
        LoggerService.debug(
          'ONBOARDING: ONT ${deviceMap['name']} (${deviceMap['id']}) - '
          'has ont_onboarding_status: $hasOnboarding',
          tag: 'WebSocket',
        );
        if (hasOnboarding) {
          LoggerService.info(
            'ONBOARDING: ONT data: ${deviceMap['ont_onboarding_status']}',
            tag: 'WebSocket',
          );
        }
      }

      switch (resourceType) {
        case 'access_points':
          final apImageData = _extractImagesData(deviceMap);
          return DeviceModelSealed.ap(
            id: 'ap_${deviceMap['id']}',
            name: deviceMap['name']?.toString() ?? 'AP-${deviceMap['id']}',
            status: _determineStatus(deviceMap),
            pmsRoomId: _extractPmsRoomId(deviceMap),
            macAddress: deviceMap['mac']?.toString(),
            ipAddress: deviceMap['ip']?.toString(),
            model: deviceMap['model']?.toString(),
            serialNumber: deviceMap['serial_number']?.toString(),
            note: deviceMap['note']?.toString(),
            images: apImageData?.urls,
            imageSignedIds: apImageData?.signedIds,
            hnCounts: hnCounts,
            healthNotices: healthNotices,
<<<<<<< HEAD
            metadata: deviceMap,
            onboardingStatus: deviceMap['ap_onboarding_status'] != null
                ? OnboardingStatusPayload.fromJson(
                    deviceMap['ap_onboarding_status'] as Map<String, dynamic>,
                  )
                : null,
=======
            infrastructureLinkId: _parseOptionalInt(
              deviceMap['infrastructure_link_id'],
            ),
>>>>>>> 3bdf0aa (Uplink added)
          );

        case 'media_converters':
          final mcImageData = _extractImagesData(deviceMap);
          return DeviceModelSealed.ont(
            id: 'ont_${deviceMap['id']}',
            name: deviceMap['name']?.toString() ?? 'ONT-${deviceMap['id']}',
            status: _determineStatus(deviceMap),
            pmsRoomId: _extractPmsRoomId(deviceMap),
            macAddress: deviceMap['mac']?.toString(),
            ipAddress: deviceMap['ip']?.toString(),
            model: deviceMap['model']?.toString(),
            serialNumber: deviceMap['serial_number']?.toString(),
            note: deviceMap['note']?.toString(),
            images: mcImageData?.urls,
            imageSignedIds: mcImageData?.signedIds,
            hnCounts: hnCounts,
            healthNotices: healthNotices,
            metadata: deviceMap,
            onboardingStatus: deviceMap['ont_onboarding_status'] != null
                ? OnboardingStatusPayload.fromJson(
                    deviceMap['ont_onboarding_status'] as Map<String, dynamic>,
                  )
                : null,
          );

        case 'switch_devices':
          final swImageData = _extractImagesData(deviceMap);
          return DeviceModelSealed.switchDevice(
            id: 'sw_${deviceMap['id']}',
            name: deviceMap['name']?.toString() ??
                deviceMap['nickname']?.toString() ??
                'Switch-${deviceMap['id']}',
            status: _determineStatus(deviceMap),
            pmsRoomId: _extractPmsRoomId(deviceMap),
            macAddress: deviceMap['scratch']?.toString(),
            ipAddress: deviceMap['host']?.toString(),
            host: deviceMap['host']?.toString(),
            model: deviceMap['model']?.toString() ?? deviceMap['device']?.toString(),
            serialNumber: deviceMap['serial_number']?.toString(),
            note: deviceMap['note']?.toString(),
            images: swImageData?.urls,
            imageSignedIds: swImageData?.signedIds,
            hnCounts: hnCounts,
            healthNotices: healthNotices,
            metadata: deviceMap,
          );

        case 'wlan_devices':
          final wlanImageData = _extractImagesData(deviceMap);
          return DeviceModelSealed.wlan(
            id: 'wlan_${deviceMap['id']}',
            name: deviceMap['name']?.toString() ?? 'WLAN-${deviceMap['id']}',
            status: _determineStatus(deviceMap),
            macAddress: deviceMap['mac']?.toString(),
            ipAddress: deviceMap['host']?.toString() ?? deviceMap['ip']?.toString(),
            model: deviceMap['model']?.toString() ?? deviceMap['device']?.toString(),
            serialNumber: deviceMap['serial_number']?.toString(),
            note: deviceMap['note']?.toString(),
            images: wlanImageData?.urls,
            imageSignedIds: wlanImageData?.signedIds,
            hnCounts: hnCounts,
            healthNotices: healthNotices,
            metadata: deviceMap,
          );

        default:
          return null;
      }
    } catch (e) {
      _logger.e('Error mapping device: $e');
      return null;
    }
  }

  String _determineStatus(Map<String, dynamic> device) {
    final onlineFlag = device['online'] as bool?;
    if (onlineFlag != null) {
      return onlineFlag ? 'online' : 'offline';
    }
    return 'unknown';
  }

  int? _extractPmsRoomId(Map<String, dynamic> deviceMap) {
    // Primary: direct pms_room_id column (what backend actually sends)
    final directId = deviceMap['pms_room_id'];
    if (directId is int) return directId;
    if (directId is String) {
      final parsed = int.tryParse(directId);
      if (parsed != null) return parsed;
    }
    // Fallback: nested pms_room object (legacy/future compatibility)
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

<<<<<<< HEAD
  /// Extract images with both URLs and signed IDs.
  ImageExtraction? _extractImagesData(Map<String, dynamic> deviceMap) {
=======
  int? _parseOptionalInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  List<String>? _extractImages(Map<String, dynamic> deviceMap) {
>>>>>>> 3bdf0aa (Uplink added)
    final imagesValue = deviceMap['images'] ?? deviceMap['pictures'];
    return extractImagesWithSignedIds(imagesValue, baseUrl: _imageBaseUrl);
  }

  HealthCountsModel? _extractHealthCounts(Map<String, dynamic> deviceMap) {
    final hnCountsData = deviceMap['hn_counts'];
    if (hnCountsData == null) {
      return null;
    }
    _logger.i('WebSocketCacheIntegration: Found hn_counts for device ${deviceMap['name'] ?? deviceMap['id']}: $hnCountsData');
    if (hnCountsData is Map<String, dynamic>) {
      try {
        return HealthCountsModel.fromJson(hnCountsData);
      } catch (e) {
        _logger.w('Failed to parse hn_counts: $e');
        return null;
      }
    }
    return null;
  }

  List<HealthNoticeModel>? _extractHealthNotices(Map<String, dynamic> deviceMap) {
    final healthNoticesData = deviceMap['health_notices'];
    if (healthNoticesData == null) {
      return null;
    }
    if (healthNoticesData is List) {
      try {
        return healthNoticesData
            .whereType<Map<String, dynamic>>()
            .map(HealthNoticeModel.fromJson)
            .toList();
      } catch (e) {
        _logger.w('Failed to parse health_notices: $e');
        return null;
      }
    }
    return null;
  }

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _logger.i('WebSocketCacheIntegration: Initializing');
    _logger.i('WebSocketCacheIntegration: WebSocket connected: ${_webSocketService.isConnected}');

    _messageSub = _webSocketService.messages.listen((message) {
      _logger.d('WebSocketCacheIntegration: Message received - type: ${message.type}');
      _handleMessage(message);
    });

    _connectionSub = _webSocketService.connectionState.listen((state) {
      _logger.i('WebSocketCacheIntegration: Connection state changed: $state');
      _handleConnection(state);
    });

    if (_webSocketService.isConnected) {
      _logger.i('WebSocketCacheIntegration: Already connected, subscribing to resources');
      _subscribeToChannel();
    } else {
      _logger.i('WebSocketCacheIntegration: Waiting for WebSocket connection...');
    }
  }

  void _handleConnection(SocketConnectionState state) {
    _logger.i('WebSocketCacheIntegration: handleConnection - state: $state');

    if (state == SocketConnectionState.connected) {
      _logger.i('WebSocketCacheIntegration: Connected! Subscribing to resources...');
      _needsSnapshot = true;
      _channelSubscribeSent = false;
      _subscribeToChannel();
      return;
    }

    if (state == SocketConnectionState.disconnected) {
      _logger.i('WebSocketCacheIntegration: Disconnected, resetting state');
      _needsSnapshot = true;
      _snapshotInFlight = false;
      _channelConfirmed = false;
      _channelSubscribeSent = false;
      _resourcesSubscribed = false;
      _pendingSnapshots.clear();
      _requestedSnapshots.clear();
      _confirmedResources.clear();
      for (final timer in _snapshotFlushTimers.values) {
        timer.cancel();
      }
      _snapshotFlushTimers.clear();
      _snapshotAccumulators.clear();
    }
  }

  static const String _channelIdentifier = '{"channel":"RxgChannel"}';

  void _subscribeToChannel() {
    if (!_webSocketService.isConnected) {
      _logger.w('WebSocketCacheIntegration: Cannot subscribe, WebSocket not connected');
      return;
    }
    if (!_channelConfirmed) {
      _ensureChannelSubscription();
      _logger.i('WebSocketCacheIntegration: Waiting for channel confirmation before subscribing');
      return;
    }
    if (_resourcesSubscribed) {
      _logger.d('WebSocketCacheIntegration: Resources already subscribed');
      return;
    }
    _logger.i('WebSocketCacheIntegration: Channel already subscribed via auth, subscribing to resources');

    // The channel is already subscribed during auth.
    // Subscribe to resources using ActionCable message format.
    var allSubscribed = true;
    for (final resource in _resourceTypes) {
      final subscribed = _subscribeToResource(resource);
      if (!subscribed) {
        allSubscribed = false;
      }
    }
    _resourcesSubscribed = allSubscribed;

    // Request snapshots after a short delay to allow subscription confirmation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_needsSnapshot && _webSocketService.isConnected && _channelConfirmed) {
        _requestFullSnapshots();
      }
    });
  }

  bool _subscribeToResource(String resourceType) {
    _logger.d('WebSocketCacheIntegration: Subscribing to resource: $resourceType');

    // Send ActionCable formatted message
    return _sendActionCableMessage({
      'action': 'subscribe_to_resource',
      'resource_type': resourceType,
    });
  }

  bool _ensureChannelSubscription() {
    if (_channelConfirmed || _channelSubscribeSent) {
      return _channelConfirmed;
    }
    if (!_webSocketService.isConnected) {
      _logger.w('WebSocketCacheIntegration: Cannot subscribe to channel, WebSocket not connected');
      return false;
    }
    _logger.i('WebSocketCacheIntegration: Sending channel subscribe request');
    _channelSubscribeSent = true;
    _webSocketService.send({
      'command': 'subscribe',
      'identifier': _channelIdentifier,
    });
    return false;
  }

  /// Send a message using ActionCable protocol format
  bool _sendActionCableMessage(Map<String, dynamic> data) {
    if (!_webSocketService.isConnected) {
      _logger.w('WebSocketCacheIntegration: Skipping send, WebSocket not connected');
      return false;
    }
    _webSocketService.send({
      'command': 'message',
      'identifier': _channelIdentifier,
      'data': jsonEncode(data),
    });
    return true;
  }

  /// Request full snapshots for all resource types.
  void requestFullSnapshots() {
    _logger.i('WebSocketCacheIntegration: Manual sync requested');
    _needsSnapshot = true;
    _snapshotInFlight = false;
    _requestFullSnapshots();
  }

  void _requestFullSnapshots() {
    if (_snapshotInFlight) {
      _logger.d('WebSocketCacheIntegration: Snapshot already in flight');
      return;
    }
    if (!_webSocketService.isConnected || !_channelConfirmed) {
      _logger.w('WebSocketCacheIntegration: Delaying snapshot request until channel is ready');
      return;
    }

    _logger.i('WebSocketCacheIntegration: Requesting snapshots for: $_resourceTypes');

    _snapshotInFlight = true;
    _needsSnapshot = false;
    _pendingSnapshots
      ..clear()
      ..addAll(_resourceTypes);
    _requestedSnapshots.clear();

    var allSent = true;
    for (final resource in _resourceTypes) {
      // Use field selection for device resources to optimize payload size
      // Rooms don't need field selection (already small)
      final fields = _deviceResourceTypes.contains(resource)
          ? DeviceFieldSets.listFields
          : null;
      final sent = _requestSnapshot(resource, fields: fields);
      if (!sent) {
        allSent = false;
      }
    }
    if (!allSent) {
      _logger.w('WebSocketCacheIntegration: Snapshot requests deferred, will retry');
      _snapshotInFlight = false;
      _needsSnapshot = true;
    }
  }

  bool _requestSnapshot(String resourceType, {List<String>? fields}) {
    if (_requestedSnapshots.contains(resourceType)) return true;
    if (!_webSocketService.isConnected || !_channelConfirmed) {
      return false;
    }

    _logger.d('WebSocketCacheIntegration: Requesting snapshot for: $resourceType'
        '${fields != null ? " with ${fields.length} fields" : ""}');
    _requestedSnapshots.add(resourceType);

    // Send ActionCable formatted resource_action index request
    final payload = <String, dynamic>{
      'action': 'resource_action',
      'resource_type': resourceType,
      'crud_action': 'index',
      'page': 1,
      'page_size': 10000,
      'request_id': 'snapshot-$resourceType-${DateTime.now().millisecondsSinceEpoch}',
    };

    // Add field selection to optimize payload size (reduces by ~80%)
    // Must be comma-separated string, not array - RESTFramework expects string format
    if (fields != null && fields.isNotEmpty) {
      payload['only'] = fields.join(',');
    }

    final sent = _sendActionCableMessage(payload);
    if (!sent) {
      _requestedSnapshots.remove(resourceType);
      return false;
    }
    return true;
  }

  void _handleMessage(SocketMessage message) {
    final payload = message.payload;
    final raw = message.raw ?? {};

    // Log all messages for debugging
    _logger.d(
      'WebSocketCacheIntegration: Received message - type: ${message.type}, '
      'payload keys: ${payload.keys.toList()}, raw keys: ${raw.keys.toList()}',
    );

    if (_isChannelConfirmation(message)) {
      _logger.i('WebSocketCacheIntegration: Channel subscription confirmed');
      _channelConfirmed = true;
      _channelSubscribeSent = true;
      _subscribeToChannel();
      return;
    }
    if (_isChannelRejection(message)) {
      _logger.w('WebSocketCacheIntegration: Channel subscription rejected');
      _channelConfirmed = false;
      _channelSubscribeSent = false;
      _resourcesSubscribed = false;
      _needsSnapshot = true;
      return;
    }

    final resourceType = payload['resource_type']?.toString() ??
        raw['resource_type']?.toString();
    final action = _extractAction(message, payload, raw);

    if (resourceType == null || !_resourceTypes.contains(resourceType)) {
      // Log why we're ignoring this message
      if (resourceType != null) {
        _logger.d(
          'WebSocketCacheIntegration: Ignoring message for unknown resource: $resourceType',
        );
      }
      return;
    }

    _logger.i(
      'WebSocketCacheIntegration: Processing message - action=$action, resource=$resourceType',
    );

    // Check if it's a subscription confirmation
    if (action == 'subscription_confirmed') {
      _confirmedResources.add(resourceType);
      _logger.i('WebSocketCacheIntegration: Subscription confirmed: $resourceType');
      return;
    }

    // Check if it's a snapshot/index response
    if (_isSnapshotMessage(action, payload, raw)) {
      final items = _extractSnapshotItems(payload, raw);
      if (items != null) {
        _logger.i(
          'WebSocketCacheIntegration: Received snapshot for $resourceType: ${items.length} items',
        );

        // Log first item to debug images
        if (items.isNotEmpty) {
          final firstItem = items.first;
          _logger.d(
            'WebSocketCacheIntegration: First $resourceType item has images: ${firstItem['images']}',
          );
        }

        final requestId = _extractSnapshotRequestId(payload, raw);
        _applySnapshotAccumulated(resourceType, items, requestId);
        _markSnapshotHandled(resourceType);
      }
      return;
    }

    // Handle individual updates
    final resourceData = _extractResourceData(payload, raw);
    if (resourceData != null) {
      if (_isUpsertAction(action)) {
        _applyUpsert(resourceType, resourceData, action: action);
      } else if (_isDeleteAction(action)) {
        _applyDelete(resourceType, resourceData);
      }
    }
  }

  bool _isChannelConfirmation(SocketMessage message) {
    if (message.type != 'confirm_subscription') {
      return false;
    }
    return _identifierMatches(message);
  }

  bool _isChannelRejection(SocketMessage message) {
    if (message.type != 'reject_subscription') {
      return false;
    }
    return _identifierMatches(message);
  }

  bool _identifierMatches(SocketMessage message) {
    final headerIdentifier = message.headers?['identifier'];
    if (_identifierMatchesChannel(headerIdentifier)) {
      return true;
    }
    final rawIdentifier = message.raw?['identifier'];
    if (_identifierMatchesChannel(rawIdentifier)) {
      return true;
    }
    return false;
  }

  bool _identifierMatchesChannel(Object? identifier) {
    if (identifier is! String || identifier.isEmpty) {
      return false;
    }
    if (identifier == _channelIdentifier) {
      return true;
    }
    try {
      final decoded = jsonDecode(identifier);
      if (decoded is Map && decoded['channel'] == 'RxgChannel') {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  bool _isSnapshotMessage(
    String action,
    Map<String, dynamic> payload,
    Map<String, dynamic> raw,
  ) {
    if (action == 'resource_index' ||
        action == 'resource_list' ||
        action == 'snapshot' ||
        action == 'index' ||
        action == 'list') {
      return true;
    }

    // Check for results array
    if (payload['results'] is List) return true;
    if (raw['results'] is List) return true;

    return false;
  }

  String _extractAction(
    SocketMessage message,
    Map<String, dynamic> payload,
    Map<String, dynamic> raw,
  ) {
    final resourceAction = payload['resource_action'] ?? raw['resource_action'];
    if (resourceAction is String && resourceAction.isNotEmpty) {
      return resourceAction.toLowerCase();
    }
    final actionValue = payload['action'] ?? raw['action'];
    if (actionValue is String && actionValue.isNotEmpty) {
      return actionValue.toLowerCase();
    }
    return message.type.toLowerCase();
  }

  bool _isUpsertAction(String action) {
    return action == 'resource_created' ||
        action == 'resource_updated' ||
        action == 'created' ||
        action == 'updated' ||
        action == 'create' ||
        action == 'update' ||
        action == 'show';
  }

  bool _isDeleteAction(String action) {
    return action == 'resource_destroyed' ||
        action == 'destroyed' ||
        action == 'deleted' ||
        action == 'destroy';
  }

  /// Returns true for mutation actions that should emit update events.
  /// Excludes 'show' to prevent feedback loops when DeviceNotifier refreshes.
  bool _isMutationAction(String action) {
    return action == 'resource_created' ||
        action == 'resource_updated' ||
        action == 'created' ||
        action == 'updated' ||
        action == 'create' ||
        action == 'update';
  }

  /// Maps resource type and raw ID to prefixed device ID (e.g., 'ap_123').
  String? _mapToDeviceId(String resourceType, dynamic id) {
    if (id == null) return null;
    switch (resourceType) {
      case 'access_points':
        return 'ap_$id';
      case 'media_converters':
        return 'ont_$id';
      case 'switch_devices':
        return 'sw_$id';
      default:
        return null;
    }
  }

  /// Emits a device update event if the event bus is available.
  void _emitDeviceUpdateEvent(
    String resourceType,
    dynamic id,
    DeviceUpdateAction action, {
    List<String>? changedFields,
  }) {
    if (_deviceUpdateEventBus == null) return;
    if (!_deviceResourceTypes.contains(resourceType)) return;

    final deviceId = _mapToDeviceId(resourceType, id);
    if (deviceId == null) return;

    _logger.d(
      'WebSocketCacheIntegration: Emitting device update event - '
      'deviceId=$deviceId, action=$action',
    );

    _deviceUpdateEventBus.emit(
      DeviceUpdateEvent(
        deviceId: deviceId,
        action: action,
        changedFields: changedFields,
      ),
    );
  }

  List<Map<String, dynamic>>? _extractSnapshotItems(
    Map<String, dynamic> payload,
    Map<String, dynamic> raw,
  ) {
    if (payload['results'] is List) {
      return (payload['results'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (raw['results'] is List) {
      return (raw['results'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (payload['data'] is List) {
      return (payload['data'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return null;
  }

  Map<String, dynamic>? _extractResourceData(
    Map<String, dynamic> payload,
    Map<String, dynamic> raw,
  ) {
    if (payload.containsKey('id')) return payload;
    if (payload['data'] is Map<String, dynamic>) {
      return payload['data'] as Map<String, dynamic>;
    }
    if (raw['data'] is Map<String, dynamic>) {
      return raw['data'] as Map<String, dynamic>;
    }
    return null;
  }

  void _applySnapshot(String resourceType, List<Map<String, dynamic>> items) {
    if (resourceType == _roomResourceType) {
      // Handle room data
      _roomCache
        ..clear()
        ..addAll(items);
      _bumpLastUpdate();

      // Notify room callbacks
      for (final callback in _roomDataCallbacks) {
        callback(items);
      }
    } else if (_deviceResourceTypes.contains(resourceType)) {
      // Handle device data
      _deviceCache[resourceType] = items;
      _bumpLastUpdate();
      _bumpDeviceUpdate();

      // Debug: Log first device's keys to see what fields backend is sending
      if (items.isNotEmpty) {
        final firstItem = items.first;
        final hasHnCounts = firstItem.containsKey('hn_counts');
        final hasHealthNotices = firstItem.containsKey('health_notices');
        _logger.i(
          'WebSocketCacheIntegration: $resourceType snapshot - ${items.length} items, '
          'has hn_counts: $hasHnCounts, has health_notices: $hasHealthNotices',
        );
        if (!hasHnCounts && !hasHealthNotices) {
          _logger.i('  First item keys: ${firstItem.keys.toList()}');
        }
      }

      // Notify device callbacks
      for (final callback in _deviceDataCallbacks) {
        callback(resourceType, items);
      }
    }
  }

  void _applySnapshotAccumulated(
    String resourceType,
    List<Map<String, dynamic>> items,
    String? requestId,
  ) {
    final accumulator = _snapshotAccumulators.putIfAbsent(
      resourceType,
      _SnapshotAccumulator.new,
    );

    final shouldReset = _shouldResetAccumulator(accumulator, requestId);
    if (shouldReset) {
      accumulator.reset(requestId);
    }

    if (items.isEmpty) {
      accumulator.touch();
      final hasCached =
          (_deviceCache[resourceType]?.isNotEmpty ?? false) ||
          _roomCache.isNotEmpty;
      final hasAccumulated = accumulator.items.isNotEmpty;
      if (hasAccumulated || hasCached) {
        return;
      }
      _scheduleSnapshotFlush(resourceType, accumulator);
      return;
    }

    accumulator.addItems(items);
    _scheduleSnapshotFlush(resourceType, accumulator);
  }

  bool _shouldResetAccumulator(
    _SnapshotAccumulator accumulator,
    String? requestId,
  ) {
    if (requestId != null && requestId != accumulator.requestId) {
      return true;
    }
    if (requestId == null) {
      final age = DateTime.now().difference(accumulator.lastUpdated);
      if (age > _snapshotMergeWindow) {
        return true;
      }
    }
    return false;
  }

  String? _extractSnapshotRequestId(
    Map<String, dynamic> payload,
    Map<String, dynamic> raw,
  ) {
    final idFromPayload = payload['request_id'];
    if (idFromPayload != null) {
      return idFromPayload.toString();
    }
    final idFromRaw = raw['request_id'];
    if (idFromRaw != null) {
      return idFromRaw.toString();
    }
    return null;
  }

  void _scheduleSnapshotFlush(
    String resourceType,
    _SnapshotAccumulator accumulator,
  ) {
    final existingTimer = _snapshotFlushTimers[resourceType];
    if (existingTimer != null) {
      existingTimer.cancel();
    }

    _snapshotFlushTimers[resourceType] = Timer(_snapshotFlushDelay, () {
      _snapshotFlushTimers.remove(resourceType);
      _applySnapshot(resourceType, accumulator.items);
    });
  }

  void _applyUpsert(
    String resourceType,
    Map<String, dynamic> data, {
    String? action,
  }) {
    final id = data['id'];
    if (id == null) return;

    if (resourceType == _roomResourceType) {
      // Handle room upsert
      final index = _roomCache.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        _roomCache[index] = data;
      } else {
        _roomCache.add(data);
      }
      _bumpLastUpdate();

      // Notify room callbacks
      for (final callback in _roomDataCallbacks) {
        callback(_roomCache);
      }
    } else if (_deviceResourceTypes.contains(resourceType)) {
      // Handle device upsert
      final cache = _deviceCache[resourceType] ?? [];
      final index = cache.indexWhere((item) => item['id'] == id);
      final isNew = index < 0;
      if (isNew) {
        cache.add(data);
      } else {
        cache[index] = data;
      }
      _deviceCache[resourceType] = cache;
      _bumpLastUpdate();
      _bumpDeviceUpdate();

      // Notify device callbacks
      for (final callback in _deviceDataCallbacks) {
        callback(resourceType, cache);
      }

      // Emit device update event only for mutation actions (not 'show')
      // to prevent feedback loops when DeviceNotifier refreshes
      if (action != null && _isMutationAction(action)) {
        _emitDeviceUpdateEvent(
          resourceType,
          id,
          isNew ? DeviceUpdateAction.created : DeviceUpdateAction.updated,
        );
      }
    }
  }

  void _applyDelete(String resourceType, Map<String, dynamic> data) {
    final id = data['id'];
    if (id == null) return;

    if (resourceType == _roomResourceType) {
      // Handle room delete
      _roomCache.removeWhere((item) => item['id'] == id);
      _bumpLastUpdate();

      // Notify room callbacks
      for (final callback in _roomDataCallbacks) {
        callback(_roomCache);
      }
    } else if (_deviceResourceTypes.contains(resourceType)) {
      // Handle device delete
      final cache = _deviceCache[resourceType] ?? [];
      cache.removeWhere((item) => item['id'] == id);
      _deviceCache[resourceType] = cache;
      _bumpLastUpdate();
      _bumpDeviceUpdate();

      // Notify device callbacks
      for (final callback in _deviceDataCallbacks) {
        callback(resourceType, cache);
      }

      // Emit device update event for external apps to trigger refresh
      _emitDeviceUpdateEvent(
        resourceType,
        id,
        DeviceUpdateAction.destroyed,
      );
    }
  }

  void _markSnapshotHandled(String resourceType) {
    _pendingSnapshots.remove(resourceType);
    _requestedSnapshots.remove(resourceType);

    if (_pendingSnapshots.isEmpty) {
      _snapshotInFlight = false;
      _logger.i('WebSocketCacheIntegration: All snapshots received');
    }
  }

  void _bumpLastUpdate() {
    lastUpdate.value = DateTime.now();
  }

  void _bumpDeviceUpdate() {
    lastDeviceUpdate.value = DateTime.now();
  }

  /// Clears device/room data caches and requests fresh data from server.
  /// Use this for "Clear Cache" in settings - keeps WebSocket connection alive.
  void clearDataAndRefresh() {
    _logger.i('WebSocketCacheIntegration: Clearing data caches and requesting refresh');

    // Clear only device and room caches
    _deviceCache.clear();
    _roomCache.clear();

    // Request fresh snapshots if connected
    if (_webSocketService.isConnected && _channelConfirmed) {
      _needsSnapshot = true;
      _snapshotInFlight = false;
      _requestFullSnapshots();
    } else {
      _logger.w('WebSocketCacheIntegration: Not connected, will request data when reconnected');
      _needsSnapshot = true;
    }
  }

  /// Clears all cached data without disposing the integration.
  /// Call this during sign-out to prevent stale data from leaking to new sessions.
  void clearCaches() {
    _logger.i('WebSocketCacheIntegration: Clearing all caches');

    // Clear device and room caches
    _deviceCache.clear();
    _roomCache.clear();

<<<<<<< HEAD
=======
    // Clear speed test caches
    _speedTestConfigCache.clear();
    _speedTestResultCache.clear();
    _apUplinkService.clearCache();

>>>>>>> 3bdf0aa (Uplink added)
    // Clear snapshot state
    for (final timer in _snapshotFlushTimers.values) {
      timer.cancel();
    }
    _snapshotFlushTimers.clear();
    _snapshotAccumulators.clear();
    _pendingSnapshots.clear();
    _requestedSnapshots.clear();

    // Reset snapshot flags to request fresh data on next connection
    _needsSnapshot = true;
    _snapshotInFlight = false;

    // Reset subscription state
    _channelSubscribeSent = false;
    _channelConfirmed = false;
    _resourcesSubscribed = false;
    _confirmedResources.clear();

    _logger.d('WebSocketCacheIntegration: All caches cleared, ready for fresh data');
  }

  void dispose() {
    _messageSub?.cancel();
    _connectionSub?.cancel();
    for (final timer in _snapshotFlushTimers.values) {
      timer.cancel();
    }
    _snapshotFlushTimers.clear();
    _snapshotAccumulators.clear();
    lastUpdate.dispose();
    lastDeviceUpdate.dispose();
    _deviceDataCallbacks.clear();
    _roomDataCallbacks.clear();
    _deviceCache.clear();
    _roomCache.clear();
<<<<<<< HEAD
=======
    _speedTestConfigCache.clear();
    _speedTestResultCache.clear();
    _apUplinkService.clearCache();
>>>>>>> 3bdf0aa (Uplink added)
  }

  /// Request a specific resource type snapshot manually.
  void requestResourceSnapshot(String resourceType) {
    _logger.i('WebSocketCacheIntegration: Manual snapshot request for: $resourceType');
    _requestSnapshot(resourceType);
  }

  /// Expose the WebSocket service for direct requests.
  WebSocketService get webSocketService => _webSocketService;
}

class _SnapshotAccumulator {
  String? requestId;
  DateTime lastUpdated = DateTime.now();
  final Map<String, Map<String, dynamic>> _itemsById = {};

  List<Map<String, dynamic>> get items => _itemsById.values.toList();

  void reset(String? newRequestId) {
    requestId = newRequestId;
    lastUpdated = DateTime.now();
    _itemsById.clear();
  }

  void touch() {
    lastUpdated = DateTime.now();
  }

  void addItems(List<Map<String, dynamic>> items) {
    for (final item in items) {
      final idValue = item['id'];
      if (idValue == null) {
        continue;
      }
      _itemsById[idValue.toString()] = item;
    }
    lastUpdated = DateTime.now();
  }
}
