import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/scanner/data/utils/mac_normalizer.dart';

/// Entry in the MAC database.
class MACEntry {
  MACEntry({
    required this.prefix,
    required this.prefixBits,
    required this.manufacturer,
    required this.registryType,
    this.isIEEEReserved = false,
  });

  final String prefix; // Normalized hex string (no separators)
  final int prefixBits; // 24, 28, or 36
  final String manufacturer; // Normalized company name
  final String registryType; // MA-L, MA-M, or MA-S
  final bool isIEEEReserved; // True if IEEE Registration Authority

  /// Get the number of hex characters for this prefix.
  int get prefixLength => prefixBits ~/ 4;
}

/// Result of a MAC lookup.
class MACLookupResult {
  MACLookupResult({
    this.entry,
    required this.type,
    required this.normalizedMAC,
    this.specialDescription,
  });

  final MACEntry? entry;
  final MACType type;
  final String normalizedMAC;
  final String? specialDescription;

  /// Get the manufacturer name or special description.
  String get manufacturer =>
      entry?.manufacturer ?? specialDescription ?? 'Unknown';

  /// Whether this MAC has a known manufacturer.
  bool get isKnown => entry != null;
}

/// Unified MAC database with support for MA-L, MA-M, and MA-S.
///
/// Based on AT&T FE Tool reference implementation.
class MACDatabase {
  static const String _tag = 'MACDatabase';

  // Separate maps for each prefix length for efficient lookup
  final Map<String, MACEntry> _mal = {}; // 24-bit (6 chars)
  final Map<String, MACEntry> _mam = {}; // 28-bit (7 chars)
  final Map<String, MACEntry> _mas = {}; // 36-bit (9 chars)

  bool _isLoaded = false;
  Completer<void>? _loadCompleter;

  /// Check if database is loaded.
  bool get isLoaded => _isLoaded;

  /// Get total entry count.
  int get entryCount => _mal.length + _mam.length + _mas.length;

  /// Load unified database from CSV string.
  Future<void> loadFromCsv(String csvData) async {
    try {
      LoggerService.info('Loading unified MAC database...', tag: _tag);
      final stopwatch = Stopwatch()..start();

      // Clear existing data
      _mal.clear();
      _mam.clear();
      _mas.clear();

      // Parse CSV line by line
      final lines = csvData.split('\n');
      var isFirstLine = true;

      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) {
          continue;
        }

        // Skip header
        if (isFirstLine) {
          isFirstLine = false;
          continue;
        }

        try {
          // Parse CSV line manually to handle quotes and commas
          final fields = _parseCsvLine(trimmedLine);
          if (fields.length < 5) {
            continue;
          }

          final entry = MACEntry(
            prefix: fields[0].trim().toUpperCase(),
            prefixBits: int.parse(fields[1].trim()),
            manufacturer: fields[2].trim(),
            registryType: fields[3].trim(),
            isIEEEReserved: fields[4].trim().toLowerCase() == 'true',
          );

          // Add to appropriate map based on prefix length
          switch (entry.prefixBits) {
            case 24:
              _mal[entry.prefix] = entry;
            case 28:
              _mam[entry.prefix] = entry;
            case 36:
              _mas[entry.prefix] = entry;
          }
        } on Exception {
          // Skip malformed rows
        }
      }

      _isLoaded = true;
      stopwatch.stop();

      LoggerService.info(
        'MAC database loaded: $entryCount entries in ${stopwatch.elapsedMilliseconds}ms',
        tag: _tag,
      );
      LoggerService.debug(
        'MA-L: ${_mal.length}, MA-M: ${_mam.length}, MA-S: ${_mas.length}',
        tag: _tag,
      );
    } on Exception catch (e) {
      LoggerService.error('Failed to load MAC database', error: e, tag: _tag);
      rethrow;
    }
  }

  /// Parse a CSV line handling quotes and commas.
  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          buffer.write('"');
          i++; // Skip next quote
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // Field separator
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    // Add final field
    fields.add(buffer.toString());
    return fields;
  }

  /// Load unified database from assets.
  Future<void> loadFromAssets() async {
    // Prevent multiple simultaneous loads
    if (_loadCompleter != null) {
      return _loadCompleter!.future;
    }

    _loadCompleter = Completer<void>();

    try {
      // Try to load unified database first
      String csvString;
      try {
        csvString = await rootBundle.loadString('assets/mac_unified.csv');
        LoggerService.info(
          'Loading unified MAC database from assets',
          tag: _tag,
        );
      } on Exception {
        // Fall back to legacy OUI database
        LoggerService.warning(
          'Unified database not found, falling back to legacy OUI',
          tag: _tag,
        );
        csvString = await _loadLegacyOUI();
      }

      await loadFromCsv(csvString);
      _loadCompleter!.complete();
    } on Exception catch (e) {
      _loadCompleter!.completeError(e);
      rethrow;
    }
  }

  /// Load legacy OUI database and convert to unified format.
  Future<String> _loadLegacyOUI() async {
    final csvString = await rootBundle.loadString('assets/oui.csv');
    final lines = csvString.split('\n');

    // Convert to unified format
    final unified = StringBuffer()
      ..writeln('prefix,prefix_bits,manufacturer,registry_type,is_ieee_reserved');

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        continue;
      }

      final fields = _parseCsvLine(line);
      if (fields.length >= 3) {
        // Column 1 contains the OUI hex
        final oui = fields[1]
            .replaceAll(RegExp(r'[^0-9A-Fa-f]'), '')
            .toUpperCase();
        // Column 2 contains the manufacturer name
        final manufacturer = fields[2].trim();

        if (oui.length == 6 && RegExp(r'^[0-9A-F]{6}$').hasMatch(oui)) {
          // Check if it's IEEE Registration Authority
          final isIEEE = manufacturer
              .toLowerCase()
              .contains('ieee registration authority');
          // Escape manufacturer name for CSV
          final escapedManufacturer = manufacturer.contains(',')
              ? '"${manufacturer.replaceAll('"', '""')}"'
              : manufacturer;
          unified.writeln('$oui,24,$escapedManufacturer,MA-L,$isIEEE');
        }
      }
    }

    return unified.toString();
  }

  /// Lookup a MAC address in the unified database.
  MACLookupResult lookup(String macAddress) {
    try {
      // Normalize MAC address
      final normalized = MACNormalizer.normalize(macAddress);

      // Try prefixes from longest to shortest for most specific match

      // MA-S lookup (9 chars)
      if (normalized.length >= 9) {
        final prefix = normalized.substring(0, 9);
        if (_mas.containsKey(prefix)) {
          return MACLookupResult(
            entry: _mas[prefix],
            type: MACType.normal,
            normalizedMAC: normalized,
          );
        }
      }

      // MA-M lookup (7 chars)
      if (normalized.length >= 7) {
        final prefix = normalized.substring(0, 7);
        if (_mam.containsKey(prefix)) {
          return MACLookupResult(
            entry: _mam[prefix],
            type: MACType.normal,
            normalizedMAC: normalized,
          );
        }
      }

      // MA-L lookup (6 chars)
      if (normalized.length >= 6) {
        final prefix = normalized.substring(0, 6);
        if (_mal.containsKey(prefix)) {
          final entry = _mal[prefix]!;

          // Special handling for IEEE Registration Authority
          if (entry.isIEEEReserved) {
            return MACLookupResult(
              entry: entry,
              type: MACType.normal,
              normalizedMAC: normalized,
              specialDescription: 'IEEE Reserved Block (check MA-M/MA-S)',
            );
          }

          return MACLookupResult(
            entry: entry,
            type: MACType.normal,
            normalizedMAC: normalized,
          );
        }
      }

      // No match found - check for special MAC types
      final macType = MACNormalizer.identifyType(macAddress);
      if (macType != MACType.normal) {
        return MACLookupResult(
          type: macType,
          normalizedMAC: normalized,
          specialDescription: MACNormalizer.getSpecialDescription(macType),
        );
      }

      // Truly unknown MAC
      return MACLookupResult(
        type: MACType.unknown,
        normalizedMAC: normalized,
      );
    } on Exception {
      return MACLookupResult(
        type: MACType.invalid,
        normalizedMAC: macAddress,
        specialDescription: 'Invalid MAC format',
      );
    }
  }

  /// Get manufacturer for full MAC address.
  String getManufacturer(String macAddress) {
    if (!_isLoaded) {
      LoggerService.warning(
        'MAC manufacturer lookup before database loaded',
        tag: _tag,
      );
      return 'Unknown';
    }

    final result = lookup(macAddress);
    return result.manufacturer;
  }

  /// Check if a specific OUI exists in any registry (MA-L, MA-M, MA-S).
  bool isValidOUI(String oui) {
    if (!_isLoaded) {
      LoggerService.warning('OUI validation before database loaded', tag: _tag);
      return false;
    }

    final normalized =
        oui.toUpperCase().replaceAll(RegExp(r'[^0-9A-F]'), '');
    if (normalized.length != 6) {
      return false;
    }

    // Check MA-L registry (most common case)
    return _mal.containsKey(normalized);
  }

  /// Check if a full MAC address has a known manufacturer.
  bool isKnownMAC(String macAddress) {
    if (!_isLoaded) {
      return false;
    }
    final result = lookup(macAddress);
    return result.isKnown;
  }
}

/// Global instance of the MAC database.
final MACDatabase macDatabase = MACDatabase();

/// Initialize the global MAC database.
Future<void> loadMACDatabase() async {
  await macDatabase.loadFromAssets();
}
