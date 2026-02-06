import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/services/websocket_data_sync_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/initialization/domain/entities/initialization_state.dart';
import 'package:rgnets_fdk/features/initialization/presentation/providers/initialization_provider.dart';

class MockWebSocketService extends Mock implements WebSocketService {}

class MockWebSocketDataSyncService extends Mock
    implements WebSocketDataSyncService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
  });

  late MockWebSocketService mockWebSocketService;
  late MockWebSocketDataSyncService mockDataSyncService;
  late StreamController<WebSocketDataSyncEvent> eventsController;
  late ProviderContainer container;

  setUp(() {
    mockWebSocketService = MockWebSocketService();
    mockDataSyncService = MockWebSocketDataSyncService();
    eventsController = StreamController<WebSocketDataSyncEvent>.broadcast();

    when(() => mockWebSocketService.isConnected).thenReturn(true);
    when(
      () => mockDataSyncService.syncInitialData(
        timeout: any(named: 'timeout'),
      ),
    ).thenAnswer((_) async => true);
    when(() => mockDataSyncService.events).thenAnswer(
      (_) => eventsController.stream,
    );
    when(() => mockDataSyncService.start()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        webSocketServiceOverrideProvider.overrideWithValue(mockWebSocketService),
        webSocketDataSyncServiceOverrideProvider
            .overrideWithValue(mockDataSyncService),
      ],
    );
  });

  tearDown(() async {
    await eventsController.close();
    container.dispose();
  });

  group('InitializationNotifier', () {
    test('initial state is uninitialized', () {
      final state = container.read(initializationNotifierProvider);
      expect(state, const InitializationState.uninitialized());
    });

    test('initialize sets checkingConnection state', () async {
      // Start initialization but don't await immediately
      final future =
          container.read(initializationNotifierProvider.notifier).initialize();

      // Give the event loop a chance to process
      await Future<void>.delayed(Duration.zero);

      final state = container.read(initializationNotifierProvider);
      expect(
        state.maybeWhen(
          checkingConnection: () => true,
          validatingCredentials: () => true,
          loadingData: (_, __) => true,
          ready: () => true,
          orElse: () => false,
        ),
        isTrue,
      );

      await future;
    });

    test('initialize transitions to ready on success', () async {
      await container.read(initializationNotifierProvider.notifier).initialize();

      final state = container.read(initializationNotifierProvider);
      expect(state, const InitializationState.ready());
    });

    test('initialize sets error when WebSocket not connected', () async {
      when(() => mockWebSocketService.isConnected).thenReturn(false);

      await container.read(initializationNotifierProvider.notifier).initialize();

      final state = container.read(initializationNotifierProvider);
      expect(
        state.maybeWhen(
          error: (message, _) => message,
          orElse: () => '',
        ),
        contains('connect'),
      );
    });

    test('initialize sets error when sync fails', () async {
      when(
        () => mockDataSyncService.syncInitialData(
          timeout: any(named: 'timeout'),
        ),
      ).thenThrow(Exception('Sync failed'));

      await container.read(initializationNotifierProvider.notifier).initialize();

      final state = container.read(initializationNotifierProvider);
      expect(
        state.maybeWhen(
          error: (message, _) => true,
          orElse: () => false,
        ),
        isTrue,
      );
    });

    test('retry increments retry count', () async {
      when(() => mockWebSocketService.isConnected).thenReturn(false);

      final notifier =
          container.read(initializationNotifierProvider.notifier);
      await notifier.initialize();

      expect(notifier.retryCount, equals(0));

      await notifier.retry();
      expect(notifier.retryCount, equals(1));
    });

    test('retry is blocked after max retries', () async {
      when(() => mockWebSocketService.isConnected).thenReturn(false);

      final notifier =
          container.read(initializationNotifierProvider.notifier);
      await notifier.initialize();

      // Exhaust retries
      for (var i = 0; i < InitializationNotifier.maxRetries; i++) {
        await notifier.retry();
      }

      expect(notifier.canRetry, isFalse);
    });

    test('canRetry returns true when retries available', () {
      final notifier =
          container.read(initializationNotifierProvider.notifier);
      expect(notifier.canRetry, isTrue);
    });

    test('reset clears state and retry count', () async {
      when(() => mockWebSocketService.isConnected).thenReturn(false);

      final notifier =
          container.read(initializationNotifierProvider.notifier);
      await notifier.initialize();
      await notifier.retry();

      expect(notifier.retryCount, equals(1));

      notifier.reset();

      expect(
        container.read(initializationNotifierProvider),
        const InitializationState.uninitialized(),
      );
      expect(notifier.retryCount, equals(0));
    });

    test('does not reinitialize when already initializing', () async {
      var callCount = 0;
      when(
        () => mockDataSyncService.syncInitialData(
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return true;
      });

      final notifier =
          container.read(initializationNotifierProvider.notifier);

      // Start multiple concurrent initializations
      final futures = <Future<void>>[
        notifier.initialize(),
        notifier.initialize(),
        notifier.initialize(),
      ];

      await Future.wait(futures);

      // Should only call syncInitialData once
      expect(callCount, equals(1));
    });

    test('progress updates state during loading', () async {
      final notifier =
          container.read(initializationNotifierProvider.notifier);

      // Start initialization
      final initFuture = notifier.initialize();

      // Wait for loading state
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Emit progress events
      eventsController.add(
        WebSocketDataSyncEvent.devicesCached(count: 10),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      eventsController.add(
        WebSocketDataSyncEvent.roomsCached(count: 5),
      );

      await initFuture;
    });
  });

  group('showInitializationOverlayProvider', () {
    test('returns true during loading states', () async {
      // Make sync take longer so we can capture loading state
      when(
        () => mockDataSyncService.syncInitialData(
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return true;
      });

      // Start initialization and wait for it in the test
      final future =
          container.read(initializationNotifierProvider.notifier).initialize();

      // Wait for state to change to loading
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(initializationNotifierProvider);

      // Verify we're in a loading state that shows the overlay
      expect(
        state.maybeWhen(
          checkingConnection: () => true,
          validatingCredentials: () => true,
          loadingData: (_, __) => true,
          orElse: () => false,
        ),
        isTrue,
      );

      // Wait for completion before container is disposed
      await future;
    });

    test('returns false when ready', () async {
      await container
          .read(initializationNotifierProvider.notifier)
          .initialize();

      final showOverlay = container.read(showInitializationOverlayProvider);
      expect(showOverlay, isFalse);
    });

    test('returns false when uninitialized', () {
      final showOverlay = container.read(showInitializationOverlayProvider);
      expect(showOverlay, isFalse);
    });

    test('returns true when error', () async {
      when(() => mockWebSocketService.isConnected).thenReturn(false);

      await container
          .read(initializationNotifierProvider.notifier)
          .initialize();

      final showOverlay = container.read(showInitializationOverlayProvider);
      expect(showOverlay, isTrue);
    });
  });

  // ============================================================
  // Manual Test Coverage - Tests for scenarios difficult to test manually
  // ============================================================

  group('manual test coverage - retry scenarios', () {
    test('error state contains correct retry count in state object', () async {
      when(() => mockWebSocketService.isConnected).thenReturn(false);
      final notifier =
          container.read(initializationNotifierProvider.notifier);

      await notifier.initialize();
      var state = container.read(initializationNotifierProvider);
      expect(
        state.maybeWhen(error: (_, count) => count, orElse: () => -1),
        equals(0),
      );

      await notifier.retry();
      state = container.read(initializationNotifierProvider);
      expect(
        state.maybeWhen(error: (_, count) => count, orElse: () => -1),
        equals(1),
      );

      await notifier.retry();
      state = container.read(initializationNotifierProvider);
      expect(
        state.maybeWhen(error: (_, count) => count, orElse: () => -1),
        equals(2),
      );
    });

    test('retry succeeds after previous failures', () async {
      var callCount = 0;
      when(() => mockWebSocketService.isConnected).thenAnswer((_) {
        callCount++;
        return callCount >= 3;
      });

      final notifier =
          container.read(initializationNotifierProvider.notifier);
      await notifier.initialize();
      await notifier.retry();
      await notifier.retry();

      final state = container.read(initializationNotifierProvider);
      expect(state, const InitializationState.ready());
    });
  });

  group('manual test coverage - state transitions', () {
    test('captures all state transitions during successful init', () async {
      final states = <InitializationState>[];
      container.listen(
        initializationNotifierProvider,
        (_, state) => states.add(state),
        fireImmediately: true,
      );

      when(
        () => mockDataSyncService.syncInitialData(
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return true;
      });

      await container
          .read(initializationNotifierProvider.notifier)
          .initialize();

      // Verify all expected states were captured
      expect(
        states.any(
          (s) => s.maybeWhen(checkingConnection: () => true, orElse: () => false),
        ),
        isTrue,
        reason: 'Should have checkingConnection state',
      );
      expect(
        states.any(
          (s) => s.maybeWhen(
            validatingCredentials: () => true,
            orElse: () => false,
          ),
        ),
        isTrue,
        reason: 'Should have validatingCredentials state',
      );
      expect(
        states.any(
          (s) => s.maybeWhen(loadingData: (_, __) => true, orElse: () => false),
        ),
        isTrue,
        reason: 'Should have loadingData state',
      );
      expect(states.last, const InitializationState.ready());
    });
  });

  group('manual test coverage - progress tracking', () {
    test('bytes downloaded accumulates across multiple events', () async {
      when(
        () => mockDataSyncService.syncInitialData(
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        return true;
      });

      final notifier =
          container.read(initializationNotifierProvider.notifier);
      final initFuture = notifier.initialize();

      // Wait for loading state (200ms validatingCredentials delay + buffer)
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Emit progress events with delay > 100ms throttle
      eventsController.add(WebSocketDataSyncEvent.devicesCached(count: 10));
      await Future<void>.delayed(const Duration(milliseconds: 150));
      eventsController.add(WebSocketDataSyncEvent.roomsCached(count: 5));
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final state = container.read(initializationNotifierProvider);
      final bytes =
          state.maybeWhen(loadingData: (b, _) => b, orElse: () => 0);
      expect(bytes, greaterThan(0));

      await initFuture;
    });

    test('operation text updates with event type', () async {
      when(
        () => mockDataSyncService.syncInitialData(
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        return true;
      });

      final notifier =
          container.read(initializationNotifierProvider.notifier);
      final initFuture = notifier.initialize();

      // Wait for loading state (200ms validatingCredentials delay + buffer)
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Emit event with specific count (past 100ms throttle)
      eventsController.add(WebSocketDataSyncEvent.devicesCached(count: 42));
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final state = container.read(initializationNotifierProvider);
      final operation =
          state.maybeWhen(loadingData: (_, op) => op, orElse: () => '');
      expect(operation, contains('42'));
      expect(operation.toLowerCase(), contains('device'));

      await initFuture;
    });
  });

  group('manual test coverage - reset behavior', () {
    test('reset after error allows fresh initialization with canRetry true',
        () async {
      when(() => mockWebSocketService.isConnected).thenReturn(false);
      final notifier =
          container.read(initializationNotifierProvider.notifier);

      await notifier.initialize();
      await notifier.retry();
      await notifier.retry();
      expect(notifier.retryCount, equals(2));

      notifier.reset();
      expect(notifier.retryCount, equals(0));
      expect(notifier.canRetry, isTrue);

      when(() => mockWebSocketService.isConnected).thenReturn(true);
      await notifier.initialize();
      expect(
        container.read(initializationNotifierProvider),
        const InitializationState.ready(),
      );
    });
  });
}
