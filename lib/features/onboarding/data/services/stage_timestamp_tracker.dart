import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/stage_tracking_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking when devices enter their current onboarding stage.
/// Persists timestamps to SharedPreferences for calculating elapsed time.
class StageTimestampTracker {
  StageTimestampTracker({
    required SharedPreferences prefs,
    Logger? logger,
  })  : _prefs = prefs,
        _logger = logger ?? Logger();

  final SharedPreferences _prefs;
  final Logger _logger;

  /// Key prefix for stage tracking data
  static const String _keyPrefix = 'onboarding_stage_';

  /// Maximum age in days before records are cleaned up
  static const int cleanupAgeDays = 7;

  /// Generate storage key for a device
  String _getKey(String deviceType, String deviceId) {
    return '$_keyPrefix${deviceType}_$deviceId';
  }

  /// Get tracking data for a device
  StageTrackingData? getTrackingData(String deviceType, String deviceId) {
    final key = _getKey(deviceType, deviceId);
    final jsonString = _prefs.getString(key);

    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return StageTrackingData.fromJson(json);
    } on Exception catch (e) {
      _logger.e('StageTimestampTracker: Failed to parse tracking data: $e');
      return null;
    }
  }

  /// Record a stage transition for a device
  Future<void> recordStageTransition({
    required String deviceType,
    required String deviceId,
    required int stage,
    required int maxStages,
  }) async {
    final key = _getKey(deviceType, deviceId);
    final existing = getTrackingData(deviceType, deviceId);

    // Check for stage regression
    if (existing != null && stage < existing.stage) {
      _logger.w(
        'StageTimestampTracker: Stage regression detected for $deviceId '
        '(${existing.stage} -> $stage). Resetting timestamp.',
      );
    }

    // Only record if stage changed or no existing data
    if (existing == null || existing.stage != stage) {
      final data = StageTrackingData.forStageTransition(
        stage: stage,
        maxStages: maxStages,
      );

      await _prefs.setString(key, jsonEncode(data.toJson()));
      _logger.d(
        'StageTimestampTracker: Recorded stage $stage for $deviceType $deviceId',
      );
    } else {
      // Update last_updated without changing entered_at
      final updated = existing.copyWith(lastUpdated: DateTime.now());
      await _prefs.setString(key, jsonEncode(updated.toJson()));
    }
  }

  /// Get elapsed time since device entered current stage
  Duration? getElapsedTime(String deviceType, String deviceId) {
    final data = getTrackingData(deviceType, deviceId);
    return data?.elapsedTime;
  }

  /// Get the timestamp when device entered current stage
  DateTime? getStageEnteredAt(String deviceType, String deviceId) {
    final data = getTrackingData(deviceType, deviceId);
    return data?.enteredAt;
  }

  /// Clear tracking data for a device
  Future<void> clearTrackingData(String deviceType, String deviceId) async {
    final key = _getKey(deviceType, deviceId);
    await _prefs.remove(key);
    _logger.d('StageTimestampTracker: Cleared tracking data for $deviceId');
  }

  /// Clean up stale records older than [cleanupAgeDays]
  Future<int> cleanupStaleRecords() async {
    var removedCount = 0;
    final keys = _prefs.getKeys().where((k) => k.startsWith(_keyPrefix));

    for (final key in keys) {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) continue;

      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final data = StageTrackingData.fromJson(json);

        if (data.isOlderThan(cleanupAgeDays)) {
          await _prefs.remove(key);
          removedCount++;
          _logger.d('StageTimestampTracker: Removed stale record: $key');
        }
      } on Exception catch (e) {
        // Remove invalid records
        await _prefs.remove(key);
        removedCount++;
        _logger.w('StageTimestampTracker: Removed invalid record: $key ($e)');
      }
    }

    if (removedCount > 0) {
      _logger.i('StageTimestampTracker: Cleaned up $removedCount stale records');
    }

    return removedCount;
  }

  /// Get all tracked device IDs
  List<String> getTrackedDeviceIds() {
    return _prefs
        .getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .map((k) => k.substring(_keyPrefix.length))
        .toList();
  }
}
