import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

/// Abstract interface for speed test data source.
abstract class SpeedTestDataSource {
  // ============================================================================
  // Speed Test Config Operations
  // ============================================================================

  /// Fetch all speed test configurations from remote
  Future<List<SpeedTestConfig>> getSpeedTestConfigs();

  /// Fetch a specific speed test configuration by ID
  Future<SpeedTestConfig> getSpeedTestConfig(int id);

  // ============================================================================
  // Speed Test Result Operations
  // ============================================================================

  /// Fetch speed test results with optional filtering
  Future<List<SpeedTestResult>> getSpeedTestResults({
    int? speedTestId,
    int? accessPointId,
    int? limit,
    int? offset,
  });

  /// Fetch a specific speed test result by ID
  Future<SpeedTestResult> getSpeedTestResult(int id);

  /// Create a new speed test result
  Future<SpeedTestResult> createSpeedTestResult(SpeedTestResult result);

  /// Update an existing speed test result
  Future<SpeedTestResult> updateSpeedTestResult(SpeedTestResult result);
}
