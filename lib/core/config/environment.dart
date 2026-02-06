import 'package:flutter/foundation.dart';

/// Environment configuration for different build flavors
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
    warnIfCompileTimeCredentials();
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

  /// REST API base URL - currently unused as the app uses WebSocket-only
  /// communication. Retained for potential future REST endpoint needs.
  @Deprecated('FDK uses WebSocket-only communication. '
      'Use webSocketUrl instead for all data operations.')
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
  ///
  /// SECURITY NOTE: Values provided via --dart-define are compiled as string
  /// constants into the binary and can be extracted from APK/IPA files.
  /// For production builds, use runtime credential injection (QR code scanning
  /// or manual entry) instead of compile-time constants.
  ///
  /// For staging/production, credentials MUST be provided via environment variables:
  /// - STAGING_API_LOGIN / API_USERNAME
  /// - STAGING_API_KEY or STAGING_TOKEN / API_KEY or WS_TOKEN
  static String get apiUsername {
    switch (_environment) {
      case Environment.development:
        return 'synthetic_user'; // Not used with synthetic data
      case Environment.staging:
        const stagingLogin = String.fromEnvironment(
          'STAGING_API_LOGIN',
          defaultValue: '',
        );
        if (stagingLogin.isEmpty) {
          throw StateError(
            'STAGING_API_LOGIN environment variable is required for staging. '
            'Build with: --dart-define=STAGING_API_LOGIN=your_username',
          );
        }
        return stagingLogin;
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
          defaultValue: '',
        );
        if (stagingToken.isEmpty) {
          throw StateError(
            'STAGING_API_KEY or STAGING_TOKEN environment variable is required for staging. '
            'Build with: --dart-define=STAGING_API_KEY=your_key',
          );
        }
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
          defaultValue: '',
        );
        if (stagingApiKey.isEmpty) {
          throw StateError(
            'STAGING_TOKEN or STAGING_API_KEY environment variable is required for staging. '
            'Build with: --dart-define=STAGING_TOKEN=your_token',
          );
        }
        return stagingApiKey;
      case Environment.production:
        const tok = String.fromEnvironment('WS_TOKEN', defaultValue: '');
        if (tok.isEmpty) {
          throw StateError('WS_TOKEN not provided for production');
        }
        return tok;
    }
  }

  /// Checks if compile-time credentials are present and logs a security
  /// warning if they are being used in a release build.
  /// Call this during app initialization to alert developers.
  static void warnIfCompileTimeCredentials() {
    const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');
    const wsToken = String.fromEnvironment('WS_TOKEN', defaultValue: '');
    const apiUsername = String.fromEnvironment('API_USERNAME', defaultValue: '');

    if (!kDebugMode && (apiKey.isNotEmpty || wsToken.isNotEmpty || apiUsername.isNotEmpty)) {
      debugPrint(
        'SECURITY WARNING: Compile-time credentials detected in a non-debug build. '
        'Values passed via --dart-define are embedded as string constants in the binary '
        'and can be extracted from APK/IPA files. For production, use runtime credential '
        'injection (QR code scanning or manual entry) instead.',
      );
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
