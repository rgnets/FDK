import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/utils/qr_decoder.dart';
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
      ..d('SPLASH_SCREEN: API Base URL: ${EnvironmentConfig.apiBaseUrl}')
      ..d(
        'SPLASH_SCREEN: Use Synthetic Data: ${EnvironmentConfig.useSyntheticData}',
      );

    if (kIsWeb) {
      // Navigation starting - environment info available in logger
    }

    // Simulate initialization
    logger.d('SPLASH_SCREEN: Starting 2-second initialization delay');
    await Future<void>.delayed(const Duration(seconds: 2));
    logger.d('SPLASH_SCREEN: Initialization delay complete');

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
            (credentials['fqdn'] as String?) ??
            EnvironmentConfig.apiBaseUrl
                .replaceFirst('https://', '')
                .replaceFirst('http://', '');
        final login =
            (credentials['login'] as String?) ?? EnvironmentConfig.apiUsername;
        final apiKey =
            (credentials['apiKey'] as String?) ?? EnvironmentConfig.apiKey;
        final siteName =
            (credentials['site_name'] as String?) ??
            (credentials['siteName'] as String?) ??
            fqdn;
        final issuedAt = DateTime.now().toUtc();

        logger
          ..d('SPLASH_SCREEN: Decoded credentials from QR:')
          ..d('SPLASH_SCREEN:   FQDN: $fqdn')
          ..d('SPLASH_SCREEN:   Login: $login')
          ..d('SPLASH_SCREEN:   API Key: ${apiKey.substring(0, 4)}...')
          ..d('SPLASH_SCREEN:   Site Name: $siteName')
          ..d('SPLASH_SCREEN:   Full FQDN type: ${fqdn.runtimeType}')
          ..d('SPLASH_SCREEN:   Full Login type: ${login.runtimeType}');

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
                apiKey: apiKey,
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
                    ..d('SPLASH_SCREEN: API URL: ${user.apiUrl}');
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
        // Extract FQDN from the API URL (remove protocol)
        final fqdn = EnvironmentConfig.apiBaseUrl
            .replaceFirst('https://', '')
            .replaceFirst('http://', '')
            .split('/')
            .first; // Get just the host part
        final login = EnvironmentConfig.apiUsername;
        final apiKey = EnvironmentConfig.apiKey;
        final siteName = fqdn;
        final issuedAt = DateTime.now().toUtc();

        logger
          ..d('Using fallback credentials:')
          ..d('FQDN: $fqdn')
          ..d('Login: $login')
          ..d('API Key: ${apiKey.substring(0, 4)}...');

        try {
          await ref
              .read(authProvider.notifier)
              .authenticate(
                fqdn: fqdn,
                login: login,
                apiKey: apiKey,
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

    // Production mode: check if user has stored credentials
    logger.i('SPLASH_SCREEN: 🏭 Production mode - checking stored credentials');
    final storageService = ref.read(storageServiceProvider);
    final hasCredentials = storageService.isAuthenticated;
    logger.d('SPLASH_SCREEN: Has stored credentials: $hasCredentials');

    if (mounted) {
      if (hasCredentials) {
        logger.i(
          'SPLASH_SCREEN: ✅ Stored credentials found, navigating to /home',
        );
        context.go('/home');
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
