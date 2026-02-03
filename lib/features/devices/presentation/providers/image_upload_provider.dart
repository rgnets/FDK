/// Riverpod providers for image upload functionality.
///
/// Provides state management for image upload operations
/// including picking, processing, uploading, and verification.
///
/// Image uploads use REST API (HTTP PUT) for reliability with large payloads.
/// The REST service uses [SecureHttpClient] to handle self-signed certificates.
/// Verification and metadata fetching still use WebSocket via the repository.
library;

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/core/services/image_upload_event_bus.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/devices/data/services/rest_image_upload_service.dart';
import 'package:rgnets_fdk/features/devices/domain/config/image_upload_config.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_processor.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_upload_service.dart';
import 'package:rgnets_fdk/features/devices/domain/services/image_upload_verifier.dart';

part 'image_upload_provider.g.dart';

/// Provider for the ImageUploadEventBus singleton
@Riverpod(keepAlive: true)
ImageUploadEventBus imageUploadEventBus(ImageUploadEventBusRef ref) {
  return ImageUploadEventBus();
}

/// Provider for ImageUploadVerifier
@riverpod
ImageUploadVerifier imageUploadVerifier(ImageUploadVerifierRef ref) {
  final repository = ref.watch(deviceRepositoryProvider);

  return ImageUploadVerifier(
    fetchImagesCallback: (deviceType, deviceId) async {
      // Use forceRefresh: true to bypass cache and make a fresh WebSocket request
      // This ensures we get the actual current images from the server after upload
      final result = await repository.getDevice(deviceId, forceRefresh: true);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (device) => device.images ?? [],
      );
    },
  );
}

/// Provider for RestImageUploadService
///
/// Uses Dio internally with certificate validation for handling
/// self-signed certificates. No external client needed.
@riverpod
Future<RestImageUploadService> restImageUploadService(RestImageUploadServiceRef ref) async {
  final storage = ref.watch(storageServiceProvider);

  final siteUrl = storage.siteUrl ?? '';
  final apiKey = await storage.getToken() ?? '';

  if (siteUrl.isEmpty || apiKey.isEmpty) {
    throw StateError('Not authenticated: missing siteUrl or apiKey');
  }

  return RestImageUploadService(
    siteUrl: siteUrl,
    apiKey: apiKey,
  );
}

/// Provider for ImageUploadService
///
/// Uses REST API (HTTP PUT) for uploading images instead of WebSocket.
/// This provides better reliability for large base64 payloads.
/// After upload, fetches fresh device data via REST and updates the
/// WebSocket cache to ensure the UI immediately reflects the new images.
@riverpod
Future<ImageUploadService> imageUploadService(ImageUploadServiceRef ref) async {
  final restService = await ref.watch(restImageUploadServiceProvider.future);
  final verifier = ref.watch(imageUploadVerifierProvider);
  final eventBus = ref.watch(imageUploadEventBusProvider);
  final webSocketCacheIntegration = ref.watch(webSocketCacheIntegrationProvider);

  return ImageUploadService(
    uploadCallback: (resourceType, deviceId, params) async {
      final images = params['images'] as List<String>;

      LoggerService.info(
        'Uploading ${images.length} images via REST API to $resourceType/$deviceId',
        tag: 'ImageUploadProvider',
      );

      final result = await restService.uploadImages(
        deviceId: deviceId,
        resourceType: resourceType,
        images: images,
      );

      if (result.success) {
        return {'success': true, 'device_id': deviceId};
      } else {
        throw Exception(result.errorMessage ?? 'Upload failed');
      }
    },
    verifier: verifier,
    eventBus: eventBus,
    restUploadService: restService,
    refreshCallback: (deviceType, deviceId) async {
      // After successful upload, fetch fresh device data via REST
      // and update the WebSocket cache directly. This ensures the
      // device list UI (which watches WebSocket cache) shows new images.
      LoggerService.info(
        'Fetching fresh device data via REST for $deviceType-$deviceId',
        tag: 'ImageUploadProvider',
      );

      // Get the resource type from device type
      final resourceType = ImageUploadService.getResourceType(deviceType);
      // Extract raw ID from prefixed device ID (e.g., ap_123 -> 123)
      final rawId = ImageUploadService.extractRawId(deviceId);

      // Fetch fresh device data from REST API
      final freshDeviceData = await restService.fetchDeviceData(
        resourceType: resourceType,
        deviceId: rawId,
      );

      if (freshDeviceData != null) {
        // Update the WebSocket cache with fresh data
        // This triggers UI updates for the device list view
        LoggerService.info(
          'Updating WebSocket cache with fresh device data for $resourceType/$rawId',
          tag: 'ImageUploadProvider',
        );
        webSocketCacheIntegration.updateDeviceFromRest(resourceType, freshDeviceData);
      } else {
        // Fallback: Request a snapshot for the resource type to get fresh data
        // This ensures the device list eventually gets updated even if REST fetch fails
        LoggerService.warning(
          'REST fetch failed, requesting WebSocket snapshot for $resourceType',
          tag: 'ImageUploadProvider',
        );
        webSocketCacheIntegration.requestResourceSnapshot(resourceType);
      }
    },
  );
}

/// State for image upload operations
class ImageUploadViewState {
  final bool isUploading;
  final bool isPickingImage;
  final String? errorMessage;
  final String? successMessage;
  final int uploadProgress;
  final int totalImages;

  const ImageUploadViewState({
    this.isUploading = false,
    this.isPickingImage = false,
    this.errorMessage,
    this.successMessage,
    this.uploadProgress = 0,
    this.totalImages = 0,
  });

  factory ImageUploadViewState.initial() => const ImageUploadViewState();

  ImageUploadViewState copyWith({
    bool? isUploading,
    bool? isPickingImage,
    String? errorMessage,
    String? successMessage,
    int? uploadProgress,
    int? totalImages,
  }) {
    return ImageUploadViewState(
      isUploading: isUploading ?? this.isUploading,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      totalImages: totalImages ?? this.totalImages,
    );
  }

  bool get isLoading => isUploading || isPickingImage;
}

/// Notifier for image upload state per device
@riverpod
class ImageUploadNotifier extends _$ImageUploadNotifier {
  @override
  ImageUploadViewState build(String deviceId) {
    return ImageUploadViewState.initial();
  }

  /// Pick and upload images
  Future<bool> pickAndUploadImages({
    required ImageSource source,
    required String deviceType,
    String? roomId,
    required List<String> existingImages,
  }) async {
    if (state.isLoading) {
      return false;
    }

    state = state.copyWith(
      isPickingImage: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      // Pick image(s)
      final picker = ImagePicker();
      List<XFile> pickedFiles = [];

      if (source == ImageSource.camera) {
        final file = await picker.pickImage(
          source: source,
          maxWidth: ImageUploadConfig.enableDownsampling
              ? ImageUploadConfig.maxDimension
              : null,
          maxHeight: ImageUploadConfig.enableDownsampling
              ? ImageUploadConfig.maxDimension
              : null,
          imageQuality: ImageUploadConfig.imageQuality,
        );
        if (file != null) {
          pickedFiles = [file];
        }
      } else {
        pickedFiles = await picker.pickMultiImage(
          maxWidth: ImageUploadConfig.enableDownsampling
              ? ImageUploadConfig.maxDimension
              : null,
          maxHeight: ImageUploadConfig.enableDownsampling
              ? ImageUploadConfig.maxDimension
              : null,
          imageQuality: ImageUploadConfig.imageQuality,
        );
      }

      if (pickedFiles.isEmpty) {
        state = state.copyWith(isPickingImage: false);
        return false;
      }

      // Process images
      state = state.copyWith(
        isPickingImage: false,
        isUploading: true,
        totalImages: pickedFiles.length,
        uploadProgress: 0,
      );

      final processedImages = <ProcessedImage>[];
      for (final file in pickedFiles) {
        final bytes = await file.readAsBytes();

        // Validate file size
        if (!ImageProcessor.validateFileSize(bytes)) {
          throw ImageTooLargeException(bytes.length);
        }

        processedImages.add(ProcessedImage(
          bytes: bytes,
          base64Data: ImageProcessor.createBase64DataUrl(bytes, file.path),
          fileName: file.name,
          sizeBytes: bytes.length,
        ));
      }

      // Upload images
      final uploadService = await ref.read(imageUploadServiceProvider.future);
      final result = await uploadService.uploadImages(
        deviceType: deviceType,
        deviceId: deviceId,
        roomId: roomId,
        images: processedImages,
        existingImages: existingImages,
      );

      if (result.success) {
        state = state.copyWith(
          isUploading: false,
          successMessage: result.message,
          uploadProgress: processedImages.length,
        );
      } else {
        state = state.copyWith(
          isUploading: false,
          errorMessage: result.message,
          uploadProgress: processedImages.length,
        );
      }

      return result.success;
    } catch (e) {
      LoggerService.error(
        'Image upload failed',
        tag: 'ImageUploadNotifier',
        error: e,
      );

      state = state.copyWith(
        isPickingImage: false,
        isUploading: false,
        errorMessage: _getErrorMessage(e),
      );

      return false;
    }
  }

  /// Clear any messages
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  String _getErrorMessage(Object error) {
    if (error is ImageTooLargeException) {
      return error.message;
    }
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}

/// Stream provider for image upload events
@Riverpod(keepAlive: true)
Stream<ImageUploadEvent> imageUploadEvents(ImageUploadEventsRef ref) {
  return ref.watch(imageUploadEventBusProvider).imageUploaded;
}

/// Stream provider for cache invalidation events
@Riverpod(keepAlive: true)
Stream<CacheInvalidationEvent> cacheInvalidationEvents(
  CacheInvalidationEventsRef ref,
) {
  return ref.watch(imageUploadEventBusProvider).cacheInvalidated;
}
