import 'dart:convert';

import 'package:rgnets_fdk/features/auth/data/models/auth_attempt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage
class StorageService {
  StorageService(this._prefs);
  final SharedPreferences _prefs;

  // Keys
  static const String _keyApiUrl = 'api_url';
  static const String _keyApiToken = 'api_token';
  static const String _keyUsername = 'username';
  static const String _keySiteName = 'site_name';
  static const String _keyAuthIssuedAt = 'auth_issued_at';
  static const String _keyAuthSignature = 'auth_signature';
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keySessionToken = 'ws_session_token';
  static const String _keySessionExpiresAt = 'ws_session_expires_at';
  static const String _keyAuthAttempts = 'auth_attempts';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyEnableNotifications = 'enable_notifications';
  static const String _keyAutoSync = 'auto_sync';
  static const String _keySyncInterval = 'sync_interval';

  // Auth
  Future<void> saveCredentials({
    required String apiUrl,
    required String apiToken,
    required String username,
    String? siteName,
    String? issuedAtIso,
    String? signature,
    bool markAuthenticated = false,
  }) async {
    await _prefs.setString(_keyApiUrl, apiUrl);
    await _prefs.setString(_keyApiToken, apiToken);
    await _prefs.setString(_keyUsername, username);
    if (siteName != null) {
      await _prefs.setString(_keySiteName, siteName);
    }
    if (issuedAtIso != null) {
      await _prefs.setString(_keyAuthIssuedAt, issuedAtIso);
    }
    if (signature != null) {
      await _prefs.setString(_keyAuthSignature, signature);
    }
    await _prefs.setBool(_keyIsAuthenticated, markAuthenticated);
  }

  Future<void> saveSession({
    required String token,
    required DateTime expiresAt,
  }) async {
    await _prefs.setString(_keySessionToken, token);
    await _prefs.setString(
      _keySessionExpiresAt,
      expiresAt.toUtc().toIso8601String(),
    );
  }

  Future<void> clearCredentials() async {
    await _prefs.remove(_keyApiUrl);
    await _prefs.remove(_keyApiToken);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keySiteName);
    await _prefs.remove(_keyAuthIssuedAt);
    await _prefs.remove(_keyAuthSignature);
    await clearSession();
    await _prefs.setBool(_keyIsAuthenticated, false);
  }

  Future<void> setAuthenticated({required bool value}) async {
    await _prefs.setBool(_keyIsAuthenticated, value);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keySessionToken);
    await _prefs.remove(_keySessionExpiresAt);
  }

  Future<void> migrateLegacyCredentialsIfNeeded() async {
    const legacyFqdnKey = 'att_fe_tool.fqdn';
    const legacyLoginKey = 'att_fe_tool.login';
    const legacyApiKey = 'att_fe_tool.api_key';

    final hasLegacy = _prefs.containsKey(legacyFqdnKey) &&
        _prefs.containsKey(legacyLoginKey) &&
        _prefs.containsKey(legacyApiKey);
    if (!hasLegacy) {
      return;
    }

    final fqdn = _prefs.getString(legacyFqdnKey) ?? '';
    final login = _prefs.getString(legacyLoginKey) ?? '';
    final apiKey = _prefs.getString(legacyApiKey) ?? '';

    if (fqdn.isNotEmpty && login.isNotEmpty && apiKey.isNotEmpty) {
      await saveCredentials(
        apiUrl: 'https://$fqdn',
        apiToken: apiKey,
        username: login,
        markAuthenticated: false,
      );
    }

    await Future.wait<bool>([
      _prefs.remove(legacyFqdnKey),
      _prefs.remove(legacyLoginKey),
      _prefs.remove(legacyApiKey),
    ]);
  }

  Future<void> logAuthAttempt(AuthAttempt attempt) async {
    final attempts = getAuthAttempts()..insert(0, attempt);

    // Cap history to last 50 attempts to avoid uncontrolled growth
    final trimmed = attempts.take(50).toList();
    final payload = trimmed.map((a) => a.toJson()).toList();
    await _prefs.setString(_keyAuthAttempts, jsonEncode(payload));
  }

  List<AuthAttempt> getAuthAttempts() {
    final raw = _prefs.getString(_keyAuthAttempts);
    if (raw == null || raw.isEmpty) {
      return <AuthAttempt>[];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((dynamic entry) {
            if (entry is Map<String, dynamic>) {
              return AuthAttempt.fromJson(entry);
            }
            if (entry is Map) {
              return AuthAttempt.fromJson(
                Map<String, dynamic>.from(entry),
              );
            }
            return null;
          })
          .whereType<AuthAttempt>()
          .toList();
    } on Object {
      return <AuthAttempt>[];
    }
  }

  String? get apiUrl => _prefs.getString(_keyApiUrl);
  String? get apiToken => _prefs.getString(_keyApiToken);
  String? get username => _prefs.getString(_keyUsername);
  String? get siteName => _prefs.getString(_keySiteName);
  String? get authIssuedAtIso => _prefs.getString(_keyAuthIssuedAt);
  DateTime? get authIssuedAt =>
      authIssuedAtIso != null ? DateTime.tryParse(authIssuedAtIso!) : null;
  String? get authSignature => _prefs.getString(_keyAuthSignature);
  bool get isAuthenticated => _prefs.getBool(_keyIsAuthenticated) ?? false;
  String? get sessionToken => _prefs.getString(_keySessionToken);
  DateTime? get sessionExpiresAt {
    final iso = _prefs.getString(_keySessionExpiresAt);
    if (iso == null) {
      return null;
    }
    return DateTime.tryParse(iso);
  }

  // Settings
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'dark';
  Future<void> setThemeMode(String mode) =>
      _prefs.setString(_keyThemeMode, mode);

  bool get enableNotifications =>
      _prefs.getBool(_keyEnableNotifications) ?? true;
  Future<void> setEnableNotifications({required bool value}) =>
      _prefs.setBool(_keyEnableNotifications, value);

  bool get autoSync => _prefs.getBool(_keyAutoSync) ?? true;
  Future<void> setAutoSync({required bool value}) =>
      _prefs.setBool(_keyAutoSync, value);

  int get syncInterval => _prefs.getInt(_keySyncInterval) ?? 15;
  Future<void> setSyncInterval(int minutes) =>
      _prefs.setInt(_keySyncInterval, minutes);

  // Generic methods
  Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
