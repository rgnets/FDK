import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/scanner/data/services/scanner_validation_service.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/value_objects/serial_patterns.dart';

part 'scanner_notifier.g.dart';

/// Scanner notifier with AT&T-style accumulation and auto-detection.
///
/// Key features:
/// - Auto-detect device type from serial patterns (AP/ONT/Switch)
/// - 6-second accumulation window for multi-barcode assembly
/// - 8-second auto-revert to Auto mode after inactivity
/// - Timer management with pause/resume for popups
@Riverpod(keepAlive: true)
class ScannerNotifier extends _$ScannerNotifier {
  static const String _tag = 'ScannerNotifier';

  // Timer configuration (like AT&T app)
  static const _accumulationWindow = Duration(seconds: 6);
  static const _autoRevertDuration = Duration(seconds: 8);
  static const _timerInterval = Duration(milliseconds: 500);
  static const _scanDebounce = Duration(seconds: 2);

  Timer? _expirationTimer;
  bool _isTimerPaused = false;
  DateTime? _lastScanTime;

  @override
  ScannerState build() {
    // Clean up timers on dispose
    ref.onDispose(() {
      _expirationTimer?.cancel();
      _expirationTimer = null;
    });

    return const ScannerState();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────────

  /// Start scanning in the current mode.
  void startScanning() {
    LoggerService.info('Starting scanner', tag: _tag);
    state = state.copyWith(
      uiState: ScannerUIState.scanning,
      errorMessage: null,
    );
    _startExpirationTimer();
  }

  /// Stop scanning and reset to idle.
  void stopScanning() {
    LoggerService.info('Stopping scanner', tag: _tag);
    _cancelExpirationTimer();
    state = state.copyWith(
      uiState: ScannerUIState.idle,
    );
  }

  /// Set the scan mode manually.
  void setScanMode(ScanMode mode) {
    LoggerService.info('Setting scan mode to ${mode.name}', tag: _tag);

    // Clear data when changing modes
    state = state.copyWith(
      scanMode: mode,
      isAutoLocked: false,
      wasAutoReverted: false,
      scanData: const AccumulatedScanData(),
      rxgCredentials: null,
      errorMessage: null,
      matchStatus: DeviceMatchStatus.unchecked,
      matchedDeviceId: null,
      matchedDeviceName: null,
      matchedDeviceRoomId: null,
      matchedDeviceRoomName: null,
    );
  }

  /// Lock to a specific mode from auto-detection.
  void lockModeFromAuto(ScanMode mode) {
    if (state.scanMode != ScanMode.auto) {
      return;
    }

    LoggerService.info('Auto-locking to ${mode.name} from serial detection', tag: _tag);

    state = state.copyWith(
      scanMode: mode,
      isAutoLocked: true,
      wasAutoReverted: false,
      lastSerialSeenAt: DateTime.now(),
    );
  }

  /// Process a scanned barcode.
  void processBarcode(String barcode) {
    if (!state.canProcessBarcode) {
      LoggerService.debug(
        'Cannot process barcode - popup: ${state.isPopupShowing}, registering: ${state.isRegistrationInProgress}',
        tag: _tag,
      );
      return;
    }

    // Debounce rapid scans
    if (_lastScanTime != null) {
      final timeSinceLastScan = DateTime.now().difference(_lastScanTime!);
      if (timeSinceLastScan < _scanDebounce) {
        LoggerService.debug('Debouncing scan (${timeSinceLastScan.inMilliseconds}ms)', tag: _tag);
        return;
      }
    }
    _lastScanTime = DateTime.now();

    LoggerService.debug('Processing barcode: ${_truncateForLog(barcode)}', tag: _tag);

    // Handle RxG mode separately
    if (state.scanMode == ScanMode.rxg) {
      _processRxgBarcode(barcode);
      return;
    }

    // Auto-detection: try to detect device type from serial
    if (state.scanMode == ScanMode.auto) {
      final detectedType = SerialPatterns.detectDeviceType(barcode);
      if (detectedType != null) {
        LoggerService.info('Detected device type: ${detectedType.name}', tag: _tag);
        lockModeFromAuto(_toScanMode(detectedType));
        // Continue processing the barcode in the new mode
      }
    }

    // Process based on current mode
    switch (state.scanMode) {
      case ScanMode.accessPoint:
        _processAPBarcode(barcode);
      case ScanMode.ont:
        _processONTBarcode(barcode);
      case ScanMode.switchDevice:
        _processSwitchBarcode(barcode);
      case ScanMode.auto:
        // Still in auto mode, just add to history for potential accumulation
        _addToScanHistory(barcode);
      case ScanMode.rxg:
        // Already handled above
        break;
    }

    // Check if scan is complete
    if (state.isScanComplete) {
      LoggerService.info('Scan complete!', tag: _tag);
      state = state.copyWith(uiState: ScannerUIState.success);
    }
  }

  /// Set room selection for registration.
  void setRoomSelection(int roomId, String roomNumber) {
    state = state.copyWith(
      selectedRoomId: roomId,
      selectedRoomNumber: roomNumber,
    );
  }

  /// Set device match status after checking.
  void setDeviceMatchStatus({
    required DeviceMatchStatus status,
    int? deviceId,
    String? deviceName,
    int? deviceRoomId,
    String? deviceRoomName,
  }) {
    state = state.copyWith(
      matchStatus: status,
      matchedDeviceId: deviceId,
      matchedDeviceName: deviceName,
      matchedDeviceRoomId: deviceRoomId,
      matchedDeviceRoomName: deviceRoomName,
    );
  }

  /// Show registration popup (pauses expiration timer).
  void showRegistrationPopup() {
    LoggerService.debug('Showing registration popup', tag: _tag);
    pauseExpirationTimer();
    state = state.copyWith(
      isPopupShowing: true,
      uiState: ScannerUIState.popup,
    );
  }

  /// Hide registration popup (resumes expiration timer).
  void hideRegistrationPopup() {
    LoggerService.debug('Hiding registration popup', tag: _tag);
    state = state.copyWith(
      isPopupShowing: false,
      uiState: ScannerUIState.scanning,
    );
    resumeExpirationTimer();
  }

  /// Set registration in progress.
  void setRegistrationInProgress(bool inProgress) {
    state = state.copyWith(isRegistrationInProgress: inProgress);
  }

  /// Clear scan data and reset to current mode.
  void clearScanData() {
    LoggerService.debug('Clearing scan data', tag: _tag);
    state = state.copyWith(
      scanData: const AccumulatedScanData(),
      rxgCredentials: null,
      errorMessage: null,
      matchStatus: DeviceMatchStatus.unchecked,
      matchedDeviceId: null,
      matchedDeviceName: null,
      matchedDeviceRoomId: null,
      matchedDeviceRoomName: null,
      selectedRoomId: null,
      selectedRoomNumber: null,
    );
  }

  /// Reset scanner to initial state.
  void reset() {
    LoggerService.info('Resetting scanner', tag: _tag);
    _cancelExpirationTimer();
    state = const ScannerState();
  }

  /// Consume the auto-reverted flag (one-shot).
  bool takeAutoRevertedFlag() {
    if (state.wasAutoReverted) {
      state = state.copyWith(wasAutoReverted: false);
      return true;
    }
    return false;
  }

  /// Pause expiration timer (for popups).
  void pauseExpirationTimer() {
    _isTimerPaused = true;
    LoggerService.debug('Expiration timer paused', tag: _tag);
  }

  /// Resume expiration timer.
  void resumeExpirationTimer() {
    _isTimerPaused = false;
    LoggerService.debug('Expiration timer resumed', tag: _tag);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timer Management
  // ─────────────────────────────────────────────────────────────────────────

  void _startExpirationTimer() {
    _cancelExpirationTimer();
    _expirationTimer = Timer.periodic(_timerInterval, (_) {
      if (!_isTimerPaused) {
        _checkAndExpireData();
      }
    });
  }

  void _cancelExpirationTimer() {
    _expirationTimer?.cancel();
    _expirationTimer = null;
  }

  /// Called periodically to expire old scan records and check auto-revert.
  void _checkAndExpireData() {
    final now = DateTime.now();
    final cutoff = now.subtract(_accumulationWindow);

    // Get current scan history
    final currentHistory = state.scanData.scanHistory;
    if (currentHistory.isEmpty) {
      _checkAutoRevert(now);
      return;
    }

    // Remove expired records
    final validRecords = currentHistory.where((r) => r.scannedAt.isAfter(cutoff)).toList();

    if (validRecords.length != currentHistory.length) {
      LoggerService.debug(
        'Expired ${currentHistory.length - validRecords.length} scan records',
        tag: _tag,
      );

      // Re-accumulate from valid records
      _reaccumulateFromHistory(validRecords);
    }

    // Check auto-revert
    _checkAutoRevert(now);
  }

  /// Check if we should auto-revert to Auto mode.
  void _checkAutoRevert(DateTime now) {
    // Don't revert if already in auto mode
    if (state.scanMode == ScanMode.auto) {
      return;
    }

    // Don't revert during popup or registration
    if (state.isPopupShowing || state.isRegistrationInProgress) {
      return;
    }

    // Don't revert if we have complete data
    if (state.isScanComplete) {
      return;
    }

    // Check time since last serial was seen
    final lastSerial = state.lastSerialSeenAt;
    if (lastSerial == null) {
      return;
    }

    final timeSinceSerial = now.difference(lastSerial);
    if (timeSinceSerial > _autoRevertDuration) {
      LoggerService.info(
        'Auto-reverting to Auto mode (${timeSinceSerial.inSeconds}s since last serial)',
        tag: _tag,
      );

      state = state.copyWith(
        scanMode: ScanMode.auto,
        isAutoLocked: false,
        wasAutoReverted: true,
        scanData: const AccumulatedScanData(),
        lastSerialSeenAt: null,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Barcode Processing
  // ─────────────────────────────────────────────────────────────────────────

  void _processRxgBarcode(String barcode) {
    final credentials = ScannerValidationService.parseRxgQRCode(barcode);
    if (credentials != null) {
      LoggerService.info('Parsed RxG credentials', tag: _tag);
      state = state.copyWith(
        rxgCredentials: RxgCredentials(
          fqdn: credentials['fqdn']!,
          login: credentials['login']!,
          apiKey: credentials['api_key']!,
        ),
        uiState: ScannerUIState.success,
      );
    } else {
      LoggerService.warning('Failed to parse RxG QR code', tag: _tag);
    }
  }

  void _processAPBarcode(String barcode) {
    // Add to history
    _addToScanHistory(barcode);

    // Parse all accumulated barcodes
    final barcodes = state.scanData.scanHistory.map((r) => r.value).toList();
    final parsed = ScannerValidationService.parseAPBarcodes(barcodes);

    // Update state with parsed data
    _updateScanData(
      mac: parsed.mac,
      serialNumber: parsed.serialNumber,
      hasValidSerial: parsed.isComplete,
    );

    // Note serial seen if we got a valid one
    if (parsed.serialNumber.isNotEmpty) {
      _noteSerialSeen();
    }
  }

  void _processONTBarcode(String barcode) {
    // Add to history
    _addToScanHistory(barcode);

    // Parse all accumulated barcodes
    final barcodes = state.scanData.scanHistory.map((r) => r.value).toList();
    final parsed = ScannerValidationService.parseONTBarcodes(barcodes);

    // Update state with parsed data
    _updateScanData(
      mac: parsed.mac,
      serialNumber: parsed.serialNumber,
      partNumber: parsed.partNumber ?? '',
      hasValidSerial: parsed.isComplete,
    );

    // Note serial seen if we got a valid one
    if (parsed.serialNumber.isNotEmpty) {
      _noteSerialSeen();
    }
  }

  void _processSwitchBarcode(String barcode) {
    // Add to history
    _addToScanHistory(barcode);

    // Parse all accumulated barcodes
    final barcodes = state.scanData.scanHistory.map((r) => r.value).toList();
    final parsed = ScannerValidationService.parseSwitchBarcodes(barcodes);

    // Update state with parsed data
    _updateScanData(
      mac: parsed.mac,
      serialNumber: parsed.serialNumber,
      model: parsed.model ?? '',
      hasValidSerial: parsed.isComplete,
    );

    // Note serial seen if we got a valid one
    if (parsed.serialNumber.isNotEmpty) {
      _noteSerialSeen();
    }
  }

  void _addToScanHistory(String barcode) {
    final record = ScanRecord(
      value: barcode.trim(),
      scannedAt: DateTime.now(),
    );

    final updatedHistory = [...state.scanData.scanHistory, record];
    state = state.copyWith(
      scanData: state.scanData.copyWith(scanHistory: updatedHistory),
    );
  }

  void _updateScanData({
    String? mac,
    String? serialNumber,
    String? partNumber,
    String? model,
    bool? hasValidSerial,
  }) {
    // Only update non-empty values (first wins strategy)
    state = state.copyWith(
      scanData: state.scanData.copyWith(
        mac: (mac?.isNotEmpty ?? false) && state.scanData.mac.isEmpty
            ? mac!
            : state.scanData.mac,
        serialNumber: (serialNumber?.isNotEmpty ?? false) && state.scanData.serialNumber.isEmpty
            ? serialNumber!
            : state.scanData.serialNumber,
        partNumber: (partNumber?.isNotEmpty ?? false) && state.scanData.partNumber.isEmpty
            ? partNumber!
            : state.scanData.partNumber,
        model: (model?.isNotEmpty ?? false) && state.scanData.model.isEmpty
            ? model!
            : state.scanData.model,
        hasValidSerial: hasValidSerial ?? state.scanData.hasValidSerial,
      ),
    );
  }

  void _noteSerialSeen() {
    state = state.copyWith(lastSerialSeenAt: DateTime.now());
  }

  void _reaccumulateFromHistory(List<ScanRecord> validRecords) {
    // Clear current accumulated data but keep history
    state = state.copyWith(
      scanData: AccumulatedScanData(scanHistory: validRecords),
    );

    // Re-process all valid barcodes
    final barcodes = validRecords.map((r) => r.value).toList();

    switch (state.scanMode) {
      case ScanMode.accessPoint:
        final parsed = ScannerValidationService.parseAPBarcodes(barcodes);
        _updateScanData(
          mac: parsed.mac,
          serialNumber: parsed.serialNumber,
          hasValidSerial: parsed.isComplete,
        );
      case ScanMode.ont:
        final parsed = ScannerValidationService.parseONTBarcodes(barcodes);
        _updateScanData(
          mac: parsed.mac,
          serialNumber: parsed.serialNumber,
          partNumber: parsed.partNumber ?? '',
          hasValidSerial: parsed.isComplete,
        );
      case ScanMode.switchDevice:
        final parsed = ScannerValidationService.parseSwitchBarcodes(barcodes);
        _updateScanData(
          mac: parsed.mac,
          serialNumber: parsed.serialNumber,
          model: parsed.model ?? '',
          hasValidSerial: parsed.isComplete,
        );
      case ScanMode.auto:
      case ScanMode.rxg:
        // Nothing to re-accumulate
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  ScanMode _toScanMode(DeviceTypeFromSerial type) {
    switch (type) {
      case DeviceTypeFromSerial.accessPoint:
        return ScanMode.accessPoint;
      case DeviceTypeFromSerial.ont:
        return ScanMode.ont;
      case DeviceTypeFromSerial.switchDevice:
        return ScanMode.switchDevice;
    }
  }

  String _truncateForLog(String value) {
    if (value.length <= 20) {
      return value;
    }
    return '${value.substring(0, 17)}...';
  }
}
