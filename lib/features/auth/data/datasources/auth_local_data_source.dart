import 'dart:convert';

import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/auth/data/models/auth_attempt.dart';
import 'package:rgnets_fdk/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<bool> isAuthenticated();
  Future<void> saveCredentials({
    required String siteUrl,
    required String token,
    required String username,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
    bool markAuthenticated = false,
  });
  Future<void> clearCredentials();
  Future<void> saveSession({
    required String token,
    required DateTime expiresAt,
  });
  Future<void> clearSession();

  /// Logs an authentication attempt for auditing/debugging.
  Future<void> logAuthAttempt(AuthAttempt attempt);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required this.storageService});

  final StorageService storageService;
  static const String _userKey = 'current_user';

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await storageService.setString(_userKey, userJson);
    } on Exception catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = storageService.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } on Exception catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await storageService.remove(_userKey);
    } on Exception catch (e) {
      throw Exception('Failed to clear user: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return storageService.isAuthenticated;
    } on Exception catch (e) {
      throw Exception('Failed to check authentication status: $e');
    }
  }

  @override
  Future<void> saveCredentials({
    required String siteUrl,
    required String token,
    required String username,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
    bool markAuthenticated = false,
  }) async {
    try {
      await storageService.saveCredentials(
        siteUrl: siteUrl,
        token: token,
        username: username,
        siteName: siteName,
        issuedAtIso: issuedAt?.toUtc().toIso8601String(),
        signature: signature,
        markAuthenticated: markAuthenticated,
      );
    } on Exception catch (e) {
      throw Exception('Failed to save credentials: $e');
    }
  }

  @override
  Future<void> clearCredentials() async {
    try {
      await storageService.clearCredentials();
    } on Exception catch (e) {
      throw Exception('Failed to clear credentials: $e');
    }
  }

  @override
  Future<void> saveSession({
    required String token,
    required DateTime expiresAt,
  }) async {
    try {
      await storageService.saveSession(token: token, expiresAt: expiresAt);
    } on Exception catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await storageService.clearSession();
    } on Exception catch (e) {
      throw Exception('Failed to clear session: $e');
    }
  }

  @override
  Future<void> logAuthAttempt(AuthAttempt attempt) async {
    try {
      await storageService.logAuthAttempt(attempt);
    } on Exception catch (e) {
      throw Exception('Failed to log auth attempt: $e');
    }
  }
}
