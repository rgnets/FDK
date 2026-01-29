import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';

part 'connectivity_provider.g.dart';

/// Represents the app's overall connection status.
enum AppConnectionStatus {
  online,
  offline,
  connecting,
  reconnecting,
}

/// Provider that combines WebSocket connection state with device connectivity
/// to determine the overall app connection status.
@riverpod
Stream<AppConnectionStatus> appConnectionStatus(AppConnectionStatusRef ref) {
  final controller = StreamController<AppConnectionStatus>();
  final connectivity = Connectivity();

  // Listen to WebSocket state changes
  final wsSubscription = ref.listen(webSocketConnectionStateProvider, (previous, next) async {
    final wsState = next.valueOrNull;
    if (wsState == null) return;

    // Check device connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (!hasInternet) {
      controller.add(AppConnectionStatus.offline);
    } else {
      controller.add(switch (wsState) {
        SocketConnectionState.connected => AppConnectionStatus.online,
        SocketConnectionState.disconnected => AppConnectionStatus.offline,
        SocketConnectionState.connecting => AppConnectionStatus.connecting,
        SocketConnectionState.reconnecting => AppConnectionStatus.reconnecting,
      });
    }
  }, fireImmediately: true);

  // Listen to device connectivity changes
  final connectivitySubscription = connectivity.onConnectivityChanged.listen((result) async {
    final hasInternet = !result.contains(ConnectivityResult.none);
    final wsState = ref.read(webSocketConnectionStateProvider).valueOrNull;

    if (!hasInternet) {
      controller.add(AppConnectionStatus.offline);
    } else if (wsState != null) {
      controller.add(switch (wsState) {
        SocketConnectionState.connected => AppConnectionStatus.online,
        SocketConnectionState.disconnected => AppConnectionStatus.offline,
        SocketConnectionState.connecting => AppConnectionStatus.connecting,
        SocketConnectionState.reconnecting => AppConnectionStatus.reconnecting,
      });
    }
  });

  ref.onDispose(() {
    wsSubscription.close();
    connectivitySubscription.cancel();
    controller.close();
  });

  return controller.stream;
}
