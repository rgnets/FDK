import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_result.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';

part 'scan_session_model.freezed.dart';
part 'scan_session_model.g.dart';

@freezed
class ScanSessionModel with _$ScanSessionModel {
  const factory ScanSessionModel({
    required String id,
    required String deviceType,
    required DateTime startedAt,
    required List<ScanResultModel> scannedBarcodes, required String status, DateTime? completedAt,
    String? serialNumber,
    String? macAddress,
    String? partNumber,
    String? assetTag,
    Map<String, String>? additionalData,
  }) = _ScanSessionModel;

  const ScanSessionModel._();

  factory ScanSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ScanSessionModelFromJson(json);

  factory ScanSessionModel.fromDomain(ScanSession session) {
    return ScanSessionModel(
      id: session.id,
      deviceType: session.deviceType.name,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      scannedBarcodes: session.scannedBarcodes
          .map(ScanResultModel.fromDomain)
          .toList(),
      status: session.status.name,
      serialNumber: session.serialNumber,
      macAddress: session.macAddress,
      partNumber: session.partNumber,
      assetTag: session.assetTag,
      additionalData: session.additionalData,
    );
  }

  ScanSession toDomain() {
    return ScanSession(
      id: id,
      deviceType: DeviceType.values.firstWhere((e) => e.name == deviceType),
      startedAt: startedAt,
      completedAt: completedAt,
      scannedBarcodes: scannedBarcodes.map((e) => e.toDomain()).toList(),
      status: ScanSessionStatus.values.firstWhere((e) => e.name == status),
      serialNumber: serialNumber,
      macAddress: macAddress,
      partNumber: partNumber,
      assetTag: assetTag,
      additionalData: additionalData,
    );
  }
}

@freezed
class ScanResultModel with _$ScanResultModel {
  const factory ScanResultModel({
    required String id,
    required String barcode,
    required String type,
    required String value,
    required DateTime scannedAt,
  }) = _ScanResultModel;

  const ScanResultModel._();

  factory ScanResultModel.fromJson(Map<String, dynamic> json) =>
      _$ScanResultModelFromJson(json);

  factory ScanResultModel.fromDomain(ScanResult result) {
    return ScanResultModel(
      id: result.id,
      barcode: result.barcode,
      type: result.type.name,
      value: result.value,
      scannedAt: result.scannedAt,
    );
  }

  ScanResult toDomain() {
    return ScanResult(
      id: id,
      barcode: barcode,
      type: BarcodeType.values.firstWhere((e) => e.name == type),
      value: value,
      scannedAt: scannedAt,
    );
  }
}