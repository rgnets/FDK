import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/speed_test/data/datasources/speed_test_data_source.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_with_results.dart';
import 'package:rgnets_fdk/features/speed_test/domain/repositories/speed_test_repository.dart';

/// Implementation of [SpeedTestRepository] using WebSocket data source.
class SpeedTestRepositoryImpl implements SpeedTestRepository {
  SpeedTestRepositoryImpl({
    required SpeedTestDataSource dataSource,
    Logger? logger,
  })  : _dataSource = dataSource,
        _logger = logger ?? Logger();

  final SpeedTestDataSource _dataSource;
  final Logger _logger;

  // ============================================================================
  // Speed Test Config Operations
  // ============================================================================

  @override
  Future<Either<Failure, List<SpeedTestConfig>>> getSpeedTestConfigs() async {
    try {
      _logger.i('SpeedTestRepositoryImpl: getSpeedTestConfigs() called');
      final configs = await _dataSource.getSpeedTestConfigs();
      _logger.i(
        'SpeedTestRepositoryImpl: Got ${configs.length} speed test configs',
      );
      return Right(configs);
    } on Exception catch (e) {
      _logger.e('SpeedTestRepositoryImpl: Failed to get configs: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SpeedTestConfig>> getSpeedTestConfig(int id) async {
    try {
      _logger.i('SpeedTestRepositoryImpl: getSpeedTestConfig($id) called');
      final config = await _dataSource.getSpeedTestConfig(id);
      return Right(config);
    } on Exception catch (e) {
      _logger.e('SpeedTestRepositoryImpl: Failed to get config $id: $e');
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
      _logger.i(
        'SpeedTestRepositoryImpl: getSpeedTestResults('
        'speedTestId: $speedTestId, accessPointId: $accessPointId) called',
      );
      final results = await _dataSource.getSpeedTestResults(
        speedTestId: speedTestId,
        accessPointId: accessPointId,
        limit: limit,
        offset: offset,
      );
      _logger.i(
        'SpeedTestRepositoryImpl: Got ${results.length} speed test results',
      );
      return Right(results);
    } on Exception catch (e) {
      _logger.e('SpeedTestRepositoryImpl: Failed to get results: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SpeedTestResult>> getSpeedTestResult(int id) async {
    try {
      _logger.i('SpeedTestRepositoryImpl: getSpeedTestResult($id) called');
      final result = await _dataSource.getSpeedTestResult(id);
      return Right(result);
    } on Exception catch (e) {
      _logger.e('SpeedTestRepositoryImpl: Failed to get result $id: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SpeedTestResult>> createSpeedTestResult(
    SpeedTestResult result,
  ) async {
    try {
      _logger.i('SpeedTestRepositoryImpl: createSpeedTestResult() called');
      final created = await _dataSource.createSpeedTestResult(result);
      _logger.i('SpeedTestRepositoryImpl: Created result with id ${created.id}');
      return Right(created);
    } on Exception catch (e) {
      _logger.e('SpeedTestRepositoryImpl: Failed to create result: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, SpeedTestResult>> updateSpeedTestResult(
    SpeedTestResult result,
  ) async {
    try {
      _logger.i(
        'SpeedTestRepositoryImpl: updateSpeedTestResult(${result.id}) called',
      );
      final updated = await _dataSource.updateSpeedTestResult(result);
      return Right(updated);
    } on Exception catch (e) {
      _logger.e('SpeedTestRepositoryImpl: Failed to update result: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  // ============================================================================
  // Joined Operations
  // ============================================================================

  @override
  Future<Either<Failure, SpeedTestWithResults>> getSpeedTestWithResults(
    int id,
  ) async {
    try {
      _logger.i('SpeedTestRepositoryImpl: getSpeedTestWithResults($id) called');

      // Fetch config and results in parallel
      final configFuture = _dataSource.getSpeedTestConfig(id);
      final resultsFuture = _dataSource.getSpeedTestResults(speedTestId: id);

      final config = await configFuture;
      final results = await resultsFuture;

      final joined = SpeedTestWithResults(
        config: config,
        results: results,
      );

      _logger.i(
        'SpeedTestRepositoryImpl: Got config $id with ${results.length} results',
      );
      return Right(joined);
    } on Exception catch (e) {
      _logger.e(
        'SpeedTestRepositoryImpl: Failed to get speed test with results: $e',
      );
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<SpeedTestWithResults>>>
      getAllSpeedTestsWithResults() async {
    try {
      _logger.i(
        'SpeedTestRepositoryImpl: getAllSpeedTestsWithResults() called',
      );

      // Fetch all configs and results
      final configs = await _dataSource.getSpeedTestConfigs();
      final allResults = await _dataSource.getSpeedTestResults();

      // Group results by speedTestId
      final resultsByConfigId = <int, List<SpeedTestResult>>{};
      for (final result in allResults) {
        if (result.speedTestId != null) {
          resultsByConfigId
              .putIfAbsent(result.speedTestId!, () => [])
              .add(result);
        }
      }

      // Join configs with their results
      final joined = configs.map((config) {
        final results = config.id != null
            ? (resultsByConfigId[config.id!] ?? <SpeedTestResult>[])
            : <SpeedTestResult>[];
        return SpeedTestWithResults(config: config, results: results);
      }).toList();

      _logger.i(
        'SpeedTestRepositoryImpl: Got ${joined.length} speed tests with results',
      );
      return Right(joined);
    } on Exception catch (e) {
      _logger.e(
        'SpeedTestRepositoryImpl: Failed to get all speed tests with results: $e',
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
