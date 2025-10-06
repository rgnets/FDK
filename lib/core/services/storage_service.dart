import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage
class StorageService {
  
  StorageService(this._prefs);
  final SharedPreferences _prefs;
  
  // Keys
  static const String _keyApiUrl = 'api_url';
  static const String _keyApiToken = 'api_token';
  static const String _keyUsername = 'username';
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyEnableNotifications = 'enable_notifications';
  static const String _keyAutoSync = 'auto_sync';
  static const String _keySyncInterval = 'sync_interval';
  
  // Auth
  Future<void> saveCredentials({
    required String apiUrl,
    required String apiToken,
    required String username,
  }) async {
    await _prefs.setString(_keyApiUrl, apiUrl);
    await _prefs.setString(_keyApiToken, apiToken);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setBool(_keyIsAuthenticated, true);
  }
  
  Future<void> clearCredentials() async {
    await _prefs.remove(_keyApiUrl);
    await _prefs.remove(_keyApiToken);
    await _prefs.remove(_keyUsername);
    await _prefs.setBool(_keyIsAuthenticated, false);
  }
  
  String? get apiUrl => _prefs.getString(_keyApiUrl);
  String? get apiToken => _prefs.getString(_keyApiToken);
  String? get username => _prefs.getString(_keyUsername);
  bool get isAuthenticated => _prefs.getBool(_keyIsAuthenticated) ?? false;
  
  // Settings
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'dark';
  Future<void> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);
  
  bool get enableNotifications => _prefs.getBool(_keyEnableNotifications) ?? true;
  Future<void> setEnableNotifications({required bool value}) => _prefs.setBool(_keyEnableNotifications, value);
  
  bool get autoSync => _prefs.getBool(_keyAutoSync) ?? true;
  Future<void> setAutoSync({required bool value}) => _prefs.setBool(_keyAutoSync, value);
  
  int get syncInterval => _prefs.getInt(_keySyncInterval) ?? 15;
  Future<void> setSyncInterval(int minutes) => _prefs.setInt(_keySyncInterval, minutes);
  
  // Generic methods
  Future<bool> setBool(String key, {required bool value}) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);
  
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);
  
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);
  
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}