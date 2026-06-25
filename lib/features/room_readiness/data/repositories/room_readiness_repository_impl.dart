import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/room_readiness/data/datasources/room_readiness_data_source.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/repositories/room_readiness_repository.dart';

/// Repository implementation for room readiness operations.
///
/// Always reads from the live [RoomReadinessDataSource] (WebSocket device data
/// plus compliance-rule results). The development-mode mock path was removed so
/// the app never substitutes fabricated room/issue data — every room status and
/// issue (including "missing images") reflects the real backend/compliance
/// state.
class RoomReadinessRepositoryImpl implements RoomReadinessRepository {
  RoomReadinessRepositoryImpl({
    required this.dataSource,
    Logger? logger,
  }) : _logger = logger ?? Logger();

  final RoomReadinessDataSource dataSource;
  final Logger _logger;

  @override
  Future<Either<Failure, List<RoomReadinessMetrics>>>
      getAllRoomReadiness() async {
    try {
      _logger.i('RoomReadinessRepositoryImpl: getAllRoomReadiness() called');
      final metrics = await dataSource.getAllRoomReadiness();
      _logger.i(
        'RoomReadinessRepositoryImpl: Got ${metrics.length} metrics from data source',
      );
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
      // Ensure we have data loaded first.
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
      // Ensure we have data loaded first.
      await dataSource.getAllRoomReadiness();
      final rooms = dataSource.getRoomsByStatus(status);
      return Right(rooms);
    } on Exception catch (e) {
      _logger.e('RoomReadinessRepositoryImpl: Error getting rooms by status: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Stream<RoomReadinessUpdate> get readinessUpdates =>
      dataSource.readinessUpdates;

  @override
  Future<Either<Failure, void>> refresh() async {
    try {
      _logger.i('RoomReadinessRepositoryImpl: refresh() called');
      await dataSource.refresh();
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
