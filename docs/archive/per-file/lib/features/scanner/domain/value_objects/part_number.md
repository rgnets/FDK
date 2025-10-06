Path: lib/features/scanner/domain/value_objects/part_number.dart
Responsibility: Validates and normalizes device part numbers with device type detection based on known patterns.
Public API:
  - class InvalidPartNumberException extends Exception:
    - Constructor: InvalidPartNumberException(String invalidValue) (7)
    - toString() -> String (9-10)
  - class PartNumber extends Equatable:
    - Constructor: PartNumber(String input) - throws InvalidPartNumberException (44-48)
    - Constants: minLength = 4 (29), maxLength = 25 (32)
    - Getters: isValid -> bool (51), deviceType -> String (54-66), isOntPart -> bool (69), isApPart -> bool (72), isGatewayPart -> bool (75), isAttPart -> bool (78)
    - Static: tryParse(String) -> PartNumber? (81-87), isValidFormat(String) -> bool (90-97)
State & Side-effects:
  - Immutable value object, no mutations
  - Constructor normalizes and validates input (44-48)
  - Throws InvalidPartNumberException on invalid input (46-47)
Imports/Exports:
  - Imports: equatable (1)
  - Exports: InvalidPartNumberException, PartNumber classes
Lifecycle:
  - Init: Constructor validates and normalizes input (44-48)
  - No disposal needed: immutable value object
  - No listeners or callbacks
Routing/UI role: None - pure value object
Error handling:
  - Throws InvalidPartNumberException from constructor (46-47)
  - tryParse returns null instead of throwing (81-87)
  - isValidFormat returns false on invalid input (90-97)
Performance notes:
  - Device type detection uses string prefix checks (54-66)
  - Normalization runs once in constructor (44)
  - Simple regex validation (129)
Security notes:
  - No security-sensitive operations
  - No PII or credentials
  - Input validation prevents injection via length limits (125-126)
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions:
  - Extract device type patterns to configuration
  - Use enum for device types instead of strings
  - Add manufacturer detection
  - Cache device type computation
  - Consider factory methods for known part formats
Trace:
  - InvalidPartNumberException: 4-11
  - PartNumber class: 25-137
  - Length constants: 29-32
  - Constructor with validation: 44-48
  - Device type detection: 54-66
  - Type checking getters: 69-78
  - Static factories: 81-97
  - Normalization logic: 100-118
  - Validation logic: 122-130