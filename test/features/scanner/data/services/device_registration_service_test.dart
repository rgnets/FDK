import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/scanner/data/services/device_registration_service.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';

class _MockWebSocketService extends Mock implements WebSocketService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // mocktail requires a fallback for non-primitive types used with any().
    registerFallbackValue(const Duration(seconds: 1));
  });

  late _MockWebSocketService ws;
  late DeviceRegistrationService service;

  setUp(() {
    ws = _MockWebSocketService();
    service = DeviceRegistrationService(webSocketService: ws);
  });

  group('DeviceRegistrationService.registerDevice', () {
    test('returns failure when WebSocket is not connected', () async {
      when(() => ws.isConnected).thenReturn(false);

      final outcome = await service.registerDevice(
        deviceType: DeviceType.ont,
        mac: '0C8247840738',
        serialNumber: 'ALCLFDFCBB18',
        pmsRoomId: 8,
      );

      expect(outcome.success, isFalse);
      expect(outcome.errorMessage, 'WebSocket not connected');
      expect(outcome.status, 0);
      verifyNever(
        () => ws.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          additionalData: any(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      );
    });

    test('surfaces the backend error message verbatim on action=error', () async {
      when(() => ws.isConnected).thenReturn(true);
      when(
        () => ws.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          additionalData: any(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => const SocketMessage(
          type: 'error',
          payload: {
            'action': 'error',
            'error': 'No OLT/PON device found.',
            'status': 404,
          },
        ),
      );

      final outcome = await service.registerDevice(
        deviceType: DeviceType.ont,
        mac: '0C8247840738',
        serialNumber: 'ALCLFDFCBB18',
        pmsRoomId: 8,
      );

      expect(outcome.success, isFalse);
      expect(outcome.errorMessage, 'No OLT/PON device found.');
      expect(outcome.status, 404);
    });

    test(
      'falls back to a synthesized message when backend returns error=null '
      '(reproduces the observed rXg-side bug)',
      () async {
        when(() => ws.isConnected).thenReturn(true);
        when(
          () => ws.requestActionCable(
            action: any(named: 'action'),
            resourceType: any(named: 'resourceType'),
            additionalData: any(named: 'additionalData'),
            timeout: any(named: 'timeout'),
          ),
        ).thenAnswer(
          (_) async => const SocketMessage(
            type: 'error',
            payload: {
              'action': 'error',
              'error': null,
              'status': 404,
            },
          ),
        );

        final outcome = await service.registerDevice(
          deviceType: DeviceType.ont,
          mac: '0C8247840738',
          serialNumber: 'ALCLFDFCBB18',
          pmsRoomId: 8,
        );

        expect(outcome.success, isFalse);
        expect(outcome.errorMessage, 'Registration failed (status 404)');
        expect(outcome.status, 404);
      },
    );

    test('returns success on action=resource_response with status 200', () async {
      when(() => ws.isConnected).thenReturn(true);
      when(
        () => ws.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          additionalData: any(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => const SocketMessage(
          type: 'resource_response',
          payload: {
            'action': 'resource_response',
            'status': 200,
            'data': {'id': 4242, 'name': 'Room12-CBB1'},
          },
        ),
      );

      final outcome = await service.registerDevice(
        deviceType: DeviceType.ont,
        mac: '0C8247840738',
        serialNumber: 'ALCLFDFCBB18',
        pmsRoomId: 8,
      );

      expect(outcome.success, isTrue);
      expect(outcome.status, 200);
      expect(outcome.errorMessage, isNull);
      expect(outcome.data, isNotNull);
      expect(outcome.data!['id'], 4242);
    });

    test('treats status>=400 as failure even when action is not "error"', () async {
      when(() => ws.isConnected).thenReturn(true);
      when(
        () => ws.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          additionalData: any(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => const SocketMessage(
          type: 'resource_response',
          payload: {
            'action': 'resource_response',
            'status': 422,
            'error': 'serial_number is already taken',
          },
        ),
      );

      final outcome = await service.registerDevice(
        deviceType: DeviceType.ont,
        mac: '0C8247840738',
        serialNumber: 'ALCLFDFCBB18',
        pmsRoomId: 8,
      );

      expect(outcome.success, isFalse);
      expect(outcome.errorMessage, 'serial_number is already taken');
      expect(outcome.status, 422);
    });

    test('returns failure with the exception message on non-timeout errors', () async {
      when(() => ws.isConnected).thenReturn(true);
      when(
        () => ws.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          additionalData: any(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      ).thenThrow(StateError('socket closed mid-flight'));

      final outcome = await service.registerDevice(
        deviceType: DeviceType.ont,
        mac: '0C8247840738',
        serialNumber: 'ALCLFDFCBB18',
        pmsRoomId: 8,
      );

      expect(outcome.success, isFalse);
      expect(outcome.errorMessage, contains('socket closed mid-flight'));
      expect(outcome.status, 0);
    });

    test('switch update path sets crud_action=update and passes id when existingDeviceId is provided', () async {
      when(() => ws.isConnected).thenReturn(true);
      when(
        () => ws.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          additionalData: any(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => const SocketMessage(
          type: 'resource_response',
          payload: {'status': 200},
        ),
      );

      await service.registerDevice(
        deviceType: DeviceType.switchDevice,
        mac: 'cc',
        serialNumber: 's',
        pmsRoomId: 1,
        existingDeviceId: 99,
        model: 'icx7150',
      );

      final calls = verify(
        () => ws.requestActionCable(
          action: 'resource_action',
          resourceType: 'switch_devices',
          additionalData: captureAny(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      ).captured;

      expect(calls, hasLength(1));
      final additional = calls.single as Map;
      expect(additional['crud_action'], 'update');
      expect(additional['id'], 99);
      expect(additional['model'], 'icx7150');
    });

    test('returns failure with the timeout message on TimeoutException', () async {
      when(() => ws.isConnected).thenReturn(true);
      when(
        () => ws.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          additionalData: any(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      ).thenThrow(TimeoutException('Request timed out: abc'));

      final outcome = await service.registerDevice(
        deviceType: DeviceType.ont,
        mac: '0C8247840738',
        serialNumber: 'ALCLFDFCBB18',
        pmsRoomId: 8,
      );

      expect(outcome.success, isFalse);
      expect(outcome.errorMessage, 'Timed out waiting for backend');
      expect(outcome.status, 0);
    });

    test('sends the correct resource_type and crud_action per device type', () async {
      when(() => ws.isConnected).thenReturn(true);
      when(
        () => ws.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          additionalData: any(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => const SocketMessage(
          type: 'resource_response',
          payload: {'status': 200},
        ),
      );

      await service.registerDevice(
        deviceType: DeviceType.ont,
        mac: 'aa',
        serialNumber: 's',
        pmsRoomId: 1,
      );
      await service.registerDevice(
        deviceType: DeviceType.accessPoint,
        mac: 'bb',
        serialNumber: 's',
        pmsRoomId: 1,
      );
      await service.registerDevice(
        deviceType: DeviceType.switchDevice,
        mac: 'cc',
        serialNumber: 's',
        pmsRoomId: 1,
      );

      final calls = verify(
        () => ws.requestActionCable(
          action: 'resource_action',
          resourceType: captureAny(named: 'resourceType'),
          additionalData: captureAny(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      ).captured;

      // Each call captures two values (resourceType, additionalData) → 6 total.
      expect(calls, hasLength(6));

      // ONT
      expect(calls[0], 'media_converters');
      expect((calls[1] as Map)['crud_action'], 'register_ont_device');

      // AP
      expect(calls[2], 'access_points');
      expect((calls[3] as Map)['crud_action'], 'register_ap_device');

      // Switch (no existingDeviceId → create)
      expect(calls[4], 'switch_devices');
      expect((calls[5] as Map)['crud_action'], 'create');

      // None of the additionalData maps should contain reserved keys.
      for (final additional in [calls[1], calls[3], calls[5]]) {
        final map = additional as Map;
        expect(map.containsKey('action'), isFalse);
        expect(map.containsKey('resource_type'), isFalse);
        expect(map.containsKey('request_id'), isFalse);
      }
    });
  });
}
