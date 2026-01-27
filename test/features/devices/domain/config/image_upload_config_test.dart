import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/devices/domain/config/image_upload_config.dart';

void main() {
  group('ImageUploadConfig', () {
    group('compression settings', () {
      test('maxDimension should be 1280 for WebSocket-friendly uploads', () {
        expect(ImageUploadConfig.maxDimension, equals(1280));
      });

      test('minDimension should be 400', () {
        expect(ImageUploadConfig.minDimension, equals(400));
      });

      test('imageQuality should be 70 (0-100 range) for smaller file sizes', () {
        expect(ImageUploadConfig.imageQuality, equals(70));
        expect(
          ImageUploadConfig.imageQuality,
          inInclusiveRange(0, 100),
        );
      });

      test('maxFileSizeBytes should be 2MB for WebSocket reliability', () {
        expect(ImageUploadConfig.maxFileSizeBytes, equals(2 * 1024 * 1024));
      });

      test('enableDownsampling should be true by default', () {
        expect(ImageUploadConfig.enableDownsampling, isTrue);
      });
    });

    group('verification settings', () {
      test('maxVerificationAttempts should be 3', () {
        expect(ImageUploadConfig.maxVerificationAttempts, equals(3));
      });

      test('initialVerificationDelay should be 2 seconds', () {
        expect(
          ImageUploadConfig.initialVerificationDelay,
          equals(const Duration(seconds: 2)),
        );
      });

      test('betweenAttemptsDelay should be 1 second', () {
        expect(
          ImageUploadConfig.betweenAttemptsDelay,
          equals(const Duration(seconds: 1)),
        );
      });

      test('maxTotalWaitTime should be 10 seconds', () {
        expect(
          ImageUploadConfig.maxTotalWaitTime,
          equals(const Duration(seconds: 10)),
        );
      });
    });

    group('upload settings', () {
      test('maxRetries should be 3', () {
        expect(ImageUploadConfig.maxRetries, equals(3));
      });

      test('uploadTimeout should be 90 seconds', () {
        expect(
          ImageUploadConfig.uploadTimeout,
          equals(const Duration(seconds: 90)),
        );
      });

      test('warningSizeKB should be 1024 (1MB)', () {
        expect(ImageUploadConfig.warningSizeKB, equals(1024));
      });
    });

    group('value ranges are sensible', () {
      test('maxDimension should be greater than minDimension', () {
        expect(
          ImageUploadConfig.maxDimension,
          greaterThan(ImageUploadConfig.minDimension),
        );
      });

      test('maxFileSizeBytes should be positive', () {
        expect(ImageUploadConfig.maxFileSizeBytes, greaterThan(0));
      });

      test('maxTotalWaitTime should be longer than initialVerificationDelay', () {
        expect(
          ImageUploadConfig.maxTotalWaitTime,
          greaterThan(ImageUploadConfig.initialVerificationDelay),
        );
      });

      test('maxTotalWaitTime should accommodate all retry attempts', () {
        final minTimeNeeded =
            ImageUploadConfig.initialVerificationDelay +
            (ImageUploadConfig.betweenAttemptsDelay *
                (ImageUploadConfig.maxVerificationAttempts - 1));

        expect(
          ImageUploadConfig.maxTotalWaitTime,
          greaterThanOrEqualTo(minTimeNeeded),
        );
      });
    });
  });
}
