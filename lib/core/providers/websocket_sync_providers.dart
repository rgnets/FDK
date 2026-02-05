import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/services/websocket_data_sync_service.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/dashboard_provider.dart';
import 'package:rgnets_fdk/features/home/presentation/providers/home_screen_provider.dart';
import 'package:rgnets_fdk/features/issues/presentation/providers/health_notices_provider.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/device_notification_provider.dart'
    hide notificationGenerationServiceProvider;
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';

/// Handles WebSocket-driven cache hydration for devices/rooms.
///
/// This provider is in a separate file to break the circular dependency
/// between repository_providers.dart and websocket_providers.dart.
final webSocketDataSyncServiceProvider = Provider<WebSocketDataSyncService>((
  ref,
) {
  final socketService = ref.watch(webSocketServiceProvider);
  final roomLocalDataSource = ref.watch(roomLocalDataSourceProvider);
  final cacheManager = ref.watch(cacheManagerProvider);
  final storageService = ref.watch(storageServiceProvider);
  final logger = LoggerService.getLogger();

  // Typed device local data sources (new architecture)
  final apLocalDataSource = ref.watch(apLocalDataSourceProvider);
  final ontLocalDataSource = ref.watch(ontLocalDataSourceProvider);
  final switchLocalDataSource = ref.watch(switchLocalDataSourceProvider);
  final wlanLocalDataSource = ref.watch(wlanLocalDataSourceProvider);

  final service = WebSocketDataSyncService(
    socketService: socketService,
    apLocalDataSource: apLocalDataSource,
    ontLocalDataSource: ontLocalDataSource,
    switchLocalDataSource: switchLocalDataSource,
    wlanLocalDataSource: wlanLocalDataSource,
    storageService: storageService,
    roomLocalDataSource: roomLocalDataSource,
    cacheManager: cacheManager,
    logger: logger,
  );

  ref.onDispose(() {
    // Note: Riverpod doesn't await async onDispose callbacks.
    // Using unawaited to make this explicit, with error logging.
    unawaited(
      service.dispose().catchError((Object e) {
        LoggerService.getLogger().w('WebSocketDataSyncService dispose error: $e');
      }),
    );
  });
  return service;
});

/// Keeps WebSocket sync events wired to provider invalidation.
final webSocketDataSyncListenerProvider = Provider<void>((ref) {
  final service = ref.watch(webSocketDataSyncServiceProvider);
  final logger = LoggerService.getLogger();
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
  final logger = LoggerService.getLogger();
  final storageService = ref.watch(storageServiceProvider);
  final deviceUpdateEventBus = ref.watch(deviceUpdateEventBusProvider);

  final integration = WebSocketCacheIntegration(
    webSocketService: webSocketService,
    imageBaseUrl: storageService.siteUrl,
    logger: logger,
    deviceUpdateEventBus: deviceUpdateEventBus,
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
