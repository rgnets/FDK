import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/features/speed_test/data/datasources/speed_test_data_source.dart';
import 'package:rgnets_fdk/features/speed_test/data/datasources/speed_test_websocket_data_source.dart';
import 'package:rgnets_fdk/features/speed_test/data/repositories/speed_test_repository_impl.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/network_gateway_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/speed_test_service.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_status.dart';
import 'package:rgnets_fdk/features/speed_test/domain/repositories/speed_test_repository.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/state/speed_test_run_state.dart';

part 'speed_test_providers.g.dart';

// ============================================================================
// Data Source Provider
// ============================================================================

@Riverpod(keepAlive: true)
SpeedTestDataSource speedTestDataSource(SpeedTestDataSourceRef ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  final cacheIntegration = ref.watch(webSocketCacheIntegrationProvider);
  return SpeedTestWebSocketDataSource(
    webSocketService: webSocketService,
    cacheIntegration: cacheIntegration,
    logger: Logger(),
  );
}

// ============================================================================
// Repository Provider
// ============================================================================

@Riverpod(keepAlive: true)
SpeedTestRepository speedTestRepository(SpeedTestRepositoryRef ref) {
  final dataSource = ref.watch(speedTestDataSourceProvider);
  final cacheIntegration = ref.watch(webSocketCacheIntegrationProvider);
  return SpeedTestRepositoryImpl(
    dataSource: dataSource,
    cacheIntegration: cacheIntegration,
    logger: Logger(),
  );
}

// ============================================================================
// Speed Test Configs Provider
// ============================================================================

@Riverpod(keepAlive: true)
class SpeedTestConfigsNotifier extends _$SpeedTestConfigsNotifier {
  Logger get _logger => ref.read(loggerProvider);

  @override
  Future<List<SpeedTestConfig>> build() async {
    _logger.i('SpeedTestConfigsNotifier: Loading speed test configs');

    final repository = ref.watch(speedTestRepositoryProvider);
    final result = await repository.getSpeedTestConfigs();

    return result.fold(
      (failure) {
        _logger.e('SpeedTestConfigsNotifier: Failed - ${failure.message}');
        throw Exception(failure.message);
      },
      (configs) {
        _logger.i(
          'SpeedTestConfigsNotifier: Loaded ${configs.length} configs',
        );
        return configs;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(speedTestRepositoryProvider);
      final result = await repository.getSpeedTestConfigs();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (configs) => configs,
      );
    });
  }
}

// ============================================================================
// Speed Test Results Provider
// ============================================================================

@riverpod
class SpeedTestResultsNotifier extends _$SpeedTestResultsNotifier {
  Logger get _logger => ref.read(loggerProvider);

  @override
  Future<List<SpeedTestResult>> build({
    int? speedTestId,
    int? accessPointId,
  }) async {
    _logger.i(
      'SpeedTestResultsNotifier: Loading results '
      '(speedTestId: $speedTestId, accessPointId: $accessPointId)',
    );

    final repository = ref.watch(speedTestRepositoryProvider);
    final result = await repository.getSpeedTestResults(
      speedTestId: speedTestId,
      accessPointId: accessPointId,
    );

    return result.fold(
      (failure) {
        _logger.e('SpeedTestResultsNotifier: Failed - ${failure.message}');
        throw Exception(failure.message);
      },
      (results) {
        _logger.i(
          'SpeedTestResultsNotifier: Loaded ${results.length} results',
        );
        return results;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(speedTestRepositoryProvider);
      final result = await repository.getSpeedTestResults(
        speedTestId: speedTestId,
        accessPointId: accessPointId,
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (results) => results,
      );
    });
  }

  Future<SpeedTestResult?> createResult(SpeedTestResult result) async {
    final repository = ref.read(speedTestRepositoryProvider);
    final createResult = await repository.createSpeedTestResult(result);

    return createResult.fold(
      (failure) {
        _logger.e('Failed to create result: ${failure.message}');
        return null;
      },
      (created) {
        // Refresh the list
        refresh();
        return created;
      },
    );
  }

  Future<SpeedTestResult?> updateResult(SpeedTestResult result) async {
    final repository = ref.read(speedTestRepositoryProvider);
    final updateResult = await repository.updateSpeedTestResult(result);

    return updateResult.fold(
      (failure) {
        _logger.e('Failed to update result: ${failure.message}');
        return null;
      },
      (updated) {
        // Refresh the list
        refresh();
        return updated;
      },
    );
  }
}

// ============================================================================
// Speed Test Run Notifier (for running tests via Riverpod)
// ============================================================================

@Riverpod(keepAlive: true)
class SpeedTestRunNotifier extends _$SpeedTestRunNotifier {
  SpeedTestService? _service;
  StreamSubscription<SpeedTestResult>? _resultSub;
  StreamSubscription<SpeedTestStatus>? _statusSub;
  StreamSubscription<double>? _progressSub;
  StreamSubscription<String>? _messageSub;

  @override
  SpeedTestRunState build() {
    ref.onDispose(() {
      _resultSub?.cancel();
      _statusSub?.cancel();
      _progressSub?.cancel();
      _messageSub?.cancel();
      _service?.dispose();
    });
    return const SpeedTestRunState();
  }

  /// Idempotent initialization - safe to call multiple times
  Future<void> initialize() async {
    if (state.isInitialized) return;

    _service = SpeedTestService();
    await _service!.initialize();
    _subscribeToStreams();
    await _syncNetworkInfo();
    _syncConfigFromService();
    state = state.copyWith(isInitialized: true);
  }

  void _subscribeToStreams() {
    // Status stream
    _statusSub = _service!.statusStream.listen((status) {
      state = state.copyWith(executionStatus: status);
    });

    // Progress stream
    _progressSub = _service!.progressStream.listen((progress) {
      state = state.copyWith(progress: progress);
    });

    // Status message stream
    _messageSub = _service!.statusMessageStream.listen((message) {
      state = state.copyWith(statusMessage: message);
    });

    // Result stream
    _resultSub = _service!.resultStream.listen((result) {
      state = state.copyWith(
        downloadSpeed: result.downloadMbps ?? state.downloadSpeed,
        uploadSpeed: result.uploadMbps ?? state.uploadSpeed,
        latency: (result.rtt ?? 0) > 0 ? result.rtt! : state.latency,
        completedResult: result,
        serverHost: result.serverHost ?? state.serverHost,
        errorMessage: result.hasError ? result.errorMessage : null,
      );

      // Auto-validate when result comes in
      if (state.config != null) {
        final passed = _validateResult(state.config!);
        state = state.copyWith(testPassed: passed);
      }
    });
  }

  Future<void> _syncNetworkInfo() async {
    final networkService = NetworkGatewayService();
    final localIp = await networkService.getWifiIP();
    final gatewayIp = await networkService.getWifiGateway();
    state = state.copyWith(
      localIpAddress: localIp,
      gatewayAddress: gatewayIp,
    );
  }

  void _syncConfigFromService() {
    if (_service == null) return;
    state = state.copyWith(
      serverHost: _service!.serverHost,
      serverPort: _service!.serverPort,
      testDuration: _service!.testDuration,
      bandwidthMbps: _service!.bandwidthMbps,
      parallelStreams: _service!.parallelStreams,
      useUdp: _service!.useUdp,
    );
  }

  Future<void> startTest({
    SpeedTestConfig? config,
    String? configTarget,
  }) async {
    if (!state.isInitialized) await initialize();

    // Reset for new test
    state = state.copyWith(
      config: config,
      downloadSpeed: 0,
      uploadSpeed: 0,
      latency: 0,
      progress: 0,
      errorMessage: null,
      statusMessage: null,
      testPassed: null,
      completedResult: null,
    );

    final target = configTarget ?? config?.target;

    try {
      await _service!.runSpeedTestWithFallback(configTarget: target);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> cancelTest() async {
    await _service?.cancelTest();
  }

  bool _validateResult(SpeedTestConfig config) {
    final minDown = config.minDownloadMbps ?? 0;
    final minUp = config.minUploadMbps ?? 0;
    return state.downloadSpeed >= minDown && state.uploadSpeed >= minUp;
  }

  void updateConfiguration({
    bool? useUdp,
    int? testDuration,
    int? bandwidthMbps,
    int? parallelStreams,
  }) {
    if (!state.isInitialized) return;
    _service!.updateConfiguration(
      useUdp: useUdp,
      testDuration: testDuration,
      bandwidthMbps: bandwidthMbps,
      parallelStreams: parallelStreams,
    );
    _syncConfigFromService();
  }

  /// Submit result to API (for config-based tests)
  /// Returns true if submission succeeded
  Future<bool> submitResult({int? accessPointId}) async {
    if (state.completedResult == null) return false;

    final result = state.completedResult!.copyWith(
      speedTestId: state.config?.id,
      passed: state.testPassed ?? false,
      accessPointId: accessPointId,
      port: state.serverPort,
      iperfProtocol: state.useUdp ? 'udp' : 'tcp',
    );

    try {
      await ref
          .read(speedTestResultsNotifierProvider(
            speedTestId: state.config?.id,
            accessPointId: accessPointId,
          ).notifier)
          .createResult(result);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Submission failed: $e');
      return false;
    }
  }

  /// Submit adhoc result via WebSocket (for card-based adhoc tests)
  /// Returns true if submission succeeded
  Future<bool> submitAdhocResult() async {
    if (state.completedResult == null) return false;

    final result = state.completedResult!;
    try {
      await ref.read(webSocketCacheIntegrationProvider).createAdhocSpeedTestResult(
            downloadSpeed: result.downloadMbps ?? 0,
            uploadSpeed: result.uploadMbps ?? 0,
            latency: result.rtt ?? 0,
            source: result.source,
            destination: result.destination,
            initiatedAt: result.initiatedAt,
            completedAt: result.completedAt,
          );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Submission failed: $e');
      return false;
    }
  }

  void reset() {
    if (!state.isInitialized) return;
    state = state.copyWith(
      executionStatus: SpeedTestStatus.idle,
      progress: 0,
      statusMessage: null,
      downloadSpeed: 0,
      uploadSpeed: 0,
      latency: 0,
      errorMessage: null,
      testPassed: null,
      completedResult: null,
      config: null,
    );
  }
}
