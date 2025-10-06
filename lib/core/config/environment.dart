import 'package:logger/logger.dart';

/// Environment configuration for different build flavors
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  static final Logger _logger = Logger();
  
  static void setEnvironment(Environment env) {
    _logger.i('🔧 EnvironmentConfig: Setting environment to ${env.name}');
    _environment = env;
    _logger
      ..i('🔧 EnvironmentConfig: Environment set, isDevelopment=$isDevelopment, isStaging=$isStaging, isProduction=$isProduction')
      ..i('🔧 EnvironmentConfig: API Base URL will be: $apiBaseUrl')
      ..i('🔧 EnvironmentConfig: useSyntheticData=$useSyntheticData');
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
        return const String.fromEnvironment('DEV_API_URL', 
            defaultValue: 'http://mock-api.local');
      case Environment.staging:
        // Staging uses the interurban test environment
        return 'https://vgw1-01.dal-interurban.mdu.attwifi.com';
      case Environment.production:
        // Production will use real customer URL (provided at runtime)
        return const String.fromEnvironment('API_URL', 
            defaultValue: 'https://api.rgnets.com');
    }
  }
  
  /// Feature flags
  static bool get enableLogging => !isProduction;
  static bool get useSyntheticData => isDevelopment; // Only debug uses synthetic
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
  
  static String get apiKey {
    switch (_environment) {
      case Environment.development:
        return 'synthetic_key'; // Not used with synthetic data
      case Environment.staging:
        // For staging, use environment variable with fallback to known staging key
        // This ensures staging works even without explicit environment variables
        const stagingKey = String.fromEnvironment(
          'STAGING_API_KEY', 
          defaultValue: 'xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r'
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