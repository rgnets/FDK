import 'package:flutter/material.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';

/// Shared utility functions for scanner UI components.
class ScannerUtils {
  ScannerUtils._();

  /// Formats a 12-character MAC address with colons.
  ///
  /// Example: "AABBCCDDEEFF" -> "AA:BB:CC:DD:EE:FF"
  static String formatMac(String mac) {
    if (mac.length != 12) {
      return mac;
    }
    return '${mac.substring(0, 2)}:${mac.substring(2, 4)}:'
        '${mac.substring(4, 6)}:${mac.substring(6, 8)}:'
        '${mac.substring(8, 10)}:${mac.substring(10, 12)}';
  }

  /// Returns the appropriate icon for a scan mode.
  static IconData getModeIcon(ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return Icons.wifi;
      case ScanMode.ont:
        return Icons.router;
      case ScanMode.switchDevice:
        return Icons.lan;
      case ScanMode.rxg:
        return Icons.qr_code;
      case ScanMode.auto:
        return Icons.auto_awesome;
    }
  }

  /// Returns display-friendly device type name for a scan mode.
  static String getDeviceTypeName(ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return 'AP';
      case ScanMode.ont:
        return 'ONT';
      case ScanMode.switchDevice:
        return 'Switch';
      case ScanMode.auto:
      case ScanMode.rxg:
        return 'Device';
    }
  }

  /// Truncates a string for logging purposes.
  static String truncateForLog(String value, {int maxLength = 20}) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength - 3)}...';
  }
}
