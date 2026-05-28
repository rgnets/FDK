import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/scanner/data/services/device_registration_service.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';

class _MockWebSocketService extends Mock implements WebSocketService {}

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // mocktail requires a fallback for non-primitive types used with any().
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(Uri.parse('https://example.test'));
  });

  late _MockWebSocketService ws;
  late _MockHttpClient httpClient;
  late DeviceRegistrationService service;

  setUp(() {
    ws = _MockWebSocketService();
    httpClient = _MockHttpClient();
    service = DeviceRegistrationService(
      webSocketService: ws,
      httpClient: httpClient,
    );
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

    test(
      'surfaces controller error text from payload.data.message when payload.error is absent',
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
            type: 'resource_response',
            payload: {
              'action': 'resource_response',
              'status': 404,
              'data': {'message': 'Existing ONT not found for id 2'},
            },
          ),
        );

        final outcome = await service.registerDevice(
          deviceType: DeviceType.ont,
          mac: '00E63A2D2570',
          serialNumber: '292372002215',
          pmsRoomId: 2,
          existingDeviceId: 2,
        );

        expect(outcome.success, isFalse);
        expect(outcome.errorMessage, 'Existing ONT not found for id 2');
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

    test('switch path passes switch_device_id when existingDeviceId is provided', () async {
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
      expect(additional['crud_action'], 'register_switch_device');
      expect(additional['switch_device_id'], 99);
      // The model param is no longer sent to the rXg by the new dedicated
      // action; it has nothing to do with onboarding.
      expect(additional.containsKey('model'), isFalse);
      expect(additional.containsKey('id'), isFalse);
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

    test('sends the correct resource_type and crud_action per WS device type', () async {
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

      // Access Points register over REST, not WebSocket, so only ONT and
      // switch flow through requestActionCable.
      await service.registerDevice(
        deviceType: DeviceType.ont,
        mac: 'aa',
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

      // Each call captures two values (resourceType, additionalData) → 4 total.
      expect(calls, hasLength(4));

      // ONT
      expect(calls[0], 'media_converters');
      expect((calls[1] as Map)['crud_action'], 'register_ont_device');

      // Switch
      expect(calls[2], 'switch_devices');
      expect((calls[3] as Map)['crud_action'], 'register_switch_device');

      // None of the additionalData maps should contain reserved keys.
      for (final additional in [calls[1], calls[3]]) {
        final map = additional as Map;
        expect(map.containsKey('action'), isFalse);
        expect(map.containsKey('resource_type'), isFalse);
        expect(map.containsKey('request_id'), isFalse);
      }
    });
  });

  group('DeviceRegistrationService.registerDevice (AP REST path)', () {
    test('never touches the WebSocket for Access Points', () async {
      when(() => ws.isConnected).thenReturn(true);
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('{"message":"ok"}', 200));

      await service.registerDevice(
        deviceType: DeviceType.accessPoint,
        mac: 'bb',
        serialNumber: 's',
        pmsRoomId: 1,
        siteUrl: 'rxg.example.test',
        apiKey: 'secret',
      );

      verifyNever(
        () => ws.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          additionalData: any(named: 'additionalData'),
          timeout: any(named: 'timeout'),
        ),
      );
    });

    test('POSTs to register_ap_device with the scanned fields', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"message":"Updated existing AP PMS room.","access_point":{"id":7}}',
          200,
        ),
      );

      final outcome = await service.registerDevice(
        deviceType: DeviceType.accessPoint,
        mac: '00E63A2D2570',
        serialNumber: '292372002215',
        pmsRoomId: 2,
        existingDeviceId: 7,
        siteUrl: 'https://rxg.example.test/',
        apiKey: 'secret',
      );

      expect(outcome.success, isTrue);
      expect(outcome.status, 200);
      expect(outcome.data?['access_point'], isA<Map<String, dynamic>>());

      final captured = verify(
        () => httpClient.post(
          captureAny(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;
      final uri = captured[0] as Uri;
      final body = jsonDecode(captured[1] as String) as Map<String, dynamic>;

      // Scheme + trailing slash normalized away from the stored siteUrl.
      expect(uri.toString(),
          'https://rxg.example.test/api/access_points/register_ap_device.json?api_key=secret');
      expect(body['serial_number'], '292372002215');
      expect(body['mac'], '00E63A2D2570');
      expect(body['pms_room_id'], 2);
      expect(body['ap_id'], 7);
    });

    test('treats HTTP 201 as success', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"message":"Access Point created."}', 201),
      );

      final outcome = await service.registerDevice(
        deviceType: DeviceType.accessPoint,
        mac: 'bb',
        serialNumber: 's',
        pmsRoomId: 1,
        siteUrl: 'rxg.example.test',
        apiKey: 'secret',
      );

      expect(outcome.success, isTrue);
      expect(outcome.status, 201);
    });

    test('surfaces the controller message on a 4xx', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          '{"message":"PMS Room not found for id 99"}',
          404,
        ),
      );

      final outcome = await service.registerDevice(
        deviceType: DeviceType.accessPoint,
        mac: 'bb',
        serialNumber: 's',
        pmsRoomId: 99,
        siteUrl: 'rxg.example.test',
        apiKey: 'secret',
      );

      expect(outcome.success, isFalse);
      expect(outcome.errorMessage, 'PMS Room not found for id 99');
      expect(outcome.status, 404);
    });

    test('fails without calling HTTP when credentials are missing', () async {
      final outcome = await service.registerDevice(
        deviceType: DeviceType.accessPoint,
        mac: 'bb',
        serialNumber: 's',
        pmsRoomId: 1,
        siteUrl: null,
        apiKey: null,
      );

      expect(outcome.success, isFalse);
      expect(outcome.errorMessage, 'Not signed in');
      expect(outcome.status, 0);
      verifyNever(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      );
    });

    test('returns the timeout message on TimeoutException', () async {
      when(
        () => httpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(TimeoutException('slow'));

      final outcome = await service.registerDevice(
        deviceType: DeviceType.accessPoint,
        mac: 'bb',
        serialNumber: 's',
        pmsRoomId: 1,
        siteUrl: 'rxg.example.test',
        apiKey: 'secret',
      );

      expect(outcome.success, isFalse);
      expect(outcome.errorMessage, 'Timed out waiting for backend');
      expect(outcome.status, 0);
    });
  });
}
