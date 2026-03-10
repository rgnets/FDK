import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/models/api_key_revocation_event.dart';
import 'package:rgnets_fdk/core/services/device_update_event_bus.dart';
import 'package:rgnets_fdk/core/services/websocket_device_cache_service.dart';
import 'package:rgnets_fdk/core/services/websocket_room_cache_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/services/websocket_speed_test_cache_service.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

// Re-export so consumers that import DeviceDataCallback from here keep working.
export 'package:rgnets_fdk/core/services/websocket_device_cache_service.dart'
    show DeviceDataCallback;

/// Keeps device, room, and speed test caches in sync with WebSocket messages.
///
/// Acts as a thin facade: owns connection lifecycle, message routing, and
/// snapshot batching, then delegates data operations to domain-specific
/// sub-services.
class WebSocketCacheIntegration {
  WebSocketCacheIntegration({
    required WebSocketService webSocketService,
    String? imageBaseUrl,
    Logger? logger,
    DeviceUpdateEventBus? deviceUpdateEventBus,
  })  : _webSocketService = webSocketService,
        _logger = logger ?? Logger() {
    _speedTestCacheService = WebSocketSpeedTestCacheService(
      webSocketService: webSocketService,
      logger: _logger,
      onDataChanged: _bumpLastUpdate,
    );
    _deviceCacheService = WebSocketDeviceCacheService(
      imageBaseUrl: imageBaseUrl,
      logger: _logger,
      deviceUpdateEventBus: deviceUpdateEventBus,
      onDataChanged: _bumpLastUpdate,
    );
    _roomCacheService = WebSocketRoomCacheService(
      onDataChanged: _bumpLastUpdate,
    );
  }

  final WebSocketService _webSocketService;
  final Logger _logger;

  late final WebSocketSpeedTestCacheService _speedTestCacheService;
  late final WebSocketDeviceCacheService _deviceCacheService;
  late final WebSocketRoomCacheService _roomCacheService;

  // ---------------------------------------------------------------------------
  // Sub-service accessors
  // ---------------------------------------------------------------------------

  WebSocketSpeedTestCacheService get speedTestCacheService =>
      _speedTestCacheService;
  WebSocketDeviceCacheService get deviceCacheService => _deviceCacheService;
  WebSocketRoomCacheService get roomCacheService => _roomCacheService;

  // ---------------------------------------------------------------------------
  // Resource type constants
  // ---------------------------------------------------------------------------

  static const String _roomResourceType = 'pms_rooms';
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

  // ---------------------------------------------------------------------------
  // Global state
  // ---------------------------------------------------------------------------

  final ValueNotifier<DateTime?> lastUpdate = ValueNotifier<DateTime?>(null);

  /// Stream controller for API key revocation events.
  final _apiKeyRevocationController =
      StreamController<ApiKeyRevocationEvent>.broadcast();

  /// Stream of API key revocation events.
  Stream<ApiKeyRevocationEvent> get apiKeyRevocations =>
      _apiKeyRevocationController.stream;

  // ---------------------------------------------------------------------------
  // Connection / subscription bookkeeping
  // ---------------------------------------------------------------------------

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
  static const String _channelIdentifier = '{"channel":"RxgChannel"}';

  // ---------------------------------------------------------------------------
  // Delegated public API: Speed Tests
  // ---------------------------------------------------------------------------

  ValueNotifier<DateTime?> get lastSpeedTestConfigUpdate =>
      _speedTestCacheService.lastSpeedTestConfigUpdate;
  ValueNotifier<DateTime?> get lastSpeedTestResultUpdate =>
      _speedTestCacheService.lastSpeedTestResultUpdate;

  bool get hasSpeedTestConfigCache =>
      _speedTestCacheService.hasSpeedTestConfigCache;
  bool get hasSpeedTestResultCache =>
      _speedTestCacheService.hasSpeedTestResultCache;

  List<SpeedTestConfig> getCachedSpeedTestConfigs() =>
      _speedTestCacheService.getCachedSpeedTestConfigs();
  SpeedTestConfig? getAdhocSpeedTestConfig() =>
      _speedTestCacheService.getAdhocSpeedTestConfig();
  SpeedTestResult? getMostRecentAdhocSpeedTestResult() =>
      _speedTestCacheService.getMostRecentAdhocSpeedTestResult();
  SpeedTestConfig? getSpeedTestConfigById(int? id) =>
      _speedTestCacheService.getSpeedTestConfigById(id);
  List<SpeedTestResult> getCachedSpeedTestResults() =>
      _speedTestCacheService.getCachedSpeedTestResults();
  List<SpeedTestResult> getSpeedTestResultsForDevice(String deviceId,
          {String? deviceType}) =>
      _speedTestCacheService.getSpeedTestResultsForDevice(deviceId,
          deviceType: deviceType);
  List<SpeedTestResult> getSpeedTestResultsForAccessPointId(
          int accessPointId) =>
      _speedTestCacheService
          .getSpeedTestResultsForAccessPointId(accessPointId);
  List<SpeedTestResult> getSpeedTestResultsForConfigId(int speedTestId) =>
      _speedTestCacheService.getSpeedTestResultsForConfigId(speedTestId);

  void updateSpeedTestResultInCache(Map<String, dynamic> data) =>
      _speedTestCacheService.updateSpeedTestResultInCache(data);

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
  }) =>
      _speedTestCacheService.createAdhocSpeedTestResult(
        downloadSpeed: downloadSpeed,
        uploadSpeed: uploadSpeed,
        latency: latency,
        source: source,
        destination: destination,
        port: port,
        protocol: protocol,
        passed: passed,
        initiatedAt: initiatedAt,
        completedAt: completedAt,
        pmsRoomId: pmsRoomId,
        roomType: roomType,
      );

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
  }) =>
      _speedTestCacheService.updateDeviceSpeedTestResult(
        deviceId: deviceId,
        downloadSpeed: downloadSpeed,
        uploadSpeed: uploadSpeed,
        latency: latency,
        source: source,
        destination: destination,
        port: port,
        protocol: protocol,
        passed: passed,
        initiatedAt: initiatedAt,
        completedAt: completedAt,
        pmsRoomId: pmsRoomId,
        roomType: roomType,
      );

  void onSpeedTestConfigData(void Function(List<SpeedTestConfig>) callback) =>
      _speedTestCacheService.onSpeedTestConfigData(callback);
  void removeSpeedTestConfigCallback(
          void Function(List<SpeedTestConfig>) callback) =>
      _speedTestCacheService.removeSpeedTestConfigCallback(callback);
  void onSpeedTestResultData(void Function(List<SpeedTestResult>) callback) =>
      _speedTestCacheService.onSpeedTestResultData(callback);
  void removeSpeedTestResultCallback(
          void Function(List<SpeedTestResult>) callback) =>
      _speedTestCacheService.removeSpeedTestResultCallback(callback);

  // ---------------------------------------------------------------------------
  // Delegated public API: Devices
  // ---------------------------------------------------------------------------

  ValueNotifier<DateTime?> get lastDeviceUpdate =>
      _deviceCacheService.lastDeviceUpdate;

  bool get hasDeviceCache => _deviceCacheService.hasDeviceCache;

  List<Map<String, dynamic>>? getCachedDevices(String resourceType) =>
      _deviceCacheService.getCachedDevices(resourceType);
  List<DeviceModelSealed> getAllCachedDeviceModels() =>
      _deviceCacheService.getAllCachedDeviceModels();
  DeviceModelSealed? mapToDeviceModel(
          String resourceType, Map<String, dynamic> deviceMap) =>
      _deviceCacheService.mapToDeviceModel(resourceType, deviceMap);

  void onDeviceData(DeviceDataCallback callback) =>
      _deviceCacheService.onDeviceData(callback);
  void removeDeviceDataCallback(DeviceDataCallback callback) =>
      _deviceCacheService.removeDeviceDataCallback(callback);

  void updateDeviceFromRest(
          String resourceType, Map<String, dynamic> deviceData) =>
      _deviceCacheService.updateDeviceFromRest(resourceType, deviceData);

  // ---------------------------------------------------------------------------
  // Delegated public API: Rooms
  // ---------------------------------------------------------------------------

  bool get hasRoomCache => _roomCacheService.hasRoomCache;
  List<Map<String, dynamic>> getCachedRooms() =>
      _roomCacheService.getCachedRooms();

  void onRoomData(void Function(List<Map<String, dynamic>>) callback) =>
      _roomCacheService.onRoomData(callback);
  void removeRoomDataCallback(
          void Function(List<Map<String, dynamic>>) callback) =>
      _roomCacheService.removeRoomDataCallback(callback);

  // ---------------------------------------------------------------------------
  // Initialization & connection lifecycle
  // ---------------------------------------------------------------------------

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _logger.i('WebSocketCacheIntegration: Initializing');
    _logger.i(
        'WebSocketCacheIntegration: WebSocket connected: ${_webSocketService.isConnected}');

    _messageSub = _webSocketService.messages.listen((message) {
      _logger.d(
          'WebSocketCacheIntegration: Message received - type: ${message.type}');
      _handleMessage(message);
    });

    _connectionSub = _webSocketService.connectionState.listen((state) {
      _logger.i(
          'WebSocketCacheIntegration: Connection state changed: $state');
      _handleConnection(state);
    });

    if (_webSocketService.isConnected) {
      _logger.i(
          'WebSocketCacheIntegration: Already connected, subscribing to resources');
      _subscribeToChannel();
    } else {
      _logger.i(
          'WebSocketCacheIntegration: Waiting for WebSocket connection...');
    }
  }

  void _handleConnection(SocketConnectionState state) {
    _logger.i('WebSocketCacheIntegration: handleConnection - state: $state');

    if (state == SocketConnectionState.connected) {
      _logger.i(
          'WebSocketCacheIntegration: Connected! Subscribing to resources...');
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

  // ---------------------------------------------------------------------------
  // Channel subscription
  // ---------------------------------------------------------------------------

  void _subscribeToChannel() {
    if (!_webSocketService.isConnected) {
      _logger.w(
          'WebSocketCacheIntegration: Cannot subscribe, WebSocket not connected');
      return;
    }
    if (!_channelConfirmed) {
      _ensureChannelSubscription();
      _logger.i(
          'WebSocketCacheIntegration: Waiting for channel confirmation before subscribing');
      return;
    }
    if (_resourcesSubscribed) {
      _logger.d('WebSocketCacheIntegration: Resources already subscribed');
      return;
    }
    _logger.i(
        'WebSocketCacheIntegration: Channel already subscribed via auth, subscribing to resources');

    var allSubscribed = true;
    for (final resource in _resourceTypes) {
      final subscribed = _subscribeToResource(resource);
      if (!subscribed) {
        allSubscribed = false;
      }
    }
    _resourcesSubscribed = allSubscribed;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_needsSnapshot &&
          _webSocketService.isConnected &&
          _channelConfirmed) {
        _requestFullSnapshots();
      }
    });
  }

  bool _subscribeToResource(String resourceType) {
    _logger.d(
        'WebSocketCacheIntegration: Subscribing to resource: $resourceType');
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
      _logger.w(
          'WebSocketCacheIntegration: Cannot subscribe to channel, WebSocket not connected');
      return false;
    }
    _logger.i(
        'WebSocketCacheIntegration: Sending channel subscribe request');
    _channelSubscribeSent = true;
    try {
      _webSocketService.send({
        'command': 'subscribe',
        'identifier': _channelIdentifier,
      });
    } on StateError catch (e) {
      _logger.w(
          'WebSocketCacheIntegration: Send failed (connection closed): $e');
      _channelSubscribeSent = false;
      return false;
    }
    return false;
  }

  bool _sendActionCableMessage(Map<String, dynamic> data) {
    if (!_webSocketService.isConnected) {
      _logger.w(
          'WebSocketCacheIntegration: Skipping send, WebSocket not connected');
      return false;
    }
    try {
      _webSocketService.send({
        'command': 'message',
        'identifier': _channelIdentifier,
        'data': jsonEncode(data),
      });
      return true;
    } on StateError catch (e) {
      _logger.w(
          'WebSocketCacheIntegration: Send failed (connection closed): $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Snapshot requests
  // ---------------------------------------------------------------------------

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
      _logger.w(
          'WebSocketCacheIntegration: Delaying snapshot request until channel is ready');
      return;
    }

    _logger.i(
        'WebSocketCacheIntegration: Requesting snapshots for: $_resourceTypes');

    _snapshotInFlight = true;
    _needsSnapshot = false;
    _pendingSnapshots
      ..clear()
      ..addAll(_resourceTypes);
    _requestedSnapshots.clear();

    var allSent = true;
    for (final resource in _resourceTypes) {
      final fields = WebSocketDeviceCacheService.isDeviceResourceType(resource)
          ? DeviceFieldSets.listFields
          : null;
      final sent = _requestSnapshot(resource, fields: fields);
      if (!sent) {
        allSent = false;
      }
    }
    if (!allSent) {
      _logger.w(
          'WebSocketCacheIntegration: Snapshot requests deferred, will retry');
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

    final payload = <String, dynamic>{
      'action': 'resource_action',
      'resource_type': resourceType,
      'crud_action': 'index',
      'page': 1,
      'page_size': 10000,
      'request_id':
          'snapshot-$resourceType-${DateTime.now().millisecondsSinceEpoch}',
    };

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

  void requestResourceSnapshot(String resourceType) {
    _logger.i(
        'WebSocketCacheIntegration: Manual snapshot request for: $resourceType');
    _requestSnapshot(resourceType);
  }

  void refreshResourceSnapshot(String resourceType) {
    _logger.i(
        'WebSocketCacheIntegration: Force-refresh snapshot for: $resourceType');
    _requestedSnapshots.remove(resourceType);
    _requestSnapshot(resourceType);
  }

  // ---------------------------------------------------------------------------
  // Message handling & routing
  // ---------------------------------------------------------------------------

  void _handleMessage(SocketMessage message) {
    final payload = message.payload;
    final raw = message.raw ?? {};

    _logger.d(
      'WebSocketCacheIntegration: Received message - type: ${message.type}, '
      'payload keys: ${payload.keys.toList()}, raw keys: ${raw.keys.toList()}',
    );

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

    if (action == 'subscription_confirmed') {
      _confirmedResources.add(resourceType);
      _logger.i(
          'WebSocketCacheIntegration: Subscription confirmed: $resourceType');
      return;
    }

    if (_isSnapshotMessage(action, payload, raw)) {
      final items = _extractSnapshotItems(payload, raw);
      if (items != null) {
        _logger.i(
          'WebSocketCacheIntegration: Received snapshot for $resourceType: ${items.length} items',
        );

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

    final resourceData = _extractResourceData(payload, raw);
    if (resourceData != null) {
      if (_isUpsertAction(action)) {
        _applyUpsert(resourceType, resourceData, action: action);
      } else if (_isDeleteAction(action)) {
        _applyDelete(resourceType, resourceData);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Message classification helpers
  // ---------------------------------------------------------------------------

  bool _isChannelConfirmation(SocketMessage message) {
    if (message.type != 'confirm_subscription') return false;
    return _identifierMatches(message);
  }

  bool _isChannelRejection(SocketMessage message) {
    if (message.type != 'reject_subscription') return false;
    return _identifierMatches(message);
  }

  bool _isApiKeyRevocation(SocketMessage message) {
    if (message.type == 'api_key_revoked') return true;

    final payloadType = message.payload['type'] as String?;
    if (payloadType == 'api_key_revoked') return true;

    if (message.type == 'disconnect' || payloadType == 'disconnect') {
      final reason = message.payload['reason'] as String?;
      if (reason == 'api_key_revoked') return true;
    }

    return false;
  }

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

    _apiKeyRevocationController.add(ApiKeyRevocationEvent(
      reason: reason,
      message: userMessage,
      timestamp: timestamp,
    ));
  }

  bool _identifierMatches(SocketMessage message) {
    final headerIdentifier = message.headers?['identifier'];
    if (_identifierMatchesChannel(headerIdentifier)) return true;
    final rawIdentifier = message.raw?['identifier'];
    if (_identifierMatchesChannel(rawIdentifier)) return true;
    return false;
  }

  bool _identifierMatchesChannel(Object? identifier) {
    if (identifier is! String || identifier.isEmpty) return false;
    if (identifier == _channelIdentifier) return true;
    try {
      final decoded = jsonDecode(identifier);
      if (decoded is Map && decoded['channel'] == 'RxgChannel') return true;
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
    if (payload['results'] is List) return true;
    if (raw['results'] is List) return true;
    return false;
  }

  String _extractAction(
    SocketMessage message,
    Map<String, dynamic> payload,
    Map<String, dynamic> raw,
  ) {
    final resourceAction =
        payload['resource_action'] ?? raw['resource_action'];
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

  // ---------------------------------------------------------------------------
  // Data extraction helpers
  // ---------------------------------------------------------------------------

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

  String? _extractSnapshotRequestId(
    Map<String, dynamic> payload,
    Map<String, dynamic> raw,
  ) {
    final idFromPayload = payload['request_id'];
    if (idFromPayload != null) return idFromPayload.toString();
    final idFromRaw = raw['request_id'];
    if (idFromRaw != null) return idFromRaw.toString();
    return null;
  }

  // ---------------------------------------------------------------------------
  // Snapshot accumulation & dispatch
  // ---------------------------------------------------------------------------

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
      final hasCached = _hasCachedItems(resourceType);
      final hasAccumulated = accumulator.items.isNotEmpty;
      if (hasAccumulated || hasCached) return;
      _scheduleSnapshotFlush(resourceType, accumulator);
      return;
    }

    accumulator.addItems(items);
    _scheduleSnapshotFlush(resourceType, accumulator);
  }

  bool _hasCachedItems(String resourceType) {
    if (resourceType == _speedTestConfigResourceType) {
      return _speedTestCacheService.hasCachedItems(isConfig: true);
    } else if (resourceType == _speedTestResultResourceType) {
      return _speedTestCacheService.hasCachedItems(isConfig: false);
    } else if (resourceType == _roomResourceType) {
      return _roomCacheService.hasRoomCache;
    } else {
      return _deviceCacheService.hasCachedItems(resourceType);
    }
  }

  bool _shouldResetAccumulator(
    _SnapshotAccumulator accumulator,
    String? requestId,
  ) {
    if (requestId != null && requestId != accumulator.requestId) return true;
    if (requestId == null) {
      final age = DateTime.now().difference(accumulator.lastUpdated);
      if (age > _snapshotMergeWindow) return true;
    }
    return false;
  }

  void _scheduleSnapshotFlush(
    String resourceType,
    _SnapshotAccumulator accumulator,
  ) {
    _snapshotFlushTimers[resourceType]?.cancel();

    _snapshotFlushTimers[resourceType] = Timer(_snapshotFlushDelay, () {
      _snapshotFlushTimers.remove(resourceType);
      _applySnapshot(resourceType, accumulator.items);
    });
  }

  // ---------------------------------------------------------------------------
  // Dispatch: snapshot / upsert / delete → sub-services
  // ---------------------------------------------------------------------------

  void _applySnapshot(String resourceType, List<Map<String, dynamic>> items) {
    if (resourceType == _speedTestConfigResourceType) {
      _speedTestCacheService.applySnapshot(items, isConfig: true);
    } else if (resourceType == _speedTestResultResourceType) {
      _speedTestCacheService.applySnapshot(items, isConfig: false);
    } else if (resourceType == _roomResourceType) {
      _roomCacheService.applySnapshot(items);
    } else if (WebSocketDeviceCacheService.isDeviceResourceType(resourceType)) {
      _deviceCacheService.applySnapshot(resourceType, items);
    }
    _bumpLastUpdate();
  }

  void _applyUpsert(
    String resourceType,
    Map<String, dynamic> data, {
    String? action,
  }) {
    final id = data['id'];
    if (id == null) return;

    if (resourceType == _speedTestConfigResourceType) {
      _speedTestCacheService.applyUpsert(data,
          isConfig: true, action: action);
    } else if (resourceType == _speedTestResultResourceType) {
      _speedTestCacheService.applyUpsert(data,
          isConfig: false, action: action);
    } else if (resourceType == _roomResourceType) {
      _roomCacheService.applyUpsert(data);
    } else if (WebSocketDeviceCacheService.isDeviceResourceType(resourceType)) {
      _deviceCacheService.applyUpsert(resourceType, data, action: action);
    }
    _bumpLastUpdate();
  }

  void _applyDelete(String resourceType, Map<String, dynamic> data) {
    final id = data['id'];
    if (id == null) return;

    if (resourceType == _speedTestConfigResourceType) {
      _speedTestCacheService.applyDelete(data, isConfig: true);
    } else if (resourceType == _speedTestResultResourceType) {
      _speedTestCacheService.applyDelete(data, isConfig: false);
    } else if (resourceType == _roomResourceType) {
      _roomCacheService.applyDelete(data);
    } else if (WebSocketDeviceCacheService.isDeviceResourceType(resourceType)) {
      _deviceCacheService.applyDelete(resourceType, data);
    }
    _bumpLastUpdate();
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

  // ---------------------------------------------------------------------------
  // Cache management
  // ---------------------------------------------------------------------------

  void clearDataAndRefresh() {
    _logger.i(
        'WebSocketCacheIntegration: Clearing data caches and requesting refresh');

    _deviceCacheService.clearCaches();
    _roomCacheService.clearCaches();
    _speedTestCacheService.clearCaches();

    if (_webSocketService.isConnected && _channelConfirmed) {
      _needsSnapshot = true;
      _snapshotInFlight = false;
      _requestFullSnapshots();
    } else {
      _logger.w(
          'WebSocketCacheIntegration: Not connected, will request data when reconnected');
      _needsSnapshot = true;
    }
  }

  void clearCaches() {
    _logger.i('WebSocketCacheIntegration: Clearing all caches');

    _deviceCacheService.clearCaches();
    _roomCacheService.clearCaches();
    _speedTestCacheService.clearCaches();

    for (final timer in _snapshotFlushTimers.values) {
      timer.cancel();
    }
    _snapshotFlushTimers.clear();
    _snapshotAccumulators.clear();
    _pendingSnapshots.clear();
    _requestedSnapshots.clear();

    _needsSnapshot = true;
    _snapshotInFlight = false;

    _channelSubscribeSent = false;
    _channelConfirmed = false;
    _resourcesSubscribed = false;
    _confirmedResources.clear();

    _logger.d(
        'WebSocketCacheIntegration: All caches cleared, ready for fresh data');
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

    _speedTestCacheService.dispose();
    _deviceCacheService.dispose();
    _roomCacheService.dispose();
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
      if (idValue == null) continue;
      _itemsById[idValue.toString()] = item;
    }
    lastUpdated = DateTime.now();
  }
}
