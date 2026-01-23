import 'package:rgnets_fdk/features/onboarding/data/config/onboarding_config.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_message.dart';

/// Resolves stage messages from configuration.
/// Provides a clean interface for looking up stage-specific messages.
class MessageResolver {
  const MessageResolver();

  /// Get the message for a specific device type and stage
  OnboardingMessage getMessage(String deviceType, int stage) {
    return OnboardingConfig.instance.getMessage(deviceType, stage);
  }

  /// Get the title for a specific device type and stage
  String getTitle(String deviceType, int stage) {
    return getMessage(deviceType, stage).title;
  }

  /// Get the description for a specific device type and stage
  String getDescription(String deviceType, int stage) {
    return getMessage(deviceType, stage).description;
  }

  /// Get the resolution text for a specific device type and stage
  String getResolution(String deviceType, int stage) {
    return getMessage(deviceType, stage).resolution;
  }

  /// Get the typical duration in minutes for a specific stage
  int? getTypicalDurationMinutes(String deviceType, int stage) {
    return getMessage(deviceType, stage).typicalDurationMinutes;
  }

  /// Check if a stage is a success stage
  bool isSuccessStage(String deviceType, int stage) {
    return getMessage(deviceType, stage).isSuccess;
  }

  /// Get the max stages for a device type
  int getMaxStages(String deviceType) {
    return OnboardingConfig.instance.getMaxStages(deviceType);
  }

  /// Get the success stage number for a device type
  int getSuccessStage(String deviceType) {
    return OnboardingConfig.instance.getSuccessStage(deviceType);
  }

  /// Check if onboarding is complete based on stage
  bool isOnboardingComplete(String deviceType, int stage) {
    if (stage <= 0) return false;
    return stage >= getSuccessStage(deviceType) ||
        getMessage(deviceType, stage).isSuccess;
  }

  /// Calculate if a stage is overdue based on elapsed time
  bool isStageOverdue({
    required String deviceType,
    required int stage,
    required Duration? elapsedTime,
  }) {
    if (elapsedTime == null) return false;

    final typicalMinutes = getTypicalDurationMinutes(deviceType, stage);
    if (typicalMinutes == null) return false; // Success stages are never overdue

    final multiplier =
        OnboardingConfig.instance.displaySettings.overdueThresholdMultiplier;
    final thresholdMinutes = (typicalMinutes * multiplier).ceil();

    return elapsedTime.inMinutes > thresholdMinutes;
  }
}
