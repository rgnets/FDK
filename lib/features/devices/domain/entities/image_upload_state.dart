/// Image upload state management.
///
/// Tracks the state of image uploads to prevent premature issue removal.
/// This model ensures that "No Images" issues only disappear after
/// successful server confirmation, not immediately upon image capture.
library;

/// State of an individual image in the upload process
enum ImageUploadState {
  /// Just captured, not yet uploaded
  local,

  /// Currently uploading to server
  uploading,

  /// Successfully uploaded and verified on server
  uploaded,

  /// Upload failed after all retries
  failed,
}

/// Result of image upload verification
enum VerificationResult {
  /// All images uploaded and verified
  success,

  /// Some images uploaded but not all verified
  partialSuccess,

  /// Verification timed out (upload may still be in progress)
  timeout,

  /// Upload actually failed
  failed,
}

/// Wrapper for device images with upload state tracking
class ImageWithUploadState {
  /// The image data (can be DeviceImage, XFile, or local image data)
  final dynamic imageData;

  /// Current state of this image
  final ImageUploadState state;

  /// Error message if upload failed
  final String? errorMessage;

  /// When the image was captured
  final DateTime capturedAt;

  /// When the image was successfully uploaded (null if not uploaded)
  final DateTime? uploadedAt;

  /// Number of upload retry attempts
  final int retryCount;

  ImageWithUploadState({
    required this.imageData,
    required this.state,
    this.errorMessage,
    DateTime? capturedAt,
    this.uploadedAt,
    this.retryCount = 0,
  }) : capturedAt = capturedAt ?? DateTime.now();

  /// Create a copy with updated fields
  ImageWithUploadState copyWith({
    dynamic imageData,
    ImageUploadState? state,
    String? errorMessage,
    DateTime? uploadedAt,
    int? retryCount,
  }) {
    return ImageWithUploadState(
      imageData: imageData ?? this.imageData,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      capturedAt: capturedAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// Check if image is successfully uploaded
  bool get isUploaded => state == ImageUploadState.uploaded;

  /// Check if image upload failed
  bool get isFailed => state == ImageUploadState.failed;

  /// Check if image is currently uploading
  bool get isUploading => state == ImageUploadState.uploading;

  /// Check if image is only local (not uploaded)
  bool get isLocal => state == ImageUploadState.local;

  @override
  String toString() {
    return 'ImageWithUploadState(state: $state, retries: $retryCount)';
  }
}
