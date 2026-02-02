import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/secure_storage_service.dart';
import 'package:rgnets_fdk/features/auth/data/models/auth_attempt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage.
///
/// Sensitive credentials are stored in secure storage (Keychain/Keystore).
/// Non-sensitive settings are stored in SharedPreferences.
class StorageService {
  StorageService(this._prefs, this._secureStorage);
  final SharedPreferences _prefs;
  final SecureStorageService _secureStorage;

  // Keys for SharedPreferences (non-sensitive data only)
  static const String _keySiteUrl = 'site_url';
  static const String _keyUsername = 'username';
  static const String _keySiteName = 'site_name';
  static const String _keyAuthIssuedAt = 'auth_issued_at';
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keySessionExpiresAt = 'ws_session_expires_at';
  static const String _keyAuthAttempts = 'auth_attempts';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyEnableNotifications = 'enable_notifications';
  static const String _keyAutoSync = 'auto_sync';
  static const String _keySyncInterval = 'sync_interval';
  static const String _keyPhaseFilter = 'device_phase_filter';
  static const String _keyStatusFilter = 'device_status_filter';
  static const String _keyRoomFilter = 'device_room_filter';
  static const String _keySecureMigrationComplete = 'secure_migration_v1';

  // Legacy keys (for migration cleanup)
  static const String _legacyKeyToken = 'token';
  static const String _legacyKeySessionToken = 'ws_session_token';
  static const String _legacyKeyAuthSignature = 'auth_signature';
  static const String _legacyKeyApiUrl = 'api_url';
  static const String _legacyKeyApiToken = 'api_token';

  /// Public key for phase filter (for tests and direct access)
  static const String keyPhaseFilter = _keyPhaseFilter;

  /// Public key for status filter (for tests and direct access)
  static const String keyStatusFilter = _keyStatusFilter;

  /// Public key for room filter (for tests and direct access)
  static const String keyRoomFilter = _keyRoomFilter;

  /// Migrates credentials from plaintext SharedPreferences to secure storage.
  ///
  /// Uses atomic migration: read → write secure → verify → delete plaintext.
  /// Only runs once; sets a flag on completion.
  Future<void> migrateToSecureStorageIfNeeded() async {
    // Check if migration already completed
    if (_prefs.getBool(_keySecureMigrationComplete) ?? false) {
      return;
    }

    LoggerService.info(
      'Starting secure storage migration',
      tag: 'StorageService',
    );

    try {
      // Check if secure storage is available
      final isAvailable = await _secureStorage.isAvailable();
      if (!isAvailable) {
        LoggerService.warning(
          'Secure storage unavailable - migration skipped',
          tag: 'StorageService',
        );
        // Don't set flag - retry on next launch
        return;
      }

      // Migrate token
      final plaintextToken = _prefs.getString(_legacyKeyToken);
      if (plaintextToken != null && plaintextToken.isNotEmpty) {
        await _secureStorage.saveToken(plaintextToken);
        // Verify write succeeded
        final verifyToken = await _secureStorage.getToken();
        if (verifyToken == plaintextToken) {
          await _prefs.remove(_legacyKeyToken);
        } else {
          throw Exception('Token migration verification failed');
        }
      }

      // Migrate session token
      final plaintextSessionToken = _prefs.getString(_legacyKeySessionToken);
      if (plaintextSessionToken != null && plaintextSessionToken.isNotEmpty) {
        await _secureStorage.saveSessionToken(plaintextSessionToken);
        // Verify write succeeded
        final verifySession = await _secureStorage.getSessionToken();
        if (verifySession == plaintextSessionToken) {
          await _prefs.remove(_legacyKeySessionToken);
        } else {
          throw Exception('Session token migration verification failed');
        }
      }

      // Migrate auth signature
      final plaintextSignature = _prefs.getString(_legacyKeyAuthSignature);
      if (plaintextSignature != null && plaintextSignature.isNotEmpty) {
        await _secureStorage.saveAuthSignature(plaintextSignature);
        // Verify write succeeded
        final verifySignature = await _secureStorage.getAuthSignature();
        if (verifySignature == plaintextSignature) {
          await _prefs.remove(_legacyKeyAuthSignature);
        } else {
          throw Exception('Auth signature migration verification failed');
        }
      }

      // Migrate legacy api_url/api_token if present
      await _migrateLegacyApiKeys();

      // Also migrate ATT FE Tool legacy keys
      await _migrateLegacyAttKeys();

      // Mark migration complete
      await _prefs.setBool(_keySecureMigrationComplete, true);

      LoggerService.info(
        'Secure storage migration completed successfully',
        tag: 'StorageService',
      );
    } on Exception catch (e) {
      LoggerService.error(
        'Secure storage migration failed: $e',
        tag: 'StorageService',
        error: e,
      );
      // Don't set flag - allow retry. User may need to re-authenticate.
    }
  }

  /// Migrates legacy api_url/api_token keys to secure storage.
  Future<void> _migrateLegacyApiKeys() async {
    final hasLegacy =
        _prefs.containsKey(_legacyKeyApiUrl) ||
        _prefs.containsKey(_legacyKeyApiToken);

    if (!hasLegacy) return;

    final apiUrl = _prefs.getString(_legacyKeyApiUrl);
    final apiToken = _prefs.getString(_legacyKeyApiToken);

    // If we have a token, migrate it to secure storage
    if (apiToken != null && apiToken.isNotEmpty) {
      await _secureStorage.saveToken(apiToken);
      // Verify write succeeded
      final verifyToken = await _secureStorage.getToken();
      if (verifyToken != apiToken) {
        throw Exception('Legacy api_token migration verification failed');
      }
    }

    // If we have a URL and no siteUrl already set, migrate it
    if (apiUrl != null &&
        apiUrl.isNotEmpty &&
        !_prefs.containsKey(_keySiteUrl)) {
      await _prefs.setString(_keySiteUrl, apiUrl);
    }

    // Remove legacy keys only after successful migration
    await _prefs.remove(_legacyKeyApiUrl);
    await _prefs.remove(_legacyKeyApiToken);
  }

  Future<void> _migrateLegacyAttKeys() async {
    const legacyFqdnKey = 'att_fe_tool.fqdn';
    const legacyLoginKey = 'att_fe_tool.login';
    const legacyApiKey = 'att_fe_tool.api_key';

    final hasAttLegacy =
        _prefs.containsKey(legacyFqdnKey) &&
        _prefs.containsKey(legacyLoginKey) &&
        _prefs.containsKey(legacyApiKey);

    if (hasAttLegacy) {
      final fqdn = _prefs.getString(legacyFqdnKey) ?? '';
      final login = _prefs.getString(legacyLoginKey) ?? '';
      final apiKey = _prefs.getString(legacyApiKey) ?? '';

      if (fqdn.isNotEmpty && login.isNotEmpty && apiKey.isNotEmpty) {
        // Save non-sensitive data to SharedPreferences
        await _prefs.setString(_keySiteUrl, 'https://$fqdn');
        await _prefs.setString(_keyUsername, login);
        // Save sensitive token to secure storage
        await _secureStorage.saveToken(apiKey);

        // Verify write succeeded before deleting legacy keys
        final verifyToken = await _secureStorage.getToken();
        if (verifyToken != apiKey) {
          throw Exception('ATT legacy token migration verification failed');
        }
      }

      // Remove legacy keys only after successful migration
      await Future.wait<bool>([
        _prefs.remove(legacyFqdnKey),
        _prefs.remove(legacyLoginKey),
        _prefs.remove(legacyApiKey),
      ]);
    }
  }

  // Auth - credentials now use secure storage
  Future<void> saveCredentials({
    required String siteUrl,
    required String token,
    required String username,
    String? siteName,
    String? issuedAtIso,
    String? signature,
    bool markAuthenticated = false,
  }) async {
    // Non-sensitive data to SharedPreferences
    await _prefs.setString(_keySiteUrl, siteUrl);
    await _prefs.setString(_keyUsername, username);
    if (siteName != null) {
      await _prefs.setString(_keySiteName, siteName);
    }
    if (issuedAtIso != null) {
      await _prefs.setString(_keyAuthIssuedAt, issuedAtIso);
    }
    await _prefs.setBool(_keyIsAuthenticated, markAuthenticated);

    // Sensitive data to secure storage
    await _secureStorage.saveToken(token);
    if (signature != null) {
      await _secureStorage.saveAuthSignature(signature);
    }
  }

  Future<void> saveSession({
    required String token,
    required DateTime expiresAt,
  }) async {
    // Session token to secure storage
    await _secureStorage.saveSessionToken(token);
    // Expiry time to SharedPreferences (not sensitive)
    await _prefs.setString(
      _keySessionExpiresAt,
      expiresAt.toUtc().toIso8601String(),
    );
  }

  Future<void> clearCredentials() async {
    // Clear non-sensitive data from SharedPreferences
    await _prefs.remove(_keySiteUrl);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keySiteName);
    await _prefs.remove(_keyAuthIssuedAt);
    // Also clear any legacy keys that might exist
    await _prefs.remove(_legacyKeyToken);
    await _prefs.remove(_legacyKeyApiUrl);
    await _prefs.remove(_legacyKeyApiToken);
    await _prefs.remove(_legacyKeySessionToken);
    await _prefs.remove(_legacyKeyAuthSignature);

    // Clear sensitive data from secure storage
    await _secureStorage.clearAll();

    await clearSession();
    await _prefs.setBool(_keyIsAuthenticated, false);
  }

  Future<void> setAuthenticated({required bool value}) async {
    await _prefs.setBool(_keyIsAuthenticated, value);
  }

  Future<void> clearSession() async {
    await _secureStorage.deleteSessionToken();
    await _prefs.remove(_keySessionExpiresAt);
    // Also clear legacy key if present
    await _prefs.remove(_legacyKeySessionToken);
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
              return AuthAttempt.fromJson(Map<String, dynamic>.from(entry));
            }
            return null;
          })
          .whereType<AuthAttempt>()
          .toList();
    } on Object {
      return <AuthAttempt>[];
    }
  }

  // Getters - synchronous for non-sensitive, async for sensitive
  String? get siteUrl => _prefs.getString(_keySiteUrl);
  String? get username => _prefs.getString(_keyUsername);
  String? get siteName => _prefs.getString(_keySiteName);
  String? get authIssuedAtIso => _prefs.getString(_keyAuthIssuedAt);
  DateTime? get authIssuedAt =>
      authIssuedAtIso != null ? DateTime.tryParse(authIssuedAtIso!) : null;
  bool get isAuthenticated => _prefs.getBool(_keyIsAuthenticated) ?? false;
  DateTime? get sessionExpiresAt {
    final iso = _prefs.getString(_keySessionExpiresAt);
    if (iso == null) {
      return null;
    }
    return DateTime.tryParse(iso);
  }

  // Async getters for sensitive data from secure storage
  Future<String?> getToken() => _secureStorage.getToken();
  Future<String?> getSessionToken() => _secureStorage.getSessionToken();
  Future<String?> getAuthSignature() => _secureStorage.getAuthSignature();

  // Synchronous token getter for backward compatibility during transition
  // DEPRECATED: Use getToken() instead
  @Deprecated('Use getToken() instead for secure access')
  String? get token {
    // This is only for backward compatibility during migration
    // Returns null - callers must use async getToken()
    if (kDebugMode) {
      LoggerService.warning(
        'Deprecated synchronous token access - use getToken() instead',
        tag: 'StorageService',
      );
    }
    return null;
  }

  // DEPRECATED: Use getSessionToken() instead
  @Deprecated('Use getSessionToken() instead for secure access')
  String? get sessionToken {
    if (kDebugMode) {
      LoggerService.warning(
        'Deprecated synchronous sessionToken access - use getSessionToken()',
        tag: 'StorageService',
      );
    }
    return null;
  }

  // DEPRECATED: Use getAuthSignature() instead
  @Deprecated('Use getAuthSignature() instead for secure access')
  String? get authSignature {
    if (kDebugMode) {
      LoggerService.warning(
        'Deprecated synchronous authSignature access - use getAuthSignature()',
        tag: 'StorageService',
      );
    }
    return null;
  }

  // Settings (non-sensitive - remain in SharedPreferences)
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

  // Phase filter
  String? get phaseFilter => _prefs.getString(_keyPhaseFilter);
  Future<void> setPhaseFilter(String phase) =>
      _prefs.setString(_keyPhaseFilter, phase);
  Future<void> clearPhaseFilter() => _prefs.remove(_keyPhaseFilter);

  // Status filter
  String? get statusFilter => _prefs.getString(_keyStatusFilter);
  Future<void> setStatusFilter(String status) =>
      _prefs.setString(_keyStatusFilter, status);
  Future<void> clearStatusFilter() => _prefs.remove(_keyStatusFilter);

  // Room filter
  String? get roomFilter => _prefs.getString(_keyRoomFilter);
  Future<void> setRoomFilter(String room) =>
      _prefs.setString(_keyRoomFilter, room);
  Future<void> clearRoomFilter() => _prefs.remove(_keyRoomFilter);

  // Generic methods (for non-sensitive data only)
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
