import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';

/// Utility to provide QR code credentials
class QrDecoder {
  static final Logger _logger = Logger();

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
        final fqdn = apiUrl
            .replaceFirst('https://', '')
            .replaceFirst('http://', '')
            .split('/')
            .first;

        return {
          'fqdn': fqdn,
          'login': EnvironmentConfig.apiUsername,
          'apiKey': EnvironmentConfig.apiKey,
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
