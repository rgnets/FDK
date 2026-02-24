import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

/// Manages speed test config and result caches synced via WebSocket.
class WebSocketSpeedTestCacheService {
  WebSocketSpeedTestCacheService({
    required WebSocketService webSocketService,
    Logger? logger,
    VoidCallback? onDataChanged,
  })  : _webSocketService = webSocketService,
        _logger = logger ?? Logger(),
        _onDataChanged = onDataChanged;

  final WebSocketService _webSocketService;
  final Logger _logger;
  final VoidCallback? _onDataChanged;

  static const String configResourceType = 'speed_tests';
  static const String resultResourceType = 'speed_test_results';

  /// Cached speed test config data.
  final List<Map<String, dynamic>> _speedTestConfigCache = [];

  /// Cached speed test result data.
  final List<Map<String, dynamic>> _speedTestResultCache = [];

  /// Update notifier for speed test configs.
  final ValueNotifier<DateTime?> lastSpeedTestConfigUpdate =
      ValueNotifier<DateTime?>(null);

  /// Update notifier for speed test results.
  final ValueNotifier<DateTime?> lastSpeedTestResultUpdate =
      ValueNotifier<DateTime?>(null);

  /// Callbacks for when speed test config data is received.
  final List<void Function(List<SpeedTestConfig>)> _speedTestConfigCallbacks =
      [];

  /// Callbacks for when speed test result data is received.
  final List<void Function(List<SpeedTestResult>)> _speedTestResultCallbacks =
      [];

  // ---------------------------------------------------------------------------
  // Public query API
  // ---------------------------------------------------------------------------

  bool get hasSpeedTestConfigCache => _speedTestConfigCache.isNotEmpty;
  bool get hasSpeedTestResultCache => _speedTestResultCache.isNotEmpty;

  List<SpeedTestConfig> getCachedSpeedTestConfigs() {
    return _speedTestConfigCache
        .map((json) {
          try {
            return SpeedTestConfig.fromJson(json);
          } catch (e) {
            _logger.w('Failed to parse speed test config: $e');
            return null;
          }
        })
        .whereType<SpeedTestConfig>()
        .toList();
  }

  SpeedTestConfig? getAdhocSpeedTestConfig() {
    final configs = getCachedSpeedTestConfigs();
    if (configs.isEmpty) return null;

    final adhocConfig = configs.firstWhereOrNull(
      (SpeedTestConfig c) => c.name?.toLowerCase().contains('adhoc') ?? false,
    );
    if (adhocConfig != null) return adhocConfig;

    return configs.first;
  }

  SpeedTestResult? getMostRecentAdhocSpeedTestResult() {
    final results = getCachedSpeedTestResults();
    if (results.isEmpty) return null;

    final adhocConfig = getAdhocSpeedTestConfig();
    final adhocConfigId = adhocConfig?.id;

    final adhocResults = results.where((r) {
      if (adhocConfigId != null && r.speedTestId == adhocConfigId) {
        return true;
      }
      if (r.testedViaAccessPointId == null &&
          r.testedViaMediaConverterId == null) {
        return true;
      }
      return false;
    }).toList();

    if (adhocResults.isEmpty) return null;

    adhocResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return adhocResults.first;
  }

  SpeedTestConfig? getSpeedTestConfigById(int? id) {
    if (id == null) return null;
    final match = _speedTestConfigCache.firstWhereOrNull(
      (Map<String, dynamic> json) => json['id'] == id,
    );
    return match != null ? SpeedTestConfig.fromJson(match) : null;
  }

  List<SpeedTestResult> getCachedSpeedTestResults() {
    return _speedTestResultCache
        .map((json) {
          try {
            return SpeedTestResult.fromJsonWithValidation(json);
          } catch (e) {
            _logger.w('Failed to parse speed test result: $e');
            return null;
          }
        })
        .whereType<SpeedTestResult>()
        .toList();
  }

  List<SpeedTestResult> getSpeedTestResultsForDevice(
    String deviceId, {
    String? deviceType,
  }) {
    final results = getCachedSpeedTestResults();
    final numericId = int.tryParse(deviceId.split('_').last);
    if (numericId == null) return [];

    if (deviceType == DeviceTypes.accessPoint || deviceId.startsWith('ap_')) {
      return results
          .where((r) => r.testedViaAccessPointId == numericId)
          .toList();
    } else if (deviceType == DeviceTypes.ont || deviceId.startsWith('ont_')) {
      return results
          .where((r) => r.testedViaMediaConverterId == numericId)
          .toList();
    }
    return [];
  }

  List<SpeedTestResult> getSpeedTestResultsForAccessPointId(int accessPointId) {
    return getCachedSpeedTestResults()
        .where((r) => r.testedViaAccessPointId == accessPointId)
        .toList();
  }

  List<SpeedTestResult> getSpeedTestResultsForConfigId(int speedTestId) {
    return getCachedSpeedTestResults()
        .where((r) => r.speedTestId == speedTestId)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Cache mutation API (REST / direct)
  // ---------------------------------------------------------------------------

  void updateSpeedTestResultInCache(Map<String, dynamic> data) {
    final id = data['id'];
    if (id == null) {
      _logger.w('updateSpeedTestResultInCache: Missing id in data');
      return;
    }

    final index = _speedTestResultCache.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      _speedTestResultCache[index] = data;
    } else {
      _speedTestResultCache.add(data);
    }
    _onDataChanged?.call();
    _bumpSpeedTestResultUpdate();
    _notifySpeedTestResultCallbacks();

    _logger.i('updateSpeedTestResultInCache: Updated result $id in cache');
  }

  Future<bool> createAdhocSpeedTestResult({
    required double downloadSpeed,
    required double uploadSpeed,
    required double latency,
    String? source,
    String? destination,
    int? port,
    String? protocol,
    bool passed = false,
    DateTime? initiatedAt,
    DateTime? completedAt,
    int? pmsRoomId,
    String? roomType,
  }) async {
    if (!_webSocketService.isConnected) {
      _logger.w('Cannot create speed test result: WebSocket not connected');
      return false;
    }

    try {
      final adhocConfig = getAdhocSpeedTestConfig();

      final params = <String, dynamic>{
        'download_mbps': downloadSpeed,
        'upload_mbps': uploadSpeed,
        'rtt': latency,
        'passed': passed,
        'test_type': 'iperf3',
        'initiated_at': (initiatedAt ?? DateTime.now()).toIso8601String(),
        'completed_at': (completedAt ?? DateTime.now()).toIso8601String(),
        if (adhocConfig?.id != null) 'speed_test_id': adhocConfig!.id,
        if (source != null) 'source': source,
        if (destination != null) 'destination': destination,
        if (port != null) 'port': port,
        if (protocol != null) 'iperf_protocol': protocol,
        if (pmsRoomId != null) 'pms_room_id': pmsRoomId,
        if (roomType != null) 'room_type': roomType,
      };

      final response = await _webSocketService.requestActionCable(
        action: 'create_resource',
        resourceType: resultResourceType,
        additionalData: {'params': params},
        timeout: const Duration(seconds: 15),
      );

      final data = response.payload['data'];
      if (data is Map<String, dynamic>) {
        applyUpsert(data, isConfig: false);
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Failed to create adhoc speed test result: $e');
      return false;
    }
  }

  Future<bool> updateDeviceSpeedTestResult({
    required String deviceId,
    required double downloadSpeed,
    required double uploadSpeed,
    required double latency,
    String? source,
    String? destination,
    int? port,
    String? protocol,
    bool passed = false,
    DateTime? initiatedAt,
    DateTime? completedAt,
    int? pmsRoomId,
    String? roomType,
  }) async {
    if (!_webSocketService.isConnected) {
      _logger.w('Cannot update speed test result: WebSocket not connected');
      return false;
    }

    try {
      final numericId = int.tryParse(deviceId.split('_').last);
      if (numericId == null) {
        _logger.w('Cannot update speed test result: Invalid device ID format');
        return false;
      }

      final existingResults = getSpeedTestResultsForDevice(deviceId);
      final speedTestId = existingResults.isNotEmpty
          ? existingResults.first.speedTestId
          : getAdhocSpeedTestConfig()?.id;

      final params = <String, dynamic>{
        'download_mbps': downloadSpeed,
        'upload_mbps': uploadSpeed,
        'rtt': latency,
        'passed': passed,
        'test_type': 'iperf3',
        'initiated_at': (initiatedAt ?? DateTime.now()).toIso8601String(),
        'completed_at': (completedAt ?? DateTime.now()).toIso8601String(),
        if (speedTestId != null) 'speed_test_id': speedTestId,
        if (source != null) 'source': source,
        if (destination != null) 'destination': destination,
        if (port != null) 'port': port,
        if (protocol != null) 'iperf_protocol': protocol,
        if (pmsRoomId != null) 'pms_room_id': pmsRoomId,
        if (roomType != null) 'room_type': roomType,
      };

      if (deviceId.startsWith('ap_')) {
        params['tested_via_access_point_id'] = numericId;
      } else if (deviceId.startsWith('ont_')) {
        params['tested_via_media_converter_id'] = numericId;
      }

      final response = await _webSocketService.requestActionCable(
        action: 'create_resource',
        resourceType: resultResourceType,
        additionalData: {'params': params},
        timeout: const Duration(seconds: 15),
      );

      final data = response.payload['data'];
      if (data is Map<String, dynamic>) {
        applyUpsert(data, isConfig: false);
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Failed to update device speed test result: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Callback registration
  // ---------------------------------------------------------------------------

  void onSpeedTestConfigData(void Function(List<SpeedTestConfig>) callback) {
    _speedTestConfigCallbacks.add(callback);
  }

  void removeSpeedTestConfigCallback(
      void Function(List<SpeedTestConfig>) callback) {
    _speedTestConfigCallbacks.remove(callback);
  }

  void onSpeedTestResultData(void Function(List<SpeedTestResult>) callback) {
    _speedTestResultCallbacks.add(callback);
  }

  void removeSpeedTestResultCallback(
      void Function(List<SpeedTestResult>) callback) {
    _speedTestResultCallbacks.remove(callback);
  }

  // ---------------------------------------------------------------------------
  // Internal: called by facade routing
  // ---------------------------------------------------------------------------

  void applySnapshot(List<Map<String, dynamic>> items,
      {required bool isConfig}) {
    if (isConfig) {
      _speedTestConfigCache
        ..clear()
        ..addAll(items);
      _onDataChanged?.call();
      _bumpSpeedTestConfigUpdate();

      _logger.i(
        'WebSocketSpeedTestCacheService: speed_tests snapshot - ${items.length} items',
      );

      _notifySpeedTestConfigCallbacks();
    } else {
      _speedTestResultCache
        ..clear()
        ..addAll(items);
      _onDataChanged?.call();
      _bumpSpeedTestResultUpdate();

      _logger.i(
        'WebSocketSpeedTestCacheService: speed_test_results snapshot - ${items.length} items',
      );

      _notifySpeedTestResultCallbacks();
    }
  }

  void applyUpsert(Map<String, dynamic> data,
      {required bool isConfig, String? action}) {
    final id = data['id'];
    if (id == null) return;

    if (isConfig) {
      final index =
          _speedTestConfigCache.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        _speedTestConfigCache[index] = data;
      } else {
        _speedTestConfigCache.add(data);
      }
      _onDataChanged?.call();
      _bumpSpeedTestConfigUpdate();
      _notifySpeedTestConfigCallbacks();
    } else {
      final index =
          _speedTestResultCache.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        _speedTestResultCache[index] = data;
      } else {
        _speedTestResultCache.add(data);
      }
      _onDataChanged?.call();
      _bumpSpeedTestResultUpdate();
      _notifySpeedTestResultCallbacks();
    }
  }

  void applyDelete(Map<String, dynamic> data, {required bool isConfig}) {
    final id = data['id'];
    if (id == null) return;

    if (isConfig) {
      _speedTestConfigCache.removeWhere((item) => item['id'] == id);
      _onDataChanged?.call();
      _bumpSpeedTestConfigUpdate();
      _notifySpeedTestConfigCallbacks();
    } else {
      _speedTestResultCache.removeWhere((item) => item['id'] == id);
      _onDataChanged?.call();
      _bumpSpeedTestResultUpdate();
      _notifySpeedTestResultCallbacks();
    }
  }

  /// Whether the config or result cache has items (used by accumulator guard).
  bool hasCachedItems({required bool isConfig}) {
    return isConfig
        ? _speedTestConfigCache.isNotEmpty
        : _speedTestResultCache.isNotEmpty;
  }

  void clearCaches() {
    _speedTestConfigCache.clear();
    _speedTestResultCache.clear();
  }

  void dispose() {
    lastSpeedTestConfigUpdate.dispose();
    lastSpeedTestResultUpdate.dispose();
    _speedTestConfigCallbacks.clear();
    _speedTestResultCallbacks.clear();
    _speedTestConfigCache.clear();
    _speedTestResultCache.clear();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _bumpSpeedTestConfigUpdate() {
    lastSpeedTestConfigUpdate.value = DateTime.now();
  }

  void _bumpSpeedTestResultUpdate() {
    lastSpeedTestResultUpdate.value = DateTime.now();
  }

  void _notifySpeedTestConfigCallbacks() {
    final configs = getCachedSpeedTestConfigs();
    for (final callback in _speedTestConfigCallbacks) {
      callback(configs);
    }
  }

  void _notifySpeedTestResultCallbacks() {
    final results = getCachedSpeedTestResults();
    for (final callback in _speedTestResultCallbacks) {
      callback(results);
    }
  }
}
