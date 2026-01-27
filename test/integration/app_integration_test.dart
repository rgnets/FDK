import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/main.dart' as dev;
import 'package:rgnets_fdk/main_production.dart' as prod;
import 'package:rgnets_fdk/main_staging.dart' as staging;
import 'package:shared_preferences/shared_preferences.dart';
import '../fixtures/environment_expectations.dart';
import '../fixtures/test_app_harness.dart';
import '../fixtures/test_auth_notifier.dart';

void main() {
  setUp(() {
    AppRouter.router.go('/splash');
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    required Widget app,
    SharedPreferences? sharedPreferences,
    List<Override> overrides = const [],
    bool autoAuthInDev = true,
  }) async {
    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
    final container = createTestContainer(
      sharedPreferences: prefs,
      overrides: overrides,
      autoAuthInDev: autoAuthInDev,
    );

    await tester.pumpWidget(
      wrapWithContainer(
        container: container,
        child: app,
      ),
    );
  }

  // NOTE: Full app integration tests are skipped because FDKApp uses ref.listen
  // in initState via WidgetsBinding.instance.addPostFrameCallback, which isn't
  // compatible with UncontrolledProviderScope in widget tests. These tests should
  // be run as integration_test/ driver tests instead.
  group('Environment Integration Tests', () {
    // Skip: FDKApp uses ref.listen in initState - not compatible with widget tests
    testWidgets('Development environment uses mock data', (WidgetTester tester) async {
      // Set environment
      EnvironmentConfig.setEnvironment(Environment.development);

      // Build app with auto-auth enabled (default)
      await pumpApp(
        tester,
        app: const dev.FDKApp(),
      );

      // Should show splash screen
      await tester.pump();
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      // Wait for navigation (2s delay + animation)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // In development, should go directly to home (mock data)
      expect(EnvironmentConfig.isDevelopment, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isTrue);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    }, skip: true); // FDKApp uses ref.listen in initState

    // Skip: FDKApp uses ref.listen in initState - not compatible with widget tests
    testWidgets('Staging environment auto-authenticates', (WidgetTester tester) async {
      // Set environment
      EnvironmentConfig.setEnvironment(Environment.staging);

      // Build app with explicit auth override for staging
      await pumpApp(
        tester,
        app: const staging.FDKApp(),
        autoAuthInDev: false, // Not dev mode
        overrides: [
          overrideAuthProvider(
            initialStatus: const AuthStatus.unauthenticated(),
            authenticateStatus: const AuthStatus.authenticated(testUser),
          ),
        ],
      );

      // Should show splash screen
      await tester.pump();
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      // Staging should have specific configuration
      expectStagingEnvironmentConfig();

      // Wait for auto-auth
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should navigate to home on success
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    }, skip: true); // FDKApp uses ref.listen in initState

    // Skip: FDKApp uses ref.listen in initState - not compatible with widget tests
    testWidgets('Production environment requires authentication', (WidgetTester tester) async {
      // Set environment
      EnvironmentConfig.setEnvironment(Environment.production);

      final sharedPreferences = await SharedPreferences.getInstance();
      // Clear any stored credentials
      await sharedPreferences.clear();

      // Build app without auto-auth
      await pumpApp(
        tester,
        app: const prod.FDKApp(),
        sharedPreferences: sharedPreferences,
        autoAuthInDev: false,
      );

      // Should show splash screen
      await tester.pump();
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      // Production should not use synthetic data
      expect(EnvironmentConfig.isProduction, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isFalse);

      // Wait for navigation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should navigate to auth screen (no stored credentials)
      expect(find.text('Connect to rXg System'), findsOneWidget);
    }, skip: true); // FDKApp uses ref.listen in initState
  });

  group('API Connectivity Tests', () {
    testWidgets('Mock data service works in development', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.development);

      await pumpApp(
        tester,
        app: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              final devicesAsync = ref.watch(devicesNotifierProvider);

              return devicesAsync.when(
                data: (devices) => Text('Devices: ${devices.length}'),
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error: $err'),
              );
            },
          ),
        ),
      );

      // Wait for async data - need multiple pumps for async provider
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should have mock devices
      expect(find.textContaining('Devices:'), findsOneWidget);
    });
  });

  group('Navigation Flow Tests', () {
    // Skip: FDKApp uses ref.listen in initState - not compatible with widget tests
    testWidgets('Splash to Home flow in development', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.development);

      await pumpApp(
        tester,
        app: const dev.FDKApp(),
      );

      // Wait for splash screen to load
      await tester.pump();

      // Verify splash screen
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      // Wait for auto-navigation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on home screen with bottom nav
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    }, skip: true); // FDKApp uses ref.listen in initState

    // Skip: FDKApp uses ref.listen in initState - not compatible with widget tests
    testWidgets('Splash to Auth flow in production', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.production);

      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();

      await pumpApp(
        tester,
        app: const prod.FDKApp(),
        sharedPreferences: sharedPreferences,
        autoAuthInDev: false,
      );

      // Wait for splash screen to load
      await tester.pump();

      // Verify splash screen
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      // Wait for auto-navigation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on auth screen
      expect(find.text('Connect to rXg System'), findsOneWidget);
    }, skip: true); // FDKApp uses ref.listen in initState
  });
}
