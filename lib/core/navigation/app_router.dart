import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/widgets/main_scaffold.dart';
import 'package:rgnets_fdk/features/auth/presentation/screens/auth_screen.dart';
import 'package:rgnets_fdk/features/debug/debug_screen.dart';
import 'package:rgnets_fdk/features/devices/presentation/screens/device_detail_screen.dart';
import 'package:rgnets_fdk/features/devices/presentation/screens/devices_screen.dart';
import 'package:rgnets_fdk/features/home/presentation/screens/home_screen.dart';
import 'package:rgnets_fdk/features/issues/presentation/screens/health_notices_screen.dart';
import 'package:rgnets_fdk/features/rooms/presentation/screens/room_detail_screen.dart';
import 'package:rgnets_fdk/features/rooms/presentation/screens/rooms_screen.dart';
import 'package:rgnets_fdk/features/scanner/presentation/screens/scanner_screen_v2.dart';
import 'package:rgnets_fdk/features/settings/presentation/screens/settings_screen.dart';
import 'package:rgnets_fdk/features/splash/presentation/screens/splash_screen.dart';

/// Application router configuration
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// Deeplink URI captured by the redirect before GoRouter consumed it.
  /// The SplashScreen checks this and feeds it to DeeplinkService, since
  /// GoRouter's redirect prevents app_links from receiving the URI.
  static Uri? pendingDeeplinkUri;

  /// Set to true when the redirect captures a deeplink. Stays true so
  /// DeeplinkService.initialize() knows to skip getInitialLink() (which
  /// would return the same URI and show a duplicate dialog).
  static bool deeplinkCapturedByRouter = false;

  /// Check whether a URI looks like a deeplink (fdk://login?...) that
  /// may have had its scheme/host stripped by GoRouter.
  static bool _isDeeplinkUri(Uri uri) {
    if (uri.scheme == 'fdk') return true;
    final path = uri.path;
    if (path == '/login' || path == 'login') return true;
    final params = uri.queryParameters;
    if (params.containsKey('fqdn') || params.containsKey('apiKey') ||
        params.containsKey('api_key') || params.containsKey('data')) {
      return true;
    }
    return false;
  }

  /// Reconstruct a canonical fdk://login URI from whatever GoRouter gave us.
  static Uri _reconstructDeeplinkUri(Uri uri) {
    if (uri.scheme == 'fdk') return uri;
    return Uri(
      scheme: 'fdk',
      host: 'login',
      queryParameters: uri.queryParameters,
    );
  }

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: EnvironmentConfig.isDevelopment,
    // Redirect deeplinks to splash. GoRouter strips the custom scheme
    // differently per platform (fdk://login?... may arrive as /login?...
    // or just /?fqdn=...), so we check multiple variants.
    // The original URI is saved in pendingDeeplinkUri because GoRouter
    // consumes the platform route event, preventing app_links from
    // independently receiving it.
    redirect: (context, state) {
      if (_isDeeplinkUri(state.uri)) {
        pendingDeeplinkUri = _reconstructDeeplinkUri(state.uri);
        deeplinkCapturedByRouter = true;
        return '/splash';
      }
      return null;
    },
    routes: [
      // Splash screen (outside of shell)
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth screen (outside of shell)
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Auth scanner (outside of shell to maintain context with auth screen)
      GoRoute(
        path: '/auth-scanner',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          return ScannerScreenV2(mode: mode);
        },
      ),

      // Debug screen - only available in non-production builds
      if (!EnvironmentConfig.isProduction)
        GoRoute(
          path: '/debug',
          builder: (context, state) => const DebugScreen(),
        ),
      
      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          // Home/Dashboard
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: HomeScreen(),
              );
            },
          ),
          
          // Scanner
          GoRoute(
            path: '/scanner',
            pageBuilder: (context, state) {
              final mode = state.uri.queryParameters['mode'];
              return NoTransitionPage(
                child: ScannerScreenV2(mode: mode),
              );
            },
          ),
          
          // Devices
          GoRoute(
            path: '/devices',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: DevicesScreen(),
              );
            },
            routes: [
              // Device detail
              GoRoute(
                path: ':deviceId',
                builder: (context, state) {
                  final deviceId = state.pathParameters['deviceId']!;
                  return DeviceDetailScreen(deviceId: deviceId);
                },
              ),
            ],
          ),
          
          // Notifications / Health Notices
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: HealthNoticesScreen(),
              );
            },
          ),
          
          // Rooms
          GoRoute(
            path: '/rooms',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: RoomsScreen(),
              );
            },
            routes: [
              // Room detail
              GoRoute(
                path: ':roomId',
                builder: (context, state) {
                  final roomId = state.pathParameters['roomId']!;
                  return RoomDetailScreen(roomId: roomId);
                },
              ),
            ],
          ),
          
          // Settings
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: SettingsScreen(),
              );
            },
          ),
        ],
      ),
    ],
    
    // Fallback page — shown when GoRouter can't match a route.
    // Most commonly hit when a deeplink URI leaks past the redirect.
    errorBuilder: (context, state) {
      final isDeeplink = _isDeeplinkUri(state.uri);

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDeeplink ? Icons.link : Icons.error_outline,
                size: 64,
                color: isDeeplink
                    ? const Color(0xFF4A90E2)
                    : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                isDeeplink ? 'Deeplink Login' : 'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                isDeeplink
                    ? 'Processing login request...'
                    : state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              if (isDeeplink) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/auth'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

