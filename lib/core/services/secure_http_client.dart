import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:rgnets_fdk/core/security/certificate_validator.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// Singleton HTTP client with SSL certificate validation.
///
/// Uses [CertificateValidator] to handle self-signed certificates,
/// accepting them only in debug mode for security.
///
/// Usage:
/// ```dart
/// final client = SecureHttpClient.getClient();
/// final response = await client.get(uri);
/// ```
class SecureHttpClient {
  static IOClient? _client;
  static final CertificateValidator _certValidator = CertificateValidator();

  // Private constructor to prevent instantiation
  SecureHttpClient._();

  /// Get or create the secure HTTP client.
  ///
  /// Returns a singleton [http.Client] instance configured with
  /// certificate validation for handling self-signed certificates.
  static http.Client getClient() {
    if (_client == null) {
      LoggerService.debug(
        'Creating new secure HTTP client with certificate validation',
        tag: 'SecureHttpClient',
      );
      final httpClient = HttpClient()
        ..badCertificateCallback = _certValidator.validateCertificate;
      _client = IOClient(httpClient);
    }
    return _client!;
  }

  /// Force creation of a new HTTP client.
  ///
  /// Use this when the current client has been closed or is in an
  /// invalid state.
  static http.Client createNewClient() {
    LoggerService.info(
      'Force creating new secure HTTP client',
      tag: 'SecureHttpClient',
    );
    dispose();
    return getClient();
  }

  /// Dispose of the HTTP client and release resources.
  ///
  /// Call this when the client is no longer needed or during app shutdown.
  static void dispose() {
    if (_client != null) {
      LoggerService.debug(
        'Disposing secure HTTP client',
        tag: 'SecureHttpClient',
      );
      _client!.close();
      _client = null;
    }
  }

  /// Check if a client instance currently exists.
  static bool get hasClient => _client != null;

  /// Validates HTTP connection by making a simple GET request.
  ///
  /// This "warms up" the HTTP client, which can help avoid issues
  /// when the first request is a large PUT (like image upload).
  /// Similar to how ATT-FE-Tool validates credentials via HTTP during login.
  ///
  /// Returns true if the connection is successful, false otherwise.
  static Future<bool> validateConnection(String siteUrl, String apiKey) async {
    try {
      final client = getClient();
      final uri = Uri.parse('https://$siteUrl/api/whoami.json?api_key=$apiKey');
      LoggerService.debug(
        'Validating HTTP connection to $siteUrl',
        tag: 'SecureHttpClient',
      );

      final response = await client.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw TimeoutException('Connection validation timeout'),
      );

      LoggerService.debug(
        'HTTP validation response: ${response.statusCode}',
        tag: 'SecureHttpClient',
      );
      return response.statusCode == 200;
    } catch (e) {
      LoggerService.error(
        'HTTP validation failed: $e',
        tag: 'SecureHttpClient',
      );
      return false;
    }
  }
}
