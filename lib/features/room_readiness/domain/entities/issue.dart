import 'package:freezed_annotation/freezed_annotation.dart';

part 'issue.freezed.dart';
part 'issue.g.dart';

/// Severity levels for issues detected in devices
enum IssueSeverity {
  critical, // Device offline, system failures, blocking issues
  warning, // Configuration errors, degraded functionality, non-blocking issues
  info // Documentation missing, minor issues, informational items
}

/// Category of issues for better organization
enum IssueCategory {
  connectivity,
  configuration,
  performance,
  compliance,
  maintenance,
  documentation,
  onboarding,
}

/// Issue detected in a room or device
@freezed
class Issue with _$Issue {
  const factory Issue({
    required String id,
    required String code,
    required String title,
    required String description,
    required IssueSeverity severity,
    required IssueCategory category,
    required DateTime detectedAt,
    @Default({}) Map<String, dynamic> metadata,
    String? resolution,
    @Default(false) bool isAutoDismissible,
    Duration? autoDismissAfter,
  }) = _Issue;

  const Issue._();

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);

  /// Factory constructor for common device offline issue
  factory Issue.deviceOffline({
    required int deviceId,
    required String deviceName,
    required String deviceType,
    DateTime? detectedAt,
  }) {
    return Issue(
      id: 'offline_${deviceType}_$deviceId',
      code: 'DEVICE_OFFLINE',
      title: '$deviceType Offline',
      description: '$deviceName is currently offline and unreachable',
      severity: IssueSeverity.critical,
      category: IssueCategory.connectivity,
      detectedAt: detectedAt ?? DateTime.now(),
      metadata: {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
      },
      resolution: 'Check network connectivity and power status of the device',
    );
  }

  /// Factory constructor for missing images issue
  factory Issue.missingImages({
    required int deviceId,
    required String deviceName,
    required String deviceType,
    DateTime? detectedAt,
  }) {
    return Issue(
      id: 'missing_images_${deviceType}_$deviceId',
      code: 'MISSING_IMAGES',
      title: 'Missing Device Images',
      description: '$deviceName has no images attached for documentation',
      severity: IssueSeverity.info,
      category: IssueCategory.documentation,
      detectedAt: detectedAt ?? DateTime.now(),
      metadata: {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
      },
      resolution: 'Capture and upload images of the device installation',
      isAutoDismissible: true,
      autoDismissAfter: const Duration(days: 7),
    );
  }

  /// Factory constructor for missing speed test results issue
  factory Issue.missingSpeedTest({
    required int deviceId,
    required String deviceName,
    DateTime? detectedAt,
  }) {
    return Issue(
      id: 'missing_speed_test_AP_$deviceId',
      code: 'MISSING_SPEED_TEST',
      title: 'Missing Speed Test',
      description: '$deviceName has no speed test results',
      severity: IssueSeverity.info,
      category: IssueCategory.performance,
      detectedAt: detectedAt ?? DateTime.now(),
      metadata: {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': 'AP',
      },
      resolution:
          'Run a speed test using this access point to verify performance',
      isAutoDismissible: true,
      autoDismissAfter: const Duration(days: 30),
    );
  }

  /// Factory constructor for onboarding issues
  factory Issue.onboardingIncomplete({
    required int deviceId,
    required String deviceName,
    required String deviceType,
    required int currentStage,
    required int totalStages,
    DateTime? detectedAt,
    Map<String, dynamic>? additionalMetadata,
  }) {
    final progress = (currentStage / totalStages * 100).round();

    return Issue(
      id: 'onboarding_${deviceType}_$deviceId',
      code: 'ONBOARDING_INCOMPLETE',
      title: 'Onboarding Incomplete',
      description:
          '$deviceName is at stage $currentStage of $totalStages ($progress%)',
      severity: IssueSeverity.warning,
      category: IssueCategory.onboarding,
      detectedAt: detectedAt ?? DateTime.now(),
      metadata: {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
        'currentStage': currentStage,
        'totalStages': totalStages,
        'progress': progress,
        if (additionalMetadata != null) ...additionalMetadata,
      },
      resolution: 'Complete the remaining onboarding steps for this device',
    );
  }

  /// Factory constructor for configuration sync issues
  factory Issue.configSyncFailed({
    required int deviceId,
    required String deviceName,
    required String deviceType,
    required DateTime lastAttempt,
    DateTime? lastSuccess,
    DateTime? detectedAt,
  }) {
    final hoursSinceAttempt = DateTime.now().difference(lastAttempt).inHours;
    return Issue(
      id: 'config_sync_${deviceType}_$deviceId',
      code: 'CONFIG_SYNC_FAILED',
      title: 'Configuration Sync Failed',
      description:
          '$deviceName failed to sync configuration $hoursSinceAttempt hours ago',
      severity: hoursSinceAttempt > 24
          ? IssueSeverity.critical
          : IssueSeverity.warning,
      category: IssueCategory.configuration,
      detectedAt: detectedAt ?? DateTime.now(),
      metadata: {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceType': deviceType,
        'lastAttempt': lastAttempt.toIso8601String(),
        'lastSuccess': lastSuccess?.toIso8601String(),
        'hoursSinceAttempt': hoursSinceAttempt,
      },
      resolution: 'Check device connectivity and retry configuration sync',
    );
  }
}
