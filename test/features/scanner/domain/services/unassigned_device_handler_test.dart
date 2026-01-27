import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/device_category.dart';
import 'package:rgnets_fdk/features/scanner/domain/services/unassigned_device_handler.dart';

void main() {
  group('UnassignedDeviceHandler', () {
    group('isUnassignedRecord', () {
      test('should return true when both MAC and serial are empty strings', () {
        final device = _createDevice(
          name: 'Room 101 AP',
          macAddress: '',
          serialNumber: '',
        );
        expect(UnassignedDeviceHandler.isUnassignedRecord(device), isTrue);
      });

      test('should return true when both MAC and serial are null', () {
        final device = _createDevice(
          name: 'Room 101 AP',
          macAddress: null,
          serialNumber: null,
        );
        expect(UnassignedDeviceHandler.isUnassignedRecord(device), isTrue);
      });

      test('should return true when both are "placeholder" (case insensitive)', () {
        expect(
          UnassignedDeviceHandler.isUnassignedRecord(
            _createDevice(name: 'AP1', macAddress: 'placeholder', serialNumber: 'placeholder'),
          ),
          isTrue,
        );
        expect(
          UnassignedDeviceHandler.isUnassignedRecord(
            _createDevice(name: 'AP2', macAddress: 'PLACEHOLDER', serialNumber: 'Placeholder'),
          ),
          isTrue,
        );
      });

      test('should return true when both are "null" string (case insensitive)', () {
        expect(
          UnassignedDeviceHandler.isUnassignedRecord(
            _createDevice(name: 'AP1', macAddress: 'null', serialNumber: 'null'),
          ),
          isTrue,
        );
        expect(
          UnassignedDeviceHandler.isUnassignedRecord(
            _createDevice(name: 'AP2', macAddress: 'NULL', serialNumber: 'Null'),
          ),
          isTrue,
        );
      });

      test('should return true when both are whitespace only', () {
        final device = _createDevice(
          name: 'AP1',
          macAddress: '   ',
          serialNumber: '  \t ',
        );
        expect(UnassignedDeviceHandler.isUnassignedRecord(device), isTrue);
      });

      test('should return false when only serial is present', () {
        final device = _createDevice(
          name: 'AP1',
          macAddress: '',
          serialNumber: 'SN12345',
        );
        expect(UnassignedDeviceHandler.isUnassignedRecord(device), isFalse);
      });

      test('should return false when only MAC is present', () {
        final device = _createDevice(
          name: 'AP1',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: '',
        );
        expect(UnassignedDeviceHandler.isUnassignedRecord(device), isFalse);
      });

      test('should return false when both MAC and serial are present', () {
        final device = _createDevice(
          name: 'AP1',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'SN12345',
        );
        expect(UnassignedDeviceHandler.isUnassignedRecord(device), isFalse);
      });

      test('should return false when placeholder MAC but real serial', () {
        final device = _createDevice(
          name: 'AP1',
          macAddress: 'placeholder',
          serialNumber: 'SN12345',
        );
        expect(UnassignedDeviceHandler.isUnassignedRecord(device), isFalse);
      });

      test('should return false when real MAC but placeholder serial', () {
        final device = _createDevice(
          name: 'AP1',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'placeholder',
        );
        expect(UnassignedDeviceHandler.isUnassignedRecord(device), isFalse);
      });

      test('should return false when real MAC but null serial string', () {
        final device = _createDevice(
          name: 'AP1',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          serialNumber: 'null',
        );
        expect(UnassignedDeviceHandler.isUnassignedRecord(device), isFalse);
      });

      test('should handle mixed placeholder types', () {
        // null MAC + placeholder serial = unassigned
        expect(
          UnassignedDeviceHandler.isUnassignedRecord(
            _createDevice(name: 'AP1', macAddress: null, serialNumber: 'placeholder'),
          ),
          isTrue,
        );

        // empty MAC + null serial string = unassigned
        expect(
          UnassignedDeviceHandler.isUnassignedRecord(
            _createDevice(name: 'AP2', macAddress: '', serialNumber: 'null'),
          ),
          isTrue,
        );

        // whitespace MAC + null Dart value serial = unassigned
        expect(
          UnassignedDeviceHandler.isUnassignedRecord(
            _createDevice(name: 'AP3', macAddress: '   ', serialNumber: null),
          ),
          isTrue,
        );
      });
    });

    group('filterUnassignedRecords', () {
      test('should return only devices where both MAC and serial are absent', () {
        final devices = [
          _createDevice(name: 'Unassigned 1', macAddress: '', serialNumber: ''),
          _createDevice(name: 'Designed 1', macAddress: null, serialNumber: 'SN123'),
          _createDevice(name: 'Unassigned 2', macAddress: 'placeholder', serialNumber: 'null'),
          _createDevice(name: 'Assigned', macAddress: 'AA:BB:CC:DD:EE:FF', serialNumber: 'SN999'),
          _createDevice(name: 'Designed 2', macAddress: 'BB:CC:DD:EE:FF:00', serialNumber: null),
        ];

        final result = UnassignedDeviceHandler.filterUnassignedRecords(devices);

        expect(result.length, equals(2));
        expect(result.any((d) => d.name == 'Unassigned 1'), isTrue);
        expect(result.any((d) => d.name == 'Unassigned 2'), isTrue);
      });

      test('should return empty list when no unassigned devices', () {
        final devices = [
          _createDevice(name: 'Designed', macAddress: null, serialNumber: 'SN123'),
          _createDevice(name: 'Assigned', macAddress: 'AA:BB:CC:DD:EE:FF', serialNumber: 'SN999'),
        ];

        final result = UnassignedDeviceHandler.filterUnassignedRecords(devices);

        expect(result, isEmpty);
      });

      test('should return empty list for empty input', () {
        final result = UnassignedDeviceHandler.filterUnassignedRecords([]);
        expect(result, isEmpty);
      });
    });

    group('getRegistrationCandidates', () {
      test('should return designed and assigned devices sorted by name', () {
        final devices = [
          _createDevice(name: 'Zebra AP', macAddress: null, serialNumber: null), // designed (both missing = still designed)
          _createDevice(name: 'Beta AP', macAddress: null, serialNumber: 'SN123'), // designed
          _createDevice(name: 'Alpha AP', macAddress: 'AA:BB:CC:DD:EE:FF', serialNumber: 'SN999'), // assigned
          _createDevice(name: 'Charlie AP', macAddress: 'BB:CC:DD:EE:FF:00', serialNumber: null), // designed
          _createDevice(name: 'AABBCCDDEEFF', macAddress: 'AA:BB:CC:DD:EE:FF', serialNumber: 'SN1'), // ephemeral - excluded
        ];

        final result = UnassignedDeviceHandler.getRegistrationCandidates(devices);

        // Should have 4 devices: 3 designed + 1 assigned (ephemeral excluded)
        expect(result.length, equals(4));

        // Designed should come first, sorted by name
        expect(result[0].name, equals('Beta AP'));
        expect(result[1].name, equals('Charlie AP'));
        expect(result[2].name, equals('Zebra AP'));

        // Then assigned, sorted by name
        expect(result[3].name, equals('Alpha AP'));
      });

      test('should exclude ephemeral devices', () {
        final devices = [
          _createDevice(name: 'AABBCCDDEEFF', macAddress: 'AA:BB:CC:DD:EE:FF', serialNumber: 'SN1'),
          _createDevice(name: 'SN12345', serialNumber: 'SN12345', macAddress: 'BB:CC:DD:EE:FF:00'),
        ];

        final result = UnassignedDeviceHandler.getRegistrationCandidates(devices);

        expect(result, isEmpty);
      });

      test('should exclude devices without names', () {
        final devices = [
          _createDevice(name: '', macAddress: 'AA:BB:CC:DD:EE:FF', serialNumber: 'SN1'),
        ];

        final result = UnassignedDeviceHandler.getRegistrationCandidates(devices);

        expect(result, isEmpty);
      });
    });

    group('categorizeForSelection', () {
      test('should group devices by category with designed first', () {
        final devices = [
          _createDevice(name: 'Assigned AP', macAddress: 'AA:BB:CC:DD:EE:FF', serialNumber: 'SN999'),
          _createDevice(name: 'Designed AP', macAddress: null, serialNumber: 'SN123'),
        ];

        final result = UnassignedDeviceHandler.categorizeForSelection(devices);

        expect(result.containsKey(DeviceCategory.designed), isTrue);
        expect(result.containsKey(DeviceCategory.assigned), isTrue);
        expect(result[DeviceCategory.designed]!.first.name, equals('Designed AP'));
        expect(result[DeviceCategory.assigned]!.first.name, equals('Assigned AP'));
      });

      test('should not include ephemeral or invalid categories', () {
        final devices = [
          _createDevice(name: '', macAddress: 'AA:BB:CC:DD:EE:FF'), // invalid
          _createDevice(name: 'AABBCCDDEEFF', macAddress: 'AA:BB:CC:DD:EE:FF'), // ephemeral
          _createDevice(name: 'Valid AP', macAddress: null, serialNumber: 'SN1'), // designed
        ];

        final result = UnassignedDeviceHandler.categorizeForSelection(devices);

        expect(result.containsKey(DeviceCategory.ephemeral), isFalse);
        expect(result.containsKey(DeviceCategory.invalid), isFalse);
        expect(result.containsKey(DeviceCategory.designed), isTrue);
      });
    });
  });

  group('UnassignedDeviceAction', () {
    test('addNew factory creates action with addAsNew=true', () {
      final action = UnassignedDeviceAction.addNew();

      expect(action.addAsNew, isTrue);
      expect(action.selectedDevice, isNull);
    });

    test('useDevice factory creates action with selected device', () {
      final device = _createDevice(
        name: 'Test AP',
        macAddress: null,
        serialNumber: 'SN123',
      );

      final action = UnassignedDeviceAction.useDevice(device);

      expect(action.addAsNew, isFalse);
      expect(action.selectedDevice, equals(device));
      expect(action.selectedDevice!.name, equals('Test AP'));
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
  int? pmsRoomId,
}) {
  return Device(
    id: id,
    name: name,
    type: type,
    status: status,
    macAddress: macAddress,
    serialNumber: serialNumber,
    pmsRoomId: pmsRoomId,
  );
}
