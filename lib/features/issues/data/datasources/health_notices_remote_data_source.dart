import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/issues/data/models/health_notices_summary_model.dart';

/// Data source for fetching health notices via WebSocket
/// Uses the WebSocket service's built-in request/response correlation
class HealthNoticesRemoteDataSource {
  HealthNoticesRemoteDataSource({
    required WebSocketService socketService,
  }) : _socketService = socketService;

  final WebSocketService _socketService;

  /// Fetches health notices summary (notices list + counts) from backend
  Future<HealthNoticesSummaryModel> fetchSummary() async {
    if (kDebugMode) {
      print('HealthNoticesDataSource: fetchSummary called, isConnected=${_socketService.isConnected}');
    }

    if (!_socketService.isConnected) {
      if (kDebugMode) {
        print('HealthNoticesDataSource: WebSocket not connected, returning empty');
      }
      return const HealthNoticesSummaryModel();
    }

    try {
      if (kDebugMode) {
        print('HealthNoticesDataSource: Sending request via requestActionCable...');
      }

      // Use the WebSocket service's built-in request/response correlation
      final response = await _socketService.requestActionCable(
        action: 'resource_action',
        resourceType: 'health_notices',
        additionalData: {'crud_action': 'summary'},
        timeout: const Duration(seconds: 10),
      );

      if (kDebugMode) {
        print('HealthNoticesDataSource: Got response type=${response.type}');
      }

      // Check for error response
      if (response.type == 'error') {
        if (kDebugMode) {
          print('HealthNoticesDataSource: Error response received');
        }
        return const HealthNoticesSummaryModel();
      }

      // For resource_response, the data is in payload['data']
      // which contains { notices: [...], counts: {...} }
      final responseData = response.payload['data'];
      if (kDebugMode) {
        print('HealthNoticesDataSource: responseData type=${responseData.runtimeType}');
      }

      if (responseData is! Map<String, dynamic>) {
        if (kDebugMode) {
          print('HealthNoticesDataSource: responseData is not a Map, returning empty');
        }
        return const HealthNoticesSummaryModel();
      }

      final summary = HealthNoticesSummaryModel.fromJson(responseData);
      if (kDebugMode) {
        print('HealthNoticesDataSource: Parsed ${summary.notices.length} notices, counts=${summary.counts.total}');
      }
      return summary;
    } on TimeoutException {
      if (kDebugMode) {
        print('HealthNoticesDataSource: Request timed out');
      }
      return const HealthNoticesSummaryModel();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('HealthNoticesDataSource: Request failed: $e');
      }
      return const HealthNoticesSummaryModel();
    }
  }

  void dispose() {
    // No cleanup needed - WebSocket service handles its own lifecycle
  }
}
