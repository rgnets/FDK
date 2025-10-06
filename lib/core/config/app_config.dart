/// Application configuration
/// Handles environment-specific settings and API configuration
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
      'fqdn': const String.fromEnvironment('TEST_API_FQDN', 
          defaultValue: 'vgw1-01.dal-interurban.mdu.attwifi.com'),
      'login': const String.fromEnvironment('TEST_API_LOGIN', 
          defaultValue: 'fetoolreadonly'),
      'apiKey': const String.fromEnvironment('TEST_API_KEY', 
          defaultValue: 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r'),
    };
  }
  
  /// Get the API base URL
  static String get apiBaseUrl {
    // This is deprecated - use EnvironmentConfig.apiBaseUrl instead
    final fqdn = testCredentials['fqdn'] ?? 'api.example.com';
    return 'https://$fqdn';
  }
  
  /// Get API headers for requests
  static Map<String, String> getApiHeaders({
    String? login,
    String? apiKey,
  }) {
    // Use provided credentials or fall back to test credentials
    final useLogin = login ?? testCredentials['login'] ?? '';
    final useApiKey = apiKey ?? testCredentials['apiKey'] ?? '';
    
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
  
  /// API endpoints
  static const String apiVersion = '/api/v1';
  
  // Device endpoints
  static const String accessPointsEndpoint = '/access_points';
  static const String ontsEndpoint = '/media_converters';
  static const String switchesEndpoint = '/switch_devices';
  static const String pmsRoomsEndpoint = '/pms_rooms';
  
  /// Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  /// Scanner configuration
  static const Duration scanAccumulationWindow = Duration(seconds: 6);
  static const Duration scanExpirationTime = Duration(seconds: 30);
}