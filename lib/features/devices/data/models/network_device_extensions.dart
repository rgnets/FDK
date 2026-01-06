import 'package:rgnets_fdk/features/devices/data/models/network_device_model.dart';

/// Common computed properties for all NetworkDevice types
extension NetworkDeviceX on NetworkDevice {
  /// Get the device type as a display string
  String get deviceType => map(
        ont: (_) => 'ONT',
        ap: (_) => 'Access Point',
        switchDevice: (_) => 'Switch',
      );

  /// Get room name if available (ONT and AP only)
  String? get roomName => mapOrNull(
        ont: (d) => d.pmsRoom?['name'] as String?,
        ap: (d) => d.pmsRoom?['name'] as String?,
      );

  /// Get room ID if available (ONT and AP only)
  int? get roomId => mapOrNull(
        ont: (d) => d.pmsRoom?['id'] as int?,
        ap: (d) => d.pmsRoom?['id'] as int?,
      );

  /// Get common ID across all device types
  int get deviceId => map(
        ont: (d) => d.id,
        ap: (d) => d.id,
        switchDevice: (d) => d.id,
      );

  /// Get common name across all device types
  String get deviceName => map(
        ont: (d) => d.name,
        ap: (d) => d.name,
        switchDevice: (d) => d.name,
      );

  /// Get online status across all device types
  bool get isOnline => map(
        ont: (d) => d.online,
        ap: (d) => d.online,
        switchDevice: (d) => d.online,
      );
}

/// ONT-specific computed properties
extension ONTDeviceX on ONTDevice {
  String? get roomName => pmsRoom?['name'] as String?;
  int? get roomId => pmsRoom?['id'] as int?;
}

/// AP-specific computed properties
extension APDeviceX on APDevice {
  bool get isConnected => connectionState == 'connected';
  String? get roomName => pmsRoom?['name'] as String?;
  int? get roomId => pmsRoom?['id'] as int?;
}

/// Switch-specific computed properties
extension SwitchDeviceX on SwitchDevice {
  /// Check if configuration sync is up to date
  bool get isConfigSyncCurrent {
    if (lastConfigSync == null) return false;
    if (lastConfigSyncAttempt == null) return true;
    return !lastConfigSyncAttempt!.isAfter(lastConfigSync!);
  }

  /// Get hours since last successful sync
  int? get hoursSinceLastSync {
    if (lastConfigSync == null) return null;
    return DateTime.now().difference(lastConfigSync!).inHours;
  }

  /// Get hours since last sync attempt
  int? get hoursSinceLastAttempt {
    if (lastConfigSyncAttempt == null) return null;
    return DateTime.now().difference(lastConfigSyncAttempt!).inHours;
  }

  /// Get number of active ports
  int get activePortCount => ports
      .where((p) => p['shutdown'] != true && p['link_speed'] != '0')
      .length;

  /// Get number of shutdown ports
  int get shutdownPortCount =>
      ports.where((p) => p['shutdown'] == true).length;
}
