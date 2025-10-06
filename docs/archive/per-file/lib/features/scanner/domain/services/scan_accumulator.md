Path: lib/features/scanner/domain/services/scan_accumulator.dart
Responsibility: Accumulates barcode scans into ScanData while tracking duplicates, replacements, and scan history.
Public API:
  - class AccumulatorResult:
    - Constructor: AccumulatorResult({required ScanData data, bool wasAdded=true, bool wasReplaced=false, bool isDuplicate=false}) (11-16)
  - class ScanAccumulator:
    - Getters: currentData -> ScanData? (38), hasData -> bool (41-46)
    - initialize(DeviceType) -> void (49-52)
    - add(Barcode) -> AccumulatorResult (55-103)
    - isDuplicate(Barcode) -> bool (106-111)
    - setRoomId(int) -> void (114-119)
    - reset() -> void (122-125)
    - clear() -> void (128-133)
    - getScannedCounts() -> Map<BarcodeType, int> (136-142)
    - getScannedValues(BarcodeType) -> List<String> (145-147)
    - isComplete() -> bool (150-152)
    - getMissingFields() -> List<String> (155-157)
    - getValidationErrors() -> List<String> (160-162)
    - export() -> Map<String, dynamic> (165-178)
    - loadFromScanData(ScanData) -> void (181-192)
State & Side-effects:
  - Mutable state: _currentData (34), _scannedValues Map (35)
  - Side effects: modifies internal state on add(), initialize(), reset(), clear(), setRoomId()
  - Tracks scan history in _scannedValues for duplicate detection
  - Maintains current accumulated data in _currentData
Imports/Exports:
  - Imports: scan_data entity (1), barcode value object (2)
  - Exports: AccumulatorResult, ScanAccumulator classes
Lifecycle:
  - Init: Must call initialize(DeviceType) before use (49-52)
  - Reset: reset() clears all state (122-125)
  - Clear: clear() maintains device type but clears data (128-133)
  - Load: loadFromScanData() restores from existing data (181-192)
Routing/UI role: None - pure domain service
Error handling:
  - Throws StateError if not initialized before use (57-58, 116-117)
  - No other exceptions, handles edge cases gracefully
  - Returns AccumulatorResult with flags for outcomes
Performance notes:
  - O(1) duplicate detection via Map lookup (61-72, 106-111)
  - Rebuilds scanned values map on loadFromScanData (186-191)
  - Creates new ScanData instances on mutations (immutable pattern)
Security notes:
  - No security-sensitive operations
  - No direct PII handling (delegates to value objects)
  - No authentication/authorization
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions:
  - Consider making stateless with pure functions
  - Extract duplicate detection to separate class
  - Add event sourcing for scan history
  - Consider using StateNotifier pattern for state management
Trace:
  - AccumulatorResult class: 5-17
  - ScanAccumulator class: 19-193
  - State fields: 34-35
  - Initialization: 49-52
  - Main add logic: 55-103
  - Duplicate detection: 61-72, 106-111
  - State management: 122-133
  - Export/import: 165-192