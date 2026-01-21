import 'dart:async';

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
<<<<<<< HEAD
  Future<HealthNoticesSummaryModel> fetchSummary() async {
    if (kDebugMode) {
      print('HealthNoticesDataSource: fetchSummary called, isConnected=${_socketService.isConnected}');
    }

    if (!_socketService.isConnected) {
      if (kDebugMode) {
        print('HealthNoticesDataSource: WebSocket not connected, returning empty');
      }
      return const HealthNoticesSummaryModel();
=======
  Future<HealthNoticesSummary> fetchSummary() async {
    if (!_socketService.isConnected) {
      return HealthNoticesSummary.empty();
>>>>>>> 3bdf0aa (Uplink added)
    }

    try {
      final response = await _socketService.requestActionCable(
        action: 'resource_action',
        resourceType: 'health_notices',
        additionalData: {'crud_action': 'summary'},
        timeout: const Duration(seconds: 10),
      );

      if (response.type == 'error') {
<<<<<<< HEAD
        if (kDebugMode) {
          print('HealthNoticesDataSource: Error response received');
        }
        return const HealthNoticesSummaryModel();
=======
        return HealthNoticesSummary.empty();
>>>>>>> 3bdf0aa (Uplink added)
      }

      final responseData = response.payload['data'];
      if (responseData is! Map<String, dynamic>) {
<<<<<<< HEAD
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
=======
        return HealthNoticesSummary.empty();
      }

      return HealthNoticesSummary.fromJson(responseData);
    } on TimeoutException {
      return HealthNoticesSummary.empty();
    } on Exception {
      return HealthNoticesSummary.empty();
>>>>>>> 3bdf0aa (Uplink added)
    }
  }

  void dispose() {
    // No cleanup needed - WebSocket service handles its own lifecycle
  }
}
