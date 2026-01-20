import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/features/speed_test/data/datasources/speed_test_data_source.dart';
import 'package:rgnets_fdk/features/speed_test/data/datasources/speed_test_websocket_data_source.dart';
import 'package:rgnets_fdk/features/speed_test/data/repositories/speed_test_repository_impl.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_with_results.dart';
import 'package:rgnets_fdk/features/speed_test/domain/repositories/speed_test_repository.dart';

part 'speed_test_providers.g.dart';

// ============================================================================
// Data Source Provider
// ============================================================================

@Riverpod(keepAlive: true)
SpeedTestDataSource speedTestDataSource(SpeedTestDataSourceRef ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return SpeedTestWebSocketDataSource(
    webSocketService: webSocketService,
    logger: Logger(),
  );
}

// ============================================================================
// Repository Provider
// ============================================================================

@Riverpod(keepAlive: true)
SpeedTestRepository speedTestRepository(SpeedTestRepositoryRef ref) {
  final dataSource = ref.watch(speedTestDataSourceProvider);
  return SpeedTestRepositoryImpl(
    dataSource: dataSource,
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

@Riverpod(keepAlive: true)
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
// Speed Test With Results Provider (Joined)
// ============================================================================

@Riverpod(keepAlive: true)
class SpeedTestWithResultsNotifier extends _$SpeedTestWithResultsNotifier {
  Logger get _logger => ref.read(loggerProvider);

  @override
  Future<SpeedTestWithResults> build(int configId) async {
    _logger.i('SpeedTestWithResultsNotifier: Loading config $configId');

    final repository = ref.watch(speedTestRepositoryProvider);
    final result = await repository.getSpeedTestWithResults(configId);

    return result.fold(
      (failure) {
        _logger.e(
          'SpeedTestWithResultsNotifier: Failed - ${failure.message}',
        );
        throw Exception(failure.message);
      },
      (joined) {
        _logger.i(
          'SpeedTestWithResultsNotifier: Loaded config $configId '
          'with ${joined.resultCount} results',
        );
        return joined;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(speedTestRepositoryProvider);
      final result = await repository.getSpeedTestWithResults(configId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (joined) => joined,
      );
    });
  }
}

// ============================================================================
// All Speed Tests With Results Provider
// ============================================================================

@Riverpod(keepAlive: true)
class AllSpeedTestsWithResultsNotifier
    extends _$AllSpeedTestsWithResultsNotifier {
  Logger get _logger => ref.read(loggerProvider);

  @override
  Future<List<SpeedTestWithResults>> build() async {
    _logger.i('AllSpeedTestsWithResultsNotifier: Loading all speed tests');

    final repository = ref.watch(speedTestRepositoryProvider);
    final result = await repository.getAllSpeedTestsWithResults();

    return result.fold(
      (failure) {
        _logger.e(
          'AllSpeedTestsWithResultsNotifier: Failed - ${failure.message}',
        );
        throw Exception(failure.message);
      },
      (joined) {
        _logger.i(
          'AllSpeedTestsWithResultsNotifier: Loaded ${joined.length} speed tests',
        );
        return joined;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(speedTestRepositoryProvider);
      final result = await repository.getAllSpeedTestsWithResults();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (joined) => joined,
      );
    });
  }
}
