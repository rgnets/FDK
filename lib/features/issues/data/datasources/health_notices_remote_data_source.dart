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

  /// In-flight request memoization. Every device WS upsert rebuilds
  /// HealthNoticesNotifier, which calls fetchSummary again. On a 767-device
  /// site the rebuilds cascade and fire hundreds of summary requests in
  /// parallel — each loads every uncured notice on the rxg and they all
  /// queue up, saturating the WS connection and triggering timeouts. We
  /// share a single in-flight Future across concurrent callers so only one
  /// summary request hits the server at a time per data source instance.
  Future<HealthNoticesSummaryModel>? _inFlight;

  /// TTL cache for the last successful summary result. Even with in-flight
  /// memoization, every rebuild that fires AFTER a request completes will
  /// start a new request. On a busy site that's ~3-10 fresh requests per
  /// second — compounded with compliance REST traffic, this trips the rxg's
  /// 429 rate limit (observed on zew: ~73s alerts-blank window after
  /// sign-in). The TTL says "if we successfully fetched within the last 30
  /// seconds, reuse that result" — live updates still arrive via WS
  /// broadcasts of related models (device cache changes, etc.), so the
  /// staleness window is bounded by how often the table-attached HealthNotice
  /// itself changes, which on real sites is minutes-to-hours.
  HealthNoticesSummaryModel? _cached;
  DateTime? _cachedAt;
  static const _cacheTtl = Duration(seconds: 30);

  /// Back-off cooldown after a failed fetch (timeout, 429, error response).
  /// While `_cooldownUntil` is in the future we short-circuit to an empty
  /// model rather than re-firing the request. Without this, the rxg's
  /// 429 keeps refreshing as we retry inside the rate-limit window.
  DateTime? _cooldownUntil;
  static const _errorCooldown = Duration(seconds: 15);

  /// Fetches health notices summary (notices list + counts) from backend.
  Future<HealthNoticesSummaryModel> fetchSummary() async {
    final cached = _cached;
    final cachedAt = _cachedAt;
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheTtl) {
      return cached;
    }
    final cooldown = _cooldownUntil;
    if (cooldown != null && DateTime.now().isBefore(cooldown)) {
      return cached ?? const HealthNoticesSummaryModel();
    }
    if (!_socketService.isConnected) {
      LoggerService.debug('WebSocket not connected, returning empty', tag: _tag);
      return const HealthNoticesSummaryModel();
    }
    final existing = _inFlight;
    if (existing != null) return existing;
    final future = _doFetchSummary();
    _inFlight = future;
    try {
      final result = await future;
      if (result.notices.isNotEmpty || result.counts.total > 0) {
        _cached = result;
        _cachedAt = DateTime.now();
        _cooldownUntil = null;
      } else {
        // Empty payload from error/timeout/rate-limit. Back off so we
        // don't re-fire the request inside the rxg's rate-limit window.
        _cooldownUntil = DateTime.now().add(_errorCooldown);
      }
      return result;
    } finally {
      _inFlight = null;
    }
  }

  Future<HealthNoticesSummaryModel> _doFetchSummary() async {
    try {
      // Use the WebSocket service's built-in request/response correlation.
      // Timeout is 45s rather than 10s because the rxg's `summary` action
      // loads every uncured HealthNotice and serializes them all in one
      // response. On large MDU sites (hundreds of APs, thousands of
      // notices) the round-trip can take 15-30s. A short timeout silently
      // returns an empty list and the alerts view looks broken.
      final response = await _socketService.requestActionCable(
        action: 'resource_action',
        resourceType: 'health_notices',
        additionalData: {'crud_action': 'summary'},
        timeout: const Duration(seconds: 45),
      );

      // Check for error response
      if (response.type == 'error') {
        LoggerService.warning(
          'Error response received: payload=${response.payload}',
          tag: _tag,
        );
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
