import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/secure_http_client.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/utils/log_redaction.dart' as log_redaction;
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';

/// Outcome of a device-registration round-trip with the backend.
///
/// `success` is the rXg's authoritative verdict, not just whether the
/// WebSocket frame was sent.
class RegistrationServiceOutcome {
  const RegistrationServiceOutcome.success({
    this.data,
    this.status = 200,
  })  : success = true,
        errorMessage = null;

  const RegistrationServiceOutcome.failure({
    required this.errorMessage,
    required this.status,
  })  : success = false,
        data = null;

  final bool success;
  final String? errorMessage;
  final int status;
  final Map<String, dynamic>? data;
}

/// Service for registering devices.
///
/// Access Points register over REST (`POST /api/access_points/
/// register_ap_device`); ONTs and switches register over WebSocket. The AP
/// path was moved off WebSocket because the rXg's controller-side work can
/// outlive AnyCable's gRPC deadline, leaving the client without an
/// authoritative reply.
class DeviceRegistrationService {
  DeviceRegistrationService({
    required WebSocketService webSocketService,
    http.Client? httpClient,
  })  : _wsService = webSocketService,
        _httpClient = httpClient;

  static const String _tag = 'DeviceRegistration';

  final WebSocketService _wsService;
  final http.Client? _httpClient;

  /// Lazily falls back to the shared cert-validating client so self-signed
  /// rXg certificates are accepted in debug builds.
  http.Client get _client => _httpClient ?? SecureHttpClient.getClient();

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
    String? siteUrl,
    String? apiKey,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    // Access Points register over REST, not WebSocket.
    if (deviceType == DeviceType.accessPoint) {
      return _registerApViaRest(
        mac: mac,
        serialNumber: serialNumber,
        pmsRoomId: pmsRoomId,
        existingDeviceId: existingDeviceId,
        siteUrl: siteUrl,
        apiKey: apiKey,
        timeout: timeout,
      );
    }

    if (!_wsService.isConnected) {
      LoggerService.error(
        'Cannot register device: WebSocket not connected',
        tag: _tag,
      );
      return const RegistrationServiceOutcome.failure(
        errorMessage: 'WebSocket not connected',
        status: 0,
      );
    }

    LoggerService.info(
      'Registering ${deviceType.displayName} via WebSocket',
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

    try {
      final response = await _wsService.requestActionCable(
        action: 'resource_action',
        resourceType: payload.resourceType,
        additionalData: payload.additionalData,
        timeout: timeout,
      );
      return _parseResponse(response);
    } on TimeoutException {
      LoggerService.warning(
        'Registration timed out waiting for backend response',
        tag: _tag,
      );
      return const RegistrationServiceOutcome.failure(
        errorMessage: 'Timed out waiting for backend',
        status: 0,
      );
    } on Object catch (e, stack) {
      LoggerService.error(
        'Registration failed before receiving backend response: $e',
        tag: _tag,
        error: e,
        stackTrace: stack,
      );
      return RegistrationServiceOutcome.failure(
        errorMessage: e.toString(),
        status: 0,
      );
    }
  }

  /// Registers an Access Point via the rXg's `register_ap_device` REST
  /// collection action. Returns the rXg's authoritative verdict.
  ///
  /// The endpoint mirrors the WebSocket `register_ap_device` crud action:
  /// it associates the scanned MAC/serial with a PMS room, creating a new AP
  /// or updating the existing one identified by [existingDeviceId].
  Future<RegistrationServiceOutcome> _registerApViaRest({
    required String mac,
    required String serialNumber,
    required int pmsRoomId,
    required Duration timeout,
    int? existingDeviceId,
    String? siteUrl,
    String? apiKey,
  }) async {
    if (siteUrl == null || siteUrl.isEmpty || apiKey == null || apiKey.isEmpty) {
      LoggerService.error(
        'Cannot register AP via REST: missing site URL or API key',
        tag: _tag,
      );
      return const RegistrationServiceOutcome.failure(
        errorMessage: 'Not signed in',
        status: 0,
      );
    }

    final uri = Uri.parse(
      'https://${_normalizeSiteUrl(siteUrl)}'
      '/api/access_points/register_ap_device.json?api_key=$apiKey',
    );
    final body = <String, dynamic>{
      'serial_number': serialNumber,
      'mac': mac,
      'pms_room_id': pmsRoomId,
      if (existingDeviceId != null) 'ap_id': existingDeviceId,
    };

    LoggerService.info(
      'Registering AccessPoint via REST POST '
      '${log_redaction.scrubUrlForLog(uri)}',
      tag: _tag,
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
      return _parseRestResponse(response);
    } on TimeoutException {
      LoggerService.warning(
        'AP REST registration timed out waiting for backend response',
        tag: _tag,
      );
      return const RegistrationServiceOutcome.failure(
        errorMessage: 'Timed out waiting for backend',
        status: 0,
      );
    } on Object catch (e) {
      // ClientException / TimeoutException can embed the full URL (with
      // api_key); scrub before logging and never pass the raw object.
      final scrubbed = log_redaction.scrubErrorForLog(e);
      LoggerService.error(
        'AP REST registration failed: $scrubbed',
        tag: _tag,
      );
      return RegistrationServiceOutcome.failure(
        errorMessage: scrubbed,
        status: 0,
      );
    }
  }

  /// Parses the rXg's `register_ap_device` REST response. The controller
  /// renders the `api:` hash directly as the JSON body (e.g.
  /// `{"message": "...", "access_point": {...}}`) with the HTTP status
  /// carrying the verdict — 200/201 on success, 4xx on failure.
  RegistrationServiceOutcome _parseRestResponse(http.Response response) {
    final status = response.statusCode;
    Map<String, dynamic>? body;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } on FormatException {
        body = null;
      }
    }

    if (status >= 200 && status < 300) {
      return RegistrationServiceOutcome.success(data: body, status: status);
    }

    final message = body?['message'];
    return RegistrationServiceOutcome.failure(
      errorMessage: message is String && message.isNotEmpty
          ? message
          : 'Registration failed (status $status)',
      status: status,
    );
  }

  /// Strips scheme and trailing slash so a stored `siteUrl` (which may be a
  /// bare host or a full `https://host/`) yields a clean authority.
  static String _normalizeSiteUrl(String url) {
    var normalized = url;
    if (normalized.startsWith('https://')) {
      normalized = normalized.substring(8);
    } else if (normalized.startsWith('http://')) {
      normalized = normalized.substring(7);
    }
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
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
      final errMsg = _extractErrorMessage(payload) ??
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
        // Access Points register over REST via _registerApViaRest and never
        // reach this WebSocket payload builder.
        throw ArgumentError('Access Points register over REST, not WebSocket');

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
