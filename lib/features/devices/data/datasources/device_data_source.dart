import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';

/// Abstract interface for device data sources
/// Follows Clean Architecture principles - defines contract without implementation
abstract class DeviceDataSource {
  /// Fetches all devices with optional field selection
  Future<List<DeviceModel>> getDevices({
    List<String>? fields,
  });
  
  /// Fetches a specific device by ID with optional field selection
  Future<DeviceModel> getDevice(
    String id, {
    List<String>? fields,
  });
  
  /// Fetches devices for a specific room
  Future<List<DeviceModel>> getDevicesByRoom(String roomId);
  
  /// Searches devices by query
  Future<List<DeviceModel>> searchDevices(String query);
  
  /// Updates a device
  Future<DeviceModel> updateDevice(DeviceModel device);
  
  /// Reboots a device
  Future<void> rebootDevice(String deviceId);
  
  /// Resets a device to factory defaults
  Future<void> resetDevice(String deviceId);

  /// Controls the LED on an access point device
  /// [deviceId] - The ID of the AP device
  /// [action] - The LED action string ('on', 'off', 'blink')
  Future<void> controlLed(String deviceId, String action);
}