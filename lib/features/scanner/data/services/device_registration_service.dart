import 'dart:async';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/utils/log_redaction.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';

/// Outcome of a device-registration round-trip with the backend.
///
/// `success` is the rXg's authoritative verdict, not just whether the
/// WebSocket frame was sent.
class RegistrationServiceOutcome {
  const RegistrationServiceOutcome.success({this.data, this.status = 200})
    : success = true,
      errorMessage = null;

  const RegistrationServiceOutcome.failure({
    required this.errorMessage,
    required this.status,
  }) : success = false,
       data = null;

  final bool success;
  final String? errorMessage;
  final int status;
  final Map<String, dynamic>? data;
}

/// Service for registering devices via WebSocket.
class DeviceRegistrationService {
  DeviceRegistrationService({required WebSocketService webSocketService})
    : _wsService = webSocketService;

  static const String _tag = 'DeviceRegistration';

  final WebSocketService _wsService;

  /// Check if WebSocket is connected.
  bool get isConnected => _wsService.isConnected;

  /// Register a device via WebSocket and await the backend's response.
  ///
  /// Uses [WebSocketService.requestActionCable] so the rXg's reply is
  /// correlated by `request_id` and the caller learns the actual outcome
  /// instead of just whether the frame left the device.
  Future<RegistrationServiceOutcome> registerDevice({
    required DeviceType deviceType,
    required String mac,
    required String serialNumber,
    required int pmsRoomId,
    String? partNumber,
    String? model,
    int? existingDeviceId,
    Duration timeout = const Duration(seconds: 30),
    String? attemptId,
  }) async {
    attemptId ??=
        'reg-${deviceType.name}-${DateTime.now().millisecondsSinceEpoch}';
    if (!_wsService.isConnected) {
      LoggerService.error(
        'Cannot register device: WebSocket not connected '
        '(attempt_id=$attemptId, device_type=${deviceType.name})',
        tag: _tag,
      );
      return const RegistrationServiceOutcome.failure(
        errorMessage: 'WebSocket not connected',
        status: 0,
      );
    }

    LoggerService.info(
      '[REGISTRATION_FLOW] Starting ${deviceType.displayName} registration '
      '(attempt_id=$attemptId)',
      tag: _tag,
    );

    final payload = _buildExtraActionPayload(
      deviceType: deviceType,
      mac: mac,
      serialNumber: serialNumber,
      pmsRoomId: pmsRoomId,
      partNumber: partNumber,
      model: model,
      existingDeviceId: existingDeviceId,
    );
    final actionData = {
      'action': 'resource_action',
      'resource_type': payload.resourceType,
      'request_id': attemptId,
      ...payload.additionalData,
    };
    final endpoint =
        'ActionCable RxgChannel/resource_action/${payload.resourceType}';

    _debugRegistration('attempt', {
      'attempt_id': attemptId,
      'device_type': deviceType.name,
      'device_display_name': deviceType.displayName,
      'identifiers': {
        'mac': mac,
        'serial_number': serialNumber,
        if (partNumber != null) 'part_number': partNumber,
        if (model != null) 'model': model,
        if (existingDeviceId != null) 'existing_device_id': existingDeviceId,
        'pms_room_id': pmsRoomId,
      },
    });
    _debugRegistration('request', {
      'attempt_id': attemptId,
      'endpoint': endpoint,
      'payload': actionData,
    });

    try {
      final response = await _wsService.requestActionCable(
        action: 'resource_action',
        resourceType: payload.resourceType,
        additionalData: payload.additionalData,
        timeout: timeout,
        requestId: attemptId,
      );
      _debugRegistration('response', {
        'attempt_id': attemptId,
        'status': (response.payload['status'] as num?)?.toInt(),
        'body': response.raw ?? response.payload,
      });

      final outcome = _parseResponse(response);
      if (outcome.success) {
        LoggerService.info(
          '[REGISTRATION_FLOW] Registration confirmed '
          '(attempt_id=$attemptId, device_type=${deviceType.name}, '
          'status=${outcome.status})',
          tag: _tag,
        );
        _debugRegistration('success', {
          'attempt_id': attemptId,
          'device_type': deviceType.name,
          'status': outcome.status,
          if (outcome.data != null) 'data': outcome.data,
        });
      } else {
        LoggerService.warning(
          '[REGISTRATION_FLOW] Registration failed '
          '(attempt_id=$attemptId, device_type=${deviceType.name}, '
          'status=${outcome.status}, reason=${outcome.errorMessage})',
          tag: _tag,
        );
        _debugRegistration('failure', {
          'attempt_id': attemptId,
          'device_type': deviceType.name,
          'status': outcome.status,
          'reason': outcome.errorMessage,
        });
      }
      return outcome;
    } on TimeoutException {
      LoggerService.warning(
        '[REGISTRATION_FLOW] Registration timed out waiting for backend '
        '(attempt_id=$attemptId, device_type=${deviceType.name})',
        tag: _tag,
      );
      _debugRegistration('failure', {
        'attempt_id': attemptId,
        'device_type': deviceType.name,
        'status': 0,
        'reason': 'Timed out waiting for backend',
        'endpoint': endpoint,
        'payload': actionData,
      });
      return const RegistrationServiceOutcome.failure(
        errorMessage: 'Timed out waiting for backend',
        status: 0,
      );
    } on Object catch (e, stack) {
      LoggerService.error(
        '[REGISTRATION_FLOW] Registration failed before backend response: '
        '${scrubErrorForLog(e)} (attempt_id=$attemptId, '
        'device_type=${deviceType.name})',
        tag: _tag,
        error: scrubErrorForLog(e),
        stackTrace: stack,
      );
      _debugRegistration('failure', {
        'attempt_id': attemptId,
        'device_type': deviceType.name,
        'status': 0,
        'reason': scrubErrorForLog(e),
        'endpoint': endpoint,
        'payload': actionData,
      });
      return RegistrationServiceOutcome.failure(
        errorMessage: scrubErrorForLog(e),
        status: 0,
      );
    }
  }

  /// Parses a [SocketMessage] returned by `requestActionCable` for a
  /// registration into a [RegistrationServiceOutcome].
  ///
  /// Treats `action == 'error'` or any `status >= 400` as failure.
  /// Error text is picked up from `payload.error` first, then from
  /// `payload.data.message` (the rXg's controller-side `render
  /// api: {message: "..."}, status: :not_found` shape, which
  /// `RxgWebsocketCrudService.extract_controller_response` serializes
  /// under `:data` rather than `:error`).
  RegistrationServiceOutcome _parseResponse(SocketMessage response) {
    final payload = response.payload;
    final status = (payload['status'] as num?)?.toInt() ?? 0;
    final isError = response.type == 'error' || status >= 400;

    if (isError) {
      final errMsg =
          _extractErrorMessage(payload) ??
          'Registration failed (status $status)';
      return RegistrationServiceOutcome.failure(
        errorMessage: errMsg,
        status: status,
      );
    }

    final data = payload['data'];
    return RegistrationServiceOutcome.success(
      data: data is Map<String, dynamic> ? data : null,
      status: status > 0 ? status : 200,
    );
  }

  String? _extractErrorMessage(Map<String, dynamic> payload) {
    final rawError = payload['error'];
    if (rawError is String && rawError.isNotEmpty) {
      return rawError;
    }

    final data = payload['data'];
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }
    return null;
  }

  void _debugRegistration(String phase, Map<String, dynamic> details) {
    if (!LoggerService.isVerboseLoggingEnabled) {
      return;
    }
    LoggerService.debug(
      '[REGISTRATION_FLOW:$phase] ${formatForLog(details)}',
      tag: _tag,
    );
  }

  /// Builds the ActionCable inner-data payload for one device-type, minus
  /// the fields that `WebSocketService.requestActionCable` adds itself
  /// (`action`, `resource_type`, `request_id`).
  ({String resourceType, Map<String, dynamic> additionalData})
  _buildExtraActionPayload({
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
        return (
          resourceType: 'access_points',
          additionalData: {
            'crud_action': 'register_ap_device',
            'mac': mac,
            'serial_number': serialNumber,
            'pms_room_id': pmsRoomId,
            if (existingDeviceId != null) 'ap_id': existingDeviceId,
          },
        );

      case DeviceType.ont:
        // The dedicated register_ont_device extra collection action
        // associates the ONT with the OLT, sets approved=true, port_type=xgs.
        return (
          resourceType: 'media_converters',
          additionalData: {
            'crud_action': 'register_ont_device',
            'mac': mac,
            'serial_number': serialNumber,
            'pms_room_id': pmsRoomId,
            if (partNumber != null) 'part_number': partNumber,
            if (existingDeviceId != null) 'ont_id': existingDeviceId,
          },
        );

      case DeviceType.switchDevice:
        // Uses the dedicated register_switch_device extra collection action.
        // The switch must already be pre-configured by an administrator on
        // the rXg (with host, credentials, management VLAN, etc.); this call
        // assigns the scanned MAC and the room.
        return (
          resourceType: 'switch_devices',
          additionalData: {
            'crud_action': 'register_switch_device',
            'mac': mac,
            'serial_number': serialNumber,
            'pms_room_id': pmsRoomId,
            if (existingDeviceId != null) 'switch_device_id': existingDeviceId,
          },
        );
    }
  }
}
