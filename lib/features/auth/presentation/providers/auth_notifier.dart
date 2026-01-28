import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/cache_manager.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';
import 'package:rgnets_fdk/features/auth/data/models/auth_attempt.dart';
import 'package:rgnets_fdk/features/auth/data/models/user_model.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/authenticate_user.dart';
import 'package:rgnets_fdk/features/auth/domain/usecases/get_current_user.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart'
    as devices_providers;
import 'package:rgnets_fdk/features/home/presentation/providers/dashboard_provider.dart'
    as dashboard_providers;
import 'package:rgnets_fdk/features/notifications/presentation/providers/device_notification_provider.dart'
    as device_notifications;
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart'
    as notifications_domain;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

// Modern Riverpod 2.0+ best practice: Use @Riverpod (capitalized) for classes
// Use AsyncNotifier to match existing usage patterns
@Riverpod(keepAlive: true) // Keep alive to maintain auth state
class Auth extends _$Auth {
  late final Logger _logger;
  int _authGeneration = 0;

  AuthenticateUser get _authenticateUser =>
      AuthenticateUser(ref.read(authRepositoryProvider));

  GetCurrentUser get _getCurrentUser =>
      GetCurrentUser(ref.read(authRepositoryProvider));

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
      final getCurrentUser = _getCurrentUser;
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
              ..d('AUTH_NOTIFIER: API URL: ${user.siteUrl}');
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
    required String token,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
  }) async {
    _authGeneration += 1;
    final keyLength = math.min(4, token.length);
    _logger
      ..i('🔑 AUTH_NOTIFIER: authenticate() called')
      ..d('AUTH_NOTIFIER: FQDN: $fqdn')
      ..d('AUTH_NOTIFIER: Login: $login')
      ..d('AUTH_NOTIFIER: API Key: ${token.substring(0, keyLength)}...')
      ..d('AUTH_NOTIFIER: Auth generation: $_authGeneration')
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
      final authenticateUser = _authenticateUser;

      // Execute authentication
      _logger.i('AUTH_NOTIFIER: Executing authentication use case');
      final params = AuthenticateUserParams(
        fqdn: fqdn,
        login: login,
        token: token,
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

          try {
            final resolvedUser = await _performWebSocketHandshake(
              fqdn: fqdn,
              login: login,
              token: token,
              siteName: siteName,
              issuedAt: issuedAt,
              signature: signature,
            ).timeout(
              const Duration(seconds: 20),
              onTimeout: () {
                _logger.e('AUTH_NOTIFIER: ⏱️ Handshake TIMED OUT after 20 seconds');
                throw TimeoutException('Authentication timed out - server may be unreachable');
              },
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
      final storage = ref.read(storageServiceProvider);
      final expectedToken = storage.token;
      final expectedSiteUrl = storage.siteUrl;

      // Set state to unauthenticated FIRST to unblock UI
      _logger.d('AUTH_NOTIFIER: Setting state to unauthenticated');
      state = const AsyncValue.data(AuthStatus.unauthenticated());

      try {
        await storage.setAuthenticated(value: false);
      } on Exception catch (e) {
        _logger.w('AUTH_NOTIFIER: Failed to mark unauthenticated: $e');
      }

      await _stopBackgroundServices();
      _clearImageCache();
      // Note: Provider invalidation and cache clearing is now handled by
      // authSignOutCleanupProvider to avoid CircularDependencyError

      // Disconnect WebSocket to stop message processing
      _logger.d('AUTH_NOTIFIER: Disconnecting WebSocket...');
      final webSocketService = ref.read(webSocketServiceProvider);
      // Fire and forget with proper async error handling
      unawaited(
        webSocketService
            .disconnect(code: 1000, reason: 'User signed out')
            .timeout(const Duration(seconds: 2))
            .catchError((Object e) {
          _logger.w('AUTH_NOTIFIER: WebSocket disconnect error: $e');
        }),
      );

      // Clear storage in background with timeout
      _logger.d('AUTH_NOTIFIER: Clearing storage in background');
      unawaited(
        _clearStorageWithTimeout(
          expectedToken: expectedToken,
          expectedSiteUrl: expectedSiteUrl,
        ),
      );

      _logger.i('AUTH_NOTIFIER: ✅ Sign out initiated');
    } on Exception catch (e, stack) {
      _logger.e('AUTH_NOTIFIER: ⚠️ Exception during sign out: $e\n$stack');
      state = AsyncValue.data(AuthStatus.failure(e.toString()));
    }
  }

  Future<void> _stopBackgroundServices() async {
    try {
      _logger.d('AUTH_NOTIFIER: Stopping background refresh services');
      ref.read(backgroundRefreshServiceProvider).stopBackgroundRefresh();
      ref.read(cacheManagerProvider).clearAll();
    } on Exception catch (e) {
      _logger.w('AUTH_NOTIFIER: Failed stopping background services: $e');
    }
  }

  void _clearImageCache() {
    try {
      // Release cached GPU/image resources during sign-out.
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();
      unawaited(DefaultCacheManager().emptyCache());
      _logger.d('AUTH_NOTIFIER: Image cache cleared');
    } on Exception catch (e) {
      _logger.w('AUTH_NOTIFIER: Failed to clear image cache: $e');
    }
  }

  Future<void> _clearStorageWithTimeout({
    required String? expectedToken,
    required String? expectedSiteUrl,
  }) async {
    try {
      final storage = ref.read(storageServiceProvider);
      final currentToken = storage.token;
      final currentSiteUrl = storage.siteUrl;
      if (!_credentialsMatch(
        expectedToken: expectedToken,
        expectedSiteUrl: expectedSiteUrl,
        currentToken: currentToken,
        currentSiteUrl: currentSiteUrl,
      )) {
        _logger.d(
          'AUTH_NOTIFIER: Skipping storage clear (credentials changed)',
        );
        return;
      }
      final localDataSource = ref.read(authLocalDataSourceProvider);
      final notificationService = ref.read(notificationGenerationServiceProvider);

      // Reset notification state to prevent memory leak on re-login
      notificationService.reset();
      _logger.d('AUTH_NOTIFIER: Notification state reset');

      await Future.wait([
        storage.clearCredentials(),
        localDataSource.clearUser(),
      ]).timeout(const Duration(seconds: 5));

      _logger.d('AUTH_NOTIFIER: Storage cleared successfully');
    } on Exception catch (e) {
      _logger.w('AUTH_NOTIFIER: Storage clear timed out or failed: $e');
    }
  }

  bool _credentialsMatch({
    required String? expectedToken,
    required String? expectedSiteUrl,
    required String? currentToken,
    required String? currentSiteUrl,
  }) {
    final expectedTokenValue = (expectedToken ?? '').trim();
    final expectedSiteValue = (expectedSiteUrl ?? '').trim();
    final currentTokenValue = (currentToken ?? '').trim();
    final currentSiteValue = (currentSiteUrl ?? '').trim();
    return expectedTokenValue == currentTokenValue &&
        expectedSiteValue == currentSiteValue;
  }

  Future<User> _performWebSocketHandshake({
    required String fqdn,
    required String login,
    required String token,
    String? siteName,
    DateTime? issuedAt,
    String? signature,
  }) async {
    var failureHandled = false;
    final config = ref.read(webSocketConfigProvider);
    final storage = ref.read(storageServiceProvider);
    final localDataSource = ref.read(authLocalDataSourceProvider);
    final service = ref.read(webSocketServiceProvider);
    _logger.i('AUTH_NOTIFIER: WebSocket service hashCode: ${service.hashCode}');

    final resolvedSite =
        (siteName ?? storage.siteName ?? fqdn).trim();
    final uri = _buildActionCableUri(
      baseUri: config.baseUri,
      fqdn: fqdn,
      token: token,
    );
    final headers = _buildAuthHeaders(token);

    if (service.isConnected) {
      await service.disconnect(code: 4000, reason: 'Re-authenticating');
    }

    final identifier = jsonEncode(const {'channel': 'RxgChannel'});
    final subscriptionPayload = <String, dynamic>{
      'command': 'subscribe',
      'identifier': identifier,
    };

    final completer = Completer<_ActionCableAuthResult>();
    final subscription = service.messages.listen((message) {
      _logger.d('AUTH_NOTIFIER: 📩 WebSocket message received: type=${message.type}, payload=${message.payload}');
      if (message.type == 'confirm_subscription' &&
          _identifierMatches(message, identifier)) {
        _logger.i('AUTH_NOTIFIER: ✅ Subscription confirmed!');
        if (!completer.isCompleted) {
          completer.complete(const _ActionCableAuthResult.success());
        }
      } else if (message.type == 'reject_subscription' &&
          _identifierMatches(message, identifier)) {
        _logger.e('AUTH_NOTIFIER: ❌ Subscription REJECTED by server');
        if (!completer.isCompleted) {
          completer.complete(
            const _ActionCableAuthResult.failure(
              'Subscription rejected by server',
            ),
          );
        }
      } else if (message.type == 'disconnect') {
        final reason =
            message.payload['reason'] as String? ??
            message.payload['message'] as String?;
        _logger.e('AUTH_NOTIFIER: ❌ Server sent disconnect: $reason');
        if (!completer.isCompleted) {
          completer.complete(
            _ActionCableAuthResult.failure(
              reason ?? 'Connection closed by server',
            ),
          );
        }
      }
    });

    final stateSubscription = service.connectionState.listen((connState) {
      _logger.d('AUTH_NOTIFIER: 🔌 WebSocket connection state changed: $connState');
      if (connState == SocketConnectionState.disconnected &&
          !completer.isCompleted) {
        _logger.e('AUTH_NOTIFIER: ❌ Connection closed before subscription confirmed');
        completer.complete(
          const _ActionCableAuthResult.failure(
            'Connection closed before subscription confirmed',
          ),
        );
      }
    });

    _logger
      ..i('AUTH_NOTIFIER: Initiating WebSocket handshake')
      ..d('AUTH_NOTIFIER: WebSocket URI: $uri')
      ..d('AUTH_NOTIFIER: Subscription identifier: $identifier');

    try {
      _logger.d('AUTH_NOTIFIER: Calling service.connect()...');
      await service.connect(
        WebSocketConnectionParams(uri: uri, headers: headers),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.e('AUTH_NOTIFIER: ⏱️ Connection TIMED OUT after 10 seconds');
          throw TimeoutException('Connection to server timed out');
        },
      );
      _logger.d('AUTH_NOTIFIER: WebSocket connected, sending subscription...');
      service.send(subscriptionPayload);
      _logger.d('AUTH_NOTIFIER: Subscription sent, waiting for confirmation (15s timeout)...');

      final result = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          _logger.e('AUTH_NOTIFIER: ⏱️ WebSocket handshake TIMED OUT after 15 seconds');
          return const _ActionCableAuthResult.failure(
            'WebSocket handshake timed out',
          );
        },
      );

      if (!result.success) {
        final errorMessage = result.message;
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
        failureHandled = true;
        throw Exception(errorMessage);
      }

      await localDataSource.clearSession();
      await storage.setAuthenticated(value: true);

      final userModel = UserModel(
        username: login,
        siteUrl: 'https://$fqdn',
        displayName: resolvedSite.isEmpty ? login : resolvedSite,
        email: null,
      );
      await localDataSource.saveUser(userModel);

      await _recordAuthAttempt(
        fqdn: fqdn,
        login: login,
        siteName: resolvedSite,
        success: true,
        message: 'action_cable.confirm_subscription',
      );

      return userModel.toEntity();
    } on Exception catch (e) {
      if (!failureHandled) {
        await storage.setAuthenticated(value: false);
        await localDataSource.clearSession();
        await service.disconnect(code: 4401, reason: 'auth.error');
        await _recordAuthAttempt(
          fqdn: fqdn,
          login: login,
          siteName: resolvedSite,
          success: false,
          message: e.toString(),
        );
      }
      rethrow;
    } finally {
      await subscription.cancel();
      await stateSubscription.cancel();
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

/// Listener provider that handles cleanup when auth state changes to unauthenticated.
/// This is separated from Auth.signOut() to avoid CircularDependencyError when
/// invalidating providers that depend on authStatusProvider.
final authSignOutCleanupProvider = Provider<void>((ref) {
  final logger = ref.read(loggerProvider);

  ref.listen<AuthStatus?>(authStatusProvider, (AuthStatus? previous, AuthStatus? next) {
    final wasAuthenticated = previous?.isAuthenticated ?? false;
    final isNowUnauthenticated = next?.isUnauthenticated ?? false;

    if (wasAuthenticated && isNowUnauthenticated) {
      logger.i('AUTH_CLEANUP: Detected sign-out, clearing caches and invalidating providers');

      // Clear typed device caches
      try {
        unawaited(ref.read(apLocalDataSourceProvider).clearCache());
        unawaited(ref.read(ontLocalDataSourceProvider).clearCache());
        unawaited(ref.read(switchLocalDataSourceProvider).clearCache());
        unawaited(ref.read(wlanLocalDataSourceProvider).clearCache());
        logger.d('AUTH_CLEANUP: Typed device caches cleared');
      } on Exception catch (e) {
        logger.w('AUTH_CLEANUP: Failed to clear typed device caches: $e');
      }

      // Clear WebSocket cache integration
      try {
        ref.read(webSocketCacheIntegrationProvider).clearCaches();
        logger.d('AUTH_CLEANUP: WebSocket cache cleared');
      } on Exception catch (e) {
        logger.w('AUTH_CLEANUP: Failed to clear WebSocket cache: $e');
      }

      // Invalidate data providers - safe from listener context (no circular dependency)
      try {
        ref.invalidate(devices_providers.devicesNotifierProvider);
        ref.invalidate(device_notifications.deviceNotificationsNotifierProvider);
        ref.invalidate(notifications_domain.notificationsDomainNotifierProvider);
        ref.invalidate(dashboard_providers.dashboardStatsProvider);
        logger.d('AUTH_CLEANUP: Data providers invalidated');
      } on Exception catch (e) {
        logger.w('AUTH_CLEANUP: Failed to invalidate data providers: $e');
      }

      logger.i('AUTH_CLEANUP: ✅ Sign-out cleanup complete');
    }
  });
});

Uri _buildActionCableUri({
  required Uri baseUri,
  required String fqdn,
  required String token,
}) {
  final useBaseUri = EnvironmentConfig.isDevelopment;
  final uri = useBaseUri
      ? baseUri
      : Uri(
        scheme: 'wss',
        host: fqdn,
        path: '/cable',
      );

  final queryParameters = Map<String, String>.from(uri.queryParameters);
  if (token.isNotEmpty) {
    queryParameters['api_key'] = token;
  }

  return uri.replace(
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
  );
}

Map<String, dynamic> _buildAuthHeaders(String token) {
  if (token.isEmpty) {
    return const {};
  }
  return {'Authorization': 'Bearer $token'};
}

bool _identifierMatches(SocketMessage message, String identifier) {
  final headerIdentifier = message.headers?['identifier'];
  if (headerIdentifier is String && headerIdentifier.isNotEmpty) {
    return headerIdentifier == identifier;
  }
  return false;
}

class _ActionCableAuthResult {
  const _ActionCableAuthResult.success()
      : success = true,
        message = '';
  const _ActionCableAuthResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}
