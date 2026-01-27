import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/scanner/data/services/scanner_validation_service.dart';
import 'package:rgnets_fdk/features/scanner/data/utils/mac_normalizer.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_registration_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/value_objects/serial_patterns.dart';

part 'scanner_notifier_v2.g.dart';

/// New scanner notifier using freezed ScannerState with auto-detection support.
///
/// This replaces the old sealed-class based ScannerNotifier with a more
/// feature-rich implementation matching the ATT-FE-Tool pattern.
@Riverpod(keepAlive: true)
class ScannerNotifierV2 extends _$ScannerNotifierV2 {
  static const String _tag = 'ScannerNotifierV2';

  @override
  ScannerState build() {
    LoggerService.debug('Building initial scanner state', tag: _tag);
    return const ScannerState();
  }

  /// Set the scan mode (auto, accessPoint, ont, switchDevice, rxg).
  void setScanMode(ScanMode mode) {
    LoggerService.debug('Setting scan mode: ${mode.displayName}', tag: _tag);

    // Clear scan data when mode changes (except from auto to a locked mode)
    if (state.scanMode != ScanMode.auto || mode == ScanMode.auto) {
      state = state.copyWith(
        scanMode: mode,
        scanData: const AccumulatedScanData(),
        isAutoLocked: false,
        wasAutoReverted: false,
        lastSerialSeenAt: null,
      );
    } else {
      state = state.copyWith(scanMode: mode);
    }
  }

  /// Process a scanned barcode value.
  ///
  /// Handles auto-detection of device type from serial patterns,
  /// MAC address detection, and accumulates scan data.
  void processBarcode(String barcode) {
    if (!state.canProcessBarcode && state.uiState != ScannerUIState.idle) {
      LoggerService.debug('Cannot process barcode in current state', tag: _tag);
      return;
    }

    final value = barcode.trim();
    if (value.isEmpty) return;

    LoggerService.debug('Processing barcode: $value', tag: _tag);

    // Try to detect device type from serial pattern
    final detectedType = ScannerValidationService.detectDeviceTypeFromBarcode(value);

    if (detectedType != null) {
      _processSerial(value, detectedType);
      return;
    }

    // Check if it's a MAC address
    if (_isMacAddress(value)) {
      _processMacAddress(value);
      return;
    }

    // Check for part number pattern (ONT)
    if (_isPartNumber(value)) {
      _processPartNumber(value);
      return;
    }

    LoggerService.debug('Barcode did not match any known pattern: $value', tag: _tag);
  }

  /// Process a serial number barcode.
  void _processSerial(String serial, DeviceTypeFromSerial detectedType) {
    final upperSerial = serial.toUpperCase();
    LoggerService.debug('Processing serial: $upperSerial (type: ${detectedType.displayName})', tag: _tag);

    // If in auto mode, lock to detected type
    if (state.scanMode == ScanMode.auto) {
      final newMode = _deviceTypeToScanMode(detectedType);
      LoggerService.debug('Auto-locking to mode: ${newMode.displayName}', tag: _tag);

      state = state.copyWith(
        scanMode: newMode,
        isAutoLocked: true,
        lastSerialSeenAt: DateTime.now(),
        scanData: state.scanData.copyWith(
          serialNumber: upperSerial,
          hasValidSerial: true,
          scanHistory: [
            ...state.scanData.scanHistory,
            ScanRecord(value: upperSerial, scannedAt: DateTime.now(), fieldType: 'serial'),
          ],
        ),
      );
      // Check completion after auto-locking (we may already have MAC)
      _checkCompletion();
      return;
    }

    // Validate serial matches current mode
    if (!_isValidSerialForMode(upperSerial, state.scanMode)) {
      LoggerService.warning(
        'Serial $upperSerial rejected - wrong type for ${state.scanMode.displayName}',
        tag: _tag,
      );
      return;
    }

    state = state.copyWith(
      lastSerialSeenAt: DateTime.now(),
      scanData: state.scanData.copyWith(
        serialNumber: upperSerial,
        hasValidSerial: true,
        scanHistory: [
          ...state.scanData.scanHistory,
          ScanRecord(value: upperSerial, scannedAt: DateTime.now(), fieldType: 'serial'),
        ],
      ),
    );

    _checkCompletion();
  }

  /// Process a MAC address barcode.
  void _processMacAddress(String mac) {
    final normalized = MACNormalizer.tryNormalize(mac);
    if (normalized == null) {
      LoggerService.warning('Failed to normalize MAC: $mac', tag: _tag);
      return;
    }

    LoggerService.debug('Processing MAC: $normalized', tag: _tag);

    state = state.copyWith(
      scanData: state.scanData.copyWith(
        mac: normalized,
        scanHistory: [
          ...state.scanData.scanHistory,
          ScanRecord(value: normalized, scannedAt: DateTime.now(), fieldType: 'mac'),
        ],
      ),
    );

    _checkCompletion();
  }

  /// Process a part number barcode (for ONT).
  void _processPartNumber(String partNumber) {
    LoggerService.debug('Processing part number: $partNumber', tag: _tag);

    state = state.copyWith(
      scanData: state.scanData.copyWith(
        partNumber: partNumber,
        scanHistory: [
          ...state.scanData.scanHistory,
          ScanRecord(value: partNumber, scannedAt: DateTime.now(), fieldType: 'partNumber'),
        ],
      ),
    );

    _checkCompletion();
  }

  /// Check if scan data is complete and update UI state.
  void _checkCompletion() {
    if (state.isScanComplete) {
      LoggerService.debug('Scan data complete!', tag: _tag);
      state = state.copyWith(uiState: ScannerUIState.success);
    }
  }

  /// Start scanning (transition to scanning UI state).
  void startScanning() {
    LoggerService.debug('Starting scanning', tag: _tag);
    state = state.copyWith(uiState: ScannerUIState.scanning);
  }

  /// Stop scanning (transition to idle UI state).
  void stopScanning() {
    LoggerService.debug('Stopping scanning', tag: _tag);
    state = state.copyWith(uiState: ScannerUIState.idle);
  }

  /// Show the registration popup.
  void showRegistrationPopup() {
    LoggerService.debug('Showing registration popup', tag: _tag);
    state = state.copyWith(
      isPopupShowing: true,
      uiState: ScannerUIState.popup,
    );
  }

  /// Hide the registration popup.
  void hideRegistrationPopup() {
    LoggerService.debug('Hiding registration popup', tag: _tag);
    state = state.copyWith(
      isPopupShowing: false,
      uiState: ScannerUIState.idle,
    );
  }

  /// Set registration in progress flag.
  void setRegistrationInProgress(bool inProgress) {
    LoggerService.debug('Setting registration in progress: $inProgress', tag: _tag);
    state = state.copyWith(isRegistrationInProgress: inProgress);
  }

  /// Set room selection for registration.
  void setRoomSelection(int? roomId, String? roomNumber) {
    LoggerService.debug('Setting room selection: $roomId ($roomNumber)', tag: _tag);
    state = state.copyWith(
      selectedRoomId: roomId,
      selectedRoomNumber: roomNumber,
    );
  }

  /// Set device match status from registration check.
  void setDeviceMatchStatus({
    required DeviceMatchStatus status,
    int? deviceId,
    String? deviceName,
    int? deviceRoomId,
    String? deviceRoomName,
  }) {
    LoggerService.debug('Setting device match status: ${status.displayName}', tag: _tag);
    state = state.copyWith(
      matchStatus: status,
      matchedDeviceId: deviceId,
      matchedDeviceName: deviceName,
      matchedDeviceRoomId: deviceRoomId,
      matchedDeviceRoomName: deviceRoomName,
    );
  }

  /// Clear all accumulated scan data and reset mode to auto.
  void clearScanData() {
    LoggerService.debug('Clearing scan data and resetting to auto mode', tag: _tag);
    state = state.copyWith(
      scanData: const AccumulatedScanData(),
      selectedRoomId: null,
      selectedRoomNumber: null,
      matchStatus: DeviceMatchStatus.unchecked,
      matchedDeviceId: null,
      matchedDeviceName: null,
      matchedDeviceRoomId: null,
      matchedDeviceRoomName: null,
      isAutoLocked: false,
      wasAutoReverted: false,
      lastSerialSeenAt: null,
      scanMode: ScanMode.auto,
    );
  }

  /// Reset the scanner to initial state.
  void reset() {
    LoggerService.debug('Resetting scanner to initial state', tag: _tag);
    state = const ScannerState();
  }

  // Helper methods

  bool _isMacAddress(String value) {
    return MACNormalizer.tryNormalize(value) != null;
  }

  bool _isPartNumber(String value) {
    // Part number patterns: starts with 1P, 23S, or S prefix, or is alphanumeric with specific format
    final v = value.toUpperCase();
    if (v.startsWith('1P') || v.startsWith('23S') || v.startsWith('S')) {
      return true;
    }
    // Also check for standard part number format (8-12 alphanumeric chars ending in letter)
    final pnRegex = RegExp(r'^[A-Z0-9]{8,12}[A-Z]$');
    return pnRegex.hasMatch(v);
  }

  bool _isValidSerialForMode(String serial, ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return SerialPatterns.isAPSerial(serial);
      case ScanMode.ont:
        return SerialPatterns.isONTSerial(serial);
      case ScanMode.switchDevice:
        return SerialPatterns.isSwitchSerial(serial);
      case ScanMode.auto:
      case ScanMode.rxg:
        return true; // Accept any in these modes
    }
  }

  ScanMode _deviceTypeToScanMode(DeviceTypeFromSerial type) {
    switch (type) {
      case DeviceTypeFromSerial.accessPoint:
        return ScanMode.accessPoint;
      case DeviceTypeFromSerial.ont:
        return ScanMode.ont;
      case DeviceTypeFromSerial.switchDevice:
        return ScanMode.switchDevice;
    }
  }
}
