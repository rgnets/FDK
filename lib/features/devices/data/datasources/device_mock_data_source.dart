import 'package:rgnets_fdk/core/services/mock_data_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';

/// Mock implementation of DeviceDataSource for development environment
/// Parses JSON from MockDataService through the same flow as production
class DeviceMockDataSourceImpl implements DeviceDataSource {
  const DeviceMockDataSourceImpl({
    required this.mockDataService,
  });

  final MockDataService mockDataService;

  @override
  Future<List<DeviceModelSealed>> getDevices({
    List<String>? fields,
  }) async {
    final devices = <DeviceModelSealed>[];

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
  Future<DeviceModelSealed> getDevice(
    String id, {
    List<String>? fields,
  }) async {
    final allDevices = await getDevices(fields: fields);
    return allDevices.firstWhere(
      (device) => device.deviceId == id,
      orElse: () => throw Exception('Device not found: $id'),
    );
  }

  @override
  Future<List<DeviceModelSealed>> getDevicesByRoom(String roomId) async {
    final allDevices = await getDevices();

    // Parse roomId to int for comparison with pmsRoomId
    final roomIdInt = int.tryParse(roomId);
    if (roomIdInt == null) {
      return [];
    }

    return allDevices.where((device) {
      final pmsRoomId = device.map(
        ap: (d) => d.pmsRoomId,
        ont: (d) => d.pmsRoomId,
        switchDevice: (d) => d.pmsRoomId,
        wlan: (d) => d.pmsRoomId,
      );
      return pmsRoomId == roomIdInt;
    }).toList();
  }

  @override
  Future<List<DeviceModelSealed>> searchDevices(String query) async {
    final allDevices = await getDevices();
    final lowerQuery = query.toLowerCase();

    return allDevices.where((device) {
      final name = device.deviceName.toLowerCase();
      final location = device.map(
        ap: (d) => d.location?.toLowerCase(),
        ont: (d) => d.location?.toLowerCase(),
        switchDevice: (d) => d.location?.toLowerCase(),
        wlan: (d) => d.location?.toLowerCase(),
      );
      final macAddress = device.map(
        ap: (d) => d.macAddress?.toLowerCase(),
        ont: (d) => d.macAddress?.toLowerCase(),
        switchDevice: (d) => d.macAddress?.toLowerCase(),
        wlan: (d) => d.macAddress?.toLowerCase(),
      );
      final ipAddress = device.map(
        ap: (d) => d.ipAddress,
        ont: (d) => d.ipAddress,
        switchDevice: (d) => d.ipAddress,
        wlan: (d) => d.ipAddress,
      );
      final serialNumber = device.map(
        ap: (d) => d.serialNumber?.toLowerCase(),
        ont: (d) => d.serialNumber?.toLowerCase(),
        switchDevice: (d) => d.serialNumber?.toLowerCase(),
        wlan: (d) => d.serialNumber?.toLowerCase(),
      );

      return name.contains(lowerQuery) ||
          (location?.contains(lowerQuery) ?? false) ||
          (macAddress?.contains(lowerQuery) ?? false) ||
          (ipAddress?.contains(query) ?? false) ||
          (serialNumber?.contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<DeviceModelSealed> updateDevice(DeviceModelSealed device) async {
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
  Future<DeviceModelSealed> deleteDeviceImage(
    String deviceId,
    String imageUrl,
  ) async {
    final device = await getDevice(deviceId);
    final currentImages = device.map(
      ap: (d) => d.images ?? const [],
      ont: (d) => d.images ?? const [],
      switchDevice: (d) => d.images ?? const [],
      wlan: (d) => d.images ?? const [],
    );
    if (currentImages.isEmpty) {
      return device;
    }

    final updatedImages =
        currentImages.where((image) => image != imageUrl).toList();

    // Return a copy with updated images
    return device.map(
      ap: (d) => d.copyWith(images: updatedImages),
      ont: (d) => d.copyWith(images: updatedImages),
      switchDevice: (d) => d.copyWith(images: updatedImages),
      wlan: (d) => d.copyWith(images: updatedImages),
    );
  }

  /// Parse access points from JSON
  List<APModel> _parseAccessPoints(Map<String, dynamic> json) {
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
        throw Exception(
            'Access point ${deviceMap['id']} missing required name field');
      }

      return DeviceModelSealed.ap(
        id: 'ap_${deviceMap['id']}',
        name: deviceMap['name'] as String,
        status: deviceMap['online'] == true ? 'online' : 'offline',
        pmsRoomId: pmsRoomId,
        location: location.isNotEmpty ? location : null,
        macAddress: deviceMap['mac']?.toString(),
        ipAddress: deviceMap['ip']?.toString(),
        model: deviceMap['model']?.toString(),
        serialNumber: deviceMap['serial_number']?.toString(),
        lastSeen: lastSeen,
        firmware: deviceMap['firmware']?.toString(),
        signalStrength: deviceMap['signal_strength'] as int?,
        connectedClients: deviceMap['connected_clients'] as int?,
        ssid: deviceMap['ssid']?.toString(),
        channel: deviceMap['channel'] as int?,
        metadata: deviceMap,
      ) as APModel;
    }).toList();
  }

  /// Parse switches from JSON
  List<SwitchModel> _parseSwitches(Map<String, dynamic> json) {
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
      final lastSeenStr =
          deviceMap['last_config_sync_at'] ?? deviceMap['updated_at'];
      if (lastSeenStr != null) {
        lastSeen = DateTime.tryParse(lastSeenStr.toString());
      }

      // Name must be provided by MockDataService
      final name = deviceMap['name'] ?? deviceMap['nickname'];
      if (name == null) {
        throw Exception(
            'Switch ${deviceMap['id']} missing required name field');
      }

      return DeviceModelSealed.switchDevice(
        id: 'sw_${deviceMap['id']}',
        name: name as String,
        status: deviceMap['online'] == true ? 'online' : 'offline',
        pmsRoomId: pmsRoomId,
        location: location.isNotEmpty ? location : deviceMap['zone']?.toString(),
        macAddress: deviceMap['scratch']?.toString(),
        ipAddress: deviceMap['host']?.toString() ??
            deviceMap['loopback_ip']?.toString(),
        host: deviceMap['host']?.toString(),
        model: deviceMap['model']?.toString() ?? deviceMap['device']?.toString(),
        serialNumber: deviceMap['serial_number']?.toString(),
        lastSeen: lastSeen,
        firmware: deviceMap['firmware']?.toString(),
        cpuUsage: deviceMap['cpu_usage'] as int?,
        memoryUsage: deviceMap['memory_usage'] as int?,
        temperature: deviceMap['temperature'] as int?,
        metadata: deviceMap,
      ) as SwitchModel;
    }).toList();
  }

  /// Parse media converters (ONTs) from JSON
  List<ONTModel> _parseMediaConverters(Map<String, dynamic> json) {
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
        throw Exception(
            'Media converter ${deviceMap['id']} missing required name field');
      }

      return DeviceModelSealed.ont(
        id: 'ont_${deviceMap['id']}',
        name: deviceMap['name'] as String,
        status: deviceMap['online'] == true ? 'online' : 'offline',
        pmsRoomId: pmsRoomId,
        location: location.isNotEmpty ? location : null,
        macAddress: deviceMap['mac']?.toString(),
        ipAddress: deviceMap['ip']?.toString(),
        model: deviceMap['model']?.toString(),
        serialNumber: deviceMap['serial_number']?.toString(),
        lastSeen: lastSeen,
        firmware: deviceMap['firmware']?.toString(),
        uptime: deviceMap['uptime']?.toString(),
        metadata: deviceMap,
      ) as ONTModel;
    }).toList();
  }
}
