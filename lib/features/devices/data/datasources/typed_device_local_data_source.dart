import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/data/models/device_model_sealed.dart';

/// Generic base class for type-specific device caches.
///
/// Features:
/// - Lazy loading: only loads from storage when first accessed
/// - O(1) lookups: maintains an index by device ID
/// - Debounced persistence: batches storage writes to reduce I/O
/// - Dirty tracking: only writes when data has changed
abstract class TypedDeviceLocalDataSource<T extends DeviceModelSealed> {
  TypedDeviceLocalDataSource({
    required this.storageService,
    required this.listKey,
    required this.timestampKey,
    this.cacheValidityDuration = const Duration(minutes: 30),
    this.flushDebounce = const Duration(seconds: 2),
  }) : _logger = LoggerService.getLogger();

  final StorageService storageService;

  /// Storage key for the JSON array of devices
  final String listKey;

  /// Storage key for the cache timestamp
  final String timestampKey;

  /// Duration for which the cache is considered valid
  final Duration cacheValidityDuration;

  /// Debounce duration before flushing to storage
  final Duration flushDebounce;

  final Logger _logger;

  /// In-memory list of devices
  final List<T> _items = <T>[];

  /// Index for O(1) lookup by device ID
  final Map<String, int> _indexById = <String, int>{};

  /// Whether data has been loaded from storage
  bool _loaded = false;

  /// Whether there are unsaved changes
  bool _dirty = false;

  /// Last time the cache was updated
  DateTime? _lastUpdated;

  /// Timer for debounced flush
  Timer? _flushTimer;

  /// Subclass provides JSON → Model conversion
  T fromJson(Map<String, dynamic> json);

  /// Subclass provides Model → JSON conversion
  Map<String, dynamic> toJson(T model);

  /// Ensure data is loaded from storage (lazy loading)
  Future<void> _ensureLoaded() async {
    if (_loaded) {
      return;
    }
    final raw = storageService.getString(listKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as List<dynamic>;
        for (final entry in decoded) {
          if (entry is Map) {
            final model = fromJson(Map<String, dynamic>.from(entry));
            _indexById[model.deviceId] = _items.length;
            _items.add(model);
          }
        }
        _logger.d('$listKey: Loaded ${_items.length} devices from storage');
      } on Exception catch (e) {
        _logger.e('$listKey: Failed to decode: $e');
      }
    }
    _loaded = true;
  }

  /// Check if the cache is still valid
  Future<bool> isCacheValid() async {
    if (_lastUpdated != null) {
      return DateTime.now().difference(_lastUpdated!) < cacheValidityDuration;
    }
    final ts = storageService.getString(timestampKey);
    if (ts == null) {
      return false;
    }
    final parsed = DateTime.tryParse(ts);
    if (parsed == null) {
      return false;
    }
    return DateTime.now().difference(parsed) < cacheValidityDuration;
  }

  /// Get all cached devices
  Future<List<T>> getCachedDevices({bool allowStale = false}) async {
    await _ensureLoaded();
    if (!allowStale && !await isCacheValid()) {
      return <T>[];
    }
    return List<T>.unmodifiable(_items);
  }

  /// Get a single device by ID (O(1) lookup)
  Future<T?> getCachedDevice(String id) async {
    await _ensureLoaded();
    final idx = _indexById[id];
    if (idx == null) {
      return null;
    }
    return _items[idx];
  }

  /// Replace all devices (used for full sync)
  Future<void> cacheDevices(List<T> devices) async {
    await _ensureLoaded();
    _items
      ..clear()
      ..addAll(devices);
    _rebuildIndex();
    _lastUpdated = DateTime.now();
    _markDirty();
    _logger.d('$listKey: Cached ${devices.length} devices');
  }

  /// Add or update a single device
  Future<void> cacheDevice(T device) async {
    await _ensureLoaded();
    final idx = _indexById[device.deviceId];
    if (idx == null) {
      _indexById[device.deviceId] = _items.length;
      _items.add(device);
    } else {
      _items[idx] = device;
    }
    _lastUpdated = DateTime.now();
    _markDirty();
  }

  /// Remove a device by ID
  Future<void> removeDevice(String id) async {
    await _ensureLoaded();
    final idx = _indexById[id];
    if (idx != null) {
      _items.removeAt(idx);
      _rebuildIndex();
      _lastUpdated = DateTime.now();
      _markDirty();
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _ensureLoaded();
    _items.clear();
    _indexById.clear();
    _lastUpdated = null;
    _dirty = false;
    _flushTimer?.cancel();
    await storageService.remove(listKey);
    await storageService.remove(timestampKey);
    _logger.d('$listKey: Cache cleared');
  }

  /// Immediately persist to storage (bypasses debounce)
  Future<void> flushNow() async {
    _flushTimer?.cancel();
    if (!_dirty) {
      return;
    }
    final payload = _items.map(toJson).toList();
    await storageService.setString(listKey, json.encode(payload));
    final ts = (_lastUpdated ?? DateTime.now()).toIso8601String();
    await storageService.setString(timestampKey, ts);
    _dirty = false;
    _logger.d('$listKey: Flushed ${_items.length} devices to storage');
  }

  /// Get all device IDs in the cache
  Future<List<String>> getDeviceIds() async {
    await _ensureLoaded();
    return _indexById.keys.toList();
  }

  /// Get the count of cached devices
  Future<int> getDeviceCount() async {
    await _ensureLoaded();
    return _items.length;
  }

  /// Check if a device exists in the cache
  Future<bool> hasDevice(String id) async {
    await _ensureLoaded();
    return _indexById.containsKey(id);
  }

  /// Rebuild the ID index after structural changes
  void _rebuildIndex() {
    _indexById.clear();
    for (var i = 0; i < _items.length; i++) {
      _indexById[_items[i].deviceId] = i;
    }
  }

  /// Mark cache as dirty and schedule flush
  void _markDirty() {
    _dirty = true;
    _flushTimer?.cancel();
    _flushTimer = Timer(flushDebounce, flushNow);
  }

  /// Clean up resources
  void dispose() {
    _flushTimer?.cancel();
    // Flush any pending changes synchronously isn't possible,
    // so ensure flushNow() is called before dispose in production
  }
}

// ============================================================================
// Type-Specific Implementations
// ============================================================================

/// Local data source for Access Point devices.
class APLocalDataSource extends TypedDeviceLocalDataSource<APModel> {
  APLocalDataSource({required super.storageService})
      : super(
          listKey: 'cached_ap_devices',
          timestampKey: 'ap_cache_timestamp',
        );

  @override
  APModel fromJson(Map<String, dynamic> json) => APModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(APModel model) => model.toJson();
}

/// Local data source for ONT (Optical Network Terminal) devices.
class ONTLocalDataSource extends TypedDeviceLocalDataSource<ONTModel> {
  ONTLocalDataSource({required super.storageService})
      : super(
          listKey: 'cached_ont_devices',
          timestampKey: 'ont_cache_timestamp',
        );

  @override
  ONTModel fromJson(Map<String, dynamic> json) => ONTModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(ONTModel model) => model.toJson();
}

/// Local data source for Network Switch devices.
class SwitchLocalDataSource extends TypedDeviceLocalDataSource<SwitchModel> {
  SwitchLocalDataSource({required super.storageService})
      : super(
          listKey: 'cached_switch_devices',
          timestampKey: 'switch_cache_timestamp',
        );

  @override
  SwitchModel fromJson(Map<String, dynamic> json) => SwitchModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(SwitchModel model) => model.toJson();
}

/// Local data source for WLAN Controller devices.
class WLANLocalDataSource extends TypedDeviceLocalDataSource<WLANModel> {
  WLANLocalDataSource({required super.storageService})
      : super(
          listKey: 'cached_wlan_devices',
          timestampKey: 'wlan_cache_timestamp',
        );

  @override
  WLANModel fromJson(Map<String, dynamic> json) => WLANModel.fromJson(json);

  @override
  Map<String, dynamic> toJson(WLANModel model) => model.toJson();
}
