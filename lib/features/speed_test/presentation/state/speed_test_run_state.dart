import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_status.dart';

part 'speed_test_run_state.freezed.dart';

@freezed
class SpeedTestRunState with _$SpeedTestRunState {
  const factory SpeedTestRunState({
    // Execution status (idle, running, completed, error)
    @Default(SpeedTestStatus.idle) SpeedTestStatus executionStatus,

    // Progress (0-100)
    @Default(0.0) double progress,

    // Status message (for UI display)
    String? statusMessage,

    // Result data (from result stream)
    @Default(0.0) double downloadSpeed,
    @Default(0.0) double uploadSpeed,
    @Default(0.0) double latency,

    // Validation status: null = not run, true = passed, false = failed
    bool? testPassed,

    // Error state
    String? errorMessage,

    // Network info
    String? localIpAddress,
    String? gatewayAddress,

    // Server configuration
    @Default('') String serverHost,
    @Default(5201) int serverPort,

    // Test configuration
    @Default(10) int testDuration,
    @Default(0) int bandwidthMbps,
    @Default(1) int parallelStreams,
    @Default(false) bool useUdp,

    // Full result object (for submission)
    SpeedTestResult? completedResult,
    SpeedTestConfig? config,

    // Initialization flag
    @Default(false) bool isInitialized,
  }) = _SpeedTestRunState;

  const SpeedTestRunState._();

  /// Derived validation status: not run, passed, or failed
  String get validationStatus {
    if (testPassed == null) return 'not run';
    return testPassed! ? 'passed' : 'failed';
  }

  /// Whether a test is currently running
  bool get isRunning => executionStatus == SpeedTestStatus.running;
}
