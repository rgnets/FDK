import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/image_upload_state.dart';

void main() {
  group('ImageUploadState enum', () {
    test('should have all expected states', () {
      expect(ImageUploadState.values.length, equals(4));
      expect(ImageUploadState.values, contains(ImageUploadState.local));
      expect(ImageUploadState.values, contains(ImageUploadState.uploading));
      expect(ImageUploadState.values, contains(ImageUploadState.uploaded));
      expect(ImageUploadState.values, contains(ImageUploadState.failed));
    });
  });

  group('VerificationResult enum', () {
    test('should have all expected results', () {
      expect(VerificationResult.values.length, equals(4));
      expect(VerificationResult.values, contains(VerificationResult.success));
      expect(
        VerificationResult.values,
        contains(VerificationResult.partialSuccess),
      );
      expect(VerificationResult.values, contains(VerificationResult.timeout));
      expect(VerificationResult.values, contains(VerificationResult.failed));
    });
  });

  group('ImageWithUploadState', () {
    test('should create with required fields', () {
      final imageWithState = ImageWithUploadState(
        imageData: 'test_image_data',
        state: ImageUploadState.local,
      );

      expect(imageWithState.imageData, equals('test_image_data'));
      expect(imageWithState.state, equals(ImageUploadState.local));
      expect(imageWithState.errorMessage, isNull);
      expect(imageWithState.capturedAt, isNotNull);
      expect(imageWithState.uploadedAt, isNull);
      expect(imageWithState.retryCount, equals(0));
    });

    test('should create with all optional fields', () {
      final capturedAt = DateTime(2024, 1, 1, 12, 0, 0);
      final uploadedAt = DateTime(2024, 1, 1, 12, 1, 0);

      final imageWithState = ImageWithUploadState(
        imageData: 'test_image_data',
        state: ImageUploadState.uploaded,
        errorMessage: 'Test error',
        capturedAt: capturedAt,
        uploadedAt: uploadedAt,
        retryCount: 2,
      );

      expect(imageWithState.imageData, equals('test_image_data'));
      expect(imageWithState.state, equals(ImageUploadState.uploaded));
      expect(imageWithState.errorMessage, equals('Test error'));
      expect(imageWithState.capturedAt, equals(capturedAt));
      expect(imageWithState.uploadedAt, equals(uploadedAt));
      expect(imageWithState.retryCount, equals(2));
    });

    group('copyWith', () {
      test('should copy with new state', () {
        final original = ImageWithUploadState(
          imageData: 'test_data',
          state: ImageUploadState.local,
        );

        final copied = original.copyWith(state: ImageUploadState.uploading);

        expect(copied.state, equals(ImageUploadState.uploading));
        expect(copied.imageData, equals(original.imageData));
        expect(copied.capturedAt, equals(original.capturedAt));
      });

      test('should copy with new error message', () {
        final original = ImageWithUploadState(
          imageData: 'test_data',
          state: ImageUploadState.local,
        );

        final copied = original.copyWith(
          state: ImageUploadState.failed,
          errorMessage: 'Upload failed',
        );

        expect(copied.state, equals(ImageUploadState.failed));
        expect(copied.errorMessage, equals('Upload failed'));
      });

      test('should copy with new retry count', () {
        final original = ImageWithUploadState(
          imageData: 'test_data',
          state: ImageUploadState.uploading,
          retryCount: 0,
        );

        final copied = original.copyWith(retryCount: 1);

        expect(copied.retryCount, equals(1));
      });

      test('should preserve unchanged fields', () {
        final capturedAt = DateTime(2024, 1, 1);
        final original = ImageWithUploadState(
          imageData: 'test_data',
          state: ImageUploadState.local,
          capturedAt: capturedAt,
          retryCount: 5,
        );

        final copied = original.copyWith(state: ImageUploadState.uploading);

        expect(copied.imageData, equals('test_data'));
        expect(copied.capturedAt, equals(capturedAt));
        expect(copied.retryCount, equals(5));
      });
    });

    group('state predicates', () {
      test('isUploaded should return true only for uploaded state', () {
        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.uploaded,
          ).isUploaded,
          isTrue,
        );

        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.local,
          ).isUploaded,
          isFalse,
        );

        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.uploading,
          ).isUploaded,
          isFalse,
        );

        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.failed,
          ).isUploaded,
          isFalse,
        );
      });

      test('isFailed should return true only for failed state', () {
        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.failed,
          ).isFailed,
          isTrue,
        );

        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.local,
          ).isFailed,
          isFalse,
        );
      });

      test('isUploading should return true only for uploading state', () {
        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.uploading,
          ).isUploading,
          isTrue,
        );

        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.local,
          ).isUploading,
          isFalse,
        );
      });

      test('isLocal should return true only for local state', () {
        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.local,
          ).isLocal,
          isTrue,
        );

        expect(
          ImageWithUploadState(
            imageData: 'test',
            state: ImageUploadState.uploaded,
          ).isLocal,
          isFalse,
        );
      });
    });

    test('toString should return readable representation', () {
      final imageWithState = ImageWithUploadState(
        imageData: 'test',
        state: ImageUploadState.uploading,
        retryCount: 2,
      );

      final str = imageWithState.toString();
      expect(str, contains('ImageWithUploadState'));
      expect(str, contains('uploading'));
      expect(str, contains('2'));
    });
  });
}
