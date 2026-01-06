import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/widgets/main_scaffold.dart';
import 'package:rgnets_fdk/features/auth/presentation/screens/auth_screen.dart';
import 'package:rgnets_fdk/features/debug/debug_screen.dart';
import 'package:rgnets_fdk/features/devices/presentation/screens/device_detail_screen.dart';
import 'package:rgnets_fdk/features/devices/presentation/screens/devices_screen.dart';
import 'package:rgnets_fdk/features/home/presentation/screens/home_screen.dart';
import 'package:rgnets_fdk/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:rgnets_fdk/features/rooms/presentation/screens/room_detail_screen.dart';
import 'package:rgnets_fdk/features/rooms/presentation/screens/rooms_screen.dart';
import 'package:rgnets_fdk/features/scanner/presentation/screens/scanner_screen.dart';
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
          return ScannerScreen(mode: mode);
        },
      ),

      // Debug screen (outside of shell for direct access)
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
                child: ScannerScreen(mode: mode),
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
          
          // Notifications
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) {
              final tab = state.uri.queryParameters['tab'];
              return NoTransitionPage(
                child: NotificationsScreen(initialTab: tab),
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
    
    // Error page
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

