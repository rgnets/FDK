import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/services/device_update_event_bus.dart';
import 'package:rgnets_fdk/core/utils/image_url_normalizer.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_counts_model.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_notice_model.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_status_payload.dart';

/// Callback type for when device data is received via WebSocket.
typedef DeviceDataCallback = void Function(
  String resourceType,
  List<Map<String, dynamic>> devices,
);

/// Manages device caches synced via WebSocket, including mapping raw JSON
/// to [DeviceModelSealed] models.
class WebSocketDeviceCacheService {
  WebSocketDeviceCacheService({
    String? imageBaseUrl,
    Logger? logger,
    DeviceUpdateEventBus? deviceUpdateEventBus,
    VoidCallback? onDataChanged,
  })  : _imageBaseUrl = imageBaseUrl,
        _logger = logger ?? Logger(),
        _deviceUpdateEventBus = deviceUpdateEventBus,
        _onDataChanged = onDataChanged;

  final String? _imageBaseUrl;
  final Logger _logger;
  final DeviceUpdateEventBus? _deviceUpdateEventBus;
  final VoidCallback? _onDataChanged;

  /// Device resource types to subscribe to.
  static const List<String> deviceResourceTypes = [
    'access_points',
    'switch_devices',
    'media_converters',
  ];

  /// Check whether [type] is a device resource type.
  static bool isDeviceResourceType(String type) =>
      deviceResourceTypes.contains(type);

  /// Cached device data by resource type.
  final Map<String, List<Map<String, dynamic>>> _deviceCache = {};

  final ValueNotifier<DateTime?> lastDeviceUpdate =
      ValueNotifier<DateTime?>(null);

  /// Callbacks for when device data is received.
  final List<DeviceDataCallback> _deviceDataCallbacks = [];

  // ---------------------------------------------------------------------------
  // Public query API
  // ---------------------------------------------------------------------------

  bool get hasDeviceCache => _deviceCache.values.any((list) => list.isNotEmpty);

  List<Map<String, dynamic>>? getCachedDevices(String resourceType) {
    return _deviceCache[resourceType];
  }

  List<DeviceModelSealed> getAllCachedDeviceModels() {
    final allDevices = <DeviceModelSealed>[];

    for (final entry in _deviceCache.entries) {
      final resourceType = entry.key;
      final devices = entry.value;

      for (final deviceMap in devices) {
        try {
          final model = mapToDeviceModel(resourceType, deviceMap);
          if (model != null) {
            allDevices.add(model);
          }
        } catch (e) {
          _logger.w('Failed to map device: $e');
        }
      }
    }

    return allDevices;
  }

  /// Maps raw device data to a [DeviceModelSealed] model.
  DeviceModelSealed? mapToDeviceModel(
    String resourceType,
    Map<String, dynamic> deviceMap,
  ) {
    try {
      final hnCounts = _extractHealthCounts(deviceMap);
      final healthNotices = _extractHealthNotices(deviceMap);

      switch (resourceType) {
        case 'access_points':
          final apImageData = _extractImagesData(deviceMap);
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
            images: apImageData?.urls,
            imageSignedIds: apImageData?.signedIds,
            hnCounts: hnCounts,
            healthNotices: healthNotices,
            metadata: deviceMap,
            onboardingStatus: deviceMap['ap_onboarding_status'] != null
                ? OnboardingStatusPayload.fromJson(
                    deviceMap['ap_onboarding_status'] as Map<String, dynamic>,
                  )
                : null,
          );

        case 'media_converters':
          final mcImageData = _extractImagesData(deviceMap);
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
            images: mcImageData?.urls,
            imageSignedIds: mcImageData?.signedIds,
            hnCounts: hnCounts,
            healthNotices: healthNotices,
            metadata: deviceMap,
            onboardingStatus: deviceMap['ont_onboarding_status'] != null
                ? OnboardingStatusPayload.fromJson(
                    deviceMap['ont_onboarding_status'] as Map<String, dynamic>,
                  )
                : null,
          );

        case 'switch_devices':
          final swImageData = _extractImagesData(deviceMap);
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
            model: deviceMap['model']?.toString() ??
                deviceMap['device']?.toString(),
            serialNumber: deviceMap['serial_number']?.toString(),
            note: deviceMap['note']?.toString(),
            images: swImageData?.urls,
            imageSignedIds: swImageData?.signedIds,
            hnCounts: hnCounts,
            healthNotices: healthNotices,
            metadata: deviceMap,
          );

        case 'wlan_devices':
          final wlanImageData = _extractImagesData(deviceMap);
          return DeviceModelSealed.wlan(
            id: 'wlan_${deviceMap['id']}',
            name: deviceMap['name']?.toString() ?? 'WLAN-${deviceMap['id']}',
            status: _determineStatus(deviceMap),
            macAddress: deviceMap['mac']?.toString(),
            ipAddress: deviceMap['host']?.toString() ??
                deviceMap['ip']?.toString(),
            model: deviceMap['model']?.toString() ??
                deviceMap['device']?.toString(),
            serialNumber: deviceMap['serial_number']?.toString(),
            note: deviceMap['note']?.toString(),
            images: wlanImageData?.urls,
            imageSignedIds: wlanImageData?.signedIds,
            hnCounts: hnCounts,
            healthNotices: healthNotices,
            metadata: deviceMap,
          );

        default:
          return null;
      }
    } catch (e) {
      _logger.e('Error mapping device: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Callback registration
  // ---------------------------------------------------------------------------

  void onDeviceData(DeviceDataCallback callback) {
    _deviceDataCallbacks.add(callback);
  }

  void removeDeviceDataCallback(DeviceDataCallback callback) {
    _deviceDataCallbacks.remove(callback);
  }

  // ---------------------------------------------------------------------------
  // REST-based cache update
  // ---------------------------------------------------------------------------

  void updateDeviceFromRest(
      String resourceType, Map<String, dynamic> deviceData) {
    if (!deviceResourceTypes.contains(resourceType)) {
      _logger.w(
        'WebSocketDeviceCacheService: updateDeviceFromRest called with non-device resource: $resourceType',
      );
      return;
    }

    final id = deviceData['id'];
    if (id == null) {
      _logger.w(
          'WebSocketDeviceCacheService: updateDeviceFromRest called with no id');
      return;
    }

    _logger.i(
      'WebSocketDeviceCacheService: Updating device from REST - '
      'resource=$resourceType, id=$id',
    );

    applyUpsert(resourceType, deviceData, action: 'show');
  }

  // ---------------------------------------------------------------------------
  // Internal: called by facade routing
  // ---------------------------------------------------------------------------

  void applySnapshot(
      String resourceType, List<Map<String, dynamic>> items) {
    _deviceCache[resourceType] = items;
    _onDataChanged?.call();
    _bumpDeviceUpdate();

    if (items.isNotEmpty) {
      final firstItem = items.first;
      final hasHnCounts = firstItem.containsKey('hn_counts');
      final hasHealthNotices = firstItem.containsKey('health_notices');
      _logger.i(
        'WebSocketDeviceCacheService: $resourceType snapshot - ${items.length} items, '
        'has hn_counts: $hasHnCounts, has health_notices: $hasHealthNotices',
      );
      if (!hasHnCounts && !hasHealthNotices) {
        _logger.i('  First item keys: ${firstItem.keys.toList()}');
      }
    }

    for (final callback in _deviceDataCallbacks) {
      callback(resourceType, items);
    }
  }

  void applyUpsert(
    String resourceType,
    Map<String, dynamic> data, {
    String? action,
  }) {
    final id = data['id'];
    if (id == null) return;

    final cache = _deviceCache[resourceType] ?? [];
    final index = cache.indexWhere((item) => item['id'] == id);
    final isNew = index < 0;
    if (isNew) {
      cache.add(data);
    } else {
      cache[index] = data;
    }
    _deviceCache[resourceType] = cache;
    _onDataChanged?.call();
    _bumpDeviceUpdate();

    for (final callback in _deviceDataCallbacks) {
      callback(resourceType, cache);
    }

    if (action != null && _isMutationAction(action)) {
      _emitDeviceUpdateEvent(
        resourceType,
        id,
        isNew ? DeviceUpdateAction.created : DeviceUpdateAction.updated,
      );
    }
  }

  void applyDelete(String resourceType, Map<String, dynamic> data) {
    final id = data['id'];
    if (id == null) return;

    final cache = _deviceCache[resourceType] ?? [];
    cache.removeWhere((item) => item['id'] == id);
    _deviceCache[resourceType] = cache;
    _onDataChanged?.call();
    _bumpDeviceUpdate();

    for (final callback in _deviceDataCallbacks) {
      callback(resourceType, cache);
    }

    _emitDeviceUpdateEvent(
      resourceType,
      id,
      DeviceUpdateAction.destroyed,
    );
  }

  /// Whether the device cache for [resourceType] has items.
  bool hasCachedItems(String resourceType) =>
      _deviceCache[resourceType]?.isNotEmpty ?? false;

  void clearCaches() {
    _deviceCache.clear();
  }

  void dispose() {
    lastDeviceUpdate.dispose();
    _deviceDataCallbacks.clear();
    _deviceCache.clear();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _bumpDeviceUpdate() {
    lastDeviceUpdate.value = DateTime.now();
  }

  String _determineStatus(Map<String, dynamic> device) {
    final onlineFlag = device['online'] as bool?;
    if (onlineFlag != null) {
      return onlineFlag ? 'online' : 'offline';
    }
    return 'unknown';
  }

  int? _extractPmsRoomId(Map<String, dynamic> deviceMap) {
    final directId = deviceMap['pms_room_id'];
    if (directId is int) return directId;
    if (directId is String) {
      final parsed = int.tryParse(directId);
      if (parsed != null) return parsed;
    }
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      final idValue = pmsRoom['id'];
      if (idValue is int) {
        return idValue;
      }
      if (idValue is String) {
        return int.tryParse(idValue);
      }
    }
    return null;
  }

  ImageExtraction? _extractImagesData(Map<String, dynamic> deviceMap) {
    final imagesValue = deviceMap['images'] ?? deviceMap['pictures'];
    return extractImagesWithSignedIds(imagesValue, baseUrl: _imageBaseUrl);
  }

  HealthCountsModel? _extractHealthCounts(Map<String, dynamic> deviceMap) {
    final hnCountsData = deviceMap['hn_counts'];
    if (hnCountsData == null) {
      return null;
    }
    _logger.i(
        'WebSocketDeviceCacheService: Found hn_counts for device ${deviceMap['name'] ?? deviceMap['id']}: $hnCountsData');
    if (hnCountsData is Map<String, dynamic>) {
      try {
        return HealthCountsModel.fromJson(hnCountsData);
      } catch (e) {
        _logger.w('Failed to parse hn_counts: $e');
        return null;
      }
    }
    return null;
  }

  List<HealthNoticeModel>? _extractHealthNotices(
      Map<String, dynamic> deviceMap) {
    final healthNoticesData = deviceMap['health_notices'];
    if (healthNoticesData == null) {
      return null;
    }
    if (healthNoticesData is List) {
      try {
        return healthNoticesData
            .whereType<Map<String, dynamic>>()
            .map(HealthNoticeModel.fromJson)
            .toList();
      } catch (e) {
        _logger.w('Failed to parse health_notices: $e');
        return null;
      }
    }
    return null;
  }

  bool _isMutationAction(String action) {
    return action == 'resource_created' ||
        action == 'resource_updated' ||
        action == 'created' ||
        action == 'updated' ||
        action == 'create' ||
        action == 'update';
  }

  String? _mapToDeviceId(String resourceType, dynamic id) {
    if (id == null) return null;
    switch (resourceType) {
      case 'access_points':
        return 'ap_$id';
      case 'media_converters':
        return 'ont_$id';
      case 'switch_devices':
        return 'sw_$id';
      default:
        return null;
    }
  }

  void _emitDeviceUpdateEvent(
    String resourceType,
    dynamic id,
    DeviceUpdateAction action, {
    List<String>? changedFields,
  }) {
    if (_deviceUpdateEventBus == null) return;
    if (!deviceResourceTypes.contains(resourceType)) return;

    final deviceId = _mapToDeviceId(resourceType, id);
    if (deviceId == null) return;

    _logger.d(
      'WebSocketDeviceCacheService: Emitting device update event - '
      'deviceId=$deviceId, action=$action',
    );

    _deviceUpdateEventBus.emit(
      DeviceUpdateEvent(
        deviceId: deviceId,
        action: action,
        changedFields: changedFields,
      ),
    );
  }
}
