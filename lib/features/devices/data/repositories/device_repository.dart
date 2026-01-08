import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/services/pagination_service.dart';
import 'package:rgnets_fdk/core/services/performance_monitor_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_local_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/datasources/device_data_source.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl({
    required this.localDataSource,
    required this.storageService,
    required this.mockDataSource,
  }) {
    _logger.i('DEVICE_REPOSITORY: Constructor called');
    
    // Initialize pagination service for incremental loading
    _initializePaginationService();
  }
  
  static final _logger = LoggerConfig.getLogger();
  
  final DeviceLocalDataSource localDataSource;
  final StorageService storageService;
  final DeviceDataSource mockDataSource;
  
  
  // Pagination service for efficient loading
  late final PaginationService<Device> _paginationService;
  
  // Stream controllers for real-time updates
  final _devicesStreamController = StreamController<List<Device>>.broadcast();
  Stream<List<Device>> get devicesStream => _devicesStreamController.stream;
  
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

      if (EnvironmentConfig.useSyntheticData) {
        _logger.i('DeviceRepositoryImpl: Synthetic mode, loading mock data');
        final deviceModels = await mockDataSource.getDevices(fields: fields);
        await localDataSource.cacheDevices(deviceModels);
        return Right(deviceModels.map((model) => model.toEntity()).toList());
      }

      final cachedModels = await localDataSource.getCachedDevices(
        allowStale: true,
      );
      if (cachedModels.isNotEmpty) {
        final devices = cachedModels.map((model) => model.toEntity()).toList();
        _logger.i('DeviceRepositoryImpl: Loaded ${devices.length} devices from cache');
        return Right(devices);
      }

      _logger.w('DeviceRepositoryImpl: No cached devices available');
      return const Right(<Device>[]);
    } on Exception catch (e) {
      _logger.e('DeviceRepositoryImpl: Failed to get devices - $e');
      return Left(DeviceFailure(message: 'Failed to get devices: $e'));
    }
  }

  @override
  Future<Either<Failure, Device>> getDevice(
    String id, {
    List<String>? fields,
  }) async {
    try {
      if (!_isAuthenticated()) {
        return Left(DeviceFailure(message: 'Not authenticated'));
      }
      final cachedModel = await localDataSource.getCachedDevice(id);
      if (cachedModel != null) {
        return Right(cachedModel.toEntity());
      }
      return Left(DeviceFailure(message: 'Device not found: $id'));
    } on Exception catch (e) {
      try {
        // Fallback to cached data
        final cachedModel = await localDataSource.getCachedDevice(id);
        if (cachedModel != null) {
          return Right(cachedModel.toEntity());
        }
        return Left(DeviceFailure(message: 'Device not found: $id'));
      } on Exception {
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
      final cachedModels = await localDataSource.getCachedDevices(
        allowStale: true,
      );
      final devices = cachedModels
          .map((model) => model.toEntity())
          .where((device) {
            final location = device.location ?? '';
            final metadata = device.metadata ?? {};
            final roomIdStr = metadata['room_id']?.toString() ?? '';
            final room = metadata['room']?.toString() ?? '';
            return location == roomId ||
                roomIdStr == roomId ||
                room == roomId;
          })
          .toList();
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
      final cachedModels = await localDataSource.getCachedDevices(
        allowStale: true,
      );
      final lowerQuery = query.toLowerCase();
      final devices = cachedModels
          .map((model) => model.toEntity())
          .where((device) {
            return device.name.toLowerCase().contains(lowerQuery) ||
                device.id.toLowerCase().contains(lowerQuery) ||
                (device.serialNumber?.toLowerCase().contains(lowerQuery) ??
                    false) ||
                (device.macAddress?.toLowerCase().contains(lowerQuery) ??
                    false);
          })
          .toList();
      return Right(devices);
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to search devices: $e'));
    }
  }

  @override
  Future<Either<Failure, Device>> updateDevice(Device device) async {
    try {
      if (!_isAuthenticated()) {
        return Left(DeviceFailure(message: 'Not authenticated'));
      }
      return Left(
        const DeviceFailure(
          message: 'Device updates are not supported without REST',
        ),
      );
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to update device: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rebootDevice(String deviceId) async {
    try {
      return Left(
        const DeviceFailure(
          message: 'Device reboot is not supported without REST',
        ),
      );
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to reboot device: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetDevice(String deviceId) async {
    try {
      return Left(
        const DeviceFailure(
          message: 'Device reset is not supported without REST',
        ),
      );
    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to reset device: $e'));
    }
  }
  
  /// Dispose resources
  void dispose() {
    _paginationService.dispose();
    _devicesStreamController.close();
  }

  bool _isAuthenticated() {
    if (EnvironmentConfig.useSyntheticData) {
      return true;
    }
    return storageService.isAuthenticated;
  }

}
