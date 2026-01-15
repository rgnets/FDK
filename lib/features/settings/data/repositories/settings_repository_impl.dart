import 'package:fpdart/fpdart.dart';
import 'package:rgnets_fdk/core/errors/failures.dart';
import 'package:rgnets_fdk/features/settings/domain/entities/app_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  static const String _themeKey = 'theme_mode';
  static const String _showDebugKey = 'show_debug_info';
  static const String _hapticKey = 'enable_haptic_feedback';
  static const String _scanTimeoutKey = 'scan_timeout_seconds';
  static const String _scanSoundKey = 'enable_scan_sound';
  static const String _continuousScanKey = 'enable_continuous_scanning';
  static const String _apiTimeoutKey = 'api_timeout_seconds';
  static const String _offlineModeKey = 'enable_offline_mode';
  static const String _cacheExpirationKey = 'cache_expiration_hours';
  static const String _notificationsKey = 'enable_notifications';
  static const String _criticalAlertsKey = 'enable_critical_alerts';
  static const String _infoAlertsKey = 'enable_info_alerts';
  static const String _autoSyncKey = 'auto_sync';
  static const String _syncIntervalKey = 'sync_interval_minutes';
  static const String _cellularDataKey = 'use_cellular_data';
  static const String _loggingKey = 'enable_logging';
  static const String _performanceKey = 'show_performance_overlay';
  static const String _mockDataKey = 'enable_mock_data';

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settings = AppSettings(
        themeMode: _getThemeMode(),
        showDebugInfo: _prefs.getBool(_showDebugKey) ?? false,
        enableHapticFeedback: _prefs.getBool(_hapticKey) ?? true,
        scanTimeoutSeconds: _prefs.getInt(_scanTimeoutKey) ?? 6,
        enableScanSound: _prefs.getBool(_scanSoundKey) ?? true,
        enableContinuousScanning: _prefs.getBool(_continuousScanKey) ?? false,
        wsTimeoutSeconds: _prefs.getInt(_apiTimeoutKey) ?? 30,
        enableOfflineMode: _prefs.getBool(_offlineModeKey) ?? true,
        cacheExpirationHours: _prefs.getInt(_cacheExpirationKey) ?? 12,
        enableNotifications: _prefs.getBool(_notificationsKey) ?? true,
        enableCriticalAlerts: _prefs.getBool(_criticalAlertsKey) ?? true,
        enableInfoAlerts: _prefs.getBool(_infoAlertsKey) ?? true,
        autoSync: _prefs.getBool(_autoSyncKey) ?? true,
        syncIntervalMinutes: _prefs.getInt(_syncIntervalKey) ?? 30,
        useCellularData: _prefs.getBool(_cellularDataKey) ?? true,
        enableLogging: _prefs.getBool(_loggingKey) ?? false,
        showPerformanceOverlay: _prefs.getBool(_performanceKey) ?? false,
        enableMockData: _prefs.getBool(_mockDataKey) ?? false,
      );
      
      return Right(settings);
    } on Exception catch (e) {
      return Left(CacheFailure(message: 'Failed to load settings: $e'));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> updateSettings(AppSettings settings) async {
    try {
      await _prefs.setString(_themeKey, settings.themeMode.name);
      await _prefs.setBool(_showDebugKey, settings.showDebugInfo);
      await _prefs.setBool(_hapticKey, settings.enableHapticFeedback);
      await _prefs.setInt(_scanTimeoutKey, settings.scanTimeoutSeconds);
      await _prefs.setBool(_scanSoundKey, settings.enableScanSound);
      await _prefs.setBool(_continuousScanKey, settings.enableContinuousScanning);
      await _prefs.setInt(_apiTimeoutKey, settings.wsTimeoutSeconds);
      await _prefs.setBool(_offlineModeKey, settings.enableOfflineMode);
      await _prefs.setInt(_cacheExpirationKey, settings.cacheExpirationHours);
      await _prefs.setBool(_notificationsKey, settings.enableNotifications);
      await _prefs.setBool(_criticalAlertsKey, settings.enableCriticalAlerts);
      await _prefs.setBool(_infoAlertsKey, settings.enableInfoAlerts);
      await _prefs.setBool(_autoSyncKey, settings.autoSync);
      await _prefs.setInt(_syncIntervalKey, settings.syncIntervalMinutes);
      await _prefs.setBool(_cellularDataKey, settings.useCellularData);
      await _prefs.setBool(_loggingKey, settings.enableLogging);
      await _prefs.setBool(_performanceKey, settings.showPerformanceOverlay);
      await _prefs.setBool(_mockDataKey, settings.enableMockData);
      
      return Right(settings);
    } on Exception catch (e) {
      return Left(CacheFailure(message: 'Failed to save settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetSettings() async {
    try {
      // Remove all settings keys
      await _prefs.remove(_themeKey);
      await _prefs.remove(_showDebugKey);
      await _prefs.remove(_hapticKey);
      await _prefs.remove(_scanTimeoutKey);
      await _prefs.remove(_scanSoundKey);
      await _prefs.remove(_continuousScanKey);
      await _prefs.remove(_apiTimeoutKey);
      await _prefs.remove(_offlineModeKey);
      await _prefs.remove(_cacheExpirationKey);
      await _prefs.remove(_notificationsKey);
      await _prefs.remove(_criticalAlertsKey);
      await _prefs.remove(_infoAlertsKey);
      await _prefs.remove(_autoSyncKey);
      await _prefs.remove(_syncIntervalKey);
      await _prefs.remove(_cellularDataKey);
      await _prefs.remove(_loggingKey);
      await _prefs.remove(_performanceKey);
      await _prefs.remove(_mockDataKey);
      
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure(message: 'Failed to reset settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      // Clear all non-settings data
      final keys = _prefs.getKeys();
      for (final key in keys) {
        // Don't clear settings keys
        if (!_isSettingsKey(key) && !_isAuthKey(key)) {
          await _prefs.remove(key);
        }
      }
      return const Right(null);
    } on Exception catch (e) {
      return Left(CacheFailure(message: 'Failed to clear cache: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportSettings() async {
    try {
      final settingsResult = await getSettings();
      return settingsResult.fold(
        Left.new,
        (settings) => Right({
          'themeMode': settings.themeMode.name,
          'showDebugInfo': settings.showDebugInfo,
          'enableHapticFeedback': settings.enableHapticFeedback,
          'scanTimeoutSeconds': settings.scanTimeoutSeconds,
          'enableScanSound': settings.enableScanSound,
          'enableContinuousScanning': settings.enableContinuousScanning,
          'wsTimeoutSeconds': settings.wsTimeoutSeconds,
          'enableOfflineMode': settings.enableOfflineMode,
          'cacheExpirationHours': settings.cacheExpirationHours,
          'enableNotifications': settings.enableNotifications,
          'enableCriticalAlerts': settings.enableCriticalAlerts,
          'enableInfoAlerts': settings.enableInfoAlerts,
          'autoSync': settings.autoSync,
          'syncIntervalMinutes': settings.syncIntervalMinutes,
          'useCellularData': settings.useCellularData,
          'enableLogging': settings.enableLogging,
          'showPerformanceOverlay': settings.showPerformanceOverlay,
          'enableMockData': settings.enableMockData,
        }),
      );
    } on Exception catch (e) {
      return Left(CacheFailure(message: 'Failed to export settings: $e'));
    }
  }

  @override
  Future<Either<Failure, AppSettings>> importSettings(Map<String, dynamic> data) async {
    try {
      final settings = AppSettings(
        themeMode: _parseThemeMode(data['themeMode'] as String?),
        showDebugInfo: data['showDebugInfo'] as bool? ?? false,
        enableHapticFeedback: data['enableHapticFeedback'] as bool? ?? true,
        scanTimeoutSeconds: data['scanTimeoutSeconds'] as int? ?? 6,
        enableScanSound: data['enableScanSound'] as bool? ?? true,
        enableContinuousScanning: data['enableContinuousScanning'] as bool? ?? false,
        wsTimeoutSeconds: data['wsTimeoutSeconds'] as int? ?? 30,
        enableOfflineMode: data['enableOfflineMode'] as bool? ?? true,
        cacheExpirationHours: data['cacheExpirationHours'] as int? ?? 12,
        enableNotifications: data['enableNotifications'] as bool? ?? true,
        enableCriticalAlerts: data['enableCriticalAlerts'] as bool? ?? true,
        enableInfoAlerts: data['enableInfoAlerts'] as bool? ?? true,
        autoSync: data['autoSync'] as bool? ?? true,
        syncIntervalMinutes: data['syncIntervalMinutes'] as int? ?? 30,
        useCellularData: data['useCellularData'] as bool? ?? true,
        enableLogging: data['enableLogging'] as bool? ?? false,
        showPerformanceOverlay: data['showPerformanceOverlay'] as bool? ?? false,
        enableMockData: data['enableMockData'] as bool? ?? false,
      );
      return updateSettings(settings);
    } on Exception catch (e) {
      return Left(ValidationFailure(message: 'Invalid settings data: $e'));
    }
  }

  AppThemeMode _getThemeMode() {
    final themeString = _prefs.getString(_themeKey) ?? 'system';
    return _parseThemeMode(themeString);
  }
  
  AppThemeMode _parseThemeMode(String? mode) {
    switch (mode) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  bool _isSettingsKey(String key) {
    return key == _themeKey ||
        key == _showDebugKey ||
        key == _hapticKey ||
        key == _scanTimeoutKey ||
        key == _scanSoundKey ||
        key == _continuousScanKey ||
        key == _apiTimeoutKey ||
        key == _offlineModeKey ||
        key == _cacheExpirationKey ||
        key == _notificationsKey ||
        key == _criticalAlertsKey ||
        key == _infoAlertsKey ||
        key == _autoSyncKey ||
        key == _syncIntervalKey ||
        key == _cellularDataKey ||
        key == _loggingKey ||
        key == _performanceKey ||
        key == _mockDataKey;
  }

  bool _isAuthKey(String key) {
    // Preserve authentication-related keys
    return key.contains('auth') || 
           key.contains('token') || 
           key.contains('user') ||
           key.contains('api_url') ||
           key.contains('api_key');
  }
}