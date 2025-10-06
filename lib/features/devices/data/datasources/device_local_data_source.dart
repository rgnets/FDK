import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';

abstract class DeviceLocalDataSource {
  Future<List<DeviceModel>> getCachedDevices();
  Future<void> cacheDevices(List<DeviceModel> devices);
  Future<DeviceModel?> getCachedDevice(String id);
  Future<void> cacheDevice(DeviceModel device);
  Future<void> clearCache();
  Future<bool> isCacheValid();
  Future<void> updateCachePartial(List<DeviceModel> devices, {required int offset});
  Future<List<DeviceModel>> getCachedDevicesPage({required int offset, required int limit});
}

class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  const DeviceLocalDataSourceImpl({
    required this.storageService,
  });

  final StorageService storageService;
  static final _logger = Logger();
  static const String _devicesKey = 'cached_devices';
  static const String _deviceKeyPrefix = 'cached_device_';
  static const String _cacheTimestampKey = 'devices_cache_timestamp';
  static const String _deviceIndexKey = 'device_index';
  static const Duration _cacheValidityDuration = Duration(minutes: 30);

  @override
  Future<bool> isCacheValid() async {
    try {
      final timestampStr = storageService.getString(_cacheTimestampKey);
      if (timestampStr == null) {
        return false;
      }
      
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);
      
      return difference < _cacheValidityDuration;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Future<List<DeviceModel>> getCachedDevices() async {
    try {
      // Check if cache is valid
      if (!await isCacheValid()) {
        _logger.d('Cache expired or invalid');
        return [];
      }
      
      // Try to load from indexed cache first (more efficient)
      final indexJson = storageService.getString(_deviceIndexKey);
      if (indexJson != null) {
        final index = json.decode(indexJson) as List<dynamic>;
        final devices = <DeviceModel>[];
        
        // Load devices in batches to avoid memory issues
        const batchSize = 100;
        for (var i = 0; i < index.length; i += batchSize) {
          final batch = index.skip(i).take(batchSize);
          final futures = batch.map((id) async {
            final deviceJson = storageService.getString('$_deviceKeyPrefix$id');
            if (deviceJson != null) {
              return DeviceModel.fromJson(json.decode(deviceJson) as Map<String, dynamic>);
            }
            return null;
          });
          
          final batchDevices = await Future.wait(futures);
          devices.addAll(batchDevices.whereType<DeviceModel>());
        }
        
        _logger.d('Loaded ${devices.length} devices from indexed cache');
        return devices;
      }
      
      // Fallback to old cache format
      final devicesJson = storageService.getString(_devicesKey);
      if (devicesJson != null) {
        final devicesList = json.decode(devicesJson) as List<dynamic>;
        return devicesList
            .map((json) => DeviceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on Exception catch (e) {
      _logger.e('Failed to get cached devices: $e');
      return [];
    }
  }

  @override
  Future<void> cacheDevices(List<DeviceModel> devices) async {
    try {
      // Update timestamp
      await storageService.setString(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );
      
      // Store device index for efficient loading
      final index = devices.map((d) => d.id).toList();
      await storageService.setString(_deviceIndexKey, json.encode(index));
      
      // Store devices individually for better performance
      // Use batching to avoid overwhelming storage
      const batchSize = 50;
      for (var i = 0; i < devices.length; i += batchSize) {
        final batch = devices.skip(i).take(batchSize);
        final futures = batch.map((device) async {
          final deviceJson = json.encode(device.toJson());
          await storageService.setString('$_deviceKeyPrefix${device.id}', deviceJson);
        });
        await Future.wait(futures);
      }
      
      _logger.d('Cached ${devices.length} devices with indexed storage');
    } on Exception catch (e) {
      _logger.e('Failed to cache devices: $e');
    }
  }

  @override
  Future<void> updateCachePartial(List<DeviceModel> devices, {required int offset}) async {
    try {
      // Get existing index
      final indexJson = storageService.getString(_deviceIndexKey);
      final index = indexJson != null 
          ? (json.decode(indexJson) as List<dynamic>).cast<String>()
          : <String>[];
      
      // Update index with new devices
      for (final device in devices) {
        if (!index.contains(device.id)) {
          index.add(device.id);
        }
        // Store device
        final deviceJson = json.encode(device.toJson());
        await storageService.setString('$_deviceKeyPrefix${device.id}', deviceJson);
      }
      
      // Update index
      await storageService.setString(_deviceIndexKey, json.encode(index));
      
      // Update timestamp
      await storageService.setString(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );
      
      _logger.d('Updated cache with ${devices.length} devices at offset $offset');
    } on Exception catch (e) {
      _logger.e('Failed to update cache partially: $e');
    }
  }

  @override
  Future<List<DeviceModel>> getCachedDevicesPage({
    required int offset, 
    required int limit,
  }) async {
    try {
      // Check if cache is valid
      if (!await isCacheValid()) {
        return [];
      }
      
      final indexJson = storageService.getString(_deviceIndexKey);
      if (indexJson == null) {
        return [];
      }
      
      final index = (json.decode(indexJson) as List<dynamic>).cast<String>();
      
      // Get page of devices
      final pageIds = index.skip(offset).take(limit);
      final devices = <DeviceModel>[];
      
      for (final id in pageIds) {
        final deviceJson = storageService.getString('$_deviceKeyPrefix$id');
        if (deviceJson != null) {
          devices.add(DeviceModel.fromJson(
            json.decode(deviceJson) as Map<String, dynamic>,
          ));
        }
      }
      
      return devices;
    } on Exception catch (e) {
      _logger.e('Failed to get cached devices page: $e');
      return [];
    }
  }

  @override
  Future<DeviceModel?> getCachedDevice(String id) async {
    try {
      final deviceJson = storageService.getString('$_deviceKeyPrefix$id');
      if (deviceJson != null) {
        final deviceMap = json.decode(deviceJson) as Map<String, dynamic>;
        return DeviceModel.fromJson(deviceMap);
      }
      return null;
    } on Exception catch (e) {
      _logger.e('Failed to get cached device: $e');
      return null;
    }
  }

  @override
  Future<void> cacheDevice(DeviceModel device) async {
    try {
      final deviceJson = json.encode(device.toJson());
      await storageService.setString('$_deviceKeyPrefix${device.id}', deviceJson);
      
      // Update index if needed
      final indexJson = storageService.getString(_deviceIndexKey);
      if (indexJson != null) {
        final index = (json.decode(indexJson) as List<dynamic>).cast<String>();
        if (!index.contains(device.id)) {
          index.add(device.id);
          await storageService.setString(_deviceIndexKey, json.encode(index));
        }
      }
    } on Exception catch (e) {
      _logger.e('Failed to cache device: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Clear main cache
      await storageService.remove(_devicesKey);
      await storageService.remove(_cacheTimestampKey);
      await storageService.remove(_deviceIndexKey);
      
      // Clear individual device caches
      // Note: This would require tracking all keys, which we'll skip for now
      // In production, you might want to use a database like SQLite for better management
      
      _logger.i('Cache cleared');
    } on Exception catch (e) {
      _logger.e('Failed to clear cache: $e');
    }
  }
}