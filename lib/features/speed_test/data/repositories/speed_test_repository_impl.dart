import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/features/speed_test/data/datasources/speed_test_data_source.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/speed_test_debug_logger.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/domain/repositories/speed_test_repository.dart';

/// Implementation of [SpeedTestRepository] using WebSocket data source.
class SpeedTestRepositoryImpl implements SpeedTestRepository {
  SpeedTestRepositoryImpl({
    required SpeedTestDataSource dataSource,
    required WebSocketCacheIntegration cacheIntegration,
  }) : _dataSource = dataSource,
       _cacheIntegration = cacheIntegration;

  final SpeedTestDataSource _dataSource;
  final WebSocketCacheIntegration _cacheIntegration;

  // ============================================================================
  // Speed Test Config Operations
  // ============================================================================

  @override
  Future<Either<Failure, List<SpeedTestConfig>>> getSpeedTestConfigs() async {
    try {
      SpeedTestDebugLogger.debug('config_fetch_start', {
        'source': 'repository',
      });
      final configs = await _dataSource.getSpeedTestConfigs();
      SpeedTestDebugLogger.debug('config_fetch_result', {
        'source': 'repository',
        'count': configs.length,
      });
      return Right(configs);
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          'source': 'repository',
          'operation': 'getSpeedTestConfigs',
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SpeedTestConfig>> getSpeedTestConfig(int id) async {
    try {
      SpeedTestDebugLogger.debug('config_fetch_start', {
        'source': 'repository',
        'speed_test_id': id,
      });
      final config = await _dataSource.getSpeedTestConfig(id);
      return Right(config);
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          'source': 'repository',
          'operation': 'getSpeedTestConfig',
          'speed_test_id': id,
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return Left(_mapExceptionToFailure(e));
    }
  }

  // ============================================================================
  // Speed Test Result Operations
  // ============================================================================

  @override
  Future<Either<Failure, List<SpeedTestResult>>> getSpeedTestResults({
    int? speedTestId,
    int? accessPointId,
    int? limit,
    int? offset,
  }) async {
    try {
      SpeedTestDebugLogger.debug('result_fetch_start', {
        'source': 'repository',
        if (speedTestId != null) 'speed_test_id': speedTestId,
        if (accessPointId != null) 'access_point_id': accessPointId,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      });
      final results = await _dataSource.getSpeedTestResults(
        speedTestId: speedTestId,
        accessPointId: accessPointId,
        limit: limit,
        offset: offset,
      );
      SpeedTestDebugLogger.debug('result_fetch_result', {
        'source': 'repository',
        'count': results.length,
      });
      return Right(results);
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          'source': 'repository',
          'operation': 'getSpeedTestResults',
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SpeedTestResult>> getSpeedTestResult(int id) async {
    try {
      SpeedTestDebugLogger.debug('result_fetch_start', {
        'source': 'repository',
        'result_id': id,
      });
      final result = await _dataSource.getSpeedTestResult(id);
      return Right(result);
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          'source': 'repository',
          'operation': 'getSpeedTestResult',
          'result_id': id,
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SpeedTestResult>> createSpeedTestResult(
    SpeedTestResult result,
  ) async {
    try {
      SpeedTestDebugLogger.debug('submit_start', {
        'source': 'repository',
        'result': SpeedTestDebugLogger.resultSummary(result),
      });
      final created = await _dataSource.createSpeedTestResult(result);
      SpeedTestDebugLogger.debug('submit_result', {
        'source': 'repository',
        'result': SpeedTestDebugLogger.resultSummary(created),
      });
      return Right(created);
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          'source': 'repository',
          'operation': 'createSpeedTestResult',
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SpeedTestResult>> updateSpeedTestResult(
    SpeedTestResult result,
  ) async {
    try {
      SpeedTestDebugLogger.debug('submit_start', {
        'source': 'repository',
        'result': SpeedTestDebugLogger.resultSummary(result),
      });
      final updated = await _dataSource.updateSpeedTestResult(result);

      // Update cache immediately (same pattern as device updates)
      _cacheIntegration.updateSpeedTestResultInCache(updated.toJson());
      SpeedTestDebugLogger.debug('submit_result', {
        'source': 'repository',
        'result': SpeedTestDebugLogger.resultSummary(updated),
      });

      return Right(updated);
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          'source': 'repository',
          'operation': 'updateSpeedTestResult',
          'reason': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return Left(_mapExceptionToFailure(e));
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  Failure _mapExceptionToFailure(Exception exception) {
    final message = exception.toString();

    if (message.contains('not found') || message.contains('404')) {
      return NotFoundFailure(message: message);
    } else if (message.contains('not connected') ||
        message.contains('network')) {
      return NetworkFailure(message: message);
    } else if (message.contains('timeout')) {
      return TimeoutFailure(message: message);
    } else if (message.contains('server') || message.contains('500')) {
      return ServerFailure(message: message);
    }

    return ServerFailure(message: 'Speed test operation failed: $message');
  }
}
