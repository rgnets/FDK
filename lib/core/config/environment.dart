import 'package:flutter/foundation.dart';

/// Environment configuration for different build flavors
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  static const String _defaultStagingToken =
      'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r';

  static void setEnvironment(Environment env) {
    _environment = env;
    // Only log in debug mode to avoid memory issues
    if (kDebugMode) {
      debugPrint(
        'EnvironmentConfig: Environment set, isDevelopment=$isDevelopment, '
        'isStaging=$isStaging, isProduction=$isProduction',
      );
      debugPrint('EnvironmentConfig: WebSocket URL will be: $websocketBaseUrl');
      debugPrint('EnvironmentConfig: useSyntheticData=$useSyntheticData');
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
        return const String.fromEnvironment(
          'STAGING_API_URL',
          defaultValue: '',
        );
      case Environment.production:
        // Production will use real customer URL (provided at runtime)
        return const String.fromEnvironment(
          'API_URL',
          defaultValue: 'https://api.rgnets.com',
        );
    }
  }

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
          defaultValue: 'wss://dlp.netlab.ninja/ws',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'WS_URL',
          defaultValue: 'wss://dlp.netlab.ninja/ws',
        );
    }
  }

  static bool get useWebSockets {
    const envFlag = bool.fromEnvironment('USE_WEBSOCKETS', defaultValue: true);
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
        defaultValue: true,
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
        return const String.fromEnvironment(
          'STAGING_API_LOGIN',
          defaultValue: '',
        );
      case Environment.production:
        return const String.fromEnvironment('API_USERNAME', defaultValue: '');
    }
  }

  /// API Key for HTTP requests.
  static String get apiKey {
    switch (_environment) {
      case Environment.development:
        return 'synthetic_api_key'; // Not used with synthetic data
      case Environment.staging:
        const stagingApiKey = String.fromEnvironment(
          'STAGING_API_KEY',
          defaultValue: '',
        );
        if (stagingApiKey.isNotEmpty) {
          return stagingApiKey;
        }
        const stagingToken = String.fromEnvironment(
          'STAGING_TOKEN',
          defaultValue: _defaultStagingToken,
        );
        return stagingToken;
      case Environment.production:
        return const String.fromEnvironment('API_KEY', defaultValue: '');
    }
  }

  /// Authentication token for WebSocket connections.
  static String get token {
    switch (_environment) {
      case Environment.development:
        return 'synthetic_token'; // Not used with synthetic data
      case Environment.staging:
        const stagingToken = String.fromEnvironment(
          'STAGING_TOKEN',
          defaultValue: '',
        );
        if (stagingToken.isNotEmpty) {
          return stagingToken;
        }
        const stagingApiKey = String.fromEnvironment(
          'STAGING_API_KEY',
          defaultValue: _defaultStagingToken,
        );
        return stagingApiKey;
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
