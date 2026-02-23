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

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: EnvironmentConfig.isDevelopment,
    // Redirect deeplinks (fdk:// scheme) to splash - the DeeplinkService handles them
    redirect: (context, state) {
      // If the URI has a custom scheme (like fdk://), redirect to splash
      // The DeeplinkService will handle the actual deeplink processing
      if (state.uri.scheme == 'fdk') {
        return '/splash';
      }
      // On some platforms GoRouter strips the custom scheme and only sees
      // the host as a path segment (e.g. /login). Catch that here so we
      // don't fall through to the error page.
      final path = state.uri.path;
      if (path == '/login' || path == 'login') {
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
      final isDeeplink = state.uri.scheme == 'fdk' ||
          state.uri.toString().contains('fdk://') ||
          state.uri.host == 'login';

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

