import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/devices/domain/config/image_upload_config.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_processor.dart';

void main() {
  group('ImageProcessor', () {
    group('createBase64DataUrl', () {
      test('should create valid base64 data URL for JPEG', () {
        final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]); // JPEG header
        final dataUrl = ImageProcessor.createBase64DataUrl(
          bytes,
          'test_image.jpg',
        );

        expect(dataUrl, startsWith('data:image/jpeg;base64,'));
        expect(dataUrl, contains(base64Encode(bytes)));
      });

      test('should create valid base64 data URL for PNG', () {
        final bytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]); // PNG header
        final dataUrl = ImageProcessor.createBase64DataUrl(
          bytes,
          'test_image.png',
        );

        expect(dataUrl, startsWith('data:image/png;base64,'));
        expect(dataUrl, contains(base64Encode(bytes)));
      });

      test('should detect JPEG from path extension', () {
        final bytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);
        final dataUrl = ImageProcessor.createBase64DataUrl(
          bytes,
          '/path/to/IMAGE.JPEG',
        );

        expect(dataUrl, startsWith('data:image/jpeg;base64,'));
      });

      test('should detect PNG from path extension', () {
        final bytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);
        final dataUrl = ImageProcessor.createBase64DataUrl(
          bytes,
          '/path/to/IMAGE.PNG',
        );

        expect(dataUrl, startsWith('data:image/png;base64,'));
      });

      test('should default to JPEG for unknown extension', () {
        final bytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x00]);
        final dataUrl = ImageProcessor.createBase64DataUrl(
          bytes,
          '/path/to/image.webp',
        );

        expect(dataUrl, startsWith('data:image/jpeg;base64,'));
      });
    });

    group('validateFileSize', () {
      test('should return true for file within size limit', () {
        final bytes = Uint8List(1000); // 1KB
        expect(ImageProcessor.validateFileSize(bytes), isTrue);
      });

      test('should return false for file exceeding size limit', () {
        final bytes = Uint8List(ImageUploadConfig.maxFileSizeBytes + 1);
        expect(ImageProcessor.validateFileSize(bytes), isFalse);
      });

      test('should return true for file at exactly size limit', () {
        final bytes = Uint8List(ImageUploadConfig.maxFileSizeBytes);
        expect(ImageProcessor.validateFileSize(bytes), isTrue);
      });
    });

    group('getFileSizeWarning', () {
      test('should return null for small files', () {
        final bytes = Uint8List(1000); // 1KB
        expect(ImageProcessor.getFileSizeWarning(bytes), isNull);
      });

      test('should return warning for large files', () {
        final largeSize = ImageUploadConfig.warningSizeKB * 1024 + 1;
        final bytes = Uint8List(largeSize);
        final warning = ImageProcessor.getFileSizeWarning(bytes);

        expect(warning, isNotNull);
        expect(warning, contains('MB'));
      });
    });

    group('getMimeType', () {
      test('should return jpeg for .jpg extension', () {
        expect(ImageProcessor.getMimeType('image.jpg'), equals('image/jpeg'));
      });

      test('should return jpeg for .jpeg extension', () {
        expect(ImageProcessor.getMimeType('image.jpeg'), equals('image/jpeg'));
      });

      test('should return png for .png extension', () {
        expect(ImageProcessor.getMimeType('image.png'), equals('image/png'));
      });

      test('should be case insensitive', () {
        expect(ImageProcessor.getMimeType('image.JPG'), equals('image/jpeg'));
        expect(ImageProcessor.getMimeType('image.PNG'), equals('image/png'));
      });

      test('should default to jpeg for unknown extension', () {
        expect(ImageProcessor.getMimeType('image.gif'), equals('image/jpeg'));
        expect(ImageProcessor.getMimeType('image.bmp'), equals('image/jpeg'));
        expect(ImageProcessor.getMimeType('image'), equals('image/jpeg'));
      });
    });

    group('formatFileSize', () {
      test('should format bytes correctly', () {
        expect(ImageProcessor.formatFileSize(500), equals('500 B'));
      });

      test('should format kilobytes correctly', () {
        expect(ImageProcessor.formatFileSize(1024), equals('1.0 KB'));
        expect(ImageProcessor.formatFileSize(2048), equals('2.0 KB'));
      });

      test('should format megabytes correctly', () {
        expect(ImageProcessor.formatFileSize(1048576), equals('1.0 MB'));
        expect(ImageProcessor.formatFileSize(5242880), equals('5.0 MB'));
      });

      test('should format with decimal precision', () {
        expect(ImageProcessor.formatFileSize(1536), equals('1.5 KB'));
        expect(ImageProcessor.formatFileSize(1572864), equals('1.5 MB'));
      });
    });
  });

  group('ProcessedImage', () {
    test('should create with required fields', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final image = ProcessedImage(
        bytes: bytes,
        base64Data: 'data:image/jpeg;base64,AQIDBA==',
        fileName: 'test.jpg',
        sizeBytes: 4,
      );

      expect(image.bytes, equals(bytes));
      expect(image.base64Data, equals('data:image/jpeg;base64,AQIDBA=='));
      expect(image.fileName, equals('test.jpg'));
      expect(image.sizeBytes, equals(4));
    });

    test('isLargeFile should return true for files over warning threshold', () {
      final largeSize = ImageUploadConfig.warningSizeKB * 1024 + 1;
      final image = ProcessedImage(
        bytes: Uint8List(largeSize),
        base64Data: 'data:image/jpeg;base64,test',
        fileName: 'test.jpg',
        sizeBytes: largeSize,
      );

      expect(image.isLargeFile, isTrue);
    });

    test('isLargeFile should return false for small files', () {
      final image = ProcessedImage(
        bytes: Uint8List(1000),
        base64Data: 'data:image/jpeg;base64,test',
        fileName: 'test.jpg',
        sizeBytes: 1000,
      );

      expect(image.isLargeFile, isFalse);
    });

    test('formattedSize should return human readable size', () {
      final image = ProcessedImage(
        bytes: Uint8List(1048576), // 1MB
        base64Data: 'data:image/jpeg;base64,test',
        fileName: 'test.jpg',
        sizeBytes: 1048576,
      );

      expect(image.formattedSize, equals('1.0 MB'));
    });
  });

  group('ImageProcessingException', () {
    test('should create with message', () {
      const exception = ImageProcessingException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.toString(), contains('Test error'));
    });
  });

  group('ImageTooLargeException', () {
    test('should create with file size', () {
      final exception = ImageTooLargeException(3000000);
      expect(exception.fileSizeBytes, equals(3000000));
      expect(exception.message, contains('2.9 MB'));
      expect(exception.message, contains('2.0 MB')); // New max file size
    });
  });
}
