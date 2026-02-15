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
  /// Returns a list of matching devices from all device types.
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

    final results = <Map<String, dynamic>>[];
    final resourceTypes = ['access_points', 'media_converters', 'switch_devices'];

    for (final resourceType in resourceTypes) {
      // Query by MAC if provided - format for backend (lowercase with colons)
      if (mac != null && mac.isNotEmpty) {
        final formattedMac = _formatMacForBackend(mac);
        LoggerService.debug(
          'DeviceRegistration: Querying $resourceType with formatted MAC: $formattedMac (original: $mac)',
          tag: 'DeviceRegistration',
        );
        final byMac = await _queryResource(wsService, resourceType, {'mac': formattedMac});
        results.addAll(byMac);
      }

      // Query by serial if provided
      if (serial != null && serial.isNotEmpty) {
        final bySerial = await _queryResource(wsService, resourceType, {'serial_number': serial});
        // Avoid duplicates if already found by MAC
        for (final device in bySerial) {
          final deviceId = device['id'];
          if (!results.any((d) => d['id'] == deviceId)) {
            results.add(device);
          }
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
  /// Queries the backend via WebSocket to find existing devices.
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

      LoggerService.debug(
        'DeviceRegistration: Querying backend for MAC=$normalizedMac, Serial=$normalizedSerial',
        tag: 'DeviceRegistration',
      );

      // Query the backend for devices matching MAC or serial
      final matchingDevices = await _queryDevicesFromBackend(
        mac: normalizedMac,
        serial: normalizedSerial,
      );

      LoggerService.debug(
        'DeviceRegistration: Found ${matchingDevices.length} matching devices',
        tag: 'DeviceRegistration',
      );

      if (matchingDevices.isEmpty) {
        // No existing device found
        state = state.copyWith(
          status: RegistrationStatus.idle,
          matchStatus: DeviceMatchStatus.noMatch,
        );
        return;
      }

      // Find devices that match by MAC and/or serial
      Map<String, dynamic>? deviceByMac;
      Map<String, dynamic>? deviceBySerial;

      for (final device in matchingDevices) {
        final rawMac = (device['mac'] ?? device['mac_address'] ?? '').toString();
        final devMac = _normalizeMac(rawMac);
        final rawSerial = (device['serial_number'] ?? device['sn'] ?? '').toString();
        final devSerial = rawSerial.toUpperCase().trim();

        LoggerService.debug(
          'DeviceRegistration: Checking device ${device['id']} - '
          'rawMac="$rawMac" normalizedMac="$devMac" vs scannedMac="$normalizedMac" | '
          'rawSerial="$rawSerial" normalizedSerial="$devSerial" vs scannedSerial="$normalizedSerial"',
          tag: 'DeviceRegistration',
        );

        // Compare normalized values - if scanned value is empty, don't set match
        if (normalizedMac.isNotEmpty && devMac.isNotEmpty && devMac == normalizedMac) {
          LoggerService.debug('DeviceRegistration: MAC match found!', tag: 'DeviceRegistration');
          deviceByMac = device;
        }
        if (normalizedSerial.isNotEmpty && devSerial.isNotEmpty && devSerial == normalizedSerial) {
          LoggerService.debug('DeviceRegistration: Serial match found!', tag: 'DeviceRegistration');
          deviceBySerial = device;
        }
      }

      LoggerService.debug(
        'DeviceRegistration: After matching - deviceByMac=${deviceByMac != null ? "found(${deviceByMac['id']})" : "null"}, '
        'deviceBySerial=${deviceBySerial != null ? "found(${deviceBySerial['id']})" : "null"}',
        tag: 'DeviceRegistration',
      );

      // If we found any device, it's a match - don't be strict about both fields
      // The backend found the device by MAC or serial, so it exists
      if (matchingDevices.isNotEmpty) {
        final existingDevice = matchingDevices.first;
        final existingMac = _normalizeMac(
          (existingDevice['mac'] ?? existingDevice['mac_address'] ?? '').toString(),
        );
        final existingSerial = (existingDevice['serial_number'] ?? existingDevice['sn'] ?? '')
            .toString()
            .toUpperCase()
            .trim();

        // Check if BOTH fields were scanned AND the device has BOTH fields AND they DIFFER
        // This is the only true mismatch case
        final hasMacMismatch = normalizedMac.isNotEmpty &&
            existingMac.isNotEmpty &&
            normalizedMac != existingMac;
        final hasSerialMismatch = normalizedSerial.isNotEmpty &&
            existingSerial.isNotEmpty &&
            normalizedSerial != existingSerial;

        LoggerService.debug(
          'DeviceRegistration: Mismatch check - hasMacMismatch=$hasMacMismatch, hasSerialMismatch=$hasSerialMismatch',
          tag: 'DeviceRegistration',
        );

        // Only flag as mismatch if we have conflicting data
        // (e.g., scanned MAC matches device A, but scanned serial matches device B)
        if (deviceByMac != null && deviceBySerial != null && deviceByMac['id'] != deviceBySerial['id']) {
          LoggerService.debug(
            'DeviceRegistration: Multiple devices match - MAC matches ${deviceByMac['id']}, serial matches ${deviceBySerial['id']}',
            tag: 'DeviceRegistration',
          );
          state = state.copyWith(
            status: RegistrationStatus.idle,
            matchStatus: DeviceMatchStatus.multipleMatch,
            errorMessage: 'MAC and serial match different devices',
          );
          return;
        }

        // If we found a device by one field, but the OTHER scanned field doesn't match
        // that device's stored value, it's a true mismatch
        if ((deviceByMac != null && hasSerialMismatch) || (deviceBySerial != null && hasMacMismatch)) {
          final mismatches = <String>[];
          if (hasMacMismatch) mismatches.add('MAC Address');
          if (hasSerialMismatch) mismatches.add('Serial Number');

          LoggerService.debug(
            'DeviceRegistration: Data mismatch detected - $mismatches',
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

        // Device found - this is a full match (existing device)
        final roomId = _extractRoomId(existingDevice);
        final roomName = _extractRoomName(existingDevice);

        LoggerService.debug(
          'DeviceRegistration: Full match - device ${existingDevice['id']} in room $roomName',
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
        return;
      }

      // No devices found at all
      LoggerService.debug('DeviceRegistration: No matching devices found', tag: 'DeviceRegistration');
      state = state.copyWith(
        status: RegistrationStatus.idle,
        matchStatus: DeviceMatchStatus.noMatch,
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

      // Get the registration service and register via WebSocket
      final registrationService = ref.read(deviceRegistrationServiceProvider);

      // Check if WebSocket is connected before attempting registration
      if (!registrationService.isConnected) {
        const error = 'Cannot register device: WebSocket not connected';
        state = state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: error,
        );
        return RegistrationResult.failure(message: error);
      }

      final sent = registrationService.registerDevice(
        deviceType: deviceType,
        mac: mac,
        serialNumber: serial,
        pmsRoomId: pmsRoomId,
        partNumber: partNumber,
        model: model,
        existingDeviceId: existingDeviceId,
      );

      if (!sent) {
        const error = 'Failed to send registration message';
        state = state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: error,
        );
        return RegistrationResult.failure(message: error);
      }

      LoggerService.info(
        'DeviceRegistration: Sent registration via WebSocket - $deviceType MAC=$mac, SN=$serial, Room=$pmsRoomId',
        tag: 'DeviceRegistration',
      );

      // WebSocket registration is fire-and-forget
      // The device.created event will be received via the WebSocket listener
      // Mark as pending until we receive confirmation
      state = state.copyWith(
        status: RegistrationStatus.success,
        registeredAt: DateTime.now(),
      );

      return RegistrationResult.success(
        deviceId: existingDeviceId ?? 0,
        deviceType: deviceType.name,
      );
    } catch (e, stack) {
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
