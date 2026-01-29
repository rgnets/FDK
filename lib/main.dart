import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/deeplink_provider.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/app_initializer.dart';
import 'package:rgnets_fdk/core/services/deeplink_service.dart';
import 'package:rgnets_fdk/core/services/error_reporter.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/theme/app_theme.dart';
import 'package:rgnets_fdk/core/utils/text_overflow_utils.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rgnets_fdk/features/auth/presentation/widgets/credential_approval_sheet.dart';
import 'package:rgnets_fdk/features/initialization/initialization.dart';
import 'package:rgnets_fdk/features/onboarding/data/config/onboarding_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _configureImageCache() {
  const maxBytes = int.fromEnvironment(
    'IMAGE_CACHE_MAX_BYTES',
    defaultValue: 50 * 1024 * 1024,
  );
  const maxCount = int.fromEnvironment(
    'IMAGE_CACHE_MAX_COUNT',
    defaultValue: 200,
  );
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSizeBytes = maxBytes;
  cache.maximumSize = maxCount;
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock orientation to portrait mode
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set environment from dart-define
    const envString = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    // Starting app - environment info available via EnvironmentConfig

    Environment env;
    switch (envString.toLowerCase()) {
      case 'staging':
        env = Environment.staging;
        break;
      case 'production':
        env = Environment.production;
        break;
      case 'development':
      default:
        env = Environment.development;
        break;
    }

    EnvironmentConfig.setEnvironment(env);
    await AppInitializer.initializeSentry();
    final enableCrashReporting = EnvironmentConfig.sentryDsn.isNotEmpty;
    LoggerService.configure(enableCrashReporting: enableCrashReporting);
    _configureImageCache();
    // Environment configuration complete - details available via EnvironmentConfig getters

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (ErrorReporter.isEnabled) {
        unawaited(
          Sentry.captureException(
            details.exception,
            stackTrace: details.stack,
          ),
        );
      }
    };

    // Initialize providers with error handling
    late final SharedPreferences sharedPreferences;
    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } on Exception catch (e) {
      // If SharedPreferences fails, provide a fallback or exit gracefully
      debugPrint('Failed to initialize SharedPreferences: $e');
      return;
    }

    // Initialize onboarding configuration
    try {
      await OnboardingConfig.initialize();
    } on Exception catch (e) {
      debugPrint('Failed to initialize OnboardingConfig: $e');
      // Non-fatal - app can continue without onboarding UI
    }

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const FDKApp(),
      ),
    );
  }, (error, stackTrace) async {
    await ErrorReporter.report(error, stackTrace: stackTrace);
  });
}

class FDKApp extends ConsumerStatefulWidget {
  const FDKApp({super.key});

  @override
  ConsumerState<FDKApp> createState() => _FDKAppState();
}

class _FDKAppState extends ConsumerState<FDKApp> {
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    // Start background refresh service after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  /// Initialize background services (called once from initState callback)
  void _initializeServices() {
    if (_servicesInitialized) return;
    _servicesInitialized = true;

    ref.read(backgroundRefreshServiceProvider).startBackgroundRefresh();
    // Initialize WebSocket data sync listener to refresh providers when data arrives
    ref.read(webSocketDataSyncListenerProvider);
    // Initialize auth sign-out cleanup listener to handle cache clearing and provider invalidation
    ref.read(authSignOutCleanupProvider);
    // Initialize deeplink service for handling fdk:// URLs
    _initializeDeeplinkService();

    // Check if already authenticated on startup
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      LoggerService.info(
        'User already authenticated, starting initialization',
        tag: 'Init',
      );
      ref.read(initializationNotifierProvider.notifier).initialize();
    }
  }

  /// Initialize the deeplink service with callbacks for confirmation and authentication.
  Future<void> _initializeDeeplinkService() async {
    final deeplinkService = ref.read(deeplinkServiceProvider);

    await deeplinkService.initialize(
      confirmCallback: _showDeeplinkConfirmation,
      authenticateCallback: _authenticateFromDeeplink,
      onSuccess: () => AppRouter.router.go('/home'),
      onCancel: () => AppRouter.router.go('/auth'),
      onError: () => AppRouter.router.go('/auth'),
    );
  }

  /// Show a confirmation dialog for deeplink credentials.
  Future<bool> _showDeeplinkConfirmation(DeeplinkCredentials credentials) async {
    final navigatorContext = AppRouter.router.routerDelegate.navigatorKey.currentContext;
    if (navigatorContext == null) {
      LoggerService.warning('No navigator context available for deeplink confirmation');
      return false;
    }

    final result = await showModalBottomSheet<bool>(
      context: navigatorContext,
      isScrollControlled: true,
      builder: (context) => CredentialApprovalSheet(
        fqdn: credentials.fqdn,
        login: credentials.login,
        token: credentials.apiKey,
      ),
    );

    return result ?? false;
  }

  /// Authenticate using credentials from a deeplink.
  Future<void> _authenticateFromDeeplink(DeeplinkCredentials credentials) async {
    await ref.read(authProvider.notifier).authenticate(
      fqdn: credentials.fqdn,
      login: credentials.login,
      token: credentials.apiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes in build (required by Riverpod)
    ref.listen<bool>(isAuthenticatedProvider, (previous, isAuthenticated) {
      final wasAuthenticated = previous ?? false;
      if (isAuthenticated && !wasAuthenticated) {
        LoggerService.info(
          'User authenticated, starting initialization',
          tag: 'Init',
        );
        ref.read(initializationNotifierProvider.notifier).initialize();
      } else if (!isAuthenticated && wasAuthenticated) {
        LoggerService.info(
          'User signed out, resetting initialization state',
          tag: 'Init',
        );
        ref.read(initializationNotifierProvider.notifier).reset();
      }
    });

    return MaterialApp.router(
      title: 'RG Nets FDK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
      // Limit text scaling to prevent overflow with large system fonts
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: clampedTextScaler(context),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
