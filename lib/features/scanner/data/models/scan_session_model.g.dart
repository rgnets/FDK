// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScanSessionModelImpl _$$ScanSessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ScanSessionModelImpl(
      id: json['id'] as String,
      deviceType: json['device_type'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      scannedBarcodes: (json['scanned_barcodes'] as List<dynamic>)
          .map((e) => ScanResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      serialNumber: json['serial_number'] as String?,
      macAddress: json['mac_address'] as String?,
      partNumber: json['part_number'] as String?,
      assetTag: json['asset_tag'] as String?,
      additionalData: (json['additional_data'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$$ScanSessionModelImplToJson(
    _$ScanSessionModelImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'device_type': instance.deviceType,
    'started_at': instance.startedAt.toIso8601String(),
    'scanned_barcodes':
        instance.scannedBarcodes.map((e) => e.toJson()).toList(),
    'status': instance.status,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('completed_at', instance.completedAt?.toIso8601String());
  writeNotNull('serial_number', instance.serialNumber);
  writeNotNull('mac_address', instance.macAddress);
  writeNotNull('part_number', instance.partNumber);
  writeNotNull('asset_tag', instance.assetTag);
  writeNotNull('additional_data', instance.additionalData);
  return val;
}

_$ScanResultModelImpl _$$ScanResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ScanResultModelImpl(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      type: json['type'] as String,
      value: json['value'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
    );

Map<String, dynamic> _$$ScanResultModelImplToJson(
        _$ScanResultModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'barcode': instance.barcode,
      'type': instance.type,
      'value': instance.value,
      'scanned_at': instance.scannedAt.toIso8601String(),
    };
