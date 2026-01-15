import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_counts.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';

/// Data source for fetching health notices via WebSocket
/// Uses the WebSocket service's built-in request/response correlation
class HealthNoticesRemoteDataSource {
  HealthNoticesRemoteDataSource({
    required WebSocketService socketService,
  }) : _socketService = socketService;

  final WebSocketService _socketService;

  /// Fetches health notices summary (notices list + counts) from backend
  Future<HealthNoticesSummary> fetchSummary() async {
    if (kDebugMode) {
      print('HealthNoticesDataSource: fetchSummary called, isConnected=${_socketService.isConnected}');
    }

    if (!_socketService.isConnected) {
      if (kDebugMode) {
        print('HealthNoticesDataSource: WebSocket not connected, returning empty');
      }
      return HealthNoticesSummary.empty();
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
        return HealthNoticesSummary.empty();
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
        return HealthNoticesSummary.empty();
      }

      final summary = HealthNoticesSummary.fromJson(responseData);
      if (kDebugMode) {
        print('HealthNoticesDataSource: Parsed ${summary.notices.length} notices, counts=${summary.counts.total}');
      }
      return summary;
    } on TimeoutException {
      if (kDebugMode) {
        print('HealthNoticesDataSource: Request timed out');
      }
      return HealthNoticesSummary.empty();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('HealthNoticesDataSource: Request failed: $e');
      }
      return HealthNoticesSummary.empty();
    }
  }

  void dispose() {
    // No cleanup needed - WebSocket service handles its own lifecycle
  }
}

/// Combined health notices data (list + counts)
class HealthNoticesSummary {
  const HealthNoticesSummary({
    required this.notices,
    required this.counts,
  });

  factory HealthNoticesSummary.empty() => HealthNoticesSummary(
        notices: const [],
        counts: HealthCounts.zero(),
      );

  factory HealthNoticesSummary.fromJson(Map<String, dynamic> json) {
    final noticesList = json['notices'] as List<dynamic>? ?? [];
    final countsMap = json['counts'] as Map<String, dynamic>? ?? {};

    final notices = noticesList
        .whereType<Map<String, dynamic>>()
        .map((n) => HealthNotice(
              id: n['id'] as int? ?? 0,
              name: n['name'] as String? ?? '',
              severity: _parseSeverity(n['severity'] as String?),
              shortMessage: n['short_message'] as String? ?? '',
              createdAt: DateTime.tryParse(n['created_at']?.toString() ?? '') ??
                  DateTime.now(),
            ))
        .toList();

    final counts = HealthCounts(
      total: (countsMap['total'] as num?)?.toInt() ?? 0,
      fatal: (countsMap['fatal'] as num?)?.toInt() ?? 0,
      critical: (countsMap['critical'] as num?)?.toInt() ?? 0,
      warning: (countsMap['warning'] as num?)?.toInt() ?? 0,
      notice: (countsMap['notice'] as num?)?.toInt() ?? 0,
    );

    return HealthNoticesSummary(notices: notices, counts: counts);
  }

  final List<HealthNotice> notices;
  final HealthCounts counts;

  static HealthNoticeSeverity _parseSeverity(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'FATAL':
        return HealthNoticeSeverity.fatal;
      case 'CRITICAL':
        return HealthNoticeSeverity.critical;
      case 'WARNING':
        return HealthNoticeSeverity.warning;
      case 'NOTICE':
      default:
        return HealthNoticeSeverity.notice;
    }
  }
}
