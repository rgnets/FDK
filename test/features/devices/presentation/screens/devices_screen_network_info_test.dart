import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';

// Test the network info formatting logic
String formatNetworkInfo(Device device) {
  final ip = (device.ipAddress == null || device.ipAddress!.trim().isEmpty)
      ? 'No IP'
      : device.ipAddress!;
  final mac = (device.macAddress == null || device.macAddress!.trim().isEmpty)
      ? 'No MAC'
      : device.macAddress!;

  // Special case: IPv6 addresses are too long to show with MAC
  if (device.ipAddress != null &&
      device.ipAddress!.trim().isNotEmpty &&
      device.ipAddress!.contains(':') &&
      device.ipAddress!.length > 20) {
    return device.ipAddress!;
  }

  return '$ip • $mac';
}

void main() {
  group('DevicesScreen Network Info Formatting', () {
    test('should show "No IP • No MAC" for null values', () {
      const device = Device(
        id: 'test1',
        name: 'Test Device',
        type: 'access_point',
        status: 'online',
        ipAddress: null,
        macAddress: null,
      );

      expect(formatNetworkInfo(device), equals('No IP • No MAC'));
    });

    test('should show "No IP • No MAC" for empty strings', () {
      const device = Device(
        id: 'test2',
        name: 'Test Device',
        type: 'access_point',
        status: 'online',
        ipAddress: '',
        macAddress: '',
      );

      expect(formatNetworkInfo(device), equals('No IP • No MAC'));
    });

    test('should show "No IP • No MAC" for whitespace only', () {
      const device = Device(
        id: 'test3',
        name: 'Test Device',
        type: 'access_point',
        status: 'online',
        ipAddress: '   ',
        macAddress: '\t  ',
      );

      expect(formatNetworkInfo(device), equals('No IP • No MAC'));
    });

    test('should show IP and MAC when both present', () {
      const device = Device(
        id: 'test4',
        name: 'Test Device',
        type: 'access_point',
        status: 'online',
        ipAddress: '192.168.1.100',
        macAddress: 'AA:BB:CC:DD:EE:FF',
      );

      expect(
        formatNetworkInfo(device),
        equals('192.168.1.100 • AA:BB:CC:DD:EE:FF'),
      );
    });

    test('should show only IP when MAC is empty', () {
      const device = Device(
        id: 'test5',
        name: 'Test Device',
        type: 'access_point',
        status: 'online',
        ipAddress: '10.0.0.1',
        macAddress: '',
      );

      expect(formatNetworkInfo(device), equals('10.0.0.1 • No MAC'));
    });

    test('should show only MAC when IP is null', () {
      const device = Device(
        id: 'test6',
        name: 'Test Device',
        type: 'access_point',
        status: 'online',
        ipAddress: null,
        macAddress: 'FF:EE:DD:CC:BB:AA',
      );

      expect(formatNetworkInfo(device), equals('No IP • FF:EE:DD:CC:BB:AA'));
    });

    test('should show only IPv6 address when it is long', () {
      const device = Device(
        id: 'test7',
        name: 'Test Device',
        type: 'access_point',
        status: 'online',
        ipAddress: '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        macAddress: 'AA:BB:CC:DD:EE:FF',
      );

      expect(
        formatNetworkInfo(device),
        equals('2001:0db8:85a3:0000:0000:8a2e:0370:7334'),
      );
    });

    test('should show short IPv6 with MAC', () {
      const device = Device(
        id: 'test8',
        name: 'Test Device',
        type: 'access_point',
        status: 'online',
        ipAddress: '::1',
        macAddress: 'AA:BB:CC:DD:EE:FF',
      );

      expect(formatNetworkInfo(device), equals('::1 • AA:BB:CC:DD:EE:FF'));
    });
  });
}
