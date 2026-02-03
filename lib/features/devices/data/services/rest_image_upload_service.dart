import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:rgnets_fdk/core/security/certificate_validator.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// REST-based service for uploading device images.
///
/// Uses HTTP PUT requests via Dio to update device images on the server.
/// Dio handles large payloads better than the http package on Android.
///
/// This service configures Dio with certificate validation for handling
/// self-signed certificates in debug mode.
class RestImageUploadService {
  final String _siteUrl;
  final String _apiKey;
  final Dio? _injectedDio;
  static Dio? _sharedDio;
  static final CertificateValidator _certValidator = CertificateValidator();

  /// Gets or creates a Dio instance configured for secure connections.
  Dio get _dio {
    if (_injectedDio != null) return _injectedDio;

    if (_sharedDio == null) {
      LoggerService.debug(
        'Creating new Dio instance with certificate validation',
        tag: 'RestImageUploadService',
      );
      _sharedDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 120),
      ));

      // Configure for self-signed certificates
      (_sharedDio!.httpClientAdapter as IOHttpClientAdapter)
          .createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = _certValidator.validateCertificate;
        return client;
      };
    }
    return _sharedDio!;
  }

  /// Fetches current images for a device, returning their signed IDs.
  ///
  /// This is needed because WebSocket data only includes URLs, not signed IDs.
  /// When uploading new images, we need to include existing signed IDs to
  /// preserve them (otherwise they get replaced).
  Future<List<String>> fetchCurrentSignedIds({
    required String resourceType,
    required String deviceId,
  }) async {
    final url =
        'https://$_siteUrl/api/$resourceType/$deviceId.json?api_key=$_apiKey';

    LoggerService.debug(
      'Fetching current signed IDs for $resourceType/$deviceId',
      tag: 'RestImageUploadService',
    );

    try {
      final response = await _dio.get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        final images = response.data!['images'];
        if (images is List) {
          final signedIds = <String>[];
          for (final img in images) {
            if (img is Map) {
              final signedId = img['signed_id'];
              if (signedId is String && signedId.isNotEmpty) {
                signedIds.add(signedId);
              }
            }
          }
          LoggerService.debug(
            'Fetched ${signedIds.length} signed IDs',
            tag: 'RestImageUploadService',
          );
          return signedIds;
        }
      }
      return [];
    } catch (e) {
      LoggerService.warning(
        'Failed to fetch signed IDs: $e',
        tag: 'RestImageUploadService',
      );
      return [];
    }
  }

  /// Fetches the full device data from REST API.
  ///
  /// This is used after image upload to get the latest device state
  /// including new image URLs, which can then be used to update
  /// the WebSocket cache for immediate UI refresh.
  ///
  /// Returns the raw device data map, or null if the fetch fails.
  Future<Map<String, dynamic>?> fetchDeviceData({
    required String resourceType,
    required String deviceId,
  }) async {
    final url =
        'https://$_siteUrl/api/$resourceType/$deviceId.json?api_key=$_apiKey';

    LoggerService.debug(
      'Fetching device data for $resourceType/$deviceId',
      tag: 'RestImageUploadService',
    );

    try {
      final response = await _dio.get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        LoggerService.debug(
          'Fetched device data successfully for $resourceType/$deviceId',
          tag: 'RestImageUploadService',
        );
        return response.data;
      }
      return null;
    } catch (e) {
      LoggerService.warning(
        'Failed to fetch device data: $e',
        tag: 'RestImageUploadService',
      );
      return null;
    }
  }

  /// Creates a REST image upload service.
  ///
  /// [siteUrl] - Base URL for the API (e.g., 'https://example.rgnetworks.com')
  /// [apiKey] - API key for authentication
  /// [dio] - Optional Dio instance for testing. If not provided,
  ///   uses a shared Dio instance with certificate validation.
  RestImageUploadService({
    required String siteUrl,
    required String apiKey,
    Dio? dio,
  })  : _siteUrl = _normalizeSiteUrl(siteUrl),
        _apiKey = apiKey,
        _injectedDio = dio {
    if (siteUrl.isEmpty) {
      throw ArgumentError('siteUrl cannot be empty');
    }
    if (apiKey.isEmpty) {
      throw ArgumentError('apiKey cannot be empty');
    }
  }

  /// Normalizes the site URL to ensure proper format.
  static String _normalizeSiteUrl(String url) {
    // Remove protocol prefix if present
    var normalized = url;
    if (normalized.startsWith('https://')) {
      normalized = normalized.substring(8);
    } else if (normalized.startsWith('http://')) {
      normalized = normalized.substring(7);
    }
    // Remove trailing slash if present
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  /// Uploads images to a device using REST API.
  ///
  /// [deviceId] - The raw device ID (numeric, without prefix)
  /// [resourceType] - The resource type ('access_points', 'media_converters', 'switch_devices')
  /// [images] - List of image identifiers (signed IDs for existing, data URLs for new)
  ///
  /// Returns [RestImageUploadResult] with the outcome of the upload.
  Future<RestImageUploadResult> uploadImages({
    required String deviceId,
    required String resourceType,
    required List<String> images,
  }) async {
    final url =
        'https://$_siteUrl/api/$resourceType/$deviceId.json?api_key=$_apiKey';

    LoggerService.debug(
      'REST Upload: PUT $resourceType/$deviceId with ${images.length} images',
      tag: 'RestImageUploadService',
    );
    // Note: Not logging URL as it contains api_key

    try {
      final dio = _dio;

      // Calculate and log payload size
      final bodyJson = jsonEncode({'images': images});
      final bodySizeKB = (bodyJson.length / 1024).toStringAsFixed(2);
      LoggerService.info(
        'REST Upload: Payload size = $bodySizeKB KB',
        tag: 'RestImageUploadService',
      );

      LoggerService.debug(
        'REST Upload: Starting PUT request with Dio...',
        tag: 'RestImageUploadService',
      );

      final response = await dio.put<Map<String, dynamic>>(
        url,
        data: {'images': images},
        options: Options(
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final percent = ((sent / total) * 100).toStringAsFixed(1);
            LoggerService.debug(
              'REST Upload: Send progress $percent% ($sent/$total bytes)',
              tag: 'RestImageUploadService',
            );
          }
        },
      );

      LoggerService.debug(
        'REST Upload: Response received with status ${response.statusCode}',
        tag: 'RestImageUploadService',
      );

      if (response.statusCode == 200) {
        List<dynamic>? serverImages;
        try {
          final body = response.data;
          serverImages = body?['images'] as List<dynamic>?;
        } catch (e) {
          // Response may not include images in body
          LoggerService.warning(
            'Could not parse response body: $e',
            tag: 'RestImageUploadService',
          );
        }

        LoggerService.info(
          'REST Upload successful: $resourceType/$deviceId',
          tag: 'RestImageUploadService',
        );

        return RestImageUploadResult.success(
          statusCode: response.statusCode ?? 200,
          serverImages: serverImages,
        );
      } else {
        LoggerService.error(
          'REST Upload failed: ${response.statusCode} - ${response.data}',
          tag: 'RestImageUploadService',
        );

        return RestImageUploadResult.failure(
          statusCode: response.statusCode ?? 0,
          errorMessage: 'Upload failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      LoggerService.error(
        'REST Upload Dio exception: ${e.type} - ${e.message}',
        tag: 'RestImageUploadService',
        error: e,
      );

      final statusCode = e.response?.statusCode ?? 0;
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout - upload took too long';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout - server took too long to respond';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error: ${e.message}';
          break;
        default:
          errorMessage = 'Network error: ${e.message}';
      }

      return RestImageUploadResult.failure(
        statusCode: statusCode,
        errorMessage: errorMessage,
      );
    } catch (e) {
      LoggerService.error(
        'REST Upload exception: $e',
        tag: 'RestImageUploadService',
        error: e,
      );

      return RestImageUploadResult.failure(
        statusCode: 0,
        errorMessage: 'Network error: $e',
      );
    }
  }
}

/// Result of a REST image upload operation.
class RestImageUploadResult {
  /// Whether the upload was successful.
  final bool success;

  /// HTTP status code of the response.
  final int statusCode;

  /// Images returned from the server (if available).
  final List<dynamic>? serverImages;

  /// Error message if the upload failed.
  final String? errorMessage;

  const RestImageUploadResult._({
    required this.success,
    required this.statusCode,
    this.serverImages,
    this.errorMessage,
  });

  /// Creates a successful upload result.
  factory RestImageUploadResult.success({
    required int statusCode,
    List<dynamic>? serverImages,
  }) {
    return RestImageUploadResult._(
      success: true,
      statusCode: statusCode,
      serverImages: serverImages,
    );
  }

  /// Creates a failed upload result.
  const factory RestImageUploadResult.failure({
    required int statusCode,
    required String errorMessage,
  }) = _FailedRestImageUploadResult;

  @override
  String toString() {
    if (success) {
      return 'RestImageUploadResult.success(statusCode: $statusCode)';
    }
    return 'RestImageUploadResult.failure(statusCode: $statusCode, error: $errorMessage)';
  }
}

class _FailedRestImageUploadResult extends RestImageUploadResult {
  const _FailedRestImageUploadResult({
    required super.statusCode,
    required String errorMessage,
  }) : super._(
          success: false,
          errorMessage: errorMessage,
        );
}
