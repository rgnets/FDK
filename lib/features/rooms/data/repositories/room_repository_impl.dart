import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_local_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_mock_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_remote_data_source.dart';
import 'package:rgnets_fdk/features/rooms/data/models/room_model.dart';
import 'package:rgnets_fdk/features/rooms/domain/entities/room.dart';
import 'package:rgnets_fdk/features/rooms/domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  const RoomRepositoryImpl({
    required this.remoteDataSource,
    required this.mockDataSource,
    this.localDataSource,
  });
  
  static final _logger = LoggerConfig.getLogger();
  final RoomRemoteDataSource remoteDataSource;
  final RoomMockDataSource mockDataSource;
  final RoomLocalDataSource? localDataSource;
  
  @override
  Future<Either<Failure, List<Room>>> getRooms() async {
    try {
      _logger
        ..i('RoomRepositoryImpl.getRooms() called')
        ..i('Environment check: isDevelopment=${EnvironmentConfig.isDevelopment}, isStaging=${EnvironmentConfig.isStaging}, isProduction=${EnvironmentConfig.isProduction}');
      // Try to use cached data first if valid (except in synthetic mode)
      if (localDataSource != null && !EnvironmentConfig.useSyntheticData) {
        final isValid = await localDataSource!.isCacheValid();
        if (isValid) {
          _logger.i('RoomRepositoryImpl: Cache is valid, loading from cache');
          final cachedRooms = await localDataSource!.getCachedRooms();
          if (cachedRooms.isNotEmpty) {
            _logger.i('RoomRepositoryImpl: Loaded ${cachedRooms.length} rooms from cache');
            
            // Start background refresh for fresh data
            _refreshInBackground();
            
            return Right(_convertRoomModelsToEntities(cachedRooms));
          }
        }
      }
      
      // Synthetic data mode: use mock data
      if (EnvironmentConfig.useSyntheticData) {
        _logger.i('RoomRepositoryImpl: Using synthetic data - returning mock data');
        final roomModels = await mockDataSource.getRooms();
        final rooms = _convertRoomModelsToEntities(roomModels);
        _logger.i('RoomRepositoryImpl: Returning ${rooms.length} mock rooms');
        return Right(rooms);
      }
      
      // Staging/Production: use real API
      _logger.i('RoomRepositoryImpl: Using ${EnvironmentConfig.name.toUpperCase()} MODE - calling API');
      final roomModels = await remoteDataSource.getRooms();
      _logger.i('RoomRepositoryImpl: Got ${roomModels.length} room models from API');
      
      // Cache the results in background
      if (localDataSource != null) {
        _cacheInBackground(roomModels);
      }
      
      final rooms = _convertRoomModelsToEntities(roomModels);
      _logger.i('RoomRepositoryImpl: Successfully converted to ${rooms.length} Room entities');
      return Right(rooms);
    } on Exception catch (e) {
      _logger.e('RoomRepositoryImpl: ERROR - $e');
      
      // Try to return cached data as fallback (except in staging)
      if (localDataSource != null && !EnvironmentConfig.isStaging) {
        try {
          final cachedRooms = await localDataSource!.getCachedRooms();
          if (cachedRooms.isNotEmpty) {
            _logger.w('RoomRepositoryImpl: Returning stale cached data due to error');
            return Right(_convertRoomModelsToEntities(cachedRooms));
          }
        } on Exception catch (cacheError) {
          _logger.e('RoomRepositoryImpl: Cache fallback also failed: $cacheError');
        }
      }
      
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<Failure, Room>> getRoom(String id) async {
    try {
      _logger.i('RoomRepositoryImpl.getRoom($id) called');
      
      // Try cached data first (except in synthetic mode)
      if (localDataSource != null && !EnvironmentConfig.useSyntheticData) {
        final cachedRoom = await localDataSource!.getCachedRoom(id);
        if (cachedRoom != null && await localDataSource!.isCacheValid()) {
          _logger.i('RoomRepositoryImpl: Using cached room $id');
          return Right(_convertRoomModelToEntity(cachedRoom));
        }
      }
      
      // Synthetic data mode: use mock data
      if (EnvironmentConfig.useSyntheticData) {
        _logger.i('RoomRepositoryImpl: Using mock data for room $id');
        final roomModel = await mockDataSource.getRoom(id);
        return Right(_convertRoomModelToEntity(roomModel));
      }
      
      // Staging/Production: use real API
      _logger.i('RoomRepositoryImpl: Fetching room $id from API');
      final roomModel = await remoteDataSource.getRoom(id);
      
      // Cache the result
      if (localDataSource != null) {
        unawaited(localDataSource!.cacheRoom(roomModel));
      }
      
      return Right(_convertRoomModelToEntity(roomModel));
    } on Exception catch (e) {
      _logger.e('RoomRepositoryImpl: Error getting room $id: $e');
      
      // Try cached fallback (except in staging)
      if (localDataSource != null && !EnvironmentConfig.isStaging) {
        final cachedRoom = await localDataSource!.getCachedRoom(id);
        if (cachedRoom != null) {
          _logger.w('RoomRepositoryImpl: Returning cached room $id due to error');
          return Right(_convertRoomModelToEntity(cachedRoom));
        }
      }
      
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<Failure, Room>> createRoom(Room room) async {
    try {
      _logger.i('RoomRepositoryImpl.createRoom(${room.name}) called');
      
      final roomModel = _convertEntityToRoomModel(room);
      
      // Synthetic data mode: use mock data source
      if (EnvironmentConfig.useSyntheticData) {
        final createdRoom = await mockDataSource.createRoom(roomModel);
        return Right(_convertRoomModelToEntity(createdRoom));
      }
      
      // Staging/Production: use real API
      final createdRoom = await remoteDataSource.createRoom(roomModel);
      
      // Update cache
      if (localDataSource != null) {
        unawaited(localDataSource!.cacheRoom(createdRoom));
      }
      
      return Right(_convertRoomModelToEntity(createdRoom));
    } on Exception catch (e) {
      _logger.e('RoomRepositoryImpl: Error creating room: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<Failure, Room>> updateRoom(Room room) async {
    try {
      _logger.i('RoomRepositoryImpl.updateRoom(${room.id}) called');
      
      final roomModel = _convertEntityToRoomModel(room);
      
      // Synthetic data mode: use mock data source
      if (EnvironmentConfig.useSyntheticData) {
        final updatedRoom = await mockDataSource.updateRoom(roomModel);
        return Right(_convertRoomModelToEntity(updatedRoom));
      }
      
      // Staging/Production: use real API
      final updatedRoom = await remoteDataSource.updateRoom(roomModel);
      
      // Update cache
      if (localDataSource != null) {
        unawaited(localDataSource!.cacheRoom(updatedRoom));
      }
      
      return Right(_convertRoomModelToEntity(updatedRoom));
    } on Exception catch (e) {
      _logger.e('RoomRepositoryImpl: Error updating room: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteRoom(String id) async {
    try {
      _logger.i('RoomRepositoryImpl.deleteRoom($id) called');
      
      // Synthetic data mode: use mock data source
      if (EnvironmentConfig.useSyntheticData) {
        await mockDataSource.deleteRoom(id);
        return const Right(null);
      }
      
      // Staging/Production: use real API
      await remoteDataSource.deleteRoom(id);
      
      // Remove from cache
      if (localDataSource != null) {
        // Note: RoomLocalDataSource doesn't have a removeRoom method
        // In a full implementation, you might want to add this
      }
      
      return const Right(null);
    } on Exception catch (e) {
      _logger.e('RoomRepositoryImpl: Error deleting room: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Helper methods for conversion and error handling
  
  /// Convert RoomModel list to Room entity list
  List<Room> _convertRoomModelsToEntities(List<RoomModel> models) {
    return models.map(_convertRoomModelToEntity).toList();
  }
  
  /// Convert RoomModel to Room entity
  Room _convertRoomModelToEntity(RoomModel model) {
    return Room(
      id: model.id,
      name: model.name,
      roomNumber: model.roomNumber,
      description: model.metadata?['description'] as String?,
      location: model.metadata?['location'] as String?,
      deviceIds: model.deviceIds,
      metadata: model.metadata,
      updatedAt: model.metadata?['updatedAt'] != null 
          ? DateTime.tryParse(model.metadata!['updatedAt'] as String)
          : null,
    );
  }
  
  /// Convert Room entity to RoomModel
  RoomModel _convertEntityToRoomModel(Room room) {
    return RoomModel(
      id: room.id,
      name: room.name,
      roomNumber: room.roomNumber,
      deviceIds: room.deviceIds,
      metadata: {
        if (room.description != null) 'description': room.description,
        if (room.location != null) 'location': room.location,
        if (room.createdAt != null) 'createdAt': room.createdAt!.toIso8601String(),
        if (room.updatedAt != null) 'updatedAt': room.updatedAt!.toIso8601String(),
        if (room.metadata != null) ...room.metadata!,
      },
    );
  }
  
  /// Map exceptions to appropriate Failure types
  Failure _mapExceptionToFailure(Exception exception) {
    final message = exception.toString();
    
    if (message.contains('404') || message.contains('not found')) {
      return NotFoundFailure(message: 'Room not found: $exception');
    } else if (message.contains('network') || message.contains('connection')) {
      return NetworkFailure(message: 'Network error: $exception');
    } else if (message.contains('server') || message.contains('500')) {
      return ServerFailure(message: 'Server error: $exception');
    } else if (message.contains('timeout')) {
      return TimeoutFailure(message: 'Request timeout: $exception');
    } else {
      return RoomFailure(message: 'Failed to process room request: $exception');
    }
  }
  
  /// Refresh data in background without blocking UI
  void _refreshInBackground() {
    _logger.d('RoomRepositoryImpl: Starting background refresh');
    
    // Don't await - this runs in background
    (() async {
      try {
        final roomModels = await remoteDataSource.getRooms();
        if (localDataSource != null) {
          await localDataSource!.cacheRooms(roomModels);
        }
        _logger.d('RoomRepositoryImpl: Background refresh completed with ${roomModels.length} rooms');
      } on Exception catch (e) {
        _logger.e('RoomRepositoryImpl: Background refresh failed: $e');
      }
    })();
  }
  
  /// Cache data in background
  void _cacheInBackground(List<RoomModel> roomModels) {
    _logger.d('RoomRepositoryImpl: Starting background caching');
    
    // Don't await - this runs in background
    (() async {
      try {
        await localDataSource!.cacheRooms(roomModels);
        _logger.d('RoomRepositoryImpl: Background caching completed');
      } on Exception catch (e) {
        _logger.e('RoomRepositoryImpl: Background caching failed: $e');
      }
    })();
  }
}
