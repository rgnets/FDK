import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/deeplink_provider.dart';
import 'package:rgnets_fdk/core/utils/qr_decoder.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';

/// Splash screen shown on app launch
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure the widget tree is built before navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNext();
    });
  }

  Future<void> _navigateToNext() async {
    // Get logger here instead of in initState
    final logger = ref.read(loggerProvider)
      ..i('🚀 SPLASH_SCREEN: Navigation flow starting')
      ..d('SPLASH_SCREEN: Environment: ${EnvironmentConfig.name}')
      ..d('SPLASH_SCREEN: WebSocket URL: ${EnvironmentConfig.websocketBaseUrl}')
      ..d(
        'SPLASH_SCREEN: Use Synthetic Data: ${EnvironmentConfig.useSyntheticData}',
      );

    if (kIsWeb) {
      // Navigation starting - environment info available in logger
    }

    // Check if the router captured a deeplink URI that app_links missed.
    // GoRouter consumes the platform route event, so we must feed the URI
    // to DeeplinkService manually.
    final pendingUri = AppRouter.pendingDeeplinkUri;
    if (pendingUri != null) {
      AppRouter.pendingDeeplinkUri = null;
      final deeplinkService = ref.read(deeplinkServiceProvider);

      // On cold start, _initializeDeeplinkService() in main.dart runs
      // concurrently and may not have set up callbacks yet. Wait for it.
      if (!deeplinkService.isInitialized) {
        logger.d('SPLASH_SCREEN: Waiting for DeeplinkService initialization...');
        for (var i = 0; i < 50; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;
          if (deeplinkService.isInitialized) break;
        }
        if (!deeplinkService.isInitialized) {
          logger.e('SPLASH_SCREEN: DeeplinkService init timed out');
          if (mounted) context.go('/auth');
          return;
        }
      }

      logger.i('SPLASH_SCREEN: Forwarding captured deeplink to DeeplinkService');
      // Fire and forget — DeeplinkService will navigate on success/cancel/error
      unawaited(deeplinkService.handleCapturedUri(pendingUri));
      return;
    }

    // Brief splash display (reduced for faster startup)
    logger.d('SPLASH_SCREEN: Starting 1-second initialization delay');
    await Future<void>.delayed(const Duration(seconds: 1));
    logger.d('SPLASH_SCREEN: Initialization delay complete');

    // Check if widget is still mounted after async delay
    if (!mounted) {
      logger.w('SPLASH_SCREEN: ⚠️ Widget disposed during delay, aborting navigation');
      return;
    }

    // Check if deeplink is being processed - if so, let deeplink service handle navigation
    final deeplinkService = ref.read(deeplinkServiceProvider);
    if (deeplinkService.isProcessing || deeplinkService.hasPendingInitialLink) {
      logger.i(
        'SPLASH_SCREEN: Deeplink in progress (isProcessing=${deeplinkService.isProcessing}, '
        'hasPendingInitialLink=${deeplinkService.hasPendingInitialLink}), deferring navigation',
      );
      return;
    }

    // Handle different environments
    if (EnvironmentConfig.isDevelopment) {
      logger
        ..i('🔧 SPLASH_SCREEN: Development mode detected')
        ..d('SPLASH_SCREEN: Skipping auth, navigating directly to /home');
      // Development mode: skip auth and go directly to home with synthetic data
      if (mounted) {
        logger.d('SPLASH_SCREEN: Widget is mounted, navigating...');
        context.go('/home');
        logger.i('SPLASH_SCREEN: ✅ Navigation to /home completed');
      } else {
        logger.w('SPLASH_SCREEN: ⚠️ Widget not mounted, skipping navigation');
      }
      return;
    }

    if (EnvironmentConfig.isStaging) {
      // Staging mode: auto-authenticate with interurban credentials from QR code
      logger
        ..i('🧪 SPLASH_SCREEN: Staging mode detected')
        ..d('SPLASH_SCREEN: Starting auto-authentication flow')
        // Decode the QR code from assets
        ..d('SPLASH_SCREEN: Decoding QR code from assets');

      final credentials = await QrDecoder.decodeTestApiQr();

      logger.d(
        'SPLASH_SCREEN: QR decode complete, credentials: ${credentials != null ? "found" : "not found"}',
      );

      if (credentials != null) {
        logger.i('SPLASH_SCREEN: ✅ QR credentials decoded successfully');
        final fqdn =
            (credentials['fqdn'] as String?) ?? EnvironmentConfig.host;
        final login =
            (credentials['login'] as String?) ?? EnvironmentConfig.apiUsername;
        // Accept 'token' or legacy 'apiKey' from QR credentials
        final authToken =
            (credentials['token'] as String?) ??
            (credentials['apiKey'] as String?) ??
            EnvironmentConfig.token;
        final siteName =
            (credentials['site_name'] as String?) ??
            (credentials['siteName'] as String?) ??
            fqdn;
        final issuedAt = DateTime.now().toUtc();

        logger
          ..d('SPLASH_SCREEN: Decoded credentials from QR:')
          ..d('SPLASH_SCREEN:   FQDN: $fqdn')
          ..d('SPLASH_SCREEN:   Login: $login')
          ..d('SPLASH_SCREEN:   Token: [REDACTED, length=${authToken.length}]')
          ..d('SPLASH_SCREEN:   Site Name: $siteName');

        try {
          logger
            ..i('SPLASH_SCREEN: 🔐 Starting authentication')
            ..d('SPLASH_SCREEN: Calling authProvider.notifier.authenticate()')
            ..d('SPLASH_SCREEN: Parameters:')
            ..d('SPLASH_SCREEN:   fqdn=$fqdn')
            ..d('SPLASH_SCREEN:   login=$login');
          // Auth starting - details available in logger

          // Add timeout to prevent hanging
          await ref
              .read(authProvider.notifier)
              .authenticate(
                fqdn: fqdn,
                login: login,
                token: authToken,
                siteName: siteName,
                issuedAt: issuedAt,
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  logger.e('Authentication timeout after 10 seconds');
                  throw TimeoutException('Authentication timeout');
                },
              );

          logger
            ..i('SPLASH_SCREEN: authenticate() call completed')
            ..d('SPLASH_SCREEN: Waiting for state to update...')
            // Auth completed - waiting for state
            // Give the state time to update after authentication
            ..d('SPLASH_SCREEN: Waiting 100ms for state propagation');
          await Future<void>.delayed(const Duration(milliseconds: 100));
          // Check if authentication was successful
          logger
            ..d('SPLASH_SCREEN: Wait complete, checking auth state')
            ..d('SPLASH_SCREEN: Reading authProvider state');
          final authAsync = ref.read(authProvider);

          logger
            ..d('SPLASH_SCREEN: authAsync type: ${authAsync.runtimeType}')
            ..d('SPLASH_SCREEN: authAsync hasValue: ${authAsync.hasValue}')
            ..d('SPLASH_SCREEN: authAsync hasError: ${authAsync.hasError}')
            ..d('SPLASH_SCREEN: authAsync isLoading: ${authAsync.isLoading}');

          final authState = authAsync.valueOrNull;
          logger.i('SPLASH_SCREEN: Auth state = $authState');
          // Auth state updated

          final isAuthenticated =
              authState?.maybeWhen(
                authenticated: (user) {
                  logger
                    ..i('SPLASH_SCREEN: ✅ User authenticated successfully')
                    ..d('SPLASH_SCREEN: User: ${user.username}')
                    ..d('SPLASH_SCREEN: API URL: ${user.siteUrl}');
                  return true;
                },
                orElse: () {
                  logger
                    ..w('SPLASH_SCREEN: ⚠️ Not authenticated')
                    ..d('SPLASH_SCREEN: Current state: $authState');
                  return false;
                },
              ) ??
              false;

          logger.d('SPLASH_SCREEN: isAuthenticated = $isAuthenticated');

          if (isAuthenticated) {
            logger.i(
              'SPLASH_SCREEN: 🎉 Authentication successful, navigating to /home',
            );
            if (mounted) {
              logger.d('SPLASH_SCREEN: Widget mounted, performing navigation');
              context.go('/home');
              logger.i('SPLASH_SCREEN: ✅ Navigation to /home initiated');
            } else {
              logger.w('SPLASH_SCREEN: ⚠️ Widget not mounted, cannot navigate');
            }
            return;
          } else {
            logger.e(
              'SPLASH_SCREEN: ❌ Authentication failed, redirecting to /auth',
            );
            if (mounted) {
              logger.d(
                'SPLASH_SCREEN: Widget mounted, navigating to auth screen',
              );
              context.go('/auth');
              logger.i('SPLASH_SCREEN: Navigation to /auth initiated');
            } else {
              logger.w('SPLASH_SCREEN: ⚠️ Widget not mounted, cannot navigate');
            }
            return;
          }
        } on Exception catch (e, stack) {
          logger.e(
            'SPLASH_SCREEN: 💥 Exception during authentication: $e\n$stack',
          );
          // Error handled by logger
          if (mounted) {
            logger.d('SPLASH_SCREEN: Navigating to /auth due to error');
            context.go('/auth');
          }
          return;
        }
      } else {
        logger.w(
          'SPLASH_SCREEN: ⚠️ Failed to decode QR, using fallback credentials',
        );
        // Use fallback credentials from EnvironmentConfig
        final fqdn = EnvironmentConfig.host;
        final login = EnvironmentConfig.apiUsername;
        final authToken = EnvironmentConfig.token;
        final siteName = fqdn;
        final issuedAt = DateTime.now().toUtc();

        logger
          ..d('Using fallback credentials:')
          ..d('FQDN: $fqdn')
          ..d('Login: $login')
          ..d('Token: [REDACTED, length=${authToken.length}]');

        try {
          await ref
              .read(authProvider.notifier)
              .authenticate(
                fqdn: fqdn,
                login: login,
                token: authToken,
                siteName: siteName,
                issuedAt: issuedAt,
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  logger.e('Fallback authentication timeout');
                  throw TimeoutException('Authentication timeout');
                },
              );

          // Wait a moment for auth state to update
          await Future<void>.delayed(const Duration(milliseconds: 500));

          // Check if authentication was successful
          final authAsync = ref.read(authProvider);
          final authState = authAsync.valueOrNull;
          final isAuthenticated =
              authState?.maybeWhen(
                authenticated: (_) => true,
                orElse: () => false,
              ) ??
              false;

          if (isAuthenticated) {
            logger.i('Fallback authentication completed successfully');
            if (mounted) {
              context.go('/home');
            }
          } else {
            logger.e('Fallback authentication also failed');
            if (mounted) {
              context.go('/auth');
            }
          }
        } on Exception catch (e) {
          logger.e('Fallback authentication error: $e');
          if (mounted) {
            context.go('/auth');
          }
        }
        return;
      }
    }

    // Production mode: first wait for auth provider build() which attempts credential recovery
    logger.i('SPLASH_SCREEN: 🏭 Production mode - checking auth state');

    // Trigger build() and wait for credential recovery to complete
    // This ensures _attemptCredentialRecovery() finishes before we proceed
    logger.d('SPLASH_SCREEN: Waiting for auth provider build() to complete...');
    try {
      final authState = await ref.read(authProvider.future).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          logger.w('SPLASH_SCREEN: Auth build timed out after 20s');
          return const AuthStatus.unauthenticated();
        },
      );

      if (!mounted) {
        logger.w('SPLASH_SCREEN: Widget disposed while waiting for auth');
        return;
      }

      final alreadyAuthenticated = authState.maybeWhen(
        authenticated: (user) {
          logger
            ..i('SPLASH_SCREEN: ✅ Already authenticated from credential recovery!')
            ..d('SPLASH_SCREEN: User: ${user.username}');
          return true;
        },
        orElse: () => false,
      );

      if (alreadyAuthenticated) {
        logger.i('SPLASH_SCREEN: 🎉 Navigating directly to /home');
        context.go('/home');
        return;
      }
    } on Exception catch (e) {
      logger.e('SPLASH_SCREEN: Error waiting for auth state: $e');
    }

    // Not authenticated yet - credential recovery either failed or no credentials exist
    // Fall back to checking stored credentials for manual auth attempt
    logger.d('SPLASH_SCREEN: Not authenticated, checking stored credentials for fallback');
    final storageService = ref.read(storageServiceProvider);

    // Check for actual stored credentials (not just the flag)
    final storedToken = await storageService.getToken();
    final hasStoredCredentials = storedToken != null &&
        storedToken.isNotEmpty &&
        storageService.siteUrl != null &&
        storageService.siteUrl!.isNotEmpty &&
        storageService.username != null &&
        storageService.username!.isNotEmpty;

    final hasCredentials = storageService.isAuthenticated || hasStoredCredentials;
    logger.d(
      'SPLASH_SCREEN: Has stored credentials: $hasCredentials '
      '(flag=${storageService.isAuthenticated}, hasData=$hasStoredCredentials)',
    );

    if (mounted) {
      if (hasCredentials) {
        final siteUrl = storageService.siteUrl ?? '';
        final authToken = storedToken ?? '';
        final login = storageService.username ?? '';
        final siteName = storageService.siteName;

        final parsed = Uri.tryParse(siteUrl);
        final fqdn = parsed?.host ?? siteUrl.replaceFirst(RegExp('^https?://'), '');

        if (authToken.isEmpty || login.isEmpty || fqdn.isEmpty) {
          logger.w(
            'SPLASH_SCREEN: Missing stored auth data; redirecting to /auth',
          );
          context.go('/auth');
          return;
        }

        logger.i('SPLASH_SCREEN: ✅ Stored credentials found, re-authenticating (fallback)');
        try {
          await ref
              .read(authProvider.notifier)
              .authenticate(
                fqdn: fqdn,
                login: login,
                token: authToken,
                siteName: siteName ?? fqdn,
                issuedAt: DateTime.now().toUtc(),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  logger.e('Production authentication timeout');
                  throw TimeoutException('Authentication timeout');
                },
              );

          await Future<void>.delayed(const Duration(milliseconds: 100));
          final authState = ref.read(authProvider).valueOrNull;
          final isAuthenticated =
              authState?.maybeWhen(
                authenticated: (_) => true,
                orElse: () => false,
              ) ??
              false;

          if (isAuthenticated) {
            logger.i(
              'SPLASH_SCREEN: 🎉 Authentication successful, navigating to /home',
            );
            context.go('/home');
          } else {
            logger.e(
              'SPLASH_SCREEN: ❌ Authentication failed, redirecting to /auth',
            );
            context.go('/auth');
          }
        } on Exception catch (e, stack) {
          logger.e(
            'SPLASH_SCREEN: 💥 Exception during production auth: $e\n$stack',
          );
          context.go('/auth');
        }
      } else {
        logger.i(
          'SPLASH_SCREEN: 🔓 No stored credentials, navigating to /auth',
        );
        context.go('/auth');
      }
    } else {
      logger.w('SPLASH_SCREEN: ⚠️ Widget not mounted, cannot navigate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'FDK',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'RG Nets Field Deployment Kit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              'For rXg Network Management',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
          ],
        ),
      ),
    );
  }
}
