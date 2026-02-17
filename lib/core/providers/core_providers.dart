import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/logging_config.dart';
import 'package:rgnets_fdk/core/services/device_update_event_bus.dart';
import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/core/services/notification_generation_service.dart';
import 'package:rgnets_fdk/core/services/performance_monitor_service.dart';
import 'package:rgnets_fdk/core/services/secure_storage_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/core/utils/image_url_normalizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Map app LogLevel to logger package Level
Level _toLoggerLevel(LogLevel logLevel) {
  switch (logLevel) {
    case LogLevel.off:
      return Level.off;
    case LogLevel.error:
      return Level.error;
    case LogLevel.warning:
      return Level.warning;
    case LogLevel.info:
      return Level.info;
    case LogLevel.debug:
      return Level.debug;
    case LogLevel.trace:
      return Level.trace;
  }
}

/// Logger provider for consistent logging across the app.
/// Respects LOG_LEVEL dart-define even in production builds.
final loggerProvider = Provider<Logger>((ref) {
  final level = _toLoggerLevel(LoggingConfig.logLevel);

  return Logger(
    level: level,
    printer: PrettyPrinter(
      methodCount: level == Level.off ? 0 : 2,
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

/// Secure storage service provider for sensitive credentials
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return StorageService(prefs, secureStorage);
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

/// Device update event bus provider
///
/// Enables the device detail view to refresh when external apps
/// modify device data (especially images) via WebSocket notifications.
final deviceUpdateEventBusProvider = Provider<DeviceUpdateEventBus>((ref) {
  final bus = DeviceUpdateEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});

/// Provider for the current API key used for authenticated HTTP requests.
/// This is the token stored during authentication, used to authenticate
/// image requests to the RXG backend's ActiveStorage.
/// Returns a Future since credentials are now stored in secure storage.
final apiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getToken();
});

/// Provider for authenticating image URLs with the current API key.
/// Returns a function that takes an image URL and returns an authenticated URL.
final authenticatedImageUrlProvider = Provider<String? Function(String?)>((ref) {
  final apiKeyAsync = ref.watch(apiKeyProvider);
  final apiKey = apiKeyAsync.valueOrNull;
  return (String? imageUrl) => authenticateImageUrl(imageUrl, apiKey);
});

/// Provider for authenticating a list of image URLs with the current API key.
final authenticatedImageUrlsProvider = Provider<List<String> Function(List<String>)>((ref) {
  final apiKeyAsync = ref.watch(apiKeyProvider);
  final apiKey = apiKeyAsync.valueOrNull;
  return (List<String> imageUrls) => authenticateImageUrls(imageUrls, apiKey);
});

/// Initialize providers that need async initialization
Future<ProviderContainer> initializeProviders() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );
}
