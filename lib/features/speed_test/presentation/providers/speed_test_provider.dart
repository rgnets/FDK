import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

/// Provider for all speed test configs from WebSocket cache
final speedTestConfigsProvider = Provider<List<SpeedTestConfig>>((ref) {
  final logger = LoggerConfig.getLogger();
  final integration = ref.watch(webSocketCacheIntegrationProvider);

  final configs = integration.getCachedSpeedTestConfigs();
  logger.d('SpeedTestProvider: Loaded ${configs.length} configs from WebSocket cache');
  return configs;
});

/// Provider for all speed test results from WebSocket cache
final speedTestResultsProvider = Provider<List<SpeedTestResult>>((ref) {
  final logger = LoggerConfig.getLogger();
  final integration = ref.watch(webSocketCacheIntegrationProvider);

  final results = integration.getCachedSpeedTestResults();
  logger.d('SpeedTestProvider: Loaded ${results.length} results from WebSocket cache');
  return results;
});

/// Provider for speed test results filtered by PMS room ID
final speedTestResultsByRoomProvider = Provider.family<List<SpeedTestResult>, int>(
  (ref, pmsRoomId) {
    final logger = LoggerConfig.getLogger();
    final integration = ref.watch(webSocketCacheIntegrationProvider);

    final results = integration.getCachedSpeedTestResultsByRoom(pmsRoomId);
    logger.d('SpeedTestProvider: Loaded ${results.length} results for room $pmsRoomId');
    return results;
  },
);

/// Provider for speed test results filtered by room name
final speedTestResultsByRoomNameProvider = Provider.family<List<SpeedTestResult>, String>(
  (ref, roomName) {
    final logger = LoggerConfig.getLogger();
    final integration = ref.watch(webSocketCacheIntegrationProvider);

    final results = integration.getCachedSpeedTestResultsByRoomName(roomName);
    logger.d('SpeedTestProvider: Loaded ${results.length} results for room name "$roomName"');
    return results;
  },
);

/// Provider for speed test results filtered by speed test config ID
final speedTestResultsByConfigProvider = Provider.family<List<SpeedTestResult>, int>(
  (ref, speedTestId) {
    final logger = LoggerConfig.getLogger();
    final results = ref.watch(speedTestResultsProvider);

    final filtered = results.where((r) => r.speedTestId == speedTestId).toList();
    logger.d('SpeedTestProvider: Loaded ${filtered.length} results for config $speedTestId');
    return filtered;
  },
);

/// Provider for a single speed test config by ID
final speedTestConfigProvider = Provider.family<SpeedTestConfig?, int>(
  (ref, configId) {
    final configs = ref.watch(speedTestConfigsProvider);
    try {
      return configs.firstWhere((c) => c.id == configId);
    } catch (_) {
      return null;
    }
  },
);
