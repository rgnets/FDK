Path: lib/features/scanner/domain/services/scan_processor.dart
Responsibility: Orchestrates barcode scanning workflow including validation, accumulation, mode switching, and completion detection.
Public API:
  - enum ScanMode: none, ont, ap, switchDevice, gateway (7-13)
  - class ProcessResult:
    - Constructor: ProcessResult({required bool isSuccess, bool isComplete=false, bool isDuplicate=false, ScanData? data, String message='', String? error, List<String> validationErrors=[]}) (25-33)
    - Factory: success({required ScanData, bool isComplete=false, bool isDuplicate=false, String message=''}) (35-48)
    - Factory: failure({required String error, List<String> validationErrors=[], ScanData? data}) (50-61)
  - class ScanProcessor:
    - Constructor: ScanProcessor({required BarcodeValidator, required ScanAccumulator}) (85-88)
    - Getters: currentMode -> ScanMode (91), isProcessing -> bool (94), currentData -> ScanData? (97), hasData -> bool (100)
    - switchMode(ScanMode) -> void (103-122)
    - processBarcode(String) -> ProcessResult (125-200)
    - processBarcodeAsync(String) -> Future<ProcessResult> (203-207)
    - clear() -> void (210-220)
    - reset() -> void (223-226)
    - setRoomId(int) -> void (229-231)
    - getScanSummary() -> String (234-239)
    - getMissingFields() -> List<String> (242-247)
    - exportData() -> Map<String, dynamic> (250-255)
State & Side-effects:
  - Mutable state: _currentMode (82), _isProcessing flag (83)
  - Delegates state to BarcodeValidator and ScanAccumulator dependencies
  - Side effects: modifies accumulator state, switches modes
  - Processing flag prevents concurrent barcode processing
Imports/Exports:
  - Imports: barcode_validator (1), scan_accumulator (2), scan_data entity (3), barcode value object (4)
  - Exports: ScanMode enum, ProcessResult, ScanProcessor classes
Lifecycle:
  - Init: Constructor injection of dependencies (85-88)
  - Mode switching: preserves roomId across mode changes (103-122)
  - Reset: full reset (223-226) or data-only clear (210-220)
  - No disposal needed (dependencies manage own lifecycle)
Routing/UI role: None - pure domain service orchestrator
Error handling:
  - Returns ProcessResult with error details instead of throwing (126-129, 135-139, 147-161)
  - Catches all exceptions in try-catch (192-197)
  - Validation errors propagated from validator (154-161)
Performance notes:
  - Synchronous processing with async wrapper available (203-207)
  - Processing flag prevents race conditions (83, 140, 198)
  - Mode switching recreates accumulator state (103-122)
Security notes:
  - No direct security operations
  - Delegates validation to BarcodeValidator
  - No authentication/authorization
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions:
  - Consider state machine pattern for mode transitions
  - Extract mode-to-device-type mapping to configuration
  - Add command pattern for processing operations
  - Consider reactive streams for scan results
  - Separate async concerns from core logic
Trace:
  - ScanMode enum: 7-13
  - ProcessResult class: 16-62
  - ScanProcessor class: 64-288
  - Dependencies: 79-80
  - State fields: 82-83
  - Mode switching: 103-122
  - Main processing: 125-200
  - Helper conversions: 258-287