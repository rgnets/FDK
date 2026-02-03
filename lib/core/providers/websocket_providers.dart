import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';

// NOTE: Sync providers are in websocket_sync_providers.dart
// Import that file directly if you need webSocketDataSyncServiceProvider,
// webSocketCacheIntegrationProvider, etc. We don't re-export here to avoid
// circular dependencies with repository_providers.dart.

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
  final logger = LoggerConfig.getLogger();

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
