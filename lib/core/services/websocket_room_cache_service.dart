import 'dart:ui';

/// Manages room caches synced via WebSocket.
class WebSocketRoomCacheService {
  WebSocketRoomCacheService({
    VoidCallback? onDataChanged,
  }) : _onDataChanged = onDataChanged;

  final VoidCallback? _onDataChanged;

  static const String roomResourceType = 'pms_rooms';

  /// Cached room data.
  final List<Map<String, dynamic>> _roomCache = [];

  /// Callbacks for when room data is received.
  final List<void Function(List<Map<String, dynamic>>)> _roomDataCallbacks = [];

  // ---------------------------------------------------------------------------
  // Public query API
  // ---------------------------------------------------------------------------

  bool get hasRoomCache => _roomCache.isNotEmpty;

  List<Map<String, dynamic>> getCachedRooms() {
    return List.unmodifiable(_roomCache);
  }

  // ---------------------------------------------------------------------------
  // Callback registration
  // ---------------------------------------------------------------------------

  void onRoomData(void Function(List<Map<String, dynamic>>) callback) {
    _roomDataCallbacks.add(callback);
  }

  void removeRoomDataCallback(
      void Function(List<Map<String, dynamic>>) callback) {
    _roomDataCallbacks.remove(callback);
  }

  // ---------------------------------------------------------------------------
  // Internal: called by facade routing
  // ---------------------------------------------------------------------------

  void applySnapshot(List<Map<String, dynamic>> items) {
    _roomCache
      ..clear()
      ..addAll(items);
    _onDataChanged?.call();

    for (final callback in _roomDataCallbacks) {
      callback(items);
    }
  }

  void applyUpsert(Map<String, dynamic> data) {
    final id = data['id'];
    if (id == null) return;

    final index = _roomCache.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      _roomCache[index] = data;
    } else {
      _roomCache.add(data);
    }
    _onDataChanged?.call();

    for (final callback in _roomDataCallbacks) {
      callback(_roomCache);
    }
  }

  void applyDelete(Map<String, dynamic> data) {
    final id = data['id'];
    if (id == null) return;

    _roomCache.removeWhere((item) => item['id'] == id);
    _onDataChanged?.call();

    for (final callback in _roomDataCallbacks) {
      callback(_roomCache);
    }
  }

  void clearCaches() {
    _roomCache.clear();
  }

  void dispose() {
    _roomDataCallbacks.clear();
    _roomCache.clear();
  }
}
