import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_registration_state.freezed.dart';

/// Status of device match check against existing records.
enum DeviceMatchStatus {
  /// Device not yet checked
  unchecked,

  /// Found exact match (both MAC and serial match)
  fullMatch,

  /// Found device but MAC or serial doesn't match
  mismatch,

  /// Multiple devices match the scanned data
  multipleMatch,

  /// No existing device found with this MAC or serial
  noMatch,
}

/// Registration status for a device.
enum RegistrationStatus {
  /// Not started
  idle,

  /// Checking if device exists
  checking,

  /// Currently registering
  registering,

  /// Registration successful
  success,

  /// Registration failed
  error,
}

/// State for device registration flow.
@freezed
class DeviceRegistrationState with _$DeviceRegistrationState {
  const factory DeviceRegistrationState({
    @Default(RegistrationStatus.idle) RegistrationStatus status,
    @Default(DeviceMatchStatus.unchecked) DeviceMatchStatus matchStatus,
    String? scannedMac,
    String? scannedSerial,
    String? deviceType,
    int? matchedDeviceId,
    String? matchedDeviceName,
    MatchMismatchInfo? mismatchInfo,
    String? errorMessage,
    DateTime? registeredAt,
  }) = _DeviceRegistrationState;

  const DeviceRegistrationState._();

  bool get isIdle => status == RegistrationStatus.idle;
  bool get isChecking => status == RegistrationStatus.checking;
  bool get isRegistering => status == RegistrationStatus.registering;
  bool get isSuccess => status == RegistrationStatus.success;
  bool get isError => status == RegistrationStatus.error;
  bool get isBusy => isChecking || isRegistering;

  bool get hasFullMatch => matchStatus == DeviceMatchStatus.fullMatch;
  bool get hasMismatch => matchStatus == DeviceMatchStatus.mismatch;
  bool get hasNoMatch => matchStatus == DeviceMatchStatus.noMatch;
  bool get hasMultipleMatch => matchStatus == DeviceMatchStatus.multipleMatch;

  /// Can proceed with registration (no conflicts or user confirmed)
  bool get canRegister =>
      scannedMac != null &&
      scannedSerial != null &&
      (hasNoMatch || hasFullMatch);
}

/// Information about mismatched fields.
@freezed
class MatchMismatchInfo with _$MatchMismatchInfo {
  const factory MatchMismatchInfo({
    required List<String> mismatchedFields,
    required Map<String, String> expected,
    required Map<String, String> scanned,
  }) = _MatchMismatchInfo;

  const MatchMismatchInfo._();

  String get description {
    if (mismatchedFields.isEmpty) return '';
    return 'Mismatch in: ${mismatchedFields.join(", ")}';
  }
}

/// Result of a registration attempt.
@freezed
class RegistrationResult with _$RegistrationResult {
  const factory RegistrationResult.success({
    required int deviceId,
    required String deviceType,
    String? deviceName,
  }) = RegistrationSuccess;

  const factory RegistrationResult.alreadyRegistered({
    required int deviceId,
    required String deviceType,
  }) = AlreadyRegistered;

  const factory RegistrationResult.failure({
    required String message,
    int? httpStatus,
  }) = RegistrationFailure;
}
