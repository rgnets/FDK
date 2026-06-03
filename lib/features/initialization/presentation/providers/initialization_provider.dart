import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/core/services/inventory_reseed_service.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_data_sync_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/initialization/domain/entities/initialization_state.dart';
import 'package:rgnets_fdk/features/initialization/presentation/providers/seed_checklist_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'initialization_provider.g.dart';

/// Override providers for testing - allows dependency injection in tests
final webSocketServiceOverrideProvider = Provider<WebSocketService?>((ref) => null);
final webSocketDataSyncServiceOverrideProvider =
    Provider<WebSocketDataSyncService?>((ref) => null);
final inventoryReseedServiceOverrideProvider =
    Provider<InventoryReseedService?>((ref) => null);

/// How long to wait for the WebSocket to (re)connect before failing init.
/// Overridable so tests don't spin on the real 10s poll loop.
final initializationConnectionWaitProvider =
    Provider<Duration>((ref) => const Duration(seconds: 10));

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

  /// Upper bound on how long the blocking init waits for the inventory seed
  /// before releasing the overlay (the seed continues in the background). Sized
  /// above the seeder's internal per-resource timeouts so it only fires on a
  /// genuine stall, not normal slow boots.
  static const Duration _seedTimeout = Duration(seconds: 60);

  int _retryCount = 0;
  int _bytesDownloaded = 0;
  DateTime _lastProgressUpdate = DateTime.now();
  StreamSubscription<WebSocketDataSyncEvent>? _eventSubscription;
  StreamSubscription<ReseedProgress>? _reseedSubscription;
  bool _isInitializing = false;

  @override
  InitializationState build() {
    ref.onDispose(() {
      _eventSubscription?.cancel();
      _reseedSubscription?.cancel();
    });
    return const InitializationState.uninitialized();
  }

  /// Get the inventory reseed coordinator, with test override support.
  InventoryReseedService get _reseedService {
    final override = ref.read(inventoryReseedServiceOverrideProvider);
    return override ?? ref.read(inventoryReseedProvider);
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
        // Wait up to 10 seconds for WebSocket to connect or auto-reconnect.
        // On cold boot from a deeplink the auth handshake establishes a
        // connection, but provider graph updates can briefly drop it.
        // ATT-FE-Tool avoids this by validating via REST first; in FDK we
        // give the auto-reconnect enough time to re-establish.
        final maxWait = ref.read(initializationConnectionWaitProvider);
        final attempts = (maxWait.inMilliseconds / 100).ceil();
        LoggerService.debug(
          'WebSocket not connected, waiting up to ${maxWait.inSeconds}s...',
          tag: 'InitProvider',
        );
        for (var i = 0; i < attempts && !isConnected; i++) {
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
          'WebSocket not connected after 10s wait, setting error state',
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
        // Step 3: Load data via REST (blocking). The overlay stays up — and the
        // technician is held out of the app — until the inventory seed finishes.
        state = const InitializationState.loadingData(
          currentOperation: 'Loading inventory...',
        );
        LoggerService.debug('State -> loadingData', tag: 'InitProvider');

        _setupProgressListener();

        // Drive the per-resource checklist shown in the overlay: reset to
        // pending, flip to loading, then mark each resource done/failed as the
        // reseed coordinator reports it.
        final checklist = ref.read(seedChecklistProvider.notifier)
          ..reset()
          ..startLoading();
        final reseed = _reseedService;
        await _reseedSubscription?.cancel();
        _reseedSubscription = reseed.progress.listen(checklist.apply);

        LoggerService.debug(
          'Calling syncInitialData with 45s timeout...',
          tag: 'InitProvider',
        );
        await _dataSyncService.syncInitialData(
          timeout: const Duration(seconds: 45),
        );
        // Full inventory loads over REST (the WS layer no longer sends `index`
        // snapshots). This is the reliable boot-time seed for every authed
        // start — including persisted-session reopen, where the auth sign-in
        // transition that also reseeds may have already fired before its
        // listener registered. `force` bypasses the cooldown.
        //
        // Bounded so the overlay can never hang the technician indefinitely on a
        // stalled persist/fetch. On timeout we proceed to `ready` anyway: the
        // inventory is already applied to the in-memory caches by this point;
        // the reseed (incl. its SQLite flush) keeps running in the background.
        await reseed
            .triggerReseed(reason: 'init', force: true)
            .timeout(_seedTimeout, onTimeout: () {
          LoggerService.warning(
            'init seed exceeded ${_seedTimeout.inSeconds}s; releasing overlay '
            '(seed continues in background)',
            tag: 'InitProvider',
          );
        });
        LoggerService.debug('syncInitialData completed', tag: 'InitProvider');

        // Clean up subscriptions - no longer needed after initial sync
        _eventSubscription?.cancel();
        _eventSubscription = null;
        await _reseedSubscription?.cancel();
        _reseedSubscription = null;

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

        // Load full inventory over REST in the background (the WS layer no
        // longer sends `index` snapshots). Reliable boot-time seed for every
        // authed start, including persisted-session reopen.
        unawaited(
          _reseedService
              .triggerReseed(reason: 'init', force: true)
              .catchError((Object e, StackTrace st) {
            LoggerService.error(
              'Background REST reseed failed: $e',
              tag: 'InitProvider',
              error: e,
              stackTrace: st,
            );
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
      // Clean up subscriptions on error
      _eventSubscription?.cancel();
      _eventSubscription = null;
      await _reseedSubscription?.cancel();
      _reseedSubscription = null;

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
    // Re-run the blocking path so the checklist is shown again on retry.
    await initialize(waitForSync: true);
  }

  /// Reset the initialization state.
  ///
  /// Call this when the user signs out or needs to re-authenticate.
  void reset() {
    _retryCount = 0;
    _bytesDownloaded = 0;
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _reseedSubscription?.cancel();
    _reseedSubscription = null;
    _isInitializing = false;
    ref.read(seedChecklistProvider.notifier).reset();
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
