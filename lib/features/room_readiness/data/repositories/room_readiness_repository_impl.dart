import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/room_readiness/data/datasources/room_readiness_data_source.dart';
import 'package:rgnets_fdk/features/room_readiness/data/datasources/room_readiness_mock_data_source.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/repositories/room_readiness_repository.dart';

/// Repository implementation for room readiness operations.
class RoomReadinessRepositoryImpl implements RoomReadinessRepository {
  RoomReadinessRepositoryImpl({
    required this.dataSource,
    required this.mockDataSource,
    Logger? logger,
  }) : _logger = logger ?? Logger();

  final RoomReadinessDataSource dataSource;
  final RoomReadinessMockDataSource mockDataSource;
  final Logger _logger;

  @override
  Future<Either<Failure, List<RoomReadinessMetrics>>> getAllRoomReadiness() async {
    try {
      _logger.i('RoomReadinessRepositoryImpl: getAllRoomReadiness() called');
      _logger.i(
        'Environment: isDevelopment=${EnvironmentConfig.isDevelopment}, '
        'isStaging=${EnvironmentConfig.isStaging}, '
        'isProduction=${EnvironmentConfig.isProduction}',
      );

      // Development mode: use mock data
      if (EnvironmentConfig.isDevelopment) {
        _logger.i('RoomReadinessRepositoryImpl: Using DEVELOPMENT MODE - returning mock data');
        final metrics = await mockDataSource.getAllRoomReadiness();
        _logger.i('RoomReadinessRepositoryImpl: Returning ${metrics.length} mock metrics');
        return Right(metrics);
      }

      // Staging/Production: use real WebSocket data
      _logger.i('RoomReadinessRepositoryImpl: Using ${EnvironmentConfig.name.toUpperCase()} MODE');
      final metrics = await dataSource.getAllRoomReadiness();
      _logger.i('RoomReadinessRepositoryImpl: Got ${metrics.length} metrics from data source');
      return Right(metrics);
    } on Exception catch (e) {
      _logger.e('RoomReadinessRepositoryImpl: Error getting room readiness: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, RoomReadinessMetrics>> getRoomReadinessById(
    int roomId,
  ) async {
    try {
      _logger.i('RoomReadinessRepositoryImpl: getRoomReadinessById($roomId) called');

      // Development mode: use mock data
      if (EnvironmentConfig.isDevelopment) {
        _logger.i('RoomReadinessRepositoryImpl: Using mock data for room $roomId');
        final metrics = await mockDataSource.getRoomReadinessById(roomId);
        if (metrics == null) {
          return const Left(
            NotFoundFailure(message: 'Room not found', statusCode: 404),
          );
        }
        return Right(metrics);
      }

      // Staging/Production: use real WebSocket data
      _logger.i('RoomReadinessRepositoryImpl: Getting room $roomId from data source');
      final metrics = await dataSource.getRoomReadinessById(roomId);
      if (metrics == null) {
        return const Left(
          NotFoundFailure(message: 'Room not found', statusCode: 404),
        );
      }
      return Right(metrics);
    } on Exception catch (e) {
      _logger.e('RoomReadinessRepositoryImpl: Error getting room $roomId: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, double>> getOverallReadinessPercentage() async {
    try {
      _logger.i('RoomReadinessRepositoryImpl: getOverallReadinessPercentage() called');

      // Development mode: use mock data
      if (EnvironmentConfig.isDevelopment) {
        final percentage = mockDataSource.getOverallReadinessPercentage();
        return Right(percentage);
      }

      // Staging/Production: use real WebSocket data
      // Ensure we have data loaded first
      await dataSource.getAllRoomReadiness();
      final percentage = dataSource.getOverallReadinessPercentage();
      return Right(percentage);
    } on Exception catch (e) {
      _logger.e('RoomReadinessRepositoryImpl: Error getting overall readiness: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<RoomReadinessMetrics>>> getRoomsByStatus(
    RoomStatus status,
  ) async {
    try {
      _logger.i('RoomReadinessRepositoryImpl: getRoomsByStatus($status) called');

      // Development mode: use mock data
      if (EnvironmentConfig.isDevelopment) {
        final rooms = mockDataSource.getRoomsByStatus(status);
        return Right(rooms);
      }

      // Staging/Production: use real WebSocket data
      // Ensure we have data loaded first
      await dataSource.getAllRoomReadiness();
      final rooms = dataSource.getRoomsByStatus(status);
      return Right(rooms);
    } on Exception catch (e) {
      _logger.e('RoomReadinessRepositoryImpl: Error getting rooms by status: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Stream<RoomReadinessUpdate> get readinessUpdates {
    if (EnvironmentConfig.isDevelopment) {
      return mockDataSource.readinessUpdates;
    }
    return dataSource.readinessUpdates;
  }

  @override
  Future<Either<Failure, void>> refresh() async {
    try {
      _logger.i('RoomReadinessRepositoryImpl: refresh() called');

      if (EnvironmentConfig.isDevelopment) {
        await mockDataSource.refresh();
      } else {
        await dataSource.refresh();
      }

      return const Right(null);
    } on Exception catch (e) {
      _logger.e('RoomReadinessRepositoryImpl: Error refreshing: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  void dispose() {
    _logger.i('RoomReadinessRepositoryImpl: dispose() called');
    dataSource.dispose();
  }

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
      return RoomReadinessFailure(
        message: 'Failed to process room readiness request: $exception',
      );
    }
  }
}
