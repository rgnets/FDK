import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';

/// Service responsible for processing raw room JSON data into RoomModel instances.
///
/// This service handles the conversion of WebSocket/API room payloads
/// into strongly-typed RoomModel objects, including device ID extraction.
class RoomDataProcessor {
  /// Build a RoomModel from raw JSON data
  RoomModel buildRoomModel(Map<String, dynamic> roomData) {
    final displayName = buildDisplayName(roomData);
    final rawId = roomData['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
    return RoomModel(
      id: id,
      name: displayName,
      deviceIds: extractDeviceIds(roomData),
      metadata: roomData,
    );
  }

  /// Build a display name for a room from raw JSON
  String buildDisplayName(Map<String, dynamic> roomData) {
    final roomNumber = roomData['room']?.toString();
    final pmsProperty = roomData['pms_property'];
    final propertyName = pmsProperty is Map<String, dynamic>
        ? pmsProperty['name']?.toString()
        : null;
    if (propertyName != null && roomNumber != null) {
      return '($propertyName) $roomNumber';
    }
    return roomNumber ?? 'Room ${roomData['id']}';
  }

  /// Extract all device IDs associated with a room
  List<String> extractDeviceIds(Map<String, dynamic> roomData) {
    final deviceIds = <String>{};
    final roomId = roomData['id']?.toString();
    if (roomId == null) {
      return [];
    }

    void addDevices(List<dynamic>? list, {String prefix = ''}) {
      if (list == null) {
        return;
      }
      for (final entry in list) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        final id = entry['id'];
        if (id != null) {
          deviceIds.add('$prefix$id');
        }

        final nested = entry['devices'];
        if (nested is List<dynamic>) {
          for (final device in nested) {
            if (device is Map<String, dynamic>) {
              final nestedId = device['id'];
              if (nestedId != null) {
                deviceIds.add(nestedId.toString());
              }
            }
          }
        }
      }
    }

    void addSwitchPortDevices(List<dynamic>? list) {
      if (list == null) {
        return;
      }
      for (final entry in list) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        final switchDevice = entry['switch_device'];
        final switchDeviceId = switchDevice is Map<String, dynamic>
            ? switchDevice['id']
            : entry['switch_device_id'];
        final id = switchDeviceId ?? entry['id'];
        if (id != null) {
          deviceIds.add('sw_$id');
        }

        final nested = entry['devices'];
        if (nested is List<dynamic>) {
          for (final device in nested) {
            if (device is Map<String, dynamic>) {
              final nestedId = device['id'];
              if (nestedId != null) {
                deviceIds.add(nestedId.toString());
              }
            }
          }
        }
      }
    }

    addDevices(roomData['access_points'] as List<dynamic>?, prefix: 'ap_');
    addDevices(roomData['media_converters'] as List<dynamic>?, prefix: 'ont_');
    final switchPorts = roomData['switch_ports'];
    if (switchPorts is List && switchPorts.isNotEmpty) {
      addSwitchPortDevices(switchPorts);
    } else {
      addDevices(roomData['switch_devices'] as List<dynamic>?, prefix: 'sw_');
    }
    addDevices(roomData['wlan_devices'] as List<dynamic>?, prefix: 'wlan_');
    addDevices(roomData['infrastructure_devices'] as List<dynamic>?);

    final routerStats = roomData['router_stats'];
    if (routerStats is Map<String, dynamic>) {
      final routerDevices = routerStats['devices'];
      if (routerDevices is Map<String, dynamic>) {
        addDevices(routerDevices['recent'] as List<dynamic>?);
      }
    }

    return deviceIds.toList();
  }
}
