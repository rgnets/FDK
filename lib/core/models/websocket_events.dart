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
  const factory DeviceEvent.batchUpdate(List<Device> devices) = DeviceBatchUpdate;

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
