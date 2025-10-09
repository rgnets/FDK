import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/services/api_service.dart';
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

/// Dio HTTP client provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors for logging only in development
  if (EnvironmentConfig.isDevelopment) {
    final logger = ref.watch(loggerProvider);
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) => logger.d(object.toString()),
      ),
    );
  }

  return dio;
});

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

/// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(storageServiceProvider);

  return ApiService(dio: dio, storageService: storage);
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
