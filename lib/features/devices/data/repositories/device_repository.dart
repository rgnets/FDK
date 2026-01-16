import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/services/pagination_service.dart';
import 'package:rgnets_fdk/core/services/performance_monitor_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/typed_device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl({
    required this.dataSource,
    required this.apLocalDataSource,
    required this.ontLocalDataSource,
    required this.switchLocalDataSource,
    required this.wlanLocalDataSource,
    required this.storageService,
    this.webSocketCacheIntegration,
  }) {
    _logger.i('DEVICE_REPOSITORY: Constructor called');

    // Load ID-to-Type index from storage
    _loadIdToTypeIndex();

    // Initialize pagination service for incremental loading
    _initializePaginationService();

    // Listen to WebSocket device updates
    _setupWebSocketListener();
  }

  static final _logger = Logger();

  final DeviceDataSource dataSource;
  final APLocalDataSource apLocalDataSource;
  final ONTLocalDataSource ontLocalDataSource;
  final SwitchLocalDataSource switchLocalDataSource;
  final WLANLocalDataSource wlanLocalDataSource;
  final StorageService storageService;
  final WebSocketCacheIntegration? webSocketCacheIntegration;

  /// ID-to-Type index for routing device lookups
  Map<String, String> _idToTypeIndex = {};

  void _loadIdToTypeIndex() {
    final indexJson = storageService.getString(DeviceModelSealed.idTypeIndexKey);
    if (indexJson != null) {
      try {
        _idToTypeIndex = Map<String, String>.from(
          json.decode(indexJson) as Map<String, dynamic>,
        );
        _logger.d('Loaded ID-to-Type index with ${_idToTypeIndex.length} entries');
      } on Exception catch (e) {
        _logger.w('Failed to load ID-to-Type index: $e');
      }
    }
  }

  // ============================================================================
  // Typed Cache Aggregation Helpers
  // ============================================================================

  /// Get all devices from all 4 typed caches
  Future<List<DeviceModelSealed>> _getAllCachedDevices({bool allowStale = false}) async {
    final results = await Future.wait([
      apLocalDataSource.getCachedDevices(allowStale: allowStale),
      ontLocalDataSource.getCachedDevices(allowStale: allowStale),
      switchLocalDataSource.getCachedDevices(allowStale: allowStale),
      wlanLocalDataSource.getCachedDevices(allowStale: allowStale),
    ]);
    return [
      ...results[0],
      ...results[1],
      ...results[2],
      ...results[3],
    ];
  }

  /// Get a single device by ID using the ID-to-Type index
  Future<DeviceModelSealed?> _getCachedDeviceById(String id) async {
    final deviceType = _idToTypeIndex[id];

    // Route to the correct typed cache
    switch (deviceType) {
      case DeviceModelSealed.typeAccessPoint:
        return apLocalDataSource.getCachedDevice(id);
      case DeviceModelSealed.typeONT:
        return ontLocalDataSource.getCachedDevice(id);
      case DeviceModelSealed.typeSwitch:
        return switchLocalDataSource.getCachedDevice(id);
      case DeviceModelSealed.typeWLAN:
        return wlanLocalDataSource.getCachedDevice(id);
      default:
        // Fallback: search all caches
        return _searchAllCachesForDevice(id);
    }
  }

  /// Search all caches for a device (fallback when not in index)
  Future<DeviceModelSealed?> _searchAllCachesForDevice(String id) async {
    final ap = await apLocalDataSource.getCachedDevice(id);
    if (ap != null) {
      return ap;
    }

    final ont = await ontLocalDataSource.getCachedDevice(id);
    if (ont != null) {
      return ont;
    }

    final sw = await switchLocalDataSource.getCachedDevice(id);
    if (sw != null) {
      return sw;
    }

    final wlan = await wlanLocalDataSource.getCachedDevice(id);
    if (wlan != null) {
      return wlan;
    }

    return null;
  }

  /// Check if any cache is valid
  Future<bool> _isAnyCacheValid() async {
    final results = await Future.wait([
      apLocalDataSource.isCacheValid(),
      ontLocalDataSource.isCacheValid(),
      switchLocalDataSource.isCacheValid(),
      wlanLocalDataSource.isCacheValid(),
    ]);
    return results.any((valid) => valid);
  }

  /// Cache a list of devices to their appropriate typed caches
  Future<void> _cacheDevicesToTypedCaches(List<DeviceModelSealed> devices) async {
    final apDevices = <APModel>[];
    final ontDevices = <ONTModel>[];
    final switchDevices = <SwitchModel>[];
    final wlanDevices = <WLANModel>[];

    for (final device in devices) {
      switch (device) {
        case APModel():
          apDevices.add(device);
          _idToTypeIndex[device.deviceId] = DeviceModelSealed.typeAccessPoint;
        case ONTModel():
          ontDevices.add(device);
          _idToTypeIndex[device.deviceId] = DeviceModelSealed.typeONT;
        case SwitchModel():
          switchDevices.add(device);
          _idToTypeIndex[device.deviceId] = DeviceModelSealed.typeSwitch;
        case WLANModel():
          wlanDevices.add(device);
          _idToTypeIndex[device.deviceId] = DeviceModelSealed.typeWLAN;
      }
    }

    await Future.wait([
      if (apDevices.isNotEmpty) apLocalDataSource.cacheDevices(apDevices),
      if (ontDevices.isNotEmpty) ontLocalDataSource.cacheDevices(ontDevices),
      if (switchDevices.isNotEmpty) switchLocalDataSource.cacheDevices(switchDevices),
      if (wlanDevices.isNotEmpty) wlanLocalDataSource.cacheDevices(wlanDevices),
    ]);

    // Persist the ID-to-Type index
    _persistIdToTypeIndex();
  }

  /// Cache a single device to the appropriate typed cache
  Future<void> _cacheDeviceToTypedCache(DeviceModelSealed device) async {
    switch (device) {
      case APModel():
        await apLocalDataSource.cacheDevice(device);
        _idToTypeIndex[device.deviceId] = DeviceModelSealed.typeAccessPoint;
      case ONTModel():
        await ontLocalDataSource.cacheDevice(device);
        _idToTypeIndex[device.deviceId] = DeviceModelSealed.typeONT;
      case SwitchModel():
        await switchLocalDataSource.cacheDevice(device);
        _idToTypeIndex[device.deviceId] = DeviceModelSealed.typeSwitch;
      case WLANModel():
        await wlanLocalDataSource.cacheDevice(device);
        _idToTypeIndex[device.deviceId] = DeviceModelSealed.typeWLAN;
    }
    _persistIdToTypeIndex();
  }

  /// Persist the ID-to-Type index to storage
  void _persistIdToTypeIndex() {
    storageService.setString(
      DeviceModelSealed.idTypeIndexKey,
      json.encode(_idToTypeIndex),
    );
  }

  /// Convert old DeviceModel to new DeviceModelSealed
  /// This bridges the gap between the old data source and new typed caches
  DeviceModelSealed _convertToSealed(DeviceModel model) {
    final json = model.toJson();
    // Ensure device_type is set for Freezed discriminator
    if (!json.containsKey('device_type')) {
      json['device_type'] = model.type;
    }
    return DeviceModelSealed.fromJson(json);
  }

  // Pagination service for efficient loading
  late final PaginationService<Device> _paginationService;
  
  // Stream controllers for real-time updates
  final _devicesStreamController = StreamController<List<Device>>.broadcast();
  Stream<List<Device>> get devicesStream => _devicesStreamController.stream;

  // Store latest devices from WebSocket for immediate access by new subscribers
  List<Device>? _latestWebSocketDevices;

  /// Get the current devices from WebSocket cache without waiting for stream event.
  /// Returns null if no WebSocket data has been received yet.
  List<Device>? get currentDevices => _latestWebSocketDevices;
  
  void _initializePaginationService() {
    _paginationService = PaginationService<Device>(
      pageSize: 100,
      fetchPage: (page, pageSize) async {
        // For now, we'll load all devices and simulate pagination
        // In production, this would call paginated API endpoints
        if (page > 1) {
          return [];
        }
        
        final result = await getDevices();
        return result.fold(
          (failure) => [],
          (devices) => devices,
        );
      },
      cachePages: true,
    );
    
    // Listen to pagination state changes
    _paginationService.stateStream.listen((state) {
      _devicesStreamController.add(state.items);
    });
  }

  void _setupWebSocketListener() {
    webSocketCacheIntegration?.onDeviceData((resourceType, devices) {
      _logger.i(
        'DeviceRepositoryImpl: Received $resourceType data via WebSocket: ${devices.length} devices',
      );

      // Convert to Device entities and update stream
      final allModels = webSocketCacheIntegration!.getAllCachedDeviceModels();
      final allDevices = allModels.map((model) => model.toEntity()).toList();

      _logger.i(
        'DeviceRepositoryImpl: Total devices from WebSocket cache: ${allDevices.length}',
      );

      // Store for immediate access by new subscribers (fixes broadcast stream race condition)
      _latestWebSocketDevices = allDevices;

      // Update the stream with new data
      _devicesStreamController.add(allDevices);

      // Note: WebSocketDataSyncService now handles caching to typed data sources
    });
  }

  @override
  Future<Either<Failure, List<Device>>> getDevices({
    List<String>? fields,
  }) async {
    return PerformanceMonitorService.instance.trackFuture(
      'DeviceRepository.getDevices',
      () => _getDevicesImpl(fields: fields),
    );
  }
  
  Future<Either<Failure, List<Device>>> _getDevicesImpl({
    List<String>? fields,
  }) async {
    try {
      _logger.i('🔍 DEVICE_REPOSITORY: getDevices() called at ${DateTime.now().toIso8601String()}');

      if (!_isAuthenticated()) {
        _logger.w('DeviceRepositoryImpl: Skipping getDevices (not authenticated)');
        return const Right(<Device>[]);
      }

      // Try WebSocket cache first
      if (webSocketCacheIntegration != null) {
        final wsModels = webSocketCacheIntegration!.getAllCachedDeviceModels();
        if (wsModels.isNotEmpty) {
          _logger.i(
            'DeviceRepositoryImpl: Using ${wsModels.length} devices from WebSocket cache',
          );
          final devices = wsModels.map((model) => model.toEntity()).toList();
          return Right(devices);
        }
        _logger.d('DeviceRepositoryImpl: WebSocket cache empty, trying other sources');
      }

      // Try to use cached data first if valid
      if (await _isAnyCacheValid()) {
        _logger.i('DeviceRepositoryImpl: Cache is valid, loading from cache');
        final cachedModels = await _getAllCachedDevices();
        if (cachedModels.isNotEmpty) {
          final devices = cachedModels.map((model) => model.toEntity()).toList();
          _logger.i('DeviceRepositoryImpl: Loaded ${devices.length} devices from cache');

          // Start background refresh for fresh data
          unawaited(_refreshInBackground());

          return Right(devices);
        }
      }
      
      _logger.i('DeviceRepositoryImpl: Fetching from data source');
      
      // Use data source (mock or remote based on provider configuration)
      final deviceModels = await PerformanceMonitorService.instance.trackFuture(
        'DeviceRepository.fetchData',
        () => dataSource.getDevices(fields: fields),
        metadata: {'source': 'dataSource', 'fields': fields?.join(',')},
      );
      _logger.i('DeviceRepositoryImpl: Got ${deviceModels.length} device models from remote data source');
      
      // Cache in background to avoid blocking
      unawaited(PerformanceMonitorService.instance.trackFuture(
        'DeviceRepository.cache',
        () => _cacheDevicesToTypedCaches(
          deviceModels.map(_convertToSealed).toList(),
        ),
        metadata: {'count': deviceModels.length},
      ));
      
      final devices = deviceModels.map((model) => model.toEntity()).toList();

      _logger.i('DeviceRepositoryImpl: Successfully converted to ${devices.length} Device entities');
      
      return Right(devices);
    } on Object catch (e) {
      // Catch both Exception and Error (e.g., StateError from WebSocket)
      _logger
        ..e('DeviceRepositoryImpl: Data source failed - $e')
        ..d('DeviceRepositoryImpl: Trying cache fallback');
      try {
        // Fallback to cached data ONLY in development/production
        final cachedModels = await _getAllCachedDevices(allowStale: true);
        final devices = cachedModels.map((model) => model.toEntity()).toList();
        _logger.i('DeviceRepositoryImpl: Fallback successful, returning ${devices.length} cached devices');
        return Right(devices);
      } on Object {
        _logger.e('DeviceRepositoryImpl: Cache fallback also failed');
        return Left(DeviceFailure(message: 'Failed to get devices: $e'));
      }
    }
  }
  
  /// Refresh data in background without blocking UI
  Future<void> _refreshInBackground() async {
    try {
      if (!_isAuthenticated()) {
        _logger.d('DeviceRepositoryImpl: Skipping background refresh (not authenticated)');
        return;
      }
      _logger.d('DeviceRepositoryImpl: Starting background refresh');
      final deviceModels = await dataSource.getDevices();
      await _cacheDevicesToTypedCaches(
        deviceModels.map(_convertToSealed).toList(),
      );

      // Update stream with fresh data
      final devices = deviceModels.map((model) => model.toEntity()).toList();
      _devicesStreamController.add(devices);

      _logger.i('DeviceRepositoryImpl: Background refresh completed with ${devices.length} devices');
    } on Exception catch (e) {
      _logger.e('DeviceRepositoryImpl: Background refresh failed: $e');
    }
  }

  @override
  Future<Either<Failure, Device>> getDevice(
    String id, {
    List<String>? fields,
  }) async {
    try {
      if (!_isAuthenticated()) {
        return const Left(DeviceFailure(message: 'Not authenticated'));
      }
      // Use data source
      final deviceModel = await dataSource.getDevice(id, fields: fields);
      final sealedModel = _convertToSealed(deviceModel);
      await _cacheDeviceToTypedCache(sealedModel);
      return Right(deviceModel.toEntity());
    } on Object catch (e) {
      // Catch both Exception and Error (e.g., StateError from WebSocket)
      _logger.w('DeviceRepositoryImpl: getDevice failed, trying cache fallback: $e');
      try {
        // Fallback to cached data using ID-to-Type index
        final cachedModel = await _getCachedDeviceById(id);
        if (cachedModel != null) {
          _logger.i('DeviceRepositoryImpl: Found device $id in local cache');
          return Right(cachedModel.toEntity());
        }
        return Left(DeviceFailure(message: 'Device not found: $id'));
      } on Object {
        return Left(DeviceFailure(message: 'Failed to get device: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Device>>> getDevicesByRoom(String roomId) async {
    try {
      if (!_isAuthenticated()) {
        return const Right(<Device>[]);
      }
      // Use data source
      final deviceModels = await dataSource.getDevicesByRoom(roomId);
      final devices = deviceModels.map((model) => model.toEntity()).toList();
      return Right(devices);
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to get devices by room: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Device>>> searchDevices(String query) async {
    try {
      if (!_isAuthenticated()) {
        return const Right(<Device>[]);
      }
      final deviceModels = await dataSource.searchDevices(query);
      final devices = deviceModels.map((model) => model.toEntity()).toList();
      return Right(devices);
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to search devices: $e'));
    }
  }

  @override
  Future<Either<Failure, Device>> updateDevice(Device device) async {
    try {
      if (!_isAuthenticated()) {
        return const Left(DeviceFailure(message: 'Not authenticated'));
      }
      final deviceModel = DeviceModel(
        id: device.id,
        name: device.name,
        type: device.type,
        status: device.status,
        ipAddress: device.ipAddress,
        macAddress: device.macAddress,
        location: device.location,
        lastSeen: device.lastSeen,
        metadata: device.metadata,
        model: device.model,
        serialNumber: device.serialNumber,
        firmware: device.firmware,
        signalStrength: device.signalStrength,
        uptime: device.uptime,
        connectedClients: device.connectedClients,
        vlan: device.vlan,
        ssid: device.ssid,
        channel: device.channel,
        totalUpload: device.totalUpload,
        totalDownload: device.totalDownload,
        currentUpload: device.currentUpload,
        currentDownload: device.currentDownload,
        packetLoss: device.packetLoss,
        latency: device.latency,
        cpuUsage: device.cpuUsage,
        memoryUsage: device.memoryUsage,
        temperature: device.temperature,
        restartCount: device.restartCount,
        maxClients: device.maxClients,
      );
      final updatedModel = await dataSource.updateDevice(deviceModel);
      final sealedModel = _convertToSealed(updatedModel);
      await _cacheDeviceToTypedCache(sealedModel);
      return Right(updatedModel.toEntity());
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to update device: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rebootDevice(String deviceId) async {
    try {
      await dataSource.rebootDevice(deviceId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to reboot device: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetDevice(String deviceId) async {
    try {
      await dataSource.resetDevice(deviceId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to reset device: $e'));
    }
  }

  @override
  Future<Either<Failure, Device>> deleteDeviceImage(
    String deviceId,
    String imageUrl,
  ) async {
    try {
      if (!_isAuthenticated()) {
        return const Left(DeviceFailure(message: 'Not authenticated'));
      }
      final updatedModel = await dataSource.deleteDeviceImage(
        deviceId,
        imageUrl,
      );
      final sealedModel = _convertToSealed(updatedModel);
      await _cacheDeviceToTypedCache(sealedModel);
      return Right(updatedModel.toEntity());
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to delete device image: $e'));
    }
  }

  /// Dispose resources
  void dispose() {
    _paginationService.dispose();
    _devicesStreamController.close();
  }

  bool _isAuthenticated() {
    if (EnvironmentConfig.isDevelopment) {
      return true;
    }
    return storageService.isAuthenticated;
  }
}
