import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';

part 'websocket_events.freezed.dart';

/// Device-related WebSocket events
@freezed
sealed class DeviceEvent with _$DeviceEvent {
  /// A new device was created/discovered
  const factory DeviceEvent.created(Device device) = DeviceCreated;

  /// An existing device was updated (full update)
  const factory DeviceEvent.updated(Device device) = DeviceUpdated;

  /// A device was deleted/removed
  const factory DeviceEvent.deleted(String id) = DeviceDeleted;

  /// Only the device status changed (lightweight update)
  const factory DeviceEvent.statusChanged({
    required String id,
    required String status,
    bool? online,
    DateTime? lastSeen,
  }) = DeviceStatusChanged;

  /// Batch update of multiple devices
  const factory DeviceEvent.batchUpdate(List<Device> devices) =
      DeviceBatchUpdate;

  /// Snapshot/initial sync of all devices
  const factory DeviceEvent.snapshot(List<Device> devices) = DeviceSnapshot;
}

/// Room-related WebSocket events
@freezed
sealed class RoomEvent with _$RoomEvent {
  /// A new room was created
  const factory RoomEvent.created(Room room) = RoomCreated;

  /// An existing room was updated
  const factory RoomEvent.updated(Room room) = RoomUpdated;

  /// A room was deleted
  const factory RoomEvent.deleted(String id) = RoomDeleted;

  /// Batch update of multiple rooms
  const factory RoomEvent.batchUpdate(List<Room> rooms) = RoomBatchUpdate;

  /// Snapshot/initial sync of all rooms
  const factory RoomEvent.snapshot(List<Room> rooms) = RoomSnapshot;
}

/// Notification-related WebSocket events
@freezed
sealed class NotificationEvent with _$NotificationEvent {
  /// A new notification arrived
  const factory NotificationEvent.received({
    required String id,
    required String title,
    required String message,
    required String type,
    required String priority,
    String? deviceId,
    String? location,
    Map<String, dynamic>? metadata,
  }) = NotificationReceived;

  /// A notification was marked as read
  const factory NotificationEvent.read(String id) = NotificationRead;

  /// All notifications were cleared
  const factory NotificationEvent.cleared() = NotificationCleared;
}

/// Sync-related WebSocket events (for initial data loading)
@freezed
sealed class SyncEvent with _$SyncEvent {
  /// Sync started
  const factory SyncEvent.started() = SyncStarted;

  /// Sync completed successfully
  const factory SyncEvent.completed({
    required int deviceCount,
    required int roomCount,
  }) = SyncCompleted;

  /// Sync failed
  const factory SyncEvent.failed(String error) = SyncFailed;

  /// Incremental sync (delta update)
  const factory SyncEvent.delta({
    List<Device>? updatedDevices,
    List<Room>? updatedRooms,
    List<String>? deletedDeviceIds,
    List<String>? deletedRoomIds,
  }) = SyncDelta;
}

/// Connection-related events
@freezed
sealed class ConnectionEvent with _$ConnectionEvent {
  /// Successfully connected
  const factory ConnectionEvent.connected() = ConnectionConnected;

  /// Disconnected (with optional reason)
  const factory ConnectionEvent.disconnected({String? reason}) =
      ConnectionDisconnected;

  /// Reconnecting (with attempt count)
  const factory ConnectionEvent.reconnecting(int attempt) =
      ConnectionReconnecting;

  /// Connection error
  const factory ConnectionEvent.error(String message, StackTrace? stackTrace) =
      ConnectionError;
}

/// Top-level WebSocket event union
/// This is what the MessageRouter emits after parsing raw messages
@freezed
sealed class WebSocketEvent with _$WebSocketEvent {
  /// Device-related event
  const factory WebSocketEvent.device(DeviceEvent event) = DeviceWebSocketEvent;

  /// Room-related event
  const factory WebSocketEvent.room(RoomEvent event) = RoomWebSocketEvent;

  /// Notification-related event
  const factory WebSocketEvent.notification(NotificationEvent event) =
      NotificationWebSocketEvent;

  /// Sync-related event
  const factory WebSocketEvent.sync(SyncEvent event) = SyncWebSocketEvent;

  /// Connection-related event
  const factory WebSocketEvent.connection(ConnectionEvent event) =
      ConnectionWebSocketEvent;

  /// Unknown/unhandled message type (for debugging)
  const factory WebSocketEvent.unknown({
    required String type,
    required Map<String, dynamic> payload,
  }) = UnknownWebSocketEvent;
}

/// ActionCable/AnyCable envelope type for raw inbound WebSocket frames.
enum WebSocketEnvelopeType {
  welcome,
  ping,
  confirmSubscription,
  rejectSubscription,
  disconnect,
  data,
  unknown,
}

extension WebSocketEnvelopeTypeX on WebSocketEnvelopeType {
  String get logName => switch (this) {
    WebSocketEnvelopeType.welcome => 'welcome',
    WebSocketEnvelopeType.ping => 'ping',
    WebSocketEnvelopeType.confirmSubscription => 'confirm_subscription',
    WebSocketEnvelopeType.rejectSubscription => 'reject_subscription',
    WebSocketEnvelopeType.disconnect => 'disconnect',
    WebSocketEnvelopeType.data => 'data',
    WebSocketEnvelopeType.unknown => 'unknown',
  };
}

/// Structured breakdown of a raw ActionCable/AnyCable inbound frame.
///
/// This preserves the envelope fields (`type`, `identifier`) separately from
/// the useful inner `message` payload so debug logs can show exactly what the
/// server sent without changing the existing [SocketMessage]-style dispatch.
class WebSocketEnvelopeBreakdown {
  const WebSocketEnvelopeBreakdown({
    required this.envelopeType,
    required this.rawType,
    required this.identifier,
    required this.identifierParams,
    required this.channel,
    required this.innerMessage,
    required this.action,
    required this.resourceType,
    required this.requestId,
    required this.status,
  });

  factory WebSocketEnvelopeBreakdown.fromDecoded(Map<String, dynamic> decoded) {
    final rawType = decoded['type']?.toString();
    final identifier = decoded['identifier']?.toString();
    final identifierParams = parseActionCableIdentifier(identifier);
    final innerMessage = decoded['message'];
    final innerMap = innerMessage is Map ? innerMessage : null;
    final payload = extractSocketPayload(decoded);
    final rawStatus = innerMap?['status'] ?? payload['status'];

    return WebSocketEnvelopeBreakdown(
      envelopeType: classifyWebSocketEnvelope(decoded),
      rawType: rawType,
      identifier: identifier,
      identifierParams: identifierParams,
      channel: identifierParams?['channel']?.toString(),
      innerMessage: innerMessage,
      action: (innerMap?['action'] ?? payload['action'])?.toString(),
      resourceType: (innerMap?['resource_type'] ?? payload['resource_type'])
          ?.toString(),
      requestId: extractSocketRequestId(decoded, payload),
      status: rawStatus is num ? rawStatus.toInt() : null,
    );
  }

  final WebSocketEnvelopeType envelopeType;
  final String? rawType;
  final String? identifier;
  final Map<String, dynamic>? identifierParams;
  final String? channel;
  final Object? innerMessage;
  final String? action;
  final String? resourceType;
  final String? requestId;
  final int? status;

  bool get isPing => envelopeType == WebSocketEnvelopeType.ping;

  Map<String, dynamic> toLogMap() => {
    'message_type': envelopeType.logName,
    if (rawType != null) 'raw_type': rawType,
    if (channel != null) 'channel': channel,
    if (identifier != null) 'identifier': identifier,
    if (identifierParams != null) 'identifier_params': identifierParams,
    if (action != null) 'action': action,
    if (resourceType != null) 'resource_type': resourceType,
    if (requestId != null) 'request_id': requestId,
    if (status != null) 'status': status,
    if (innerMessage != null) 'message': innerMessage,
  };
}

WebSocketEnvelopeType classifyWebSocketEnvelope(Map<String, dynamic> decoded) {
  final type = decoded['type']?.toString();
  if (type == 'welcome') {
    return WebSocketEnvelopeType.welcome;
  }
  if (type == 'ping') {
    return WebSocketEnvelopeType.ping;
  }
  if (type == 'confirm_subscription') {
    return WebSocketEnvelopeType.confirmSubscription;
  }
  if (type == 'reject_subscription') {
    return WebSocketEnvelopeType.rejectSubscription;
  }
  if (type == 'disconnect') {
    return WebSocketEnvelopeType.disconnect;
  }
  if (decoded.containsKey('message')) {
    return WebSocketEnvelopeType.data;
  }
  return WebSocketEnvelopeType.unknown;
}

Map<String, dynamic>? parseActionCableIdentifier(String? identifier) {
  if (identifier == null || identifier.isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(identifier);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  } on Object {
    return {'raw': identifier};
  }
  return {'raw': identifier};
}

Map<String, dynamic> extractSocketPayload(Map<String, dynamic> decoded) {
  final payloadValue = decoded['payload'];
  if (payloadValue is Map<String, dynamic>) {
    return Map<String, dynamic>.from(payloadValue);
  }

  final messageValue = decoded['message'];
  if (messageValue is Map<String, dynamic>) {
    return Map<String, dynamic>.from(messageValue);
  }
  if (messageValue != null) {
    return {'message': messageValue};
  }

  final fallback = Map<String, dynamic>.from(decoded)
    ..remove('type')
    ..remove('identifier')
    ..remove('message')
    ..remove('payload')
    ..remove('headers');
  return fallback;
}

String extractSocketType(
  Map<String, dynamic> decoded,
  Map<String, dynamic> payload,
) {
  final typeValue = decoded['type'];
  if (typeValue is String && typeValue.isNotEmpty) {
    return typeValue;
  }
  final actionValue = payload['action'];
  if (actionValue is String && actionValue.isNotEmpty) {
    return actionValue;
  }
  return 'message';
}

Map<String, dynamic>? extractSocketHeaders(Map<String, dynamic> decoded) {
  final headers = decoded['headers'] as Map<String, dynamic>?;
  final identifier = decoded['identifier'];
  if (identifier == null) {
    return headers;
  }
  final merged = <String, dynamic>{'identifier': identifier};
  if (headers != null) {
    merged.addAll(headers);
  }
  return merged;
}

String? extractSocketRequestId(
  Map<String, dynamic> decoded,
  Map<String, dynamic> payload,
) {
  if (decoded['request_id'] != null) {
    return decoded['request_id'].toString();
  }
  if (payload['request_id'] != null) {
    return payload['request_id'].toString();
  }
  final messageField = decoded['message'];
  if (messageField is Map<String, dynamic> &&
      messageField['request_id'] != null) {
    return messageField['request_id'].toString();
  }
  return null;
}
