import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/models/api_key_revocation_event.dart';
import 'package:rgnets_fdk/core/services/device_update_event_bus.dart';
import 'package:rgnets_fdk/core/services/websocket_device_cache_service.dart';
import 'package:rgnets_fdk/core/services/websocket_room_cache_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/services/websocket_compliance_cache_service.dart';
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
    Future<void> Function({bool force})? onReconnectReseed,
    Future<void> Function(String resourceType)? onResourceReseed,
  })  : _webSocketService = webSocketService,
        _onReconnectReseed = onReconnectReseed,
        _onResourceReseed = onResourceReseed,
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
    _complianceCacheService = WebSocketComplianceCacheService(
      onDataChanged: _bumpLastUpdate,
    );
  }

  final WebSocketService _webSocketService;
  final Logger _logger;

  /// Triggers a full REST inventory reseed (devices + rooms). Full inventory
  /// is loaded over REST, off the AnyCable gRPC path, so it never competes
  /// with WS write actions. The WS layer only subscribes for live deltas.
  /// `force: true` bypasses the coordinator's cooldown — used for explicit
  /// loads (sign-in clear+reseed, manual sync) that must not be suppressed by
  /// a recently-completed seed; automatic reconnect heals pass `force: false`.
  final Future<void> Function({bool force})? _onReconnectReseed;

  /// Triggers a targeted single-resource REST reseed (used by the repurposed
  /// public snapshot methods that legacy callers still invoke).
  final Future<void> Function(String resourceType)? _onResourceReseed;

  /// Wall-clock when the socket last dropped, used to skip a reseed on brief
  /// reconnect flaps (only reseed if the gap exceeded [_reseedMinGap]).
  DateTime? _disconnectedAt;
  static const Duration _reseedMinGap = Duration(seconds: 10);

  /// Whether an initial full REST seed has been triggered since this
  /// integration started. Ensures the first connect (app launch / persisted
  /// session, with no prior disconnect) still seeds the caches.
  bool _hasSeededSinceStart = false;

  late final WebSocketSpeedTestCacheService _speedTestCacheService;
  late final WebSocketDeviceCacheService _deviceCacheService;
  late final WebSocketRoomCacheService _roomCacheService;
  late final WebSocketComplianceCacheService _complianceCacheService;

  // ---------------------------------------------------------------------------
  // Sub-service accessors
  // ---------------------------------------------------------------------------

  WebSocketSpeedTestCacheService get speedTestCacheService =>
      _speedTestCacheService;
  WebSocketDeviceCacheService get deviceCacheService => _deviceCacheService;
  WebSocketRoomCacheService get roomCacheService => _roomCacheService;
  WebSocketComplianceCacheService get complianceCacheService =>
      _complianceCacheService;

  // ---------------------------------------------------------------------------
  // Resource type constants
  // ---------------------------------------------------------------------------

  static const String _roomResourceType = 'pms_rooms';
  static const String _speedTestConfigResourceType = 'speed_tests';
  static const String _speedTestResultResourceType = 'speed_test_results';
  static const String _complianceResultResourceType =
      'compliance_check_results';

  /// All resource types (devices + rooms + speed tests + compliance).
  static const List<String> _resourceTypes = [
    'access_points',
    'switch_devices',
    'media_converters',
    'pms_rooms',
    'speed_tests',
    'speed_test_results',
    // Subscribe to `compliance_check_results` (history feed), NOT
    // `compliance_check_result_snapshots`. Deliberate spec deviation:
    // the snapshot table delegates `fleet_node_id` through its parent
    // `compliance_check_result` row, so the auto-routed snapshot JSON has
    // no `fleet_node_id` column to filter on. Results expose it directly,
    // letting FDK key its dedupe on `(compliance_rule_id, fleet_node_id)`
    // with `checked_at` as a tie-breaker without joining. See
    // `WebSocketComplianceCacheService` for the cache details and
    // `ComplianceRepositoryImpl._handleWsDelta` for the dedupe.
    'compliance_check_results',
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
  bool _channelConfirmed = false;
  bool _channelSubscribeSent = false;
  bool _resourcesSubscribed = false;
  final Set<String> _confirmedResources = {};
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
  SpeedTestConfig? getValidationConfigForDeviceType(String? deviceType) =>
      _speedTestCacheService.getValidationConfigForDeviceType(deviceType);
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
          'WebSocketCacheIntegration: Already connected, subscribing + seeding');
      // Route through the same path as a live `connected` event so the
      // first-connect REST seed fires even when this integration is created
      // after the socket is already up (connectionState is non-replaying, so
      // the initial `connected` event would otherwise be missed).
      _handleConnection(SocketConnectionState.connected);
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
      _channelSubscribeSent = false;
      _subscribeToChannel();
      // Load full inventory over REST on connect. The FIRST connect (app launch
      // / persisted-session reopen, `droppedAt == null`) must seed — there is
      // no WS `index` snapshot anymore. Reconnects only reseed if the gap was
      // long enough to have plausibly missed deltas (brief flaps skipped). The
      // coordinator additionally coalesces/throttles, and REST is off the gRPC
      // path so it never competes with WS writes like register_ap_device.
      final droppedAt = _disconnectedAt;
      _disconnectedAt = null;
      final isFirstConnect = droppedAt == null && !_hasSeededSinceStart;
      final gapWasLong = droppedAt != null &&
          DateTime.now().difference(droppedAt) > _reseedMinGap;
      if (_onReconnectReseed != null && (isFirstConnect || gapWasLong)) {
        _hasSeededSinceStart = true;
        // Initial seed forces past the cooldown; automatic reconnect heals are
        // throttled by it.
        unawaited(_onReconnectReseed(force: isFirstConnect));
      }
      return;
    }

    if (state == SocketConnectionState.disconnected) {
      _logger.i('WebSocketCacheIntegration: Disconnected, resetting state');
      _disconnectedAt ??= DateTime.now();
      _channelConfirmed = false;
      _channelSubscribeSent = false;
      _resourcesSubscribed = false;
      _confirmedResources.clear();
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
    // No WS `index` snapshot here: full inventory is loaded over REST by the
    // reseed coordinator. The subscriptions above are sufficient to receive
    // live `action=updated`/`destroyed` deltas into the same caches.
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
  // Full-inventory loading (delegated to REST reseed coordinator)
  //
  // The WS layer no longer issues `index` snapshots (page_size=10000 across
  // every resource saturated the rXg AnyCable→Ruby gRPC pool and starved WS
  // write actions like register_ap_device). Full inventory is fetched over
  // REST, off the gRPC path. These methods keep their names because legacy
  // callers (device data source, room readiness, image upload, registration)
  // still invoke them; they now route to the REST reseed coordinator.
  // ---------------------------------------------------------------------------

  void requestFullSnapshots() {
    if (_onReconnectReseed == null) {
      _logger.w('WebSocketCacheIntegration: No reseed callback wired');
      return;
    }
    _logger.i('WebSocketCacheIntegration: Full inventory reseed requested (REST)');
    // Explicit/programmatic request (sign-in clear+reseed, manual sync) — must
    // bypass the cooldown so a fresh sign-in's only seed is never suppressed.
    unawaited(_onReconnectReseed(force: true));
  }

  void requestResourceSnapshot(String resourceType) {
    if (_onResourceReseed == null) {
      _logger.w('WebSocketCacheIntegration: No resource reseed callback wired');
      return;
    }
    _logger.i('WebSocketCacheIntegration: Resource reseed requested (REST): $resourceType');
    unawaited(_onResourceReseed(resourceType));
  }

  void refreshResourceSnapshot(String resourceType) =>
      requestResourceSnapshot(resourceType);

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
      return;
    }

    final resourceType = payload['resource_type']?.toString() ??
        raw['resource_type']?.toString();
    final action = _extractAction(message, payload, raw);

    // rxg's `send_error` (RxgChannel#send_error) emits `action=error` with a
    // `status` and `error` field but NO `resource_type`, so it would otherwise
    // fall through the unknown-resource early-return below and be silently
    // dropped. Surface these explicitly so 429 / auth failures / unknown
    // resource type rejections are visible in logs and we can correlate to
    // pending snapshots via `request_id` if needed.
    if (action == 'error') {
      final status = payload['status'] ?? raw['status'];
      final errMsg = payload['error'] ?? raw['error'];
      final reqId = payload['request_id'] ?? raw['request_id'];
      _logger.w(
        'WebSocketCacheIntegration: WS error status=$status request_id=$reqId message=$errMsg',
      );
      return;
    }

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
      // WSCI no longer requests `index`/snapshots — full inventory is loaded
      // over REST by the reseed coordinator. Ignore any snapshot/list response
      // so an unrelated `index` reply (e.g. the scanner's targeted 10-row
      // device-lookup during registration) can't overwrite the REST-seeded
      // global cache. Live `action=updated`/`destroyed` deltas (handled below)
      // remain the only WS-driven cache mutations.
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

  // ---------------------------------------------------------------------------
  // Dispatch: upsert / delete → sub-services
  // ---------------------------------------------------------------------------

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
    } else if (resourceType == _complianceResultResourceType) {
      _complianceCacheService.applyUpsert(data);
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
    } else if (resourceType == _complianceResultResourceType) {
      _complianceCacheService.applyDelete(data);
    } else if (WebSocketDeviceCacheService.isDeviceResourceType(resourceType)) {
      _deviceCacheService.applyDelete(resourceType, data);
    }
    _bumpLastUpdate();
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
    _complianceCacheService.clearCaches();

    // Full inventory reloads over REST (off the gRPC path), not WS index.
    requestFullSnapshots();
  }

  void clearCaches() {
    _logger.i('WebSocketCacheIntegration: Clearing all caches');

    _deviceCacheService.clearCaches();
    _roomCacheService.clearCaches();
    _speedTestCacheService.clearCaches();
    _complianceCacheService.clearCaches();

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
    lastUpdate.dispose();

    _speedTestCacheService.dispose();
    _deviceCacheService.dispose();
    _roomCacheService.dispose();
    _complianceCacheService.dispose();
  }

  /// Expose the WebSocket service for direct requests.
  WebSocketService get webSocketService => _webSocketService;
}
