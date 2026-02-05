import 'dart:convert';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/typed_device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';

/// One-time migration service to convert old unified device cache
/// to new type-specific caches.
///
/// Old format:
/// - `device_index` → List of device IDs
/// - `cached_device_{id}` → Individual device JSON
///
/// New format:
/// - `cached_ap_devices` → JSON array of all APs
/// - `cached_ont_devices` → JSON array of all ONTs
/// - `cached_switch_devices` → JSON array of all Switches
/// - `cached_wlan_devices` → JSON array of all WLANs
class DeviceCacheMigrationService {
  DeviceCacheMigrationService({
    required this.storageService,
    required this.apDataSource,
    required this.ontDataSource,
    required this.switchDataSource,
    required this.wlanDataSource,
  });

  final StorageService storageService;
  final APLocalDataSource apDataSource;
  final ONTLocalDataSource ontDataSource;
  final SwitchLocalDataSource switchDataSource;
  final WLANLocalDataSource wlanDataSource;
  final _logger = LoggerService.getLogger();

  // Old cache keys
  static const String _oldIndexKey = 'device_index';
  static const String _oldDeviceKeyPrefix = 'cached_device_';
  static const String _oldTimestampKey = 'devices_cache_timestamp';
  static const String _migrationCompleteKey = 'device_cache_migration_v2_complete';

  /// Check if migration is needed
  Future<bool> needsMigration() async {
    // Already migrated
    final migrated = storageService.getString(_migrationCompleteKey);
    if (migrated == 'true') {
      return false;
    }

    // Check if old cache exists
    final oldIndex = storageService.getString(_oldIndexKey);
    return oldIndex != null && oldIndex.isNotEmpty;
  }

  /// Run the migration
  Future<MigrationResult> migrate() async {
    if (!await needsMigration()) {
      return const MigrationResult(
        success: true,
        migrated: false,
        message: 'Migration not needed',
      );
    }

    _logger.i('Starting device cache migration...');

    try {
      // Load old device index
      final indexJson = storageService.getString(_oldIndexKey);
      if (indexJson == null) {
        return const MigrationResult(
          success: true,
          migrated: false,
          message: 'No old cache found',
        );
      }

      final index = (json.decode(indexJson) as List<dynamic>).cast<String>();
      _logger.d('Found ${index.length} devices in old cache');

      // Collect devices by type
      final apDevices = <APModel>[];
      final ontDevices = <ONTModel>[];
      final switchDevices = <SwitchModel>[];
      final wlanDevices = <WLANModel>[];
      final failedIds = <String>[];

      for (final id in index) {
        final deviceJson = storageService.getString('$_oldDeviceKeyPrefix$id');
        if (deviceJson == null) {
          failedIds.add(id);
          continue;
        }

        try {
          final data = json.decode(deviceJson) as Map<String, dynamic>;
          final deviceType = _determineDeviceType(data);

          switch (deviceType) {
            case DeviceModelSealed.typeAccessPoint:
              apDevices.add(_parseAsAP(data));
            case DeviceModelSealed.typeONT:
              ontDevices.add(_parseAsONT(data));
            case DeviceModelSealed.typeSwitch:
              switchDevices.add(_parseAsSwitch(data));
            case DeviceModelSealed.typeWLAN:
              wlanDevices.add(_parseAsWLAN(data));
            default:
              _logger.w('Unknown device type for id $id: $deviceType');
              failedIds.add(id);
          }
        } on Exception catch (e) {
          _logger.w('Failed to parse device $id: $e');
          failedIds.add(id);
        }
      }

      // Cache to new typed data sources
      if (apDevices.isNotEmpty) {
        await apDataSource.cacheDevices(apDevices);
        await apDataSource.flushNow();
      }
      if (ontDevices.isNotEmpty) {
        await ontDataSource.cacheDevices(ontDevices);
        await ontDataSource.flushNow();
      }
      if (switchDevices.isNotEmpty) {
        await switchDataSource.cacheDevices(switchDevices);
        await switchDataSource.flushNow();
      }
      if (wlanDevices.isNotEmpty) {
        await wlanDataSource.cacheDevices(wlanDevices);
        await wlanDataSource.flushNow();
      }

      // Clean up old cache
      await _cleanupOldCache(index);

      // Mark migration complete
      await storageService.setString(_migrationCompleteKey, 'true');

      final total = apDevices.length + ontDevices.length +
                    switchDevices.length + wlanDevices.length;

      _logger.i('Migration complete: $total devices migrated '
          '(AP: ${apDevices.length}, ONT: ${ontDevices.length}, '
          'Switch: ${switchDevices.length}, WLAN: ${wlanDevices.length})');

      return MigrationResult(
        success: true,
        migrated: true,
        message: 'Migrated $total devices',
        apCount: apDevices.length,
        ontCount: ontDevices.length,
        switchCount: switchDevices.length,
        wlanCount: wlanDevices.length,
        failedCount: failedIds.length,
      );
    } on Exception catch (e, stack) {
      _logger.e('Migration failed: $e', error: e, stackTrace: stack);
      return MigrationResult(
        success: false,
        migrated: false,
        message: 'Migration failed: $e',
      );
    }
  }

  /// Determine device type from old cache data
  String? _determineDeviceType(Map<String, dynamic> data) {
    // Check explicit type field
    final type = data['type']?.toString();
    if (type != null && DeviceModelSealed.allTypes.contains(type)) {
      return type;
    }

    // Check device_type field (used by Freezed)
    final deviceType = data['device_type']?.toString();
    if (deviceType != null && DeviceModelSealed.allTypes.contains(deviceType)) {
      return deviceType;
    }

    return null;
  }

  APModel _parseAsAP(Map<String, dynamic> data) {
    // Ensure device_type is set for Freezed
    final normalized = Map<String, dynamic>.from(data);
    normalized['device_type'] = DeviceModelSealed.typeAccessPoint;
    return APModel.fromJson(normalized);
  }

  ONTModel _parseAsONT(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    normalized['device_type'] = DeviceModelSealed.typeONT;
    return ONTModel.fromJson(normalized);
  }

  SwitchModel _parseAsSwitch(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    normalized['device_type'] = DeviceModelSealed.typeSwitch;
    return SwitchModel.fromJson(normalized);
  }

  WLANModel _parseAsWLAN(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    normalized['device_type'] = DeviceModelSealed.typeWLAN;
    return WLANModel.fromJson(normalized);
  }

  /// Clean up old cache keys
  Future<void> _cleanupOldCache(List<String> deviceIds) async {
    // Remove old index
    await storageService.remove(_oldIndexKey);
    await storageService.remove(_oldTimestampKey);

    // Remove individual device entries
    for (final id in deviceIds) {
      await storageService.remove('$_oldDeviceKeyPrefix$id');
    }

    _logger.d('Cleaned up ${deviceIds.length + 2} old cache keys');
  }

  /// Reset migration state (for testing)
  Future<void> resetMigration() async {
    await storageService.remove(_migrationCompleteKey);
  }
}

/// Result of a migration attempt
class MigrationResult {
  const MigrationResult({
    required this.success,
    required this.migrated,
    required this.message,
    this.apCount = 0,
    this.ontCount = 0,
    this.switchCount = 0,
    this.wlanCount = 0,
    this.failedCount = 0,
  });

  final bool success;
  final bool migrated;
  final String message;
  final int apCount;
  final int ontCount;
  final int switchCount;
  final int wlanCount;
  final int failedCount;

  int get totalMigrated => apCount + ontCount + switchCount + wlanCount;
}
