import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/core/services/notification_generation_service.dart';
import 'package:rgnets_fdk/core/services/performance_monitor_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Logger provider for consistent logging across the app
final loggerProvider = Provider<Logger>((ref) {
  // Disable logging in production
  if (EnvironmentConfig.isProduction) {
    return Logger(level: Level.off, printer: PrettyPrinter(methodCount: 0));
  }

  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
});

/// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden with override',
  );
});

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

/// Performance monitor service provider (singleton)
final performanceMonitorProvider = Provider<PerformanceMonitorService>((ref) {
  return PerformanceMonitorService.instance;
});

// Background refresh service provider moved to repository_providers.dart
// because it depends on data sources and repositories

/// Mock data service provider
final mockDataServiceProvider = Provider<MockDataService>((ref) {
  return MockDataService();
});

/// Notification generation service provider
final notificationGenerationServiceProvider =
    Provider<NotificationGenerationService>((ref) {
      return NotificationGenerationService();
    });

/// Initialize providers that need async initialization
Future<ProviderContainer> initializeProviders() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );
}
