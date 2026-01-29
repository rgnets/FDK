import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/models/api_key_revocation_event.dart';
import 'package:rgnets_fdk/core/services/device_update_event_bus.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/utils/image_url_normalizer.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_counts_model.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_notice_model.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_status_payload.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

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
        _logger = logger ?? Logger(),
        _deviceUpdateEventBus = deviceUpdateEventBus;

  final WebSocketService _webSocketService;
  final String? _imageBaseUrl;
  final Logger _logger;
  final DeviceUpdateEventBus? _deviceUpdateEventBus;

  /// Device resource types to subscribe to.
  static const List<String> _deviceResourceTypes = [
    'access_points',
    'switch_devices',
    'media_converters',
  ];

  /// Room resource type.
  static const String _roomResourceType = 'pms_rooms';

  /// Speed test resource types.
  static const String _speedTestConfigResourceType = 'speed_tests';
  static const String _speedTestResultResourceType = 'speed_test_results';

  /// All resource types (devices + rooms + speed tests).
  static const List<String> _resourceTypes = [
    'access_points',
    'switch_devices',
    'media_converters',
    'pms_rooms',
    'speed_tests',
    'speed_test_results',
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

  /// Cached speed test config data.
  final List<Map<String, dynamic>> _speedTestConfigCache = [];

  /// Cached speed test result data.
  final List<Map<String, dynamic>> _speedTestResultCache = [];

  /// Update notifier for speed test configs.
  final ValueNotifier<DateTime?> lastSpeedTestConfigUpdate =
      ValueNotifier<DateTime?>(null);

  /// Update notifier for speed test results.
  final ValueNotifier<DateTime?> lastSpeedTestResultUpdate =
      ValueNotifier<DateTime?>(null);

  /// Callbacks for when speed test config data is received.
  final List<void Function(List<SpeedTestConfig>)> _speedTestConfigCallbacks =
      [];

  /// Callbacks for when speed test result data is received.
  final List<void Function(List<SpeedTestResult>)> _speedTestResultCallbacks =
      [];

  /// Stream controller for API key revocation events.
  final _apiKeyRevocationController =
      StreamController<ApiKeyRevocationEvent>.broadcast();

  /// Stream of API key revocation events.
  /// Listen to this stream to be notified when the API key has been revoked.
  Stream<ApiKeyRevocationEvent> get apiKeyRevocations =>
      _apiKeyRevocationController.stream;

  /// Register a callback for device data updates.
  void onDeviceData(DeviceDataCallback callback) {
    _deviceDataCallbacks.add(callback);
  }

  /// Register a callback for room data updates.
  void onRoomData(void Function(List<Map<String, dynamic>>) callback) {
    _roomDataCallbacks.add(callback);
  }

  /// Register a callback for speed test config data updates.
  void onSpeedTestConfigData(void Function(List<SpeedTestConfig>) callback) {
    _speedTestConfigCallbacks.add(callback);
  }

  /// Register a callback for speed test result data updates.
  void onSpeedTestResultData(void Function(List<SpeedTestResult>) callback) {
    _speedTestResultCallbacks.add(callback);
  }

  /// Get cached rooms.
  List<Map<String, dynamic>> getCachedRooms() {
    return List.unmodifiable(_roomCache);
  }

  /// Check if we have cached room data.
  bool get hasRoomCache => _roomCache.isNotEmpty;

  /// Check if we have cached device data.
  bool get hasDeviceCache => _deviceCache.values.any((list) => list.isNotEmpty);

  /// Check if we have cached speed test config data.
  bool get hasSpeedTestConfigCache => _speedTestConfigCache.isNotEmpty;

  /// Check if we have cached speed test result data.
  bool get hasSpeedTestResultCache => _speedTestResultCache.isNotEmpty;

  /// Get all cached speed test configs.
  List<SpeedTestConfig> getCachedSpeedTestConfigs() {
    return _speedTestConfigCache
        .map((json) {
          try {
            return SpeedTestConfig.fromJson(json);
          } catch (e) {
            _logger.w('Failed to parse speed test config: $e');
            return null;
          }
        })
        .whereType<SpeedTestConfig>()
        .toList();
  }

  /// Get adhoc speed test config (name contains 'adhoc' or first available).
  SpeedTestConfig? getAdhocSpeedTestConfig() {
    final configs = getCachedSpeedTestConfigs();
    if (configs.isEmpty) return null;

    // Try to find one with 'adhoc' in the name
    final adhocConfig = configs.firstWhereOrNull(
      (SpeedTestConfig c) => c.name?.toLowerCase().contains('adhoc') ?? false,
    );
    if (adhocConfig != null) return adhocConfig;

    // Fall back to first config
    return configs.first;
  }

  /// Get speed test config by ID.
  SpeedTestConfig? getSpeedTestConfigById(int? id) {
    if (id == null) return null;
    final match = _speedTestConfigCache.firstWhereOrNull(
      (Map<String, dynamic> json) => json['id'] == id,
    );
    return match != null ? SpeedTestConfig.fromJson(match) : null;
  }

  /// Get all cached speed test results.
  List<SpeedTestResult> getCachedSpeedTestResults() {
    return _speedTestResultCache
        .map((json) {
          try {
            return SpeedTestResult.fromJsonWithValidation(json);
          } catch (e) {
            _logger.w('Failed to parse speed test result: $e');
            return null;
          }
        })
        .whereType<SpeedTestResult>()
        .toList();
  }

  /// Get speed test results filtered by device ID.
  List<SpeedTestResult> getSpeedTestResultsForDevice(
    String deviceId, {
    String? deviceType,
  }) {
    final results = getCachedSpeedTestResults();
    // Parse numeric ID from prefixed ID (e.g., "ap_123" -> 123)
    final numericId = int.tryParse(deviceId.split('_').last);
    if (numericId == null) return [];

    if (deviceType == DeviceTypes.accessPoint || deviceId.startsWith('ap_')) {
      return results
          .where((r) => r.testedViaAccessPointId == numericId)
          .toList();
    } else if (deviceType == DeviceTypes.ont || deviceId.startsWith('ont_')) {
      return results
          .where((r) => r.testedViaMediaConverterId == numericId)
          .toList();
    }
    return [];
  }

  /// Get speed test results filtered by access point ID.
  List<SpeedTestResult> getSpeedTestResultsForAccessPointId(int accessPointId) {
    return getCachedSpeedTestResults()
        .where((r) => r.testedViaAccessPointId == accessPointId)
        .toList();
  }

  /// Get speed test results filtered by speed test config ID.
  List<SpeedTestResult> getSpeedTestResultsForConfigId(int speedTestId) {
    return getCachedSpeedTestResults()
        .where((r) => r.speedTestId == speedTestId)
        .toList();
  }

  /// Update a single speed test result in the cache.
  /// Used when we receive a direct response from an update request
  /// to ensure cache consistency without waiting for broadcast.
  /// Follows the same pattern as device cache updates.
  void updateSpeedTestResultInCache(Map<String, dynamic> data) {
    final id = data['id'];
    if (id == null) {
      _logger.w('updateSpeedTestResultInCache: Missing id in data');
      return;
    }

    final index = _speedTestResultCache.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      _speedTestResultCache[index] = data;
    } else {
      _speedTestResultCache.add(data);
    }
    _bumpLastUpdate();
    _bumpSpeedTestResultUpdate();
    _notifySpeedTestResultCallbacks();

    _logger.i('updateSpeedTestResultInCache: Updated result $id in cache');
  }

  /// Create an adhoc speed test result via WebSocket.
  /// Returns true if the creation was successful.
  Future<bool> createAdhocSpeedTestResult({
    required double downloadSpeed,
    required double uploadSpeed,
    required double latency,
    String? source,
    String? destination,
    int? port,
    String? protocol,
    bool passed = false,
    DateTime? initiatedAt,
    DateTime? completedAt,
    int? pmsRoomId,
    String? roomType,
  }) async {
    if (!_webSocketService.isConnected) {
      _logger.w('Cannot create speed test result: WebSocket not connected');
      return false;
    }

    try {
      // Get adhoc config to associate the result with
      final adhocConfig = getAdhocSpeedTestConfig();

      final params = <String, dynamic>{
        'download_mbps': downloadSpeed,
        'upload_mbps': uploadSpeed,
        'rtt': latency,
        'passed': passed,
        'test_type': 'iperf3',
        'initiated_at': (initiatedAt ?? DateTime.now()).toIso8601String(),
        'completed_at': (completedAt ?? DateTime.now()).toIso8601String(),
        if (adhocConfig?.id != null) 'speed_test_id': adhocConfig!.id,
        if (source != null) 'source': source,
        if (destination != null) 'destination': destination,
        if (port != null) 'port': port,
        if (protocol != null) 'iperf_protocol': protocol,
        if (pmsRoomId != null) 'pms_room_id': pmsRoomId,
        if (roomType != null) 'room_type': roomType,
      };

      final response = await _webSocketService.requestActionCable(
        action: 'create_resource',
        resourceType: _speedTestResultResourceType,
        additionalData: {'params': params},
        timeout: const Duration(seconds: 15),
      );

      // Add to local cache on success
      final data = response.payload['data'];
      if (data is Map<String, dynamic>) {
        _applyUpsert(_speedTestResultResourceType, data);
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Failed to create adhoc speed test result: $e');
      return false;
    }
  }

  /// Update an existing device speed test result via WebSocket.
  /// Returns true if the update was successful.
  Future<bool> updateDeviceSpeedTestResult({
    required String deviceId,
    required double downloadSpeed,
    required double uploadSpeed,
    required double latency,
    String? source,
    String? destination,
    int? port,
    String? protocol,
    bool passed = false,
    DateTime? initiatedAt,
    DateTime? completedAt,
    int? pmsRoomId,
    String? roomType,
  }) async {
    if (!_webSocketService.isConnected) {
      _logger.w('Cannot update speed test result: WebSocket not connected');
      return false;
    }

    try {
      // Parse numeric ID from prefixed device ID (e.g., "ap_123" -> 123)
      final numericId = int.tryParse(deviceId.split('_').last);
      if (numericId == null) {
        _logger.w('Cannot update speed test result: Invalid device ID format');
        return false;
      }

      // Look up existing results for this device to get the speed_test_id
      final existingResults = getSpeedTestResultsForDevice(deviceId);
      final speedTestId = existingResults.isNotEmpty
          ? existingResults.first.speedTestId // Results are sorted newest first
          : getAdhocSpeedTestConfig()?.id; // Fall back to adhoc config

      // Determine which ID field to use based on device type prefix
      final params = <String, dynamic>{
        'download_mbps': downloadSpeed,
        'upload_mbps': uploadSpeed,
        'rtt': latency,
        'passed': passed,
        'test_type': 'iperf3',
        'initiated_at': (initiatedAt ?? DateTime.now()).toIso8601String(),
        'completed_at': (completedAt ?? DateTime.now()).toIso8601String(),
        if (speedTestId != null) 'speed_test_id': speedTestId,
        if (source != null) 'source': source,
        if (destination != null) 'destination': destination,
        if (port != null) 'port': port,
        if (protocol != null) 'iperf_protocol': protocol,
        if (pmsRoomId != null) 'pms_room_id': pmsRoomId,
        if (roomType != null) 'room_type': roomType,
      };

      // Set the appropriate device association field based on prefix
      if (deviceId.startsWith('ap_')) {
        params['tested_via_access_point_id'] = numericId;
      } else if (deviceId.startsWith('ont_')) {
        params['tested_via_media_converter_id'] = numericId;
      }

      final response = await _webSocketService.requestActionCable(
        action: 'create_resource',
        resourceType: _speedTestResultResourceType,
        additionalData: {'params': params},
        timeout: const Duration(seconds: 15),
      );

      // Add to local cache on success
      final data = response.payload['data'];
      if (data is Map<String, dynamic>) {
        _applyUpsert(_speedTestResultResourceType, data);
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Failed to update device speed test result: $e');
      return false;
    }
  }

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
            metadata: deviceMap,
            onboardingStatus: deviceMap['ap_onboarding_status'] != null
                ? OnboardingStatusPayload.fromJson(
                    deviceMap['ap_onboarding_status'] as Map<String, dynamic>,
                  )
                : null,
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

  /// Extract images with both URLs and signed IDs.
  ImageExtraction? _extractImagesData(Map<String, dynamic> deviceMap) {
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

    // Check for API key revocation BEFORE other message processing
    if (_isApiKeyRevocation(message)) {
      _handleApiKeyRevocation(message);
      return;
    }

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

  /// Checks if the message indicates an API key revocation.
  ///
  /// Revocation can be indicated by:
  /// - A message with type 'api_key_revoked'
  /// - A 'disconnect' message with reason 'api_key_revoked'
  /// - ActionCable wrapped message with type in payload
  bool _isApiKeyRevocation(SocketMessage message) {
    // Direct revocation message type
    if (message.type == 'api_key_revoked') {
      return true;
    }

    // ActionCable wraps messages - check payload for type field
    // When server broadcasts via ActionCable, the outer message.type may be 'message'
    // and the actual type is in payload['type']
    final payloadType = message.payload['type'] as String?;
    if (payloadType == 'api_key_revoked') {
      return true;
    }

    // Disconnect message with revocation reason
    if (message.type == 'disconnect' || payloadType == 'disconnect') {
      final reason = message.payload['reason'] as String?;
      if (reason == 'api_key_revoked') {
        return true;
      }
    }

    return false;
  }

  /// Handles an API key revocation message by emitting an event.
  void _handleApiKeyRevocation(SocketMessage message) {
    final reason = message.payload['reason'] as String? ?? 'unknown';
    final userMessage = message.payload['message'] as String? ??
        'Your session has been invalidated. Please sign in again.';
    final timestampValue = message.payload['timestamp'];
    DateTime? timestamp;
    if (timestampValue is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue * 1000);
    }

    _logger.w(
      'WebSocketCacheIntegration: API key revoked - reason: $reason',
    );

    // Emit revocation event for auth layer to handle
    _apiKeyRevocationController.add(ApiKeyRevocationEvent(
      reason: reason,
      message: userMessage,
      timestamp: timestamp,
    ));
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
    } else if (resourceType == _speedTestConfigResourceType) {
      // Handle speed test config data
      _speedTestConfigCache
        ..clear()
        ..addAll(items);
      _bumpLastUpdate();
      _bumpSpeedTestConfigUpdate();

      _logger.i(
        'WebSocketCacheIntegration: speed_tests snapshot - ${items.length} items',
      );

      // Notify speed test config callbacks
      _notifySpeedTestConfigCallbacks();
    } else if (resourceType == _speedTestResultResourceType) {
      // Handle speed test result data
      _speedTestResultCache
        ..clear()
        ..addAll(items);
      _bumpLastUpdate();
      _bumpSpeedTestResultUpdate();

      _logger.i(
        'WebSocketCacheIntegration: speed_test_results snapshot - ${items.length} items',
      );

      // Notify speed test result callbacks
      _notifySpeedTestResultCallbacks();
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
      // Check appropriate cache based on resource type
      bool hasCached;
      if (resourceType == _speedTestConfigResourceType) {
        hasCached = _speedTestConfigCache.isNotEmpty;
      } else if (resourceType == _speedTestResultResourceType) {
        hasCached = _speedTestResultCache.isNotEmpty;
      } else if (resourceType == _roomResourceType) {
        hasCached = _roomCache.isNotEmpty;
      } else {
        hasCached = _deviceCache[resourceType]?.isNotEmpty ?? false;
      }
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
    } else if (resourceType == _speedTestConfigResourceType) {
      // Handle speed test config upsert
      final index = _speedTestConfigCache.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        _speedTestConfigCache[index] = data;
      } else {
        _speedTestConfigCache.add(data);
      }
      _bumpLastUpdate();
      _bumpSpeedTestConfigUpdate();
      _notifySpeedTestConfigCallbacks();
    } else if (resourceType == _speedTestResultResourceType) {
      // Handle speed test result upsert
      final index = _speedTestResultCache.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        _speedTestResultCache[index] = data;
      } else {
        _speedTestResultCache.add(data);
      }
      _bumpLastUpdate();
      _bumpSpeedTestResultUpdate();
      _notifySpeedTestResultCallbacks();
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
    } else if (resourceType == _speedTestConfigResourceType) {
      // Handle speed test config delete
      _speedTestConfigCache.removeWhere((item) => item['id'] == id);
      _bumpLastUpdate();
      _bumpSpeedTestConfigUpdate();
      _notifySpeedTestConfigCallbacks();
    } else if (resourceType == _speedTestResultResourceType) {
      // Handle speed test result delete
      _speedTestResultCache.removeWhere((item) => item['id'] == id);
      _bumpLastUpdate();
      _bumpSpeedTestResultUpdate();
      _notifySpeedTestResultCallbacks();
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

  void _bumpSpeedTestConfigUpdate() {
    lastSpeedTestConfigUpdate.value = DateTime.now();
  }

  void _bumpSpeedTestResultUpdate() {
    lastSpeedTestResultUpdate.value = DateTime.now();
  }

  void _notifySpeedTestConfigCallbacks() {
    final configs = getCachedSpeedTestConfigs();
    for (final callback in _speedTestConfigCallbacks) {
      callback(configs);
    }
  }

  void _notifySpeedTestResultCallbacks() {
    final results = getCachedSpeedTestResults();
    for (final callback in _speedTestResultCallbacks) {
      callback(results);
    }
  }

  /// Updates a single device in the cache with data from a REST response.
  ///
  /// Use this after a REST-based operation (like image upload) to ensure
  /// the WebSocket cache reflects the latest server state. This enables
  /// immediate UI updates without waiting for a WebSocket broadcast.
  ///
  /// Note: This uses `action: 'show'` to avoid emitting DeviceUpdateEvent,
  /// since the ImageUploadService already emits CacheInvalidationEvent
  /// which triggers DeviceNotifier refresh. Using 'update' would cause
  /// redundant refresh calls.
  ///
  /// [resourceType] - The resource type (e.g., 'access_points', 'media_converters')
  /// [deviceData] - The raw device data map from the REST response
  void updateDeviceFromRest(String resourceType, Map<String, dynamic> deviceData) {
    if (!_deviceResourceTypes.contains(resourceType)) {
      _logger.w(
        'WebSocketCacheIntegration: updateDeviceFromRest called with non-device resource: $resourceType',
      );
      return;
    }

    final id = deviceData['id'];
    if (id == null) {
      _logger.w('WebSocketCacheIntegration: updateDeviceFromRest called with no id');
      return;
    }

    _logger.i(
      'WebSocketCacheIntegration: Updating device from REST - '
      'resource=$resourceType, id=$id',
    );

    // Use existing upsert logic to update cache and notify listeners
    // Pass action: 'show' to avoid emitting DeviceUpdateEvent (prevents redundant refresh)
    _applyUpsert(resourceType, deviceData, action: 'show');
  }

  /// Clears device/room/speed test data caches and requests fresh data from server.
  /// Use this for "Clear Cache" in settings - keeps WebSocket connection alive.
  void clearDataAndRefresh() {
    _logger.i('WebSocketCacheIntegration: Clearing data caches and requesting refresh');

    // Clear device, room, and speed test caches
    _deviceCache.clear();
    _roomCache.clear();
    _speedTestConfigCache.clear();
    _speedTestResultCache.clear();

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

    // Clear device, room, and speed test caches
    _deviceCache.clear();
    _roomCache.clear();
    _speedTestConfigCache.clear();
    _speedTestResultCache.clear();

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
    _apiKeyRevocationController.close();
    for (final timer in _snapshotFlushTimers.values) {
      timer.cancel();
    }
    _snapshotFlushTimers.clear();
    _snapshotAccumulators.clear();
    lastUpdate.dispose();
    lastDeviceUpdate.dispose();
    lastSpeedTestConfigUpdate.dispose();
    lastSpeedTestResultUpdate.dispose();
    _deviceDataCallbacks.clear();
    _roomDataCallbacks.clear();
    _speedTestConfigCallbacks.clear();
    _speedTestResultCallbacks.clear();
    _deviceCache.clear();
    _roomCache.clear();
    _speedTestConfigCache.clear();
    _speedTestResultCache.clear();
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
