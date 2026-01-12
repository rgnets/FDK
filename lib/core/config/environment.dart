import 'package:logger/logger.dart';

/// Environment configuration for different build flavors
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  static final Logger _logger = Logger();

  static void setEnvironment(Environment env) {
    _logger.i('🔧 EnvironmentConfig: Setting environment to ${env.name}');
    _environment = env;
    _logger
      ..i(
        '🔧 EnvironmentConfig: Environment set, isDevelopment=$isDevelopment, isStaging=$isStaging, isProduction=$isProduction',
      )
      ..i('🔧 EnvironmentConfig: WebSocket URL will be: $websocketBaseUrl')
      ..i('🔧 EnvironmentConfig: useSyntheticData=$useSyntheticData');
  }

  static Environment get environment => _environment;

  static String get name => _environment.name;

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  /// Get the host (FQDN) from the WebSocket URL for authentication purposes.
  static String get host {
    final wsUri = Uri.parse(websocketBaseUrl);
    return wsUri.host;
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
      isDevelopment; // Only debug uses synthetic
  static bool get enableDebugBanner => isDevelopment;
  static bool get enablePerformanceOverlay => isDevelopment;

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

  /// Authentication token for WebSocket connections.
  static String get token {
    switch (_environment) {
      case Environment.development:
        return 'synthetic_token'; // Not used with synthetic data
      case Environment.staging:
        // For staging, use environment variable with fallback to known staging token
        // This ensures staging works even without explicit environment variables
        const stagingToken = String.fromEnvironment(
          'STAGING_TOKEN',
          defaultValue:
              'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r',
        );
        return stagingToken;
      case Environment.production:
        const tok = String.fromEnvironment('WS_TOKEN', defaultValue: '');
        if (tok.isEmpty) {
          throw Exception('WS_TOKEN not provided for production');
        }
        return tok;
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
