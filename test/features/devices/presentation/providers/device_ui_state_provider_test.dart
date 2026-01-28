import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/device_ui_state_provider.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test override for DevicesNotifier that returns a fixed list of devices
class TestDevicesNotifier extends DevicesNotifier {
  TestDevicesNotifier(this._testDevices);

  final List<Device> _testDevices;

  @override
  Future<List<Device>> build() async => _testDevices;
}

void main() {
  group('filteredDevicesList search', () {
    late List<Device> testDevices;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      testDevices = [
        const Device(
          id: '1',
          name: 'Access Point 1',
          type: 'access_point',
          status: 'online',
          ipAddress: '192.168.1.100',
          macAddress: '00:11:22:33:44:55',
          location: 'Building A',
        ),
        const Device(
          id: '2',
          name: 'Switch 1',
          type: 'switch',
          status: 'online',
          ipAddress: '10.0.0.50',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          location: 'Building B',
        ),
        const Device(
          id: '3',
          name: 'ONT Device',
          type: 'ont',
          status: 'offline',
          ipAddress: null,
          macAddress: null,
          location: null,
        ),
        const Device(
          id: '4',
          name: 'Router Main',
          type: 'access_point',
          status: 'online',
          ipAddress: '192.168.1.1',
          macAddress: '12:34:56:78:9A:BC',
          location: 'Server Room',
        ),
      ];
    });

    ProviderContainer createContainer(List<Device> devices) {
      return ProviderContainer(
        overrides: [
          devicesNotifierProvider.overrideWith(
            () => TestDevicesNotifier(devices),
          ),
        ],
      );
    }

    test('search matches device by full IP address', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      // Wait for devices to load
      await container.read(devicesNotifierProvider.future);

      // Set search query and filter type
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('192.168.1.100');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('1'));
    });

    test('search matches device by partial IP address', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('192.168');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      expect(filtered.length, equals(2));
      expect(filtered.map((d) => d.id).toList(), containsAll(['1', '4']));
    });

    test('search matches device by full MAC address', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('00:11:22:33:44:55');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('1'));
    });

    test('search matches device by partial MAC address', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('AA:BB');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('2'));
    });

    test('search is case-insensitive for MAC address', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      // Search with lowercase MAC
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('aa:bb:cc');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('2'));
    });

    test('search handles devices with null IP and MAC addresses', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      // Search for something that won't match
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('xyz123');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      // No matches, but no crash
      expect(filtered.length, equals(0));
    });

    test('search still matches by device name', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('Router Main');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('4'));
    });

    test('search still matches by location', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('Server Room');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('4'));
    });

    test('empty search returns all devices matching filter type', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      container.read(deviceUIStateNotifierProvider.notifier).setSearchQuery('');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      expect(filtered.length, equals(4));
    });

    test('whitespace-only search is treated as empty search', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('   ');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('all');

      final filtered = container.read(filteredDevicesListProvider);

      // Whitespace-only should return all devices (treated as empty)
      expect(filtered.length, equals(4));
    });

    test('search combined with type filter works correctly', () async {
      final container = createContainer(testDevices);
      addTearDown(container.dispose);

      await container.read(devicesNotifierProvider.future);

      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setSearchQuery('192.168');
      container
          .read(deviceUIStateNotifierProvider.notifier)
          .setFilterType('access_point');

      final filtered = container.read(filteredDevicesListProvider);

      // Both devices with 192.168 are access_points
      expect(filtered.length, equals(2));
      expect(filtered.every((d) => d.type == 'access_point'), isTrue);
    });
  });
}
