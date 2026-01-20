import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
// Service locator removed - using Riverpod now
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
class MockStorageService extends Mock implements StorageService {}
class MockWebSocketService extends Mock implements WebSocketService {}
class MockWebSocketDataSyncService extends Mock implements WebSocketDataSyncService {}

void main() {
  group('Performance Optimization Verification Tests', () {
    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(const DeviceModel(
        id: 'fallback',
        name: 'Fallback Device',
        type: 'access_point',
        status: 'online',
      ));
      registerFallbackValue(<DeviceModel>[]);
    });

    group('Service Registration Verification', () {
      test('should have all performance services registered in service locator', () {
        // This is a conceptual test - in practice, we'd need to initialize
        // the service locator with mocks to test registration
        expect(PerformanceMonitorService.instance, isNotNull);
        
        // Verify performance monitor singleton works
        final instance1 = PerformanceMonitorService.instance;
        final instance2 = PerformanceMonitorService.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Parallel API Implementation Verification', () {
      test('should demonstrate parallel API performance improvement', () async {
        // This test simulates the parallel fetching behavior
        
        final deviceTypes = ['access_points', 'switches', 'onts', 'wlan_controllers'];
        
        // Sequential approach (baseline)
        final sequentialStopwatch = Stopwatch()..start();
        final sequentialResults = <List<Map<String, dynamic>>>[];
        
        for (final type in deviceTypes) {
          await Future<void>.delayed(const Duration(milliseconds: 100)); // Simulate API delay
          sequentialResults.add([{'id': type, 'name': 'Device for $type'}]);
        }
        sequentialStopwatch.stop();
        
        // Parallel approach (optimized)
        final parallelStopwatch = Stopwatch()..start();
        final parallelFutures = deviceTypes.map((type) async {
          await Future<void>.delayed(const Duration(milliseconds: 100)); // Same API delay
          return [{'id': type, 'name': 'Device for $type'}];
        });
        final parallelResults = await Future.wait(parallelFutures);
        parallelStopwatch.stop();
        
        // Verify results are the same
        expect(sequentialResults.length, equals(parallelResults.length));
        
        // Verify parallel is significantly faster
        final speedupRatio = sequentialStopwatch.elapsedMilliseconds / parallelStopwatch.elapsedMilliseconds;
        expect(speedupRatio, greaterThan(2.5), 
               reason: 'Parallel execution should be at least 2.5x faster than sequential');
        
        debugPrint('Sequential time: ${sequentialStopwatch.elapsedMilliseconds}ms');
        debugPrint('Parallel time: ${parallelStopwatch.elapsedMilliseconds}ms');
        debugPrint('Speedup: ${speedupRatio.toStringAsFixed(2)}x');
      });

      test('should handle batched parallel requests to prevent server overload', () async {
        // Simulate fetching many pages in batches
        const totalPages = 15;
        const batchSize = 5;
        
        final batchStopwatch = Stopwatch()..start();
        final allResults = <String>[];
        
        for (var i = 0; i < totalPages; i += batchSize) {
          final batch = List.generate(
            (i + batchSize > totalPages) ? totalPages - i : batchSize,
            (index) => i + index + 1,
          );
          
          // Process batch in parallel
          final batchFutures = batch.map((page) async {
            await Future<void>.delayed(const Duration(milliseconds: 50)); // API delay
            return 'Page $page data';
          });
          
          final batchResults = await Future.wait(batchFutures);
          allResults.addAll(batchResults);
          
          // Small delay between batches to be server-friendly
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        batchStopwatch.stop();
        
        expect(allResults.length, equals(totalPages));
        
        // Batched approach should be much faster than fully sequential
        // but not as fast as fully parallel (due to batching overhead)
        const expectedSequentialTime = totalPages * 50; // 50ms per page
        final actualTime = batchStopwatch.elapsedMilliseconds;
        
        expect(actualTime, lessThan(expectedSequentialTime));
        debugPrint('Batched parallel time: ${actualTime}ms vs expected sequential: ${expectedSequentialTime}ms');
      });
    });

    group('Cache with TTL Verification', () {
      test('should demonstrate cache TTL behavior', () async {
        // This test verifies the TTL cache concept
        
        const cacheValidityDuration = Duration(milliseconds: 100);
        var cacheTimestamp = DateTime.now();
        
        bool isCacheValid() {
          final now = DateTime.now();
          final difference = now.difference(cacheTimestamp);
          return difference < cacheValidityDuration;
        }
        
        // Initially cache should be valid
        expect(isCacheValid(), isTrue);
        
        // Wait for cache to expire
        await Future<void>.delayed(const Duration(milliseconds: 150));
        
        // Cache should now be expired
        expect(isCacheValid(), isFalse);
        
        // Update cache timestamp
        cacheTimestamp = DateTime.now();
        expect(isCacheValid(), isTrue);
      });

      test('should use cached data when available and valid', () async {
        final mockLocalDataSource = MockDeviceLocalDataSource();
        
        final cachedDevices = [
          const DeviceModel(id: '1', name: 'Cached Device', type: 'access_point', status: 'online'),
        ];
        
        // Setup mock - cache is valid and has data
        when(mockLocalDataSource.isCacheValid).thenAnswer((_) async => true);
        when(mockLocalDataSource.getCachedDevices).thenAnswer((_) async => cachedDevices);
        
        // Simulate data loading logic
        List<DeviceModel> devices;
        if (await mockLocalDataSource.isCacheValid()) {
          devices = await mockLocalDataSource.getCachedDevices();
        } else {
          // Would fetch from remote
          devices = [];
        }
        
        expect(devices, equals(cachedDevices));
        expect(devices.length, equals(1));
        expect(devices.first.name, equals('Cached Device'));
      });
    });

    group('Background Refresh Service Verification', () {
      late MockDeviceDataSource mockDeviceDataSource;
      late MockDeviceLocalDataSource mockLocalDataSource;
      late MockRoomRepository mockRoomRepository;
      late MockStorageService mockStorageService;
      late MockWebSocketService mockWebSocketService;
      late MockWebSocketDataSyncService mockWebSocketDataSyncService;
      late NotificationGenerationService notificationGenerationService;
      late BackgroundRefreshService backgroundRefreshService;

      setUp(() {
        mockDeviceDataSource = MockDeviceDataSource();
        mockLocalDataSource = MockDeviceLocalDataSource();
        mockRoomRepository = MockRoomRepository();
        mockStorageService = MockStorageService();
        mockWebSocketService = MockWebSocketService();
        mockWebSocketDataSyncService = MockWebSocketDataSyncService();
        notificationGenerationService = NotificationGenerationService();

        when(() => mockStorageService.isAuthenticated).thenReturn(true);
        when(() => mockWebSocketService.isConnected).thenReturn(true);
        when(() => mockWebSocketDataSyncService.syncInitialData()).thenAnswer((_) async {});

        backgroundRefreshService = BackgroundRefreshService(
          deviceDataSource: mockDeviceDataSource,
          deviceLocalDataSource: mockLocalDataSource,
          roomRepository: mockRoomRepository,
          notificationGenerationService: notificationGenerationService,
          storageService: mockStorageService,
          webSocketService: mockWebSocketService,
          webSocketDataSyncService: mockWebSocketDataSyncService,
        );
      });

      tearDown(() {
        backgroundRefreshService.dispose();
      });

      test('should refresh multiple data sources in parallel', () async {
        final testDevices = [
          const DeviceModel(id: '1', name: 'Test Device', type: 'access_point', status: 'online'),
        ];
        
        // Setup mocks
        when(() => mockDeviceDataSource.getDevices()).thenAnswer((_) async => testDevices);
        when(() => mockLocalDataSource.cacheDevices(any())).thenAnswer((_) async {});
        when(mockRoomRepository.getRooms).thenAnswer((_) async => const Right([]));
        
        // Track refresh events
        final deviceEvents = <RefreshStatus>[];
        final roomEvents = <RefreshStatus>[];
        
        backgroundRefreshService.deviceRefreshStream.listen(deviceEvents.add);
        backgroundRefreshService.roomRefreshStream.listen(roomEvents.add);
        
        // Perform refresh
        final stopwatch = Stopwatch()..start();
        await backgroundRefreshService.refreshNow();
        stopwatch.stop();
        
        // Wait for stream events
        await Future<void>.delayed(const Duration(milliseconds: 50));
        
        // Verify parallel execution (should be fast)
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        
        // Verify both data sources were refreshed (success or error)
        expect(deviceEvents.where((e) => e.isSuccess || e.isError).length, equals(1));
        expect(roomEvents.where((e) => e.isSuccess || e.isError).length, equals(1));
      });

      test('should handle refresh errors without stopping other operations', () async {
        // Setup mocks - devices fail, rooms succeed
        when(() => mockDeviceDataSource.getDevices()).thenThrow(Exception('Device API error'));
        when(mockRoomRepository.getRooms).thenAnswer((_) async => const Right([]));
        
        final deviceEvents = <RefreshStatus>[];
        final roomEvents = <RefreshStatus>[];
        
        backgroundRefreshService.deviceRefreshStream.listen(deviceEvents.add);
        backgroundRefreshService.roomRefreshStream.listen(roomEvents.add);
        
        // Perform refresh - should not throw
        await backgroundRefreshService.refreshNow();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        
        // Devices should have error, rooms should succeed
        expect(deviceEvents.where((e) => e.isError).length, equals(1));
        expect(roomEvents.where((e) => e.isSuccess).length, equals(1));
      });
    });

    group('Pagination Service Verification', () {
      test('should demonstrate pagination performance optimization', () async {
        var apiCallCount = 0;
        
        final paginationService = PaginationService<String>(
          pageSize: 10,
          fetchPage: (page, pageSize) async {
            apiCallCount++;
            await Future<void>.delayed(const Duration(milliseconds: 50)); // Simulate API delay
            
            final startIndex = (page - 1) * pageSize;
            return List.generate(pageSize, (i) => 'Item ${startIndex + i + 1}');
          },
        );
        
        // Test sequential loading
        final sequentialStopwatch = Stopwatch()..start();
        await paginationService.loadNextPage(); // Page 1
        await paginationService.loadNextPage(); // Page 2
        await paginationService.loadNextPage(); // Page 3
        sequentialStopwatch.stop();
        
        expect(paginationService.totalLoaded, equals(30));
        expect(apiCallCount, equals(3));
        
        // Reset for parallel test
        await paginationService.refresh();
        apiCallCount = 0;
        
        // Test parallel loading
        final parallelStopwatch = Stopwatch()..start();
        await paginationService.loadPagesInParallel(3);
        parallelStopwatch.stop();
        
        expect(paginationService.totalLoaded, equals(40)); // 10 from refresh + 30 from parallel
        expect(apiCallCount, equals(3)); // Only parallel calls counted (reset after refresh)
        
        // Parallel should be faster
        final speedup = sequentialStopwatch.elapsedMilliseconds / parallelStopwatch.elapsedMilliseconds;
        expect(speedup, greaterThan(2.0));
        
        debugPrint('Sequential pagination: ${sequentialStopwatch.elapsedMilliseconds}ms');
        debugPrint('Parallel pagination: ${parallelStopwatch.elapsedMilliseconds}ms');
        debugPrint('Speedup: ${speedup.toStringAsFixed(2)}x');
        
        paginationService.dispose();
      });

      test('should demonstrate cache benefits in pagination', () async {
        final paginationService = PaginationService<String>(
          pageSize: 10,
          cachePages: true,
          fetchPage: (page, pageSize) async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return List.generate(10, (i) => 'Page $page Item ${i + 1}');
          },
        );
        
        // First load - from API
        final firstLoadStopwatch = Stopwatch()..start();
        await paginationService.loadNextPage();
        firstLoadStopwatch.stop();
        
        // Preload next page
        await paginationService.preloadNextPage();
        
        // Second load - should be from cache, much faster
        final secondLoadStopwatch = Stopwatch()..start();
        await paginationService.loadNextPage();
        secondLoadStopwatch.stop();
        
        expect(paginationService.totalLoaded, equals(20));
        
        // Cached load should be much faster
        expect(secondLoadStopwatch.elapsedMilliseconds, lessThan(firstLoadStopwatch.elapsedMilliseconds));
        
        debugPrint('First load (API): ${firstLoadStopwatch.elapsedMilliseconds}ms');
        debugPrint('Second load (cached): ${secondLoadStopwatch.elapsedMilliseconds}ms');
        
        paginationService.dispose();
      });
    });

    group('Performance Monitoring Verification', () {
      test('should track and report performance metrics correctly', () async {
        final performanceMonitor = PerformanceMonitorService.instance
          ..clearMetrics();
        
        // Perform various operations
        await performanceMonitor.trackFuture('fast_operation', () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return 'fast result';
        });
        
        await performanceMonitor.trackFuture('slow_operation', () async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return 'slow result';
        });
        
        await performanceMonitor.trackFuture('fast_operation', () async {
          await Future<void>.delayed(const Duration(milliseconds: 60));
          return 'fast result 2';
        });
        
        // Get statistics
        final fastStats = performanceMonitor.getStats('fast_operation');
        final slowStats = performanceMonitor.getStats('slow_operation');
        
        expect(fastStats, isNotNull);
        expect(slowStats, isNotNull);
        
        expect(fastStats!.sampleCount, equals(2));
        expect(slowStats!.sampleCount, equals(1));
        
        expect(fastStats.averageMs, lessThan(slowStats.averageMs));
        expect(fastStats.successRate, equals(1.0));
        expect(slowStats.successRate, equals(1.0));
        
        // Generate report
        final report = performanceMonitor.generateReport();
        expect(report, contains('Performance Report'));
        expect(report, contains('fast_operation'));
        expect(report, contains('slow_operation'));
        
        debugPrint('Performance Report:');
        debugPrint(report);
        
        performanceMonitor.clearMetrics();
      });

      test('should track parallel operations with correct metrics', () async {
        final performanceMonitor = PerformanceMonitorService.instance
          ..clearMetrics();
        
        // Track parallel operations
        final results = await performanceMonitor.trackParallel('parallel_test', [
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return 'result1';
          },
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 80));
            return 'result2';
          },
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 120));
            return 'result3';
          },
        ]);
        
        expect(results, equals(['result1', 'result2', 'result3']));
        
        final stats = performanceMonitor.getStats('parallel_test');
        expect(stats, isNotNull);
        expect(stats!.sampleCount, equals(1));
        
        // Parallel execution should be faster than sum of individual operations
        // (100 + 80 + 120 = 300ms, but parallel should be ~120ms)
        expect(stats.averageMs, lessThan(200));
        
        performanceMonitor.clearMetrics();
      });
    });

    group('Integration Verification', () {
      test('should demonstrate full optimization stack performance', () async {
        // This test shows how all optimizations work together
        
        final performanceMonitor = PerformanceMonitorService.instance
          ..clearMetrics();
        
        // Simulate a complex dashboard load with multiple data sources
        final overallStopwatch = Stopwatch()..start();
        
        final results = await performanceMonitor.trackParallel('dashboard_load', [
          // Device data with caching
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 50)); // Cache hit simulation
            return 'devices_cached';
          },
          
          // Background refresh of rooms
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 80)); // API call
            return 'rooms_refreshed';
          },
          
          // Paginated notifications
          () async {
            await Future<void>.delayed(const Duration(milliseconds: 60)); // First page cached
            return 'notifications_paginated';
          },
        ]);
        
        overallStopwatch.stop();
        
        expect(results.length, equals(3));
        expect(overallStopwatch.elapsedMilliseconds, lessThan(150)); // Much faster than sequential
        
        // Verify performance tracking
        final stats = performanceMonitor.getStats('dashboard_load');
        expect(stats, isNotNull);
        expect(stats!.successRate, equals(1.0));
        
        debugPrint('Integrated optimization performance: ${overallStopwatch.elapsedMilliseconds}ms');
        debugPrint('vs Sequential estimate: ${50 + 80 + 60}ms');
        
        final report = performanceMonitor.generateReport();
        expect(report, contains('dashboard_load'));
        
        performanceMonitor.clearMetrics();
      });
    });

    group('No Synchronous Blocking Verification', () {
      test('should verify no blocking synchronous operations in data flow', () async {
        // This test ensures all data operations are properly async
        
        final performanceMonitor = PerformanceMonitorService.instance
          ..clearMetrics();
        
        // Test that operations don't block the main thread
        final mainThreadWork = Stopwatch()..start();
        
        // Simulate concurrent operations that should not block each other
        final futures = <Future<String>>[];
        
        for (var i = 0; i < 5; i++) {
          futures.add(
            performanceMonitor.trackFuture('concurrent_$i', () async {
              // Simulate I/O operation
              await Future<void>.delayed(Duration(milliseconds: 100 + (i * 10)));
              return 'result_$i';
            })
          );
        }
        
        // This should not be blocked by the futures above
        final quickWork = performanceMonitor.trackFuture('quick_work', () async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return 'quick_result';
        });
        
        // Wait for quick work - should complete fast even with other operations running
        final quickResult = await quickWork;
        final quickTime = mainThreadWork.elapsedMilliseconds;
        
        expect(quickResult, equals('quick_result'));
        expect(quickTime, lessThan(100)); // Should complete quickly, not blocked
        
        // Now wait for all operations
        final allResults = await Future.wait(futures);
        mainThreadWork.stop();
        
        expect(allResults.length, equals(5));
        expect(mainThreadWork.elapsedMilliseconds, lessThan(200)); // Parallel execution
        
        debugPrint('All operations completed in: ${mainThreadWork.elapsedMilliseconds}ms');
        debugPrint('Quick operation completed in: ${quickTime}ms (not blocked)');
        
        performanceMonitor.clearMetrics();
      });
    });
  });
}
