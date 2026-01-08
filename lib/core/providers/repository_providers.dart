import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/background_refresh_service.dart';
import 'package:rgnets_fdk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:rgnets_fdk/features/auth/data/repositories/auth_repository.dart'
    as auth_impl;
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_mock_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/repositories/device_repository.dart'
    as device_impl;
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';
import 'package:rgnets_fdk/features/notifications/data/repositories/notification_repository_impl.dart'
    as notification_impl;
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_local_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_mock_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/repositories/room_repository_impl.dart';
import 'package:rgnets_fdk/features/rooms/domain/repositories/room_repository.dart';
import 'package:rgnets_fdk/features/scanner/data/datasources/scanner_local_data_source.dart';
import 'package:rgnets_fdk/features/scanner/data/repositories/scanner_repository_impl.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:rgnets_fdk/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';

// ============================================================================
// Data Sources
// ============================================================================

/// Auth local data source provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthLocalDataSourceImpl(storageService: storage);
});

/// Device local data source provider
final deviceLocalDataSourceProvider = Provider<DeviceLocalDataSource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DeviceLocalDataSourceImpl(storageService: storage);
});

/// Device mock data source provider
final deviceMockDataSourceProvider = Provider<DeviceDataSource>((ref) {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return DeviceMockDataSourceImpl(mockDataService: mockDataService);
});

/// Room local data source provider
final roomLocalDataSourceProvider = Provider<RoomLocalDataSource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return RoomLocalDataSourceImpl(storageService: storage);
});

/// Room mock data source provider
final roomMockDataSourceProvider = Provider<RoomMockDataSource>((ref) {
  final mockDataService = ref.watch(mockDataServiceProvider);
  return RoomMockDataSourceImpl(mockDataService: mockDataService);
});

// ============================================================================
// Repositories
// ============================================================================

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final mockDataService = ref.watch(mockDataServiceProvider);

  return auth_impl.AuthRepositoryImpl(
    localDataSource: localDataSource,
    mockDataService: mockDataService,
  );
});

/// Device repository provider
final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final localDataSource = ref.watch(deviceLocalDataSourceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final mockDataSource = ref.watch(deviceMockDataSourceProvider);

  return device_impl.DeviceRepositoryImpl(
    localDataSource: localDataSource,
    storageService: storageService,
    mockDataSource: mockDataSource,
  );
});

/// Room repository provider
final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final mockDataSource = ref.watch(roomMockDataSourceProvider);
  final localDataSource = ref.watch(roomLocalDataSourceProvider);

  return RoomRepositoryImpl(
    mockDataSource: mockDataSource,
    localDataSource: localDataSource,
  );
});

/// Notification repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final notificationService = ref.watch(notificationGenerationServiceProvider);
  final deviceRepository = ref.watch(deviceRepositoryProvider);

  return notification_impl.NotificationRepositoryImpl(
    notificationGenerationService: notificationService,
    deviceRepository: deviceRepository,
  );
});

/// Scanner local data source provider
final scannerLocalDataSourceProvider = Provider<ScannerLocalDataSource>((ref) {
  return ScannerLocalDataSourceImpl();
});

/// Scanner repository provider
final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  final localDataSource = ref.watch(scannerLocalDataSourceProvider);
  final deviceRepository = ref.watch(deviceRepositoryProvider);

  return ScannerRepositoryImpl(
    localDataSource: localDataSource,
    deviceRepository: deviceRepository,
  );
});

/// Settings repository provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepositoryImpl(sharedPreferences: prefs);
});

// ============================================================================
// Services that depend on repositories
// ============================================================================

/// Background refresh service provider
final backgroundRefreshServiceProvider = Provider<BackgroundRefreshService>((
  ref,
) {
  final deviceLocalDataSource = ref.watch(deviceLocalDataSourceProvider);
  final roomRepository = ref.watch(roomRepositoryProvider);
  final notificationService = ref.watch(notificationGenerationServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  final webSocketDataSyncService = ref.watch(webSocketDataSyncServiceProvider);

  return BackgroundRefreshService(
    deviceLocalDataSource: deviceLocalDataSource,
    roomRepository: roomRepository,
    notificationGenerationService: notificationService,
    storageService: storageService,
    webSocketService: webSocketService,
    webSocketDataSyncService: webSocketDataSyncService,
  );
});
