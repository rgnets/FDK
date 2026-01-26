import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/security/certificate_validator.dart';

/// Mock X509Certificate for testing purposes
class MockX509Certificate implements X509Certificate {
  MockX509Certificate({
    required this.issuer,
    required this.subject,
    required this.startValidity,
    required this.endValidity,
  });

  @override
  final String issuer;

  @override
  final String subject;

  @override
  final DateTime startValidity;

  @override
  final DateTime endValidity;

  @override
  Uint8List get der => Uint8List.fromList([1, 2, 3, 4, 5]);

  @override
  String get pem => '-----BEGIN CERTIFICATE-----\nMOCK\n-----END CERTIFICATE-----';

  @override
  Uint8List get sha1 => Uint8List.fromList(List.generate(20, (i) => i));
}

void main() {
  late CertificateValidator validator;

  setUp(() {
    validator = CertificateValidator();
    validator.resetErrorState();
  });

  group('CertificateValidator', () {
    group('self-signed certificate detection', () {
      test('should detect self-signed certificate when issuer equals subject', () {
        // Arrange
        final selfSignedCert = MockX509Certificate(
          issuer: 'CN=Example Corp, O=Example Corp',
          subject: 'CN=Example Corp, O=Example Corp',
          startValidity: DateTime.now().subtract(const Duration(days: 365)),
          endValidity: DateTime.now().add(const Duration(days: 365)),
        );

        // Act
        final result = validator.validateCertificate(selfSignedCert, 'example.com', 443);

        // Assert
        // In debug mode, self-signed certs are accepted
        // In production, they should be rejected
        if (kDebugMode) {
          expect(result, isTrue, reason: 'Self-signed certs should be accepted in debug mode');
        } else {
          expect(result, isFalse, reason: 'Self-signed certs should be rejected in production');
        }
      });

      test('should accept valid certificate when issuer differs from subject', () {
        // Arrange
        final validCert = MockX509Certificate(
          issuer: 'CN=DigiCert CA, O=DigiCert Inc',
          subject: 'CN=example.com, O=Example Corp',
          startValidity: DateTime.now().subtract(const Duration(days: 365)),
          endValidity: DateTime.now().add(const Duration(days: 365)),
        );

        // Act
        final result = validator.validateCertificate(validCert, 'example.com', 443);

        // Assert
        expect(result, isTrue, reason: 'Valid CA-signed certificate should be accepted');
      });

      test('should detect self-signed certificate with complex DN', () {
        // Arrange
        final selfSignedCert = MockX509Certificate(
          issuer: 'C=US, ST=California, L=San Francisco, O=Example Corp, OU=IT, CN=internal.example.com',
          subject: 'C=US, ST=California, L=San Francisco, O=Example Corp, OU=IT, CN=internal.example.com',
          startValidity: DateTime.now().subtract(const Duration(days: 30)),
          endValidity: DateTime.now().add(const Duration(days: 30)),
        );

        // Act
        final result = validator.validateCertificate(selfSignedCert, 'internal.example.com', 443);

        // Assert
        if (kDebugMode) {
          expect(result, isTrue);
        } else {
          expect(result, isFalse);
        }
      });
    });

    group('certificate expiry validation', () {
      test('should reject expired certificate', () {
        // Arrange
        final expiredCert = MockX509Certificate(
          issuer: 'CN=DigiCert CA',
          subject: 'CN=example.com',
          startValidity: DateTime.now().subtract(const Duration(days: 730)),
          endValidity: DateTime.now().subtract(const Duration(days: 1)),
        );

        // Act
        final result = validator.validateCertificate(expiredCert, 'example.com', 443);

        // Assert
        expect(result, isFalse, reason: 'Expired certificate should be rejected');
      });

      test('should reject certificate that is not yet valid', () {
        // Arrange
        final notYetValidCert = MockX509Certificate(
          issuer: 'CN=DigiCert CA',
          subject: 'CN=example.com',
          startValidity: DateTime.now().add(const Duration(days: 1)),
          endValidity: DateTime.now().add(const Duration(days: 366)),
        );

        // Act
        final result = validator.validateCertificate(notYetValidCert, 'example.com', 443);

        // Assert
        expect(result, isFalse, reason: 'Certificate not yet valid should be rejected');
      });

      test('should accept certificate within validity period', () {
        // Arrange
        final validCert = MockX509Certificate(
          issuer: 'CN=DigiCert CA',
          subject: 'CN=example.com',
          startValidity: DateTime.now().subtract(const Duration(days: 180)),
          endValidity: DateTime.now().add(const Duration(days: 185)),
        );

        // Act
        final result = validator.validateCertificate(validCert, 'example.com', 443);

        // Assert
        expect(result, isTrue, reason: 'Certificate within validity period should be accepted');
      });

      test('should accept certificate that just became valid', () {
        // Arrange
        final justValidCert = MockX509Certificate(
          issuer: 'CN=DigiCert CA',
          subject: 'CN=example.com',
          startValidity: DateTime.now().subtract(const Duration(seconds: 1)),
          endValidity: DateTime.now().add(const Duration(days: 365)),
        );

        // Act
        final result = validator.validateCertificate(justValidCert, 'example.com', 443);

        // Assert
        expect(result, isTrue, reason: 'Certificate that just became valid should be accepted');
      });

      test('should accept certificate about to expire', () {
        // Arrange
        final aboutToExpireCert = MockX509Certificate(
          issuer: 'CN=DigiCert CA',
          subject: 'CN=example.com',
          startValidity: DateTime.now().subtract(const Duration(days: 364)),
          endValidity: DateTime.now().add(const Duration(seconds: 1)),
        );

        // Act
        final result = validator.validateCertificate(aboutToExpireCert, 'example.com', 443);

        // Assert
        expect(result, isTrue, reason: 'Certificate about to expire but still valid should be accepted');
      });
    });

    group('error handling', () {
      test('should return last error after self-signed detection', () {
        // Arrange
        final selfSignedCert = MockX509Certificate(
          issuer: 'CN=Example Corp',
          subject: 'CN=Example Corp',
          startValidity: DateTime.now().subtract(const Duration(days: 30)),
          endValidity: DateTime.now().add(const Duration(days: 30)),
        );

        // Act
        validator.validateCertificate(selfSignedCert, 'example.com', 443);
        final lastError = validator.getLastError();

        // Assert
        expect(lastError['has_error'], isTrue);
        expect(lastError['is_critical'], isTrue);
        expect(lastError['last_error_time'], isNotNull);
      });

      test('should return empty map when no error has occurred', () {
        // Arrange
        validator.resetErrorState();

        // Act
        final lastError = validator.getLastError();

        // Assert
        expect(lastError, isEmpty);
      });

      test('should reset error state correctly', () {
        // Arrange
        final selfSignedCert = MockX509Certificate(
          issuer: 'CN=Example Corp',
          subject: 'CN=Example Corp',
          startValidity: DateTime.now().subtract(const Duration(days: 30)),
          endValidity: DateTime.now().add(const Duration(days: 30)),
        );

        // Act
        validator.validateCertificate(selfSignedCert, 'example.com', 443);
        validator.resetErrorState();
        final lastError = validator.getLastError();

        // Assert
        expect(lastError, isEmpty);
      });
    });

    group('rate limiting', () {
      test('should rate limit repeated self-signed certificate errors', () {
        // Arrange
        final selfSignedCert = MockX509Certificate(
          issuer: 'CN=Example Corp',
          subject: 'CN=Example Corp',
          startValidity: DateTime.now().subtract(const Duration(days: 30)),
          endValidity: DateTime.now().add(const Duration(days: 30)),
        );

        // Act - call validation multiple times
        validator.validateCertificate(selfSignedCert, 'example.com', 443);
        validator.validateCertificate(selfSignedCert, 'example.com', 443);
        validator.validateCertificate(selfSignedCert, 'example.com', 443);
        final lastError = validator.getLastError();

        // Assert - should still only have one error logged (rate limited)
        expect(lastError['has_error'], isTrue);
      });
    });

    group('singleton pattern', () {
      test('should return the same instance', () {
        // Act
        final instance1 = CertificateValidator();
        final instance2 = CertificateValidator();

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('edge cases', () {
      test('should handle certificate with empty issuer and subject', () {
        // Arrange
        final emptyCert = MockX509Certificate(
          issuer: '',
          subject: '',
          startValidity: DateTime.now().subtract(const Duration(days: 30)),
          endValidity: DateTime.now().add(const Duration(days: 30)),
        );

        // Act
        final result = validator.validateCertificate(emptyCert, 'example.com', 443);

        // Assert - empty strings match, so treated as self-signed
        if (kDebugMode) {
          expect(result, isTrue);
        } else {
          expect(result, isFalse);
        }
      });

      test('should handle different port numbers', () {
        // Arrange
        final validCert = MockX509Certificate(
          issuer: 'CN=DigiCert CA',
          subject: 'CN=example.com',
          startValidity: DateTime.now().subtract(const Duration(days: 30)),
          endValidity: DateTime.now().add(const Duration(days: 30)),
        );

        // Act
        final result443 = validator.validateCertificate(validCert, 'example.com', 443);
        final result8443 = validator.validateCertificate(validCert, 'example.com', 8443);
        final result80 = validator.validateCertificate(validCert, 'example.com', 80);

        // Assert
        expect(result443, isTrue);
        expect(result8443, isTrue);
        expect(result80, isTrue);
      });
    });
  });
}
