import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/core/services/websocket_data_sync_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/typed_device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_local_data_source.dart';

class MockWebSocketService extends Mock implements WebSocketService {}

class MockAPLocalDataSource extends Mock implements APLocalDataSource {}

class MockONTLocalDataSource extends Mock implements ONTLocalDataSource {}

class MockSwitchLocalDataSource extends Mock implements SwitchLocalDataSource {}

class MockWLANLocalDataSource extends Mock implements WLANLocalDataSource {}

class MockRoomLocalDataSource extends Mock implements RoomLocalDataSource {}

class MockCacheManager extends Mock implements CacheManager {}

class MockStorageService extends Mock implements StorageService {}


void main() {
  late MockWebSocketService mockWebSocketService;
  late MockAPLocalDataSource mockAPDataSource;
  late MockONTLocalDataSource mockONTDataSource;
  late MockSwitchLocalDataSource mockSwitchDataSource;
  late MockWLANLocalDataSource mockWLANDataSource;
  late MockRoomLocalDataSource mockRoomDataSource;
  late MockCacheManager mockCacheManager;
  late MockStorageService mockStorageService;
  late StreamController<SocketMessage> messageController;
  late StreamController<SocketConnectionState> stateController;
  late WebSocketDataSyncService service;

  setUpAll(() {
    // Register fallback values BEFORE any setUp that uses any()
    registerFallbackValue(<DeviceModelSealed>[]);
    registerFallbackValue(<RoomModel>[]);
    registerFallbackValue(Duration.zero);
    registerFallbackValue(const SocketMessage(type: '', payload: {}));
  });

  setUp(() {
    mockWebSocketService = MockWebSocketService();
    mockAPDataSource = MockAPLocalDataSource();
    mockONTDataSource = MockONTLocalDataSource();
    mockSwitchDataSource = MockSwitchLocalDataSource();
    mockWLANDataSource = MockWLANLocalDataSource();
    mockRoomDataSource = MockRoomLocalDataSource();
    mockCacheManager = MockCacheManager();
    mockStorageService = MockStorageService();
    messageController = StreamController<SocketMessage>.broadcast();
    stateController = StreamController<SocketConnectionState>.broadcast();

    when(() => mockWebSocketService.messages)
        .thenAnswer((_) => messageController.stream);
    when(() => mockWebSocketService.connectionState)
        .thenAnswer((_) => stateController.stream);
    when(() => mockWebSocketService.isConnected).thenReturn(true);
    when(() => mockWebSocketService.send(any())).thenReturn(null);
    when(() => mockWebSocketService.requestActionCable(
          action: any(named: 'action'),
          resourceType: any(named: 'resourceType'),
          timeout: any(named: 'timeout'),
        )).thenAnswer((_) async => const SocketMessage(
          type: 'response',
          payload: {'data': []},
        ));

    // Storage mock defaults
    when(() => mockStorageService.token).thenReturn('test-token');

    service = WebSocketDataSyncService(
      socketService: mockWebSocketService,
      apLocalDataSource: mockAPDataSource,
      ontLocalDataSource: mockONTDataSource,
      switchLocalDataSource: mockSwitchDataSource,
      wlanLocalDataSource: mockWLANDataSource,
      roomLocalDataSource: mockRoomDataSource,
      cacheManager: mockCacheManager,
      storageService: mockStorageService,
      logger: Logger(level: Level.off),
    );
  });

  tearDown(() async {
    service.stop();
    await messageController.close();
    await stateController.close();
  });

  group('WebSocketDataSyncService', () {
    group('events stream', () {
      test('emits events when created', () {
        expect(service.events, isNotNull);
      });
    });

    group('start and stop', () {
      test('start subscribes to websocket messages', () {
        service.start();

        verify(() => mockWebSocketService.messages).called(greaterThan(0));
      });

      test('stop cancels subscriptions', () {
        service.start();
        service.stop();

        // Should not throw when stop is called again
        service.stop();
      });
    });

    group('message handling with data key', () {
      test('processes device snapshot from data key', () async {
        // Stub cache methods
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});

        service.start();

        // Simulate a snapshot message with 'data' key (backend format)
        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'access_points',
            'data': [
              {
                'id': 1,
                'name': 'AP-100',
                'type': 'AccessPoint',
                'online': true,
                'mac_address': 'AA:BB:CC:DD:EE:FF',
              },
              {
                'id': 2,
                'name': 'AP-200',
                'type': 'AccessPoint',
                'online': false,
                'mac_address': '11:22:33:44:55:66',
              },
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        // Wait for async processing
        await Future<void>.delayed(const Duration(milliseconds: 50));

        verify(() => mockAPDataSource.cacheDevices(any())).called(1);
      });

      test('processes device snapshot from results key (fallback)', () async {
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});

        service.start();

        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'access_points',
            'results': [
              {
                'id': 1,
                'name': 'AP-100',
                'type': 'AccessPoint',
                'online': true,
              },
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        verify(() => mockAPDataSource.cacheDevices(any())).called(1);
      });
    });

    group('device status determination', () {
      test('online boolean true maps to online status', () async {
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});

        service.start();

        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'access_points',
            'data': [
              {'id': 1, 'name': 'AP-1', 'type': 'AccessPoint', 'online': true},
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final captured = verify(
          () => mockAPDataSource.cacheDevices(captureAny()),
        ).captured.first as List<DeviceModelSealed>;

        expect(captured.first.status, 'online');
      });

      test('online boolean false maps to offline status', () async {
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});

        service.start();

        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'access_points',
            'data': [
              {'id': 1, 'name': 'AP-1', 'type': 'AccessPoint', 'online': false},
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final captured = verify(
          () => mockAPDataSource.cacheDevices(captureAny()),
        ).captured.first as List<DeviceModelSealed>;

        expect(captured.first.status, 'offline');
      });

      test('string status online is preserved', () async {
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});

        service.start();

        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'access_points',
            'data': [
              {'id': 1, 'name': 'AP-1', 'type': 'AccessPoint', 'status': 'online'},
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final captured = verify(
          () => mockAPDataSource.cacheDevices(captureAny()),
        ).captured.first as List<DeviceModelSealed>;

        expect(captured.first.status, 'online');
      });

      test('no status info defaults to unknown', () async {
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});

        service.start();

        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'access_points',
            'data': [
              {'id': 1, 'name': 'AP-1', 'type': 'AccessPoint'},
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final captured = verify(
          () => mockAPDataSource.cacheDevices(captureAny()),
        ).captured.first as List<DeviceModelSealed>;

        expect(captured.first.status, 'unknown');
      });
    });

    group('image extraction', () {
      test('extracts images from images list', () async {
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});

        service.start();

        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'access_points',
            'data': [
              {
                'id': 1,
                'name': 'AP-1',
                'type': 'AccessPoint',
                'online': true,
                'images': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
              },
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final captured = verify(
          () => mockAPDataSource.cacheDevices(captureAny()),
        ).captured.first as List<DeviceModelSealed>;

        expect(captured.first.images, hasLength(2));
        expect(captured.first.images?.first, 'https://example.com/img1.jpg');
      });

      test('extracts images from image objects with url key', () async {
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});

        service.start();

        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'access_points',
            'data': [
              {
                'id': 1,
                'name': 'AP-1',
                'type': 'AccessPoint',
                'online': true,
                'images': [
                  {'url': 'https://example.com/img1.jpg'},
                  {'url': 'https://example.com/img2.jpg'},
                ],
              },
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final captured = verify(
          () => mockAPDataSource.cacheDevices(captureAny()),
        ).captured.first as List<DeviceModelSealed>;

        expect(captured.first.images, hasLength(2));
      });

      test('returns null when no images present', () async {
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});

        service.start();

        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'access_points',
            'data': [
              {'id': 1, 'name': 'AP-1', 'type': 'AccessPoint', 'online': true},
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        final captured = verify(
          () => mockAPDataSource.cacheDevices(captureAny()),
        ).captured.first as List<DeviceModelSealed>;

        expect(captured.first.images, isNull);
      });
    });

    group('room snapshot handling', () {
      test('caches rooms from snapshot', () async {
        when(() => mockRoomDataSource.cacheRooms(any()))
            .thenAnswer((_) async {});

        service.start();

        messageController.add(SocketMessage(
          type: 'message',
          payload: {
            'action': 'snapshot',
            'resource_type': 'pms_rooms',
            'data': [
              {'id': 1, 'room': 'Room 101', 'floor': '1st'},
              {'id': 2, 'room': 'Room 202', 'floor': '2nd'},
            ],
          },
          headers: {'identifier': '{"channel":"RxgChannel"}'},
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));

        verify(() => mockRoomDataSource.cacheRooms(any())).called(1);
      });
    });

    group('syncInitialData', () {
      test('returns true on successful sync', () async {
        when(() => mockAPDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});
        when(() => mockONTDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});
        when(() => mockSwitchDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});
        when(() => mockWLANDataSource.cacheDevices(any()))
            .thenAnswer((_) async {});
        when(() => mockRoomDataSource.cacheRooms(any()))
            .thenAnswer((_) async {});

        // Stub flushNow() for all device datasources
        when(() => mockAPDataSource.flushNow())
            .thenAnswer((_) async {});
        when(() => mockONTDataSource.flushNow())
            .thenAnswer((_) async {});
        when(() => mockSwitchDataSource.flushNow())
            .thenAnswer((_) async {});
        when(() => mockWLANDataSource.flushNow())
            .thenAnswer((_) async {});

        // Stub storage for persisting ID-to-type index
        when(() => mockStorageService.setString(any(), any()))
            .thenAnswer((_) async => true);

        // Start sync (non-blocking) and then send snapshot responses
        final syncFuture = service.syncInitialData(
          timeout: const Duration(seconds: 5),
        );

        // Simulate snapshot responses for all 5 resource types
        await Future<void>.delayed(const Duration(milliseconds: 10));
        for (final resourceType in [
          'access_points',
          'media_converters',
          'switch_devices',
          'wlan_devices',
          'pms_rooms',
        ]) {
          messageController.add(SocketMessage(
            type: 'message',
            payload: {
              'action': 'snapshot',
              'resource_type': resourceType,
              'data': <Map<String, dynamic>>[],
            },
            headers: {'identifier': '{"channel":"RxgChannel"}'},
          ));
        }

        final result = await syncFuture;
        expect(result, isTrue);
      });
    });
  });
}
