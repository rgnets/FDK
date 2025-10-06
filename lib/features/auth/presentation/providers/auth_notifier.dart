import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/use_case_providers.dart';
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
            ..w('AUTH_NOTIFIER: No existing session found or error: ${failure.message}')
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
      ..d('AUTH_NOTIFIER: State after setting to authenticating: ${state.value}');
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
      );
      _logger.d('AUTH_NOTIFIER: Params created: $params');
      
      final result = await authenticateUser(params);
      _logger
        ..d('AUTH_NOTIFIER: Authentication use case completed')
        ..d('AUTH_NOTIFIER: Result is success: ${result.isRight()}');
      
      // Update state based on result
      final newStatus = result.fold(
        (failure) {
          _logger.e('AUTH_NOTIFIER: ❌ Authentication failed: ${failure.message}');
          // Authentication failed - error available in logger
          return AuthStatus.failure(failure.message);
        },
        (user) {
          _logger
            ..i('AUTH_NOTIFIER: ✅ Authentication successful!')
            ..d('AUTH_NOTIFIER: User: ${user.username}')
            ..d('AUTH_NOTIFIER: API URL: ${user.apiUrl}')
            ..d('AUTH_NOTIFIER: Display Name: ${user.displayName}');
          // Authentication successful - user info available in logger
          return AuthStatus.authenticated(user);
        },
      );
      
      _logger
        ..d('AUTH_NOTIFIER: Setting new auth status: $newStatus')
        ..i('AUTH_NOTIFIER: State updated successfully')
        ..d('AUTH_NOTIFIER: Final state: ${state.value}');
      state = AsyncValue.data(newStatus);
      
      // Final auth state updated
    } on Exception catch (e, stack) {
      _logger.e('AUTH_NOTIFIER: ⚠️ Exception during authentication: $e\n$stack');
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
    } on Exception catch (e, stack) {
      _logger.e('AUTH_NOTIFIER: ⚠️ Exception during sign out: $e\n$stack');
      state = AsyncValue.data(AuthStatus.failure(e.toString()));
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
  ) ?? false;
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