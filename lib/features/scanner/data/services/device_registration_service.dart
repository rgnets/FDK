import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';

/// Service for registering devices via WebSocket.
class DeviceRegistrationService {
  DeviceRegistrationService({required WebSocketService webSocketService})
      : _wsService = webSocketService;

  static const String _tag = 'DeviceRegistration';

  final WebSocketService _wsService;

  /// Check if WebSocket is connected.
  bool get isConnected => _wsService.isConnected;

  /// Register a device via WebSocket.
  /// Sends a 'device.register' message with device data.
  /// Returns true if message was sent, false if WebSocket not connected.
  bool registerDevice({
    required DeviceType deviceType,
    required String mac,
    required String serialNumber,
    required int pmsRoomId,
    String? partNumber,
    String? model,
    int? existingDeviceId,
  }) {
    if (!_wsService.isConnected) {
      LoggerService.error(
        'Cannot register device: WebSocket not connected',
        tag: _tag,
      );
      return false;
    }

    final payload = _buildPayload(
      deviceType: deviceType,
      mac: mac,
      serialNumber: serialNumber,
      pmsRoomId: pmsRoomId,
      partNumber: partNumber,
      model: model,
      existingDeviceId: existingDeviceId,
    );

    LoggerService.info(
      'Registering ${deviceType.displayName} via WebSocket',
      tag: _tag,
    );

    _wsService.sendType('device.register', payload: payload);
    return true;
  }

  Map<String, dynamic> _buildPayload({
    required DeviceType deviceType,
    required String mac,
    required String serialNumber,
    required int pmsRoomId,
    String? partNumber,
    String? model,
    int? existingDeviceId,
  }) {
    switch (deviceType) {
      case DeviceType.ont:
        return {
          'device_type': 'ont',
          'mac': mac,
          'serial_number': serialNumber,
          'pms_room_id': pmsRoomId,
          if (partNumber != null) 'part_number': partNumber,
          if (existingDeviceId != null) 'id': existingDeviceId,
        };

      case DeviceType.accessPoint:
        return {
          'device_type': 'access_point',
          'mac': mac,
          'serial_number': serialNumber,
          'pms_room_id': pmsRoomId,
          if (existingDeviceId != null) 'id': existingDeviceId,
        };

      case DeviceType.switchDevice:
        return {
          'device_type': 'switch',
          'mac': mac,
          'serial_number': serialNumber,
          'pms_room_id': pmsRoomId,
          if (model != null) 'model': model,
          if (existingDeviceId != null) 'id': existingDeviceId,
        };
    }
  }
}
