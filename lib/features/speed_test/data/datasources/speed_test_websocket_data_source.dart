import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/datasources/speed_test_data_source.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

/// WebSocket-based data source for speed test operations.
class SpeedTestWebSocketDataSource implements SpeedTestDataSource {
  SpeedTestWebSocketDataSource({
    required WebSocketService webSocketService,
    Logger? logger,
  })  : _webSocketService = webSocketService,
        _logger = logger ?? Logger();

  final WebSocketService _webSocketService;
  final Logger _logger;

  static const String _speedTestConfigResourceType = 'speed_tests';
  static const String _speedTestResultResourceType = 'speed_test_results';

  // ============================================================================
  // Speed Test Config Operations
  // ============================================================================

  @override
  Future<List<SpeedTestConfig>> getSpeedTestConfigs() async {
    _logger.i('SpeedTestWebSocketDataSource: getSpeedTestConfigs() called');

    if (!_webSocketService.isConnected) {
      _logger.w('SpeedTestWebSocketDataSource: WebSocket not connected');
      return [];
    }

    try {
      final response = await _webSocketService.requestActionCable(
        action: 'index',
        resourceType: _speedTestConfigResourceType,
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

    if (!_webSocketService.isConnected) {
      throw StateError('WebSocket not connected');
    }

    final response = await _webSocketService.requestActionCable(
      action: 'show',
      resourceType: _speedTestConfigResourceType,
      additionalData: {'id': id},
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

    if (!_webSocketService.isConnected) {
      _logger.w('SpeedTestWebSocketDataSource: WebSocket not connected');
      return [];
    }

    try {
      final additionalData = <String, dynamic>{};
      if (speedTestId != null) additionalData['speed_test_id'] = speedTestId;
      if (accessPointId != null) {
        additionalData['access_point_id'] = accessPointId;
      }
      if (limit != null) additionalData['limit'] = limit;
      if (offset != null) additionalData['offset'] = offset;

      final response = await _webSocketService.requestActionCable(
        action: 'index',
        resourceType: _speedTestResultResourceType,
        additionalData: additionalData.isNotEmpty ? additionalData : null,
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
      action: 'show',
      resourceType: _speedTestResultResourceType,
      additionalData: {'id': id},
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
      action: 'create',
      resourceType: _speedTestResultResourceType,
      additionalData: jsonToSend,
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
      action: 'update',
      resourceType: _speedTestResultResourceType,
      additionalData: result.toJson(),
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
