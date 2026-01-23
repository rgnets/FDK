/// Image upload service for WebSocket-based uploads.
///
/// Handles the complete upload flow including:
/// - Sending images via WebSocket
/// - Verification of upload success
/// - Event bus notifications
library;

import 'package:rgnets_fdk/core/services/image_upload_event_bus.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/devices/data/services/rest_image_upload_service.dart';
import 'package:rgnets_fdk/features/devices/domain/config/image_upload_config.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/image_upload_state.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_processor.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_upload_verifier.dart';

/// Callback type for WebSocket upload
typedef UploadCallback = Future<Map<String, dynamic>> Function(
  String resourceType,
  String deviceId,
  Map<String, dynamic> params,
);

/// Callback type for requesting device refresh after upload
/// This triggers a WebSocket request to fetch updated device data
typedef DeviceRefreshCallback = Future<void> Function(
  String deviceType,
  String deviceId,
);

/// Service for uploading images via WebSocket
class ImageUploadService {
  final UploadCallback _uploadCallback;
  final ImageUploadVerifier _verifier;
  final ImageUploadEventBus _eventBus;
  final DeviceRefreshCallback? _refreshCallback;
  final RestImageUploadService? _restUploadService;

  ImageUploadService({
    required UploadCallback uploadCallback,
    required ImageUploadVerifier verifier,
    required ImageUploadEventBus eventBus,
    DeviceRefreshCallback? refreshCallback,
    RestImageUploadService? restUploadService,
  })  : _uploadCallback = uploadCallback,
        _verifier = verifier,
        _eventBus = eventBus,
        _refreshCallback = refreshCallback,
        _restUploadService = restUploadService;

  /// Device type prefix to resource type mapping
  static const Map<String, String> _devicePrefixes = {
    'ap_': 'access_points',
    'ont_': 'media_converters',
    'sw_': 'switch_devices',
    'wlan_': 'wlan_devices',
  };

  /// Device type to resource type mapping
  static const Map<String, String> _deviceTypeToResource = {
    'access_point': 'access_points',
    'ap': 'access_points',
    'ont': 'media_converters',
    'media_converter': 'media_converters',
    'switch': 'switch_devices',
    'wlan_controller': 'wlan_devices',
  };

  /// Upload images to a device via WebSocket
  ///
  /// [deviceType] - Type of device (access_point, ont, switch)
  /// [deviceId] - Device ID (may include prefix like ap_123)
  /// [roomId] - Optional room ID for event notification
  /// [images] - List of processed images to upload
  /// [existingImages] - List of existing image URLs
  ///
  /// Returns [ImageUploadResult] with success status and verification result
  Future<ImageUploadResult> uploadImages({
    required String deviceType,
    required String deviceId,
    required String? roomId,
    required List<ProcessedImage> images,
    required List<String> existingImages,
  }) async {
    LoggerService.info(
      'Starting image upload: $deviceType-$deviceId, ${images.length} new images',
      tag: 'ImageUploadService',
    );

    final resourceType = getResourceType(deviceType);
    final rawId = extractRawId(deviceId);
    final previousCount = existingImages.length;

    // Fetch current signed IDs via HTTP (WebSocket data only has URLs, not signed IDs)
    // This matches how ATT-FE-Tool preserves existing images when uploading new ones
    List<String> currentSignedIds = [];
    if (previousCount > 0 && _restUploadService != null) {
      LoggerService.debug(
        'Fetching current signed IDs via HTTP (WebSocket only has URLs)',
        tag: 'ImageUploadService',
      );
      currentSignedIds = await _restUploadService.fetchCurrentSignedIds(
        resourceType: resourceType,
        deviceId: rawId,
      );
      LoggerService.debug(
        'Fetched ${currentSignedIds.length} signed IDs from server',
        tag: 'ImageUploadService',
      );
    }

    // Combine existing signed IDs with new base64 images
    final allImages = [
      ...currentSignedIds,
      ...images.map((img) => img.base64Data),
    ];

    LoggerService.info(
      'Sending ${allImages.length} total images (${currentSignedIds.length} existing + ${images.length} new)',
      tag: 'ImageUploadService',
    );

    // Notify upload starting
    _eventBus.notifyUploadProgress(
      deviceId: deviceId,
      current: 0,
      total: images.length,
      status: UploadStatus.uploading,
    );

    try {
      // Send upload request via WebSocket
      LoggerService.debug(
        'Sending upload request to $resourceType/$rawId',
        tag: 'ImageUploadService',
      );

      await _uploadCallback(
        resourceType,
        rawId,
        {'images': allImages},
      ).timeout(
        ImageUploadConfig.uploadTimeout,
        onTimeout: () => throw Exception('Upload timeout'),
      );

      // Verify upload success
      LoggerService.debug(
        'Upload request sent, starting verification',
        tag: 'ImageUploadService',
      );

      final verificationResult = await _verifier.verifyUpload(
        expectedCount: allImages.length,
        deviceType: deviceType,
        deviceId: deviceId,
        previousCount: previousCount,
      );

      // Notify upload complete
      _eventBus.notifyUploadProgress(
        deviceId: deviceId,
        current: images.length,
        total: images.length,
        status: verificationResult == VerificationResult.failed
            ? UploadStatus.failed
            : UploadStatus.completed,
      );

      // On success or partial success, request device refresh and emit events
      if (verificationResult != VerificationResult.failed) {
        // Request updated device data via WebSocket before emitting events
        // This ensures the cache is updated with latest image URLs
        if (_refreshCallback != null) {
          LoggerService.debug(
            'Requesting device refresh via WebSocket for $deviceType-$deviceId',
            tag: 'ImageUploadService',
          );
          try {
            await _refreshCallback(deviceType, deviceId);
            LoggerService.debug(
              'Device refresh completed for $deviceType-$deviceId',
              tag: 'ImageUploadService',
            );
          } catch (e) {
            LoggerService.warning(
              'Device refresh failed, will still emit events: $e',
              tag: 'ImageUploadService',
            );
          }
        }

        _eventBus.notifyImageUploaded(
          deviceType: deviceType,
          deviceId: deviceId,
          roomId: roomId,
          newImageCount: images.length,
        );

        _eventBus.notifyCacheInvalidated(
          deviceType: deviceType,
          deviceId: deviceId,
        );
      }

      final result = ImageUploadResult(
        success: verificationResult != VerificationResult.failed,
        verificationResult: verificationResult,
        uploadedCount: images.length,
        message: ImageUploadVerifier.getUserMessage(verificationResult),
      );

      LoggerService.info(
        'Upload complete: ${result.success ? 'SUCCESS' : 'FAILED'} - ${result.message}',
        tag: 'ImageUploadService',
      );

      return result;
    } catch (e) {
      LoggerService.error(
        'Upload failed for $deviceType-$deviceId',
        tag: 'ImageUploadService',
        error: e,
      );

      // Notify upload failed
      _eventBus.notifyUploadProgress(
        deviceId: deviceId,
        current: 0,
        total: images.length,
        status: UploadStatus.failed,
      );

      rethrow;
    }
  }

  /// Get the resource type for a device type
  ///
  /// Throws [ArgumentError] for unknown device types
  static String getResourceType(String deviceType) {
    final resourceType = _deviceTypeToResource[deviceType.toLowerCase()];
    if (resourceType == null) {
      throw ArgumentError('Unknown device type: $deviceType');
    }
    return resourceType;
  }

  /// Extract raw numeric ID from prefixed device ID
  ///
  /// Examples:
  /// - ap_123 -> 123
  /// - ont_456 -> 456
  /// - 789 -> 789 (no prefix)
  static String extractRawId(String deviceId) {
    for (final prefix in _devicePrefixes.keys) {
      if (deviceId.startsWith(prefix)) {
        return deviceId.substring(prefix.length);
      }
    }
    return deviceId;
  }
}

/// Result of an image upload operation
class ImageUploadResult {
  /// Whether the upload was successful
  final bool success;

  /// Detailed verification result
  final VerificationResult verificationResult;

  /// Number of images uploaded
  final int uploadedCount;

  /// User-friendly message describing the result
  final String message;

  ImageUploadResult({
    required this.success,
    required this.verificationResult,
    required this.uploadedCount,
    required this.message,
  });

  /// Check if this result indicates an error
  bool get isError => !success;

  @override
  String toString() {
    return 'ImageUploadResult(success: $success, result: $verificationResult, count: $uploadedCount)';
  }
}
