import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/device_registration_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/test_app_harness.dart';

/// Serves a fixed device list so the registration notifier can resolve a
/// just-registered device out of the live cache.
class _TestDevicesNotifier extends DevicesNotifier {
  _TestDevicesNotifier(this._devices);

  final List<Device> _devices;

  @override
  Future<List<Device>> build() async => _devices;
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<ProviderContainer> containerWith(List<Device> devices) async {
    final container = createTestContainer(
      sharedPreferences: prefs,
      overrides: [
        devicesNotifierProvider.overrideWith(() => _TestDevicesNotifier(devices)),
        // The cache integration's snapshot refresh fires a detached REST
        // reseed that needs live credentials/WS; stub it out so the resolver's
        // best-effort refresh is a no-op under test.
        webSocketCacheIntegrationProvider.overrideWith((ref) {
          final integration = WebSocketCacheIntegration(
            webSocketService: ref.watch(webSocketServiceProvider),
            onResourceReseed: (_) async {},
            onReconnectReseed: ({bool force = false}) async {},
          );
          ref.onDispose(integration.dispose);
          return integration;
        }),
      ],
    );
    await container.read(devicesNotifierProvider.future);
    return container;
  }

  group('locateRegisteredDeviceId', () {
    test('returns the canonical prefixed id of the AP matching the scanned MAC',
        () async {
      final container = await containerWith(const [
        Device(
          id: 'ap_4437',
          name: 'AP1',
          type: 'access_point',
          status: 'online',
          macAddress: 'aa:bb:cc:dd:ee:ff',
        ),
        Device(
          id: 'ont_12',
          name: 'ONT1',
          type: 'ont',
          status: 'online',
          macAddress: '11:22:33:44:55:66',
        ),
      ]);

      final id = await container
          .read(deviceRegistrationNotifierProvider.notifier)
          .locateRegisteredDeviceId(
            mac: 'AABBCCDDEEFF',
            deviceType: DeviceType.accessPoint,
          );

      expect(id, 'ap_4437');
    });

    test('ignores a same-MAC device of a different type', () async {
      // A stale duplicate-MAC row of another type must not be resolved.
      final container = await containerWith(const [
        Device(
          id: 'sw_77',
          name: 'StaleSwitch',
          type: 'switch',
          status: 'offline',
          macAddress: 'aa:bb:cc:dd:ee:ff',
        ),
        Device(
          id: 'ap_4437',
          name: 'AP1',
          type: 'access_point',
          status: 'online',
          macAddress: 'aa:bb:cc:dd:ee:ff',
        ),
      ]);

      final id = await container
          .read(deviceRegistrationNotifierProvider.notifier)
          .locateRegisteredDeviceId(
            mac: 'AABBCCDDEEFF',
            deviceType: DeviceType.accessPoint,
          );

      expect(id, 'ap_4437');
    });

    test('matches regardless of MAC separators or case', () async {
      final container = await containerWith(const [
        Device(
          id: 'sw_9',
          name: 'Switch1',
          type: 'switch',
          status: 'online',
          macAddress: 'AA-BB-CC-11-22-33',
        ),
      ]);

      final id = await container
          .read(deviceRegistrationNotifierProvider.notifier)
          .locateRegisteredDeviceId(
            mac: 'aabbcc112233',
            deviceType: DeviceType.switchDevice,
          );

      expect(id, 'sw_9');
    });
  });
}
