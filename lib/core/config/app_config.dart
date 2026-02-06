import 'package:rgnets_fdk/core/config/environment.dart';

/// Application configuration
/// Handles environment-specific settings and WebSocket configuration
class AppConfig {
  // NOTE: Do NOT use this for environment detection! Use EnvironmentConfig instead.
  // This is only for backwards compatibility and will be removed.
  @Deprecated('Use EnvironmentConfig.isDevelopment instead')
  static const bool isDevelopment = false; // Use EnvironmentConfig instead

  /// Test credentials should be loaded from environment variables
  /// Never commit actual credentials to version control
  static Map<String, String> get testCredentials {
    // In production, these should come from secure environment variables
    // For staging, we provide working defaults for the test environment
    return {
      'fqdn': const String.fromEnvironment(
        'TEST_API_FQDN',
        defaultValue: '',
      ),
      'login': const String.fromEnvironment(
        'TEST_API_LOGIN',
        defaultValue: '',
      ),
      'apiKey': const String.fromEnvironment(
        'TEST_API_KEY',
        defaultValue: '',
      ),
      'token': const String.fromEnvironment(
        'TEST_TOKEN',
        defaultValue: '',
      ),
    };
  }

  /// Get the API base URL
  @Deprecated('FDK uses WebSocket-only communication. '
      'Use EnvironmentConfig.webSocketUrl instead.')
  static String get apiBaseUrl {
    // ignore: deprecated_member_use_from_same_package
    return EnvironmentConfig.apiBaseUrl;
  }

  /// Get API headers for requests
  static Map<String, String> getApiHeaders({
    String? login,
    String? apiKey,
  }) {
    // Use provided credentials or fall back to environment configuration
    final useLogin = login ?? EnvironmentConfig.apiUsername;
    final useApiKey = apiKey ?? EnvironmentConfig.apiKey;


    return {
      'X-API-Login': useLogin,
      'X-API-Key': useApiKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Test QR code for scanner testing
  static const String testQrCodePath = 'assets/interurban fetoolreadonly flutter test suite json.png';

  /// Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableMockData = false; // Set to false to use real API
  static const bool enableLogging = true;
  static const bool allowSelfSignedCerts = bool.fromEnvironment('ALLOW_SELF_SIGNED_CERTS', defaultValue: false);

  /// Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  /// Scanner configuration
  static const Duration scanAccumulationWindow = Duration(seconds: 6);
  static const Duration scanExpirationTime = Duration(seconds: 30);
}
