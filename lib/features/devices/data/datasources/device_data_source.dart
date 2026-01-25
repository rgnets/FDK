import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';

/// Abstract interface for device data sources
/// Follows Clean Architecture principles - defines contract without implementation
abstract class DeviceDataSource {
  /// Fetches all devices with optional field selection
  Future<List<DeviceModelSealed>> getDevices({
    List<String>? fields,
  });

  /// Fetches a specific device by ID with optional field selection
  ///
  /// Set [forceRefresh] to true to bypass cache and make a fresh request.
  Future<DeviceModelSealed> getDevice(
    String id, {
    List<String>? fields,
    bool forceRefresh = false,
  });

  /// Fetches devices for a specific room
  Future<List<DeviceModelSealed>> getDevicesByRoom(String roomId);

  /// Searches devices by query
  Future<List<DeviceModelSealed>> searchDevices(String query);

  /// Updates a device
  Future<DeviceModelSealed> updateDevice(DeviceModelSealed device);

  /// Reboots a device
  Future<void> rebootDevice(String deviceId);

  /// Resets a device to factory defaults
  Future<void> resetDevice(String deviceId);

  /// Deletes an image from a device by its signed ID
  Future<DeviceModelSealed> deleteDeviceImage(String deviceId, String signedIdToDelete);

  /// Uploads images to a device
  ///
  /// [deviceId] - The device ID (with prefix like ap_123)
  /// [base64Images] - List of base64-encoded image data URLs
  ///
  /// Returns the updated device model with new images
  Future<DeviceModelSealed> uploadDeviceImages(
    String deviceId,
    List<String> base64Images,
  );
}
