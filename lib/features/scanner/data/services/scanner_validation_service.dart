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
    final hexCandidates = <String>[]; // 12 hex-char values (could be MAC or PN)

    // First pass: categorize all barcodes
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

      // ONT-SPECIFIC: Only accept ALCL serials (strict) — check first
      if (SerialPatterns.isONTSerial(value)) {
        serialNumber = value.toUpperCase();
        hasALCLSerial = true;
        LoggerService.debug('Found ALCL serial: $serialNumber', tag: _tag);
        continue;
      }

      // Collect 12-hex candidates (could be MAC or part number)
      if (value.length == 12 && _isValidMacAddress(value)) {
        final upper = value.toUpperCase();
        if (!hexCandidates.contains(upper)) {
          hexCandidates.add(upper);
        }
        continue;
      }

      // Check for Part Number pattern (non-hex values)
      final pnRegex = RegExp(r'^[A-Z0-9]{8,12}[A-Z]$');
      if (pnRegex.hasMatch(value) && value.length >= 8 && partNumber.isEmpty) {
        partNumber = value;
        LoggerService.debug('Found part number: $partNumber', tag: _tag);
        continue;
      }
    }

    // Second pass: disambiguate 12-hex candidates into MAC vs part number.
    // ONT part numbers (e.g. 3FE47273AAAA) can be 12 hex chars just like MACs.
    final pnRegex = RegExp(r'^[A-Z0-9]{8,12}[A-Z]$');
    if (hexCandidates.length == 1) {
      // Single candidate: check if it's actually a part number (ends with letter)
      // and we don't have a PN yet — if so, it might be PN not MAC
      if (partNumber.isEmpty && pnRegex.hasMatch(hexCandidates[0])) {
        // Ambiguous — treat as MAC since we can't tell with one candidate
        mac = hexCandidates[0];
      } else {
        mac = hexCandidates[0];
      }
      LoggerService.debug('Found MAC (sole candidate): $mac', tag: _tag);
    } else if (hexCandidates.length >= 2) {
      // Multiple 12-hex candidates. Use OUI database if loaded for clear results,
      // otherwise use heuristic: part numbers end with a letter (A-Z).
      if (macDatabase.isLoaded) {
        String? knownMac;
        String? unknownCandidate;
        for (final c in hexCandidates) {
          if (isKnownManufacturer(c)) {
            knownMac ??= c;
          } else {
            unknownCandidate ??= c;
          }
        }
        if (knownMac != null && unknownCandidate != null) {
          mac = knownMac;
          if (partNumber.isEmpty) partNumber = unknownCandidate;
        }
      }

      // Fallback heuristic: PN matches regex (ends with letter), MAC doesn't
      if (mac.isEmpty) {
        for (final candidate in hexCandidates) {
          if (pnRegex.hasMatch(candidate) && partNumber.isEmpty) {
            partNumber = candidate;
          } else if (mac.isEmpty) {
            mac = candidate;
          }
        }
        if (mac.isEmpty) mac = hexCandidates.first;
      }
      LoggerService.debug('Disambiguated: MAC=$mac, PN=$partNumber', tag: _tag);
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
  /// Accepts AT&T-style serials (1K9/1M3/1HN) and, when the MAC's OUI
  /// resolves to Ruckus, any alphanumeric serial >=10 chars.
  static ParsedDeviceData parseAPBarcodes(List<String> barcodes) {
    LoggerService.debug(
      'Parsing AP barcodes from ${barcodes.length} values',
      tag: _tag,
    );

    String mac = '';
    String serialNumber = '';
    bool hasAPSerial = false;

    // First pass: split into 12-hex candidates (potential MAC, or a numeric
    // Ruckus serial that happens to parse as hex) and other values.
    final hexCandidates = <String>[];
    final otherValues = <String>[];
    for (final barcode in barcodes) {
      if (barcode.isEmpty) continue;
      final value = barcode.trim();
      if (value.length == 12 && _isValidMacAddress(value)) {
        final upper = value.toUpperCase();
        if (!hexCandidates.contains(upper)) hexCandidates.add(upper);
      } else if (value.isNotEmpty) {
        otherValues.add(value);
      }
    }

    // Strict AT&T-style serial (1K9/1M3/1HN) in non-hex values.
    for (final value in otherValues) {
      if (SerialPatterns.isAPSerial(value)) {
        serialNumber = value.toUpperCase();
        hasAPSerial = true;
        LoggerService.debug('Found AP serial (1K9/1M3/1HN): $serialNumber', tag: _tag);
        break;
      }
    }

    // Resolve MAC from hex candidates. With multiple candidates, prefer the
    // one whose OUI is known so a Ruckus MAC wins over an all-numeric Ruckus
    // serial that incidentally parses as hex.
    if (hexCandidates.length == 1) {
      mac = hexCandidates.first;
    } else if (hexCandidates.length >= 2) {
      String? vendorMac;
      String? leftover;
      for (final c in hexCandidates) {
        if (macDatabase.isLoaded && macDatabase.isKnownMAC(c)) {
          vendorMac ??= c;
        } else {
          leftover ??= c;
        }
      }
      mac = vendorMac ?? hexCandidates.first;
      // Treat any unclaimed 12-hex value as the numeric Ruckus serial.
      if (!hasAPSerial && leftover != null && leftover != mac) {
        serialNumber = leftover;
        hasAPSerial = true;
        LoggerService.debug(
          'Found Ruckus serial (numeric, vendor-disambiguated): $serialNumber',
          tag: _tag,
        );
      }
    }
    if (mac.isNotEmpty) {
      LoggerService.debug('Found MAC: $mac', tag: _tag);
    }

    // Vendor-aware relaxation: if MAC resolves to Ruckus and we still don't
    // have a serial, accept any non-MAC alphanumeric value >=10 chars.
    if (mac.isNotEmpty && !hasAPSerial && _isRuckusMac(mac)) {
      final lenient = RegExp(r'^[A-Z0-9]+$');
      for (final value in otherValues) {
        final upper = value.toUpperCase();
        if (upper.length >= 10 && lenient.hasMatch(upper)) {
          serialNumber = upper;
          hasAPSerial = true;
          LoggerService.debug(
            'Found Ruckus serial (vendor-relaxed): $serialNumber',
            tag: _tag,
          );
          break;
        }
      }
    }

    // Log leftover non-serial values to help diagnose unsupported labels.
    if (!hasAPSerial) {
      for (final value in otherValues) {
        if (value.length >= 10) {
          LoggerService.warning(
            'Ignored non-AP serial format in AP mode: $value',
            tag: _tag,
          );
        }
      }
    }

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
        if (!hasAPSerial) 'Serial Number',
      ],
    );
  }

  /// Whether the OUI of the given MAC resolves to Ruckus Wireless.
  static bool _isRuckusMac(String mac) {
    if (!macDatabase.isLoaded) return false;
    return macDatabase.getManufacturer(mac).toLowerCase().contains('ruckus');
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
