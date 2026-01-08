import 'dart:async';

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

  // Dual-index cache for O(1) device lookup (like AT&T app)
  final Map<String, Map<String, dynamic>> _deviceIndexByMac = {};
  final Map<String, Map<String, dynamic>> _deviceIndexBySerial = {};
  bool _indexesDirty = true;

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

      // Mark indexes as dirty to trigger rebuild on next lookup
      _indexesDirty = true;

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

    _indexesDirty = false;
    LoggerService.debug(
      'DeviceRegistration: Rebuilt indexes from snapshot (${items.length} devices)',
      tag: 'DeviceRegistration',
    );
  }

  String _normalizeMac(String mac) {
    // Remove separators and convert to uppercase
    return mac.replaceAll(RegExp('[^0-9A-Fa-f]'), '').toUpperCase();
  }

  /// Check if a device already exists with the given MAC and serial.
  /// Returns match status and any mismatches found.
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

      // Look up in both indexes
      final byMac = _deviceIndexByMac[normalizedMac];
      final bySerial = _deviceIndexBySerial[normalizedSerial];

      // Determine match status
      if (byMac == null && bySerial == null) {
        // No existing device found
        state = state.copyWith(
          status: RegistrationStatus.idle,
          matchStatus: DeviceMatchStatus.noMatch,
        );
        return;
      }

      // Check for full match (same device found by both MAC and serial)
      if (byMac != null && bySerial != null) {
        if (byMac['id'] == bySerial['id']) {
          // Full match - same device
          state = state.copyWith(
            status: RegistrationStatus.idle,
            matchStatus: DeviceMatchStatus.fullMatch,
            matchedDeviceId: byMac['id'] as int?,
            matchedDeviceName: byMac['name'] as String?,
          );
          return;
        } else {
          // Multiple different devices match
          state = state.copyWith(
            status: RegistrationStatus.idle,
            matchStatus: DeviceMatchStatus.multipleMatch,
            errorMessage:
                'MAC and serial match different devices',
          );
          return;
        }
      }

      // One index has a match, check for mismatch
      final existingDevice = byMac ?? bySerial;
      final existingMac =
          _normalizeMac((existingDevice?['mac'] ?? existingDevice?['mac_address'] ?? '').toString());
      final existingSerial =
          (existingDevice?['serial_number'] ?? existingDevice?['sn'] ?? '')
              .toString()
              .toUpperCase();

      final mismatches = <String>[];
      if (byMac != null && existingSerial != normalizedSerial) {
        mismatches.add('Serial Number');
      }
      if (bySerial != null && existingMac != normalizedMac) {
        mismatches.add('MAC Address');
      }

      if (mismatches.isNotEmpty) {
        state = state.copyWith(
          status: RegistrationStatus.idle,
          matchStatus: DeviceMatchStatus.mismatch,
          matchedDeviceId: existingDevice?['id'] as int?,
          matchedDeviceName: existingDevice?['name'] as String?,
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

      // Shouldn't reach here, but default to no match
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
      // Validate serial pattern
      final detectedType = SerialPatterns.detectDeviceType(serial);
      if (detectedType == null) {
        final error = 'Invalid serial number format for ${deviceType.displayName}';
        state = state.copyWith(
          status: RegistrationStatus.error,
          errorMessage: error,
        );
        return RegistrationResult.failure(message: error);
      }

      // Get the registration service and register via WebSocket
      final registrationService = ref.read(deviceRegistrationServiceProvider);

      registrationService.registerDevice(
        deviceType: deviceType,
        mac: mac,
        serialNumber: serial,
        pmsRoomId: pmsRoomId,
        partNumber: partNumber,
        model: model,
        existingDeviceId: existingDeviceId,
      );

      LoggerService.info(
        'DeviceRegistration: Sent registration via WebSocket - $deviceType MAC=$mac, SN=$serial, Room=$pmsRoomId',
        tag: 'DeviceRegistration',
      );

      // WebSocket registration is fire-and-forget
      // The device.created event will be received via the WebSocket listener
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
    _indexesDirty = true;
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
