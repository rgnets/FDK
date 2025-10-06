Path: lib/features/scanner/domain/entities/scan_data.dart
Responsibility: Aggregates multiple barcode scans into a cohesive device representation with validation and completeness tracking.
Public API: 
  - enum DeviceType: ont, ap, switchDevice, gateway
  - class ScanData extends Equatable:
    - Constructor: ScanData({required DeviceType, String? sessionId, MacAddress?, SerialNumber?, PartNumber?, int? roomId, List<Barcode>?, DateTime? createdAt/updatedAt})
    - Getters: isComplete (67-83), hasInvalidSerial (97-106), missingFields (109-131), validationErrors (134-146), hasDuplicateScans (264-285), duplicateTypes (288-321), summary (324-335)
    - Methods: addBarcode(Barcode) -> ScanData (149-183), withMacAddress/SerialNumber/PartNumber/RoomId() -> ScanData (186-243), clear() -> ScanData (246-252), resetForDeviceType(DeviceType) -> ScanData (255-261), toMap() -> Map (372-385), fromMap(Map) factory (401-427)
State & Side-effects: 
  - Static counter: _sessionCounter (57) for unique session ID generation
  - Immutable state: all fields are final, mutations return new instances
  - Session tracking: auto-generates unique sessionId on creation (52-64)
  - Timestamp tracking: createdAt/updatedAt automatically managed (54-55)
Imports/Exports: 
  - Imports: equatable (1), value objects: mac_address (2), serial_number (3), part_number (4), barcode (5)
  - Exports: DeviceType enum, ScanData class
Lifecycle: 
  - Init: Constructor initializes with defaults, generates sessionId if not provided (42-55)
  - No dispose needed: immutable value object
  - No listeners: pure data class
Routing/UI role: None - pure domain entity
Error handling: 
  - Returns validation errors via validationErrors getter (134-146)
  - No exceptions thrown, validation failures returned as data
Performance notes: 
  - Cached computations via getters (isComplete, missingFields, etc.)
  - Creates new instances on mutations (immutable pattern)
  - List operations in duplicate detection (264-321) could be O(n²) for large scan counts
Security notes: 
  - No PII directly handled (MAC addresses could be considered device identifiers)
  - No secrets or credentials
  - No input validation on constructor (relies on value objects)
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions: 
  - Consider using freezed for immutable data classes
  - Extract device-specific validation rules to separate classes
  - Replace string-based device type conversion (387-398, 429-442) with extension methods
Trace: 
  - DeviceType enum: 8-13
  - ScanData class: 30-456
  - Constructor: 42-55
  - Completeness logic: 67-83
  - Serial validation: 86-106
  - Missing fields calculation: 109-131
  - Barcode addition: 149-183
  - Immutable updates: 186-261
  - Duplicate detection: 264-321
  - Serialization: 372-427