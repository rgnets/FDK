/// Types of barcodes that can be scanned
enum BarcodeType {
  serialNumber,
  macAddress,
  authCode,
  unknown;
  
  /// Get display name for the barcode type
  String get displayName {
    switch (this) {
      case BarcodeType.serialNumber:
        return 'Serial Number';
      case BarcodeType.macAddress:
        return 'MAC Address';
      case BarcodeType.authCode:
        return 'Authentication Code';
      case BarcodeType.unknown:
        return 'Unknown';
    }
  }
  
  /// Check if this is a device-related barcode
  bool get isDeviceBarcode {
    return this == BarcodeType.serialNumber || this == BarcodeType.macAddress;
  }
}