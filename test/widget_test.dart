import 'package:flutter_test/flutter_test.dart';

/// Full-app widget tests have been moved to integration_test/app_test.dart
///
/// Run integration tests with:
///   flutter test integration_test/app_test.dart
///
/// Or with a real device/emulator:
///   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
///
/// The tests were moved because FDKApp uses ref.listen in initState,
/// which is incompatible with UncontrolledProviderScope in widget tests.
void main() {
  test('Full app tests moved to integration_test/', () {
    // This is a placeholder to document the test relocation.
    // See integration_test/app_test.dart for the actual tests.
    expect(true, isTrue);
  });
}
