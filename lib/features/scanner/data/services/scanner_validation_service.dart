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
  ///
  /// Uses two-pass parsing with OUI-based disambiguation to correctly
  /// distinguish MAC addresses from part numbers (both are 12 hex chars).
  /// Pass 1: Classify unambiguous values (ALCL serial, prefixed part numbers).
  /// Pass 2: Resolve ambiguous 12-hex candidates using OUI database lookup.
  static ParsedDeviceData parseONTBarcodes(List<String> barcodes) {
    LoggerService.debug(
      'Parsing ONT barcodes from ${barcodes.length} values',
      tag: _tag,
    );

    String partNumber = '';
    String mac = '';
    String serialNumber = '';
    bool hasALCLSerial = false;
    final pnRegex = RegExp(r'^[A-Z0-9]{8,12}[A-Z]$');

    // Collect ambiguous 12-hex candidates for OUI-based resolution
    final hexCandidates = <String>[];

    // --- Pass 1: Classify unambiguous values ---
    for (String barcode in barcodes) {
      if (barcode.isEmpty) continue;

      String value = barcode.trim();

      // Remove known ONT prefixes — these are definitively part numbers
      if (value.startsWith('1P')) {
        partNumber = value.substring(2);
        LoggerService.debug('Found prefixed part number (1P): $partNumber', tag: _tag);
        continue;
      } else if (value.startsWith('23S')) {
        partNumber = value.substring(3);
        LoggerService.debug('Found prefixed part number (23S): $partNumber', tag: _tag);
        continue;
      } else if (value.startsWith('S') && value.length > 1 && !SerialPatterns.isONTSerial(value)) {
        partNumber = value.substring(1);
        LoggerService.debug('Found prefixed part number (S): $partNumber', tag: _tag);
        continue;
      }

      // ONT-SPECIFIC: Only accept ALCL serials (strict)
      if (SerialPatterns.isONTSerial(value)) {
        serialNumber = value.toUpperCase();
        hasALCLSerial = true;
        LoggerService.debug('Found ALCL serial: $serialNumber', tag: _tag);
        continue;
      }

      // Ambiguous: 12-hex value could be MAC or part number — defer to Pass 2
      if (value.length == 12 && _isValidMacAddress(value)) {
        hexCandidates.add(value.toUpperCase());
        continue;
      }

      // Non-hex part number (matches regex but wasn't 12 hex chars)
      if (pnRegex.hasMatch(value.toUpperCase()) && value.length >= 8 && partNumber.isEmpty) {
        partNumber = value.toUpperCase();
        LoggerService.debug('Found part number: $partNumber', tag: _tag);
        continue;
      }

      // Log ignored non-ALCL serials
      if (serialNumber.isEmpty && value.length >= 10 && !value.startsWith('ALCL')) {
        LoggerService.warning('Ignored non-ALCL serial in ONT mode: $value', tag: _tag);
      }
    }

    // --- Pass 2: Resolve 12-hex candidates using OUI database ---
    if (hexCandidates.isNotEmpty) {
      // Deduplicate while preserving order
      final seen = <String>{};
      final unique = hexCandidates.where(seen.add).toList();

      LoggerService.debug(
        'Resolving ${unique.length} hex candidate(s) via OUI lookup: $unique',
        tag: _tag,
      );

      if (unique.length == 1) {
        // Single candidate: assign to whichever slot is empty
        final value = unique.first;
        if (mac.isEmpty) {
          mac = value;
          LoggerService.debug('Single hex candidate → MAC: $mac', tag: _tag);
        } else if (partNumber.isEmpty) {
          partNumber = value;
          LoggerService.debug('Single hex candidate → part number: $partNumber', tag: _tag);
        }
      } else {
        // Multiple candidates: use OUI to disambiguate
        final withOUI = <String>[];
        final withoutOUI = <String>[];

        for (final value in unique) {
          if (macDatabase.isLoaded && macDatabase.isKnownMAC(value)) {
            withOUI.add(value);
          } else {
            withoutOUI.add(value);
          }
        }

        LoggerService.debug(
          'OUI results — known: $withOUI, unknown: $withoutOUI',
          tag: _tag,
        );

        // Assign MAC from known-OUI candidates
        if (mac.isEmpty && withOUI.isNotEmpty) {
          mac = withOUI.first;
          LoggerService.debug('OUI-resolved MAC: $mac', tag: _tag);
        }

        // Assign part number from unknown-OUI candidates
        if (partNumber.isEmpty && withoutOUI.isNotEmpty) {
          partNumber = withoutOUI.first;
          LoggerService.debug('OUI-resolved part number: $partNumber', tag: _tag);
        }

        // Fallback: if OUI database wasn't loaded or all candidates had same
        // OUI status, fall back to first-come = MAC, second = part number
        if (mac.isEmpty && partNumber.isEmpty && unique.length >= 2) {
          mac = unique.first;
          partNumber = unique[1];
          LoggerService.debug(
            'OUI unavailable, fallback order → MAC: $mac, PN: $partNumber',
            tag: _tag,
          );
        } else if (mac.isEmpty && unique.isNotEmpty) {
          mac = unique.first;
          LoggerService.debug('Fallback → MAC: $mac', tag: _tag);
        } else if (partNumber.isEmpty && unique.isNotEmpty) {
          // MAC already set, remaining candidate is part number
          final remaining = unique.where((v) => v != mac).toList();
          if (remaining.isNotEmpty) {
            partNumber = remaining.first;
            LoggerService.debug('Remaining hex candidate → part number: $partNumber', tag: _tag);
          }
        }
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
  /// Requires AP serial (1K9/1M3/1HN/EC2) and valid MAC.
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

      // Accept approved AP prefixes including EC2
      if (SerialPatterns.isAPSerial(value)) {
        serialNumber = value.toUpperCase();
        hasAPSerial = true;
        LoggerService.debug('Found AP serial: $serialNumber', tag: _tag);
        continue;
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

  /// Parses Switch barcodes from multiple scanned values.
  /// Requires valid MAC and Switch serial (LL or EC2).
  static ParsedDeviceData parseSwitchBarcodes(List<String> barcodes) {
    LoggerService.debug(
      'Parsing Switch barcodes from ${barcodes.length} values',
      tag: _tag,
    );

    String mac = '';
    String serialNumber = '';
    String model = '';
    bool hasSwitchSerial = false;

    for (String barcode in barcodes) {
      if (barcode.isEmpty) continue;

      String value = barcode.trim();

      // Check for MAC address first (12 hex chars)
      if (value.length == 12 && _isValidMacAddress(value) && mac.isEmpty) {
        mac = value.toUpperCase();
        LoggerService.debug('Found MAC: $mac', tag: _tag);
        continue;
      }

      // Accept LL or EC2 switch serials
      if (SerialPatterns.isSwitchSerial(value) && serialNumber.isEmpty) {
        serialNumber = value.toUpperCase();
        hasSwitchSerial = true;
        LoggerService.debug('Found Switch serial: $serialNumber', tag: _tag);
        continue;
      }

      // Check for model number (optional)
      if (value.length >= 4 && value.length <= 20 && model.isEmpty) {
        if (!value.toUpperCase().startsWith('LL') &&
            !value.toUpperCase().startsWith('EC2') &&
            !_isValidMacAddress(value)) {
          model = value;
          LoggerService.debug('Found possible model: $model', tag: _tag);
        }
      }
    }

    final isComplete = mac.isNotEmpty && hasSwitchSerial;

    if (!isComplete) {
      LoggerService.warning(
        'Switch incomplete - MAC: ${mac.isNotEmpty}, serial: $hasSwitchSerial',
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
        if (!hasSwitchSerial) 'Serial Number',
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
  /// Uses auto-detect-safe prefixes that exclude ambiguous EC2 serials,
  /// so the caller can route EC2 to the ambiguous handler instead.
  static DeviceTypeFromSerial? detectDeviceTypeFromBarcode(String barcode) {
    return SerialPatterns.detectDeviceType(barcode);
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
