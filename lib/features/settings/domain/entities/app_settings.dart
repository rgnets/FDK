import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    // Display Settings
    required AppThemeMode themeMode,
    required bool showDebugInfo,
    required bool enableHapticFeedback,
    
    // Scanner Settings
    required int scanTimeoutSeconds,
    required bool enableScanSound,
    required bool enableContinuousScanning,
    
    // Network Settings
    required int wsTimeoutSeconds,
    required bool enableOfflineMode,
    required int cacheExpirationHours,
    
    // Notification Settings
    required bool enableNotifications,
    required bool enableCriticalAlerts,
    required bool enableInfoAlerts,
    
    // Data Settings
    required bool autoSync,
    required int syncIntervalMinutes,
    required bool useCellularData,
    
    // Developer Settings
    required bool enableLogging,
    required bool showPerformanceOverlay,
    required bool enableMockData,
  }) = _AppSettings;

  const AppSettings._();

  // Factory constructor with default values
  factory AppSettings.defaults() => const AppSettings(
        themeMode: AppThemeMode.system,
        showDebugInfo: false,
        enableHapticFeedback: true,
        scanTimeoutSeconds: 6,
        enableScanSound: true,
        enableContinuousScanning: false,
        wsTimeoutSeconds: 30,
        enableOfflineMode: true,
        cacheExpirationHours: 12,
        enableNotifications: true,
        enableCriticalAlerts: true,
        enableInfoAlerts: true,
        autoSync: true,
        syncIntervalMinutes: 3,
        useCellularData: true,
        enableLogging: false,
        showPerformanceOverlay: false,
        enableMockData: false,
      );
}

enum AppThemeMode {
  light,
  dark,
  system,
}