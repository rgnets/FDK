import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// Validates SSL/TLS certificates for secure connections.
///
/// Handles self-signed certificates by accepting them in debug mode only,
/// while always rejecting them in production builds for security.
class CertificateValidator {
  static final CertificateValidator _instance = CertificateValidator._internal();

  factory CertificateValidator() => _instance;

  CertificateValidator._internal();

  bool _hasLoggedError = false;
  DateTime _lastErrorTime = DateTime.now();

  /// Main validation callback for HttpClient.badCertificateCallback
  ///
  /// This callback is invoked when the system's default certificate
  /// validation has failed. This implementation matches ATT-FE-Tool's behavior:
  /// - Self-signed certificates: Accept in debug mode only
  /// - Other certificates: Accept if not expired
  ///
  /// Returns true to accept the certificate, false to reject.
  bool validateCertificate(X509Certificate cert, String host, int port) {
    try {
      LoggerService.debug(
        'Certificate validation callback invoked for $host:$port',
        tag: 'CertificateValidator',
      );
      LoggerService.debug(
        'Certificate issuer: ${cert.issuer}',
        tag: 'CertificateValidator',
      );
      LoggerService.debug(
        'Certificate subject: ${cert.subject}',
        tag: 'CertificateValidator',
      );

      // Check if self-signed (issuer == subject)
      final isSelfSigned = _isSelfSigned(cert);

      if (isSelfSigned) {
        _handleSelfSignedCertificate(cert, host, port);

        // Allow bypass ONLY in debug builds
        if (kDebugMode) {
          LoggerService.warning(
            'DEBUG MODE: Accepting self-signed certificate for $host:$port',
            tag: 'CertificateValidator',
          );
          return true; // Accept in debug only
        }

        return false; // ALWAYS reject in production
      }

      // Additional validation checks for non-self-signed certs
      if (!_validateExpiry(cert)) {
        _handleExpiredCertificate(cert, host, port);
        return false;
      }

      // Accept valid certificates (matches ATT-FE-Tool behavior)
      LoggerService.debug(
        'Accepting non-self-signed certificate for $host:$port',
        tag: 'CertificateValidator',
      );
      return true;
    } catch (e, stack) {
      LoggerService.error(
        'Certificate validation error for $host:$port',
        tag: 'CertificateValidator',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  /// Check if certificate is self-signed.
  ///
  /// A self-signed certificate has the same issuer and subject.
  bool _isSelfSigned(X509Certificate cert) {
    return cert.issuer == cert.subject;
  }

  /// Validate certificate expiry dates.
  bool _validateExpiry(X509Certificate cert) {
    final now = DateTime.now();

    if (now.isBefore(cert.startValidity)) {
      return false; // Certificate not yet valid
    }

    if (now.isAfter(cert.endValidity)) {
      return false; // Certificate expired
    }

    return true;
  }

  /// Handle self-signed certificate detection with rate-limited logging.
  void _handleSelfSignedCertificate(
    X509Certificate cert,
    String host,
    int port,
  ) {
    // Rate limiting to prevent log spam (log every 5 minutes max)
    if (_hasLoggedError &&
        DateTime.now().difference(_lastErrorTime).inMinutes < 5) {
      return;
    }

    _hasLoggedError = true;
    _lastErrorTime = DateTime.now();

    final metadata = {
      'event_type': 'CERTIFICATE_VALIDATION_FAILED',
      'reason': 'SELF_SIGNED',
      'host': host,
      'port': port,
      'issuer': cert.issuer,
      'subject': cert.subject,
      'validity_start': cert.startValidity.toIso8601String(),
      'validity_end': cert.endValidity.toIso8601String(),
      'debug_mode': kDebugMode,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (kDebugMode) {
      LoggerService.warning(
        'Self-signed certificate detected for $host:$port - accepting in debug mode',
        tag: 'CertificateValidator',
      );
    } else {
      LoggerService.error(
        'SELF-SIGNED CERTIFICATE REJECTED: $host:$port. '
        'Self-signed certificates are not allowed in production. '
        'Contact your IT administrator to install a valid SSL certificate.',
        tag: 'CertificateValidator',
      );
    }

    LoggerService.debug(
      'Certificate metadata: $metadata',
      tag: 'CertificateValidator',
    );
  }

  /// Handle expired certificate with logging.
  void _handleExpiredCertificate(
    X509Certificate cert,
    String host,
    int port,
  ) {
    final now = DateTime.now();
    final isNotYetValid = now.isBefore(cert.startValidity);

    final message = isNotYetValid
        ? 'Certificate for $host:$port is not yet valid (starts ${cert.startValidity})'
        : 'Certificate for $host:$port expired on ${cert.endValidity}';

    LoggerService.error(
      message,
      tag: 'CertificateValidator',
    );

    LoggerService.debug(
      'Certificate expiry details: '
      'validity_start=${cert.startValidity.toIso8601String()}, '
      'validity_end=${cert.endValidity.toIso8601String()}, '
      'current_time=${now.toIso8601String()}',
      tag: 'CertificateValidator',
    );
  }

  /// Reset error state (useful for testing or retry scenarios).
  void resetErrorState() {
    _hasLoggedError = false;
    _lastErrorTime = DateTime.now();
  }

  /// Get diagnostic information about the last validation error.
  Map<String, dynamic> getLastError() {
    if (!_hasLoggedError) return {};

    return {
      'has_error': true,
      'last_error_time': _lastErrorTime.toIso8601String(),
      'is_critical': true,
    };
  }
}
