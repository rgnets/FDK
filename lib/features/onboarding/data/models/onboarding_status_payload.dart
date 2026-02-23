import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_status_payload.freezed.dart';
part 'onboarding_status_payload.g.dart';

/// Typed model for WebSocket onboarding status payload.
/// Replaces `Map<String, dynamic>?` for type safety at the data layer.
///
/// This model is used for both AP and ONT onboarding status:
/// - APModel: `ap_onboarding_status`
/// - ONTModel: `ont_onboarding_status`
@freezed
class OnboardingStatusPayload with _$OnboardingStatusPayload {
  const factory OnboardingStatusPayload({
    /// Current onboarding stage (1-6 for ONT, 1-6 for AP, 0 = not started)
    int? stage,

    /// Maximum number of stages (6 for ONT, 6 for AP)
    @JsonKey(name: 'max_stages') int? maxStages,

    /// Human-readable status text
    String? status,

    /// Display text for current stage
    @JsonKey(name: 'stage_display') String? stageDisplay,

    /// Suggested next action
    @JsonKey(name: 'next_action') String? nextAction,

    /// Error message if any
    String? error,

    /// Last update timestamp
    @JsonKey(name: 'last_update') DateTime? lastUpdate,

    /// Last seen timestamp (AP only)
    @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,

    /// Seconds since last update (from backend)
    @JsonKey(name: 'last_update_age_secs') int? lastUpdateAgeSecs,

    /// Explicit completion flag
    @JsonKey(name: 'onboarding_complete') bool? onboardingComplete,
  }) = _OnboardingStatusPayload;

  factory OnboardingStatusPayload.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStatusPayloadFromJson(json);

  const OnboardingStatusPayload._();
}

/// Extension methods for OnboardingStatusPayload
extension OnboardingStatusPayloadX on OnboardingStatusPayload {
  /// Returns true if onboarding is complete based on available data
  bool get isComplete {
    // Priority 1: Explicit completion flag
    if (onboardingComplete == true) return true;

    // Priority 2: Stage equals max stages (success stage)
    if (stage != null && maxStages != null && stage! >= maxStages!) {
      return true;
    }

    return false;
  }

  /// Returns true if the device has started onboarding
  bool get hasStarted => stage != null && stage! > 0;

  /// Returns progress as a fraction (0.0 to 1.0)
  double get progress {
    if (stage == null || maxStages == null || maxStages == 0) return 0.0;
    return (stage! / maxStages!).clamp(0.0, 1.0);
  }
}
