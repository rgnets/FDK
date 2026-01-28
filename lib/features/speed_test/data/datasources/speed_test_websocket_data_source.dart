import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/datasources/speed_test_data_source.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

/// WebSocket-based data source for speed test operations.
class SpeedTestWebSocketDataSource implements SpeedTestDataSource {
  SpeedTestWebSocketDataSource({
    required WebSocketService webSocketService,
    required WebSocketCacheIntegration cacheIntegration,
    Logger? logger,
  })  : _webSocketService = webSocketService,
        _cacheIntegration = cacheIntegration,
        _logger = logger ?? Logger();

  final WebSocketService _webSocketService;
  final WebSocketCacheIntegration _cacheIntegration;
  final Logger _logger;

  static const String _speedTestConfigResourceType = 'speed_tests';
  static const String _speedTestResultResourceType = 'speed_test_results';

  // ============================================================================
  // Speed Test Config Operations
  // ============================================================================

  @override
  Future<List<SpeedTestConfig>> getSpeedTestConfigs() async {
    _logger.i('SpeedTestWebSocketDataSource: getSpeedTestConfigs() called');

    // Try cache first
    final cachedConfigs = _cacheIntegration.getCachedSpeedTestConfigs();
    if (cachedConfigs.isNotEmpty) {
      _logger.i(
        'SpeedTestWebSocketDataSource: Returning ${cachedConfigs.length} configs from cache',
      );
      return cachedConfigs;
    }

    // Fall back to WebSocket request if cache empty
    if (!_webSocketService.isConnected) {
      _logger.w('SpeedTestWebSocketDataSource: WebSocket not connected');
      return [];
    }

    try {
      final response = await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: _speedTestConfigResourceType,
        additionalData: {'crud_action': 'index'},
        timeout: const Duration(seconds: 15),
      );

      final data = response.payload['data'];
      LoggerService.info(
        'SpeedTestConfigs raw response: ${response.payload}',
        tag: 'SpeedTestWS',
      );
      if (data is List) {
        LoggerService.info(
          'SpeedTestConfigs received ${data.length} configs',
          tag: 'SpeedTestWS',
        );
        for (int i = 0; i < data.length; i++) {
          final json = data[i];
          LoggerService.info(
            'Config[$i]: id=${json['id']}, name=${json['name']}, target=${json['target']}',
            tag: 'SpeedTestWS',
          );
        }
        return data
            .map((dynamic json) => SpeedTestConfig.fromJson(
                  Map<String, dynamic>.from(json as Map),
                ))
            .toList();
      }

      LoggerService.warning('SpeedTestConfigs: data is not a List', tag: 'SpeedTestWS');
      return [];
    } catch (e) {
      _logger.e('SpeedTestWebSocketDataSource: Failed to get configs: $e');
      return [];
    }
  }

  @override
  Future<SpeedTestConfig> getSpeedTestConfig(int id) async {
    _logger.i('SpeedTestWebSocketDataSource: getSpeedTestConfig($id) called');

    // Try cache first
    final cachedConfig = _cacheIntegration.getSpeedTestConfigById(id);
    if (cachedConfig != null) {
      _logger.i('SpeedTestWebSocketDataSource: Returning config $id from cache');
      return cachedConfig;
    }

    // Fall back to WebSocket request
    if (!_webSocketService.isConnected) {
      throw StateError('WebSocket not connected');
    }

    final response = await _webSocketService.requestActionCable(
      action: 'resource_action',
      resourceType: _speedTestConfigResourceType,
      additionalData: {
        'crud_action': 'show',
        'id': id,
      },
      timeout: const Duration(seconds: 15),
    );

    final data = response.payload['data'];
    if (data != null) {
      return SpeedTestConfig.fromJson(Map<String, dynamic>.from(data as Map));
    }

    throw Exception('Speed test config with id $id not found');
  }

  // ============================================================================
  // Speed Test Result Operations
  // ============================================================================

  @override
  Future<List<SpeedTestResult>> getSpeedTestResults({
    int? speedTestId,
    int? accessPointId,
    int? limit,
    int? offset,
  }) async {
    _logger.i(
      'SpeedTestWebSocketDataSource: getSpeedTestResults('
      'speedTestId: $speedTestId, accessPointId: $accessPointId, '
      'limit: $limit, offset: $offset) called',
    );

    // Try cache first with filtering
    var cachedResults = _cacheIntegration.getCachedSpeedTestResults();
    if (cachedResults.isNotEmpty) {
      // Apply filters
      if (speedTestId != null) {
        cachedResults = cachedResults
            .where((r) => r.speedTestId == speedTestId)
            .toList();
      }
      if (accessPointId != null) {
        cachedResults = cachedResults
            .where((r) => r.testedViaAccessPointId == accessPointId)
            .toList();
      }

      // Sort by timestamp (newest first)
      cachedResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply pagination
      if (offset != null && offset > 0) {
        cachedResults = cachedResults.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        cachedResults = cachedResults.take(limit).toList();
      }

      // Only return from cache if we have results after filtering
      if (cachedResults.isNotEmpty) {
        _logger.i(
          'SpeedTestWebSocketDataSource: Returning ${cachedResults.length} results from cache',
        );
        return cachedResults;
      }

      // Log cache miss and fall through to WebSocket
      _logger.d(
        'SpeedTestWebSocketDataSource: Filters resulted in empty cache, '
        'falling back to WebSocket',
      );
    }

    // Fall back to WebSocket request if cache empty
    if (!_webSocketService.isConnected) {
      _logger.w('SpeedTestWebSocketDataSource: WebSocket not connected');
      return [];
    }

    try {
      final additionalData = <String, dynamic>{
        'crud_action': 'index',
      };
      if (speedTestId != null) additionalData['speed_test_id'] = speedTestId;
      if (accessPointId != null) {
        additionalData['access_point_id'] = accessPointId;
      }
      if (limit != null) additionalData['limit'] = limit;
      if (offset != null) additionalData['offset'] = offset;

      final response = await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: _speedTestResultResourceType,
        additionalData: additionalData,
        timeout: const Duration(seconds: 15),
      );

      final data = response.payload['data'];
      LoggerService.info(
        'SpeedTestResults raw response: ${response.payload}',
        tag: 'SpeedTestWS',
      );
      if (data is List) {
        LoggerService.info(
          'SpeedTestResults received ${data.length} results',
          tag: 'SpeedTestWS',
        );
        for (var i = 0; i < data.length && i < 5; i++) {
          final json = data[i] as Map;
          LoggerService.info(
            'Result[$i]: id=${json['id']}, speed_test_id=${json['speed_test_id']}, '
            'download=${json['download_mbps']}, upload=${json['upload_mbps']}',
            tag: 'SpeedTestWS',
          );
        }
        if (data.length > 5) {
          LoggerService.info('... and ${data.length - 5} more results', tag: 'SpeedTestWS');
        }
        return data
            .map((dynamic json) => SpeedTestResult.fromJsonWithValidation(
                  Map<String, dynamic>.from(json as Map),
                ))
            .toList();
      }

      LoggerService.warning('SpeedTestResults: data is not a List', tag: 'SpeedTestWS');
      return [];
    } catch (e) {
      _logger.e('SpeedTestWebSocketDataSource: Failed to get results: $e');
      return [];
    }
  }

  @override
  Future<SpeedTestResult> getSpeedTestResult(int id) async {
    _logger.i('SpeedTestWebSocketDataSource: getSpeedTestResult($id) called');

    if (!_webSocketService.isConnected) {
      throw StateError('WebSocket not connected');
    }

    final response = await _webSocketService.requestActionCable(
      action: 'resource_action',
      resourceType: _speedTestResultResourceType,
      additionalData: {
        'crud_action': 'show',
        'id': id,
      },
      timeout: const Duration(seconds: 15),
    );

    final data = response.payload['data'];
    if (data != null) {
      return SpeedTestResult.fromJsonWithValidation(
        Map<String, dynamic>.from(data as Map),
      );
    }

    throw Exception('Speed test result with id $id not found');
  }

  @override
  Future<SpeedTestResult> createSpeedTestResult(SpeedTestResult result) async {
    _logger.i('SpeedTestWebSocketDataSource: createSpeedTestResult() called');

    if (!_webSocketService.isConnected) {
      throw StateError('WebSocket not connected');
    }

    final jsonToSend = result.toJson();
    LoggerService.info(
      'createSpeedTestResult sending: $jsonToSend',
      tag: 'SpeedTestWS',
    );

    final response = await _webSocketService.requestActionCable(
      action: 'create_resource',
      resourceType: _speedTestResultResourceType,
      additionalData: {
        'params': jsonToSend,
      },
      timeout: const Duration(seconds: 15),
    );

    LoggerService.info(
      'createSpeedTestResult response: ${response.payload}',
      tag: 'SpeedTestWS',
    );

    final data = response.payload['data'];
    if (data != null) {
      return SpeedTestResult.fromJsonWithValidation(
        Map<String, dynamic>.from(data as Map),
      );
    }

    throw Exception(
      response.payload['error']?.toString() ??
          'Failed to create speed test result',
    );
  }

  @override
  Future<SpeedTestResult> updateSpeedTestResult(SpeedTestResult result) async {
    _logger.i(
      'SpeedTestWebSocketDataSource: updateSpeedTestResult(${result.id}) called',
    );

    if (!_webSocketService.isConnected) {
      throw StateError('WebSocket not connected');
    }

    if (result.id == null) {
      throw ArgumentError('Cannot update speed test result without id');
    }

    final response = await _webSocketService.requestActionCable(
      action: 'update_resource',
      resourceType: _speedTestResultResourceType,
      additionalData: {
        'id': result.id,
        'params': result.toJson(),
      },
      timeout: const Duration(seconds: 15),
    );

    final data = response.payload['data'];
    if (data != null) {
      return SpeedTestResult.fromJsonWithValidation(
        Map<String, dynamic>.from(data as Map),
      );
    }

    throw Exception(
      response.payload['error']?.toString() ??
          'Failed to update speed test result',
    );
  }
}
