import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/providers/use_case_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/auth/data/models/auth_attempt.dart';
import 'package:rgnets_fdk/features/auth/data/models/user_model.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/authenticate_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

// Modern Riverpod 2.0+ best practice: Use @Riverpod (capitalized) for classes
// Use AsyncNotifier to match existing usage patterns
@Riverpod(keepAlive: true) // Keep alive to maintain auth state
class Auth extends _$Auth {
  late final Logger _logger;

  @override
  Future<AuthStatus> build() async {
    _logger = ref.watch(loggerProvider);
    final storage = ref.read(storageServiceProvider);
    await storage.migrateLegacyCredentialsIfNeeded();

    _logger
      ..i('🔐 AUTH_NOTIFIER: build() called - initializing auth state')
      ..d('AUTH_NOTIFIER: Provider hash: $hashCode');

    try {
      // Check if user is already authenticated (stored session)
      _logger.d('AUTH_NOTIFIER: Checking for existing user session...');
      final getCurrentUser = ref.read(getCurrentUserProvider);
      final result = await getCurrentUser();

      return result.fold(
        (failure) {
          _logger
            ..w(
              'AUTH_NOTIFIER: No existing session found or error: ${failure.message}',
            )
            ..d('AUTH_NOTIFIER: Setting initial state to unauthenticated');
          return const AuthStatus.unauthenticated();
        },
        (user) {
          if (user != null) {
            _logger
              ..i('AUTH_NOTIFIER: ✅ Found existing user session!')
              ..d('AUTH_NOTIFIER: Username: ${user.username}')
              ..d('AUTH_NOTIFIER: API URL: ${user.apiUrl}');
            return AuthStatus.authenticated(user);
          } else {
            _logger.d('AUTH_NOTIFIER: No user found in storage');
            return const AuthStatus.unauthenticated();
          }
        },
      );
    } on Exception catch (e) {
      _logger.e('AUTH_NOTIFIER: Error checking for existing session: $e');
      return const AuthStatus.unauthenticated();
    }
  }

  Future<void> authenticate({
    required String fqdn,
    required String login,
    required String apiKey,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
  }) async {
    final keyLength = math.min(4, apiKey.length);
    _logger
      ..i('🔑 AUTH_NOTIFIER: authenticate() called')
      ..d('AUTH_NOTIFIER: FQDN: $fqdn')
      ..d('AUTH_NOTIFIER: Login: $login')
      ..d('AUTH_NOTIFIER: API Key: ${apiKey.substring(0, keyLength)}...')
      ..d('AUTH_NOTIFIER: Current state before auth: ${state.value}');

    if (kIsWeb) {
      // Authentication starting - details available in logger
    }

    // Set loading state
    _logger
      ..d('AUTH_NOTIFIER: Setting state to authenticating')
      ..d(
        'AUTH_NOTIFIER: State after setting to authenticating: ${state.value}',
      );
    state = const AsyncValue.data(AuthStatus.authenticating());

    try {
      // Get the use case
      _logger
        ..d('AUTH_NOTIFIER: Getting authenticateUser use case')
        ..d('AUTH_NOTIFIER: Use case retrieved successfully');
      final authenticateUser = ref.read(authenticateUserProvider);

      // Execute authentication
      _logger.i('AUTH_NOTIFIER: Executing authentication use case');
      final params = AuthenticateUserParams(
        fqdn: fqdn,
        login: login,
        apiKey: apiKey,
        siteName: siteName,
        issuedAt: issuedAt,
        signature: signature,
      );
      _logger.d('AUTH_NOTIFIER: Params created: $params');

      final result = await authenticateUser(params);
      _logger
        ..d('AUTH_NOTIFIER: Authentication use case completed')
        ..d('AUTH_NOTIFIER: Result is success: ${result.isRight()}');

      await result.fold<Future<void>>(
        (failure) async {
          _logger.e(
            'AUTH_NOTIFIER: ❌ Authentication failed: ${failure.message}',
          );
          await _recordAuthAttempt(
            fqdn: fqdn,
            login: login,
            siteName: siteName,
            success: false,
            message: failure.message,
          );
          state = AsyncValue.data(AuthStatus.failure(failure.message));
        },
        (user) async {
          _logger
            ..i('AUTH_NOTIFIER: ✅ Credentials stored, proceeding to handshake')
            ..d('AUTH_NOTIFIER: User placeholder: ${user.username}');

          if (!EnvironmentConfig.useWebSockets) {
            _logger.w(
              'AUTH_NOTIFIER: WebSockets disabled via config, marking authenticated without handshake',
            );
            await ref
                .read(storageServiceProvider)
                .setAuthenticated(value: true);
            await _recordAuthAttempt(
              fqdn: fqdn,
              login: login,
              siteName: siteName,
              success: true,
              message: 'WebSockets disabled fallback',
            );
            state = AsyncValue.data(AuthStatus.authenticated(user));
            return;
          }

          try {
            final resolvedUser = await _performWebSocketHandshake(
              fqdn: fqdn,
              login: login,
              apiKey: apiKey,
              siteName: siteName,
              issuedAt: issuedAt,
              signature: signature,
            );

            _logger
              ..i('AUTH_NOTIFIER: ✅ WebSocket handshake acknowledged')
              ..d('AUTH_NOTIFIER: Resolved user: ${resolvedUser.username}')
              ..d('AUTH_NOTIFIER: Display name: ${resolvedUser.displayName}');

            state = AsyncValue.data(AuthStatus.authenticated(resolvedUser));
          } on Exception catch (e, stack) {
            _logger
              ..e('AUTH_NOTIFIER: WebSocket handshake failed: $e')
              ..d('AUTH_NOTIFIER: Handshake failure stacktrace: $stack');
            state = AsyncValue.data(AuthStatus.failure(e.toString()));
          }
        },
      );
    } on Exception catch (e, stack) {
      _logger.e(
        'AUTH_NOTIFIER: ⚠️ Exception during authentication: $e\n$stack',
      );
      // Exception handled by logger
      state = AsyncValue.data(AuthStatus.failure(e.toString()));
    }
  }

  Future<void> signOut() async {
    _logger
      ..i('🚪 AUTH_NOTIFIER: signOut() called')
      ..d('AUTH_NOTIFIER: Current state before signout: ${state.value}');

    try {
      // Get the use case
      _logger.d('AUTH_NOTIFIER: Getting signOutUser use case');
      final signOutUser = ref.read(signOutUserProvider);

      // Execute sign out
      _logger.i('AUTH_NOTIFIER: Executing sign out');
      final result = await signOutUser();
      _logger.d('AUTH_NOTIFIER: Sign out use case completed');

      // Update state based on result
      final newStatus = result.fold(
        (failure) {
          _logger.e('AUTH_NOTIFIER: ❌ Sign out failed: ${failure.message}');
          return AuthStatus.failure(failure.message);
        },
        (_) {
          _logger.i('AUTH_NOTIFIER: ✅ Sign out successful');
          return const AuthStatus.unauthenticated();
        },
      );

      _logger.d('AUTH_NOTIFIER: Setting state to: $newStatus');
      state = AsyncValue.data(newStatus);
      _logger.d('AUTH_NOTIFIER: Final state after signout: ${state.value}');
      if (EnvironmentConfig.useWebSockets) {
        final webSocketService = ref.read(webSocketServiceProvider);
        await webSocketService.disconnect(
          code: 1000,
          reason: 'User signed out',
        );
      }
    } on Exception catch (e, stack) {
      _logger.e('AUTH_NOTIFIER: ⚠️ Exception during sign out: $e\n$stack');
      state = AsyncValue.data(AuthStatus.failure(e.toString()));
    }
  }

  Future<User> _performWebSocketHandshake({
    required String fqdn,
    required String login,
    required String apiKey,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
  }) async {
    final config = ref.read(webSocketConfigProvider);
    final storage = ref.read(storageServiceProvider);
    final localDataSource = ref.read(authLocalDataSourceProvider);
    final service = ref.read(webSocketServiceProvider);

    final baseUri = config.baseUri;
    final queryParameters = Map<String, String>.from(baseUri.queryParameters);
    final resolvedSite =
        (siteName ?? storage.siteName ?? fqdn).trim();
    if (resolvedSite.isNotEmpty) {
      queryParameters['site'] = resolvedSite;
    }
    final uri = baseUri.replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final payload = <String, dynamic>{
      'type': 'auth.init',
      'payload': {
        'fqdn': fqdn,
        'login': login,
        'api_key': apiKey,
        'site_name': resolvedSite,
        'timestamp': (issuedAt ?? DateTime.now().toUtc()).toIso8601String(),
        if (signature != null && signature.isNotEmpty) 'signature': signature,
      },
    };

    if (service.isConnected) {
      await service.disconnect(code: 4000, reason: 'Re-authenticating');
    }

    final completer = Completer<SocketMessage>();
    final subscription = service.messages.listen((message) {
      if (message.type == 'auth.ack' || message.type == 'auth.error') {
        if (!completer.isCompleted) {
          completer.complete(message);
        }
      }
    });

    _logger
      ..i('AUTH_NOTIFIER: Initiating WebSocket handshake')
      ..d('AUTH_NOTIFIER: WebSocket URI: $uri');

    try {
      await service.connect(
        WebSocketConnectionParams(uri: uri, handshakeMessage: payload),
      );

      final socketMessage = await completer.future.timeout(
        const Duration(seconds: 15),
      );

      if (socketMessage.type == 'auth.error') {
        final errorMessage =
            socketMessage.payload['message'] as String? ??
            'Authentication error';
        await storage.setAuthenticated(value: false);
        await localDataSource.clearSession();
        await service.disconnect(code: 4401, reason: 'auth.error');
        await _recordAuthAttempt(
          fqdn: fqdn,
          login: login,
          siteName: resolvedSite,
          success: false,
          message: errorMessage,
        );
        throw Exception(errorMessage);
      }

      final payloadMap = socketMessage.payload;
      final sessionToken = payloadMap['sessionToken'] as String?;
      final expiresAtIso = payloadMap['expiresAt'] as String?;
      DateTime? expiresAt;
      if (expiresAtIso != null) {
        expiresAt = DateTime.tryParse(expiresAtIso);
      }

      if (sessionToken != null &&
          sessionToken.isNotEmpty &&
          expiresAt != null) {
        await localDataSource.saveSession(
          token: sessionToken,
          expiresAt: expiresAt,
        );
      } else {
        await localDataSource.clearSession();
      }

      await storage.setAuthenticated(value: true);

      final userPayload =
          (payloadMap['user'] as Map<String, dynamic>?) ?? const {};
      final resolvedLogin =
          userPayload['login'] as String? ?? login;
      final resolvedDisplayName =
          userPayload['siteName'] as String? ?? resolvedSite;

      final userModel = UserModel(
        username: resolvedLogin,
        apiUrl: 'https://$fqdn',
        displayName: resolvedDisplayName,
        email: null,
      );
      await localDataSource.saveUser(userModel);

      await _recordAuthAttempt(
        fqdn: fqdn,
        login: resolvedLogin,
        siteName: resolvedDisplayName,
        success: true,
        message: 'auth.ack',
      );

      return userModel.toEntity();
    } on TimeoutException {
      await storage.setAuthenticated(value: false);
      await localDataSource.clearSession();
      await service.disconnect(code: 4408, reason: 'Handshake timeout');
      await _recordAuthAttempt(
        fqdn: fqdn,
        login: login,
        siteName: siteName ?? resolvedSite,
        success: false,
        message: 'WebSocket handshake timed out',
      );
      throw Exception('WebSocket handshake timed out');
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> _recordAuthAttempt({
    required String fqdn,
    required String login,
    required bool success,
    String? siteName,
    String? message,
  }) async {
    try {
      final storage = ref.read(storageServiceProvider);
      final attempt = AuthAttempt(
        fqdn: fqdn,
        login: login,
        siteName: siteName,
        success: success,
        message: message,
        timestamp: DateTime.now().toUtc(),
      );
      await storage.logAuthAttempt(attempt);
    } on Exception catch (e) {
      _logger.w('AUTH_NOTIFIER: Failed to record auth attempt: $e');
    }
  }
}

// Modern computed providers using @riverpod
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authAsync = ref.watch(authProvider);
  final authState = authAsync.valueOrNull;
  return authState?.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      ) ??
      false;
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  final authAsync = ref.watch(authProvider);
  final authState = authAsync.valueOrNull;
  return authState?.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
}

@riverpod
AuthStatus? authStatus(AuthStatusRef ref) {
  final authAsync = ref.watch(authProvider);
  return authAsync.valueOrNull;
}
