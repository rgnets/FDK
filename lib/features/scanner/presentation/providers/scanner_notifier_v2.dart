import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/scanner/data/services/scanner_validation_service.dart';
import 'package:rgnets_fdk/features/scanner/data/utils/mac_database.dart';
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
    // Kick off the OUI database load so vendor-aware scanning (e.g. Ruckus)
    // can identify the MAC's manufacturer. Idempotent via internal completer.
    // Errors are tolerated (e.g. in unit tests where ServicesBinding isn't up).
    loadMACDatabase().catchError((Object e) {
      LoggerService.warning('MAC database load skipped: $e', tag: _tag);
    });
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

  /// Process all barcodes from a single camera frame as a batch.
  ///
  /// This is critical for ONT scanning where the part number (e.g. 3FE47273AAAA)
  /// is 12 hex chars and would be misclassified as a MAC if processed individually.
  /// Batch processing via parseONTBarcodes fills the MAC slot first, then subsequent
  /// 12-hex values fall through to part number detection.
  void processBarcodeFrame(List<String> barcodes) {
    if (!state.canProcessBarcode && state.uiState != ScannerUIState.idle) {
      return;
    }

    final values = barcodes.map((b) => b.trim()).where((b) => b.isNotEmpty).toList();
    if (values.isEmpty) return;

    LoggerService.debug('Processing frame with ${values.length} barcodes: $values', tag: _tag);

    // Determine device type: use current mode if already locked, otherwise auto-detect
    DeviceTypeFromSerial? detectedType;
    if (state.isAutoLocked || state.isInDeviceMode) {
      detectedType = _scanModeToDeviceType(state.scanMode);
    } else {
      // Auto mode: try to detect device type from any serial in the batch
      for (final value in values) {
        detectedType = ScannerValidationService.detectDeviceTypeFromBarcode(value);
        if (detectedType != null) break;
      }
    }

    // If we detected a device type, use batch parsing (critical for ONT)
    if (detectedType != null) {
      final result = ScannerValidationService.parseBarcodesForType(
        values,
        detectedType,
        existingSerial: state.scanData.serialNumber,
      );
      _applyBatchResult(result, detectedType);
      return;
    }

    // No device type detected — process individually as fallback
    for (final value in values) {
      processBarcode(value);
    }
  }

  /// Process a single scanned barcode value.
  ///
  /// Used as fallback when batch processing can't determine device type,
  /// and for manual barcode entry.
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

    // Ruckus T-series AP serials are 12 purely-numeric digits (e.g.
    // 422720000021) that parse as valid hex and otherwise look just like a
    // MAC. The OUI database disambiguates: a real Ruckus MAC's OUI is
    // registered to Ruckus, a numeric AP serial's prefix is not. In
    // AP/auto modes any 12-char hex value with an unknown OUI must NEVER
    // fill the MAC slot — it's a Ruckus serial (or noise). Either claim
    // the serial slot the first time we see it or no-op on a re-scan; the
    // batch parser uses the same OUI test (scanner_validation_service.dart:229).
    //
    // Gate on `macDatabase.isLoaded`: until the OUI table is in memory
    // every value reads as "unknown OUI", which would mis-route real MACs
    // into the serial slot during the ~500 ms DB-load window. The camera
    // re-fires every frame, so deferring here just costs one frame.
    if ((state.scanMode == ScanMode.accessPoint ||
            state.scanMode == ScanMode.auto) &&
        value.length == 12 &&
        _isMacAddress(value) &&
        macDatabase.isLoaded &&
        !ScannerValidationService.isKnownManufacturer(value)) {
      if (state.scanData.serialNumber.isEmpty) {
        _acceptVendorApSerial(value);
      }
      return;
    }

    // Check if it's a MAC address
    if (_isMacAddress(value)) {
      _processMacAddress(value);
      return;
    }

    // Check for part number pattern
    if (_isPartNumber(value)) {
      _processPartNumber(value);
      return;
    }

    // Vendor-aware fallback: Ruckus AP serials don't share the AT&T
    // 1K9/1M3/1HN prefix scheme. If we already have a Ruckus MAC and the
    // value looks like a generic AP serial, accept it.
    if ((state.scanMode == ScanMode.accessPoint ||
            state.scanMode == ScanMode.auto) &&
        state.scanData.mac.isNotEmpty &&
        _isRuckusMac(state.scanData.mac) &&
        _looksLikeGenericApSerial(value)) {
      _acceptVendorApSerial(value);
      return;
    }

    LoggerService.debug('Barcode did not match any known pattern: $value', tag: _tag);
  }

  /// Accept a vendor-relaxed AP serial (e.g. Ruckus, which doesn't use
  /// 1K9/1M3/1HN prefixes). Mirrors the auto-lock behavior of [_processSerial].
  void _acceptVendorApSerial(String serial) {
    final upper = serial.toUpperCase();
    LoggerService.debug('Accepting vendor-relaxed AP serial: $upper', tag: _tag);

    final history = [
      ...state.scanData.scanHistory,
      ScanRecord(value: upper, scannedAt: DateTime.now(), fieldType: 'serial'),
    ];

    if (state.scanMode == ScanMode.auto) {
      state = state.copyWith(
        scanMode: ScanMode.accessPoint,
        isAutoLocked: true,
        lastSerialSeenAt: DateTime.now(),
        scanData: state.scanData.copyWith(
          serialNumber: upper,
          hasValidSerial: true,
          scanHistory: history,
        ),
      );
    } else {
      state = state.copyWith(
        lastSerialSeenAt: DateTime.now(),
        scanData: state.scanData.copyWith(
          serialNumber: upper,
          hasValidSerial: true,
          scanHistory: history,
        ),
      );
    }

    _checkCompletion();
  }

  /// Whether the given MAC's OUI resolves to Ruckus Wireless.
  bool _isRuckusMac(String mac) {
    return ScannerValidationService.getManufacturer(mac)
        .toLowerCase()
        .contains('ruckus');
  }

  /// Whether a value looks like a generic AP serial: alphanumeric, 10-16
  /// chars, and not a 12-hex MAC (those go through the MAC path and are
  /// disambiguated in [_processMacAddress]).
  bool _looksLikeGenericApSerial(String value) {
    final upper = value.toUpperCase();
    if (upper.length < 10 || upper.length > 16) {
      return false;
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(upper)) {
      return false;
    }
    if (upper.length == 12 && _isMacAddress(value)) {
      return false;
    }
    return true;
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

    // Vendor-aware disambiguation: a 12-digit numeric Ruckus serial parses
    // as valid hex and otherwise looks like a MAC. If we already have a
    // Ruckus MAC and this incoming "MAC" has an unknown OUI, treat it as
    // the Ruckus serial instead of overwriting the valid MAC.
    if ((state.scanMode == ScanMode.accessPoint ||
            state.scanMode == ScanMode.auto) &&
        state.scanData.mac.isNotEmpty &&
        _isRuckusMac(state.scanData.mac) &&
        !ScannerValidationService.isKnownManufacturer(normalized)) {
      LoggerService.debug(
        'Routing $normalized to serial slot (existing MAC is Ruckus, this OUI unknown)',
        tag: _tag,
      );
      _acceptVendorApSerial(normalized);
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
      // Defensive: clear the popup flag too so a previously orphaned popup
      // state can't lock out future Register Device taps.
      isPopupShowing: false,
      isRegistrationInProgress: false,
    );
  }

  /// Reset the scanner to initial state.
  void reset() {
    LoggerService.debug('Resetting scanner to initial state', tag: _tag);
    state = const ScannerState();
  }

  /// Apply batch-parsed result from ScannerValidationService to state.
  void _applyBatchResult(ParsedDeviceData result, DeviceTypeFromSerial detectedType) {
    LoggerService.debug(
      'Batch result: MAC=${result.mac}, Serial=${result.serialNumber}, '
      'PN=${result.partNumber}, complete=${result.isComplete}',
      tag: _tag,
    );

    final now = DateTime.now();
    final newHistory = <ScanRecord>[...state.scanData.scanHistory];

    // Build updated scan data from batch result
    var newMac = state.scanData.mac;
    var newSerial = state.scanData.serialNumber;
    var newPartNumber = state.scanData.partNumber;
    var newHasValidSerial = state.scanData.hasValidSerial;

    if (result.mac.isNotEmpty && result.mac != state.scanData.mac) {
      newMac = result.mac;
      newHistory.add(ScanRecord(value: result.mac, scannedAt: now, fieldType: 'mac'));
    }
    if (result.serialNumber.isNotEmpty && result.serialNumber != state.scanData.serialNumber) {
      newSerial = result.serialNumber;
      newHasValidSerial = true;
      newHistory.add(ScanRecord(value: result.serialNumber, scannedAt: now, fieldType: 'serial'));
    }
    if (result.partNumber != null && result.partNumber!.isNotEmpty && result.partNumber != state.scanData.partNumber) {
      newPartNumber = result.partNumber!;
      newHistory.add(ScanRecord(value: result.partNumber!, scannedAt: now, fieldType: 'partNumber'));
    }

    // Auto-lock mode if in auto
    final newMode = state.scanMode == ScanMode.auto ? _deviceTypeToScanMode(detectedType) : state.scanMode;
    final autoLocked = state.scanMode == ScanMode.auto || state.isAutoLocked;

    state = state.copyWith(
      scanMode: newMode,
      isAutoLocked: autoLocked,
      lastSerialSeenAt: newSerial.isNotEmpty ? now : state.lastSerialSeenAt,
      scanData: state.scanData.copyWith(
        mac: newMac,
        serialNumber: newSerial,
        partNumber: newPartNumber,
        hasValidSerial: newHasValidSerial,
        scanHistory: newHistory,
      ),
    );

    _checkCompletion();
  }

  // Helper methods

  DeviceTypeFromSerial? _scanModeToDeviceType(ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        return DeviceTypeFromSerial.accessPoint;
      case ScanMode.ont:
        return DeviceTypeFromSerial.ont;
      case ScanMode.switchDevice:
        return DeviceTypeFromSerial.switchDevice;
      case ScanMode.auto:
      case ScanMode.rxg:
        return null;
    }
  }

  bool _isMacAddress(String value) {
    return MACNormalizer.tryNormalize(value) != null;
  }

  bool _isPartNumber(String value) {
    // Standard part number format (8-12 alphanumeric chars ending in letter)
    // Note: 1P/23S/S prefixes are ONT barcode prefixes handled by parseONTBarcodes
    final v = value.toUpperCase();
    final pnRegex = RegExp(r'^[A-Z0-9]{8,12}[A-Z]$');
    return pnRegex.hasMatch(v);
  }

  bool _isValidSerialForMode(String serial, ScanMode mode) {
    switch (mode) {
      case ScanMode.accessPoint:
        // Ruckus serials don't carry an AT&T-style prefix, so relax when
        // the captured MAC's OUI identifies Ruckus.
        if (state.scanData.mac.isNotEmpty &&
            _isRuckusMac(state.scanData.mac) &&
            _looksLikeGenericApSerial(serial)) {
          return true;
        }
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
