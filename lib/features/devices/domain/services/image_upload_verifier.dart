/// Image upload verification service.
///
/// Provides intelligent verification of image uploads with proper error detection.
/// This service prevents spurious error messages by distinguishing between
/// actual failures, timeouts, and partial successes.
library;

import 'dart:async';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/devices/domain/config/image_upload_config.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/image_upload_state.dart';

/// Callback type for fetching device images
typedef FetchImagesCallback = Future<List<String>> Function(
  String deviceType,
  String deviceId,
);

/// Service for verifying image uploads
class ImageUploadVerifier {
  final FetchImagesCallback _fetchImagesCallback;
  final Duration _initialDelay;
  final Duration _betweenAttempts;
  final Duration _maxTotalWaitTime;
  final int _maxAttempts;

  ImageUploadVerifier({
    required FetchImagesCallback fetchImagesCallback,
    Duration? initialDelay,
    Duration? betweenAttempts,
    Duration? maxTotalWaitTime,
    int? maxAttempts,
  })  : _fetchImagesCallback = fetchImagesCallback,
        _initialDelay =
            initialDelay ?? ImageUploadConfig.initialVerificationDelay,
        _betweenAttempts =
            betweenAttempts ?? ImageUploadConfig.betweenAttemptsDelay,
        _maxTotalWaitTime =
            maxTotalWaitTime ?? ImageUploadConfig.maxTotalWaitTime,
        _maxAttempts =
            maxAttempts ?? ImageUploadConfig.maxVerificationAttempts;

  /// Verify that an image upload completed successfully
  ///
  /// [expectedCount] - The expected number of images after upload
  /// [deviceType] - The type of device (access_point, ont, switch)
  /// [deviceId] - The device ID
  /// [previousCount] - Number of images before upload
  ///
  /// Returns a [VerificationResult] indicating the outcome
  Future<VerificationResult> verifyUpload({
    required int expectedCount,
    required String deviceType,
    required String deviceId,
    required int previousCount,
  }) async {
    LoggerService.debug(
      'Starting verification - Expected: $expectedCount, Previous: $previousCount',
      tag: 'ImageUploadVerifier',
    );

    // Initial delay to allow server processing
    await Future<void>.delayed(_initialDelay);

    final stopwatch = Stopwatch()..start();
    var attempts = 0;
    List<String> verifiedImages = [];
    var foundNewImages = false;
    Exception? lastError;

    while (attempts < _maxAttempts && stopwatch.elapsed < _maxTotalWaitTime) {
      attempts++;

      try {
        LoggerService.debug(
          'Verification attempt $attempts/$_maxAttempts',
          tag: 'ImageUploadVerifier',
        );

        verifiedImages = await _fetchImagesCallback(deviceType, deviceId)
            .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Fetch timeout'),
        );

        LoggerService.debug(
          'Found ${verifiedImages.length} images',
          tag: 'ImageUploadVerifier',
        );

        // Check if we have the expected count
        if (verifiedImages.length >= expectedCount) {
          LoggerService.info(
            'Full verification success - all images found',
            tag: 'ImageUploadVerifier',
          );
          return VerificationResult.success;
        }

        // Check if we have more images than before (partial success)
        if (verifiedImages.length > previousCount) {
          foundNewImages = true;
          final newCount = verifiedImages.length - previousCount;
          LoggerService.info(
            'Found $newCount new images (partial success)',
            tag: 'ImageUploadVerifier',
          );

          // If we found some new images, consider it partial success
          // Don't keep retrying if we already have progress
          if (attempts >= 2) {
            return VerificationResult.partialSuccess;
          }
        }

        // If not the last attempt, wait before retrying
        if (attempts < _maxAttempts) {
          await Future<void>.delayed(_betweenAttempts);
        }
      } on TimeoutException catch (e) {
        LoggerService.warning(
          'Verification timeout on attempt $attempts',
          tag: 'ImageUploadVerifier',
        );
        lastError = Exception('Verification timeout: ${e.message}');

        // If we found new images before timeout, it's partial success
        if (foundNewImages) {
          return VerificationResult.partialSuccess;
        }
      } catch (e) {
        LoggerService.error(
          'Error during verification attempt $attempts',
          tag: 'ImageUploadVerifier',
          error: e,
        );
        lastError = e is Exception ? e : Exception(e.toString());

        // If we found new images before error, consider it partial success
        if (foundNewImages) {
          return VerificationResult.partialSuccess;
        }

        // Continue trying unless this was the last attempt
        if (attempts >= _maxAttempts) {
          return VerificationResult.failed;
        }

        // Wait before retry
        if (attempts < _maxAttempts) {
          await Future<void>.delayed(_betweenAttempts);
        }
      }
    }

    // After all attempts, determine result
    if (foundNewImages) {
      LoggerService.info(
        'Partial success - some images uploaded',
        tag: 'ImageUploadVerifier',
      );
      return VerificationResult.partialSuccess;
    } else if (verifiedImages.length == previousCount) {
      LoggerService.warning(
        'Timeout - no change detected (upload may still be in progress)',
        tag: 'ImageUploadVerifier',
      );
      return VerificationResult.timeout;
    } else {
      LoggerService.error(
        'Verification failed after $attempts attempts',
        tag: 'ImageUploadVerifier',
        error: lastError,
      );
      return VerificationResult.failed;
    }
  }

  /// Determine if an error message should be shown to the user
  ///
  /// Only show error for actual failures, not timeouts or partial success
  static bool shouldShowError(VerificationResult result) {
    return result == VerificationResult.failed;
  }

  /// Get appropriate user-facing message for verification result
  static String getUserMessage(VerificationResult result) {
    switch (result) {
      case VerificationResult.success:
        return 'Image uploaded successfully';
      case VerificationResult.partialSuccess:
        return 'Image uploaded - verification pending';
      case VerificationResult.timeout:
        return 'Upload in progress - please refresh to verify';
      case VerificationResult.failed:
        return 'Upload failed - please try again or contact support';
    }
  }

  /// Get message color/severity for UI
  static String getMessageSeverity(VerificationResult result) {
    switch (result) {
      case VerificationResult.success:
        return 'success'; // Green
      case VerificationResult.partialSuccess:
        return 'warning'; // Orange
      case VerificationResult.timeout:
        return 'info'; // Blue
      case VerificationResult.failed:
        return 'error'; // Red
    }
  }
}
