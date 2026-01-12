import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';

/// Provides the base WebSocket configuration derived from the environment.
final webSocketConfigProvider = Provider<WebSocketConfig>((ref) {
  final uri = Uri.parse(EnvironmentConfig.websocketBaseUrl);
  return WebSocketConfig(
    baseUri: uri,
    autoReconnect: true, // Always enabled - WebSocket-only architecture
    initialReconnectDelay: EnvironmentConfig.webSocketInitialReconnectDelay,
    maxReconnectDelay: EnvironmentConfig.webSocketMaxReconnectDelay,
    heartbeatInterval: EnvironmentConfig.webSocketHeartbeatInterval,
    heartbeatTimeout: EnvironmentConfig.webSocketHeartbeatTimeout,
    sendClientPing: false,
  );
});

/// Provides a singleton [WebSocketService] for the application lifecycle.
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final config = ref.watch(webSocketConfigProvider);
  final logger = ref.watch(loggerProvider);

  final service = WebSocketService(config: config, logger: logger);
  final stateSub = service.connectionState.listen((state) {
    logger.i('WebSocketService: state -> ${state.name}');
  });
  final messageSub = service.messages.listen((message) {
    logger.d('WebSocketService: message type=${message.type}');
  });

  ref.onDispose(() {
    stateSub.cancel();
    messageSub.cancel();
    service.dispose();
  });
  return service;
});

/// Exposes the connection state as a Riverpod stream provider so UI can react.
final webSocketConnectionStateProvider = StreamProvider<SocketConnectionState>((
  ref,
) {
  final service = ref.watch(webSocketServiceProvider);
  return service.connectionState;
});

/// Exposes the last socket message for debugging / instrumentation.
final webSocketLastMessageProvider = StreamProvider<SocketMessage>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.messages;
});

/// Emits only authentication-related socket messages.
final webSocketAuthEventsProvider = StreamProvider<SocketMessage>((ref) {
  final service = ref.watch(webSocketServiceProvider);
  return service.messages.where(
    (message) => message.type.startsWith('auth.'),
  );
});

/// Provides the WebSocket cache integration for device data.
/// This keeps device caches in sync with WebSocket messages.
final webSocketCacheIntegrationProvider = Provider<WebSocketCacheIntegration>((
  ref,
) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  final logger = ref.watch(loggerProvider);
  final storageService = ref.watch(storageServiceProvider);

  final integration = WebSocketCacheIntegration(
    webSocketService: webSocketService,
    imageBaseUrl: storageService.siteUrl,
    logger: logger,
  );

  // Initialize the integration
  integration.initialize();

  ref.onDispose(() {
    integration.dispose();
  });

  return integration;
});

/// Emits the last device-cache update time for WebSocket snapshots/updates.
final webSocketDeviceLastUpdateProvider = StreamProvider<DateTime?>((ref) {
  final integration = ref.watch(webSocketCacheIntegrationProvider);
  final controller = StreamController<DateTime?>();

  void listener() {
    controller.add(integration.lastDeviceUpdate.value);
  }

  integration.lastDeviceUpdate.addListener(listener);
  controller.add(integration.lastDeviceUpdate.value);

  ref.onDispose(() {
    integration.lastDeviceUpdate.removeListener(listener);
    controller.close();
  });

  return controller.stream;
});
