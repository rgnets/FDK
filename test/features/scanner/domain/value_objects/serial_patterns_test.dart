import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/scanner/domain/value_objects/serial_patterns.dart';

void main() {
  group('SerialPatterns – Ruckus ICX switch prefixes', () {
    test('FEK is registered as a Ruckus switch prefix', () {
      expect(SerialPatterns.ruckusSwitchPrefixes, contains('FEK'));
    });

    test('a FEK serial is detected as a switch', () {
      // Ruckus serials need a minimum of 10 characters.
      const serial = 'FEK1234567';
      expect(SerialPatterns.isSwitchSerial(serial), isTrue);
      expect(
        SerialPatterns.detectDeviceType(serial),
        DeviceTypeFromSerial.switchDevice,
      );
    });

    test('FEK detection is case-insensitive and trims whitespace', () {
      expect(SerialPatterns.isSwitchSerial('  fek1234567  '), isTrue);
    });

    test('a too-short FEK serial is rejected', () {
      expect(SerialPatterns.isSwitchSerial('FEK12345'), isFalse); // 8 chars
    });

    test('existing Ruckus prefixes still detect as switches', () {
      for (final prefix in ['FJN', 'FMR', 'FND', 'FEA', 'FNS', 'FNK', 'FNH', 'CYR']) {
        final serial = '${prefix}1234567';
        expect(
          SerialPatterns.isSwitchSerial(serial),
          isTrue,
          reason: '$prefix should be recognised as a switch',
        );
      }
    });

    test('FEK is not misclassified as an AP or ONT', () {
      const serial = 'FEK1234567';
      expect(SerialPatterns.isAPSerial(serial), isFalse);
      expect(SerialPatterns.isONTSerial(serial), isFalse);
    });

    test('expected-format message lists FEK for switches', () {
      final msg =
          SerialPatterns.getExpectedFormat(DeviceTypeFromSerial.switchDevice);
      expect(msg, contains('FEK'));
    });
  });
}
