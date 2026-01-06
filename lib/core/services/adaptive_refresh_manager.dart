import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration for refresh intervals based on conditions
class RefreshConfig {
  const RefreshConfig({
    this.foregroundInterval = const Duration(seconds: 30),
    this.backgroundInterval = const Duration(minutes: 10),
    this.wifiInterval = const Duration(seconds: 30),
    this.cellularInterval = const Duration(minutes: 2),
    this.lowBatteryInterval = const Duration(minutes: 15),
  });

  final Duration foregroundInterval;
  final Duration backgroundInterval;
  final Duration wifiInterval;
  final Duration cellularInterval;
  final Duration lowBatteryInterval;
}

/// Manages adaptive refresh based on network, battery, and app state
class AdaptiveRefreshManager {
  AdaptiveRefreshManager({RefreshConfig refreshConfig = const RefreshConfig()})
    : config = refreshConfig;

  final RefreshConfig config;
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  bool _isInForeground = true;
  bool _shouldContinueRefreshing = true;
  List<ConnectivityResult> _currentConnectivity = [ConnectivityResult.none];
  int _batteryLevel = 100;
  bool _isCharging = false;

  // Callbacks
  VoidCallback? onRefreshNeeded;

  /// Initialize and start monitoring
  Future<void> initialize() async {
    // Get initial states
    _currentConnectivity = await _connectivity.checkConnectivity();
    _batteryLevel = await _battery.batteryLevel;

    // Monitor battery state
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      _isCharging =
          state == BatteryState.charging || state == BatteryState.full;
    });

    // Monitor connectivity changes
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _currentConnectivity = results;
      _updateRefreshInterval();
    });
  }

  /// Start the sequential refresh pattern
  /// Waits AFTER each refresh completes before scheduling the next one
  void startSequentialRefresh(Future<void> Function() refreshCallback) {
    _shouldContinueRefreshing = true;
    unawaited(_scheduleNextRefresh(refreshCallback));
  }

  /// Schedule the next refresh in the sequence
  Future<void> _scheduleNextRefresh(
    Future<void> Function() refreshCallback,
  ) async {
    if (!_shouldContinueRefreshing) {
      return;
    }

    try {
      // Perform the refresh
      await refreshCallback();

      // Calculate wait duration based on current conditions
      final waitDuration = _calculateRefreshInterval();

      // Wait AFTER the refresh completes
      await Future<void>.delayed(waitDuration);

      // Schedule the next refresh
      if (_shouldContinueRefreshing) {
        await _scheduleNextRefresh(refreshCallback);
      }
    } on Object catch (error, stackTrace) {
      // On error, wait longer before retrying
      final errorWaitDuration = _calculateRefreshInterval() * 2;
      await Future<void>.delayed(errorWaitDuration);

      if (_shouldContinueRefreshing) {
        await _scheduleNextRefresh(refreshCallback);
      }
      if (kDebugMode) {
        debugPrint('Adaptive refresh retry after error: $error');
        debugPrint(stackTrace.toString());
      }
    }
  }

  /// Calculate the appropriate refresh interval based on conditions
  Duration _calculateRefreshInterval() {
    // Priority order for determining interval:
    // 1. Low battery (if not charging)
    // 2. Network type (cellular vs wifi)
    // 3. App state (foreground vs background)

    // Low battery takes precedence
    if (_batteryLevel < 20 && !_isCharging) {
      return config.lowBatteryInterval;
    }

    // Network-based intervals
    Duration baseInterval;
    if (_currentConnectivity.contains(ConnectivityResult.mobile)) {
      baseInterval = config.cellularInterval;
    } else if (_currentConnectivity.contains(ConnectivityResult.wifi) ||
        _currentConnectivity.contains(ConnectivityResult.ethernet)) {
      baseInterval = config.wifiInterval;
    } else {
      // No connection - use background interval
      return config.backgroundInterval;
    }

    // Adjust based on app state
    if (_isInForeground) {
      // Use the shorter of foreground interval or network-based interval
      return baseInterval.compareTo(config.foregroundInterval) < 0
          ? baseInterval
          : config.foregroundInterval;
    } else {
      // Use the longer of background interval or network-based interval
      return baseInterval.compareTo(config.backgroundInterval) > 0
          ? baseInterval
          : config.backgroundInterval;
    }
  }

  /// Update refresh interval when conditions change
  void _updateRefreshInterval() {
    // The sequential pattern will automatically use the new interval
    // on the next iteration
  }

  /// Set app foreground state
  void setForegroundState({required bool isInForeground}) {
    _isInForeground = isInForeground;
    _updateRefreshInterval();
  }

  /// Stop refresh timer
  void stopRefresh() {
    _shouldContinueRefreshing = false;
  }

  /// Dispose resources
  void dispose() {
    stopRefresh();
  }

  /// Get current refresh status
  Map<String, dynamic> getStatus() {
    return {
      'isRefreshing': _shouldContinueRefreshing,
      'isInForeground': _isInForeground,
      'connectivity': _currentConnectivity.map((e) => e.toString()).join(', '),
      'batteryLevel': _batteryLevel,
      'isCharging': _isCharging,
      'currentInterval': _calculateRefreshInterval().inSeconds,
    };
  }
}

/// Provider for adaptive refresh manager
final adaptiveRefreshManagerProvider = Provider<AdaptiveRefreshManager>((ref) {
  final manager = AdaptiveRefreshManager();

  ref.onDispose(manager.dispose);

  // Initialize on creation
  manager.initialize();

  return manager;
});
