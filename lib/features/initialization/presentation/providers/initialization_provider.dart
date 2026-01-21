import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
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
  Future<void> initialize() async {
    // Prevent multiple simultaneous initializations
    if (_isInitializing) {
      return;
    }

    // Allow re-initialization from uninitialized or error states
    if (state != const InitializationState.uninitialized() &&
        !state.maybeWhen(error: (_, __) => true, orElse: () => false)) {
      return;
    }

    _isInitializing = true;

    try {
      // Step 1: Check WebSocket connection
      state = const InitializationState.checkingConnection();

      if (!_webSocketService.isConnected) {
        state = const InitializationState.error(
          message: 'Unable to connect to server',
          retryCount: 0,
        );
        return;
      }

      // Step 2: Validate credentials (auth is handled separately)
      state = const InitializationState.validatingCredentials();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      // Step 3: Load data via WebSocket
      state = const InitializationState.loadingData(
        currentOperation: 'Loading devices and rooms...',
      );

      _setupProgressListener();

      await _dataSyncService.syncInitialData(
        timeout: const Duration(seconds: 45),
      );

      // Step 4: Ready
      state = const InitializationState.ready();
    } on Exception catch (e) {
      state = InitializationState.error(
        message: e.toString(),
        retryCount: _retryCount,
      );
    } finally {
      _isInitializing = false;
    }
  }

  /// Set up listener for progress events from WebSocket sync.
  void _setupProgressListener() {
    _eventSubscription?.cancel();
    _eventSubscription = _dataSyncService.events.listen(_updateProgress);
  }

  /// Update progress state based on sync events.
  void _updateProgress(WebSocketDataSyncEvent event) {
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
