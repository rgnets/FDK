import 'dart:convert';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/scanner/data/utils/mac_database.dart';
import 'package:rgnets_fdk/features/scanner/data/utils/mac_normalizer.dart';
import 'package:rgnets_fdk/features/scanner/domain/value_objects/serial_patterns.dart';

/// Result of parsed device barcodes.
class ParsedDeviceData {
  final String mac;
  final String serialNumber;
  final String? partNumber;
  final String? model;
  final bool isComplete;
  final DeviceTypeFromSerial? detectedType;
  final List<String> missingFields;

  const ParsedDeviceData({
    required this.mac,
    required this.serialNumber,
    this.partNumber,
    this.model,
    required this.isComplete,
    this.detectedType,
    this.missingFields = const [],
  });

  factory ParsedDeviceData.incomplete({
    String mac = '',
    String serialNumber = '',
    String? partNumber,
    DeviceTypeFromSerial? detectedType,
  }) {
    final missing = <String>[];
    if (mac.isEmpty) missing.add('MAC Address');
    if (serialNumber.isEmpty) missing.add('Serial Number');
    if (detectedType == DeviceTypeFromSerial.ont && (partNumber?.isEmpty ?? true)) {
      missing.add('Part Number');
    }

    return ParsedDeviceData(
      mac: mac,
      serialNumber: serialNumber,
      partNumber: partNumber,
      isComplete: false,
      detectedType: detectedType,
      missingFields: missing,
    );
  }
}

/// Service to handle barcode scanning validation logic.
/// Based on AT&T FE Tool reference implementation.
class ScannerValidationService {
  static const String _tag = 'ScannerValidation';

  /// Parses ONT barcodes from multiple scanned values.
  /// STRICT MODE: Requires ALCL serial, valid MAC, and part number.
  static ParsedDeviceData parseONTBarcodes(List<String> barcodes) {
    LoggerService.debug(
      'Parsing ONT barcodes from ${barcodes.length} values',
      tag: _tag,
    );

    String partNumber = '';
    String mac = '';
    String serialNumber = '';
    bool hasALCLSerial = false;

    for (String barcode in barcodes) {
      if (barcode.isEmpty) continue;

      String value = barcode.trim();

      // Remove known ONT prefixes
      if (value.startsWith('1P')) {
        value = value.substring(2);
      } else if (value.startsWith('23S')) {
        value = value.substring(3);
      } else if (value.startsWith('S')) {
        value = value.substring(1);
      }

      // Check for MAC address (12 hex chars)
      if (value.length == 12 && _isValidMacAddress(value) && mac.isEmpty) {
        mac = value.toUpperCase();
        LoggerService.debug('Found MAC: $mac', tag: _tag);
        continue;
      }

      // ONT-SPECIFIC: Only accept ALCL serials (strict)
      if (SerialPatterns.isONTSerial(value)) {
        serialNumber = value.toUpperCase();
        hasALCLSerial = true;
        LoggerService.debug('Found ALCL serial: $serialNumber', tag: _tag);
        continue;
      }

      // Check for Part Number pattern
      final pnRegex = RegExp(r'^[A-Z0-9]{8,12}[A-Z]$');
      if (pnRegex.hasMatch(value) && value.length >= 8 && partNumber.isEmpty) {
        partNumber = value;
        LoggerService.debug('Found part number: $partNumber', tag: _tag);
        continue;
      }

      // Log ignored non-ALCL serials
      if (serialNumber.isEmpty && value.length >= 10 && !value.startsWith('ALCL')) {
        LoggerService.warning('Ignored non-ALCL serial in ONT mode: $value', tag: _tag);
      }
    }

    // STRICT validation: ALL three required for ONT
    final isComplete = mac.isNotEmpty && partNumber.isNotEmpty && hasALCLSerial;

    if (!isComplete) {
      LoggerService.warning(
        'ONT incomplete - MAC: ${mac.isNotEmpty}, PN: ${partNumber.isNotEmpty}, ALCL: $hasALCLSerial',
        tag: _tag,
      );
    }

    return ParsedDeviceData(
      mac: mac,
      serialNumber: serialNumber,
      partNumber: partNumber,
      isComplete: isComplete,
      detectedType: DeviceTypeFromSerial.ont,
      missingFields: [
        if (mac.isEmpty) 'MAC Address',
        if (!hasALCLSerial) 'Serial Number (ALCL)',
        if (partNumber.isEmpty) 'Part Number',
      ],
    );
  }

  /// Parses AP barcodes from multiple scanned values.
  /// STRICT MODE: Requires AP serial (1K9/1M3/1HN) and valid MAC.
  static ParsedDeviceData parseAPBarcodes(List<String> barcodes) {
    LoggerService.debug(
      'Parsing AP barcodes from ${barcodes.length} values',
      tag: _tag,
    );

    String mac = '';
    String serialNumber = '';
    bool hasAPSerial = false;

    for (String barcode in barcodes) {
      if (barcode.isEmpty) continue;

      String value = barcode.trim();

      // Check for MAC address (12 hex chars)
      if (value.length == 12 && _isValidMacAddress(value) && mac.isEmpty) {
        mac = value.toUpperCase();
        LoggerService.debug('Found MAC: $mac', tag: _tag);
        continue;
      }

      // AP-SPECIFIC: Only accept approved prefixes (strict)
      if (SerialPatterns.isAPSerial(value)) {
        serialNumber = value.toUpperCase();
        hasAPSerial = true;
        LoggerService.debug('Found AP serial (1K9/1M3/1HN): $serialNumber', tag: _tag);
        continue;
      }

      // Log ignored non-AP serials
      if (serialNumber.isEmpty &&
          value.length >= 10 &&
          !SerialPatterns.apPrefixes.any((p) => value.toUpperCase().startsWith(p))) {
        LoggerService.warning('Ignored non-AP serial format in AP mode: $value', tag: _tag);
      }
    }

    // STRICT validation: Both required for AP
    final isComplete = mac.isNotEmpty && hasAPSerial;

    if (!isComplete) {
      LoggerService.warning(
        'AP incomplete - MAC: ${mac.isNotEmpty}, AP serial: $hasAPSerial',
        tag: _tag,
      );
    }

    return ParsedDeviceData(
      mac: mac,
      serialNumber: serialNumber,
      isComplete: isComplete,
      detectedType: DeviceTypeFromSerial.accessPoint,
      missingFields: [
        if (mac.isEmpty) 'MAC Address',
        if (!hasAPSerial) 'Serial Number (1K9/1M3/1HN)',
      ],
    );
  }

  /// Parses Switch barcodes from multiple scanned values.
  /// STRICT MODE: Requires valid MAC and LL serial (14+ chars).
  static ParsedDeviceData parseSwitchBarcodes(List<String> barcodes) {
    LoggerService.debug(
      'Parsing Switch barcodes from ${barcodes.length} values',
      tag: _tag,
    );

    String mac = '';
    String serialNumber = '';
    String model = '';
    bool hasLLSerial = false;

    for (String barcode in barcodes) {
      if (barcode.isEmpty) continue;

      String value = barcode.trim();

      // Check for MAC address first (12 hex chars)
      if (value.length == 12 && _isValidMacAddress(value) && mac.isEmpty) {
        mac = value.toUpperCase();
        LoggerService.debug('Found MAC: $mac', tag: _tag);
        continue;
      }

      // SWITCH-SPECIFIC: Only accept LL serials (14+ chars)
      if (SerialPatterns.isSwitchSerial(value) && serialNumber.isEmpty) {
        // Validate characters after LL (alphanumeric and dashes)
        final afterLL = value.substring(2);
        if (RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(afterLL)) {
          serialNumber = value.toUpperCase();
          hasLLSerial = true;
          LoggerService.debug('Found LL serial: $serialNumber', tag: _tag);
          continue;
        }
      }

      // Check for model number (optional)
      if (value.length >= 4 && value.length <= 20 && model.isEmpty) {
        if (!value.toUpperCase().startsWith('LL') && !_isValidMacAddress(value)) {
          model = value;
          LoggerService.debug('Found possible model: $model', tag: _tag);
        }
      }
    }

    // STRICT validation: require both MAC and LL serial
    final isComplete = mac.isNotEmpty && serialNumber.isNotEmpty && hasLLSerial;

    if (!isComplete) {
      LoggerService.warning(
        'Switch incomplete - MAC: ${mac.isNotEmpty}, LL: $hasLLSerial',
        tag: _tag,
      );
    }

    return ParsedDeviceData(
      mac: mac,
      serialNumber: serialNumber,
      model: model,
      isComplete: isComplete,
      detectedType: DeviceTypeFromSerial.switchDevice,
      missingFields: [
        if (mac.isEmpty) 'MAC Address',
        if (!hasLLSerial) 'Serial Number (LL)',
      ],
    );
  }

  /// Parse barcodes based on detected device type.
  static ParsedDeviceData parseBarcodesForType(
    List<String> barcodes,
    DeviceTypeFromSerial deviceType,
  ) {
    switch (deviceType) {
      case DeviceTypeFromSerial.ont:
        return parseONTBarcodes(barcodes);
      case DeviceTypeFromSerial.accessPoint:
        return parseAPBarcodes(barcodes);
      case DeviceTypeFromSerial.switchDevice:
        return parseSwitchBarcodes(barcodes);
    }
  }

  /// Auto-detect device type from a single barcode value.
  static DeviceTypeFromSerial? detectDeviceTypeFromBarcode(String barcode) {
    final value = barcode.trim().toUpperCase();

    // Check serial patterns
    if (SerialPatterns.isAPSerial(value)) {
      return DeviceTypeFromSerial.accessPoint;
    }
    if (SerialPatterns.isONTSerial(value)) {
      return DeviceTypeFromSerial.ont;
    }
    if (SerialPatterns.isSwitchSerial(value)) {
      return DeviceTypeFromSerial.switchDevice;
    }

    return null;
  }

  /// Parses RxG credentials from QR code.
  static Map<String, String>? parseRxgQRCode(String barcode) {
    try {
      // Check for JSON format
      if (barcode.startsWith('{')) {
        final json = jsonDecode(barcode) as Map<String, dynamic>;
        if (json['fqdn'] != null &&
            json['login'] != null &&
            json['api_key'] != null) {
          return {
            'fqdn': json['fqdn'].toString(),
            'login': json['login'].toString(),
            'api_key': json['api_key'].toString(),
          };
        }
      }

      // Try line-separated format
      final lines = barcode.split('\n');
      if (lines.length >= 3) {
        return {
          'fqdn': lines[0].trim(),
          'login': lines[1].trim(),
          'api_key': lines[2].trim(),
        };
      }

      return null;
    } catch (e) {
      LoggerService.error('Error parsing RxG QR code', error: e, tag: _tag);
      return null;
    }
  }

  /// Validates MAC address format using MACNormalizer.
  static bool _isValidMacAddress(String mac) {
    return MACNormalizer.tryNormalize(mac) != null;
  }

  /// Validates MAC address format (public).
  static bool isValidMacAddress(String mac) => _isValidMacAddress(mac);

  /// Check if a string looks like a MAC address (lenient check).
  static bool isMacLike(String value) => MACNormalizer.isMacLike(value);

  /// Validates MAC address against OUI database.
  /// Returns true if the MAC has a known manufacturer.
  static bool isKnownManufacturer(String mac) {
    if (!macDatabase.isLoaded) {
      return true; // Allow if database not loaded
    }
    return macDatabase.isKnownMAC(mac);
  }

  /// Get manufacturer name for a MAC address.
  static String getManufacturer(String mac) {
    if (!macDatabase.isLoaded) {
      return 'Unknown';
    }
    return macDatabase.getManufacturer(mac);
  }

  /// Formats MAC address with colons.
  static String formatMacAddress(String mac) {
    final normalized = MACNormalizer.tryNormalize(mac);
    if (normalized != null) {
      return MACNormalizer.formatWithColons(normalized);
    }
    return mac;
  }

  /// Normalizes MAC address (removes separators, uppercase).
  static String normalizeMac(String mac) {
    return MACNormalizer.tryNormalize(mac) ?? mac.toUpperCase();
  }

  /// Identify MAC address type (normal, broadcast, multicast, etc).
  static MACType identifyMacType(String mac) {
    return MACNormalizer.identifyType(mac);
  }
}
