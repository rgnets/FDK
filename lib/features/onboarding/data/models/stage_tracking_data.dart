import 'package:freezed_annotation/freezed_annotation.dart';

part 'stage_tracking_data.freezed.dart';
part 'stage_tracking_data.g.dart';

/// Persistent data model for tracking when a device entered its current stage.
/// Stored in SharedPreferences for calculating elapsed time per stage.
@freezed
class StageTrackingData with _$StageTrackingData {
  const factory StageTrackingData({
    /// Current stage number
    required int stage,

    /// Maximum stages for this device type
    required int maxStages,

    /// When the device entered this stage
    @JsonKey(name: 'entered_at') required DateTime enteredAt,

    /// Last time this record was updated
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
  }) = _StageTrackingData;

  factory StageTrackingData.fromJson(Map<String, dynamic> json) =>
      _$StageTrackingDataFromJson(json);

  const StageTrackingData._();

  /// Calculate elapsed time since entering this stage
  Duration get elapsedTime => DateTime.now().difference(enteredAt);

  /// Check if this record is stale (older than specified days)
  bool isOlderThan(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return lastUpdated.isBefore(cutoff);
  }

  /// Create a new record for a stage transition
  factory StageTrackingData.forStageTransition({
    required int stage,
    required int maxStages,
  }) {
    final now = DateTime.now();
    return StageTrackingData(
      stage: stage,
      maxStages: maxStages,
      enteredAt: now,
      lastUpdated: now,
    );
  }
}
