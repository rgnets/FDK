import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/main.dart' as dev;
import 'package:rgnets_fdk/main_production.dart' as prod;
import 'package:rgnets_fdk/main_staging.dart' as staging;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Environment Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Development environment uses mock data', (WidgetTester tester) async {
      // Set environment
      EnvironmentConfig.setEnvironment(Environment.development);
      
      final sharedPreferences = await SharedPreferences.getInstance();
      
      // Build app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: const dev.FDKApp(),
        ),
      );
      
      // Should show splash screen
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      
      // Wait for navigation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      
      // In development, should go directly to home (mock data)
      expect(EnvironmentConfig.isDevelopment, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isTrue);
    });

    testWidgets('Staging environment auto-authenticates', (WidgetTester tester) async {
      // Set environment
      EnvironmentConfig.setEnvironment(Environment.staging);
      
      final sharedPreferences = await SharedPreferences.getInstance();
      
      // Build app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: const staging.FDKApp(),
        ),
      );
      
      // Should show splash screen
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      
      // Staging should have specific configuration
      expect(EnvironmentConfig.isStaging, isTrue);
      expect(EnvironmentConfig.apiBaseUrl, contains('interurban'));
      
      // Wait for auto-auth
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('Production environment requires authentication', (WidgetTester tester) async {
      // Set environment
      EnvironmentConfig.setEnvironment(Environment.production);
      
      final sharedPreferences = await SharedPreferences.getInstance();
      // Clear any stored credentials
      await sharedPreferences.clear();
      
      // Build app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: const prod.FDKApp(),
        ),
      );
      
      // Should show splash screen
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      
      // Production should not use synthetic data
      expect(EnvironmentConfig.isProduction, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isFalse);
      
      // Wait for navigation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      
      // Should navigate to auth screen (no stored credentials)
      expect(find.text('Connect to rXg System'), findsOneWidget);
    });
  });

  group('API Connectivity Tests', () {
    testWidgets('Mock data service works in development', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.development);
      
      final sharedPreferences = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: MaterialApp(
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
        ),
      );
      
      // Wait for async data
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      // Should have mock devices
      expect(find.textContaining('Devices:'), findsOneWidget);
    });
  });

  group('Navigation Flow Tests', () {
    testWidgets('Splash to Home flow in development', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.development);
      
      final sharedPreferences = await SharedPreferences.getInstance();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: const dev.FDKApp(),
        ),
      );
      
      // Wait for splash screen to load
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Verify splash screen
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      
      // Wait for auto-navigation
      await tester.pump(const Duration(seconds: 2, milliseconds: 500));
      await tester.pumpAndSettle();
      
      // Should be on home screen with bottom nav
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Splash to Auth flow in production', (WidgetTester tester) async {
      EnvironmentConfig.setEnvironment(Environment.production);
      
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: const prod.FDKApp(),
        ),
      );
      
      // Wait for splash screen to load
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Verify splash screen
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      
      // Wait for auto-navigation
      await tester.pump(const Duration(seconds: 2, milliseconds: 500));
      await tester.pumpAndSettle();
      
      // Should be on auth screen
      expect(find.text('Connect to rXg System'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets); // Should have input fields
    });
  });
}

// Import provider for devices  
final devicesNotifierProvider = AsyncNotifierProvider.autoDispose<DevicesNotifier, List<Map<String, dynamic>>>(() {
  throw UnimplementedError('This should be provided by the app');
});

abstract class DevicesNotifier extends AutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {}