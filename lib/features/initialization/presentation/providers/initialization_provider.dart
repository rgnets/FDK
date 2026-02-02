import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_data_sync_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/initialization/domain/entities/initialization_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'initialization_provider.g.dart';

/// Override providers for testing - allows dependency injection in tests
final webSocketServiceOverrideProvider = Provider<WebSocketService?>((ref) => null);
final webSocketDataSyncServiceOverrideProvider =
    Provider<WebSocketDataSyncService?>((ref) => null);

/// Manages the app initialization state and progress.
///
/// This notifier tracks the initialization flow through several states:
/// - [InitializationState.uninitialized] - Initial state
/// - [InitializationState.checkingConnection] - Verifying WebSocket
/// - [InitializationState.validatingCredentials] - Checking auth
/// - [InitializationState.loadingData] - Loading data with progress
/// - [InitializationState.ready] - App is ready
/// - [InitializationState.error] - Error occurred
@Riverpod(keepAlive: true)
class InitializationNotifier extends _$InitializationNotifier {
  /// Maximum number of retry attempts before giving up.
  static const int maxRetries = 3;

  int _retryCount = 0;
  int _bytesDownloaded = 0;
  DateTime _lastProgressUpdate = DateTime.now();
  StreamSubscription<WebSocketDataSyncEvent>? _eventSubscription;
  bool _isInitializing = false;

  @override
  InitializationState build() {
    ref.onDispose(() {
      _eventSubscription?.cancel();
    });
    return const InitializationState.uninitialized();
  }

  /// Get the WebSocket service, with test override support.
  WebSocketService get _webSocketService {
    final override = ref.read(webSocketServiceOverrideProvider);
    return override ?? ref.read(webSocketServiceProvider);
  }

  /// Get the data sync service, with test override support.
  WebSocketDataSyncService get _dataSyncService {
    final override = ref.read(webSocketDataSyncServiceOverrideProvider);
    return override ?? ref.read(webSocketDataSyncServiceProvider);
  }

  /// Start the initialization process.
  ///
  /// This method transitions through several states:
  /// 1. checkingConnection - Verifies WebSocket is connected
  /// 2. validatingCredentials - Brief pause to validate auth
  /// 3. loadingData - Syncs data via WebSocket
  /// 4. ready - Initialization complete
  ///
  /// On error, transitions to [InitializationState.error].
  Future<void> initialize({bool waitForSync = false}) async {
    LoggerService.debug(
      'initialize() called, _isInitializing=$_isInitializing, state=$state',
      tag: 'InitProvider',
    );

    // Prevent multiple simultaneous initializations
    if (_isInitializing) {
      LoggerService.debug(
        'Returning early: already initializing',
        tag: 'InitProvider',
      );
      return;
    }

    // Allow re-initialization from uninitialized or error states
    if (state != const InitializationState.uninitialized() &&
        !state.maybeWhen(error: (_, __) => true, orElse: () => false)) {
      LoggerService.debug(
        'Returning early: state is not uninitialized or error (state=$state)',
        tag: 'InitProvider',
      );
      return;
    }

    _isInitializing = true;
    LoggerService.info('Starting initialization sequence', tag: 'InitProvider');

    try {
      // Step 1: Check WebSocket connection (with brief wait for connection to stabilize)
      state = const InitializationState.checkingConnection();
      LoggerService.debug('State -> checkingConnection', tag: 'InitProvider');

      // Wait briefly for WebSocket to stabilize after credential recovery
      // This handles the race condition where auth completes but WebSocket state
      // hasn't propagated yet
      var isConnected = _webSocketService.isConnected;
      LoggerService.debug(
        'Initial WebSocket isConnected=$isConnected',
        tag: 'InitProvider',
      );

      if (!isConnected) {
        // Wait up to 1 second for connection (reduced for faster startup)
        LoggerService.debug(
          'WebSocket not connected, waiting up to 1s...',
          tag: 'InitProvider',
        );
        for (var i = 0; i < 10 && !isConnected; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          isConnected = _webSocketService.isConnected;
        }
        LoggerService.debug(
          'After waiting: isConnected=$isConnected',
          tag: 'InitProvider',
        );
      }

      if (!isConnected) {
        LoggerService.error(
          'WebSocket not connected after 1s wait, setting error state',
          tag: 'InitProvider',
        );
        state = InitializationState.error(
          message: 'Unable to connect to server',
          retryCount: _retryCount,
        );
        return;
      }

      // Step 2: Validate credentials (auth is handled separately)
      state = const InitializationState.validatingCredentials();
      LoggerService.debug(
        'State -> validatingCredentials',
        tag: 'InitProvider',
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      if (waitForSync) {
        // Step 3: Load data via WebSocket (blocking)
        state = const InitializationState.loadingData(
          currentOperation: 'Loading devices and rooms...',
        );
        LoggerService.debug('State -> loadingData', tag: 'InitProvider');

        _setupProgressListener();

        LoggerService.debug(
          'Calling syncInitialData with 45s timeout...',
          tag: 'InitProvider',
        );
        await _dataSyncService.syncInitialData(
          timeout: const Duration(seconds: 45),
        );
        LoggerService.debug('syncInitialData completed', tag: 'InitProvider');

        // Clean up event subscription - no longer needed after initial sync
        _eventSubscription?.cancel();
        _eventSubscription = null;

        // Step 4: Ready
        state = const InitializationState.ready();
        LoggerService.info(
          'Initialization complete! State -> ready',
          tag: 'InitProvider',
        );
      } else {
        // Start sync in background to avoid blocking initial UI.
        unawaited(
          _dataSyncService
              .syncInitialData(timeout: const Duration(seconds: 45))
              .catchError((Object e, StackTrace st) {
            LoggerService.error(
              'Background sync failed: $e',
              tag: 'InitProvider',
              error: e,
              stackTrace: st,
            );
          }).whenComplete(() {
            _eventSubscription?.cancel();
            _eventSubscription = null;
          }),
        );

        // Step 4: Ready immediately
        state = const InitializationState.ready();
        LoggerService.info(
          'Initialization complete (background sync)! State -> ready',
          tag: 'InitProvider',
        );
      }
    } on Exception catch (e, stack) {
      // Clean up event subscription on error
      _eventSubscription?.cancel();
      _eventSubscription = null;

      LoggerService.error(
        'Initialization failed with exception: $e\n$stack',
        tag: 'InitProvider',
      );
      state = InitializationState.error(
        message: e.toString(),
        retryCount: _retryCount,
      );
    } finally {
      _isInitializing = false;
      LoggerService.debug(
        'initialize() completed, _isInitializing=false',
        tag: 'InitProvider',
      );
    }
  }

  /// Set up listener for progress events from WebSocket sync.
  void _setupProgressListener() {
    _eventSubscription?.cancel();
    _eventSubscription = _dataSyncService.events.listen(_updateProgress);
  }

  /// Update progress state based on sync events.
  void _updateProgress(WebSocketDataSyncEvent event) {
    // Only update state if we're actively initializing
    // This prevents "Sync Now" from triggering the overlay
    if (!_isInitializing) {
      return;
    }

    // Throttle updates to 100ms to prevent UI jank
    final now = DateTime.now();
    if (now.difference(_lastProgressUpdate).inMilliseconds < 100) {
      return;
    }
    _lastProgressUpdate = now;

    // Estimate bytes based on event count (approximate ~500 bytes per item)
    final estimatedBytes = event.count * 500;
    _bytesDownloaded += estimatedBytes;

    final operation = switch (event.type) {
      WebSocketDataSyncEventType.devicesCached =>
        'Loaded ${event.count} devices',
      WebSocketDataSyncEventType.roomsCached => 'Loaded ${event.count} rooms',
    };

    state = InitializationState.loadingData(
      bytesDownloaded: _bytesDownloaded,
      currentOperation: operation,
    );
  }

  /// Retry initialization after an error.
  ///
  /// Returns early if max retries have been reached.
  Future<void> retry() async {
    if (!canRetry) {
      return;
    }
    _retryCount++;
    _bytesDownloaded = 0;
    state = const InitializationState.uninitialized();
    await initialize();
  }

  /// Reset the initialization state.
  ///
  /// Call this when the user signs out or needs to re-authenticate.
  void reset() {
    _retryCount = 0;
    _bytesDownloaded = 0;
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _isInitializing = false;
    state = const InitializationState.uninitialized();
  }

  /// Whether retry is available (hasn't exceeded max retries).
  bool get canRetry => _retryCount < maxRetries;

  /// Current retry count.
  int get retryCount => _retryCount;
}

/// Computed provider that returns whether the overlay should be shown.
@riverpod
bool showInitializationOverlay(Ref ref) {
  final state = ref.watch(initializationNotifierProvider);
  return state.showOverlay;
}
