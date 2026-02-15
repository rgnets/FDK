/// Serial number validation patterns for device types.
/// Based on AT&T FE Tool reference implementation.
class SerialPatterns {
  SerialPatterns._();

  // AP serial prefixes (Access Points)
  static const List<String> apPrefixes = ['1K9', '1M3', '1HN', 'C0C'];

  // ONT serial prefixes (Optical Network Terminal / Media Converter)
  static const List<String> ontPrefixes = ['ALCL'];

  // Switch serial prefixes
  static const List<String> switchPrefixes = ['LL'];

  /// Check if serial is an Access Point serial number.
  /// AP serials start with 1K9, 1M3, or 1HN and are at least 10 characters.
  static bool isAPSerial(String serial) {
    final s = serial.toUpperCase().trim();
    return s.length >= 10 && apPrefixes.any((prefix) => s.startsWith(prefix));
  }

  /// Check if serial is an ONT serial number.
  /// ONT serials start with ALCL and are exactly 12 characters.
  static bool isONTSerial(String serial) {
    final s = serial.toUpperCase().trim();
    return s.length == 12 && ontPrefixes.any((prefix) => s.startsWith(prefix));
  }

  /// Check if serial is a Switch serial number.
  /// Switch serials start with LL and are at least 14 characters.
  static bool isSwitchSerial(String serial) {
    final s = serial.toUpperCase().trim();
    return s.length >= 14 &&
        switchPrefixes.any((prefix) => s.startsWith(prefix));
  }

  /// Detect device type from serial number.
  /// Returns null if serial doesn't match any known pattern.
  static DeviceTypeFromSerial? detectDeviceType(String serial) {
    if (isAPSerial(serial)) {
      return DeviceTypeFromSerial.accessPoint;
    }
    if (isONTSerial(serial)) {
      return DeviceTypeFromSerial.ont;
    }
    if (isSwitchSerial(serial)) {
      return DeviceTypeFromSerial.switchDevice;
    }
    return null;
  }

  /// Validate serial format for a specific device type.
  static bool isValidForType(String serial, DeviceTypeFromSerial type) {
    switch (type) {
      case DeviceTypeFromSerial.accessPoint:
        return isAPSerial(serial);
      case DeviceTypeFromSerial.ont:
        return isONTSerial(serial);
      case DeviceTypeFromSerial.switchDevice:
        return isSwitchSerial(serial);
    }
  }

  /// Get expected prefix info for error messages.
  static String getExpectedFormat(DeviceTypeFromSerial type) {
    switch (type) {
      case DeviceTypeFromSerial.accessPoint:
        return 'AP serials start with ${apPrefixes.join(", ")} (min 10 chars)';
      case DeviceTypeFromSerial.ont:
        return 'ONT serials start with ${ontPrefixes.join(", ")} (exactly 12 chars)';
      case DeviceTypeFromSerial.switchDevice:
        return 'Switch serials start with ${switchPrefixes.join(", ")} (min 14 chars)';
    }
  }
}

/// Device type detected from serial number pattern.
enum DeviceTypeFromSerial {
  accessPoint,
  ont,
  switchDevice,
}

extension DeviceTypeFromSerialX on DeviceTypeFromSerial {
  String get displayName {
    switch (this) {
      case DeviceTypeFromSerial.accessPoint:
        return 'Access Point';
      case DeviceTypeFromSerial.ont:
        return 'ONT';
      case DeviceTypeFromSerial.switchDevice:
        return 'Switch';
    }
  }

  String get abbreviation {
    switch (this) {
      case DeviceTypeFromSerial.accessPoint:
        return 'AP';
      case DeviceTypeFromSerial.ont:
        return 'ONT';
      case DeviceTypeFromSerial.switchDevice:
        return 'SW';
    }
  }
}
