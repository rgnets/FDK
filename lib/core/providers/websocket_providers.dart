import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/services/websocket_data_sync_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/dashboard_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/home_screen_provider.dart';
import 'package:rgnets_fdk/features/issues/presentation/providers/health_notices_provider.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/device_notification_provider.dart'
    hide notificationGenerationServiceProvider;
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/providers/speed_test_provider.dart';

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

/// Handles WebSocket-driven cache hydration for devices/rooms/notifications.
final webSocketDataSyncServiceProvider = Provider<WebSocketDataSyncService>((
  ref,
) {
  final socketService = ref.watch(webSocketServiceProvider);
  final deviceLocalDataSource = ref.watch(deviceLocalDataSourceProvider);
  final roomLocalDataSource = ref.watch(roomLocalDataSourceProvider);
  final notificationService = ref.watch(notificationGenerationServiceProvider);
  final cacheManager = ref.watch(cacheManagerProvider);
  final logger = LoggerConfig.getLogger();

  final speedTestLocalDataSource = ref.watch(speedTestLocalDataSourceProvider);

  final service = WebSocketDataSyncService(
    socketService: socketService,
    deviceLocalDataSource: deviceLocalDataSource,
    roomLocalDataSource: roomLocalDataSource,
    speedTestLocalDataSource: speedTestLocalDataSource,
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
  final logger = LoggerConfig.getLogger();
  final subscription = service.events.listen((event) {
    switch (event.type) {
      case WebSocketDataSyncEventType.devicesCached:
        logger.i('WebSocketDataSync: devices cached -> refreshing providers');
        ref.invalidate(devicesNotifierProvider);
        ref.invalidate(deviceNotificationsNotifierProvider);
        ref.invalidate(notificationsDomainNotifierProvider);
        ref.invalidate(homeScreenStatisticsProvider);
        ref.invalidate(dashboardStatsProvider);
        // Refresh health notices providers (they aggregate from device data)
        ref.invalidate(aggregateHealthCountsNotifierProvider);
        ref.invalidate(healthNoticesNotifierProvider);
        break;
      case WebSocketDataSyncEventType.roomsCached:
        logger.i('WebSocketDataSync: rooms cached -> refreshing providers');
        ref.invalidate(roomsNotifierProvider);
        break;
      case WebSocketDataSyncEventType.speedTestConfigsCached:
        logger.i('WebSocketDataSync: speed test configs cached (${event.count})');
        ref.invalidate(speedTestConfigsProvider);
        break;
      case WebSocketDataSyncEventType.speedTestResultsCached:
        logger.i('WebSocketDataSync: speed test results cached (${event.count})');
        ref.invalidate(speedTestResultsProvider);
        break;
      case WebSocketDataSyncEventType.speedTestConfigsCached:
        logger.i('WebSocketDataSync: speed test configs cached (${event.count})');
        ref.invalidate(speedTestConfigsProvider);
        break;
      case WebSocketDataSyncEventType.speedTestResultsCached:
        logger.i('WebSocketDataSync: speed test results cached (${event.count})');
        ref.invalidate(speedTestResultsProvider);
        break;
    }
  });

  ref.onDispose(subscription.cancel);
  return;
});

/// Provides the WebSocket cache integration for device data.
/// This keeps device caches in sync with WebSocket messages.
final webSocketCacheIntegrationProvider = Provider<WebSocketCacheIntegration>((
  ref,
) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  final logger = LoggerConfig.getLogger();
  final storageService = ref.watch(storageServiceProvider);

  final integration = WebSocketCacheIntegration(
    webSocketService: webSocketService,
    imageBaseUrl: storageService.siteUrl,
    logger: logger,
  );

  // Initialize the integration
  integration.initialize();

  ref.onDispose(integration.dispose);

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

/// Emits the last cache update time for any WebSocket data (including speed tests).
final webSocketLastUpdateProvider = StreamProvider<DateTime?>((ref) {
  final integration = ref.watch(webSocketCacheIntegrationProvider);
  final controller = StreamController<DateTime?>();

  void listener() {
    controller.add(integration.lastUpdate.value);
  }

  integration.lastUpdate.addListener(listener);
  controller.add(integration.lastUpdate.value);

  ref.onDispose(() {
    integration.lastUpdate.removeListener(listener);
    controller.close();
  });

  return controller.stream;
});
