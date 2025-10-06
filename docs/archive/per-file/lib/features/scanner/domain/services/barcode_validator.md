Path: lib/features/scanner/domain/services/barcode_validator.dart
Responsibility: Validates barcodes against device-specific business rules enforcing manufacturer and part compatibility requirements.
Public API:
  - class ValidationResult:
    - Constructor: ValidationResult({required bool isValid, String error='', List<String> errors=[]}) (10-14)
    - Factory: valid() -> ValidationResult (16-18)
    - Factory: invalid(String error, [List<String>? errors]) -> ValidationResult (20-26)
  - class BarcodeValidator:
    - validateForMode(Barcode, ScanMode) -> ValidationResult (38-51)
    - isRequiredType(BarcodeType, ScanMode) -> bool (188-204)
    - getRequiredTypes(ScanMode) -> List<BarcodeType> (207-227)
State & Side-effects:
  - Stateless service, pure functions only
  - No internal state or mutations
  - ValidationResult is immutable data holder
Imports/Exports:
  - Imports: barcode value object (1), scan_processor for ScanMode enum (2)
  - Exports: ValidationResult, BarcodeValidator classes
Lifecycle:
  - Init: Default constructor, no initialization needed
  - Dispose: No disposal needed (stateless)
  - No listeners or subscriptions
Routing/UI role: None - pure domain service
Error handling:
  - Returns ValidationResult with error messages instead of throwing
  - Detailed error messages with context (68-70, 108-111, 122-124, 176-178)
  - Multi-error support via errors list in ValidationResult (8, 23-24)
Performance notes:
  - All validation is synchronous and lightweight
  - Switch statements for mode/type branching (39-50, 55-91, 95-130, 134-154, 158-184)
  - No async operations or heavy computations
Security notes:
  - No security-sensitive operations
  - Input validation only, no data persistence
  - No authentication/authorization concerns
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions:
  - Consider strategy pattern for device-specific validators
  - Extract validation rules to configuration
  - Add caching for repeated validations
  - Consider making ValidationResult a sealed class/union type
Trace:
  - ValidationResult class: 5-27
  - BarcodeValidator class: 29-228
  - validateForMode main entry: 38-51
  - ONT validation: 54-92
  - AP validation: 95-131
  - Switch validation: 134-155
  - Gateway validation: 158-185
  - Type requirement checks: 188-227