import 'package:logger/logger.dart';
import 'package:rgnets_fdk/features/settings/domain/entities/app_settings.dart';
import 'package:rgnets_fdk/features/settings/domain/repositories/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_riverpod_provider.g.dart';

/// Repository provider (re-export from core providers)
@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  return ref.watch(settingsRepositoryProvider);
}

/// Settings state class
class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.enableNotifications,
    required this.autoSync,
    required this.syncInterval,
    this.username,
    this.apiUrl,
  });

  final String themeMode;
  final bool enableNotifications;
  final bool autoSync;
  final int syncInterval;
  final String? username;
  final String? apiUrl;

  SettingsState copyWith({
    String? themeMode,
    bool? enableNotifications,
    bool? autoSync,
    int? syncInterval,
    String? username,
    String? apiUrl,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoSync: autoSync ?? this.autoSync,
      syncInterval: syncInterval ?? this.syncInterval,
      username: username ?? this.username,
      apiUrl: apiUrl ?? this.apiUrl,
    );
  }
}

/// Main settings provider
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  final Logger _logger = Logger();
  
  @override
  SettingsState build() {
    // Load initial settings from repository
    _loadSettings();
    // Return default state initially
    return const SettingsState(
      themeMode: 'dark',
      enableNotifications: true,
      autoSync: true,
      syncInterval: 3,
    );
  }
  
  Future<void> _loadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    final result = await repository.getSettings();
    result.fold(
      (failure) => _logger.e('Failed to load settings: ${failure.message}'),
      (settings) {
        state = SettingsState(
          themeMode: settings.themeMode.name,
          enableNotifications: settings.enableNotifications,
          autoSync: settings.autoSync,
          syncInterval: settings.syncIntervalMinutes,
        );
      },
    );
  }

  Future<void> setThemeMode(String mode) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await repository.getSettings();
    currentSettings.fold(
      (failure) => _logger.e('Failed to get settings: ${failure.message}'),
      (settings) async {
        final updatedSettings = settings.copyWith(
          themeMode: _parseAppThemeMode(mode),
        );
        await repository.updateSettings(updatedSettings);
        state = state.copyWith(themeMode: mode);
      },
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

  Future<void> toggleNotifications() async {
    final repository = ref.read(settingsRepositoryProvider);
    final newValue = !state.enableNotifications;
    final currentSettings = await repository.getSettings();
    currentSettings.fold(
      (failure) => _logger.e('Failed to get settings: ${failure.message}'),
      (settings) async {
        final updatedSettings = settings.copyWith(
          enableNotifications: newValue,
        );
        await repository.updateSettings(updatedSettings);
        state = state.copyWith(enableNotifications: newValue);
      },
    );
  }

  Future<void> toggleAutoSync() async {
    final repository = ref.read(settingsRepositoryProvider);
    final newValue = !state.autoSync;
    final currentSettings = await repository.getSettings();
    currentSettings.fold(
      (failure) => _logger.e('Failed to get settings: ${failure.message}'),
      (settings) async {
        final updatedSettings = settings.copyWith(
          autoSync: newValue,
        );
        await repository.updateSettings(updatedSettings);
        state = state.copyWith(autoSync: newValue);
      },
    );
  }

  Future<void> setSyncInterval(int minutes) async {
    final repository = ref.read(settingsRepositoryProvider);
    final currentSettings = await repository.getSettings();
    currentSettings.fold(
      (failure) => _logger.e('Failed to get settings: ${failure.message}'),
      (settings) async {
        final updatedSettings = settings.copyWith(
          syncIntervalMinutes: minutes,
        );
        await repository.updateSettings(updatedSettings);
        state = state.copyWith(syncInterval: minutes);
      },
    );
  }

  Future<void> clearAllData() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.clearCache();
    
    // Reload settings after clearing
    await _loadSettings();
  }
}