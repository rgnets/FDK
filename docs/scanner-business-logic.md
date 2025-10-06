# Scanner Business Logic - RG Nets FDK

**Created**: 2025-08-17
**Purpose**: Document critical business logic for the barcode scanning feature

## Core Scanning Challenge

The barcode scanner faces a fundamental challenge:
- **Camera limitation**: Outputs only 1 barcode at a time
- **Registration requirement**: Need 2-3 barcodes minimum to register a device
- **Physical reality**: Devices have 8-10 barcodes on them

## Accumulation Window Logic

### Why 6 Seconds?
The 6-second accumulation window balances two competing needs:
1. **Enough time** to scan multiple barcodes from the same device
2. **Not too long** that users can't move to scan a different device

### How It Works
```
Time 0.0s: User points camera at device
Time 0.5s: First barcode detected (e.g., serial number)
Time 1.2s: Second barcode detected (e.g., MAC address)  
Time 2.0s: Third barcode detected (e.g., part number)
Time 2.5s: All required fields present → Enable registration
Time 6.0s: Window closes, accumulator resets
```

### Evolution
- Originally: 3-second window
- Current: 6-second window
- Reason: Field testing showed 3 seconds was too short for reliable multi-barcode capture

## Device Registration Requirements

### Minimum Required Barcodes by Device Type

#### Access Point (AP)
- **Required**: 2 barcodes
  1. Serial Number
  2. MAC Address
- **Optional**: Part number, asset tag

#### Optical Network Terminal (ONT)
- **Required**: 2 barcodes
  1. Serial Number
  2. MAC Address
- **Optional**: Part number, asset tag

#### Switch Device
- **Required**: 1 barcode
  1. Serial Number
- **Optional**: MAC address, part number, asset tag

### Validation Logic
```dart
bool canRegister(DeviceType type, ScannedData data) {
  switch (type) {
    case DeviceType.ap:
    case DeviceType.ont:
      return data.hasSerialNumber && data.hasMacAddress;
    case DeviceType.switch:
      return data.hasSerialNumber;
    default:
      return false;
  }
}
```

## Barcode Types on Physical Devices

Typical network equipment has these barcodes:
1. **Serial Number** - Manufacturer's unique identifier
2. **MAC Address** - Network hardware address
3. **Part Number** - Model/SKU identifier
4. **Asset Tag** - Company inventory tag
5. **QR Code** - May contain multiple fields
6. **Service Tag** - Support/warranty identifier
7. **IMEI/MEID** - For cellular-enabled devices
8. **Regulatory Labels** - FCC ID, IC ID, etc.

## Accumulator Implementation

### Key Features
1. **Time-based window**: 6 seconds from first scan
2. **Deduplication**: Same barcode won't be added twice
3. **Field extraction**: Parse different barcode formats
4. **Progressive validation**: Check if we have enough data
5. **Reset mechanism**: Clear and start fresh after timeout

### State Management
```dart
class ScanAccumulator {
  final Duration window = Duration(seconds: 6);
  DateTime? windowStart;
  Map<String, String> collectedData = {};
  
  void addBarcode(String barcode) {
    if (windowStart == null) {
      windowStart = DateTime.now();
    }
    
    if (DateTime.now().difference(windowStart!) > window) {
      reset();
      windowStart = DateTime.now();
    }
    
    extractAndStore(barcode);
    checkCompleteness();
  }
}
```

## User Experience Flow

### Successful Registration
1. User selects device type (AP, ONT, Switch)
2. Points camera at device
3. Scans visible barcodes (camera auto-focuses)
4. Progress indicator shows fields collected
5. Registration button enables when minimum met
6. User can continue scanning for optional fields
7. User taps register or waits for timeout

### Failed Registration
1. If required fields not found in 6 seconds
2. Accumulator resets automatically
3. User can try again with different angle/barcode
4. Error message if consistently failing

## Edge Cases

### Multiple Devices in Frame
- Only process one barcode at a time
- User must physically isolate device

### Damaged/Partial Barcodes
- Accumulator allows multiple attempts
- Partial data is retained within window

### Wrong Device Type Selected
- Validation will fail
- User must select correct type and rescan

## Testing Considerations

### Test Scenarios
1. Fast scanning (all barcodes in <2 seconds)
2. Slow scanning (barcodes spread across 5 seconds)
3. Timeout handling (>6 seconds)
4. Duplicate barcode handling
5. Invalid barcode rejection
6. Device type switching mid-scan

### Performance Metrics
- Average time to complete registration: 3-4 seconds
- Success rate target: >95% on first attempt
- Timeout rate: <5% of scanning sessions

## Future Enhancements

### Potential Improvements
1. **Adaptive timeout**: Adjust based on success patterns
2. **Multi-barcode QR**: Encode all fields in single QR code
3. **Batch scanning**: Queue multiple devices
4. **ML-assisted extraction**: Better parse damaged barcodes
5. **Haptic feedback**: Vibrate on successful field capture

### Configuration Options
```dart
class ScannerConfig {
  Duration accumulationWindow = Duration(seconds: 6);
  bool allowManualEntry = true;
  bool requireAllFields = false;
  bool hapticFeedback = true;
  int maxRetries = 3;
}
```

## References
- Implementation: lib/features/scanner/domain/services/scan_accumulator.dart
- Provider: lib/features/scanner/presentation/providers/scanner_provider.dart
- Validation: lib/features/scanner/domain/services/barcode_validator.dart