import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/services/api_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';

/// Abstract class for remote data source to maintain backward compatibility
abstract class DeviceRemoteDataSource extends DeviceDataSource {}

/// Implementation of remote data source for fetching devices from API
class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  const DeviceRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;
  static final _logger = LoggerConfig.getLogger();

  /// Extracts location from device map, prioritizing pms_room.name
  String _extractLocation(Map<String, dynamic> deviceMap) {
    // Primary: Extract from pms_room.name
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      final pmsRoomName = pmsRoom['name']?.toString();
      if (pmsRoomName != null && pmsRoomName.isNotEmpty) {
        return pmsRoomName;
      }
    }

    // Fallback chain: try various location fields
    return deviceMap['location']?.toString() ??
        deviceMap['room']?.toString() ??
        deviceMap['zone']?.toString() ??
        deviceMap['room_id']?.toString() ??
        '';
  }

  /// Extract PMS room ID from device map
  int? _extractPmsRoomId(Map<String, dynamic> deviceMap) {
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      final idValue = pmsRoom['id'];
      if (idValue is int) {
        return idValue;
      } else if (idValue is String) {
        return int.tryParse(idValue);
      }
    }
    return null;
  }

  /// Extract images from device map (handles various formats)
  List<String>? _extractImages(Map<String, dynamic> deviceMap) {
    // Try various image field names
    final imageKeys = [
      'images',
      'image',
      'image_url',
      'imageUrl',
      'photos',
      'photo',
      'photo_url',
      'photoUrl',
      'device_images',
      'device_image',
    ];

    for (final key in imageKeys) {
      final value = deviceMap[key];
      if (value == null) continue;

      // Handle List of URLs
      if (value is List && value.isNotEmpty) {
        final urls = value
            .map((e) {
              if (e is String) return e;
              if (e is Map) return e['url']?.toString() ?? e['src']?.toString();
              return e?.toString();
            })
            .where((e) => e != null && e.isNotEmpty)
            .cast<String>()
            .toList();
        if (urls.isNotEmpty) return urls;
      }

      // Handle single URL string
      if (value is String && value.isNotEmpty) {
        // Check if it's a JSON-encoded array
        if (value.startsWith('[')) {
          try {
            final decoded = value.replaceAll(RegExp(r'[\[\]"]'), '').split(',');
            final urls = decoded
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            if (urls.isNotEmpty) return urls;
          } on Exception catch (_) {
            // Not valid JSON array, treat as single URL
          }
        }
        return [value];
      }

      // Handle Map with url/src field
      if (value is Map) {
        final url = value['url']?.toString() ?? value['src']?.toString();
        if (url != null && url.isNotEmpty) {
          return [url];
        }
      }
    }

    return null;
  }

  /// Fetch all items from endpoint without pagination
  Future<List<Map<String, dynamic>>> _fetchAllPages(
    String endpoint, {
    List<String>? fields,
  }) async {
    try {
      // Build query with field selection
      final fieldsParam = (fields?.isNotEmpty ?? false)
          ? '&only=${fields!.join(',')}'
          : '';

      // Request all items using page_size=0 (returns all records) with field selection
      final response = await apiService.get<dynamic>(
        '$endpoint${endpoint.contains('?') ? '&' : '?'}page_size=0$fieldsParam',
      );

      if (response.data == null) {
        return [];
      }

      var results = <dynamic>[];

      // Handle different response formats
      if (response.data is List) {
        results = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Try different possible keys for the results array
        if (data['results'] != null && data['results'] is List) {
          results = data['results'] as List<dynamic>;
        } else if (data['data'] != null && data['data'] is List) {
          results = data['data'] as List<dynamic>;
        } else if (data['items'] != null && data['items'] is List) {
          results = data['items'] as List<dynamic>;
        } else {
          return [];
        }
      } else {
        return [];
      }

      // Deduplicate by ID to ensure uniqueness
      final uniqueResults = <String, Map<String, dynamic>>{};
      for (final result in results) {
        if (result is Map<String, dynamic>) {
          final id = result['id']?.toString();
          if (id != null) {
            uniqueResults[id] = result;
          }
        }
      }

      return uniqueResults.values.toList();
    } on Exception catch (e) {
      _logger.e('Error fetching $endpoint: $e');
      return [];
    }
  }

  @override
  Future<List<DeviceModel>> getDevices({List<String>? fields}) async {
    try {
      // Fetch all device types in parallel with retry logic
      final results = await Future.wait([
        _fetchDeviceTypeWithRetry('access_points', fields: fields),
        _fetchDeviceTypeWithRetry('media_converters', fields: fields),
        _fetchDeviceTypeWithRetry('switch_devices', fields: fields),
        _fetchDeviceTypeWithRetry('wlan_devices', fields: fields),
      ]);

      // Combine all results
      final allDevices = <DeviceModel>[
        ...results[0],
        ...results[1],
        ...results[2],
        ...results[3],
      ];

      // Debug: Log device counts by type (using debugPrint for production visibility)
      debugPrint('REMOTE_DATA_SOURCE: Fetched devices - APs: ${results[0].length}, ONTs: ${results[1].length}, Switches: ${results[2].length}, WLAN: ${results[3].length}');

      return allDevices;
    } on Exception catch (e) {
      _logger.e('getDevices error: $e');
      throw Exception('Failed to get devices: $e');
    }
  }

  /// Fetch devices of a specific type with retry logic
  Future<List<DeviceModel>> _fetchDeviceTypeWithRetry(
    String type, {
    List<String>? fields,
    int maxRetries = 2,
  }) async {
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final results = await _fetchDeviceType(type, fields: fields);
        if (results.isNotEmpty || attempt == maxRetries) {
          return results;
        }
        // Empty results - brief retry delay
        await Future<void>.delayed(const Duration(milliseconds: 500));
      } on Exception catch (_) {
        if (attempt == maxRetries) {
          return [];
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }
    return [];
  }

  /// Fetch devices of a specific type
  Future<List<DeviceModel>> _fetchDeviceType(
    String type, {
    List<String>? fields,
  }) async {
    try {
      final results = await _fetchAllPages('/api/$type.json', fields: fields);

      return results.map((deviceMap) {
        switch (type) {
          case 'access_points':
            return DeviceModel.fromJson({
              'id':
                  'ap_${deviceMap['id']?.toString() ?? ''}', // Prefixed to avoid ID collisions
              'name': deviceMap['name'] ?? 'AP-${deviceMap['id']}',
              'type': 'access_point',
              'status': _determineStatus(deviceMap),
              'pms_room_id': _extractPmsRoomId(deviceMap),
              'mac_address': deviceMap['mac'] ?? deviceMap['mac_address'] ?? '',
              'ip_address': deviceMap['ip'] ?? deviceMap['ip_address'] ?? '',
              'model': deviceMap['model'] ?? '',
              'serial_number': deviceMap['serial_number'] ?? '',
              'location': _extractLocation(deviceMap),
              'last_seen': deviceMap['last_seen'] ?? deviceMap['updated_at'],
              'images': _extractImages(deviceMap),
              'metadata': deviceMap,
            });

          case 'media_converters':
            return DeviceModel.fromJson({
              'id':
                  'ont_${deviceMap['id']?.toString() ?? ''}', // Prefixed to avoid ID collisions
              'name': deviceMap['name'] ?? 'ONT-${deviceMap['id']}',
              'type': 'ont',
              'status': _determineStatus(deviceMap),
              'pms_room_id': _extractPmsRoomId(deviceMap),
              'mac_address': deviceMap['mac'] ?? deviceMap['mac_address'] ?? '',
              'ip_address': deviceMap['ip'] ?? deviceMap['ip_address'] ?? '',
              'model': deviceMap['model']?.toString() ?? '',
              'serialNumber': deviceMap['serial_number'] ?? '',
              'location': _extractLocation(deviceMap),
              'last_seen': deviceMap['last_seen'] ?? deviceMap['updated_at'],
              'images': _extractImages(deviceMap),
              'metadata': deviceMap,
            });

          case 'switch_devices':
            return DeviceModel.fromJson({
              'id':
                  'sw_${deviceMap['id']?.toString() ?? ''}', // Prefixed to avoid ID collisions
              'name':
                  deviceMap['name'] ??
                  deviceMap['nickname'] ??
                  'Switch-${deviceMap['id']}',
              'type': 'switch',
              'status': _determineStatus(deviceMap),
              'pms_room_id': _extractPmsRoomId(deviceMap),
              'mac_address':
                  deviceMap['scratch'] ??
                  '', // MAC stored in scratch field for switches
              'ip_address': deviceMap['host'] ?? deviceMap['loopback_ip'] ?? '',
              'model': deviceMap['model'] ?? deviceMap['device'] ?? '',
              'serial_number': deviceMap['serial_number'] ?? '',
              'location': _extractLocation(deviceMap),
              'last_seen':
                  deviceMap['last_config_sync_at'] ?? deviceMap['updated_at'],
              'images': _extractImages(deviceMap),
              'metadata': deviceMap,
            });

          case 'wlan_devices':
            return DeviceModel.fromJson({
              'id':
                  'wlan_${deviceMap['id']?.toString() ?? ''}', // Prefixed to avoid ID collisions
              'name': deviceMap['name'] ?? 'WLAN-${deviceMap['id']}',
              'type': 'wlan_controller',
              'status': _determineStatus(deviceMap),
              'mac_address': deviceMap['mac'] ?? deviceMap['mac_address'] ?? '',
              'ip_address':
                  deviceMap['host'] ??
                  deviceMap['ip'] ??
                  deviceMap['ip_address'] ??
                  '',
              'model': deviceMap['model'] ?? deviceMap['device'] ?? '',
              'serial_number': deviceMap['serial_number'] ?? '',
              'location': _extractLocation(deviceMap),
              'last_seen': deviceMap['updated_at'],
              'images': _extractImages(deviceMap),
              'metadata': deviceMap,
            });

          default:
            return DeviceModel.fromJson(deviceMap);
        }
      }).toList();
    } on Exception catch (e) {
      _logger.e('Error getting $type: $e');
      return [];
    }
  }

  String _determineStatus(Map<String, dynamic> device) {
    // Check various fields that might indicate status
    final onlineFlag = device['online'] as bool?;
    final activeFlag = device['active'] as bool?;

    if (onlineFlag != null) {
      return onlineFlag ? 'online' : 'offline';
    }
    if (device['status']?.toString().toLowerCase() == 'online') {
      return 'online';
    }
    if (device['status']?.toString().toLowerCase() == 'offline') {
      return 'offline';
    }
    if (activeFlag != null) {
      return activeFlag ? 'online' : 'offline';
    }

    // Check last seen time to determine if online
    if (device['last_seen'] != null || device['updated_at'] != null) {
      try {
        final lastSeenStr = (device['last_seen'] ?? device['updated_at'])
            .toString();
        final lastSeen = DateTime.parse(lastSeenStr);
        final now = DateTime.now();
        final difference = now.difference(lastSeen);

        // Consider online if seen in last 5 minutes
        if (difference.inMinutes < 5) {
          return 'online';
        } else if (difference.inHours < 1) {
          return 'warning';
        } else {
          return 'offline';
        }
      } on Exception catch (_) {
        // Can't parse date
      }
    }

    return 'unknown';
  }

  @override
  Future<DeviceModel> getDevice(String id, {List<String>? fields}) async {
    // Extract the raw ID (remove prefix like ap_, ont_, sw_, wlan_)
    final rawId = id.replaceFirst(RegExp('^(ap_|ont_|sw_|wlan_)'), '');

    // Determine device type from prefix
    String? deviceType;
    if (id.startsWith('ap_')) {
      deviceType = 'access_points';
    } else if (id.startsWith('ont_')) {
      deviceType = 'media_converters';
    } else if (id.startsWith('sw_')) {
      deviceType = 'switch_devices';
    } else if (id.startsWith('wlan_')) {
      deviceType = 'wlan_devices';
    }

    // Try specific endpoint first if we know the type
    if (deviceType != null) {
      try {
        final response = await apiService.get<Map<String, dynamic>>(
          '/api/$deviceType/$rawId.json',
        );
        if (response.data != null) {
          return _buildDeviceModel(response.data!, deviceType);
        }
      } on Exception catch (_) {
        // Fall through to try other endpoints
      }
    }

    // Try all endpoints
    for (final endpoint in ['switch_devices', 'access_points', 'media_converters', 'wlan_devices']) {
      try {
        final response = await apiService.get<Map<String, dynamic>>(
          '/api/$endpoint/$rawId.json',
        );
        if (response.data != null) {
          return _buildDeviceModel(response.data!, endpoint);
        }
      } on Exception catch (_) {
        // Continue to next endpoint
      }
    }

    throw Exception('Device not found');
  }

  DeviceModel _buildDeviceModel(Map<String, dynamic> data, String endpoint) {
    switch (endpoint) {
      case 'access_points':
        return DeviceModel.fromJson({
          'id': 'ap_${data['id']?.toString() ?? ''}',
          'name': data['name'] ?? 'AP-${data['id']}',
          'type': 'access_point',
          'status': _determineStatus(data),
          'pms_room_id': _extractPmsRoomId(data),
          'mac_address': data['mac'] ?? data['mac_address'] ?? '',
          'ip_address': data['ip'] ?? data['ip_address'] ?? '',
          'model': data['model'] ?? '',
          'serial_number': data['serial_number'] ?? '',
          'location': _extractLocation(data),
          'last_seen': data['last_seen'] ?? data['updated_at'],
          'images': _extractImages(data),
          'metadata': data,
        });

      case 'media_converters':
        return DeviceModel.fromJson({
          'id': 'ont_${data['id']?.toString() ?? ''}',
          'name': data['name'] ?? 'ONT-${data['id']}',
          'type': 'ont',
          'status': _determineStatus(data),
          'pms_room_id': _extractPmsRoomId(data),
          'mac_address': data['mac'] ?? data['mac_address'] ?? '',
          'ip_address': data['ip'] ?? data['ip_address'] ?? '',
          'model': data['model']?.toString() ?? '',
          'serial_number': data['serial_number'] ?? '',
          'location': _extractLocation(data),
          'last_seen': data['last_seen'] ?? data['updated_at'],
          'images': _extractImages(data),
          'metadata': data,
        });

      case 'switch_devices':
        return DeviceModel.fromJson({
          'id': 'sw_${data['id']?.toString() ?? ''}',
          'name': data['name'] ?? data['nickname'] ?? 'Switch-${data['id']}',
          'type': 'switch',
          'status': _determineStatus(data),
          'pms_room_id': _extractPmsRoomId(data),
          'mac_address': data['scratch'] ?? '',
          'ip_address': data['host'] ?? data['loopback_ip'] ?? '',
          'model': data['model'] ?? data['device'] ?? '',
          'serial_number': data['serial_number'] ?? '',
          'location': _extractLocation(data),
          'last_seen': data['last_config_sync_at'] ?? data['updated_at'],
          'images': _extractImages(data),
          'metadata': data,
        });

      case 'wlan_devices':
        return DeviceModel.fromJson({
          'id': 'wlan_${data['id']?.toString() ?? ''}',
          'name': data['name'] ?? 'WLAN-${data['id']}',
          'type': 'wlan_controller',
          'status': _determineStatus(data),
          'mac_address': data['mac'] ?? data['mac_address'] ?? '',
          'ip_address': data['host'] ?? data['ip'] ?? data['ip_address'] ?? '',
          'model': data['model'] ?? data['device'] ?? '',
          'serial_number': data['serial_number'] ?? '',
          'location': _extractLocation(data),
          'last_seen': data['updated_at'],
          'images': _extractImages(data),
          'metadata': data,
        });

      default:
        return DeviceModel.fromJson(data);
    }
  }

  @override
  Future<List<DeviceModel>> getDevicesByRoom(String roomId) async {
    try {
      // Get all devices and filter by room
      final allDevices = await getDevices();
      return allDevices.where((device) {
        final location = device.location ?? '';
        final metadata = device.metadata ?? {};
        final roomIdStr = metadata['room_id']?.toString() ?? '';
        final room = metadata['room']?.toString() ?? '';
        return location == roomId || roomIdStr == roomId || room == roomId;
      }).toList();
    } on Exception catch (e) {
      throw Exception('Failed to get devices by room: $e');
    }
  }

  @override
  Future<List<DeviceModel>> searchDevices(String query) async {
    try {
      // Get all devices and filter locally
      final allDevices = await getDevices();
      final lowerQuery = query.toLowerCase();

      return allDevices.where((device) {
        return device.name.toLowerCase().contains(lowerQuery) ||
            device.id.toLowerCase().contains(lowerQuery) ||
            (device.serialNumber?.toLowerCase().contains(lowerQuery) ??
                false) ||
            (device.macAddress?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } on Exception catch (e) {
      throw Exception('Failed to search devices: $e');
    }
  }

  @override
  Future<DeviceModel> updateDevice(DeviceModel device) async {
    try {
      final response = await apiService.put<Map<String, dynamic>>(
        '/api/devices/${device.id}.json',
        data: {'device': device.toJson()},
      );
      return DeviceModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw Exception('Failed to update device: $e');
    }
  }

  @override
  Future<void> rebootDevice(String deviceId) async {
    try {
      await apiService.post<void>('/api/devices/$deviceId/reboot.json');
    } on Exception catch (e) {
      throw Exception('Failed to reboot device: $e');
    }
  }

  @override
  Future<void> resetDevice(String deviceId) async {
    try {
      await apiService.post<void>('/api/devices/$deviceId/reset.json');
    } on Exception catch (e) {
      throw Exception('Failed to reset device: $e');
    }
  }
}
