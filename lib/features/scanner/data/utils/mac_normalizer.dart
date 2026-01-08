/// MAC address normalization and type identification utilities.
///
/// Based on AT&T FE Tool reference implementation.

/// Types of MAC addresses.
enum MACType {
  normal,
  broadcast,
  multicast,
  locallyAdministered,
  randomized,
  invalid,
  unknown,
}

/// Utility class for MAC address normalization and identification.
class MACNormalizer {
  MACNormalizer._();

  /// Regular expression for valid hex characters.
  static final RegExp _hexPattern = RegExp(r'^[0-9A-F]+$');

  /// Regular expression for removing separators.
  static final RegExp _separatorPattern = RegExp(r'[:\-\.\s\t]');

  /// Normalize a MAC address to uppercase hex without separators.
  ///
  /// Supports formats:
  /// - 70:B3:D5:7A:BC:EF (colons)
  /// - 70-B3-D5-7A-BC-EF (dashes)
  /// - 70.B3.D5.7A.BC.EF (dots)
  /// - 70b3.d57a.bcef (Cisco format)
  /// - 70 B3 D5 7A BC EF (spaces)
  /// - 70B3D57ABCEF (no separators)
  /// - 0x70B3D57ABCEF (with prefix)
  static String normalize(String mac) {
    if (mac.isEmpty) {
      throw const FormatException('MAC address cannot be empty');
    }

    // Trim whitespace
    mac = mac.trim();

    if (mac.isEmpty) {
      throw const FormatException('MAC address cannot be empty');
    }

    // Remove common prefixes (0x or 0X)
    if (mac.toLowerCase().startsWith('0x')) {
      mac = mac.substring(2);
    }

    // Check if we have a format with separators
    final hasSeparators = mac.contains(':') ||
        mac.contains('-') ||
        mac.contains('.') ||
        mac.contains(' ') ||
        mac.contains('\t');

    if (hasSeparators) {
      // Check for mixed separators (invalid but handle gracefully)
      if ((mac.contains(':') && mac.contains('-')) ||
          (mac.contains(':') && mac.contains('.')) ||
          (mac.contains('-') && mac.contains('.'))) {
        // Mixed separators - just remove all of them
        mac = mac.replaceAll(_separatorPattern, '');
      } else if (mac.contains('.') &&
          !mac.contains(':') &&
          !mac.contains('-')) {
        // Cisco format (4 chars . 4 chars . 4 chars)
        mac = mac.replaceAll('.', '');
      } else {
        // Handle formats with individual octets
        var octets = mac.split(RegExp(r'[:\-\s\t]'));

        // Filter out empty strings from multiple consecutive separators
        octets = octets.where((s) => s.isNotEmpty).toList();

        if (octets.length == 6) {
          // Pad each octet to 2 chars and join
          mac = octets.map((octet) {
            octet = octet.toUpperCase();
            if (octet.length == 1) {
              return '0$octet';
            }
            return octet;
          }).join();
        } else {
          // Not standard 6-octet format, just remove separators
          mac = mac.replaceAll(_separatorPattern, '');
        }
      }
    } else {
      // No separators
      mac = mac.replaceAll(_separatorPattern, '');
    }

    // Convert to uppercase
    mac = mac.toUpperCase();

    // Validate hex characters only
    if (!_hexPattern.hasMatch(mac)) {
      throw const FormatException(
        'Invalid MAC address format - contains non-hex characters',
      );
    }

    // Check length (should be 12 hex chars for a full MAC)
    if (mac.length > 12) {
      throw const FormatException(
        'MAC address too long - expected 12 hex characters',
      );
    }

    // Pad with leading zeros if necessary
    if (mac.length < 12) {
      mac = mac.padLeft(12, '0');
    }

    return mac;
  }

  /// Returns true if the input looks like a MAC address.
  ///
  /// This is a lenient precheck and does not guarantee that [normalize] will succeed.
  static bool isMacLike(String input) {
    if (input.isEmpty) {
      return false;
    }
    var s = input.trim();
    if (s.isEmpty) {
      return false;
    }
    if (s.toLowerCase().startsWith('0x')) {
      s = s.substring(2);
    }
    // Remove common separators for the check
    final compact = s.replaceAll(_separatorPattern, '');
    // Must be hex-only after stripping separators
    if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(compact)) {
      return false;
    }
    // Plausible length (allow short/partial up to typical maximum)
    return compact.length >= 6 && compact.length <= 12;
  }

  /// Try to normalize a MAC address.
  ///
  /// Returns normalized hex (12 chars) on success, or null if normalization fails.
  static String? tryNormalize(String mac) {
    try {
      return normalize(mac);
    } catch (_) {
      return null;
    }
  }

  /// Identify the type of MAC address.
  static MACType identifyType(String macAddress) {
    try {
      // Normalize first
      final mac = normalize(macAddress);

      // Check for broadcast
      if (mac == 'FFFFFFFFFFFF') {
        return MACType.broadcast;
      }

      // Parse first octet
      final firstOctet = int.parse(mac.substring(0, 2), radix: 16);

      // Check for multicast (LSB of first octet is 1)
      if ((firstOctet & 0x01) == 1) {
        return MACType.multicast;
      }

      // Check for locally administered (bit 1 of first octet is set)
      if ((firstOctet & 0x02) == 2) {
        // Check if it's likely a randomized privacy address
        if (_isLikelyRandomized(mac)) {
          return MACType.randomized;
        }
        return MACType.locallyAdministered;
      }

      // Otherwise it's a normal address
      return MACType.normal;
    } catch (e) {
      return MACType.invalid;
    }
  }

  /// Check if a MAC address is likely randomized (privacy address).
  static bool _isLikelyRandomized(String mac) {
    final prefix = mac.substring(0, 2);

    // Common randomized prefixes (must have odd first nibble for randomized)
    const randomPrefixes = {
      '92', '96', '9A', '9E',
      'D2', 'D6', 'DA', 'DE',
      'F2', 'F6', 'FA', 'FE',
      'B2', 'B6', 'BA', 'BE',
      '32', '36', '3A', '3E',
      '52', '56', '5A', '5E',
      '72', '76', '7A', '7E',
    };

    if (randomPrefixes.contains(prefix)) {
      return true;
    }

    // Check for patterns like DA:A1:19 (common iOS pattern)
    if (mac.startsWith('DAA119')) {
      return true;
    }

    // Check for all zeros in the last part (common pattern) but only for random prefixes
    if (mac.endsWith('000000') && randomPrefixes.contains(prefix)) {
      return true;
    }

    // Not randomized if it's a simple locally administered like 02:00:00:00:00:01
    if (prefix == '02' || prefix == '06' || prefix == '0A' || prefix == '0E') {
      // Check if it looks too regular to be random
      final rest = mac.substring(2);
      // Count unique hex digits in the rest
      final uniqueChars = rest.split('').toSet();
      if (uniqueChars.length <= 2) {
        // Too regular, probably not randomized
        return false;
      }
    }

    return false;
  }

  /// Get a human-readable description for special MAC types.
  static String? getSpecialDescription(MACType type) {
    switch (type) {
      case MACType.broadcast:
        return 'Broadcast Address';
      case MACType.multicast:
        return 'Multicast Address';
      case MACType.locallyAdministered:
        return 'Locally Administered Address';
      case MACType.randomized:
        return 'Randomized Privacy Address';
      case MACType.normal:
        return null;
      case MACType.unknown:
        return 'Unknown';
      case MACType.invalid:
        return 'Invalid MAC Format';
    }
  }

  /// Format a normalized MAC address with colons.
  static String formatWithColons(String normalizedMac) {
    if (normalizedMac.length != 12) {
      return normalizedMac;
    }
    return '${normalizedMac.substring(0, 2)}:${normalizedMac.substring(2, 4)}:'
        '${normalizedMac.substring(4, 6)}:${normalizedMac.substring(6, 8)}:'
        '${normalizedMac.substring(8, 10)}:${normalizedMac.substring(10, 12)}';
  }
}
