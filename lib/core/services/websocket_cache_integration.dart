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
    _complianceCacheService = WebSocketComplianceCacheService(
      onDataChanged: _bumpLastUpdate,
    );
  }

  final WebSocketService _webSocketService;
  final Logger _logger;

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
  bool _snapshotInFlight = false;
  bool _needsSnapshot = true;
  // True once any snapshot response has arrived in the current cycle. Lets the
  // retry path tell a dead channel (no responses at all → re-subscribe) from a
  // single slow/missing resource (others returned → just advance).
  bool _snapshotResponseSeen = false;
  /// Wall-clock of the last time `requestFullSnapshots()` actually fired
  /// the WS requests. Multiple consumers (auth notifier, device WS data
  /// source, room readiness data source) each call `requestFullSnapshots()`
  /// independently right after sign-in. Without a coalesce window, that
  /// triples the snapshot traffic (21 WS requests instead of 7) and the
  /// rxg's `compliance_check_results` channel can also briefly hit its
  /// rate limit during the burst.
  DateTime? _lastSnapshotFiredAt;
  static const Duration _snapshotCoalesceWindow = Duration(seconds: 5);

  /// Per-resource retry timer. The rxg's WS `index` handler sometimes
  /// returns the inventory as a stream of `action=updated` upserts
  /// instead of a single `action=index` snapshot (observed on the
  /// large-site sign-in path). When that happens, the cache fills
  /// only with devices the rxg happens to poll while WS is up — the
  /// offline ones never arrive because their state isn't poll-driven.
  /// If the snapshot for a resource hasn't been marked handled within
  /// this window, re-fire its `index` request once. Limited per-resource
  /// to `_maxSnapshotRetries` to avoid amplifying any rate-limit issue.
  static const Duration _snapshotRetryDelay = Duration(seconds: 30);
  static const int _maxSnapshotRetries = 2;
  final Map<String, int> _snapshotRetryCount = {};
  Timer? _snapshotRetryTimer;

  /// Snapshot pagination. Each `index` page is requested with this size and
  /// the server returns `page`/`total_pages`; we loop through pages until the
  /// last one (see `_handleMessage`). A 10000-row single page held a DB
  /// connection for the whole query and shipped a multi-MB payload; smaller
  /// pages keep each query cheap and well under the rxg's 10s deadline.
  /// `_maxSnapshotPages` is a hard backstop so a misbehaving server can't
  /// loop forever.
  static const int _snapshotPageSize = 1000;
  static const int _maxSnapshotPages = 1000;
  bool _channelConfirmed = false;
  bool _channelSubscribeSent = false;
  bool _resourcesSubscribed = false;
  // Distinguishes the initial connect (where auth already subscribed the sid)
  // from a reconnect (new sid, nobody re-subscribes). Only reconnects need a
  // forced channel re-subscribe; forcing it on first connect makes the server
  // reject a duplicate as "already subscribed".
  bool _hasConnectedBefore = false;
  final Set<String> _pendingSnapshots = {};
  final Set<String> _requestedSnapshots = {};
  // request_id per resource for the in-progress paginated snapshot cycle.
  // Reused across pages so the accumulator merges them instead of resetting.
  final Map<String, String> _snapshotRequestIds = {};
  final Set<String> _confirmedResources = {};
  final Map<String, _SnapshotAccumulator> _snapshotAccumulators = {};
  final Map<String, Timer> _snapshotFlushTimers = {};
  static const Duration _snapshotMergeWindow = Duration(seconds: 2);
  static const Duration _snapshotFlushDelay = Duration(milliseconds: 500);
  static const String _channelIdentifier = '{"channel":"RxgChannel"}';

  /// Monotonic counter for `request_id` uniqueness. Wall-clock alone collides
  /// when two snapshot cycles are initiated within the same millisecond,
  /// which happens after a fast disconnect/reconnect.
  int _requestIdSeq = 0;
  String _newRequestId(String resourceType) {
    final seq = (++_requestIdSeq).toString().padLeft(4, '0');
    return 'snapshot-$resourceType-${DateTime.now().millisecondsSinceEpoch}-$seq';
  }

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
      if (_hasConnectedBefore) {
        // Reconnect: brand-new AnyCable session (sid) with NO RxgChannel
        // subscription. WebSocketService reconnects via reconnecting→connected
        // and never passes through `disconnected`, so without resetting these
        // the flags stay stale-true: we'd skip re-sending `command: subscribe`
        // and every later `command: message` would be rejected as "unknown
        // subscription". Auth only subscribes on the initial login, so the
        // re-subscribe has to happen here.
        _channelConfirmed = false;
        _resourcesSubscribed = false;
        _confirmedResources.clear();
      }
      _hasConnectedBefore = true;
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
      _snapshotRequestIds.clear();
      _confirmedResources.clear();
      // Invalidate the snapshot-coalesce window. A disconnect ends the
      // current snapshot cycle, so the very next `requestFullSnapshots()`
      // after reconnect must always fire — otherwise a flaky WS that drops
      // + reconnects within 5s would silently skip the post-reconnect
      // snapshot and leave the cache empty.
      _lastSnapshotFiredAt = null;
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
    final lastFired = _lastSnapshotFiredAt;
    if (lastFired != null &&
        DateTime.now().difference(lastFired) < _snapshotCoalesceWindow) {
      _logger.d(
        'WebSocketCacheIntegration: Manual sync coalesced (last fire ${DateTime.now().difference(lastFired).inMilliseconds}ms ago)',
      );
      return;
    }
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
    _lastSnapshotFiredAt = DateTime.now();
    _logger.i(
        'WebSocketCacheIntegration: Requesting snapshots for: $_resourceTypes');

    _snapshotInFlight = true;
    _needsSnapshot = false;
    _snapshotResponseSeen = false;
    _pendingSnapshots
      ..clear()
      ..addAll(_resourceTypes);
    _requestedSnapshots.clear();
    _snapshotRequestIds.clear();
    _snapshotRetryCount.clear();

    // Serialize: send one resource's index at a time, waiting for its snapshot
    // (via _markSnapshotHandled) or a retry timeout before sending the next.
    // Firing all five in parallel makes the rxg hold 5+ DB connections per
    // client at once; one-at-a-time keeps it to a single connection.
    if (!_sendNextSnapshot()) {
      _logger.w(
          'WebSocketCacheIntegration: First snapshot request deferred, will retry');
      _snapshotInFlight = false;
      _needsSnapshot = true;
      return;
    }
    _scheduleSnapshotRetry();
  }

  /// Serialized snapshot pump: sends the `index` request for the next queued
  /// resource, but only when none is currently in flight. Returns false only
  /// if a send was attempted and failed (e.g. the connection dropped).
  bool _sendNextSnapshot() {
    if (!_webSocketService.isConnected || !_channelConfirmed) return false;
    if (_requestedSnapshots.isNotEmpty) return true; // wait for the in-flight one
    for (final resource in _resourceTypes) {
      if (_pendingSnapshots.contains(resource)) {
        return _requestSnapshot(resource);
      }
    }
    return true; // queue drained
  }

  bool _requestSnapshot(String resourceType, {int page = 1}) {
    if (!_webSocketService.isConnected || !_channelConfirmed) {
      return false;
    }

    // Page 1 starts a fresh cycle: dedup against an in-flight cycle and mint a
    // request_id that's reused for pages 2,3,… so the accumulator merges them
    // instead of resetting per page. Later pages reuse the stored id.
    if (page == 1) {
      if (_requestedSnapshots.contains(resourceType)) return true;
      _requestedSnapshots.add(resourceType);
      _snapshotRequestIds[resourceType] = _newRequestId(resourceType);
    }
    final requestId = _snapshotRequestIds[resourceType];
    if (requestId == null) return false;

    _logger.d(
        'WebSocketCacheIntegration: Requesting $resourceType snapshot page $page (size $_snapshotPageSize)');

    // Deliberately no `only:` field filter. The rxg's WS index handler
    // takes a slow/incomplete path when `only:` is set on device-typed
    // resources (access_points, switch_devices, media_converters): instead
    // of returning a single snapshot response it streams individual
    // `action=updated` upserts and stops well before delivering the full
    // inventory. Without the filter, the snapshot returns cleanly with
    // every row in one batch. Trade-off: heavier payload per row.
    final payload = <String, dynamic>{
      'action': 'resource_action',
      'resource_type': resourceType,
      'crud_action': 'index',
      'page': page,
      'page_size': _snapshotPageSize,
      'request_id': requestId,
    };

    final sent = _sendActionCableMessage(payload);
    if (!sent && page == 1) {
      _requestedSnapshots.remove(resourceType);
      _snapshotRequestIds.remove(resourceType);
      return false;
    }
    return sent;
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
      final items = _extractSnapshotItems(payload, raw);
      if (items != null) {
        // A snapshot response arrived → the channel is alive this cycle.
        _snapshotResponseSeen = true;
        final requestId = _extractSnapshotRequestId(payload, raw);
        final page = _extractSnapshotInt(payload, raw, 'page') ?? 1;
        final totalPages = _extractSnapshotInt(payload, raw, 'total_pages');
        _logger.i(
          'WebSocketCacheIntegration: snapshot $resourceType page $page'
          '${totalPages != null ? '/$totalPages' : ''} (${items.length} items)',
        );

        // Merge this page into the accumulator (no flush yet) — all pages of a
        // cycle share one request_id, so the accumulator keeps growing.
        _accumulateSnapshotPage(resourceType, items, requestId);

        // Prefer the server's `total_pages`; fall back to a short page if it's
        // absent. Cap pages so a misbehaving server can't loop forever.
        final lastPage = (totalPages != null
                ? page >= totalPages
                : items.length < _snapshotPageSize) ||
            page >= _maxSnapshotPages;

        if (lastPage) {
          _flushSnapshot(resourceType);
          _markSnapshotHandled(resourceType);
        } else {
          // Same resource, next page, same request_id — stays in flight, so
          // the serialized queue doesn't advance to another resource yet.
          _requestSnapshot(resourceType, page: page + 1);
          // A page arrived = progress; reset the stall timer so a slow-but-
          // advancing multi-page fetch isn't restarted from page 1.
          _scheduleSnapshotRetry();
        }
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
    // `records` is the key the rxg's paginated `index` (apply_pagination)
    // returns the page rows under, alongside page/total_pages/count.
    if (payload['records'] is List) {
      return (payload['records'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (raw['records'] is List) {
      return (raw['records'] as List)
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

  /// Reads an int field (e.g. `page`, `total_pages`) from the snapshot
  /// response, tolerating num/String encodings, from payload then raw.
  int? _extractSnapshotInt(
    Map<String, dynamic> payload,
    Map<String, dynamic> raw,
    String key,
  ) {
    final value = payload[key] ?? raw[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // ---------------------------------------------------------------------------
  // Snapshot accumulation & dispatch
  // ---------------------------------------------------------------------------

  /// Merges one snapshot page into the per-resource accumulator. All pages of
  /// a cycle share the same [requestId], so the accumulator keeps growing
  /// (dedup by id) instead of resetting per page. Does NOT flush — the caller
  /// flushes once, after the final page, via [_flushSnapshot].
  void _accumulateSnapshotPage(
    String resourceType,
    List<Map<String, dynamic>> items,
    String? requestId,
  ) {
    final accumulator = _snapshotAccumulators.putIfAbsent(
      resourceType,
      _SnapshotAccumulator.new,
    );
    if (_shouldResetAccumulator(accumulator, requestId)) {
      accumulator.reset(requestId);
    }
    accumulator.addItems(items);
  }

  /// Applies the fully-accumulated snapshot for [resourceType] (all pages) to
  /// the cache, via the existing debounced flush. Skips an empty snapshot when
  /// the cache is already populated — the rxg occasionally returns an empty
  /// index erroneously, and we don't want to wipe good data.
  void _flushSnapshot(String resourceType) {
    final accumulator = _snapshotAccumulators[resourceType];
    if (accumulator == null) return;
    if (accumulator.items.isEmpty && _hasCachedItems(resourceType)) {
      _logger.w(
          'WebSocketCacheIntegration: skipping empty $resourceType snapshot (cache already populated)');
      return;
    }
    _scheduleSnapshotFlush(resourceType, accumulator);
  }

  bool _hasCachedItems(String resourceType) {
    if (resourceType == _speedTestConfigResourceType) {
      return _speedTestCacheService.hasCachedItems(isConfig: true);
    } else if (resourceType == _speedTestResultResourceType) {
      return _speedTestCacheService.hasCachedItems(isConfig: false);
    } else if (resourceType == _roomResourceType) {
      return _roomCacheService.hasRoomCache;
    } else if (resourceType == _complianceResultResourceType) {
      return _complianceCacheService.hasCache;
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
    } else if (resourceType == _complianceResultResourceType) {
      _complianceCacheService.applySnapshot(items);
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

  void _markSnapshotHandled(String resourceType) {
    _pendingSnapshots.remove(resourceType);
    _requestedSnapshots.remove(resourceType);
    _snapshotRequestIds.remove(resourceType);

    if (_pendingSnapshots.isEmpty) {
      _snapshotInFlight = false;
      _snapshotRetryTimer?.cancel();
      _snapshotRetryTimer = null;
      _logger.i('WebSocketCacheIntegration: All snapshots received');
    } else {
      // Serialized: this one's done, so send the next queued resource and
      // reset the retry window for it.
      _sendNextSnapshot();
      _scheduleSnapshotRetry();
    }
  }

  /// Schedule a one-shot retry after `_snapshotRetryDelay`. Resources still
  /// in `_pendingSnapshots` when the timer fires get their `index` request
  /// re-sent (up to `_maxSnapshotRetries` per resource). This recovers from
  /// the rxg's intermittent "stream upserts instead of snapshot" behavior.
  void _scheduleSnapshotRetry() {
    _snapshotRetryTimer?.cancel();
    _snapshotRetryTimer = Timer(_snapshotRetryDelay, _retryStaleSnapshots);
  }

  void _retryStaleSnapshots() {
    _snapshotRetryTimer = null;
    if (_pendingSnapshots.isEmpty) return;
    if (!_webSocketService.isConnected || !_channelConfirmed) {
      _scheduleSnapshotRetry();
      return;
    }
    // Serialized: at most one resource is in flight (in _requestedSnapshots);
    // the rest are queued and simply haven't been sent yet, so only the
    // in-flight one can be stale.
    final inFlight =
        _requestedSnapshots.isNotEmpty ? _requestedSnapshots.first : null;
    if (inFlight == null) {
      // Nothing in flight but the queue isn't empty — pump the next one.
      _sendNextSnapshot();
      _scheduleSnapshotRetry();
      return;
    }

    final attempts = _snapshotRetryCount[inFlight] ?? 0;
    if (attempts >= _maxSnapshotRetries) {
      if (!_snapshotResponseSeen) {
        // No snapshot response of any kind since this cycle began — the
        // RxgChannel subscription is almost certainly stale/dead (AnyCable
        // silently drops `command: message` on an unconfirmed channel after a
        // reconnect left `_channelConfirmed` stale-true, with no `connected`
        // event to recover). Re-subscribe from scratch; the confirm cascades
        // into a fresh snapshot round. This is the critical self-heal.
        _logger.w(
            'WebSocketCacheIntegration: no snapshot responses this cycle — re-subscribing RxgChannel (suspected dead subscription)');
        _resubscribeStaleChannel();
        return;
      }
      // The channel is alive (other resources have returned this cycle) — just
      // this one is slow/missing. Give up on it and advance so it can't block
      // the rest of the queue.
      _logger.w(
          'WebSocketCacheIntegration: Giving up snapshot for $inFlight (retried $attempts times), advancing queue');
      _pendingSnapshots.remove(inFlight);
      _requestedSnapshots.remove(inFlight);
      _snapshotRequestIds.remove(inFlight);
      if (_pendingSnapshots.isEmpty) {
        _snapshotInFlight = false;
        return;
      }
      _sendNextSnapshot();
      _scheduleSnapshotRetry();
      return;
    }

    _snapshotRetryCount[inFlight] = attempts + 1;
    _requestedSnapshots.remove(inFlight);
    _logger.i(
        'WebSocketCacheIntegration: Retrying snapshot for $inFlight (attempt ${attempts + 1}/$_maxSnapshotRetries)');
    _requestSnapshot(inFlight);
    _scheduleSnapshotRetry();
  }

  /// Recovery for a stale/dead RxgChannel subscription on an otherwise healthy
  /// socket (see [_retryStaleSnapshots]). Drops all channel/snapshot state and
  /// re-sends `command: subscribe` from scratch.
  void _resubscribeStaleChannel() {
    _logger.w(
        'WebSocketCacheIntegration: snapshots exhausted with no response — '
        'forcing RxgChannel re-subscribe (suspected stale subscription)');
    _channelConfirmed = false;
    _channelSubscribeSent = false;
    _resourcesSubscribed = false;
    _confirmedResources.clear();
    _snapshotInFlight = false;
    _snapshotResponseSeen = false;
    _snapshotRetryCount.clear();
    _requestedSnapshots.clear();
    _snapshotRequestIds.clear();
    _pendingSnapshots.clear();
    _needsSnapshot = true;
    _subscribeToChannel();
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
    _complianceCacheService.clearCaches();

    for (final timer in _snapshotFlushTimers.values) {
      timer.cancel();
    }
    _snapshotFlushTimers.clear();
    _snapshotAccumulators.clear();
    _pendingSnapshots.clear();
    _requestedSnapshots.clear();
    _snapshotRequestIds.clear();
    _snapshotRetryCount.clear();
    _snapshotRetryTimer?.cancel();
    _snapshotRetryTimer = null;

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
    _snapshotRetryTimer?.cancel();
    _snapshotRetryTimer = null;
    lastUpdate.dispose();

    _speedTestCacheService.dispose();
    _deviceCacheService.dispose();
    _roomCacheService.dispose();
    _complianceCacheService.dispose();
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

  void addItems(List<Map<String, dynamic>> items) {
    for (final item in items) {
      final idValue = item['id'];
      if (idValue == null) continue;
      _itemsById[idValue.toString()] = item;
    }
    lastUpdated = DateTime.now();
  }
}
