/// Utility class for device type operations
/// Following Clean Architecture - this belongs in the domain layer
class DeviceTypeUtils {
  DeviceTypeUtils._(); // Private constructor to prevent instantiation
  
  /// Check if device type is an Access Point
  static bool isAccessPoint(String type) {
    final normalized = type.toLowerCase().trim();
    return normalized == 'access_point' || 
           normalized == 'access point' || 
           normalized == 'accesspoint' ||
           normalized == 'ap';
  }
  
  /// Check if device type is a Switch
  static bool isSwitch(String type) {
    final normalized = type.toLowerCase().trim();
    return normalized == 'switch' || 
           normalized == 'sw';
  }
  
  /// Check if device type is an ONT/Media Converter
  static bool isONT(String type) {
    final normalized = type.toLowerCase().trim();
    return normalized == 'ont' || 
           normalized == 'media_converter' || 
           normalized == 'media converter' ||
           normalized == 'mediaconverter';
  }
  
  /// Get standardized device type name
  static String getStandardizedType(String type) {
    if (isAccessPoint(type)) {
      return 'Access Point';
    }
    if (isSwitch(type)) {
      return 'Switch';
    }
    if (isONT(type)) {
      return 'ONT';
    }
    return type;
  }
  
  /// Get abbreviated device type name
  static String getAbbreviatedType(String type) {
    if (isAccessPoint(type)) {
      return 'AP';
    }
    if (isSwitch(type)) {
      return 'SW';
    }
    if (isONT(type)) {
      return 'ONT';
    }
    return type;
  }
}