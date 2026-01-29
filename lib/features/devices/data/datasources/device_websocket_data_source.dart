import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/core/utils/image_url_normalizer.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';

/// WebSocket-based data source for fetching devices.
/// Replaces DeviceRemoteDataSource with a WebSocket-backed implementation.
class DeviceWebSocketDataSource implements DeviceDataSource {
  DeviceWebSocketDataSource({
    required WebSocketCacheIntegration webSocketCacheIntegration,
    String? imageBaseUrl,
    Logger? logger,
  })  : _cacheIntegration = webSocketCacheIntegration,
        _imageBaseUrl = imageBaseUrl,
        _logger = logger ?? Logger();

  final WebSocketCacheIntegration _cacheIntegration;
  final String? _imageBaseUrl;
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

      // Fetch fresh device data if response didn't include it
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

    // Get current device to access imageSignedIds
    final device = await getDevice(deviceId);
    final currentSignedIds = device.map(
      ap: (d) => d.imageSignedIds ?? [],
      ont: (d) => d.imageSignedIds ?? [],
      switchDevice: (d) => d.imageSignedIds ?? [],
      wlan: (d) => d.imageSignedIds ?? [],
    );

    // Filter out the signed ID to delete (like ATT-FE-Tool does)
    final updatedSignedIds = currentSignedIds
        .where((id) => id != signedIdToDelete)
        .toList();

    if (updatedSignedIds.length == currentSignedIds.length) {
      _logger.e(
        'DeviceWebSocketDataSource: SignedId not found in device images: $signedIdToDelete',
      );
      throw Exception('SignedId not found in device images.');
    }

    try {
      // Send update request without waiting for response (fire-and-forget)
      // The backend broadcasts resource_updated without request_id, causing timeouts
      // Instead, we send and verify by fetching the updated device
      final requestId = 'req-$resourceType-${DateTime.now().millisecondsSinceEpoch}';
      final data = {
        'action': 'update_resource',
        'resource_type': resourceType,
        'request_id': requestId,
        'id': rawId,
        'params': {'images': updatedSignedIds},
      };

      _webSocketService.send({
        'command': 'message',
        'identifier': '{"channel":"RxgChannel"}',
        'data': jsonEncode(data),
      });

      _logger.i('DeviceWebSocketDataSource: Image delete request sent');

      // Wait briefly for the backend to process the update
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Verify the change by fetching the updated device
      final updatedDevice = await getDevice(deviceId, forceRefresh: true);

      final newImageCount = updatedDevice.map(
        ap: (d) => d.images?.length ?? 0,
        ont: (d) => d.images?.length ?? 0,
        switchDevice: (d) => d.images?.length ?? 0,
        wlan: (d) => d.images?.length ?? 0,
      );

      if (newImageCount < currentSignedIds.length) {
        _logger.i('DeviceWebSocketDataSource: Image deletion verified successfully');
        return updatedDevice;
      } else {
        _logger.w('DeviceWebSocketDataSource: Image count unchanged after delete');
        // Still return the device - the cache may update later via WebSocket broadcast
        return updatedDevice;
      }
    } on Exception catch (e) {
      _logger.e('DeviceWebSocketDataSource: Failed to delete device image: $e');
      throw Exception('Failed to delete device image: $e');
    }
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

  DeviceModelSealed _mapToDeviceModel(
    String resourceType,
    Map<String, dynamic> deviceMap,
  ) {
    // Extract images with both URLs and signed IDs
    final imageData = _extractImagesData(deviceMap);

    switch (resourceType) {
      case 'access_points':
        return DeviceModelSealed.ap(
          id: 'ap_${deviceMap['id']}',
          name: deviceMap['name']?.toString() ?? 'AP-${deviceMap['id']}',
          status: _determineStatus(deviceMap),
          pmsRoomId: _extractPmsRoomId(deviceMap),
          macAddress: deviceMap['mac']?.toString(),
          ipAddress: deviceMap['ip']?.toString(),
          model: deviceMap['model']?.toString(),
          serialNumber: deviceMap['serial_number']?.toString(),
          note: deviceMap['note']?.toString(),
          images: imageData?.urls,
          imageSignedIds: imageData?.signedIds,
        );

      case 'media_converters':
        return DeviceModelSealed.ont(
          id: 'ont_${deviceMap['id']}',
          name: deviceMap['name']?.toString() ?? 'ONT-${deviceMap['id']}',
          status: _determineStatus(deviceMap),
          pmsRoomId: _extractPmsRoomId(deviceMap),
          macAddress: deviceMap['mac']?.toString(),
          ipAddress: deviceMap['ip']?.toString(),
          model: deviceMap['model']?.toString(),
          serialNumber: deviceMap['serial_number']?.toString(),
          note: deviceMap['note']?.toString(),
          images: imageData?.urls,
          imageSignedIds: imageData?.signedIds,
        );

      case 'switch_devices':
        return DeviceModelSealed.switchDevice(
          id: 'sw_${deviceMap['id']}',
          name: deviceMap['name']?.toString() ??
              deviceMap['nickname']?.toString() ??
              'Switch-${deviceMap['id']}',
          status: _determineStatus(deviceMap),
          pmsRoomId: _extractPmsRoomId(deviceMap),
          macAddress: deviceMap['scratch']?.toString(),
          ipAddress: deviceMap['host']?.toString(),
          host: deviceMap['host']?.toString(),
          model:
              deviceMap['model']?.toString() ?? deviceMap['device']?.toString(),
          serialNumber: deviceMap['serial_number']?.toString(),
          note: deviceMap['note']?.toString(),
          images: imageData?.urls,
          imageSignedIds: imageData?.signedIds,
        );

      case 'wlan_devices':
        return DeviceModelSealed.wlan(
          id: 'wlan_${deviceMap['id']}',
          name: deviceMap['name']?.toString() ?? 'WLAN-${deviceMap['id']}',
          status: _determineStatus(deviceMap),
          macAddress: deviceMap['mac']?.toString(),
          ipAddress: deviceMap['host']?.toString() ??
              deviceMap['ip']?.toString(),
          model:
              deviceMap['model']?.toString() ?? deviceMap['device']?.toString(),
          serialNumber: deviceMap['serial_number']?.toString(),
          note: deviceMap['note']?.toString(),
          images: imageData?.urls,
          imageSignedIds: imageData?.signedIds,
        );

      default:
        throw Exception('Unknown resource type: $resourceType');
    }
  }

  String _determineStatus(Map<String, dynamic> device) {
    final onlineFlag = device['online'] as bool?;
    if (onlineFlag != null) {
      return onlineFlag ? 'online' : 'offline';
    }
    return 'unknown';
  }

  int? _extractPmsRoomId(Map<String, dynamic> deviceMap) {
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      final idValue = pmsRoom['id'];
      if (idValue is int) return idValue;
      if (idValue is String) return int.tryParse(idValue);
    }
    return null;
  }

  /// Extract images with both URLs (for display) and signed IDs (for API operations)
  ImageExtraction? _extractImagesData(Map<String, dynamic> deviceMap) {
    final imagesValue = deviceMap['images'] ?? deviceMap['pictures'];
    return extractImagesWithSignedIds(imagesValue, baseUrl: _imageBaseUrl);
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
