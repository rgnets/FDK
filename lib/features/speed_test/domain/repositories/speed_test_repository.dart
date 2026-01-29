import 'package:fpdart/fpdart.dart';

import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

/// Repository interface for speed test configurations and results.
abstract class SpeedTestRepository {
  // ============================================================================
  // Speed Test Config Operations (Read-only)
  // ============================================================================

  /// Get all speed test configurations
  Future<Either<Failure, List<SpeedTestConfig>>> getSpeedTestConfigs();

  /// Get a specific speed test configuration by ID
  Future<Either<Failure, SpeedTestConfig>> getSpeedTestConfig(int id);

  // ============================================================================
  // Speed Test Result Operations
  // ============================================================================

  /// Get all speed test results with optional filtering
  Future<Either<Failure, List<SpeedTestResult>>> getSpeedTestResults({
    int? speedTestId,
    int? accessPointId,
    int? limit,
    int? offset,
  });

  /// Get a specific speed test result by ID
  Future<Either<Failure, SpeedTestResult>> getSpeedTestResult(int id);

  /// Create a new speed test result
  Future<Either<Failure, SpeedTestResult>> createSpeedTestResult(
    SpeedTestResult result,
  );

  /// Update an existing speed test result
  Future<Either<Failure, SpeedTestResult>> updateSpeedTestResult(
    SpeedTestResult result,
  );
}
