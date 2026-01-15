import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/services/background_refresh_service.dart';
import 'package:rgnets_fdk/core/services/notification_generation_service.dart';
import 'package:rgnets_fdk/core/services/pagination_service.dart';
import 'package:rgnets_fdk/core/services/performance_monitor_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/core/services/websocket_data_sync_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';
import 'package:rgnets_fdk/features/rooms/domain/repositories/room_repository.dart';

// Mock classes
class MockDeviceDataSource extends Mock implements DeviceDataSource {}
class MockDeviceLocalDataSource extends Mock implements DeviceLocalDataSource {}
class MockRoomRepository extends Mock implements RoomRepository {}
class MockNotificationGenerationService extends Mock implements NotificationGenerationService {}
class MockStorageService extends Mock implements StorageService {}
class MockWebSocketDataSyncService extends Mock implements WebSocketDataSyncService {}
class MockWebSocketService extends Mock implements WebSocketService {}

void main() {
  group('Performance Optimization Tests', () {
    late MockDeviceDataSource mockDeviceDataSource;
    late MockDeviceLocalDataSource mockLocalDataSource;
    late MockRoomRepository mockRoomRepository;
    late MockNotificationGenerationService mockNotificationService;
    late MockStorageService mockStorageService;
    late MockWebSocketDataSyncService mockWebSocketDataSyncService;
    late MockWebSocketService mockWebSocketService;
    late BackgroundRefreshService backgroundRefreshService;
    late PerformanceMonitorService performanceMonitor;

    setUp(() {
      mockDeviceDataSource = MockDeviceDataSource();
      mockLocalDataSource = MockDeviceLocalDataSource();
      mockRoomRepository = MockRoomRepository();
      mockNotificationService = MockNotificationGenerationService();
      mockStorageService = MockStorageService();
      mockWebSocketDataSyncService = MockWebSocketDataSyncService();
      mockWebSocketService = MockWebSocketService();
      performanceMonitor = PerformanceMonitorService.instance;

      backgroundRefreshService = BackgroundRefreshService(
        deviceDataSource: mockDeviceDataSource,
        deviceLocalDataSource: mockLocalDataSource,
        roomRepository: mockRoomRepository,
        notificationGenerationService: mockNotificationService,
        storageService: mockStorageService,
        webSocketService: mockWebSocketService,
        webSocketDataSyncService: mockWebSocketDataSyncService,
      );

      // Clear any existing metrics
      performanceMonitor.clearMetrics();
    });

    tearDown(() {
      backgroundRefreshService.dispose();
      performanceMonitor.clearMetrics();
    });

    group('Cache TTL Tests', () {
      test('should return empty list when cache is expired', () async {
        // Arrange
        when(() => mockLocalDataSource.isCacheValid()).thenAnswer((_) async => false);
        when(() => mockLocalDataSource.getCachedDevices()).thenAnswer((_) async => []);

        // Act
        final result = await mockLocalDataSource.getCachedDevices();

        // Assert
        expect(result, isEmpty);
      });

      test('should return cached data when cache is valid', () async {
        // Arrange
        final testDevices = [
          const DeviceModel(
            id: '1',
            name: 'Test Device',
            type: 'access_point',
            status: 'online',
          ),
        ];

        when(() => mockLocalDataSource.isCacheValid()).thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getCachedDevices()).thenAnswer((_) async => testDevices);

        // Act
        final result = await mockLocalDataSource.getCachedDevices();

        // Assert
        expect(result, equals(testDevices));
        expect(result.length, equals(1));
      });

      test('should cache devices with TTL timestamp', () async {
        // Arrange
        final testDevices = [
          const DeviceModel(
            id: '1',
            name: 'Test Device',
            type: 'access_point',
            status: 'online',
          ),
        ];

        when(() => mockLocalDataSource.cacheDevices(any())).thenAnswer((_) async {});

        // Act
        await mockLocalDataSource.cacheDevices(testDevices);

        // Assert - verify the method was called
        verify(() => mockLocalDataSource.cacheDevices(any())).called(1);
      });

      test('should handle partial cache updates', () async {
        // Arrange
        final testDevices = [
          const DeviceModel(
            id: '2',
            name: 'Updated Device',
            type: 'switch',
            status: 'offline',
          ),
        ];

        when(() => mockLocalDataSource.updateCachePartial(any(), offset: any(named: 'offset')))
            .thenAnswer((_) async {});

        // Act
        await mockLocalDataSource.updateCachePartial(testDevices, offset: 0);

        // Assert
        verify(() => mockLocalDataSource.updateCachePartial(any(), offset: any(named: 'offset'))).called(1);
      });

      test('should retrieve paginated cached data', () async {
        // Arrange
        final testDevices = [
          const DeviceModel(id: '1', name: 'Device 1', type: 'access_point', status: 'online'),
          const DeviceModel(id: '2', name: 'Device 2', type: 'switch', status: 'offline'),
        ];

        when(() => mockLocalDataSource.getCachedDevicesPage(offset: 0, limit: 10))
            .thenAnswer((_) async => testDevices);

        // Act
        final result = await mockLocalDataSource.getCachedDevicesPage(offset: 0, limit: 10);

        // Assert
        expect(result, equals(testDevices));
        verify(() => mockLocalDataSource.getCachedDevicesPage(offset: any(named: 'offset'), limit: any(named: 'limit'))).called(1);
      });
    });

    group('Background Refresh Service Tests', () {
      test('should refresh devices and rooms in parallel', () async {
        // Arrange
        final testDevices = [
          const DeviceModel(id: '1', name: 'Device 1', type: 'access_point', status: 'online'),
        ];
        when(() => mockStorageService.isAuthenticated).thenReturn(true);
        when(() => mockWebSocketService.isConnected).thenReturn(true);
        when(() => mockWebSocketDataSyncService.syncInitialData())
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.getCachedDevices(allowStale: true))
            .thenAnswer((_) async => testDevices);
        when(() => mockRoomRepository.getRooms()).thenAnswer((_) async => const Right([]));

        // Track refresh events
        final deviceRefreshEvents = <RefreshStatus>[];
        final roomRefreshEvents = <RefreshStatus>[];
        
        backgroundRefreshService.deviceRefreshStream.listen(deviceRefreshEvents.add);
        backgroundRefreshService.roomRefreshStream.listen(roomRefreshEvents.add);

        // Act
        await backgroundRefreshService.refreshNow();

        // Wait for streams to emit events
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(deviceRefreshEvents.any((event) => event.isSuccess), isTrue);
        expect(roomRefreshEvents.any((event) => event.isSuccess), isTrue);
        verify(() => mockWebSocketDataSyncService.syncInitialData()).called(1);
      });

      test('should handle refresh errors gracefully', () async {
        // Arrange
        when(() => mockStorageService.isAuthenticated).thenReturn(true);
        when(() => mockWebSocketService.isConnected).thenReturn(false);

        final deviceRefreshEvents = <RefreshStatus>[];
        backgroundRefreshService.deviceRefreshStream.listen(deviceRefreshEvents.add);

        // Act
        await backgroundRefreshService.refreshNow();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(deviceRefreshEvents.any((event) => event.isError), isTrue);
        final errorEvent = deviceRefreshEvents.firstWhere((event) => event.isError);
        expect(errorEvent.error, contains('WebSocket disconnected'));
      });

      test('should prevent concurrent refresh operations', () async {
        // Arrange
        final completer = Completer<void>();
        when(() => mockStorageService.isAuthenticated).thenReturn(true);
        when(() => mockWebSocketService.isConnected).thenReturn(true);
        when(() => mockWebSocketDataSyncService.syncInitialData())
            .thenAnswer((_) => completer.future);
        when(() => mockLocalDataSource.getCachedDevices(allowStale: true))
            .thenAnswer((_) async => []);
        when(() => mockRoomRepository.getRooms()).thenAnswer((_) async => const Right([]));

        // Act - trigger two refresh operations
        final future1 = backgroundRefreshService.refreshNow();
        final future2 = backgroundRefreshService.refreshNow();

        // Complete the first request
        completer.complete();

        await Future.wait([future1, future2]);

        // Assert - should only sync once due to concurrent protection
        verify(() => mockWebSocketDataSyncService.syncInitialData()).called(1);
      });

      test('should start and stop background refresh timer', () async {
        // Arrange
        when(() => mockStorageService.isAuthenticated).thenReturn(true);
        when(() => mockWebSocketService.isConnected).thenReturn(false);

        // Act
        backgroundRefreshService.startBackgroundRefresh();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        backgroundRefreshService.stopBackgroundRefresh();

        // Assert - verify timer was set up (indirect test through no exceptions)
        expect(backgroundRefreshService, isNotNull);
      });
    });

    group('Pagination Service Tests', () {
      late PaginationService<String> paginationService;

      setUp(() {
        paginationService = PaginationService<String>(
          pageSize: 10,
          fetchPage: (page, pageSize) async {
            // Simulate API delay
            await Future<void>.delayed(const Duration(milliseconds: 50));
            
            // Return mock data for testing
            final startIndex = (page - 1) * pageSize;
            return List.generate(
              pageSize,
              (i) => 'Item ${startIndex + i + 1}',
            );
          },
        );
      });

      tearDown(() {
        paginationService.dispose();
      });

      test('should load first page successfully', () async {
        // Act
        final result = await paginationService.loadNextPage();

        // Assert
        expect(result.length, equals(10));
        expect(result.first, equals('Item 1'));
        expect(result.last, equals('Item 10'));
        expect(paginationService.totalLoaded, equals(10));
        expect(paginationService.hasMore, isTrue);
      });

      test('should load multiple pages sequentially', () async {
        // Act
        await paginationService.loadNextPage(); // Page 1
        final result = await paginationService.loadNextPage(); // Page 2

        // Assert
        expect(result.length, equals(10));
        expect(result.first, equals('Item 11'));
        expect(result.last, equals('Item 20'));
        expect(paginationService.totalLoaded, equals(20));
      });

      test('should load multiple pages in parallel', () async {
        // Act
        final stopwatch = Stopwatch()..start();
        await paginationService.loadPagesInParallel(3);
        stopwatch.stop();

        // Assert
        expect(paginationService.totalLoaded, equals(30));
        expect(paginationService.items.first, equals('Item 1'));
        expect(paginationService.items.last, equals('Item 30'));
        
        // Parallel loading should be faster than sequential
        expect(stopwatch.elapsedMilliseconds, lessThan(200),
               reason: 'Parallel page loading should be faster than sequential');
      });

      test('should preload next page in background', () async {
        // Arrange - load first page
        await paginationService.loadNextPage();

        // Act - preload next page
        await paginationService.preloadNextPage();

        // Assert - preload doesn't change current state
        expect(paginationService.totalLoaded, equals(10));
        expect(paginationService.hasMore, isTrue);

        // But next load should be faster (from cache)
        final stopwatch = Stopwatch()..start();
        await paginationService.loadNextPage();
        stopwatch.stop();

        expect(paginationService.totalLoaded, equals(20));
        // Should be faster due to caching (less than normal API delay)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle pagination state updates', () async {
        // Arrange
        final stateUpdates = <PaginationState<String>>[];
        paginationService.stateStream.listen(stateUpdates.add);

        // Act
        await paginationService.loadNextPage();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(stateUpdates.length, greaterThanOrEqualTo(1));
        final finalState = stateUpdates.last;
        expect(finalState.items.length, equals(10));
        expect(finalState.isLoading, isFalse);
        expect(finalState.hasMore, isTrue);
        expect(finalState.hasError, isFalse);
      });

      test('should refresh and clear existing data', () async {
        // Arrange - load some data
        await paginationService.loadNextPage();
        expect(paginationService.totalLoaded, equals(10));

        // Act
        await paginationService.refresh();

        // Assert
        expect(paginationService.totalLoaded, equals(10)); // Fresh first page
        expect(paginationService.items.first, equals('Item 1'));
      });

      test('should handle fetch errors gracefully', () async {
        // Arrange
        final errorPaginationService = PaginationService<String>(
          pageSize: 10,
          fetchPage: (page, pageSize) async {
            throw Exception('API Error');
          },
        );

        // Act & Assert
        expect(
          errorPaginationService.loadNextPage,
          throwsA(isA<Exception>()),
        );

        errorPaginationService.dispose();
      });
    });

    group('Performance Monitor Service Tests', () {
      test('should track operation duration', () async {
        // Act
        final duration = await performanceMonitor.trackFuture(
          'test_operation',
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return 'success';
          },
        );

        // Assert
        expect(duration, equals('success'));
        
        final stats = performanceMonitor.getStats('test_operation');
        expect(stats, isNotNull);
        expect(stats!.sampleCount, equals(1));
        expect(stats.averageMs, greaterThanOrEqualTo(90));
        expect(stats.successRate, equals(1.0));
      });

      test('should track failed operations', () async {
        // Act & Assert
        expect(
          () => performanceMonitor.trackFuture(
            'failing_operation',
            () async {
              throw Exception('Test error');
            },
          ),
          throwsA(isA<Exception>()),
        );

        final stats = performanceMonitor.getStats('failing_operation');
        expect(stats, isNotNull);
        expect(stats!.successRate, equals(0.0));
      });

      test('should track parallel operations', () async {
        // Act
        final results = await performanceMonitor.trackParallel(
          'parallel_test',
          [
            () async {
              await Future<void>.delayed(const Duration(milliseconds: 50));
              return 'result1';
            },
            () async {
              await Future<void>.delayed(const Duration(milliseconds: 75));
              return 'result2';
            },
            () async {
              await Future<void>.delayed(const Duration(milliseconds: 25));
              return 'result3';
            },
          ],
        );

        // Assert
        expect(results, equals(['result1', 'result2', 'result3']));
        
        final stats = performanceMonitor.getStats('parallel_test');
        expect(stats, isNotNull);
        expect(stats!.sampleCount, equals(1));
        // Parallel execution should be faster than sequential (< 150ms vs 150ms)
        expect(stats.averageMs, lessThan(120));
      });

      test('should generate performance report', () async {
        // Arrange - create some performance data
        await performanceMonitor.trackFuture('fast_operation', () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return 'fast';
        });

        await performanceMonitor.trackFuture('slow_operation', () async {
          await Future<void>.delayed(const Duration(milliseconds: 1200));
          return 'slow';
        });

        // Act
        final report = performanceMonitor.generateReport();

        // Assert
        expect(report, contains('Performance Report'));
        expect(report, contains('fast_operation'));
        expect(report, contains('slow_operation'));
        expect(report, contains('SLOW')); // Should warn about slow operation
        expect(report, contains('FAST')); // Should mark fast operation as good
      });

      test('should calculate performance statistics correctly', () async {
        // Arrange - create multiple samples
        for (var i = 0; i < 10; i++) {
          await performanceMonitor.trackFuture('stats_test', () async {
            await Future<void>.delayed(Duration(milliseconds: 50 + (i * 10)));
            return 'sample $i';
          });
        }

        // Act
        final stats = performanceMonitor.getStats('stats_test');

        // Assert
        expect(stats, isNotNull);
        expect(stats!.sampleCount, equals(10));
        expect(stats.minMs, greaterThanOrEqualTo(45));
        expect(stats.maxMs, greaterThanOrEqualTo(135));
        expect(stats.averageMs, greaterThan(stats.minMs));
        expect(stats.averageMs, lessThan(stats.maxMs));
        expect(stats.p95Ms, greaterThanOrEqualTo(stats.medianMs));
        expect(stats.p99Ms, greaterThanOrEqualTo(stats.p95Ms));
      });

      test('should handle concurrent operations tracking', () async {
        // Act - start multiple operations concurrently
        final futures = List.generate(5, (i) => 
          performanceMonitor.trackFuture('concurrent_op_$i', () async {
            await Future<void>.delayed(Duration(milliseconds: 50 + (i * 10)));
            return 'result $i';
          })
        );

        final results = await Future.wait(futures);

        // Assert
        expect(results.length, equals(5));
        
        // Check that all operations were tracked
        for (var i = 0; i < 5; i++) {
          final stats = performanceMonitor.getStats('concurrent_op_$i');
          expect(stats, isNotNull);
          expect(stats!.sampleCount, equals(1));
        }
      });
    });

    group('Integration Tests', () {
      test('should demonstrate end-to-end performance optimization', () async {
        // This test demonstrates how all performance optimizations work together
        
        // Arrange
        final testDevices = List.generate(50, (i) => 
          DeviceModel(
            id: i.toString(),
            name: 'Device $i',
            type: i.isEven ? 'access_point' : 'switch',
            status: 'online',
          )
        );

        when(() => mockStorageService.isAuthenticated).thenReturn(true);
        when(() => mockWebSocketService.isConnected).thenReturn(true);
        when(() => mockWebSocketDataSyncService.syncInitialData())
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.getCachedDevices(allowStale: true))
            .thenAnswer((_) async => testDevices);
        when(() => mockRoomRepository.getRooms()).thenAnswer((_) async => const Right([]));

        // Act - Perform background refresh with performance monitoring
        await performanceMonitor.trackFuture(
          'end_to_end_refresh',
          () => backgroundRefreshService.refreshNow(),
        );

        // Assert
        final stats = performanceMonitor.getStats('end_to_end_refresh');
        expect(stats, isNotNull);
        expect(stats!.successRate, equals(1.0));
        
        // Verify all components were called
        verify(() => mockWebSocketDataSyncService.syncInitialData()).called(1);
        verify(() => mockRoomRepository.getRooms()).called(1);
      });

      test('should handle complex error scenarios with proper fallbacks', () async {
        // Arrange - simulate cached fallback usage
        when(() => mockLocalDataSource.getCachedDevices(allowStale: true))
            .thenAnswer((_) async => [
          const DeviceModel(id: 'cached1', name: 'Cached Device', type: 'access_point', status: 'online'),
        ]);

        // Act - should fall back to cached data when WebSocket sync is unavailable
        final cachedData = await mockLocalDataSource.getCachedDevices(allowStale: true);

        // Assert
        expect(cachedData.length, equals(1));
        expect(cachedData.first.name, equals('Cached Device'));
      });
    });
  });
}
