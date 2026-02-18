import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/scanner/data/services/device_registration_service.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_registration_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/value_objects/serial_patterns.dart';

part 'device_registration_provider.g.dart';

/// Provider for the device registration service.
@riverpod
DeviceRegistrationService deviceRegistrationService(
  DeviceRegistrationServiceRef ref,
) {
  final wsService = ref.watch(webSocketServiceProvider);
  return DeviceRegistrationService(webSocketService: wsService);
}

/// Provider for device registration with WebSocket integration.
/// Handles checking existing devices and registering new ones.
@Riverpod(keepAlive: true)
class DeviceRegistrationNotifier extends _$DeviceRegistrationNotifier {
  StreamSubscription<SocketMessage>? _wsSubscription;

  // Dual-index cache for O(1) device lookup (populated from WebSocket events)
  final Map<String, Map<String, dynamic>> _deviceIndexByMac = {};
  final Map<String, Map<String, dynamic>> _deviceIndexBySerial = {};

  @override
  DeviceRegistrationState build() {
    // Subscribe to WebSocket device events
    _subscribeToWebSocket();

    // Clean up on dispose
    ref.onDispose(() {
      _wsSubscription?.cancel();
    });

    return const DeviceRegistrationState();
  }

  void _subscribeToWebSocket() {
    final wsService = ref.watch(webSocketServiceProvider);

    _wsSubscription?.cancel();
    _wsSubscription = wsService.messages.listen((message) {
      _handleWebSocketMessage(message);
    });
  }

  void _handleWebSocketMessage(SocketMessage message) {
    final type = message.type.toLowerCase();

    // Handle device-related WebSocket events
    if (_isDeviceEvent(type)) {
      LoggerService.debug(
        'DeviceRegistration: Received device event: $type',
        tag: 'DeviceRegistration',
      );

      // Handle specific event types
      if (type.contains('created') || type.contains('updated')) {
        _handleDeviceUpsert(message.payload);
      } else if (type.contains('destroyed') || type.contains('deleted')) {
        _handleDeviceRemove(message.payload);
      } else if (type.contains('snapshot') ||
          type.contains('index') ||
          type.contains('list')) {
        _handleDeviceSnapshot(message.payload);
      }
    }
  }

  bool _isDeviceEvent(String type) {
    return type.contains('access_point') ||
        type.contains('media_converter') ||
        type.contains('ont') ||
        type.contains('switch') ||
        type.contains('device');
  }

  void _handleDeviceUpsert(Map<String, dynamic> payload) {
    final device = payload['data'] ?? payload;
    if (device is! Map<String, dynamic>) return;

    final mac = _normalizeMac((device['mac'] ?? device['mac_address'] ?? '').toString());
    final serial =
        (device['serial_number'] ?? device['sn'] ?? '').toString().toUpperCase();

    if (mac.isNotEmpty) {
      _deviceIndexByMac[mac] = device;
    }
    if (serial.isNotEmpty) {
      _deviceIndexBySerial[serial] = device;
    }

    LoggerService.debug(
      'DeviceRegistration: Upserted device MAC=$mac, SN=$serial',
      tag: 'DeviceRegistration',
    );
  }

  void _handleDeviceRemove(Map<String, dynamic> payload) {
    final id = payload['id'] ?? payload['device_id'];
    if (id == null) return;

    // Remove from indexes by ID
    _deviceIndexByMac.removeWhere((_, device) => device['id'] == id);
    _deviceIndexBySerial.removeWhere((_, device) => device['id'] == id);

    LoggerService.debug(
      'DeviceRegistration: Removed device ID=$id',
      tag: 'DeviceRegistration',
    );
  }

  void _handleDeviceSnapshot(Map<String, dynamic> payload) {
    final items = payload['items'] ?? payload['data'] ?? payload['devices'];
    if (items is! List) return;

    // Rebuild indexes from snapshot
    _deviceIndexByMac.clear();
    _deviceIndexBySerial.clear();

    for (final item in items) {
      if (item is Map<String, dynamic>) {
        _handleDeviceUpsert(item);
      }
    }

    LoggerService.debug(
      'DeviceRegistration: Rebuilt indexes from snapshot (${items.length} devices)',
      tag: 'DeviceRegistration',
    );
  }

  String _normalizeMac(String mac) {
    // Remove separators and convert to uppercase
    return mac.replaceAll(RegExp('[^0-9A-Fa-f]'), '').toUpperCase();
  }

  /// Format MAC address for backend queries.
  /// Backend stores MACs as lowercase with colons: a1:b2:c3:d4:e5:f6
  String _formatMacForBackend(String mac) {
    final normalized = _normalizeMac(mac); // Remove all separators, uppercase
    if (normalized.length != 12) return mac.toLowerCase();

    // Insert colons and lowercase
    final buffer = StringBuffer();
    for (var i = 0; i < 12; i += 2) {
      if (i > 0) buffer.write(':');
      buffer.write(normalized.substring(i, i + 2).toLowerCase());
    }
    return buffer.toString();
  }

  /// Extract room ID from device payload (handles nested and flat structures).
  int? _extractRoomId(Map<String, dynamic> device) {
    // Try flat structure first
    if (device['pms_room_id'] != null) {
      return device['pms_room_id'] as int?;
    }
    // Try nested pms_room object
    final pmsRoom = device['pms_room'];
    if (pmsRoom is Map<String, dynamic>) {
      return pmsRoom['id'] as int?;
    }
    // Try alternate field names
    return device['room_id'] as int?;
  }

  /// Extract room name from device payload (handles nested and flat structures).
  String? _extractRoomName(Map<String, dynamic> device) {
    // Try nested pms_room object first (preferred for name)
    final pmsRoom = device['pms_room'];
    if (pmsRoom is Map<String, dynamic>) {
      return (pmsRoom['room_number'] ?? pmsRoom['name']) as String?;
    }
    // Try flat structure
    return (device['pms_room_name'] ?? device['room_name']) as String?;
  }

  /// Query the backend via WebSocket to find devices matching MAC or serial.
  /// Runs all queries in parallel for fast lookups.
  Future<List<Map<String, dynamic>>> _queryDevicesFromBackend({
    String? mac,
    String? serial,
  }) async {
    final wsService = ref.read(webSocketServiceProvider);
    if (!wsService.isConnected) {
      LoggerService.warning(
        'DeviceRegistration: WebSocket not connected, cannot query devices',
        tag: 'DeviceRegistration',
      );
      return [];
    }

    final resourceTypes = ['access_points', 'media_converters', 'switch_devices'];
    final futures = <Future<List<Map<String, dynamic>>>>[];

    final formattedMac = (mac != null && mac.isNotEmpty)
        ? _formatMacForBackend(mac)
        : null;

    for (final resourceType in resourceTypes) {
      if (formattedMac != null) {
        futures.add(_queryResource(wsService, resourceType, {'mac': formattedMac}));
      }
      if (serial != null && serial.isNotEmpty) {
        futures.add(_queryResource(wsService, resourceType, {'serial_number': serial}));
      }
    }

    if (futures.isEmpty) {
      return [];
    }

    final allResults = await Future.wait(futures);

    // Flatten and deduplicate by device ID
    final seen = <dynamic>{};
    final results = <Map<String, dynamic>>[];
    for (final batch in allResults) {
      for (final device in batch) {
        if (seen.add(device['id'])) {
          results.add(device);
        }
      }
    }

    return results;
  }

  /// Query a specific resource type with filters via WebSocket.
  Future<List<Map<String, dynamic>>> _queryResource(
    WebSocketService wsService,
    String resourceType,
    Map<String, String> filters,
  ) async {
    final requestId = 'device-lookup-${DateTime.now().millisecondsSinceEpoch}';
    final completer = Completer<List<Map<String, dynamic>>>();

    // Listen for the response
    StreamSubscription<SocketMessage>? subscription;
    subscription = wsService.messages.listen((message) {
      final payload = message.payload;
      if (payload['request_id'] == requestId) {
        subscription?.cancel();

        // Extract results from response
        final data = payload['data'];
        if (data is List) {
          completer.complete(
            data.whereType<Map<String, dynamic>>().toList(),
          );
        } else {
          completer.complete([]);
        }
      }
    });

    // Send the query
    final channelIdentifier = jsonEncode(const {'channel': 'RxgChannel'});
    final queryPayload = jsonEncode({
      'action': 'resource_action',
      'resource_type': resourceType,
      'crud_action': 'index',
      'request_id': requestId,
      'page_size': 10,
      ...filters,
    });

    wsService.send({
      'command': 'message',
      'identifier': channelIdentifier,
      'data': queryPayload,
    });

    // Wait for response with timeout
    try {
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          subscription?.cancel();
          LoggerService.warning(
            'DeviceRegistration: Query timeout for $resourceType',
            tag: 'DeviceRegistration',
          );
          return [];
        },
      );
    } on Exception catch (e) {
      unawaited(subscription.cancel());
      LoggerService.error(
        'DeviceRegistration: Query failed for $resourceType',
        error: e,
        tag: 'DeviceRegistration',
      );
      return [];
    }
  }

  /// Check if a device already exists with the given MAC and serial.
  /// Checks local cache first (O(1) lookup), falls back to backend query.
  Future<void> checkDeviceMatch({
    required String mac,
    required String serial,
    required DeviceType deviceType,
  }) async {
    state = state.copyWith(
      status: RegistrationStatus.checking,
      scannedMac: mac,
      scannedSerial: serial,
      deviceType: deviceType.name,
      matchStatus: DeviceMatchStatus.unchecked,
      mismatchInfo: null,
      errorMessage: null,
    );

    try {
      final normalizedMac = _normalizeMac(mac);
      final normalizedSerial = serial.toUpperCase().trim();

      // Try local cache first — O(1) lookup from WebSocket-populated indexes
      final deviceByMac = normalizedMac.isNotEmpty
          ? _deviceIndexByMac[normalizedMac]
          : null;
      final deviceBySerial = normalizedSerial.isNotEmpty
          ? _deviceIndexBySerial[normalizedSerial]
          : null;

      if (deviceByMac != null || deviceBySerial != null) {
        LoggerService.debug(
          'DeviceRegistration: Cache hit — MAC=${deviceByMac != null}, Serial=${deviceBySerial != null}',
          tag: 'DeviceRegistration',
        );
        _resolveMatch(
          deviceByMac: deviceByMac,
          deviceBySerial: deviceBySerial,
          normalizedMac: normalizedMac,
          normalizedSerial: normalizedSerial,
        );
        return;
      }

      // Cache miss — query backend (parallel across resource types)
      LoggerService.debug(
        'DeviceRegistration: Cache miss, querying backend for MAC=$normalizedMac, Serial=$normalizedSerial',
        tag: 'DeviceRegistration',
      );

      final matchingDevices = await _queryDevicesFromBackend(
        mac: normalizedMac,
        serial: normalizedSerial,
      );

      LoggerService.debug(
        'DeviceRegistration: Found ${matchingDevices.length} matching devices',
        tag: 'DeviceRegistration',
      );

      if (matchingDevices.isEmpty) {
        state = state.copyWith(
          status: RegistrationStatus.idle,
          matchStatus: DeviceMatchStatus.noMatch,
        );
        return;
      }

      // Find devices that match by MAC and/or serial from query results
      Map<String, dynamic>? queryDeviceByMac;
      Map<String, dynamic>? queryDeviceBySerial;

      for (final device in matchingDevices) {
        final devMac = _normalizeMac(
          (device['mac'] ?? device['mac_address'] ?? '').toString(),
        );
        final devSerial = (device['serial_number'] ?? device['sn'] ?? '')
            .toString()
            .toUpperCase()
            .trim();

        if (normalizedMac.isNotEmpty && devMac == normalizedMac) {
          queryDeviceByMac = device;
        }
        if (normalizedSerial.isNotEmpty && devSerial == normalizedSerial) {
          queryDeviceBySerial = device;
        }
      }

      _resolveMatch(
        deviceByMac: queryDeviceByMac,
        deviceBySerial: queryDeviceBySerial,
        normalizedMac: normalizedMac,
        normalizedSerial: normalizedSerial,
      );
    } catch (e, stack) {
      LoggerService.error(
        'DeviceRegistration: Check match failed',
        error: e,
        stackTrace: stack,
        tag: 'DeviceRegistration',
      );
      state = state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: 'Failed to check device: $e',
      );
    }
  }

  /// Resolve match status from device lookups (shared by cache and query paths).
  void _resolveMatch({
    required Map<String, dynamic>? deviceByMac,
    required Map<String, dynamic>? deviceBySerial,
    required String normalizedMac,
    required String normalizedSerial,
  }) {
    if (deviceByMac == null && deviceBySerial == null) {
      state = state.copyWith(
        status: RegistrationStatus.idle,
        matchStatus: DeviceMatchStatus.noMatch,
      );
      return;
    }

    // Check if MAC and serial point to different devices
    if (deviceByMac != null &&
        deviceBySerial != null &&
        deviceByMac['id'] != deviceBySerial['id']) {
      LoggerService.debug(
        'DeviceRegistration: Multiple devices — MAC→${deviceByMac['id']}, Serial→${deviceBySerial['id']}',
        tag: 'DeviceRegistration',
      );
      state = state.copyWith(
        status: RegistrationStatus.idle,
        matchStatus: DeviceMatchStatus.multipleMatch,
        errorMessage: 'MAC and serial match different devices',
      );
      return;
    }

    final existingDevice = deviceByMac ?? deviceBySerial!;
    final existingMac = _normalizeMac(
      (existingDevice['mac'] ?? existingDevice['mac_address'] ?? '').toString(),
    );
    final existingSerial = (existingDevice['serial_number'] ?? existingDevice['sn'] ?? '')
        .toString()
        .toUpperCase()
        .trim();

    final hasMacMismatch = normalizedMac.isNotEmpty &&
        existingMac.isNotEmpty &&
        normalizedMac != existingMac;
    final hasSerialMismatch = normalizedSerial.isNotEmpty &&
        existingSerial.isNotEmpty &&
        normalizedSerial != existingSerial;

    // Mismatch: found device by one field but the other field conflicts
    if ((deviceByMac != null && hasSerialMismatch) ||
        (deviceBySerial != null && hasMacMismatch)) {
      final mismatches = <String>[];
      if (hasMacMismatch) {
        mismatches.add('MAC Address');
      }
      if (hasSerialMismatch) {
        mismatches.add('Serial Number');
      }

      LoggerService.debug(
        'DeviceRegistration: Mismatch — $mismatches',
        tag: 'DeviceRegistration',
      );

      state = state.copyWith(
        status: RegistrationStatus.idle,
        matchStatus: DeviceMatchStatus.mismatch,
        matchedDeviceId: existingDevice['id'] as int?,
        matchedDeviceName: existingDevice['name'] as String?,
        mismatchInfo: MatchMismatchInfo(
          mismatchedFields: mismatches,
          expected: {
            'mac': existingMac,
            'serial_number': existingSerial,
          },
          scanned: {
            'mac': normalizedMac,
            'serial_number': normalizedSerial,
          },
        ),
      );
      return;
    }

    // Full match — existing device found
    final roomId = _extractRoomId(existingDevice);
    final roomName = _extractRoomName(existingDevice);

    LoggerService.debug(
      'DeviceRegistration: Full match — device ${existingDevice['id']} in room $roomName',
      tag: 'DeviceRegistration',
    );

    state = state.copyWith(
      status: RegistrationStatus.idle,
      matchStatus: DeviceMatchStatus.fullMatch,
      matchedDeviceId: existingDevice['id'] as int?,
      matchedDeviceName: existingDevice['name'] as String?,
      matchedDeviceRoomId: roomId,
      matchedDeviceRoomName: roomName,
    );
  }

  /// Register a new device via WebSocket.
  Future<RegistrationResult> registerDevice({
    required String mac,
    required String serial,
    required DeviceType deviceType,
    required int pmsRoomId,
    String? partNumber,
    String? model,
    int? existingDeviceId,
  }) async {
    state = state.copyWith(
      status: RegistrationStatus.registering,
      errorMessage: null,
    );

    try {
      // Validate serial pattern matches the device type
      // Use isValidForType instead of detectDeviceType to support EC2 serials
      // (EC2 is valid for both AP and Switch in manual mode)
      final serialType = _deviceTypeToSerialType(deviceType);
      final isValidSerial = SerialPatterns.isValidForType(serial, serialType);
      if (!isValidSerial) {
        final expected = SerialPatterns.getExpectedFormat(serialType);
        final error = 'Invalid serial number format for ${deviceType.displayName}. $expected';
        state = state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: error,
        );
        return RegistrationResult.failure(message: error);
      }

      final registrationService = ref.read(deviceRegistrationServiceProvider);

      final response = await registrationService.registerDevice(
        deviceType: deviceType,
        mac: mac,
        serialNumber: serial,
        pmsRoomId: pmsRoomId,
        partNumber: partNumber,
        model: model,
        existingDeviceId: existingDeviceId,
      );

      // Server confirmed — extract device ID from response
      final data = response.payload['data'] ?? response.payload;
      final deviceId = data is Map<String, dynamic>
          ? (data['id'] as int? ?? existingDeviceId ?? 0)
          : (existingDeviceId ?? 0);

      LoggerService.info(
        'DeviceRegistration: Server confirmed registration - $deviceType MAC=$mac, SN=$serial, Room=$pmsRoomId',
        tag: 'DeviceRegistration',
      );

      state = state.copyWith(
        status: RegistrationStatus.success,
        registeredAt: DateTime.now(),
      );

      return RegistrationResult.success(
        deviceId: deviceId,
        deviceType: deviceType.name,
      );
    } on TimeoutException {
      const error =
          'Server did not confirm registration. Check the device on the RXG.';
      LoggerService.warning(
        'DeviceRegistration: Registration timed out - $deviceType MAC=$mac, SN=$serial',
        tag: 'DeviceRegistration',
      );
      state = state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: error,
      );
      return const RegistrationResult.failure(message: error);
    } on Exception catch (e, stack) {
      LoggerService.error(
        'DeviceRegistration: Registration failed',
        error: e,
        stackTrace: stack,
        tag: 'DeviceRegistration',
      );

      final error = 'Registration failed: $e';
      state = state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: error,
      );

      return RegistrationResult.failure(message: error);
    }
  }

  /// Reset registration state to idle.
  void reset() {
    state = const DeviceRegistrationState();
  }

  /// Clear all cached device indexes.
  void clearIndexes() {
    _deviceIndexByMac.clear();
    _deviceIndexBySerial.clear();
  }

  /// Convert DeviceType to DeviceTypeFromSerial for serial validation.
  DeviceTypeFromSerial _deviceTypeToSerialType(DeviceType type) {
    switch (type) {
      case DeviceType.accessPoint:
        return DeviceTypeFromSerial.accessPoint;
      case DeviceType.ont:
        return DeviceTypeFromSerial.ont;
      case DeviceType.switchDevice:
        return DeviceTypeFromSerial.switchDevice;
    }
  }
}

/// Stream provider for device registration events from WebSocket.
@riverpod
Stream<SocketMessage> deviceWebSocketEvents(DeviceWebSocketEventsRef ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.messages.where((message) {
    final type = message.type.toLowerCase();
    return type.contains('access_point') ||
        type.contains('media_converter') ||
        type.contains('ont') ||
        type.contains('switch') ||
        type.contains('device');
  });
}
