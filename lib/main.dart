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
import 'package:rgnets_fdk/core/providers/websocket_sync_providers.dart';
import 'package:rgnets_fdk/core/services/app_initializer.dart';
import 'package:rgnets_fdk/core/services/deeplink_service.dart';
import 'package:rgnets_fdk/core/services/error_reporter.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/theme/app_theme.dart';
import 'package:rgnets_fdk/core/utils/text_overflow_utils.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rgnets_fdk/features/auth/presentation/widgets/credential_approval_sheet.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_providers.dart';
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

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initializeApp();
  }, (error, stackTrace) async {
    await ErrorReporter.report(error, stackTrace: stackTrace);
  });
}

/// App initialization extracted from main() so the retry path does not
/// re-enter runZonedGuarded or re-call ensureInitialized.
Future<void> _initializeApp() async {
  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set environment from dart-define. main.dart is the production entry point;
  // dev and staging have dedicated main_development.dart / main_staging.dart.
  const envString = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'production',
  );

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
    debugPrint('Failed to initialize SharedPreferences: $e');
    // Show error UI instead of silent exit
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Storage Initialization Failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Error: $e', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _initializeApp(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}

class FDKApp extends ConsumerStatefulWidget {
  const FDKApp({super.key});

  @override
  ConsumerState<FDKApp> createState() => _FDKAppState();
}

class _FDKAppState extends ConsumerState<FDKApp> with WidgetsBindingObserver {
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start background refresh service after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The app is WebSocket-only, so a backgrounded socket that the OS tears down
  /// must be deliberately suspended and re-established. Without this the socket
  /// silently dies during sleep and the app appears frozen on resume. Only
  /// `paused`/`detached` count as backgrounded — `inactive`/`hidden` are
  /// transient (Control Center, app switcher, permission prompts) and must not
  /// drop the connection. Resume is gated on auth so a signed-out session is
  /// never silently reconnected.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!ref.read(isAuthenticatedProvider)) {
      return;
    }
    final socket = ref.read(webSocketServiceProvider);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(socket.suspendForLifecycle());
      case AppLifecycleState.resumed:
        unawaited(socket.resumeForLifecycle());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// Initialize background services (called once from initState callback)
  Future<void> _initializeServices() async {
    if (_servicesInitialized) return;
    _servicesInitialized = true;

    // Migrate credentials to secure storage if needed (runs once)
    final storageService = ref.read(storageServiceProvider);
    await storageService.migrateToSecureStorageIfNeeded();

    ref.read(backgroundRefreshServiceProvider).startBackgroundRefresh();
    // Initialize WebSocket data sync listener to refresh providers when data arrives
    ref.read(webSocketDataSyncListenerProvider);
    // Initialize auth sign-out cleanup listener to handle cache clearing and provider invalidation
    ref.read(authSignOutCleanupProvider);
    // Initialize deeplink service for handling fdk:// URLs
    await _initializeDeeplinkService();

    // Check if already authenticated on startup
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (isAuthenticated) {
      LoggerService.info(
        'User already authenticated, starting initialization',
        tag: 'Init',
      );
      // Block the technician behind the startup loader until the inventory
      // seed completes (waitForSync), so they never land on empty lists.
      unawaited(
        ref
            .read(initializationNotifierProvider.notifier)
            .initialize(waitForSync: true),
      );
      ref.read(complianceTriggerWiringProvider);
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
      // Skip getInitialLink() when the router already captured the deeplink —
      // the SplashScreen handles it directly to avoid a duplicate dialog.
      skipInitialLink: AppRouter.deeplinkCapturedByRouter,
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
    // ref.listen in build() is Riverpod's recommended pattern for ConsumerStatefulWidget.
    // The framework automatically removes the previous listener on rebuild,
    // preventing duplicate side-effects.
    ref.listen<bool>(isAuthenticatedProvider, (previous, isAuthenticated) {
      final wasAuthenticated = previous ?? false;
      if (isAuthenticated && !wasAuthenticated) {
        LoggerService.info(
          'User authenticated, starting initialization',
          tag: 'Init',
        );
        // Block behind the startup loader until the inventory seed completes.
        unawaited(
          ref
              .read(initializationNotifierProvider.notifier)
              .initialize(waitForSync: true),
        );
        ref.read(complianceTriggerWiringProvider);
      } else if (!isAuthenticated && wasAuthenticated) {
        LoggerService.info(
          'User signed out, navigating to auth screen',
          tag: 'Init',
        );
        ref.read(initializationNotifierProvider.notifier).reset();

        // Navigate to auth screen FIRST — this must happen regardless of
        // whether a sign-out reason dialog is shown. Previously the dialog
        // used `return` to defer navigation to the dialog's button, but
        // concurrent data-provider invalidation (from authSignOutCleanupProvider)
        // could cause rebuilds that dismissed the dialog, leaving the user
        // stuck on an empty home screen.
        AppRouter.router.go('/auth');

        // If there's a sign-out reason, show it as a dialog on top of /auth
        final signOutReason = ref.read(signOutReasonProvider);
        if (signOutReason != null) {
          ref.read(signOutReasonProvider.notifier).state = null;

          // Schedule dialog after the navigation frame completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navigatorContext =
                AppRouter.router.routerDelegate.navigatorKey.currentContext;
            if (navigatorContext != null) {
              LoggerService.info(
                'Showing sign-out reason dialog',
                tag: 'Auth',
              );
              showDialog<void>(
                context: navigatorContext,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(child: Text('Session Ended')),
                    ],
                  ),
                  content: Text(signOutReason),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          });
        }
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
