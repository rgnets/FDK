import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';

/// Service for registering devices via WebSocket ActionCable channel.
class DeviceRegistrationService {
  DeviceRegistrationService({required WebSocketService webSocketService})
      : _wsService = webSocketService;

  static const String _tag = 'DeviceRegistration';
  static const Duration _registrationTimeout = Duration(seconds: 10);

  final WebSocketService _wsService;

  /// Check if WebSocket is connected.
  bool get isConnected => _wsService.isConnected;

  /// Register a device via the RxgChannel ActionCable channel.
  ///
  /// Uses 'create_resource' for new devices or 'update_resource' for existing
  /// ones, with device fields nested under 'params' per the RxgChannel API.
  ///
  /// Throws [StateError] if WebSocket is not connected.
  /// Throws [TimeoutException] if the server does not confirm within 10s.
  Future<SocketMessage> registerDevice({
    required DeviceType deviceType,
    required String mac,
    required String serialNumber,
    required int pmsRoomId,
    String? partNumber,
    String? model,
    int? existingDeviceId,
  }) {
    final resourceType = _deviceTypeToResourceType(deviceType);
    final isUpdate = existingDeviceId != null;
    final action = isUpdate ? 'update_resource' : 'create_resource';

    LoggerService.info(
      'Registering ${deviceType.displayName} via ActionCable '
      '($action on $resourceType, existingId=$existingDeviceId)',
      tag: _tag,
    );

    return _wsService.requestActionCable(
      action: action,
      resourceType: resourceType,
      additionalData: {
        if (isUpdate) 'id': existingDeviceId,
        'params': {
          'mac': mac,
          'serial_number': serialNumber,
          'pms_room_id': pmsRoomId,
          if (partNumber != null) 'part_number': partNumber,
          if (model != null) 'model': model,
        },
      },
      timeout: _registrationTimeout,
    );
  }

  /// Maps DeviceType to the Rails resource type name.
  String _deviceTypeToResourceType(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.ont:
        return 'media_converters';
      case DeviceType.accessPoint:
        return 'access_points';
      case DeviceType.switchDevice:
        return 'switch_devices';
    }
  }
}
