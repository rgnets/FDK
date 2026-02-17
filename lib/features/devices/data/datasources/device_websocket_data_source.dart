import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/devices/data/services/rest_image_upload_service.dart';

/// WebSocket-based data source for fetching devices.
/// Replaces DeviceRemoteDataSource with a WebSocket-backed implementation.
class DeviceWebSocketDataSource implements DeviceDataSource {
  DeviceWebSocketDataSource({
    required WebSocketCacheIntegration webSocketCacheIntegration,
    String? imageBaseUrl,
    Logger? logger,
    StorageService? storageService,
  })  : _cacheIntegration = webSocketCacheIntegration,
        _storageService = storageService,
        _logger = logger ?? Logger();

  final WebSocketCacheIntegration _cacheIntegration;
  final StorageService? _storageService;
  final Logger _logger;

  static const Map<String, String> _deviceEndpointByPrefix = {
    'ap_': 'access_points',
    'ont_': 'media_converters',
    'sw_': 'switch_devices',
    'wlan_': 'wlan_devices',
  };

  WebSocketService get _webSocketService => _cacheIntegration.webSocketService;

  @override
  Future<List<DeviceModelSealed>> getDevices({List<String>? fields}) async {
    _logger
      ..i('DeviceWebSocketDataSource: getDevices() called')
      ..i('DeviceWebSocketDataSource: WebSocket service hashCode: ${_webSocketService.hashCode}')
      ..i('DeviceWebSocketDataSource: WebSocket connected: ${_webSocketService.isConnected}')
      ..i('DeviceWebSocketDataSource: WebSocket state: ${_webSocketService.currentState}')
      ..i('DeviceWebSocketDataSource: Cache integration hashCode: ${_cacheIntegration.hashCode}')
      ..i('DeviceWebSocketDataSource: Cache has device data: ${_cacheIntegration.hasDeviceCache}');

    // First try to get from cache
    final cachedModels = _cacheIntegration.getAllCachedDeviceModels();
    if (cachedModels.isNotEmpty) {
      _logger.i(
        'DeviceWebSocketDataSource: Returning ${cachedModels.length} devices from cache',
      );
      return cachedModels;
    }

    // If cache is empty, request snapshots and wait for data
    _logger.i('DeviceWebSocketDataSource: Cache empty, requesting snapshots');

    if (!_webSocketService.isConnected) {
      _logger.w('DeviceWebSocketDataSource: WebSocket not connected, cannot request data');
      return [];
    }

    // Request snapshots for all device types
    _logger.i('DeviceWebSocketDataSource: Calling requestFullSnapshots()');
    _cacheIntegration.requestFullSnapshots();

    // Wait a bit for data to arrive (with timeout)
    const maxWaitTime = Duration(seconds: 10);
    const pollInterval = Duration(milliseconds: 500);
    var elapsed = Duration.zero;

    while (elapsed < maxWaitTime) {
      await Future<void>.delayed(pollInterval);
      elapsed += pollInterval;

      final models = _cacheIntegration.getAllCachedDeviceModels();
      if (models.isNotEmpty) {
        _logger.i(
          'DeviceWebSocketDataSource: Got ${models.length} devices after ${elapsed.inMilliseconds}ms',
        );
        return models;
      }
    }

    _logger.w('DeviceWebSocketDataSource: Timeout waiting for device data');
    return [];
  }

  @override
  Future<DeviceModelSealed> getDevice(
    String id, {
    List<String>? fields,
    bool forceRefresh = false,
  }) async {
    _logger.i('DeviceWebSocketDataSource: getDevice($id, forceRefresh: $forceRefresh) called');

    // Skip cache if force refresh requested
    if (!forceRefresh) {
      // First try to find in cache
      final cachedModels = _cacheIntegration.getAllCachedDeviceModels();
      final cached = cachedModels.where((d) => d.deviceId == id).firstOrNull;
      if (cached != null) {
        _logger.i('DeviceWebSocketDataSource: Found device $id in cache');
        return cached;
      }
    } else {
      _logger.i('DeviceWebSocketDataSource: Bypassing cache due to forceRefresh');
    }

    // If WebSocket not connected, we can't fetch - throw so repository can use cache fallback
    if (!_webSocketService.isConnected) {
      _logger.w('DeviceWebSocketDataSource: WebSocket not connected, device $id not in cache');
      throw Exception('Device not in cache and WebSocket not connected');
    }

    // Request specific device via WebSocket
    final resourceType = _getResourceTypeFromId(id);
    final rawId = _extractRawId(id);

    if (resourceType == null) {
      throw Exception('Unknown device type for ID: $id');
    }

    try {
      final response = await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: resourceType,
        additionalData: {
          'crud_action': 'show',
          'id': rawId,
        },
        timeout: const Duration(seconds: 15),
      );

      final deviceData = _extractDeviceData(response.payload, response.raw);
      if (deviceData != null) {
        return _mapToDeviceModel(resourceType, deviceData);
      }

      throw Exception('Device not found: $id');
    } on Exception catch (e) {
      _logger.e('DeviceWebSocketDataSource: Failed to get device $id: $e');
      throw Exception('Failed to get device: $e');
    }
  }

  @override
  Future<List<DeviceModelSealed>> getDevicesByRoom(String roomId) async {
    _logger.i('DeviceWebSocketDataSource: getDevicesByRoom($roomId) called');

    // Get all devices and filter by room
    final allDevices = await getDevices();
    return allDevices.where((device) {
      final pmsRoomId = device.map(
        ap: (d) => d.pmsRoomId?.toString(),
        ont: (d) => d.pmsRoomId?.toString(),
        switchDevice: (d) => d.pmsRoomId?.toString(),
        wlan: (d) => d.pmsRoomId?.toString(),
      );
      return pmsRoomId == roomId;
    }).toList();
  }

  @override
  Future<List<DeviceModelSealed>> searchDevices(String query) async {
    _logger.i('DeviceWebSocketDataSource: searchDevices($query) called');

    // Get all devices and filter locally
    final allDevices = await getDevices();
    final lowerQuery = query.toLowerCase();

    return allDevices.where((device) {
      final name = device.deviceName.toLowerCase();
      final id = device.deviceId.toLowerCase();
      final serialNumber = device.map(
        ap: (d) => d.serialNumber?.toLowerCase(),
        ont: (d) => d.serialNumber?.toLowerCase(),
        switchDevice: (d) => d.serialNumber?.toLowerCase(),
        wlan: (d) => d.serialNumber?.toLowerCase(),
      );
      final macAddress = device.map(
        ap: (d) => d.macAddress?.toLowerCase(),
        ont: (d) => d.macAddress?.toLowerCase(),
        switchDevice: (d) => d.macAddress?.toLowerCase(),
        wlan: (d) => d.macAddress?.toLowerCase(),
      );

      return name.contains(lowerQuery) ||
          id.contains(lowerQuery) ||
          (serialNumber?.contains(lowerQuery) ?? false) ||
          (macAddress?.contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<DeviceModelSealed> updateDevice(DeviceModelSealed device) async {
    final deviceId = device.deviceId;
    _logger.i('DeviceWebSocketDataSource: updateDevice($deviceId) called');

    final resourceType = _getResourceTypeFromId(deviceId);
    final rawId = _extractRawId(deviceId);

    if (resourceType == null) {
      throw Exception('Unknown device type for ID: $deviceId');
    }

    try {
      final response = await _webSocketService.requestActionCable(
        action: 'update_resource',
        resourceType: resourceType,
        additionalData: {
          'id': rawId,
          'params': device.map(
            ap: (d) => d.toJson(),
            ont: (d) => d.toJson(),
            switchDevice: (d) => d.toJson(),
            wlan: (d) => d.toJson(),
          ),
        },
        timeout: const Duration(seconds: 15),
      );

      final deviceData = _extractDeviceData(response.payload, response.raw);
      if (deviceData != null) {
        return _mapToDeviceModel(resourceType, deviceData);
      }

      // Return the original device if no response data
      return device;
    } on Exception catch (e) {
      _logger.e('DeviceWebSocketDataSource: Failed to update device: $e');
      throw Exception('Failed to update device: $e');
    }
  }

  @override
  Future<DeviceModelSealed> updateDeviceNote(String deviceId, String? note) async {
    _logger.i('DeviceWebSocketDataSource: updateDeviceNote($deviceId) called');

    final resourceType = _getResourceTypeFromId(deviceId);
    final rawId = _extractRawId(deviceId);

    if (resourceType == null) {
      throw Exception('Unknown device type for ID: $deviceId');
    }

    try {
      final response = await _webSocketService.requestActionCable(
        action: 'update_resource',
        resourceType: resourceType,
        additionalData: {
          'id': rawId,
          'params': {'note': note}, // Only send the note field!
        },
        timeout: const Duration(seconds: 15),
      );

      final deviceData = _extractDeviceData(response.payload, response.raw);
      if (deviceData != null) {
        return _mapToDeviceModel(resourceType, deviceData);
      }

      // Response didn't include parseable device data. The update was still
      // sent successfully (got a response, no timeout). Log the response for
      // debugging, then return the cached device with the note applied locally.
      _logger.w(
        'DeviceWebSocketDataSource: update_resource response missing device '
        'data for $deviceId. payload keys: ${response.payload.keys.toList()}',
      );

      // Fall back to cached device with local note update
      final cachedModels = _cacheIntegration.getAllCachedDeviceModels();
      final cached = cachedModels.where((d) => d.deviceId == deviceId).firstOrNull;
      if (cached != null) {
        return cached.map(
          ap: (d) => d.copyWith(note: note),
          ont: (d) => d.copyWith(note: note),
          switchDevice: (d) => d.copyWith(note: note),
          wlan: (d) => d.copyWith(note: note),
        );
      }

      // No cached device either — last resort
      return getDevice(deviceId, forceRefresh: true);
    } on Exception catch (e) {
      _logger.e('DeviceWebSocketDataSource: Failed to update note: $e');
      throw Exception('Failed to update note: $e');
    }
  }

  @override
  Future<void> rebootDevice(String deviceId) async {
    _logger.i('DeviceWebSocketDataSource: rebootDevice($deviceId) called');

    final resourceType = _getResourceTypeFromId(deviceId);
    final rawId = _extractRawId(deviceId);

    if (resourceType == null) {
      throw Exception('Unknown device type for ID: $deviceId');
    }

    try {
      await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: resourceType,
        additionalData: {
          'crud_action': 'reboot',
          'id': rawId,
        },
        timeout: const Duration(seconds: 30),
      );
      _logger.i('DeviceWebSocketDataSource: Reboot command sent for $deviceId');
    } on Exception catch (e) {
      _logger.e('DeviceWebSocketDataSource: Failed to reboot device: $e');
      throw Exception('Failed to reboot device: $e');
    }
  }

  @override
  Future<void> resetDevice(String deviceId) async {
    _logger.i('DeviceWebSocketDataSource: resetDevice($deviceId) called');

    final resourceType = _getResourceTypeFromId(deviceId);
    final rawId = _extractRawId(deviceId);

    if (resourceType == null) {
      throw Exception('Unknown device type for ID: $deviceId');
    }

    try {
      await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: resourceType,
        additionalData: {
          'crud_action': 'reset',
          'id': rawId,
        },
        timeout: const Duration(seconds: 30),
      );
      _logger.i('DeviceWebSocketDataSource: Reset command sent for $deviceId');
    } on Exception catch (e) {
      _logger.e('DeviceWebSocketDataSource: Failed to reset device: $e');
      throw Exception('Failed to reset device: $e');
    }
  }

  @override
  Future<DeviceModelSealed> deleteDeviceImage(
    String deviceId,
    String signedIdToDelete,
  ) async {
    _logger.i(
      'DeviceWebSocketDataSource: deleteDeviceImage($deviceId, signedId: $signedIdToDelete)',
    );

    final resourceType = _getResourceTypeFromId(deviceId);
    final rawId = _extractRawId(deviceId);

    if (resourceType == null) {
      throw Exception('Unknown device type for ID: $deviceId');
    }

    // Use REST API (HTTP PUT) for image deletion.
    // The WebSocket update_resource action does not process the images
    // parameter - only the REST API endpoint handles image updates.
    // This matches how ATT-FE-Tool deletes images.
    final restService = await _getRestImageUploadService();

    // Fetch current signed IDs from the server via REST
    final currentSignedIds = await restService.fetchCurrentSignedIds(
      resourceType: resourceType,
      deviceId: rawId,
    );

    _logger.i(
      'DeviceWebSocketDataSource: Current image count: ${currentSignedIds.length}',
    );

    // Filter out the signed ID to delete
    final updatedSignedIds = currentSignedIds
        .where((id) => id != signedIdToDelete)
        .toList();

    if (updatedSignedIds.length == currentSignedIds.length) {
      _logger.e(
        'DeviceWebSocketDataSource: SignedId not found in device images: $signedIdToDelete',
      );
      throw Exception('SignedId not found in device images.');
    }

    // Send the remaining signed IDs via REST PUT
    final result = await restService.uploadImages(
      deviceId: rawId,
      resourceType: resourceType,
      images: updatedSignedIds,
    );

    if (!result.success) {
      _logger.e(
        'DeviceWebSocketDataSource: REST delete failed: ${result.errorMessage}',
      );
      throw Exception('Failed to delete device image: ${result.errorMessage}');
    }

    _logger.i('DeviceWebSocketDataSource: Image deleted via REST API successfully');

    // Fetch the updated device data via REST to get the new state
    final deviceData = await restService.fetchDeviceData(
      resourceType: resourceType,
      deviceId: rawId,
    );

    if (deviceData != null) {
      return _mapToDeviceModel(resourceType, deviceData);
    }

    // Fallback: return cached device if REST fetch fails
    return getDevice(deviceId);
  }

  /// Creates a [RestImageUploadService] using stored credentials.
  Future<RestImageUploadService> _getRestImageUploadService() async {
    final storage = _storageService;
    if (storage == null) {
      throw Exception('StorageService not available for REST API');
    }

    final siteUrl = storage.siteUrl;
    if (siteUrl == null || siteUrl.isEmpty) {
      throw Exception('Site URL not available for REST API');
    }

    final apiKey = await storage.getToken();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not available for REST API');
    }

    return RestImageUploadService(siteUrl: siteUrl, apiKey: apiKey);
  }

  String? _getResourceTypeFromId(String deviceId) {
    for (final entry in _deviceEndpointByPrefix.entries) {
      if (deviceId.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  String _extractRawId(String deviceId) {
    for (final prefix in _deviceEndpointByPrefix.keys) {
      if (deviceId.startsWith(prefix)) {
        return deviceId.substring(prefix.length);
      }
    }
    return deviceId;
  }

  Map<String, dynamic>? _extractDeviceData(
    Map<String, dynamic> payload,
    Map<String, dynamic>? raw,
  ) {
    if (payload.containsKey('id')) return payload;
    if (payload['data'] is Map<String, dynamic>) {
      return payload['data'] as Map<String, dynamic>;
    }
    if (raw != null && raw['data'] is Map<String, dynamic>) {
      return raw['data'] as Map<String, dynamic>;
    }
    return null;
  }

  /// Delegates to [WebSocketCacheIntegration.mapToDeviceModel] so there is
  /// a single, complete mapper for all device data (includes onboardingStatus,
  /// hnCounts, healthNotices, metadata).
  DeviceModelSealed _mapToDeviceModel(
    String resourceType,
    Map<String, dynamic> deviceMap,
  ) {
    final model = _cacheIntegration.mapToDeviceModel(resourceType, deviceMap);
    if (model == null) {
      throw Exception('Failed to map device of type: $resourceType');
    }
    return model;
  }

  @override
  Future<DeviceModelSealed> uploadDeviceImages(
    String deviceId,
    List<String> images,
  ) async {
    _logger.i(
      'DeviceWebSocketDataSource: uploadDeviceImages($deviceId, ${images.length} images) called',
    );

    final resourceType = _getResourceTypeFromId(deviceId);
    final rawId = _extractRawId(deviceId);

    if (resourceType == null) {
      throw Exception('Unknown device type for ID: $deviceId');
    }

    // Note: The caller (ImageUploadService) is responsible for combining
    // existing images (using signed IDs) with new images (data URLs).
    // We just pass through the complete list to the server.
    try {
      final response = await _webSocketService.requestActionCable(
        action: 'update_resource',
        resourceType: resourceType,
        additionalData: {
          'id': rawId,
          'params': {'images': images},
        },
        timeout: const Duration(seconds: 30),
      );

      final deviceData = _extractDeviceData(response.payload, response.raw);
      if (deviceData != null) {
        return _mapToDeviceModel(resourceType, deviceData);
      }

      // Return updated device if no response data
      return await getDevice(deviceId);
    } on Exception catch (e) {
      _logger.e('DeviceWebSocketDataSource: Failed to upload device images: $e');
      throw Exception('Failed to upload device images: $e');
    }
  }
}
