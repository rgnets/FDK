import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/scanner/domain/value_objects/serial_patterns.dart';

part 'barcode_data.freezed.dart';

@freezed
class BarcodeData with _$BarcodeData {
  const factory BarcodeData({
    required String rawValue,
    required String format,
    required DateTime scannedAt,
    Map<String, String>? extractedFields,
  }) = _BarcodeData;

  const BarcodeData._();

  /// Check if this looks like a MAC address
  bool get isMacAddress {
    final macPattern = RegExp(
      r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$|^([0-9A-Fa-f]{12})$',
    );
    return macPattern.hasMatch(rawValue);
  }

  /// Check if this looks like a serial number
  bool get isSerialNumber {
    // Serial numbers are typically alphanumeric, 6-20 characters
    final serialPattern = RegExp(r'^[A-Z0-9]{6,20}$', caseSensitive: false);
    return serialPattern.hasMatch(rawValue) && !isMacAddress;
  }

  /// Detect device type from serial number using prefix patterns.
  /// Returns null if serial doesn't match any known device pattern.
  DeviceTypeFromSerial? get detectedDeviceType {
    if (!isSerialNumber) return null;
    return SerialPatterns.detectDeviceType(rawValue);
  }

  /// Check if this is an AP serial number.
  bool get isAPSerial => SerialPatterns.isAPSerial(rawValue);

  /// Check if this is an ONT serial number.
  bool get isONTSerial => SerialPatterns.isONTSerial(rawValue);

  /// Check if this is a Switch serial number.
  bool get isSwitchSerial => SerialPatterns.isSwitchSerial(rawValue);

  /// Check if this looks like a part number
  bool get isPartNumber {
    // Part numbers often have specific patterns with dashes or slashes
    final partPattern = RegExp(
      r'^[A-Z0-9]+[-/][A-Z0-9]+|^P/N:?\s*[A-Z0-9]+',
      caseSensitive: false,
    );
    return partPattern.hasMatch(rawValue);
  }

  /// Get the normalized MAC address if this is a MAC
  String? get normalizedMacAddress {
    if (!isMacAddress) {
      return null;
    }
    
    // Remove all separators and convert to uppercase
    final mac = rawValue.replaceAll(RegExp('[:-]'), '').toUpperCase();
    
    // Format as XX:XX:XX:XX:XX:XX
    if (mac.length == 12) {
      return '${mac.substring(0, 2)}:${mac.substring(2, 4)}:'
             '${mac.substring(4, 6)}:${mac.substring(6, 8)}:'
             '${mac.substring(8, 10)}:${mac.substring(10, 12)}';
    }
    
    return null;
  }
}