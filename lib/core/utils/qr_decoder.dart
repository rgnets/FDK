import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';

/// Utility to provide QR code credentials
class QrDecoder {
  static final _logger = LoggerConfig.getLogger();

  /// Get the test API credentials
  /// In production, this would decode an actual QR code image
  /// For staging/development, uses environment configuration
  static Future<Map<String, dynamic>?> decodeTestApiQr() async {
    try {
      // In a real implementation, this would decode the QR code from assets
      // For security, credentials should come from environment variables

      if (EnvironmentConfig.isStaging || EnvironmentConfig.isDevelopment) {
        // Use environment-configured credentials
        final apiUrl = EnvironmentConfig.apiBaseUrl;
        final login = EnvironmentConfig.apiUsername;
        final apiKey = EnvironmentConfig.apiKey;
        if (apiUrl.isEmpty || login.isEmpty || apiKey.isEmpty) {
          _logger.w('QR credentials not configured via environment');
          return null;
        }

        final fqdn = apiUrl
            .replaceFirst('https://', '')
            .replaceFirst('http://', '')
            .split('/')
            .first;

        return {
          'fqdn': fqdn,
          'login': login,
          'apiKey': apiKey,
          'site_name': fqdn,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        };
      }

      // In production, this would decode from actual QR code
      // or return null to force manual authentication
      return null;
    } on Exception catch (e) {
      _logger.e('Error getting QR credentials: $e');
      return null;
    }
  }
}
