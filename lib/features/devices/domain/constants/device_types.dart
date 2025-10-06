/// Device type constants for the domain layer
/// 
/// Following Clean Architecture principles, the domain layer defines
/// the canonical device type identifiers used throughout the application.
/// These constants ensure consistency between data and presentation layers.
class DeviceTypes {
  // Private constructor to prevent instantiation
  DeviceTypes._();
  
  /// Access Point device type
  /// Used for wireless access points and WiFi infrastructure
  static const String accessPoint = 'access_point';
  
  /// Switch device type  
  /// Used for network switches and switching infrastructure
  /// Note: Using networkSwitch to avoid Dart reserved keyword 'switch'
  static const String networkSwitch = 'switch';
  
  /// ONT (Optical Network Terminal) device type
  /// Used for fiber optic network terminals and media converters
  static const String ont = 'ont';
  
  /// WLAN Controller device type
  /// Used for wireless LAN controllers and management devices
  static const String wlanController = 'wlan_controller';
  
  /// All valid device types
  /// Used for validation and enumeration
  static const List<String> all = [
    accessPoint,
    networkSwitch,
    ont,
    wlanController,
  ];
  
  /// Validate if a device type is recognized
  /// 
  /// Throws [ArgumentError] if the device type is not valid.
  /// This enforces strict type checking as requested.
  static void validateDeviceType(String deviceType) {
    if (!all.contains(deviceType)) {
      throw ArgumentError(
        'Invalid device type: "$deviceType". '
        'Valid types are: ${all.join(', ')}',
      );
    }
  }
  
  /// Get display name for a device type
  /// 
  /// Converts internal device type identifiers to human-readable names
  /// for UI display purposes.
  static String getDisplayName(String deviceType) {
    validateDeviceType(deviceType);
    
    switch (deviceType) {
      case accessPoint:
        return 'Access Point';
      case networkSwitch:
        return 'Switch';
      case ont:
        return 'ONT';
      case wlanController:
        return 'WLAN Controller';
      default:
        // This should never happen due to validation above
        throw StateError('Unhandled device type: $deviceType');
    }
  }
  
  /// Get icon identifier for a device type
  /// 
  /// Returns the appropriate icon identifier for UI components.
  /// Using strings instead of IconData to maintain domain layer purity.
  static String getIconIdentifier(String deviceType) {
    validateDeviceType(deviceType);
    
    switch (deviceType) {
      case accessPoint:
        return 'wifi';
      case networkSwitch:
        return 'hub';
      case ont:
        return 'fiber_manual_record';
      case wlanController:
        return 'router';
      default:
        // This should never happen due to validation above
        throw StateError('Unhandled device type: $deviceType');
    }
  }
  
  /// Check if device type is a wireless infrastructure device
  static bool isWirelessDevice(String deviceType) {
    validateDeviceType(deviceType);
    return deviceType == accessPoint || deviceType == wlanController;
  }
  
  /// Check if device type is a wired infrastructure device
  static bool isWiredDevice(String deviceType) {
    validateDeviceType(deviceType);
    return deviceType == networkSwitch || deviceType == ont;
  }
}