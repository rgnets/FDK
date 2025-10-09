import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/background_refresh_service.dart';
import 'package:rgnets_fdk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:rgnets_fdk/features/auth/data/repositories/auth_repository.dart'
    as auth_impl;
import 'package:rgnets_fdk/features/auth/domain/repositories/auth_repository.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_mock_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_remote_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/repositories/device_repository.dart'
    as device_impl;
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';
import 'package:rgnets_fdk/features/notifications/data/repositories/notification_repository_impl.dart'
    as notification_impl;
import 'package:rgnets_fdk/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_local_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_mock_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_remote_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/repositories/room_repository_impl.dart';
import 'package:rgnets_fdk/features/rooms/domain/repositories/room_repository.dart';
import 'package:rgnets_fdk/features/scanner/data/datasources/scanner_local_data_source.dart';
import 'package:rgnets_fdk/features/scanner/data/repositories/scanner_repository_impl.dart';
import 'package:rgnets_fdk/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:rgnets_fdk/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';

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

/// Device data source provider (interface)
final deviceDataSourceProvider = Provider<DeviceDataSource>((ref) {
  if (EnvironmentConfig.isDevelopment) {
    // Use mock data source in development
    final mockDataService = ref.watch(mockDataServiceProvider);
    return DeviceMockDataSourceImpl(mockDataService: mockDataService);
  } else {
    // Use remote data source in staging/production
    final apiService = ref.watch(apiServiceProvider);
    return DeviceRemoteDataSourceImpl(apiService: apiService);
  }
});

/// Device remote data source provider (for backward compatibility)
final deviceRemoteDataSourceProvider = Provider<DeviceDataSource>((ref) {
  return ref.watch(deviceDataSourceProvider);
});

/// Room local data source provider
final roomLocalDataSourceProvider = Provider<RoomLocalDataSource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return RoomLocalDataSourceImpl(storageService: storage);
});

/// Room remote data source provider
final roomRemoteDataSourceProvider = Provider<RoomRemoteDataSource>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RoomRemoteDataSourceImpl(apiService: apiService);
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
  final dataSource = ref.watch(deviceDataSourceProvider);
  final localDataSource = ref.watch(deviceLocalDataSourceProvider);

  return device_impl.DeviceRepositoryImpl(
    dataSource: dataSource,
    localDataSource: localDataSource,
  );
});

/// Room repository provider
final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final remoteDataSource = ref.watch(roomRemoteDataSourceProvider);
  final mockDataSource = ref.watch(roomMockDataSourceProvider);
  final localDataSource = ref.watch(roomLocalDataSourceProvider);

  return RoomRepositoryImpl(
    remoteDataSource: remoteDataSource,
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
  final deviceRemoteDataSource = ref.watch(deviceRemoteDataSourceProvider);
  final deviceLocalDataSource = ref.watch(deviceLocalDataSourceProvider);
  final roomRepository = ref.watch(roomRepositoryProvider);
  final notificationService = ref.watch(notificationGenerationServiceProvider);

  return BackgroundRefreshService(
    deviceRemoteDataSource: deviceRemoteDataSource,
    deviceLocalDataSource: deviceLocalDataSource,
    roomRepository: roomRepository,
    notificationGenerationService: notificationService,
  );
});
