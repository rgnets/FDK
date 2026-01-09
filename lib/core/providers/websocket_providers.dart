import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/models/websocket_events.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/websocket_data_sync_service.dart';
import 'package:rgnets_fdk/core/services/websocket_message_router.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/dashboard_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/home_screen_provider.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/device_notification_provider.dart'
    hide notificationGenerationServiceProvider;
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';

/// Provides the base WebSocket configuration derived from the environment.
final webSocketConfigProvider = Provider<WebSocketConfig>((ref) {
  final uri = Uri.parse(EnvironmentConfig.websocketBaseUrl);
  return WebSocketConfig(
    baseUri: uri,
    autoReconnect: EnvironmentConfig.useWebSockets,
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

/// Handles WebSocket-driven cache hydration for devices/rooms/notifications.
final webSocketDataSyncServiceProvider = Provider<WebSocketDataSyncService>((
  ref,
) {
  final socketService = ref.watch(webSocketServiceProvider);
  final deviceLocalDataSource = ref.watch(deviceLocalDataSourceProvider);
  final roomLocalDataSource = ref.watch(roomLocalDataSourceProvider);
  final notificationService = ref.watch(notificationGenerationServiceProvider);
  final cacheManager = ref.watch(cacheManagerProvider);
  final logger = ref.watch(loggerProvider);

  final service = WebSocketDataSyncService(
    socketService: socketService,
    deviceLocalDataSource: deviceLocalDataSource,
    roomLocalDataSource: roomLocalDataSource,
    notificationService: notificationService,
    cacheManager: cacheManager,
    logger: logger,
  );

  ref.onDispose(() async {
    await service.dispose();
  });
  return service;
});

/// Keeps WebSocket sync events wired to provider invalidation.
final webSocketDataSyncListenerProvider = Provider<void>((ref) {
  final service = ref.watch(webSocketDataSyncServiceProvider);
  final logger = ref.watch(loggerProvider);
  final subscription = service.events.listen((event) {
    switch (event.type) {
      case WebSocketDataSyncEventType.devicesCached:
        logger.i('WebSocketDataSync: devices cached -> refreshing providers');
        ref.refresh(devicesNotifierProvider);
        ref.refresh(deviceNotificationsNotifierProvider);
        ref.refresh(notificationsDomainNotifierProvider);
        ref.refresh(homeScreenStatisticsProvider);
        ref.refresh(dashboardStatsProvider);
        break;
      case WebSocketDataSyncEventType.roomsCached:
        logger.i('WebSocketDataSync: rooms cached -> refreshing providers');
        ref.refresh(roomsNotifierProvider);
        break;
    }
  });

  ref.onDispose(subscription.cancel);
  return;
});

// =============================================================================
// TYPED EVENT PROVIDERS (New Architecture)
// =============================================================================

/// Provides the WebSocket message router for type-safe event dispatch.
/// Parses raw messages ONCE and emits typed [WebSocketEvent] objects.
final webSocketMessageRouterProvider = Provider<WebSocketMessageRouter>((ref) {
  final socketService = ref.watch(webSocketServiceProvider);
  final logger = ref.watch(loggerProvider);

  final router = WebSocketMessageRouter(
    socketService: socketService,
    logger: logger,
  );

  // Start the router
  router.start();

  ref.onDispose(() async {
    await router.dispose();
  });

  return router;
});

/// Stream of all typed WebSocket events (union type).
/// Use `.when()` for O(1) pattern matching.
final webSocketEventsProvider = StreamProvider<WebSocketEvent>((ref) {
  final router = ref.watch(webSocketMessageRouterProvider);
  return router.events;
});

/// Stream of device-specific events only.
/// Emits [DeviceEvent] for created, updated, deleted, statusChanged, etc.
final webSocketDeviceEventsProvider = StreamProvider<DeviceEvent>((ref) {
  final router = ref.watch(webSocketMessageRouterProvider);
  return router.deviceEvents;
});

/// Stream of room-specific events only.
/// Emits [RoomEvent] for created, updated, deleted, etc.
final webSocketRoomEventsProvider = StreamProvider<RoomEvent>((ref) {
  final router = ref.watch(webSocketMessageRouterProvider);
  return router.roomEvents;
});

/// Stream of notification events only.
/// Emits [NotificationEvent] for received, read, cleared.
final webSocketNotificationEventsProvider =
    StreamProvider<NotificationEvent>((ref) {
  final router = ref.watch(webSocketMessageRouterProvider);
  return router.notificationEvents;
});

/// Stream of sync events only.
/// Emits [SyncEvent] for started, completed, failed, delta.
final webSocketSyncEventsProvider = StreamProvider<SyncEvent>((ref) {
  final router = ref.watch(webSocketMessageRouterProvider);
  return router.syncEvents;
});

/// Stream of connection events only.
/// Emits [ConnectionEvent] for connected, disconnected, reconnecting, error.
final webSocketConnectionEventsProvider =
    StreamProvider<ConnectionEvent>((ref) {
  final router = ref.watch(webSocketMessageRouterProvider);
  return router.connectionEvents;
});

/// Connection status with staleness tracking.
/// Combines connection state with last sync timestamp.
final connectionStatusProvider = Provider<ConnectionStatus>((ref) {
  final stateAsync = ref.watch(webSocketConnectionStateProvider);
  final state = stateAsync.valueOrNull ?? SocketConnectionState.disconnected;

  return ConnectionStatus(
    state: state,
    isConnected: state == SocketConnectionState.connected,
    isReconnecting: state == SocketConnectionState.reconnecting,
  );
});

/// Simple connection status model.
class ConnectionStatus {
  const ConnectionStatus({
    required this.state,
    required this.isConnected,
    required this.isReconnecting,
  });

  final SocketConnectionState state;
  final bool isConnected;
  final bool isReconnecting;
}
