Path: lib/features/scanner/domain/value_objects/barcode.dart
Responsibility: Analyzes raw barcode strings to detect type (MAC/Serial/Part) with confidence scoring and provides typed conversions.
Public API:
  - enum BarcodeType: macAddress, serialNumber, partNumber, unknown (7-12)
  - class Barcode extends Equatable:
    - Constructor: Barcode({required String rawValue, DateTime? scannedAt}) (40-48)
    - Getters: normalizedValue (51), isValid (54), type (57), confidence (60), isMacAddress/isSerialNumber/isPartNumber/isUnknown (63-66), displayValue (69-79), typeDescription (82-93)
    - Methods: asMacAddress() -> MacAddress? (96-99), asSerialNumber() -> SerialNumber? (102-105), asPartNumber() -> PartNumber? (108-111)
    - Factories: fromMacAddress(MacAddress) (114-119), fromSerialNumber(SerialNumber) (122-127), fromPartNumber(PartNumber) (130-135)
    - Static: tryParse(String) -> Barcode? (138-147)
State & Side-effects:
  - Immutable with cached lazy values: _normalizedValue, _type, _confidence (32-34)
  - Caching happens in constructor (44-48)
  - No mutations after construction
Imports/Exports:
  - Imports: equatable (1), mac_address (2), serial_number (3), part_number (4)
  - Exports: BarcodeType enum, Barcode class
Lifecycle:
  - Init: Constructor performs type detection and caching (40-48)
  - No disposal needed: immutable value object
  - No listeners or subscriptions
Routing/UI role: None - pure value object
Error handling:
  - No exceptions thrown from public API
  - tryParse returns null on failure (138-147)
  - Type detection returns unknown type instead of failing
Performance notes:
  - Type detection runs once in constructor and caches results (44-48)
  - Complex regex patterns in detection methods (197, 202, 242-246, 250)
  - Multiple detection passes with confidence scoring (156-183)
Security notes:
  - No security operations
  - Normalizes input but doesn't sanitize for injection
  - No validation of malicious patterns
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions:
  - Extract type detection strategies to separate classes
  - Use pattern matching for type detection
  - Consider builder pattern for complex barcode creation
  - Optimize regex compilation (pre-compile patterns)
  - Add barcode format validation rules
Trace:
  - BarcodeType enum: 7-12
  - Barcode class: 27-313
  - Constructor with caching: 40-48
  - Type detection entry: 150-183
  - MAC detection: 186-208
  - Serial detection: 211-258
  - Part detection: 261-306
  - Internal TypeDetection class: 316-321