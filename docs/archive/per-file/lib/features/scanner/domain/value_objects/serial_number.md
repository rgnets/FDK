Path: lib/features/scanner/domain/value_objects/serial_number.dart
Responsibility: Validates and normalizes device serial numbers with manufacturer detection based on prefix patterns.
Public API:
  - class InvalidSerialNumberException extends Exception:
    - Constructor: InvalidSerialNumberException(String invalidValue) (7)
    - toString() -> String (9-10)
  - class SerialNumber extends Equatable:
    - Constructor: SerialNumber(String input) - throws InvalidSerialNumberException (44-48)
    - Constants: minLength = 6 (29), maxLength = 30 (32)
    - Getters: isValid -> bool (51), manufacturer -> String (54-59), isAlclFormat -> bool (62), is1kFormat -> bool (65-67)
    - Static: tryParse(String) -> SerialNumber? (70-76), isValidFormat(String) -> bool (79-86)
State & Side-effects:
  - Immutable value object, no mutations
  - Constructor normalizes and validates input (44-48)
  - Throws InvalidSerialNumberException on invalid input (46-47)
Imports/Exports:
  - Imports: equatable (1)
  - Exports: InvalidSerialNumberException, SerialNumber classes
Lifecycle:
  - Init: Constructor validates and normalizes input (44-48)
  - No disposal needed: immutable value object
  - No listeners or callbacks
Routing/UI role: None - pure value object
Error handling:
  - Throws InvalidSerialNumberException from constructor (46-47)
  - tryParse returns null instead of throwing (70-76)
  - isValidFormat returns false on invalid input (79-86)
Performance notes:
  - Manufacturer detection uses string prefix checks (54-59)
  - Normalization runs once in constructor (44)
  - Simple regex validation (118)
Security notes:
  - Serial numbers could be used for device tracking
  - No PII or credentials
  - Input validation prevents injection via length limits (114-115)
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions:
  - Extract manufacturer patterns to configuration
  - Use enum for manufacturers instead of strings
  - Add validation for manufacturer-specific formats
  - Cache manufacturer computation
  - Support more manufacturer prefixes
Trace:
  - InvalidSerialNumberException: 4-11
  - SerialNumber class: 25-126
  - Length constants: 29-32
  - Constructor with validation: 44-48
  - Manufacturer detection: 54-59
  - Format checking getters: 62-67
  - Static factories: 70-86
  - Normalization logic: 89-107
  - Validation logic: 111-119