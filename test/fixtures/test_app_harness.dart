import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/background_refresh_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoopBackgroundRefreshService extends BackgroundRefreshService {
  NoopBackgroundRefreshService({
    required super.deviceDataSource,
    required super.deviceLocalDataSource,
    required super.roomRepository,
    required super.notificationGenerationService,
    required super.storageService,
    required super.webSocketService,
    required super.webSocketDataSyncService,
  });

  @override
  void startBackgroundRefresh() {}

  @override
  Future<void> refreshNow() async {}
}

ProviderContainer createTestContainer({
  required SharedPreferences sharedPreferences,
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      backgroundRefreshServiceProvider.overrideWith((ref) {
        final service = NoopBackgroundRefreshService(
          deviceDataSource: ref.watch(deviceDataSourceProvider),
          deviceLocalDataSource: ref.watch(deviceLocalDataSourceProvider),
          roomRepository: ref.watch(roomRepositoryProvider),
          notificationGenerationService:
              ref.watch(notificationGenerationServiceProvider),
          storageService: ref.watch(storageServiceProvider),
          webSocketService: ref.watch(webSocketServiceProvider),
          webSocketDataSyncService: ref.watch(webSocketDataSyncServiceProvider),
        );

        ref.onDispose(service.dispose);
        return service;
      }),
      ...overrides,
    ],
  );

  addTearDown(container.dispose);
  return container;
}

Widget wrapWithContainer({
  required ProviderContainer container,
  required Widget child,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: child,
  );
}
