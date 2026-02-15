import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_registration_state.dart'
    show DeviceMatchStatus;

export 'package:rgnets_fdk/features/scanner/domain/entities/device_registration_state.dart'
    show DeviceMatchStatus;

part 'scanner_state.freezed.dart';

/// Scanner operating modes (like AT&T app).
enum ScanMode {
  /// Auto-detect device type from serial pattern.
  auto,

  /// RxG credentials QR code.
  rxg,

  /// Access Point (1K9/1M3/1HN/C0C serials).
  accessPoint,

  /// ONT device (ALCL serials).
  ont,

  /// Network Switch (LL serials).
  switchDevice,
}

/// Scanner UI states.
enum ScannerUIState {
  /// Initial state, ready to scan.
  idle,

  /// Camera active, scanning for barcodes.
  scanning,

  /// Processing scanned data.
  processing,

  /// Validating against existing devices.
  validating,

  /// Scan data complete and validated.
  success,

  /// Error occurred.
  error,

  /// Showing popup/dialog (registration, room picker).
  popup,
}

/// Individual scan record with timestamp for accumulation window.
@freezed
class ScanRecord with _$ScanRecord {
  const factory ScanRecord({
    required String value,
    required DateTime scannedAt,
    String? fieldType,
  }) = _ScanRecord;

  const ScanRecord._();

  /// Check if record is within the accumulation window.
  bool isWithinWindow(Duration window) {
    return DateTime.now().difference(scannedAt) <= window;
  }
}

/// Accumulated scan data for a device.
@freezed
class AccumulatedScanData with _$AccumulatedScanData {
  const factory AccumulatedScanData({
    @Default('') String mac,
    @Default('') String serialNumber,
    @Default('') String partNumber,
    @Default('') String model,
    @Default(false) bool hasValidSerial,
    @Default([]) List<ScanRecord> scanHistory,
  }) = _AccumulatedScanData;

  const AccumulatedScanData._();

  /// Check if data is complete based on device type.
  bool isCompleteFor(ScanMode mode) {
    switch (mode) {
      case ScanMode.ont:
        // ONT requires: MAC + ALCL Serial + Part Number
        return mac.isNotEmpty &&
            serialNumber.isNotEmpty &&
            partNumber.isNotEmpty &&
            hasValidSerial;
      case ScanMode.accessPoint:
        // AP requires: MAC + AP Serial (1K9/1M3/1HN)
        return mac.isNotEmpty && serialNumber.isNotEmpty && hasValidSerial;
      case ScanMode.switchDevice:
        // Switch requires: MAC + LL Serial
        return mac.isNotEmpty && serialNumber.isNotEmpty && hasValidSerial;
      case ScanMode.rxg:
      case ScanMode.auto:
        return false;
    }
  }

  /// Get list of missing fields for display.
  List<String> getMissingFields(ScanMode mode) {
    final missing = <String>[];

    if (mac.isEmpty) {
      missing.add('MAC Address');
    }

    switch (mode) {
      case ScanMode.ont:
        if (serialNumber.isEmpty || !hasValidSerial) {
          missing.add('Serial Number (ALCL)');
        }
        if (partNumber.isEmpty) {
          missing.add('Part Number');
        }
      case ScanMode.accessPoint:
        if (serialNumber.isEmpty || !hasValidSerial) {
          missing.add('Serial Number (1K9/1M3/1HN/C0C)');
        }
      case ScanMode.switchDevice:
        if (serialNumber.isEmpty || !hasValidSerial) {
          missing.add('Serial Number (LL)');
        }
      case ScanMode.rxg:
      case ScanMode.auto:
        break;
    }

    return missing;
  }

  /// Get list of collected fields for display.
  List<String> getCollectedFields(ScanMode mode) {
    final collected = <String>[];

    if (mac.isNotEmpty) {
      collected.add('MAC Address');
    }

    switch (mode) {
      case ScanMode.ont:
        if (serialNumber.isNotEmpty && hasValidSerial) {
          collected.add('Serial Number');
        }
        if (partNumber.isNotEmpty) {
          collected.add('Part Number');
        }
      case ScanMode.accessPoint:
      case ScanMode.switchDevice:
        if (serialNumber.isNotEmpty && hasValidSerial) {
          collected.add('Serial Number');
        }
      case ScanMode.rxg:
      case ScanMode.auto:
        break;
    }

    return collected;
  }
}

/// RxG credentials from QR code.
@freezed
class RxgCredentials with _$RxgCredentials {
  const factory RxgCredentials({
    required String fqdn,
    required String login,
    required String apiKey,
  }) = _RxgCredentials;

  const RxgCredentials._();

  bool get isValid => fqdn.isNotEmpty && login.isNotEmpty && apiKey.isNotEmpty;
}

/// Main scanner state.
@freezed
class ScannerState with _$ScannerState {
  const factory ScannerState({
    /// Current scan mode.
    @Default(ScanMode.auto) ScanMode scanMode,

    /// Current UI state.
    @Default(ScannerUIState.idle) ScannerUIState uiState,

    /// Whether mode was auto-locked from auto mode.
    @Default(false) bool isAutoLocked,

    /// Whether mode was auto-reverted back to auto.
    @Default(false) bool wasAutoReverted,

    /// Accumulated scan data for current session.
    @Default(AccumulatedScanData()) AccumulatedScanData scanData,

    /// Last time a valid serial was detected (for auto-revert).
    DateTime? lastSerialSeenAt,

    /// RxG credentials if scanning RxG QR.
    RxgCredentials? rxgCredentials,

    /// Error message if any.
    String? errorMessage,

    /// Whether registration popup is showing.
    @Default(false) bool isPopupShowing,

    /// Whether registration is in progress.
    @Default(false) bool isRegistrationInProgress,

    /// Selected room ID for registration.
    int? selectedRoomId,

    /// Selected room number/name for display.
    String? selectedRoomNumber,

    /// Matched device ID if existing device found.
    int? matchedDeviceId,

    /// Matched device name.
    String? matchedDeviceName,

    /// Matched device's current room ID (for move/reset detection).
    int? matchedDeviceRoomId,

    /// Matched device's current room name (for display).
    String? matchedDeviceRoomName,

    /// Device match status.
    @Default(DeviceMatchStatus.unchecked) DeviceMatchStatus matchStatus,
  }) = _ScannerState;

  const ScannerState._();

  /// Whether scan data is complete for current mode.
  bool get isScanComplete => scanData.isCompleteFor(scanMode);

  /// Get missing fields for current mode.
  List<String> get missingFields => scanData.getMissingFields(scanMode);

  /// Get collected fields for current mode.
  List<String> get collectedFields => scanData.getCollectedFields(scanMode);

  /// Whether scanner is actively scanning.
  bool get isScanning => uiState == ScannerUIState.scanning;

  /// Whether scanner can process new barcodes.
  bool get canProcessBarcode =>
      !isPopupShowing && !isRegistrationInProgress && isScanning;

  /// Whether in a device-specific mode (not auto or rxg).
  bool get isInDeviceMode =>
      scanMode == ScanMode.accessPoint ||
      scanMode == ScanMode.ont ||
      scanMode == ScanMode.switchDevice;

  /// Whether RxG credentials are complete.
  bool get hasValidRxgCredentials => rxgCredentials?.isValid ?? false;

  /// Get progress percentage (0.0 to 1.0) based on collected fields.
  double get scanProgress {
    if (scanMode == ScanMode.auto || scanMode == ScanMode.rxg) {
      return 0.0;
    }

    final total = missingFields.length + collectedFields.length;
    if (total == 0) {
      return 0.0;
    }
    return collectedFields.length / total;
  }
}

extension ScanModeX on ScanMode {
  String get displayName {
    switch (this) {
      case ScanMode.auto:
        return 'Auto Detect';
      case ScanMode.rxg:
        return 'RxG Credentials';
      case ScanMode.accessPoint:
        return 'Access Point';
      case ScanMode.ont:
        return 'ONT';
      case ScanMode.switchDevice:
        return 'Switch';
    }
  }

  String get abbreviation {
    switch (this) {
      case ScanMode.auto:
        return 'AUTO';
      case ScanMode.rxg:
        return 'RXG';
      case ScanMode.accessPoint:
        return 'AP';
      case ScanMode.ont:
        return 'ONT';
      case ScanMode.switchDevice:
        return 'SW';
    }
  }

  /// Whether this mode requires serial validation.
  bool get requiresSerial =>
      this == ScanMode.accessPoint ||
      this == ScanMode.ont ||
      this == ScanMode.switchDevice;

  /// Get the required fields for this mode.
  List<String> get requiredFields {
    switch (this) {
      case ScanMode.ont:
        return ['MAC Address', 'Serial Number (ALCL)', 'Part Number'];
      case ScanMode.accessPoint:
        return ['MAC Address', 'Serial Number (1K9/1M3/1HN/C0C)'];
      case ScanMode.switchDevice:
        return ['MAC Address', 'Serial Number (LL)'];
      case ScanMode.rxg:
        return ['QR Code'];
      case ScanMode.auto:
        return [];
    }
  }
}

extension ScannerUIStateX on ScannerUIState {
  String get displayName {
    switch (this) {
      case ScannerUIState.idle:
        return 'Ready';
      case ScannerUIState.scanning:
        return 'Scanning';
      case ScannerUIState.processing:
        return 'Processing';
      case ScannerUIState.validating:
        return 'Validating';
      case ScannerUIState.success:
        return 'Complete';
      case ScannerUIState.error:
        return 'Error';
      case ScannerUIState.popup:
        return 'Registration';
    }
  }

  bool get isActive =>
      this == ScannerUIState.scanning || this == ScannerUIState.processing;
}

extension DeviceMatchStatusX on DeviceMatchStatus {
  String get displayName {
    switch (this) {
      case DeviceMatchStatus.unchecked:
        return 'Not Checked';
      case DeviceMatchStatus.fullMatch:
        return 'Device Found';
      case DeviceMatchStatus.mismatch:
        return 'Mismatch';
      case DeviceMatchStatus.multipleMatch:
        return 'Multiple Matches';
      case DeviceMatchStatus.noMatch:
        return 'New Device';
    }
  }

  bool get isConflict =>
      this == DeviceMatchStatus.mismatch ||
      this == DeviceMatchStatus.multipleMatch;
}
