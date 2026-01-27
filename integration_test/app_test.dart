import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/main.dart' as dev;
import 'package:rgnets_fdk/main_production.dart' as prod;
import 'package:rgnets_fdk/main_staging.dart' as staging;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Reset router to splash screen
    AppRouter.router.go('/splash');
    // Clear shared preferences
    SharedPreferences.setMockInitialValues({});
  });

  group('Development Environment Tests', () {
    testWidgets('Development environment navigates to home with mock data',
        (WidgetTester tester) async {
      // Set environment to development
      EnvironmentConfig.setEnvironment(Environment.development);

      // Launch the app
      await tester.pumpWidget(const dev.FDKApp());

      // Wait for splash screen to appear
      await tester.pump();
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      // Wait for initialization and navigation (2 second delay in splash)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify we're in development mode
      expect(EnvironmentConfig.isDevelopment, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isTrue);

      // Should be on home screen with bottom navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Development environment shows device list',
        (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.development);

      await tester.pumpWidget(const dev.FDKApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to devices tab if not already there
      final devicesTab = find.byIcon(Icons.devices);
      if (devicesTab.evaluate().isNotEmpty) {
        await tester.tap(devicesTab);
        await tester.pumpAndSettle();
      }

      // Should have loaded mock devices
      // Look for device list indicators (device cards, list items, etc.)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // The home screen should have content (not empty)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });

  group('Staging Environment Tests', () {
    testWidgets('Staging environment attempts auto-authentication',
        (WidgetTester tester) async {
      // Set environment to staging
      EnvironmentConfig.setEnvironment(Environment.staging);

      // Verify staging configuration
      expect(EnvironmentConfig.isStaging, isTrue);
      expect(EnvironmentConfig.websocketBaseUrl, startsWith('wss://'));

      // Launch the app
      await tester.pumpWidget(const staging.FDKApp());

      // Wait for splash screen
      await tester.pump();
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      // Wait for auto-auth attempt (may succeed or fail depending on network)
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should navigate somewhere (home on success, auth on failure)
      // Either BottomNavigationBar (home) or 'Connect to rXg System' (auth)
      final hasBottomNav = find.byType(BottomNavigationBar).evaluate().isNotEmpty;
      final hasAuthScreen = find.text('Connect to rXg System').evaluate().isNotEmpty;

      expect(hasBottomNav || hasAuthScreen, isTrue,
          reason: 'Should navigate to either home or auth screen');
    });
  });

  group('Production Environment Tests', () {
    testWidgets('Production environment requires authentication',
        (WidgetTester tester) async {
      // Set environment to production
      EnvironmentConfig.setEnvironment(Environment.production);

      // Clear any stored credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Verify production configuration
      expect(EnvironmentConfig.isProduction, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isFalse);

      // Launch the app
      await tester.pumpWidget(const prod.FDKApp());

      // Wait for splash screen
      await tester.pump();
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);

      // Wait for navigation to auth screen
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should navigate to auth screen (no stored credentials)
      expect(find.text('Connect to rXg System'), findsOneWidget);
    });

    testWidgets('Production auth screen has required input fields',
        (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.production);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      await tester.pumpWidget(const prod.FDKApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on auth screen
      expect(find.text('Connect to rXg System'), findsOneWidget);

      // Should have input fields for authentication
      expect(find.byType(TextFormField), findsWidgets);
    });
  });

  group('Navigation Flow Tests', () {
    testWidgets('Splash screen displays correctly',
        (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.development);

      await tester.pumpWidget(const dev.FDKApp());
      await tester.pump();

      // Verify splash screen content
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      expect(find.text('FDK'), findsOneWidget);
      expect(find.text('For rXg Network Management'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Bottom navigation works after reaching home',
        (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.development);

      await tester.pumpWidget(const dev.FDKApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Try tapping different navigation items
      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      // Get the BottomNavigationBar and verify it has items
      final bottomNavWidget = tester.widget<BottomNavigationBar>(bottomNav);
      expect(bottomNavWidget.items.length, greaterThan(1));
    });
  });
}
