/// Image processing service for upload preparation.
///
/// Provides utilities for processing images before upload:
/// - Base64 encoding
/// - File size validation
/// - MIME type detection
/// - Size formatting
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:rgnets_fdk/features/devices/domain/config/image_upload_config.dart';

/// Service for processing images before upload
class ImageProcessor {
  ImageProcessor._();

  /// Create a base64 data URL from image bytes
  ///
  /// [bytes] - The raw image bytes
  /// [path] - The file path (used for MIME type detection)
  ///
  /// Returns a data URL in format: data:image/jpeg;base64,<encoded>
  static String createBase64DataUrl(Uint8List bytes, String path) {
    final mimeType = getMimeType(path);
    final base64String = base64Encode(bytes);
    return 'data:$mimeType;base64,$base64String';
  }

  /// Validate that file size is within allowed limits
  ///
  /// Returns true if file is within [ImageUploadConfig.maxFileSizeBytes]
  static bool validateFileSize(Uint8List bytes) {
    return bytes.length <= ImageUploadConfig.maxFileSizeBytes;
  }

  /// Get a warning message if file is large (but still within limits)
  ///
  /// Returns null if file is small, otherwise returns a warning message
  static String? getFileSizeWarning(Uint8List bytes) {
    final warningThreshold = ImageUploadConfig.warningSizeKB * 1024;
    if (bytes.length > warningThreshold) {
      return 'Large file (${formatFileSize(bytes.length)}). Upload may take longer.';
    }
    return null;
  }

  /// Detect MIME type from file path extension
  ///
  /// Supports JPEG and PNG, defaults to JPEG for unknown types
  static String getMimeType(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) {
      return 'image/png';
    }
    // Default to JPEG for .jpg, .jpeg, and all other formats
    return 'image/jpeg';
  }

  /// Format file size in human readable format
  ///
  /// Examples: 500 B, 1.5 KB, 2.0 MB
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Represents a processed image ready for upload
class ProcessedImage {
  /// The raw image bytes
  final Uint8List bytes;

  /// The base64-encoded data URL for upload
  final String base64Data;

  /// The original file name
  final String fileName;

  /// Size in bytes
  final int sizeBytes;

  ProcessedImage({
    required this.bytes,
    required this.base64Data,
    required this.fileName,
    required this.sizeBytes,
  });

  /// Check if this is considered a large file
  bool get isLargeFile {
    return sizeBytes > ImageUploadConfig.warningSizeKB * 1024;
  }

  /// Get human-readable file size
  String get formattedSize {
    return ImageProcessor.formatFileSize(sizeBytes);
  }
}

/// Base exception for image processing errors
class ImageProcessingException implements Exception {
  final String message;

  const ImageProcessingException(this.message);

  @override
  String toString() => 'ImageProcessingException: $message';
}

/// Exception thrown when image exceeds maximum file size
class ImageTooLargeException extends ImageProcessingException {
  final int fileSizeBytes;

  ImageTooLargeException(this.fileSizeBytes)
      : super(
          'Image file size (${ImageProcessor.formatFileSize(fileSizeBytes)}) '
          'exceeds maximum allowed (${ImageProcessor.formatFileSize(ImageUploadConfig.maxFileSizeBytes)})',
        );
}
