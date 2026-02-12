import 'dart:convert';

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
  /// Sends an ActionCable-formatted resource_action through RxgChannel.
  ///
  /// For access points, uses the dedicated `register_ap_device` extra action.
  /// For ONTs and switches, uses generic CRUD create/update.
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

    LoggerService.info(
      'Registering ${deviceType.displayName} via WebSocket',
      tag: _tag,
    );

    final channelIdentifier = jsonEncode(const {'channel': 'RxgChannel'});

    final data = _buildActionCableData(
      deviceType: deviceType,
      mac: mac,
      serialNumber: serialNumber,
      pmsRoomId: pmsRoomId,
      partNumber: partNumber,
      model: model,
      existingDeviceId: existingDeviceId,
    );

    _wsService.send({
      'command': 'message',
      'identifier': channelIdentifier,
      'data': jsonEncode(data),
    });
    return true;
  }

  Map<String, dynamic> _buildActionCableData({
    required DeviceType deviceType,
    required String mac,
    required String serialNumber,
    required int pmsRoomId,
    String? partNumber,
    String? model,
    int? existingDeviceId,
  }) {
    switch (deviceType) {
      case DeviceType.accessPoint:
        // Use the dedicated register_ap_device extra collection action
        return {
          'action': 'resource_action',
          'resource_type': 'access_points',
          'crud_action': 'register_ap_device',
          'mac': mac,
          'serial_number': serialNumber,
          'pms_room_id': pmsRoomId,
          if (existingDeviceId != null) 'ap_id': existingDeviceId,
        };

      case DeviceType.ont:
        // Use generic CRUD create/update for media_converters
        return {
          'action': 'resource_action',
          'resource_type': 'media_converters',
          'crud_action': existingDeviceId != null ? 'update' : 'create',
          'mac': mac,
          'serial_number': serialNumber,
          'pms_room_id': pmsRoomId,
          if (partNumber != null) 'part_number': partNumber,
          if (existingDeviceId != null) 'id': existingDeviceId,
        };

      case DeviceType.switchDevice:
        // Use generic CRUD create/update for switch_devices
        return {
          'action': 'resource_action',
          'resource_type': 'switch_devices',
          'crud_action': existingDeviceId != null ? 'update' : 'create',
          'mac': mac,
          'serial_number': serialNumber,
          'pms_room_id': pmsRoomId,
          if (model != null) 'model': model,
          if (existingDeviceId != null) 'id': existingDeviceId,
        };
    }
  }
}
