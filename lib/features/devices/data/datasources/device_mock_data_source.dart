import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';

/// Mock implementation of DeviceDataSource for development environment
/// Parses JSON from MockDataService through the same flow as production
class DeviceMockDataSourceImpl implements DeviceDataSource {
  const DeviceMockDataSourceImpl({
    required this.mockDataService,
  });

  final MockDataService mockDataService;

  @override
  Future<List<DeviceModel>> getDevices({
    List<String>? fields,
  }) async {
    final devices = <DeviceModel>[];
    
    // Get JSON data from MockDataService
    final apJson = mockDataService.getMockAccessPointsJson();
    final switchJson = mockDataService.getMockSwitchesJson();
    final ontJson = mockDataService.getMockMediaConvertersJson();
    
    // Parse each device type
    devices.addAll(_parseAccessPoints(apJson));
    devices.addAll(_parseSwitches(switchJson));
    devices.addAll(_parseMediaConverters(ontJson));
    
    return devices;
  }

  @override
  Future<DeviceModel> getDevice(
    String id, {
    List<String>? fields,
    bool forceRefresh = false,
  }) async {
    // Mock data source doesn't have caching, so forceRefresh is a no-op
    final allDevices = await getDevices(fields: fields);
    return allDevices.firstWhere(
      (device) => device.id == id,
      orElse: () => throw Exception('Device not found: $id'),
    );
  }

  @override
  Future<List<DeviceModel>> getDevicesByRoom(String roomId) async {
    final allDevices = await getDevices();
    
    // Parse roomId to int for comparison with pmsRoomId
    final roomIdInt = int.tryParse(roomId);
    if (roomIdInt == null) {
      return [];
    }
    
    return allDevices.where((device) => device.pmsRoomId == roomIdInt).toList();
  }

  @override
  Future<List<DeviceModel>> searchDevices(String query) async {
    final allDevices = await getDevices();
    final lowerQuery = query.toLowerCase();
    
    return allDevices.where((device) {
      return device.name.toLowerCase().contains(lowerQuery) ||
             device.location?.toLowerCase().contains(lowerQuery) == true ||
             device.macAddress?.toLowerCase().contains(lowerQuery) == true ||
             device.ipAddress?.contains(query) == true ||
             device.serialNumber?.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }

  @override
  Future<DeviceModel> updateDevice(DeviceModel device) async {
    // Mock update - just return the device
    // In a real implementation, this would update the mock data
    return device;
  }

  @override
  Future<void> rebootDevice(String deviceId) async {
    // Mock reboot - just verify device exists
    await getDevice(deviceId);
    // Simulate reboot delay
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> resetDevice(String deviceId) async {
    // Mock reset - just verify device exists
    await getDevice(deviceId);
    // Simulate reset delay
    await Future<void>.delayed(const Duration(seconds: 2));
  }

  @override
  Future<DeviceModel> deleteDeviceImage(
    String deviceId,
    String signedIdToDelete,
  ) async {
    final device = await getDevice(deviceId);
    final currentSignedIds = device.imageSignedIds ?? const [];
    final currentImages = device.images ?? const [];
    if (currentSignedIds.isEmpty) {
      return device;
    }

    // Filter out the signed ID to delete
    final updatedSignedIds =
        currentSignedIds.where((id) => id != signedIdToDelete).toList();
    // Also update images list to match
    final deleteIndex = currentSignedIds.indexOf(signedIdToDelete);
    List<String> updatedImages;
    if (deleteIndex >= 0 && deleteIndex < currentImages.length) {
      updatedImages = List<String>.from(currentImages)..removeAt(deleteIndex);
    } else {
      updatedImages = List<String>.from(currentImages);
    }
    return device.copyWith(
      images: updatedImages,
      imageSignedIds: updatedSignedIds,
    );
  }

  @override
  Future<DeviceModel> uploadDeviceImages(
    String deviceId,
    List<String> base64Images,
  ) async {
    final device = await getDevice(deviceId);
    final currentImages = device.images ?? const [];

    // For mock, simulate converting base64 to URLs
    // In production, the server would return actual URLs
    final newImageUrls = base64Images.asMap().entries.map((entry) {
      return 'https://mock.example.com/images/$deviceId/${DateTime.now().millisecondsSinceEpoch}_${entry.key}.jpg';
    }).toList();

    final updatedImages = [...currentImages, ...newImageUrls];
    return device.copyWith(images: updatedImages);
  }

  /// Parse access points from JSON
  List<DeviceModel> _parseAccessPoints(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    
    return results.map((deviceMap) {
      deviceMap = deviceMap as Map<String, dynamic>;
      
      // Extract pms_room data
      int? pmsRoomId;
      String location = '';
      
      if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
        final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
        pmsRoomId = pmsRoom['id'] as int?;
        location = pmsRoom['name']?.toString() ?? '';
      }
      
      // Parse last_seen
      DateTime? lastSeen;
      if (deviceMap['last_seen'] != null) {
        lastSeen = DateTime.tryParse(deviceMap['last_seen'].toString());
      }
      
      // Name must be provided by MockDataService
      if (deviceMap['name'] == null) {
        throw Exception('Access point ${deviceMap['id']} missing required name field');
      }
      
      return DeviceModel.fromJson({
        'id': 'ap_${deviceMap['id']}',
        'name': deviceMap['name'],
        'type': 'access_point',
        'status': deviceMap['online'] == true ? 'online' : 'offline',
        'pms_room_id': pmsRoomId,
        'location': location,
        'mac_address': deviceMap['mac'],
        'ip_address': deviceMap['ip'],
        'model': deviceMap['model'],
        'serial_number': deviceMap['serial_number'],
        'last_seen': lastSeen?.toIso8601String(),
        'firmware': deviceMap['firmware'],
        'signal_strength': deviceMap['signal_strength'],
        'uptime': deviceMap['uptime'],
        'connected_clients': deviceMap['connected_clients'],
        'vlan': deviceMap['vlan'],
        'ssid': deviceMap['ssid'],
        'channel': deviceMap['channel'],
        'metadata': deviceMap,
      });
    }).toList();
  }

  /// Parse switches from JSON
  List<DeviceModel> _parseSwitches(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    
    return results.map((deviceMap) {
      deviceMap = deviceMap as Map<String, dynamic>;
      
      // Extract pms_room data
      int? pmsRoomId;
      String location = '';
      
      if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
        final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
        pmsRoomId = pmsRoom['id'] as int?;
        location = pmsRoom['name']?.toString() ?? '';
      }
      
      // Parse last_seen/last_config_sync_at
      DateTime? lastSeen;
      final lastSeenStr = deviceMap['last_config_sync_at'] ?? deviceMap['updated_at'];
      if (lastSeenStr != null) {
        lastSeen = DateTime.tryParse(lastSeenStr.toString());
      }
      
      // Name must be provided by MockDataService
      final name = deviceMap['name'] ?? deviceMap['nickname'];
      if (name == null) {
        throw Exception('Switch ${deviceMap['id']} missing required name field');
      }
      
      return DeviceModel.fromJson({
        'id': 'sw_${deviceMap['id']}',
        'name': name,
        'type': 'switch',
        'status': deviceMap['online'] == true ? 'online' : 'offline',
        'pms_room_id': pmsRoomId,
        'location': location.isNotEmpty ? location : deviceMap['zone'],
        'mac_address': deviceMap['scratch'], // MAC stored in scratch field for switches
        'ip_address': deviceMap['host'] ?? deviceMap['loopback_ip'],
        'model': deviceMap['model'] ?? deviceMap['device'],
        'serial_number': deviceMap['serial_number'],
        'last_seen': lastSeen?.toIso8601String(),
        'firmware': deviceMap['firmware'],
        'uptime': deviceMap['uptime'],
        'cpu_usage': deviceMap['cpu_usage'],
        'memory_usage': deviceMap['memory_usage'],
        'temperature': deviceMap['temperature'],
        'metadata': deviceMap,
      });
    }).toList();
  }

  /// Parse media converters (ONTs) from JSON
  List<DeviceModel> _parseMediaConverters(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    
    return results.map((deviceMap) {
      deviceMap = deviceMap as Map<String, dynamic>;
      
      // Extract pms_room data
      int? pmsRoomId;
      String location = '';
      
      if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
        final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
        pmsRoomId = pmsRoom['id'] as int?;
        location = pmsRoom['name']?.toString() ?? '';
      }
      
      // Parse updated_at
      DateTime? lastSeen;
      if (deviceMap['updated_at'] != null) {
        lastSeen = DateTime.tryParse(deviceMap['updated_at'].toString());
      }
      
      // Name must be provided by MockDataService
      if (deviceMap['name'] == null) {
        throw Exception('Media converter ${deviceMap['id']} missing required name field');
      }
      
      return DeviceModel.fromJson({
        'id': 'ont_${deviceMap['id']}',
        'name': deviceMap['name'],
        'type': 'ont',
        'status': deviceMap['online'] == true ? 'online' : 'offline',
        'pms_room_id': pmsRoomId,
        'location': location,
        'mac_address': deviceMap['mac'],
        'ip_address': deviceMap['ip'],
        'model': deviceMap['model']?.toString(),
        'serial_number': deviceMap['serial_number'],
        'last_seen': lastSeen?.toIso8601String(),
        'firmware': deviceMap['firmware'],
        'signal_strength': deviceMap['signal_strength'],
        'uptime': deviceMap['uptime'],
        'temperature': deviceMap['temperature'],
        'packet_loss': deviceMap['packet_loss']?.toDouble(),
        'latency': deviceMap['latency'],
        'metadata': deviceMap,
      });
    }).toList();
  }
}
