import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/image_upload_state.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_upload_verifier.dart';

void main() {
  group('ImageUploadVerifier', () {
    group('verifyUpload', () {
      test('should return success when expected count is reached', () async {
        var callCount = 0;
        final verifier = ImageUploadVerifier(
          fetchImagesCallback: (deviceType, deviceId) async {
            callCount++;
            return ['image1.jpg', 'image2.jpg', 'image3.jpg'];
          },
        );

        final result = await verifier.verifyUpload(
          expectedCount: 3,
          deviceType: 'access_point',
          deviceId: 'ap_123',
          previousCount: 2,
        );

        expect(result, equals(VerificationResult.success));
        expect(callCount, greaterThanOrEqualTo(1));
      });

      test('should return partialSuccess when some images found', () async {
        var callCount = 0;
        final verifier = ImageUploadVerifier(
          fetchImagesCallback: (deviceType, deviceId) async {
            callCount++;
            // Return 2 images when 3 were expected, but more than previous 1
            return ['image1.jpg', 'image2.jpg'];
          },
        );

        final result = await verifier.verifyUpload(
          expectedCount: 3,
          deviceType: 'access_point',
          deviceId: 'ap_123',
          previousCount: 1,
        );

        expect(result, equals(VerificationResult.partialSuccess));
      });

      test('should return timeout when no change detected after retries',
          () async {
        var callCount = 0;
        final verifier = ImageUploadVerifier(
          fetchImagesCallback: (deviceType, deviceId) async {
            callCount++;
            // Return same count as previous (no change)
            return ['image1.jpg'];
          },
          // Use shorter delays for testing
          initialDelay: const Duration(milliseconds: 10),
          betweenAttempts: const Duration(milliseconds: 10),
          maxTotalWaitTime: const Duration(milliseconds: 100),
        );

        final result = await verifier.verifyUpload(
          expectedCount: 3,
          deviceType: 'access_point',
          deviceId: 'ap_123',
          previousCount: 1,
        );

        expect(result, equals(VerificationResult.timeout));
        expect(callCount, greaterThan(1)); // Should have retried
      });

      test('should return failed when fetch throws error', () async {
        final verifier = ImageUploadVerifier(
          fetchImagesCallback: (deviceType, deviceId) async {
            throw Exception('Network error');
          },
          initialDelay: const Duration(milliseconds: 10),
          betweenAttempts: const Duration(milliseconds: 10),
          maxTotalWaitTime: const Duration(milliseconds: 100),
        );

        final result = await verifier.verifyUpload(
          expectedCount: 3,
          deviceType: 'access_point',
          deviceId: 'ap_123',
          previousCount: 1,
        );

        expect(result, equals(VerificationResult.failed));
      });

      test('should return success even if it takes multiple attempts', () async {
        var callCount = 0;
        final verifier = ImageUploadVerifier(
          fetchImagesCallback: (deviceType, deviceId) async {
            callCount++;
            // First call returns old count, second returns expected
            if (callCount == 1) {
              return ['image1.jpg', 'image2.jpg'];
            }
            return ['image1.jpg', 'image2.jpg', 'image3.jpg'];
          },
          initialDelay: const Duration(milliseconds: 10),
          betweenAttempts: const Duration(milliseconds: 10),
          maxTotalWaitTime: const Duration(seconds: 5),
        );

        final result = await verifier.verifyUpload(
          expectedCount: 3,
          deviceType: 'access_point',
          deviceId: 'ap_123',
          previousCount: 2,
        );

        expect(result, equals(VerificationResult.success));
        expect(callCount, equals(2));
      });

      test('should return partialSuccess when new images found but error occurs',
          () async {
        var callCount = 0;
        final verifier = ImageUploadVerifier(
          fetchImagesCallback: (deviceType, deviceId) async {
            callCount++;
            if (callCount == 1) {
              // First call succeeds with partial result
              return ['image1.jpg', 'image2.jpg'];
            }
            // Subsequent calls fail
            throw Exception('Network error');
          },
          initialDelay: const Duration(milliseconds: 10),
          betweenAttempts: const Duration(milliseconds: 10),
          maxTotalWaitTime: const Duration(milliseconds: 100),
        );

        final result = await verifier.verifyUpload(
          expectedCount: 3,
          deviceType: 'access_point',
          deviceId: 'ap_123',
          previousCount: 1,
        );

        expect(result, equals(VerificationResult.partialSuccess));
      });

      test('should handle timeout exception from fetch', () async {
        final verifier = ImageUploadVerifier(
          fetchImagesCallback: (deviceType, deviceId) async {
            throw TimeoutException('Fetch timeout');
          },
          initialDelay: const Duration(milliseconds: 10),
          betweenAttempts: const Duration(milliseconds: 10),
          maxTotalWaitTime: const Duration(milliseconds: 100),
        );

        final result = await verifier.verifyUpload(
          expectedCount: 3,
          deviceType: 'access_point',
          deviceId: 'ap_123',
          previousCount: 1,
        );

        // Should return timeout or failed, not crash
        expect(
          result,
          anyOf(equals(VerificationResult.timeout), equals(VerificationResult.failed)),
        );
      });
    });

    group('getUserMessage', () {
      test('should return appropriate message for success', () {
        final message = ImageUploadVerifier.getUserMessage(VerificationResult.success);
        expect(message, equals('Image uploaded successfully'));
      });

      test('should return appropriate message for partialSuccess', () {
        final message = ImageUploadVerifier.getUserMessage(VerificationResult.partialSuccess);
        expect(message, equals('Image uploaded - verification pending'));
      });

      test('should return appropriate message for timeout', () {
        final message = ImageUploadVerifier.getUserMessage(VerificationResult.timeout);
        expect(message, equals('Upload in progress - please refresh to verify'));
      });

      test('should return appropriate message for failed', () {
        final message = ImageUploadVerifier.getUserMessage(VerificationResult.failed);
        expect(message, equals('Upload failed - please try again or contact support'));
      });
    });

    group('shouldShowError', () {
      test('should return false for success', () {
        expect(ImageUploadVerifier.shouldShowError(VerificationResult.success), isFalse);
      });

      test('should return false for partialSuccess', () {
        expect(ImageUploadVerifier.shouldShowError(VerificationResult.partialSuccess), isFalse);
      });

      test('should return false for timeout', () {
        expect(ImageUploadVerifier.shouldShowError(VerificationResult.timeout), isFalse);
      });

      test('should return true for failed', () {
        expect(ImageUploadVerifier.shouldShowError(VerificationResult.failed), isTrue);
      });
    });

    group('getMessageSeverity', () {
      test('should return success for success result', () {
        expect(ImageUploadVerifier.getMessageSeverity(VerificationResult.success), equals('success'));
      });

      test('should return warning for partialSuccess result', () {
        expect(ImageUploadVerifier.getMessageSeverity(VerificationResult.partialSuccess), equals('warning'));
      });

      test('should return info for timeout result', () {
        expect(ImageUploadVerifier.getMessageSeverity(VerificationResult.timeout), equals('info'));
      });

      test('should return error for failed result', () {
        expect(ImageUploadVerifier.getMessageSeverity(VerificationResult.failed), equals('error'));
      });
    });
  });
}
