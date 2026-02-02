import 'dart:async';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_notices_summary_model.dart';

/// Data source for fetching health notices via WebSocket
/// Uses the WebSocket service's built-in request/response correlation
class HealthNoticesRemoteDataSource {
  HealthNoticesRemoteDataSource({
    required WebSocketService socketService,
  }) : _socketService = socketService;

  final WebSocketService _socketService;
  static const _tag = 'HealthNoticesDataSource';

  /// Fetches health notices summary (notices list + counts) from backend
  Future<HealthNoticesSummaryModel> fetchSummary() async {
    if (!_socketService.isConnected) {
      LoggerService.debug('WebSocket not connected, returning empty', tag: _tag);
      return const HealthNoticesSummaryModel();
    }

    try {
      // Use the WebSocket service's built-in request/response correlation
      final response = await _socketService.requestActionCable(
        action: 'resource_action',
        resourceType: 'health_notices',
        additionalData: {'crud_action': 'summary'},
        timeout: const Duration(seconds: 10),
      );

      // Check for error response
      if (response.type == 'error') {
        LoggerService.warning('Error response received', tag: _tag);
        return const HealthNoticesSummaryModel();
      }

      // For resource_response, the data is in payload['data']
      // which contains { notices: [...], counts: {...} }
      final responseData = response.payload['data'];

      if (responseData is! Map<String, dynamic>) {
        LoggerService.warning('Invalid response data type: ${responseData.runtimeType}', tag: _tag);
        return const HealthNoticesSummaryModel();
      }

      final summary = HealthNoticesSummaryModel.fromJson(responseData);
      LoggerService.debug(
        'Parsed ${summary.notices.length} notices, counts=${summary.counts.total}',
        tag: _tag,
      );
      return summary;
    } on TimeoutException {
      LoggerService.warning('Request timed out', tag: _tag);
      return const HealthNoticesSummaryModel();
    } on Exception catch (e) {
      LoggerService.error('Request failed: $e', tag: _tag, error: e);
      return const HealthNoticesSummaryModel();
    }
  }

  void dispose() {
    // No cleanup needed - WebSocket service handles its own lifecycle
  }
}
