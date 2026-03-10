import 'package:flutter/material.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
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
  static IconData getModeIcon(ScanMode mode) => switch (mode) {
    ScanMode.accessPoint => Icons.wifi,
    ScanMode.ont => Icons.router,
    ScanMode.switchDevice => Icons.lan,
    ScanMode.rxg => Icons.qr_code,
    ScanMode.auto => Icons.auto_awesome,
  };

  /// Returns abbreviated device type name (e.g. "AP", "ONT").
  static String getDeviceTypeName(ScanMode mode) => switch (mode) {
    ScanMode.accessPoint => 'AP',
    ScanMode.ont => 'ONT',
    ScanMode.switchDevice => 'Switch',
    ScanMode.auto || ScanMode.rxg => 'Device',
  };

  /// Returns full device type name for registration context
  /// (e.g. "Access Point" instead of "AP").
  static String getFullDeviceTypeName(ScanMode mode) => switch (mode) {
    ScanMode.accessPoint => 'Access Point',
    ScanMode.ont => 'ONT',
    ScanMode.switchDevice => 'Switch',
    ScanMode.auto || ScanMode.rxg => 'Device',
  };

  /// Returns the DeviceTypes constant string for a scan mode, or null for
  /// auto/rxg.
  static String? getDeviceTypeForMode(ScanMode mode) => switch (mode) {
    ScanMode.accessPoint => DeviceTypes.accessPoint,
    ScanMode.ont => DeviceTypes.ont,
    ScanMode.switchDevice => DeviceTypes.networkSwitch,
    ScanMode.auto || ScanMode.rxg => null,
  };

  /// Converts ScanMode to the DeviceType entity enum.
  static DeviceType toDeviceType(ScanMode mode) => switch (mode) {
    ScanMode.accessPoint => DeviceType.accessPoint,
    ScanMode.ont => DeviceType.ont,
    ScanMode.switchDevice => DeviceType.switchDevice,
    ScanMode.auto || ScanMode.rxg => DeviceType.accessPoint,
  };

  /// Truncates a string for logging purposes.
  static String truncateForLog(String value, {int maxLength = 20}) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength - 3)}...';
  }
}
