import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/websocket_cache_integration.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/datasources/speed_test_data_source.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/speed_test_debug_logger.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

/// WebSocket-based data source for speed test operations.
class SpeedTestWebSocketDataSource implements SpeedTestDataSource {
  SpeedTestWebSocketDataSource({
    required WebSocketService webSocketService,
    required WebSocketCacheIntegration cacheIntegration,
    Logger? logger,
  }) : _webSocketService = webSocketService,
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
    SpeedTestDebugLogger.debug('config_fetch_start', {
      'source': 'websocket_data_source',
      'resource_type': _speedTestConfigResourceType,
    });

    // Try cache first
    final cachedConfigs = _cacheIntegration.getCachedSpeedTestConfigs();
    if (cachedConfigs.isNotEmpty) {
      SpeedTestDebugLogger.debug('config_fetch_cache_hit', {
        'source': 'websocket_data_source',
        'resource_type': _speedTestConfigResourceType,
        'count': cachedConfigs.length,
      });
      return cachedConfigs;
    }

    // Fall back to WebSocket request if cache empty
    if (!_webSocketService.isConnected) {
      SpeedTestDebugLogger.warning('error', {
        'source': 'websocket_data_source',
        'resource_type': _speedTestConfigResourceType,
        'reason': 'WebSocket not connected',
      });
      return [];
    }

    try {
      final requestId = SpeedTestDebugLogger.newRequestId('speed-test-configs');
      final payload = {
        'action': 'resource_action',
        'resource_type': _speedTestConfigResourceType,
        'request_id': requestId,
        'crud_action': 'index',
      };
      SpeedTestDebugLogger.debug('request', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'endpoint':
            'ActionCable RxgChannel/resource_action/$_speedTestConfigResourceType',
        'payload': payload,
      });
      final response = await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: _speedTestConfigResourceType,
        additionalData: {'crud_action': 'index'},
        requestId: requestId,
        timeout: const Duration(seconds: 15),
      );

      final data = response.payload['data'];
      SpeedTestDebugLogger.debug('response', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'resource_type': _speedTestConfigResourceType,
        'status': (response.payload['status'] as num?)?.toInt(),
        'body': response.raw ?? response.payload,
      });
      if (data is List) {
        SpeedTestDebugLogger.debug('config_fetch_result', {
          'source': 'websocket_data_source',
          'request_id': requestId,
          'count': data.length,
        });
        return data
            .map(
              (dynamic json) => SpeedTestConfig.fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList();
      }

      SpeedTestDebugLogger.warning('error', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'resource_type': _speedTestConfigResourceType,
        'reason': 'Response data is not a List',
        'body': response.raw ?? response.payload,
      });
      return [];
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          'source': 'websocket_data_source',
          'resource_type': _speedTestConfigResourceType,
          'reason': 'Failed to get configs',
          'error': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return [];
    }
  }

  @override
  Future<SpeedTestConfig> getSpeedTestConfig(int id) async {
    SpeedTestDebugLogger.debug('config_fetch_start', {
      'source': 'websocket_data_source',
      'resource_type': _speedTestConfigResourceType,
      'speed_test_id': id,
    });

    // Try cache first
    final cachedConfig = _cacheIntegration.getSpeedTestConfigById(id);
    if (cachedConfig != null) {
      SpeedTestDebugLogger.debug('config_fetch_cache_hit', {
        'source': 'websocket_data_source',
        'resource_type': _speedTestConfigResourceType,
        'speed_test_id': id,
      });
      return cachedConfig;
    }

    // Fall back to WebSocket request
    if (!_webSocketService.isConnected) {
      throw StateError('WebSocket not connected');
    }

    final requestId = SpeedTestDebugLogger.newRequestId(
      'speed-test-config-$id',
    );
    SpeedTestDebugLogger.debug('request', {
      'source': 'websocket_data_source',
      'request_id': requestId,
      'endpoint':
          'ActionCable RxgChannel/resource_action/$_speedTestConfigResourceType',
      'payload': {
        'action': 'resource_action',
        'resource_type': _speedTestConfigResourceType,
        'request_id': requestId,
        'crud_action': 'show',
        'id': id,
      },
    });
    final response = await _webSocketService.requestActionCable(
      action: 'resource_action',
      resourceType: _speedTestConfigResourceType,
      additionalData: {'crud_action': 'show', 'id': id},
      requestId: requestId,
      timeout: const Duration(seconds: 15),
    );

    final data = response.payload['data'];
    if (data != null) {
      SpeedTestDebugLogger.debug('response', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'resource_type': _speedTestConfigResourceType,
        'status': (response.payload['status'] as num?)?.toInt(),
        'body': response.raw ?? response.payload,
      });
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
    SpeedTestDebugLogger.debug('result_fetch_start', {
      'source': 'websocket_data_source',
      'resource_type': _speedTestResultResourceType,
      if (speedTestId != null) 'speed_test_id': speedTestId,
      if (accessPointId != null) 'access_point_id': accessPointId,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });

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
        SpeedTestDebugLogger.debug('result_fetch_cache_hit', {
          'source': 'websocket_data_source',
          'resource_type': _speedTestResultResourceType,
          'count': cachedResults.length,
          if (speedTestId != null) 'speed_test_id': speedTestId,
          if (accessPointId != null) 'access_point_id': accessPointId,
        });
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
      SpeedTestDebugLogger.warning('error', {
        'source': 'websocket_data_source',
        'resource_type': _speedTestResultResourceType,
        'reason': 'WebSocket not connected',
      });
      return [];
    }

    try {
      final additionalData = <String, dynamic>{'crud_action': 'index'};
      if (speedTestId != null) additionalData['speed_test_id'] = speedTestId;
      if (accessPointId != null) {
        additionalData['access_point_id'] = accessPointId;
      }
      if (limit != null) additionalData['limit'] = limit;
      if (offset != null) additionalData['offset'] = offset;
      final requestId = SpeedTestDebugLogger.newRequestId('speed-test-results');
      SpeedTestDebugLogger.debug('request', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'endpoint':
            'ActionCable RxgChannel/resource_action/$_speedTestResultResourceType',
        'payload': {
          'action': 'resource_action',
          'resource_type': _speedTestResultResourceType,
          'request_id': requestId,
          ...additionalData,
        },
      });

      final response = await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: _speedTestResultResourceType,
        additionalData: additionalData,
        requestId: requestId,
        timeout: const Duration(seconds: 15),
      );

      final data = response.payload['data'];
      SpeedTestDebugLogger.debug('response', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'resource_type': _speedTestResultResourceType,
        'status': (response.payload['status'] as num?)?.toInt(),
        'body': response.raw ?? response.payload,
      });
      if (data is List) {
        SpeedTestDebugLogger.debug('result_fetch_result', {
          'source': 'websocket_data_source',
          'request_id': requestId,
          'count': data.length,
        });
        return data
            .map(
              (dynamic json) => SpeedTestResult.fromJsonWithValidation(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList();
      }

      SpeedTestDebugLogger.warning('error', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'resource_type': _speedTestResultResourceType,
        'reason': 'Response data is not a List',
        'body': response.raw ?? response.payload,
      });
      return [];
    } on Exception catch (e, stack) {
      SpeedTestDebugLogger.error(
        'error',
        {
          'source': 'websocket_data_source',
          'resource_type': _speedTestResultResourceType,
          'reason': 'Failed to get results',
          'error': e.toString(),
        },
        error: e,
        stackTrace: stack,
      );
      return [];
    }
  }

  @override
  Future<SpeedTestResult> getSpeedTestResult(int id) async {
    SpeedTestDebugLogger.debug('result_fetch_start', {
      'source': 'websocket_data_source',
      'resource_type': _speedTestResultResourceType,
      'result_id': id,
    });

    if (!_webSocketService.isConnected) {
      throw StateError('WebSocket not connected');
    }

    final requestId = SpeedTestDebugLogger.newRequestId(
      'speed-test-result-$id',
    );
    SpeedTestDebugLogger.debug('request', {
      'source': 'websocket_data_source',
      'request_id': requestId,
      'endpoint':
          'ActionCable RxgChannel/resource_action/$_speedTestResultResourceType',
      'payload': {
        'action': 'resource_action',
        'resource_type': _speedTestResultResourceType,
        'request_id': requestId,
        'crud_action': 'show',
        'id': id,
      },
    });
    final response = await _webSocketService.requestActionCable(
      action: 'resource_action',
      resourceType: _speedTestResultResourceType,
      additionalData: {'crud_action': 'show', 'id': id},
      requestId: requestId,
      timeout: const Duration(seconds: 15),
    );

    final data = response.payload['data'];
    if (data != null) {
      SpeedTestDebugLogger.debug('response', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'resource_type': _speedTestResultResourceType,
        'status': (response.payload['status'] as num?)?.toInt(),
        'body': response.raw ?? response.payload,
      });
      return SpeedTestResult.fromJsonWithValidation(
        Map<String, dynamic>.from(data as Map),
      );
    }

    throw Exception('Speed test result with id $id not found');
  }

  @override
  Future<SpeedTestResult> createSpeedTestResult(SpeedTestResult result) async {
    final requestId = SpeedTestDebugLogger.newRequestId(
      'create-speed-test-result',
    );
    SpeedTestDebugLogger.debug('submit_start', {
      'source': 'websocket_data_source',
      'request_id': requestId,
      'result': SpeedTestDebugLogger.resultSummary(result),
    });

    if (!_webSocketService.isConnected) {
      throw StateError('WebSocket not connected');
    }

    final jsonToSend = result.toJson();
    SpeedTestDebugLogger.debug('request', {
      'source': 'websocket_data_source',
      'request_id': requestId,
      'endpoint':
          'ActionCable RxgChannel/create_resource/$_speedTestResultResourceType',
      'payload': {
        'action': 'create_resource',
        'resource_type': _speedTestResultResourceType,
        'request_id': requestId,
        'params': jsonToSend,
      },
    });

    final response = await _webSocketService.requestActionCable(
      action: 'create_resource',
      resourceType: _speedTestResultResourceType,
      additionalData: {'params': jsonToSend},
      requestId: requestId,
      timeout: const Duration(seconds: 15),
    );

    SpeedTestDebugLogger.debug('response', {
      'source': 'websocket_data_source',
      'request_id': requestId,
      'resource_type': _speedTestResultResourceType,
      'status': (response.payload['status'] as num?)?.toInt(),
      'body': response.raw ?? response.payload,
    });

    final data = response.payload['data'];
    if (data != null) {
      final created = SpeedTestResult.fromJsonWithValidation(
        Map<String, dynamic>.from(data as Map),
      );
      SpeedTestDebugLogger.debug('submit_result', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'result': SpeedTestDebugLogger.resultSummary(created),
      });
      return created;
    }

    throw Exception(
      response.payload['error']?.toString() ??
          'Failed to create speed test result',
    );
  }

  @override
  Future<SpeedTestResult> updateSpeedTestResult(SpeedTestResult result) async {
    final requestId = SpeedTestDebugLogger.newRequestId(
      'update-speed-test-result',
    );
    SpeedTestDebugLogger.debug('submit_start', {
      'source': 'websocket_data_source',
      'request_id': requestId,
      'result': SpeedTestDebugLogger.resultSummary(result),
    });

    if (!_webSocketService.isConnected) {
      throw StateError('WebSocket not connected');
    }

    if (result.id == null) {
      throw ArgumentError('Cannot update speed test result without id');
    }

    SpeedTestDebugLogger.debug('request', {
      'source': 'websocket_data_source',
      'request_id': requestId,
      'endpoint':
          'ActionCable RxgChannel/update_resource/$_speedTestResultResourceType',
      'payload': {
        'action': 'update_resource',
        'resource_type': _speedTestResultResourceType,
        'request_id': requestId,
        'id': result.id,
        'params': result.toJson(),
      },
    });
    final response = await _webSocketService.requestActionCable(
      action: 'update_resource',
      resourceType: _speedTestResultResourceType,
      additionalData: {'id': result.id, 'params': result.toJson()},
      requestId: requestId,
      timeout: const Duration(seconds: 15),
    );

    final data = response.payload['data'];
    if (data != null) {
      SpeedTestDebugLogger.debug('response', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'resource_type': _speedTestResultResourceType,
        'status': (response.payload['status'] as num?)?.toInt(),
        'body': response.raw ?? response.payload,
      });
      final updated = SpeedTestResult.fromJsonWithValidation(
        Map<String, dynamic>.from(data as Map),
      );
      SpeedTestDebugLogger.debug('submit_result', {
        'source': 'websocket_data_source',
        'request_id': requestId,
        'result': SpeedTestDebugLogger.resultSummary(updated),
      });
      return updated;
    }

    throw Exception(
      response.payload['error']?.toString() ??
          'Failed to update speed test result',
    );
  }
}
