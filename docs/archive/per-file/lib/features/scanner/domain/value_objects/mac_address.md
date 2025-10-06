Path: lib/features/scanner/domain/value_objects/mac_address.dart
Responsibility: Validates and normalizes MAC addresses from various input formats into canonical representation.
Public API:
  - class InvalidMacAddressException extends Exception:
    - Constructor: InvalidMacAddressException(String invalidValue) (7)
    - toString() -> String (9-10)
  - class MacAddress extends Equatable:
    - Constructor: MacAddress(String input) - throws InvalidMacAddressException (36-40)
    - Getters: isValid -> bool (43), formatted -> String (46-53)
    - Static: tryParse(String) -> MacAddress? (56-62), isValidFormat(String) -> bool (65-72)
State & Side-effects:
  - Immutable value object, no mutations
  - Constructor normalizes and validates input (36-40)
  - Throws InvalidMacAddressException on invalid input (38-39)
Imports/Exports:
  - Imports: equatable (1)
  - Exports: InvalidMacAddressException, MacAddress classes
Lifecycle:
  - Init: Constructor validates and normalizes input (36-40)
  - No disposal needed: immutable value object
  - No listeners or callbacks
Routing/UI role: None - pure value object
Error handling:
  - Throws InvalidMacAddressException from constructor (38-39)
  - tryParse returns null instead of throwing (56-62)
  - isValidFormat returns false on invalid input (65-72)
Performance notes:
  - Normalization runs once in constructor (36)
  - Formatted getter rebuilds string each call (46-53)
  - Regex validation on each construction (97)
Security notes:
  - MAC addresses are device identifiers (potential privacy concern)
  - No input sanitization beyond format validation
  - No secrets or credentials
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions:
  - Cache formatted output instead of rebuilding (46-53)
  - Pre-compile regex pattern for performance
  - Consider factory pattern for different MAC formats
  - Add vendor lookup capability
  - Support EUI-64 format for IPv6
Trace:
  - InvalidMacAddressException: 4-11
  - MacAddress class: 24-105
  - Constructor with validation: 36-40
  - Formatted output: 46-53
  - Static factories: 56-72
  - Normalization logic: 75-92
  - Validation logic: 95-98