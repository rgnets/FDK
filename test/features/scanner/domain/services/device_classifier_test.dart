import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_category.dart';
import 'package:rgnets_fdk/features/scanner/domain/services/device_classifier.dart';

void main() {
  group('DeviceClassifier', () {
    group('isPlaceholderValue', () {
      test('should return true for null', () {
        expect(DeviceClassifier.isPlaceholderValue(null), isTrue);
      });

      test('should return true for empty string', () {
        expect(DeviceClassifier.isPlaceholderValue(''), isTrue);
      });

      test('should return true for whitespace only', () {
        expect(DeviceClassifier.isPlaceholderValue('   '), isTrue);
        expect(DeviceClassifier.isPlaceholderValue('\t'), isTrue);
        expect(DeviceClassifier.isPlaceholderValue('\n'), isTrue);
      });

      test('should return true for "null" string (case insensitive)', () {
        expect(DeviceClassifier.isPlaceholderValue('null'), isTrue);
        expect(DeviceClassifier.isPlaceholderValue('NULL'), isTrue);
        expect(DeviceClassifier.isPlaceholderValue('Null'), isTrue);
        expect(DeviceClassifier.isPlaceholderValue('nUlL'), isTrue);
      });

      test('should return true for "placeholder" string (case insensitive)', () {
        expect(DeviceClassifier.isPlaceholderValue('placeholder'), isTrue);
        expect(DeviceClassifier.isPlaceholderValue('PLACEHOLDER'), isTrue);
        expect(DeviceClassifier.isPlaceholderValue('Placeholder'), isTrue);
      });

      test('should return false for actual values', () {
        expect(DeviceClassifier.isPlaceholderValue('AA:BB:CC:DD:EE:FF'), isFalse);
        expect(DeviceClassifier.isPlaceholderValue('SN12345'), isFalse);
        expect(DeviceClassifier.isPlaceholderValue('some-value'), isFalse);
      });

      test('should handle whitespace around placeholder values', () {
        expect(DeviceClassifier.isPlaceholderValue('  null  '), isTrue);
        expect(DeviceClassifier.isPlaceholderValue(' placeholder '), isTrue);
      });
    });

    group('isEphemeralName', () {
      test('should return false for device with empty name', () {
        final device = _createDevice(name: '', macAddress: 'AA:BB:CC:DD:EE:FF');
        expect(DeviceClassifier.isEphemeralName(device), isFalse);
      });

      test('should return true when name matches normalized MAC (uppercase)', () {
        final device = _createDevice(
          name: 'AABBCCDDEEFF',
          macAddress: 'AA:BB:CC:DD:EE:FF',
        );
        expect(DeviceClassifier.isEphemeralName(device), isTrue);
      });

      test('should return true when name matches MAC with different format', () {
        final device = _createDevice(
          name: 'AA:BB:CC:DD:EE:FF',
          macAddress: 'AABBCCDDEEFF',
        );
        expect(DeviceClassifier.isEphemeralName(device), isTrue);
      });

      test('should return true when name matches MAC case-insensitively', () {
        final device = _createDevice(
          name: 'aabbccddeeff',
          macAddress: 'AA:BB:CC:DD:EE:FF',
        );
        expect(DeviceClassifier.isEphemeralName(device), isTrue);
      });

      test('should return true when name matches serial number', () {
        final device = _createDevice(
          name: 'SN12345',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isEphemeralName(device), isTrue);
      });

      test('should return true when name matches serial (case insensitive)', () {
        final device = _createDevice(
          name: 'sn12345',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isEphemeralName(device), isTrue);
      });

      test('should return false when name is different from MAC and serial', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isEphemeralName(device), isFalse);
      });

      test('should return false when MAC and serial are both null', () {
        final device = _createDevice(name: 'Living Room AP');
        expect(DeviceClassifier.isEphemeralName(device), isFalse);
      });
    });

    group('isDesignedDevice', () {
      test('should return false for device without name', () {
        final device = _createDevice(name: '');
        expect(DeviceClassifier.isDesignedDevice(device), isFalse);
      });

      test('should return false for device with ephemeral name', () {
        final device = _createDevice(
          name: 'AABBCCDDEEFF',
          macAddress: 'AA:BB:CC:DD:EE:FF',
        );
        expect(DeviceClassifier.isDesignedDevice(device), isFalse);
      });

      test('should return true for device with name but missing MAC', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: null,
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isDesignedDevice(device), isTrue);
      });

      test('should return true for device with name but missing serial', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: null,
        );
        expect(DeviceClassifier.isDesignedDevice(device), isTrue);
      });

      test('should return true for device with name but both MAC and serial missing', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: null,
          serialNumber: null,
        );
        expect(DeviceClassifier.isDesignedDevice(device), isTrue);
      });

      test('should return true for device with placeholder MAC', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'placeholder',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isDesignedDevice(device), isTrue);
      });

      test('should return true for device with placeholder serial', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'null',
        );
        expect(DeviceClassifier.isDesignedDevice(device), isTrue);
      });

      test('should return false for fully assigned device', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isDesignedDevice(device), isFalse);
      });
    });

    group('isFullyAssignedDevice', () {
      test('should return false for device without name', () {
        final device = _createDevice(
          name: '',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isFullyAssignedDevice(device), isFalse);
      });

      test('should return false for device with ephemeral name', () {
        final device = _createDevice(
          name: 'AABBCCDDEEFF',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isFullyAssignedDevice(device), isFalse);
      });

      test('should return false for device missing MAC', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: null,
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isFullyAssignedDevice(device), isFalse);
      });

      test('should return false for device missing serial', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: null,
        );
        expect(DeviceClassifier.isFullyAssignedDevice(device), isFalse);
      });

      test('should return false for device with placeholder MAC', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'placeholder',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isFullyAssignedDevice(device), isFalse);
      });

      test('should return false for device with placeholder serial', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'NULL',
        );
        expect(DeviceClassifier.isFullyAssignedDevice(device), isFalse);
      });

      test('should return true for device with name, MAC, and serial all present', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.isFullyAssignedDevice(device), isTrue);
      });
    });

    group('classifyDevice', () {
      test('should return invalid for device without name', () {
        final device = _createDevice(name: '');
        expect(DeviceClassifier.classifyDevice(device), DeviceCategory.invalid);
      });

      test('should return ephemeral for device with name matching MAC', () {
        final device = _createDevice(
          name: 'AABBCCDDEEFF',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.classifyDevice(device), DeviceCategory.ephemeral);
      });

      test('should return ephemeral for device with name matching serial', () {
        final device = _createDevice(
          name: 'SN12345',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.classifyDevice(device), DeviceCategory.ephemeral);
      });

      test('should return designed for device with name but missing MAC', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: null,
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.classifyDevice(device), DeviceCategory.designed);
      });

      test('should return designed for device with name but missing serial', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: null,
        );
        expect(DeviceClassifier.classifyDevice(device), DeviceCategory.designed);
      });

      test('should return designed for device with placeholder values', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'placeholder',
          serialNumber: 'null',
        );
        expect(DeviceClassifier.classifyDevice(device), DeviceCategory.designed);
      });

      test('should return assigned for fully configured device', () {
        final device = _createDevice(
          name: 'Living Room AP',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'SN12345',
        );
        expect(DeviceClassifier.classifyDevice(device), DeviceCategory.assigned);
      });
    });

    group('filterSelectableDevices', () {
      test('should exclude ephemeral devices', () {
        final devices = [
          _createDevice(name: 'AABBCCDDEEFF', macAddress: 'AA:BB:CC:DD:EE:FF'), // ephemeral
          _createDevice(name: 'Living Room AP', macAddress: null), // designed
          _createDevice(name: 'Kitchen AP', macAddress: 'BB:CC:DD:EE:FF:00', serialNumber: 'SN999'), // assigned
        ];

        final result = DeviceClassifier.filterSelectableDevices(devices);
        expect(result.length, equals(2));
        expect(result.any((d) => d.name == 'Living Room AP'), isTrue);
        expect(result.any((d) => d.name == 'Kitchen AP'), isTrue);
      });

      test('should exclude invalid devices (no name)', () {
        final devices = [
          _createDevice(name: '', macAddress: 'AA:BB:CC:DD:EE:FF'), // invalid
          _createDevice(name: 'Living Room AP', macAddress: null), // designed
        ];

        final result = DeviceClassifier.filterSelectableDevices(devices);
        expect(result.length, equals(1));
        expect(result.first.name, equals('Living Room AP'));
      });

      test('should return both designed and assigned devices', () {
        final devices = [
          _createDevice(name: 'Designed AP', macAddress: null, serialNumber: null),
          _createDevice(name: 'Assigned AP', macAddress: 'AA:BB:CC:DD:EE:FF', serialNumber: 'SN123'),
        ];

        final result = DeviceClassifier.filterSelectableDevices(devices);
        expect(result.length, equals(2));
      });

      test('should return empty list for empty input', () {
        final result = DeviceClassifier.filterSelectableDevices([]);
        expect(result, isEmpty);
      });
    });

    group('categorizeDevices', () {
      test('should correctly categorize mixed device list', () {
        final devices = [
          _createDevice(name: 'AABBCCDDEEFF', macAddress: 'AA:BB:CC:DD:EE:FF'), // ephemeral
          _createDevice(name: 'Designed 1', macAddress: null), // designed
          _createDevice(name: 'Designed 2', serialNumber: 'placeholder'), // designed
          _createDevice(name: 'Assigned 1', macAddress: 'BB:CC:DD:EE:FF:00', serialNumber: 'SN1'), // assigned
          _createDevice(name: '', macAddress: 'CC:DD:EE:FF:00:11'), // invalid
        ];

        final result = DeviceClassifier.categorizeDevices(devices);

        expect(result[DeviceCategory.ephemeral]?.length, equals(1));
        expect(result[DeviceCategory.designed]?.length, equals(2));
        expect(result[DeviceCategory.assigned]?.length, equals(1));
        expect(result[DeviceCategory.invalid]?.length, equals(1));
      });

      test('should return empty map for empty input', () {
        final result = DeviceClassifier.categorizeDevices([]);
        expect(result, isEmpty);
      });
    });

    group('edge cases', () {
      test('should handle device with all null optional fields', () {
        final device = _createDevice(
          name: 'Test AP',
          macAddress: null,
          serialNumber: null,
        );
        expect(DeviceClassifier.classifyDevice(device), DeviceCategory.designed);
      });

      test('should handle device with empty strings vs null', () {
        final deviceEmpty = _createDevice(
          name: 'Test AP',
          macAddress: '',
          serialNumber: '',
        );
        final deviceNull = _createDevice(
          name: 'Test AP',
          macAddress: null,
          serialNumber: null,
        );

        // Both should be classified as designed
        expect(DeviceClassifier.classifyDevice(deviceEmpty), DeviceCategory.designed);
        expect(DeviceClassifier.classifyDevice(deviceNull), DeviceCategory.designed);
      });

      test('should handle MAC address formats in ephemeral detection', () {
        // Various MAC formats should all be detected as ephemeral
        final devices = [
          _createDevice(name: 'AA-BB-CC-DD-EE-FF', macAddress: 'AA:BB:CC:DD:EE:FF'),
          _createDevice(name: 'aa:bb:cc:dd:ee:ff', macAddress: 'AABBCCDDEEFF'),
          _createDevice(name: 'aabb.ccdd.eeff', macAddress: 'AA:BB:CC:DD:EE:FF'),
        ];

        for (final device in devices) {
          expect(
            DeviceClassifier.isEphemeralName(device),
            isTrue,
            reason: 'Device with name "${device.name}" should be ephemeral',
          );
        }
      });
    });
  });
}

/// Helper function to create a Device for testing.
Device _createDevice({
  required String name,
  String? macAddress,
  String? serialNumber,
  String id = '1',
  String type = 'access_point',
  String status = 'online',
}) {
  return Device(
    id: id,
    name: name,
    type: type,
    status: status,
    macAddress: macAddress,
    serialNumber: serialNumber,
  );
}
