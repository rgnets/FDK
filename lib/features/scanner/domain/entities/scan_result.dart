import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_result.freezed.dart';

@freezed
class ScanResult with _$ScanResult {
  const factory ScanResult({
    required String id,
    required String barcode,
    required BarcodeType type,
    required String value,
    required DateTime scannedAt,
  }) = _ScanResult;

  const ScanResult._();
}

enum BarcodeType {
  serialNumber,
  macAddress,
  partNumber,
  assetTag,
  qrCode,
  unknown,
}

extension BarcodeTypeX on BarcodeType {
  String get displayName {
    switch (this) {
      case BarcodeType.serialNumber:
        return 'Serial Number';
      case BarcodeType.macAddress:
        return 'MAC Address';
      case BarcodeType.partNumber:
        return 'Part Number';
      case BarcodeType.assetTag:
        return 'Asset Tag';
      case BarcodeType.qrCode:
        return 'QR Code';
      case BarcodeType.unknown:
        return 'Unknown';
    }
  }
}