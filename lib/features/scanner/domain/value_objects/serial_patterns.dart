/// Serial number validation patterns for device types.
/// Based on AT&T FE Tool reference implementation.
class SerialPatterns {
  SerialPatterns._();

  // AP serial prefixes (Access Points) - for manual mode validation
  static const List<String> apPrefixes = ['1K9', '1M3', '1HN', 'EC2'];

  // AP prefixes for auto-detect (excludes ambiguous EC2)
  static const List<String> _apAutoDetectPrefixes = ['1K9', '1M3', '1HN'];

  // ONT serial prefixes (Optical Network Terminal / Media Converter)
  static const List<String> ontPrefixes = ['ALCL'];

  // Switch serial prefixes - for manual mode validation
  static const List<String> switchPrefixes = ['LL', 'EC2'];

  // Switch prefixes for auto-detect (excludes ambiguous EC2)
  static const List<String> _switchAutoDetectPrefixes = ['LL'];

  // Part number prefixes for Edge-core device differentiation
  // FI2WL = Edge-core AP (EAP models)
  static const List<String> apPartNumberPrefixes = ['FI2WL'];

  // F0PWL = Edge-core Switch (ECS models)
  static const List<String> switchPartNumberPrefixes = ['F0PWL'];

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
  /// Switch serials start with LL or EC2 and are at least 12 characters.
  static bool isSwitchSerial(String serial) {
    final s = serial.toUpperCase().trim();
    return s.length >= 12 &&
        switchPrefixes.any((prefix) => s.startsWith(prefix));
  }

  /// Check if serial is an ambiguous EC2 serial (could be AP or Switch).
  static bool isAmbiguousEC2Serial(String serial) {
    final s = serial.toUpperCase().trim();
    return s.startsWith('EC2') && s.length >= 10;
  }

  /// Detect device type from part number (for EC2 devices).
  /// Returns null if part number doesn't match known patterns.
  static DeviceTypeFromSerial? detectDeviceTypeFromPartNumber(String partNumber) {
    final p = partNumber.toUpperCase().trim();

    // Check AP part number prefixes (FI2WL = Edge-core EAP)
    if (apPartNumberPrefixes.any((prefix) => p.startsWith(prefix))) {
      return DeviceTypeFromSerial.accessPoint;
    }

    // Check Switch part number prefixes (F0PWL = Edge-core ECS)
    if (switchPartNumberPrefixes.any((prefix) => p.startsWith(prefix))) {
      return DeviceTypeFromSerial.switchDevice;
    }

    return null;
  }

  /// Detect device type from serial number for auto-detect mode.
  /// Returns null if serial doesn't match any unique pattern.
  /// Note: EC2 serials return null - use detectDeviceTypeFromPartNumber instead.
  static DeviceTypeFromSerial? detectDeviceType(String serial) {
    final s = serial.toUpperCase().trim();

    // Check AP auto-detect prefixes (excludes EC2)
    if (s.length >= 10 && _apAutoDetectPrefixes.any((prefix) => s.startsWith(prefix))) {
      return DeviceTypeFromSerial.accessPoint;
    }

    // Check ONT
    if (isONTSerial(serial)) {
      return DeviceTypeFromSerial.ont;
    }

    // Check Switch auto-detect prefixes (excludes EC2)
    if (s.length >= 12 && _switchAutoDetectPrefixes.any((prefix) => s.startsWith(prefix))) {
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
        return 'Switch serials start with ${switchPrefixes.join(", ")} (min 12 chars)';
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
