/// Configuration constants for image upload processing.
///
/// Centralizes all configuration values for image compression,
/// verification, and upload settings.
library;

/// Configuration constants for image uploads
class ImageUploadConfig {
  ImageUploadConfig._();

  // ============================================
  // Compression Settings
  // ============================================

  /// Feature flag for easy rollback of downsampling
  static const bool enableDownsampling = true;

  /// Maximum image dimension (width or height) in pixels
  /// Images larger than this will be downscaled maintaining aspect ratio
  /// 1280px is sufficient for viewing on mobile devices and web
  static const double maxDimension = 1280;

  /// Minimum image dimension (width or height) in pixels
  /// Images smaller than this may be rejected
  static const int minDimension = 400;

  /// JPEG quality setting (0-100)
  /// 70% provides good balance between quality and file size for WebSocket uploads
  static const int imageQuality = 70;

  /// Maximum file size in bytes (2MB)
  /// Images larger than this after processing will be rejected
  /// Keeping this small helps with WebSocket transmission reliability
  static const int maxFileSizeBytes = 2 * 1024 * 1024;

  /// Warning threshold for file size in KB (1MB)
  /// Large files will trigger a warning but still upload
  static const int warningSizeKB = 1024;

  // ============================================
  // Verification Settings
  // ============================================

  /// Maximum number of verification attempts
  static const int maxVerificationAttempts = 3;

  /// Initial delay before first verification check
  /// Allows server time to process the upload
  static const Duration initialVerificationDelay = Duration(seconds: 2);

  /// Delay between verification attempts
  static const Duration betweenAttemptsDelay = Duration(seconds: 1);

  /// Maximum total time to wait for verification
  static const Duration maxTotalWaitTime = Duration(seconds: 10);

  // ============================================
  // Upload Settings
  // ============================================

  /// Maximum number of upload retry attempts
  static const int maxRetries = 3;

  /// Timeout for individual upload requests
  /// Increased to accommodate connection warmup + actual upload
  static const Duration uploadTimeout = Duration(seconds: 90);

  /// Retry delay multiplier for exponential backoff
  static const Duration retryDelay = Duration(seconds: 2);
}
