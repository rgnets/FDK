import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_status_payload.dart';

/// Service responsible for normalizing raw JSON device data into typed models.
///
/// This service handles the conversion of WebSocket/API device payloads
/// into strongly-typed device models (AP, ONT, Switch, WLAN).
class DeviceNormalizer {
  /// Normalize raw JSON to APModel
  APModel normalizeToAP(Map<String, dynamic> data) {
    return APModel(
      id: (data['id'] ?? '').toString(),
      name: data['name']?.toString() ?? 'Unknown AP',
      status: determineStatus(data),
      pmsRoomId: extractPmsRoomId(data),
      ipAddress: data['ip']?.toString(),
      macAddress: data['mac']?.toString(),
      location: extractLocation(data),
      model: data['model']?.toString(),
      serialNumber: data['serial_number']?.toString(),
      firmware: data['firmware']?.toString() ?? data['version']?.toString(),
      note: data['note']?.toString(),
      images: extractImages(data),
      metadata: data,
      connectionState: data['connection_state']?.toString(),
      signalStrength: _toInt(data['signal_strength']),
      connectedClients: _toInt(data['connected_clients']),
      ssid: data['ssid']?.toString(),
      channel: _toInt(data['channel']),
      maxClients: _toInt(data['max_clients']),
      currentUpload: _toDouble(data['current_upload']),
      currentDownload: _toDouble(data['current_download']),
      onboardingStatus: data['ap_onboarding_status'] != null
          ? OnboardingStatusPayload.fromJson(
              data['ap_onboarding_status'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Normalize raw JSON to ONTModel
  ONTModel normalizeToONT(Map<String, dynamic> data) {
    return ONTModel(
      id: (data['id'] ?? '').toString(),
      name: data['name']?.toString() ?? 'Unknown ONT',
      status: determineStatus(data),
      pmsRoomId: extractPmsRoomId(data),
      ipAddress: data['ip']?.toString(),
      macAddress: data['mac']?.toString(),
      location: extractLocation(data),
      model: data['model']?.toString(),
      serialNumber: data['serial_number']?.toString(),
      firmware: data['firmware']?.toString() ?? data['version']?.toString(),
      note: data['note']?.toString(),
      images: extractImages(data),
      metadata: data,
      isRegistered: data['is_registered'] as bool?,
      switchPort: data['switch_port'] as Map<String, dynamic>?,
      onboardingStatus: data['ont_onboarding_status'] != null
          ? OnboardingStatusPayload.fromJson(
              data['ont_onboarding_status'] as Map<String, dynamic>,
            )
          : null,
      ports: (data['ont_ports'] as List<dynamic>?)?.cast<Map<String, dynamic>>(),
      uptime: data['uptime']?.toString(),
      phase: data['phase']?.toString(),
    );
  }

  /// Normalize raw JSON to SwitchModel
  SwitchModel normalizeToSwitch(Map<String, dynamic> data) {
    return SwitchModel(
      id: (data['id'] ?? '').toString(),
      name: data['name']?.toString() ?? 'Unknown Switch',
      status: determineStatus(data),
      pmsRoomId: extractPmsRoomId(data),
      ipAddress: data['ip']?.toString() ?? data['host']?.toString(),
      macAddress: data['mac']?.toString(),
      location: extractLocation(data),
      model: data['model']?.toString(),
      serialNumber: data['serial_number']?.toString(),
      firmware: data['firmware']?.toString() ?? data['version']?.toString(),
      note: data['note']?.toString(),
      images: extractImages(data),
      metadata: data,
      host: data['host']?.toString(),
      ports: (data['switch_ports'] as List<dynamic>?)?.cast<Map<String, dynamic>>(),
      cpuUsage: _toInt(data['cpu_usage']),
      memoryUsage: _toInt(data['memory_usage']),
      temperature: _toInt(data['temperature']),
    );
  }

  /// Normalize raw JSON to WLANModel
  WLANModel normalizeToWLAN(Map<String, dynamic> data) {
    return WLANModel(
      id: (data['id'] ?? '').toString(),
      name: data['name']?.toString() ?? 'Unknown WLAN',
      status: determineStatus(data),
      pmsRoomId: extractPmsRoomId(data),
      ipAddress: data['ip']?.toString(),
      macAddress: data['mac']?.toString(),
      location: extractLocation(data),
      model: data['model']?.toString(),
      serialNumber: data['serial_number']?.toString(),
      firmware: data['firmware']?.toString() ?? data['version']?.toString(),
      note: data['note']?.toString(),
      images: extractImages(data),
      metadata: data,
      controllerType: data['controller_type']?.toString(),
      managedAPs: _toInt(data['managed_aps']),
      vlan: _toInt(data['vlan']),
      totalUpload: _toInt(data['total_upload']),
      totalDownload: _toInt(data['total_download']),
      packetLoss: _toDouble(data['packet_loss']),
      latency: _toInt(data['latency']),
      restartCount: _toInt(data['restart_count']),
    );
  }

  /// Determine device online/offline status from various JSON fields
  String determineStatus(Map<String, dynamic> device) {
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

    if (device['last_seen'] != null || device['updated_at'] != null) {
      try {
        final lastSeenStr = (device['last_seen'] ?? device['updated_at'])
            .toString();
        final lastSeen = DateTime.parse(lastSeenStr);
        final now = DateTime.now();
        final difference = now.difference(lastSeen);
        if (difference.inMinutes < 5) {
          return 'online';
        } else if (difference.inHours < 1) {
          return 'warning';
        } else {
          return 'offline';
        }
      } on Exception {
        // Date parsing failed - fallback to unknown status
      }
    }

    return 'unknown';
  }

  /// Extract location/room name from device data
  String extractLocation(Map<String, dynamic> deviceMap) {
    if (deviceMap['pms_room'] != null && deviceMap['pms_room'] is Map) {
      final pmsRoom = deviceMap['pms_room'] as Map<String, dynamic>;
      final pmsRoomName = pmsRoom['name']?.toString();
      if (pmsRoomName != null && pmsRoomName.isNotEmpty) {
        return pmsRoomName;
      }
    }
    return deviceMap['location']?.toString() ??
        deviceMap['room']?.toString() ??
        deviceMap['zone']?.toString() ??
        deviceMap['room_id']?.toString() ??
        '';
  }

  /// Extract PMS room ID from device data
  int? extractPmsRoomId(Map<String, dynamic> deviceMap) {
    // Try direct pms_room_id field first
    final directId = deviceMap['pms_room_id'];
    if (directId != null) {
      if (directId is int) {
        return directId;
      }
      if (directId is String) {
        final parsed = int.tryParse(directId);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    // Try nested pms_room.id
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

  /// Extract image URLs from device data
  List<String>? extractImages(Map<String, dynamic> deviceMap) {
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
      if (value == null) {
        continue;
      }

      if (value is List && value.isNotEmpty) {
        final urls = value
            .map((e) {
              if (e is String) {
                return e;
              }
              if (e is Map) {
                return e['url']?.toString() ?? e['src']?.toString();
              }
              return e?.toString();
            })
            .where((e) => e != null && e.isNotEmpty)
            .cast<String>()
            .toList();
        if (urls.isNotEmpty) {
          return urls;
        }
      }

      if (value is String && value.isNotEmpty) {
        return [value];
      }

      if (value is Map) {
        final url = value['url']?.toString() ?? value['src']?.toString();
        if (url != null && url.isNotEmpty) {
          return [url];
        }
      }
    }

    return null;
  }

  /// Safely convert a dynamic value to int.
  /// Handles int, num, String, and List (returns length for count fields
  /// like connected_clients which may arrive as a list of client objects).
  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is List) {
      return value.length;
    }
    return null;
  }

  /// Safely convert a dynamic value to double.
  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
