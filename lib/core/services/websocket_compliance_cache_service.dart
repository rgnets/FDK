import 'dart:ui';

/// Manages the `compliance_check_results` resource cache synced via
/// WebSocket.
///
/// Follows the same shape as [WebSocketRoomCacheService] — receives raw JSON
/// maps from [WebSocketCacheIntegration] and exposes them via a callback so a
/// feature-specific repository can map them into domain state.
///
/// **Deliberate spec deviation:** we subscribe to `compliance_check_results`
/// (the history feed), NOT `compliance_check_result_snapshots`. Reason: the
/// snapshot table delegates `fleet_node_id` through its parent
/// `compliance_check_result` row, so the auto-routed REST/WS JSON payload
/// does NOT expose `fleet_node_id` directly on snapshot rows. Results expose
/// it as a real column, which is what FDK needs to filter `(rule_id,
/// fleet_node_id)` deltas without an extra join. FDK dedupes by
/// `(compliance_rule_id, fleet_node_id)` with `checked_at` as the
/// tie-breaker — see `ComplianceRepositoryImpl._handleWsDelta`.
class WebSocketComplianceCacheService {
  WebSocketComplianceCacheService({
    VoidCallback? onDataChanged,
  }) : _onDataChanged = onDataChanged;

  final VoidCallback? _onDataChanged;

  static const String resultResourceType = 'compliance_check_results';

  final List<Map<String, dynamic>> _snapshotCache = [];
  final List<void Function(List<Map<String, dynamic>>)> _callbacks = [];

  bool get hasCache => _snapshotCache.isNotEmpty;

  List<Map<String, dynamic>> getCached() => List.unmodifiable(_snapshotCache);

  void onResultData(void Function(List<Map<String, dynamic>>) callback) {
    _callbacks.add(callback);
  }

  void removeResultDataCallback(
      void Function(List<Map<String, dynamic>>) callback) {
    _callbacks.remove(callback);
  }

  void applySnapshot(List<Map<String, dynamic>> items) {
    _snapshotCache
      ..clear()
      ..addAll(items);
    _onDataChanged?.call();
    final snapshot = List<Map<String, dynamic>>.unmodifiable(_snapshotCache);
    for (final cb in _callbacks) {
      cb(snapshot);
    }
  }

  void applyUpsert(Map<String, dynamic> data) {
    final id = data['id'];
    if (id == null) return;

    final index = _snapshotCache.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      _snapshotCache[index] = data;
    } else {
      _snapshotCache.add(data);
    }
    _onDataChanged?.call();
    for (final cb in _callbacks) {
      cb(List.unmodifiable(_snapshotCache));
    }
  }

  void applyDelete(Map<String, dynamic> data) {
    final id = data['id'];
    if (id == null) return;
    _snapshotCache.removeWhere((item) => item['id'] == id);
    _onDataChanged?.call();
    for (final cb in _callbacks) {
      cb(List.unmodifiable(_snapshotCache));
    }
  }

  void clearCaches() {
    _snapshotCache.clear();
  }

  void dispose() {
    _callbacks.clear();
    _snapshotCache.clear();
  }
}
