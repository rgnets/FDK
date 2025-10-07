import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/api_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';

/// Abstract class for remote data source to maintain backward compatibility
abstract class DeviceRemoteDataSource extends DeviceDataSource {}

/// Implementation of remote data source for fetching devices from API
class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  const DeviceRemoteDataSourceImpl({required this.apiService});

  final ApiService apiService;
  static final _logger = Logger();

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

  /// Fetch all items from endpoint without pagination
  Future<List<Map<String, dynamic>>> _fetchAllPages(
    String endpoint, {
    List<String>? fields,
  }) async {
    try {
      _logger.d('Fetching all items from $endpoint');

      // Build query with field selection
      final fieldsParam = (fields?.isNotEmpty ?? false)
          ? '&only=${fields!.join(',')}'
          : '';

      // Request all items using page_size=0 (returns all records) with field selection
      final response = await apiService.get<dynamic>(
        '$endpoint${endpoint.contains('?') ? '&' : '?'}page_size=0$fieldsParam',
      );

      if (response.data == null) {
        _logger.w('No data received from $endpoint');
        return [];
      }

      // Log the response type for debugging
      _logger.d('Response type from $endpoint: ${response.data.runtimeType}');

      var results = <dynamic>[];

      // Handle different response formats
      if (response.data is List) {
        // Direct array response (when page_size=0 might return unpaginated)
        _logger.d('Direct array response from $endpoint');
        results = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        _logger.d(
          'Map response from $endpoint with keys: ${data.keys.toList()}',
        );

        // Try different possible keys for the results array
        if (data['results'] != null && data['results'] is List) {
          results = data['results'] as List<dynamic>;
        } else if (data['data'] != null && data['data'] is List) {
          results = data['data'] as List<dynamic>;
        } else if (data['items'] != null && data['items'] is List) {
          results = data['items'] as List<dynamic>;
        } else {
          // If no standard key found, log available keys for debugging
          _logger.w(
            'No recognized data key found in response from $endpoint. Keys: ${data.keys}',
          );
          return [];
        }
      } else {
        _logger.e(
          'Unexpected response type from $endpoint: ${response.data.runtimeType}',
        );
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

      _logger.i('Fetched ${uniqueResults.length} unique items from $endpoint');
      return uniqueResults.values.toList();
    } on Exception catch (e) {
      _logger.e('Error fetching from $endpoint: $e');
      return [];
    }
  }

  // Track calls to prevent duplicate fetches
  static int _getDevicesCallCount = 0;

  @override
  Future<List<DeviceModel>> getDevices({List<String>? fields}) async {
    try {
      _getDevicesCallCount++;
      final callId = _getDevicesCallCount;

      _logger
        ..i(
          '📡 DEVICE_REMOTE_DATA_SOURCE: getDevices() CALL #$callId at ${DateTime.now().toIso8601String()}',
        )
        ..i(
          'DeviceRemoteDataSource: Getting devices with fields: ${fields?.join(',')}',
        )
        ..i('🔍 DEBUG: Call stack trace for getDevices() - Call #$callId');
      final stopwatch = Stopwatch()..start();

      // Fetch all device types in parallel with retry logic
      _logger
        ..d(
          'DEVICE_REMOTE_DATA_SOURCE: Starting parallel fetch of device types with retry',
        )
        ..d('Starting parallel fetch of all device types');
      final results = await Future.wait([
        _fetchDeviceTypeWithRetry('access_points', fields: fields),
        _fetchDeviceTypeWithRetry('media_converters', fields: fields),
        _fetchDeviceTypeWithRetry('switch_devices', fields: fields),
        _fetchDeviceTypeWithRetry('wlan_devices', fields: fields),
      ]);
      _logger.d('DEVICE_REMOTE_DATA_SOURCE: Parallel fetch completed');

      // Combine all results
      final allDevices = <DeviceModel>[];
      final apDevices = results[0];
      final ontDevices = results[1];
      final switchDevices = results[2];
      final wlanDevices = results[3];

      // Combine all results (deduplication already handled in _fetchAllPages)
      allDevices
        ..addAll(apDevices)
        ..addAll(ontDevices)
        ..addAll(switchDevices)
        ..addAll(wlanDevices);

      stopwatch.stop();
      _logger.i(
        'Total ${allDevices.length} devices collected in ${stopwatch.elapsedMilliseconds}ms',
      );

      // Count devices by type for logging
      final typeCounts = <String, int>{};
      for (final device in allDevices) {
        typeCounts[device.type] = (typeCounts[device.type] ?? 0) + 1;
      }

      _logger.d('Device counts by type:');
      typeCounts.forEach((type, count) {
        _logger.d('  $type: $count');
      });

      return allDevices;
    } on Exception catch (e) {
      _logger.e('DeviceRemoteDataSource: Error - $e');
      throw Exception('Failed to get devices: $e');
    }
  }

  /// Fetch devices of a specific type with retry logic
  Future<List<DeviceModel>> _fetchDeviceTypeWithRetry(
    String type, {
    List<String>? fields,
    int maxRetries = 3,
  }) async {
    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        _logger.d('Attempt $attempt of $maxRetries for $type');

        // Try to fetch the device type
        final results = await _fetchDeviceType(type, fields: fields);

        // If we got results, return them
        if (results.isNotEmpty) {
          _logger.i(
            'Successfully fetched ${results.length} $type on attempt $attempt',
          );
          return results;
        }

        // Empty results might indicate a transient error - retry if not last attempt
        if (attempt < maxRetries) {
          _logger.w('Got 0 $type on attempt $attempt - retrying');
          await Future<void>.delayed(Duration(seconds: attempt));
          continue;
        }

        // Last attempt got empty results - accept it
        _logger.w('Got 0 $type after $maxRetries attempts - may be legitimate');
        return results;
      } on Exception catch (e) {
        _logger.e('Attempt $attempt failed for $type: $e');

        // If this was our last attempt, return empty list for compatibility
        if (attempt == maxRetries) {
          _logger.e(
            'All $maxRetries attempts failed for $type - returning empty list',
          );
          return [];
        }

        // Calculate backoff delay (exponential: 1s, 2s, 4s)
        final delaySeconds = attempt;
        _logger.d('Waiting ${delaySeconds}s before retry ${attempt + 1}');
        await Future<void>.delayed(Duration(seconds: delaySeconds));
      }
    }

    // Should never reach here, but return empty list for safety
    return [];
  }

  /// Fetch devices of a specific type
  Future<List<DeviceModel>> _fetchDeviceType(
    String type, {
    List<String>? fields,
  }) async {
    try {
      _logger
        ..d(
          'DEVICE_REMOTE_DATA_SOURCE: Fetching $type with fields: ${fields?.join(',')}',
        )
        ..d('Fetching $type')
        ..i(
          '🔍 _fetchDeviceType: Starting fetch for $type at ${DateTime.now().toIso8601String()}',
        );
      final results = await _fetchAllPages('/api/$type.json', fields: fields);
      _logger
        ..d('DEVICE_REMOTE_DATA_SOURCE: Got ${results.length} $type')
        ..d('Total $type fetched: ${results.length}')
        ..i(
          '🔍 _fetchDeviceType: Completed fetch for $type - got ${results.length} items',
        );

      // Special debugging for switches
      if (type == 'switch_devices') {
        _logger.i(
          '🔍 SWITCH_DEVICES DEBUG: Raw API returned ${results.length} switches',
        );
        for (var i = 0; i < results.length; i++) {
          final raw = results[i];
          _logger.i(
            '  Raw switch ${i + 1}: ID=${raw['id']}, Name=${raw['name'] ?? raw['nickname']}',
          );
        }
      }

      // Debug for WLAN devices
      if (type == 'wlan_devices') {
        _logger.i(
          '🔍 WLAN_DEVICES DEBUG: Raw API returned ${results.length} WLAN devices',
        );
        for (var i = 0; i < results.length; i++) {
          final raw = results[i];
          _logger.i(
            '  Raw WLAN ${i + 1}: ID=${raw['id']}, Name=${raw['name']}, Device=${raw['device']}',
          );
        }
      }

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
    try {
      // Try different endpoints based on what's available
      try {
        final response = await apiService.get<Map<String, dynamic>>(
          '/api/devices/$id.json',
        );
        if (response.data != null) {
          return DeviceModel.fromJson(response.data!);
        }
      } on Exception catch (_) {
        // Try specific endpoints
        try {
          final response = await apiService.get<Map<String, dynamic>>(
            '/api/switch_devices/$id.json',
          );
          if (response.data != null) {
            final swMap = response.data!;
            return DeviceModel.fromJson({
              'id': swMap['id']?.toString() ?? '',
              'name': swMap['name'] ?? 'Switch-${swMap['id']}',
              'type': 'switch',
              'status': _determineStatus(swMap),
              'macAddress': swMap['scratch'] ?? '',
              'ipAddress': swMap['host'] ?? '',
              'model': swMap['model'] ?? '',
              'serialNumber': swMap['serial_number'] ?? '',
              'location': _extractLocation(swMap),
              'lastSeen': swMap['last_config_sync_at'] ?? swMap['updated_at'],
              'metadata': swMap,
            });
          }
        } on Exception catch (_) {
          // Try access points
          try {
            final response = await apiService.get<Map<String, dynamic>>(
              '/api/access_points/$id.json',
            );
            if (response.data != null) {
              final apMap = response.data!;
              return DeviceModel.fromJson({
                'id': apMap['id']?.toString() ?? '',
                'name': apMap['name'] ?? 'AP-${apMap['id']}',
                'type': 'access_point',
                'status': _determineStatus(apMap),
                'macAddress': apMap['mac'] ?? '',
                'ipAddress': apMap['ip'] ?? '',
                'model': apMap['model'] ?? '',
                'serialNumber': apMap['serial_number'] ?? '',
                'location': _extractLocation(apMap),
                'lastSeen': apMap['updated_at'],
                'metadata': apMap,
              });
            }
          } on Exception catch (_) {
            // Try media converters
            try {
              final response = await apiService.get<Map<String, dynamic>>(
                '/api/media_converters/$id.json',
              );
              if (response.data != null) {
                final ontMap = response.data!;
                return DeviceModel.fromJson({
                  'id': ontMap['id']?.toString() ?? '',
                  'name': ontMap['name'] ?? 'ONT-${ontMap['id']}',
                  'type': 'ont',
                  'status': _determineStatus(ontMap),
                  'macAddress': ontMap['mac'] ?? '',
                  'ipAddress': ontMap['ip'] ?? '',
                  'model': ontMap['model']?.toString() ?? '',
                  'serialNumber': ontMap['serial_number'] ?? '',
                  'location': _extractLocation(ontMap),
                  'lastSeen': ontMap['updated_at'],
                  'metadata': ontMap,
                });
              }
            } on Exception catch (_) {
              _logger.w('Device not found in any endpoint');
            }
          }
        }
      }
      throw Exception('Device not found');
    } on Exception catch (e) {
      throw Exception('Failed to get device: $e');
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
