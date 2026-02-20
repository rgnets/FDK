import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

/// Core onboarding state for a device.
/// Contains current stage, completion status, and timing information.
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    /// Device ID this state belongs to
    required String deviceId,

    /// Device type ('AP' or 'ONT')
    required String deviceType,

    /// Current onboarding stage (1-based, defaults to 1)
    required int currentStage,

    /// Maximum stages for this device type
    required int maxStages,

    /// Human-readable status text from backend
    String? statusText,

    /// Display text for current stage from backend
    String? stageDisplay,

    /// Suggested next action from backend
    String? nextAction,

    /// Error message if any
    String? errorText,

    /// When this stage was entered (from local tracking)
    DateTime? stageEnteredAt,

    /// Last update timestamp from backend
    DateTime? lastUpdate,

    /// Seconds since last update (from backend)
    int? lastUpdateAgeSecs,

    /// Whether onboarding is complete
    @Default(false) bool isComplete,

    /// Whether the current stage is overdue
    @Default(false) bool isOverdue,

    /// Typical duration for current stage in minutes
    int? typicalDurationMinutes,
  }) = _OnboardingState;

  const OnboardingState._();

  /// Create an empty state for devices without onboarding data
  factory OnboardingState.empty({
    required String deviceId,
    required String deviceType,
  }) =>
      OnboardingState(
        deviceId: deviceId,
        deviceType: deviceType,
        currentStage: 1,
        maxStages: 6,
      );

  /// Progress as a fraction (0.0 to 1.0)
  double get progress {
    if (maxStages == 0) return 0.0;
    return (currentStage / maxStages).clamp(0.0, 1.0);
  }

  /// Whether onboarding has started
  bool get hasStarted => currentStage > 0;

  /// Elapsed time since entering current stage
  Duration? get elapsedTime {
    if (stageEnteredAt == null) return null;
    return DateTime.now().difference(stageEnteredAt!);
  }

  /// Elapsed time in minutes
  int? get elapsedMinutes => elapsedTime?.inMinutes;

  /// Formatted elapsed time string (e.g., "5m 30s" or "1h 15m")
  String? get elapsedTimeFormatted {
    final elapsed = elapsedTime;
    if (elapsed == null) return null;

    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    final seconds = elapsed.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
