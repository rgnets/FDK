import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_result.dart';

part 'scan_session.freezed.dart';

@freezed
class ScanSession with _$ScanSession {
  const factory ScanSession({
    required String id,
    required DeviceType deviceType,
    required DateTime startedAt,
    required List<ScanResult> scannedBarcodes, required ScanSessionStatus status, DateTime? completedAt,
    String? serialNumber,
    String? macAddress,
    String? partNumber,
    String? assetTag,
    Map<String, String>? additionalData,
  }) = _ScanSession;

  const ScanSession._();

  bool get isComplete {
    switch (deviceType) {
      case DeviceType.accessPoint:
      case DeviceType.ont:
        return serialNumber != null && macAddress != null;
      case DeviceType.switchDevice:
        return serialNumber != null;
    }
  }

  bool get canRegister => isComplete;

  Duration? get duration {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    }
    return null;
  }
}

enum DeviceType {
  accessPoint,
  ont,
  switchDevice,
}

enum ScanSessionStatus {
  scanning,
  complete,
  cancelled,
  timeout,
  error,
}

extension DeviceTypeX on DeviceType {
  String get displayName {
    switch (this) {
      case DeviceType.accessPoint:
        return 'Access Point';
      case DeviceType.ont:
        return 'ONT';
      case DeviceType.switchDevice:
        return 'Switch';
    }
  }

  String get abbreviation {
    switch (this) {
      case DeviceType.accessPoint:
        return 'AP';
      case DeviceType.ont:
        return 'ONT';
      case DeviceType.switchDevice:
        return 'SW';
    }
  }
}