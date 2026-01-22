import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_message.freezed.dart';
part 'onboarding_message.g.dart';

/// Represents a stage message from the onboarding configuration.
/// Contains title, description, resolution text, and timing information.
@freezed
class OnboardingMessage with _$OnboardingMessage {
  const factory OnboardingMessage({
    /// Stage number (1-based)
    required int stage,

    /// Human-readable title for this stage
    required String title,

    /// Detailed description of what happens in this stage
    required String description,

    /// Resolution text - what to do if stuck in this stage
    required String resolution,

    /// Typical duration in minutes for this stage (null for success stages)
    int? typicalDurationMinutes,

    /// Whether this stage represents successful completion
    @Default(false) bool isSuccess,
  }) = _OnboardingMessage;

  factory OnboardingMessage.fromJson(Map<String, dynamic> json) =>
      _$OnboardingMessageFromJson(json);

  const OnboardingMessage._();

  /// Creates a fallback message for unknown stages
  factory OnboardingMessage.unknown(int stage) => OnboardingMessage(
        stage: stage,
        title: 'Stage $stage - Unknown status',
        description: 'This stage is not recognized by the configuration.',
        resolution: 'Please check the device status or contact support.',
        typicalDurationMinutes: 6,
        isSuccess: false,
      );
}
