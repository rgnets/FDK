import 'dart:async';

/// Event emitted when a device is updated via WebSocket
class DeviceUpdateEvent {
  const DeviceUpdateEvent({
    required this.deviceId,
    required this.action,
    this.changedFields,
  });

  final String deviceId;
  final DeviceUpdateAction action;
  final List<String>? changedFields;
}

/// Actions that can be performed on a device
enum DeviceUpdateAction {
  created,
  updated,
  destroyed,
}

/// Event bus for device updates received via WebSocket
///
/// This enables the device detail view to refresh when external apps
/// modify device data (especially images).
class DeviceUpdateEventBus {
  DeviceUpdateEventBus();

  final _controller = StreamController<DeviceUpdateEvent>.broadcast();

  /// Stream of device update events
  Stream<DeviceUpdateEvent> get updates => _controller.stream;

  /// Emit a device update event
  void emit(DeviceUpdateEvent event) {
    _controller.add(event);
  }

  /// Dispose the event bus
  void dispose() {
    _controller.close();
  }
}
