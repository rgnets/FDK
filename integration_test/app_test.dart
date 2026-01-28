/// Integration tests for FDK app.
///
/// IMPORTANT: These tests must be run on iOS or Android devices/emulators.
/// They will NOT work on macOS desktop due to SharedPreferences plugin limitations.
///
/// Run with:
///   flutter test integration_test/app_test.dart -d <device_id>
///
/// Or use flutter drive:
///   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d <device_id>
///
/// Example device IDs: iPhone simulator, Android emulator, physical device
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/main.dart' as dev;
import 'package:rgnets_fdk/main_production.dart' as prod;
import 'package:rgnets_fdk/main_staging.dart' as staging;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Helper to wait real time and then pump frames
  Future<void> waitAndPump(WidgetTester tester, Duration duration) async {
    await binding.delayed(duration);
    await tester.pump();
  }

  /// Initialize test state and return SharedPreferences instance
  Future<SharedPreferences> initTestState() async {
    AppRouter.router.go('/splash');
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return prefs;
  }

  group('Development Environment Tests', () {
    testWidgets('Development environment navigates to home with mock data',
        (WidgetTester tester) async {
      final prefs = await initTestState();
      EnvironmentConfig.setEnvironment(Environment.development);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const dev.FDKApp(),
        ),
      );

      await waitAndPump(tester, const Duration(milliseconds: 500));
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      await waitAndPump(tester, const Duration(seconds: 4));

      expect(EnvironmentConfig.isDevelopment, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isTrue);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Development environment shows device list',
        (WidgetTester tester) async {
      final prefs = await initTestState();
      EnvironmentConfig.setEnvironment(Environment.development);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const dev.FDKApp(),
        ),
      );
      await waitAndPump(tester, const Duration(seconds: 5));

      final devicesTab = find.byIcon(Icons.devices);
      if (devicesTab.evaluate().isNotEmpty) {
        await tester.tap(devicesTab);
        await waitAndPump(tester, const Duration(seconds: 2));
      }

      await waitAndPump(tester, const Duration(seconds: 2));

      expect(find.byType(BottomNavigationBar), findsOneWidget);

      final hasListContent = find.byType(ListView).evaluate().isNotEmpty ||
          find.byType(Card).evaluate().isNotEmpty ||
          find.byType(ListTile).evaluate().isNotEmpty;
      expect(hasListContent, isTrue,
          reason: 'Device list should contain scrollable content');
    });
  });

  group('Staging Environment Tests', () {
    testWidgets('Staging environment attempts auto-authentication',
        (WidgetTester tester) async {
      final prefs = await initTestState();
      EnvironmentConfig.setEnvironment(Environment.staging);

      expect(EnvironmentConfig.isStaging, isTrue);
      expect(EnvironmentConfig.websocketBaseUrl, startsWith('wss://'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const staging.FDKApp(),
        ),
      );

      await waitAndPump(tester, const Duration(milliseconds: 500));
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      await waitAndPump(tester, const Duration(seconds: 10));

      final hasBottomNav = find.byType(BottomNavigationBar).evaluate().isNotEmpty;
      final hasAuthScreen = find.text('Connect to rXg System').evaluate().isNotEmpty;

      expect(hasBottomNav || hasAuthScreen, isTrue,
          reason: 'Should navigate to either home or auth screen');
    });
  });

  group('Production Environment Tests', () {
    testWidgets('Production environment requires authentication',
        (WidgetTester tester) async {
      final prefs = await initTestState();
      EnvironmentConfig.setEnvironment(Environment.production);

      expect(EnvironmentConfig.isProduction, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isFalse);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const prod.FDKApp(),
        ),
      );

      await waitAndPump(tester, const Duration(milliseconds: 500));
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      await waitAndPump(tester, const Duration(seconds: 4));

      expect(find.text('Connect to rXg System'), findsOneWidget);
    });

    testWidgets('Production auth screen has required input fields',
        (WidgetTester tester) async {
      final prefs = await initTestState();
      EnvironmentConfig.setEnvironment(Environment.production);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const prod.FDKApp(),
        ),
      );
      await waitAndPump(tester, const Duration(seconds: 5));

      expect(find.text('Connect to rXg System'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });
  });

  group('Navigation Flow Tests', () {
    testWidgets('Splash screen displays correctly',
        (WidgetTester tester) async {
      final prefs = await initTestState();
      EnvironmentConfig.setEnvironment(Environment.development);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const dev.FDKApp(),
        ),
      );
      await waitAndPump(tester, const Duration(milliseconds: 500));

      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      expect(find.text('FDK'), findsOneWidget);
      expect(find.text('For rXg Network Management'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Bottom navigation works after reaching home',
        (WidgetTester tester) async {
      final prefs = await initTestState();
      EnvironmentConfig.setEnvironment(Environment.development);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const dev.FDKApp(),
        ),
      );
      await waitAndPump(tester, const Duration(seconds: 5));

      expect(find.byType(BottomNavigationBar), findsOneWidget);

      final bottomNav = find.byType(BottomNavigationBar);
      final bottomNavWidget = tester.widget<BottomNavigationBar>(bottomNav);
      expect(bottomNavWidget.items.length, greaterThan(1));
    });
  });
}
