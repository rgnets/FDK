import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';

/// Abstract interface for device data sources
/// Follows Clean Architecture principles - defines contract without implementation
abstract class DeviceDataSource {
  /// Fetches all devices with optional field selection
  Future<List<DeviceModel>> getDevices({
    List<String>? fields,
  });
  
  /// Fetches a specific device by ID with optional field selection
  ///
  /// Set [forceRefresh] to true to bypass cache and make a fresh request.
  Future<DeviceModel> getDevice(
    String id, {
    List<String>? fields,
    bool forceRefresh = false,
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

  /// Deletes an image from a device
  Future<DeviceModel> deleteDeviceImage(String deviceId, String imageUrl);

  /// Uploads images to a device
  ///
  /// [deviceId] - The device ID (with prefix like ap_123)
  /// [base64Images] - List of base64-encoded image data URLs
  ///
  /// Returns the updated device model with new images
  Future<DeviceModel> uploadDeviceImages(
    String deviceId,
    List<String> base64Images,
  );
}