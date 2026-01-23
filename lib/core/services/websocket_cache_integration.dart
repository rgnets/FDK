import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/constants/device_field_sets.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/utils/image_url_normalizer.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_counts_model.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_notice_model.dart';

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
  })  : _webSocketService = webSocketService,
        _imageBaseUrl = imageBaseUrl,
        _logger = logger ?? Logger();

  final WebSocketService _webSocketService;
  final String? _imageBaseUrl;
  final Logger _logger;

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

  /// Get cached devices by resource type.
  List<Map<String, dynamic>>? getCachedDevices(String resourceType) {
    return _deviceCache[resourceType];
  }

  /// Get all cached devices as DeviceModels.
  List<DeviceModel> getAllCachedDeviceModels() {
    final allDevices = <DeviceModel>[];

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

  DeviceModel? _mapToDeviceModel(
    String resourceType,
    Map<String, dynamic> deviceMap,
  ) {
    try {
      // DEBUG: Log raw device data keys to see what backend sends
      final hasHnCounts = deviceMap['hn_counts'] != null;
      final hasHealthNotices = deviceMap['health_notices'] != null;
      final phase = deviceMap['phase'];
      final pmsRoomId = deviceMap['pms_room_id'];
      final pmsRoom = deviceMap['pms_room'];
      print('RAW DEVICE [$resourceType] id=${deviceMap['id']}: pms_room_id=$pmsRoomId, pms_room=$pmsRoom, hn_counts=$hasHnCounts, phase=$phase');
      if (hasHnCounts) {
        print('  hn_counts value: ${deviceMap['hn_counts']}');
      }

      // Extract health notice counts if present
      final hnCounts = _extractHealthCounts(deviceMap);
      final healthNotices = _extractHealthNotices(deviceMap);

      switch (resourceType) {
        case 'access_points':
          return DeviceModel(
            id: 'ap_${deviceMap['id']}',
            name: deviceMap['name']?.toString() ?? 'AP-${deviceMap['id']}',
            type: 'access_point',
            status: _determineStatus(deviceMap),
            pmsRoomId: _extractPmsRoomId(deviceMap),
            macAddress: deviceMap['mac']?.toString() ?? '',
            ipAddress: deviceMap['ip']?.toString() ?? '',
            model: deviceMap['model']?.toString(),
            serialNumber: deviceMap['serial_number']?.toString(),
            note: deviceMap['note']?.toString(),
            images: _extractImages(deviceMap),
            hnCounts: hnCounts,
            healthNotices: healthNotices,
            metadata: deviceMap,
          );

        case 'media_converters':
          return DeviceModel(
            id: 'ont_${deviceMap['id']}',
            name: deviceMap['name']?.toString() ?? 'ONT-${deviceMap['id']}',
            type: 'ont',
            status: _determineStatus(deviceMap),
            pmsRoomId: _extractPmsRoomId(deviceMap),
            macAddress: deviceMap['mac']?.toString() ?? '',
            ipAddress: deviceMap['ip']?.toString() ?? '',
            model: deviceMap['model']?.toString(),
            serialNumber: deviceMap['serial_number']?.toString(),
            note: deviceMap['note']?.toString(),
            images: _extractImages(deviceMap),
            hnCounts: hnCounts,
            healthNotices: healthNotices,
            metadata: deviceMap,
          );

        case 'switch_devices':
          return DeviceModel(
            id: 'sw_${deviceMap['id']}',
            name: deviceMap['name']?.toString() ??
                deviceMap['nickname']?.toString() ??
                'Switch-${deviceMap['id']}',
            type: 'switch',
            status: _determineStatus(deviceMap),
            pmsRoomId: _extractPmsRoomId(deviceMap),
            macAddress: deviceMap['scratch']?.toString() ?? '',
            ipAddress: deviceMap['host']?.toString() ?? '',
            model: deviceMap['model']?.toString() ?? deviceMap['device']?.toString(),
            serialNumber: deviceMap['serial_number']?.toString(),
            note: deviceMap['note']?.toString(),
            images: _extractImages(deviceMap),
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
      if (idValue is int) return idValue;
      if (idValue is String) return int.tryParse(idValue);
    }
    return null;
  }

  List<String>? _extractImages(Map<String, dynamic> deviceMap) {
    final imagesValue = deviceMap['images'] ?? deviceMap['pictures'];
    return normalizeImageUrls(imagesValue, baseUrl: _imageBaseUrl);
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
        _applyUpsert(resourceType, resourceData);
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

  void _applyUpsert(String resourceType, Map<String, dynamic> data) {
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
      if (index >= 0) {
        cache[index] = data;
      } else {
        cache.add(data);
      }
      _deviceCache[resourceType] = cache;
      _bumpLastUpdate();
      _bumpDeviceUpdate();

      // Notify device callbacks
      for (final callback in _deviceDataCallbacks) {
        callback(resourceType, cache);
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

  /// Clears all cached data without disposing the integration.
  /// Call this during sign-out to prevent stale data from leaking to new sessions.
  void clearCaches() {
    _logger.i('WebSocketCacheIntegration: Clearing all caches');

    // Clear device and room caches
    _deviceCache.clear();
    _roomCache.clear();

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
