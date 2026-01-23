import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:rgnets_fdk/core/utils/safe_parser.dart';
import 'package:rgnets_fdk/features/onboarding/data/models/onboarding_message.dart';

/// Configuration loader for onboarding messages.
/// Loads and validates the onboarding_messages.json asset at app startup.
class OnboardingConfig {
  OnboardingConfig._();

  static OnboardingConfig? _instance;
  static OnboardingConfig get instance {
    if (_instance == null) {
      throw StateError(
        'OnboardingConfig not initialized. Call OnboardingConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Whether the config has been initialized
  static bool get isInitialized => _instance != null;

  late final String version;
  late final bool strictMode;
  late final DisplaySettings displaySettings;
  late final Map<String, DeviceConfig> _deviceConfigs;

  /// Initialize the configuration from the asset file.
  /// Must be called during app startup before using the config.
  static Future<void> initialize() async {
    if (_instance != null) return;

    final jsonString = await rootBundle.loadString(
      'assets/config/onboarding_messages.json',
    );
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    final config = OnboardingConfig._();
    config._parseConfig(json);
    _instance = config;
  }

  void _parseConfig(Map<String, dynamic> json) {
    version = SafeParser.parseStringOr(json['version'], '1.0.0');
    strictMode = SafeParser.parseBoolOr(json['strict_mode'], true);

    final displayJson = SafeParser.parseMap(json['display_settings']) ?? {};
    displaySettings = DisplaySettings(
      showElapsedTime: SafeParser.parseBoolOr(
        displayJson['show_elapsed_time'],
        true,
      ),
      showOverdueWarning: SafeParser.parseBoolOr(
        displayJson['show_overdue_warning'],
        true,
      ),
      refreshIntervalSeconds: SafeParser.parseIntOr(
        displayJson['refresh_interval_seconds'],
        10,
      ),
      overdueThresholdMultiplier: SafeParser.parseDoubleOr(
        displayJson['overdue_threshold_multiplier'],
        1.0,
      ),
    );

    _deviceConfigs = {};
    final devicesJson = SafeParser.parseMap(json['devices']) ?? {};

    for (final entry in devicesJson.entries) {
      final deviceType = entry.key;
      final deviceJson = SafeParser.parseMap(entry.value);
      if (deviceJson == null) continue;

      final maxStages = SafeParser.parseIntOr(deviceJson['max_stages'], 0);
      final successStage = SafeParser.parseIntOr(deviceJson['success_stage'], maxStages);

      final stagesJson = SafeParser.parseMap(deviceJson['stages']) ?? {};
      final messages = <int, OnboardingMessage>{};

      for (final stageEntry in stagesJson.entries) {
        final stageNum = SafeParser.parseInt(stageEntry.key);
        if (stageNum == null) continue;

        final stageJson = SafeParser.parseMap(stageEntry.value);
        if (stageJson == null) continue;

        messages[stageNum] = OnboardingMessage(
          stage: stageNum,
          title: SafeParser.parseStringOr(stageJson['title'], 'Stage $stageNum'),
          description: SafeParser.parseStringOr(
            stageJson['description'],
            'No description available.',
          ),
          resolution: SafeParser.parseStringOr(
            stageJson['resolution'],
            'No resolution available.',
          ),
          typicalDurationMinutes: SafeParser.parseInt(
            stageJson['typical_duration_minutes'],
          ),
          isSuccess: SafeParser.parseBoolOr(stageJson['is_success'], false),
        );
      }

      _deviceConfigs[deviceType] = DeviceConfig(
        deviceType: deviceType,
        maxStages: maxStages,
        successStage: successStage,
        messages: messages,
      );
    }

    // Validate config in strict mode
    if (strictMode) {
      _validateConfig();
    }
  }

  void _validateConfig() {
    if (_deviceConfigs.isEmpty) {
      throw StateError('OnboardingConfig: No device configurations found');
    }

    for (final config in _deviceConfigs.values) {
      if (config.maxStages <= 0) {
        throw StateError(
          'OnboardingConfig: Invalid max_stages for ${config.deviceType}',
        );
      }

      // Verify all stages have messages
      for (var i = 1; i <= config.maxStages; i++) {
        if (!config.messages.containsKey(i)) {
          throw StateError(
            'OnboardingConfig: Missing message for ${config.deviceType} stage $i',
          );
        }
      }
    }
  }

  /// Get device configuration for a device type
  DeviceConfig? getDeviceConfig(String deviceType) {
    return _deviceConfigs[deviceType];
  }

  /// Get message for a specific device type and stage
  OnboardingMessage getMessage(String deviceType, int stage) {
    final config = _deviceConfigs[deviceType];
    if (config == null) {
      return OnboardingMessage.unknown(stage);
    }
    return config.messages[stage] ?? OnboardingMessage.unknown(stage);
  }

  /// Get max stages for a device type
  int getMaxStages(String deviceType) {
    return _deviceConfigs[deviceType]?.maxStages ?? 0;
  }

  /// Get success stage for a device type
  int getSuccessStage(String deviceType) {
    final config = _deviceConfigs[deviceType];
    return config?.successStage ?? config?.maxStages ?? 0;
  }

  /// Check if a stage is the success stage for a device type
  bool isSuccessStage(String deviceType, int stage) {
    return stage == getSuccessStage(deviceType);
  }

  /// Get typical duration in minutes for a stage
  int? getTypicalDurationMinutes(String deviceType, int stage) {
    return getMessage(deviceType, stage).typicalDurationMinutes;
  }
}

/// Display settings from configuration
class DisplaySettings {
  const DisplaySettings({
    required this.showElapsedTime,
    required this.showOverdueWarning,
    required this.refreshIntervalSeconds,
    required this.overdueThresholdMultiplier,
  });

  final bool showElapsedTime;
  final bool showOverdueWarning;
  final int refreshIntervalSeconds;
  final double overdueThresholdMultiplier;
}

/// Configuration for a specific device type
class DeviceConfig {
  const DeviceConfig({
    required this.deviceType,
    required this.maxStages,
    required this.successStage,
    required this.messages,
  });

  final String deviceType;
  final int maxStages;
  final int successStage;
  final Map<int, OnboardingMessage> messages;
}
