import 'package:flutter/foundation.dart';

/// Environment configuration for different build flavors
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
    // Only log in debug mode to avoid memory issues
    if (kDebugMode) {
      debugPrint('EnvironmentConfig: Set to ${env.name}');
    }
  }

  static Environment get environment => _environment;

  static String get name => _environment.name;

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  /// API Configuration
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        // Development uses synthetic/mock data, no real API
        return const String.fromEnvironment(
          'DEV_API_URL',
          defaultValue: 'http://mock-api.local',
        );
      case Environment.staging:
        // Staging uses the interurban test environment
        return 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
      case Environment.production:
        // Production will use real customer URL (provided at runtime)
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'https://api.rgnets.com',
        );
    }
  }

  /// WebSocket configuration
  static String get websocketBaseUrl {
    switch (_environment) {
      case Environment.development:
        return const String.fromEnvironment(
          'DEV_WS_URL',
          defaultValue: 'ws://localhost:9443/ws',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'STAGING_WS_URL',
          defaultValue: 'wss://zew.netlab.ninja/ws',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'WS_URL',
          defaultValue: 'wss://zew.netlab.ninja/ws',
        );
    }
  }

  static bool get useWebSockets {
    const envFlag = bool.fromEnvironment('USE_WEBSOCKETS', defaultValue: true);
    return envFlag;
  }

  static bool get enableRestFallback {
    const envFlag = bool.fromEnvironment(
      'USE_REST_FALLBACK',
      defaultValue: true,
    );
    return envFlag;
  }

  static Duration get webSocketInitialReconnectDelay => const Duration(
    milliseconds: int.fromEnvironment(
      'WS_RECONNECT_BASE_MS',
      defaultValue: 1000,
    ),
  );

  static Duration get webSocketMaxReconnectDelay => const Duration(
    milliseconds: int.fromEnvironment(
      'WS_RECONNECT_MAX_MS',
      defaultValue: 32000,
    ),
  );

  static Duration get webSocketHeartbeatInterval => const Duration(
    seconds: int.fromEnvironment('WS_HEARTBEAT_INTERVAL_S', defaultValue: 30),
  );

  static Duration get webSocketHeartbeatTimeout => const Duration(
    seconds: int.fromEnvironment('WS_HEARTBEAT_TIMEOUT_S', defaultValue: 45),
  );

  /// Feature flags
  static bool get enableLogging => !isProduction;
  static bool get useSyntheticData =>
      isDevelopment &&
      const bool.fromEnvironment(
        'USE_SYNTHETIC_DATA',
        defaultValue: false,
      );
  static bool get enableDebugBanner => isDevelopment;
  static bool get enablePerformanceOverlay => isDevelopment;

  static bool get skipAutoLogin {
    return const bool.fromEnvironment(
      'SKIP_AUTO_LOGIN',
      defaultValue: false,
    );
  }

  /// API Credentials
  static String get apiUsername {
    switch (_environment) {
      case Environment.development:
        return 'synthetic_user'; // Not used with synthetic data
      case Environment.staging:
        // Interurban test credentials
        return 'fetoolreadonly';
      case Environment.production:
        return const String.fromEnvironment('API_USERNAME', defaultValue: '');
    }
  }

  static String get apiKey {
    switch (_environment) {
      case Environment.development:
        return 'synthetic_key'; // Not used with synthetic data
      case Environment.staging:
        // For staging, use environment variable with fallback to known staging key
        // This ensures staging works even without explicit environment variables
        const stagingKey = String.fromEnvironment(
          'STAGING_API_KEY',
          defaultValue:
              'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r',
        );
        return stagingKey;
      case Environment.production:
        const key = String.fromEnvironment('API_KEY', defaultValue: '');
        if (key.isEmpty) {
          throw Exception('API_KEY not provided for production');
        }
        return key;
    }
  }

  /// Sentry DSN
  static String get sentryDsn {
    if (isDevelopment) {
      return '';
    }
    return const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  }
}
