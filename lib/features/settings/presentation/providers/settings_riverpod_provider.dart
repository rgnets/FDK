import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/features/settings/domain/entities/app_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_riverpod_provider.g.dart';

/// Settings state class
class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.enableNotifications,
    required this.autoSync,
    required this.syncInterval,
    this.username,
    this.siteUrl,
  });

  final String themeMode;
  final bool enableNotifications;
  final bool autoSync;
  final int syncInterval;
  final String? username;
  final String? siteUrl;

  SettingsState copyWith({
    String? themeMode,
    bool? enableNotifications,
    bool? autoSync,
    int? syncInterval,
    String? username,
    String? siteUrl,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoSync: autoSync ?? this.autoSync,
      syncInterval: syncInterval ?? this.syncInterval,
      username: username ?? this.username,
      siteUrl: siteUrl ?? this.siteUrl,
    );
  }
}

/// Main settings provider
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  final Logger _logger = Logger();
  AppSettings? _cachedSettings;

  @override
  Future<SettingsState> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    final result = await repository.getSettings();

    return result.fold(
      (failure) {
        _logger.e('Failed to load settings: ${failure.message}');
        final defaults = AppSettings.defaults();
        _cachedSettings = defaults;
        return _mapSettingsToState(defaults);
      },
      (settings) {
        _cachedSettings = settings;
        return _mapSettingsToState(settings);
      },
    );
  }

  Future<void> setThemeMode(String mode) async {
    await _updateSettings(
      (settings) => settings.copyWith(themeMode: _parseAppThemeMode(mode)),
    );
  }

  Future<void> toggleNotifications() async {
    await _updateSettings(
      (settings) =>
          settings.copyWith(enableNotifications: !settings.enableNotifications),
    );
  }

  Future<void> toggleAutoSync() async {
    await _updateSettings(
      (settings) => settings.copyWith(autoSync: !settings.autoSync),
    );
  }

  Future<void> setSyncInterval(int minutes) async {
    await _updateSettings(
      (settings) => settings.copyWith(syncIntervalMinutes: minutes),
    );
  }

  Future<void> clearAllData() async {
    final repository = ref.read(settingsRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      await repository.clearCache();
      final defaults = AppSettings.defaults();
      _cachedSettings = defaults;
      state = AsyncValue.data(_mapSettingsToState(defaults));
    } on Exception catch (error, stackTrace) {
      _logger.e('Failed to clear cache: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> _updateSettings(
    AppSettings Function(AppSettings settings) transform,
  ) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await _ensureSettings();
    final updatedSettings = transform(currentSettings);
    state = const AsyncValue.loading();
    try {
      await repository.updateSettings(updatedSettings);
      _cachedSettings = updatedSettings;
      state = AsyncValue.data(_mapSettingsToState(updatedSettings));
    } on Exception catch (error, stackTrace) {
      _logger.e('Failed to update settings: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<AppSettings> _ensureSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.getSettings();
    return result.fold(
      (failure) {
        _logger.e('Failed to get settings: ${failure.message}');
        final defaults = AppSettings.defaults();
        _cachedSettings = defaults;
        return defaults;
      },
      (settings) {
        _cachedSettings = settings;
        return settings;
      },
    );
  }

  SettingsState _mapSettingsToState(
    AppSettings settings, {
    SettingsState? previousState,
  }) {
    return SettingsState(
      themeMode: settings.themeMode.name,
      enableNotifications: settings.enableNotifications,
      autoSync: settings.autoSync,
      syncInterval: settings.syncIntervalMinutes,
      username: previousState?.username,
      siteUrl: previousState?.siteUrl,
    );
  }

  AppThemeMode _parseAppThemeMode(String mode) {
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
}
