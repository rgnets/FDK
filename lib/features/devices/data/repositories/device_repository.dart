import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/services/pagination_service.dart';
import 'package:rgnets_fdk/core/services/performance_monitor_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl({
    required this.dataSource,
    required this.localDataSource,
    required this.storageService,
    this.webSocketCacheIntegration,
  }) {
    _logger.i('DEVICE_REPOSITORY: Constructor called');

    // Initialize pagination service for incremental loading
    _initializePaginationService();

    // Listen to WebSocket device updates
    _setupWebSocketListener();
  }

  static final _logger = Logger();

  final DeviceDataSource dataSource;
  final DeviceLocalDataSource localDataSource;
  final StorageService storageService;
  final WebSocketCacheIntegration? webSocketCacheIntegration;
  
  
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

      // Also cache locally for offline access
      unawaited(localDataSource.cacheDevices(allModels));
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
      if (await localDataSource.isCacheValid()) {
        _logger.i('DeviceRepositoryImpl: Cache is valid, loading from cache');
        final cachedModels = await localDataSource.getCachedDevices();
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
        () => localDataSource.cacheDevices(deviceModels),
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
        final cachedModels = await localDataSource.getCachedDevices();
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
      await localDataSource.cacheDevices(deviceModels);
      
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
    bool forceRefresh = false,
  }) async {
    try {
      if (!_isAuthenticated()) {
        return const Left(DeviceFailure(message: 'Not authenticated'));
      }
      // Use data source
      final deviceModel = await dataSource.getDevice(
        id,
        fields: fields,
        forceRefresh: forceRefresh,
      );
      await localDataSource.cacheDevice(deviceModel);
      return Right(deviceModel.toEntity());
    } on Object catch (e) {
      // Catch both Exception and Error (e.g., StateError from WebSocket)
      _logger.w('DeviceRepositoryImpl: getDevice failed, trying cache fallback: $e');
      try {
        // Fallback to cached data
        final cachedModel = await localDataSource.getCachedDevice(id);
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
      await localDataSource.cacheDevice(updatedModel);
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
    String signedIdToDelete,
  ) async {
    print('=== REPOSITORY DELETE IMAGE ===');
    print('DeviceRepositoryImpl: deleteDeviceImage called for $deviceId, signedId: $signedIdToDelete');
    _logger.i('DeviceRepositoryImpl: deleteDeviceImage called for $deviceId, signedId: $signedIdToDelete');
    try {
      if (!_isAuthenticated()) {
        _logger.w('DeviceRepositoryImpl: Not authenticated');
        return const Left(DeviceFailure(message: 'Not authenticated'));
      }
      _logger.i('DeviceRepositoryImpl: Calling dataSource.deleteDeviceImage');
      final updatedModel = await dataSource.deleteDeviceImage(
        deviceId,
        signedIdToDelete,
      );
      _logger.i('DeviceRepositoryImpl: Delete successful, caching device');
      await localDataSource.cacheDevice(updatedModel);
      return Right(updatedModel.toEntity());
    } on Exception catch (e) {
      _logger.e('DeviceRepositoryImpl: Failed to delete device image: $e');
      return Left(DeviceFailure(message: 'Failed to delete device image: $e'));
    }
  }

  @override
  Future<Either<Failure, Device>> uploadDeviceImages(
    String deviceId,
    List<String> base64Images,
  ) async {
    try {
      if (!_isAuthenticated()) {
        return const Left(DeviceFailure(message: 'Not authenticated'));
      }
      _logger.i('DeviceRepositoryImpl: Uploading ${base64Images.length} images to $deviceId');
      final updatedModel = await dataSource.uploadDeviceImages(
        deviceId,
        base64Images,
      );
      await localDataSource.cacheDevice(updatedModel);
      _logger.i('DeviceRepositoryImpl: Successfully uploaded images to $deviceId');
      return Right(updatedModel.toEntity());
    } on Exception catch (e) {
      _logger.e('DeviceRepositoryImpl: Failed to upload images: $e');
      return Left(DeviceFailure(message: 'Failed to upload device images: $e'));
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
