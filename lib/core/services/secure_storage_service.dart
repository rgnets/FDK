import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive credentials.
///
/// Uses platform-native secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences (backed by Keystore)
/// - macOS: Keychain
/// - Linux: libsecret
/// - Windows: Credential Manager
class SecureStorageService {
  SecureStorageService() : _storage = _createStorage();

  final FlutterSecureStorage _storage;

  // Keys for secure storage
  static const String _keyToken = 'secure_token';
  static const String _keySessionToken = 'secure_session_token';
  static const String _keyAuthSignature = 'secure_auth_signature';
  static const String _keyApiKey = 'secure_api_key';

  static FlutterSecureStorage _createStorage() {
    // iOS: afterFirstUnlock allows access after device unlock, enabling auto-login
    // Android: encryptedSharedPreferences provides better compatibility
    const iOSOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    );
    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
    );
    return const FlutterSecureStorage(
      iOptions: iOSOptions,
      aOptions: androidOptions,
    );
  }

  // Token (API token/auth token)
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  // Session token
  Future<void> saveSessionToken(String token) async {
    await _storage.write(key: _keySessionToken, value: token);
  }

  Future<String?> getSessionToken() async {
    return _storage.read(key: _keySessionToken);
  }

  Future<void> deleteSessionToken() async {
    await _storage.delete(key: _keySessionToken);
  }

  // Auth signature
  Future<void> saveAuthSignature(String signature) async {
    await _storage.write(key: _keyAuthSignature, value: signature);
  }

  Future<String?> getAuthSignature() async {
    return _storage.read(key: _keyAuthSignature);
  }

  Future<void> deleteAuthSignature() async {
    await _storage.delete(key: _keyAuthSignature);
  }

  // API Key (if stored separately)
  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _keyApiKey, value: apiKey);
  }

  Future<String?> getApiKey() async {
    return _storage.read(key: _keyApiKey);
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: _keyApiKey);
  }

  /// Clears all secure credentials.
  Future<void> clearAll() async {
    await Future.wait([
      deleteToken(),
      deleteSessionToken(),
      deleteAuthSignature(),
      deleteApiKey(),
    ]);
  }

  /// Checks if secure storage is available and working.
  /// Returns true if a test write/read/delete cycle succeeds.
  Future<bool> isAvailable() async {
    const testKey = 'secure_storage_test';
    const testValue = 'test_value';
    try {
      await _storage.write(key: testKey, value: testValue);
      final readBack = await _storage.read(key: testKey);
      await _storage.delete(key: testKey);
      return readBack == testValue;
    } on Object {
      return false;
    }
  }
}
