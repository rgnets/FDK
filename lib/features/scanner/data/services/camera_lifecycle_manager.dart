import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// Camera states for lifecycle management.
enum CameraState {
  inactive,
  activating,
  active,
  deactivating,
  error,
}

/// Camera lifecycle event types.
enum CameraLifecycleEventType {
  activated,
  deactivated,
  error,
  permissionChanged,
  navigationComplete,
}

/// Camera lifecycle event.
class CameraLifecycleEvent {
  final CameraLifecycleEventType type;
  final int pageIndex;
  final DateTime timestamp;
  final String? error;

  CameraLifecycleEvent({
    required this.type,
    required this.pageIndex,
    required this.timestamp,
    this.error,
  });

  @override
  String toString() => 'CameraLifecycleEvent($type at page $pageIndex)';
}

/// Manages camera lifecycle in coordination with navigation.
/// Prevents unnecessary camera activation during page transitions.
/// Based on AT&T FE Tool reference implementation.
class CameraLifecycleManager {
  static const String _tag = 'CameraLifecycle';

  final MobileScannerController _cameraController;

  // State management
  CameraState _currentState = CameraState.inactive;
  bool _cameraPermissionGranted = false;
  bool _isTargetPage = false;
  bool _isNavigating = false;
  bool _hasError = false;
  String? _lastError;

  // Timing control
  Timer? _activationTimer;
  Timer? _deactivationTimer;
  Duration _activationDelay = const Duration(milliseconds: 100);

  // Disposal flag
  bool _isDisposed = false;

  // Mutex to prevent concurrent activation
  bool _isActivationInProgress = false;

  // Scanner page index (configurable)
  int _scannerPageIndex = 2;

  // Event stream
  final StreamController<CameraLifecycleEvent> _eventController =
      StreamController<CameraLifecycleEvent>.broadcast();

  Stream<CameraLifecycleEvent> get events => _eventController.stream;

  CameraLifecycleManager(this._cameraController);

  // Getters
  bool get isCameraActive => _currentState == CameraState.active;
  bool get hasError => _hasError;
  String? get lastError => _lastError;
  String get currentState => _currentState.toString().split('.').last;
  bool get hasActiveTimers =>
      (_activationTimer?.isActive ?? false) ||
      (_deactivationTimer?.isActive ?? false);
  bool get isDisposed => _isDisposed;
  CameraState get state => _currentState;

  /// Set the scanner page index (default is 2).
  void setScannerPageIndex(int index) {
    _scannerPageIndex = index;
  }

  /// Set camera permission status.
  void setCameraPermission(bool granted) {
    LoggerService.debug(
      'setCameraPermission: granted=$granted',
      tag: _tag,
    );

    _cameraPermissionGranted = granted;

    if (granted && _isTargetPage && !_isNavigating) {
      LoggerService.debug(
        'Conditions met for activation',
        tag: _tag,
      );
      checkAndActivateCamera();
    } else if (!granted && isCameraActive) {
      LoggerService.debug(
        'Permission revoked - deactivating',
        tag: _tag,
      );
      _deactivateCamera();
    }
  }

  /// Set activation delay.
  void setActivationDelay(Duration delay) {
    _activationDelay = delay;
  }

  /// Called when navigation starts.
  void onNavigationStart(int targetPage) {
    LoggerService.debug(
      'Navigation started to page $targetPage',
      tag: _tag,
    );

    _isNavigating = true;
    _cancelPendingActivation();

    // Deactivate camera if navigating away from scanner
    if (targetPage != _scannerPageIndex && isCameraActive) {
      _deactivateCamera();
    }
  }

  /// Called when navigation ends.
  void onNavigationEnd(int currentPage) {
    LoggerService.debug(
      'Navigation ended at page $currentPage',
      tag: _tag,
    );

    _isNavigating = false;
    _isTargetPage = (currentPage == _scannerPageIndex);

    if (_isTargetPage && _cameraPermissionGranted && !_isDisposed) {
      LoggerService.debug(
        'On scanner page - scheduling activation',
        tag: _tag,
      );
      _scheduleActivation();
    } else if (!_isTargetPage && isCameraActive) {
      LoggerService.debug(
        'Not on scanner page - deactivating',
        tag: _tag,
      );
      _deactivateCamera();
    }

    _emitEvent(CameraLifecycleEventType.navigationComplete, currentPage);
  }

  /// Called when a page becomes visible.
  void onPageVisible(int pageIndex, {required bool intentional}) {
    LoggerService.debug(
      'Page $pageIndex visible (intentional: $intentional)',
      tag: _tag,
    );

    if (pageIndex == _scannerPageIndex && intentional) {
      _isTargetPage = true;
    } else if (pageIndex == _scannerPageIndex && !intentional) {
      LoggerService.debug(
        'Scanner visible during transition - not activating',
        tag: _tag,
      );
    }
  }

  /// Check conditions and activate camera if appropriate.
  void checkAndActivateCamera() {
    LoggerService.debug(
      'checkAndActivateCamera: _isTargetPage=$_isTargetPage, _isNavigating=$_isNavigating, '
      '_cameraPermissionGranted=$_cameraPermissionGranted, isCameraActive=$isCameraActive',
      tag: _tag,
    );

    if (_isTargetPage &&
        !_isNavigating &&
        _cameraPermissionGranted &&
        !isCameraActive &&
        !_isDisposed) {
      _scheduleActivation();
    }
  }

  /// Retry camera activation after error.
  Future<void> retryActivation() async {
    if (_hasError && _isTargetPage && _cameraPermissionGranted) {
      LoggerService.info(
        'Retrying camera activation after error',
        tag: _tag,
      );

      _hasError = false;
      _lastError = null;
      await _activateCamera();
    }
  }

  /// Public method to deactivate camera.
  void deactivateCamera() {
    _deactivateCamera();
  }

  /// Schedule camera activation with delay.
  void _scheduleActivation() {
    _cancelPendingActivation();

    LoggerService.debug(
      'Scheduling camera activation in ${_activationDelay.inMilliseconds}ms',
      tag: _tag,
    );

    _activationTimer = Timer(_activationDelay, () {
      if (_isTargetPage && !_isNavigating && !_isDisposed) {
        _activateCamera();
      }
    });
  }

  /// Activate the camera.
  Future<void> _activateCamera() async {
    // Mutex check - prevent concurrent activation attempts
    if (_isActivationInProgress) {
      LoggerService.debug(
        'Camera activation already in progress',
        tag: _tag,
      );
      return;
    }

    if (isCameraActive || _isDisposed) {
      LoggerService.debug(
        'Camera activation skipped - active: $isCameraActive, disposed: $_isDisposed',
        tag: _tag,
      );
      return;
    }

    // Controller already running - sync state
    if (_cameraController.value.isRunning) {
      LoggerService.debug(
        'Controller already running, syncing state',
        tag: _tag,
      );
      _updateState(CameraState.active);
      return;
    }

    _isActivationInProgress = true;

    LoggerService.info('Activating camera', tag: _tag);
    _updateState(CameraState.activating);

    try {
      await _cameraController.start();

      if (!_isDisposed) {
        // Reset zoom for consistent behavior
        try {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await _cameraController.resetZoomScale();
          LoggerService.debug('Camera zoom reset to 1.0x', tag: _tag);
        } on Exception catch (e) {
          LoggerService.warning('Failed to reset zoom: $e', tag: _tag);
        }

        _updateState(CameraState.active);
        _emitEvent(CameraLifecycleEventType.activated, _scannerPageIndex);
        LoggerService.info('Camera activated successfully', tag: _tag);
      }
    } on Exception catch (e) {
      LoggerService.error('Failed to activate camera', error: e, tag: _tag);
      _hasError = true;
      _lastError = e.toString();
      _updateState(CameraState.error);
      _emitEvent(
        CameraLifecycleEventType.error,
        _scannerPageIndex,
        error: e.toString(),
      );
    } finally {
      _isActivationInProgress = false;
    }
  }

  /// Deactivate the camera.
  void _deactivateCamera() {
    _cancelPendingActivation();

    if (!isCameraActive) return;

    LoggerService.info('Deactivating camera', tag: _tag);
    _updateState(CameraState.deactivating);

    // Use a short delay for smooth transition
    _deactivationTimer?.cancel();
    _deactivationTimer = Timer(const Duration(milliseconds: 50), () {
      _doDeactivateCamera();
    });
  }

  /// Actually deactivate the camera.
  Future<void> _doDeactivateCamera() async {
    try {
      await _cameraController.stop();

      if (!_isDisposed) {
        _updateState(CameraState.inactive);
        _emitEvent(CameraLifecycleEventType.deactivated, -1);
        LoggerService.info('Camera deactivated successfully', tag: _tag);
      }
    } on Exception catch (e) {
      LoggerService.error('Failed to deactivate camera', error: e, tag: _tag);
      _hasError = true;
      _lastError = e.toString();
    }
  }

  /// Cancel pending camera activation.
  void _cancelPendingActivation() {
    if (_activationTimer?.isActive ?? false) {
      LoggerService.debug('Cancelling pending activation', tag: _tag);
      _activationTimer?.cancel();
      _activationTimer = null;
    }
  }

  /// Update camera state.
  void _updateState(CameraState newState) {
    if (_currentState != newState) {
      LoggerService.debug(
        'Camera state: $_currentState -> $newState',
        tag: _tag,
      );
      _currentState = newState;
    }
  }

  /// Emit lifecycle event.
  void _emitEvent(
    CameraLifecycleEventType type,
    int pageIndex, {
    String? error,
  }) {
    if (!_isDisposed) {
      _eventController.add(CameraLifecycleEvent(
        type: type,
        pageIndex: pageIndex,
        timestamp: DateTime.now(),
        error: error,
      ));
    }
  }

  /// Dispose resources.
  void dispose() {
    LoggerService.debug('Disposing CameraLifecycleManager', tag: _tag);

    _isDisposed = true;

    // Cancel all timers
    _activationTimer?.cancel();
    _deactivationTimer?.cancel();

    // Deactivate camera if active
    if (isCameraActive) {
      try {
        _cameraController.stop();
      } on Exception {
        // Ignore errors during disposal
      }
    }

    // Close event stream
    _eventController.close();

    // Reset state
    _currentState = CameraState.inactive;
    _isTargetPage = false;
    _isNavigating = false;
  }
}
