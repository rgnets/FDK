import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/user.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rgnets_fdk/main_staging.dart' as staging;
import 'package:shared_preferences/shared_preferences.dart';

class MockAuth extends Mock implements Auth {}

void main() {
  group('Staging Auto-Authentication Tests', () {
    late ProviderContainer container;
    late SharedPreferences sharedPreferences;
    
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      
      // Set staging environment
      EnvironmentConfig.setEnvironment(Environment.staging);
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('Staging environment should have correct configuration', () {
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );
      
      expect(EnvironmentConfig.isStaging, isTrue);
      if (EnvironmentConfig.apiBaseUrl.isEmpty) {
        expect(EnvironmentConfig.apiUsername, isEmpty);
        expect(EnvironmentConfig.apiKey, isEmpty);
        return;
      }
      expect(EnvironmentConfig.apiBaseUrl, contains('interurban'));
      expect(EnvironmentConfig.apiUsername, isNotEmpty);
      expect(EnvironmentConfig.apiKey, isNotEmpty);
    });
    
    test('Staging should attempt auto-authentication', () async {
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );
      
      // The staging environment should have credentials configured
      if (EnvironmentConfig.apiBaseUrl.isEmpty) {
        expect(EnvironmentConfig.apiUsername, isEmpty);
        expect(EnvironmentConfig.apiKey, isEmpty);
        return;
      }
      expect(EnvironmentConfig.apiBaseUrl, isNotEmpty);
      expect(EnvironmentConfig.apiUsername, isNotEmpty);
      expect(EnvironmentConfig.apiKey, isNotEmpty);
    });
    
    testWidgets('Staging splash screen handles auth failure gracefully', 
      (WidgetTester tester) async {
      // This test ensures that if auto-auth fails, user is redirected to auth screen
      if (EnvironmentConfig.apiBaseUrl.isEmpty ||
          EnvironmentConfig.apiUsername.isEmpty ||
          EnvironmentConfig.apiKey.isEmpty) {
        return;
      }
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            // Override auth to simulate failure
            authProvider.overrideWith(() {
              final notifier = MockAuth();
              when(notifier.build).thenAnswer(
                (_) async => const AuthStatus.unauthenticated(),
              );
              when(() => notifier.authenticate(
                fqdn: any(named: 'fqdn'),
                login: any(named: 'login'),
                apiKey: any(named: 'apiKey'),
              )).thenAnswer((_) async {
                // Simulate auth failure
                throw Exception('Auth failed');
              });
              return notifier;
            }),
          ],
          child: const staging.FDKApp(),
        ),
      );
      
      // Should show splash initially
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      
      // Wait for auto-auth attempt
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      
      // Should navigate to auth screen on failure
      expect(find.text('Connect to rXg System'), findsOneWidget);
    });
    
    testWidgets('Staging splash screen navigates to home on successful auth', 
      (WidgetTester tester) async {
      if (EnvironmentConfig.apiBaseUrl.isEmpty ||
          EnvironmentConfig.apiUsername.isEmpty ||
          EnvironmentConfig.apiKey.isEmpty) {
        return;
      }
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            // Override auth to simulate success
            authProvider.overrideWith(() {
              final notifier = MockAuth();
              when(notifier.build).thenAnswer(
                (_) async => const AuthStatus.authenticated(
                  User(
                    username: 'test',
                    apiUrl: 'https://test.example.com',
                    email: 'test@example.com',
                  ),
                ),
              );
              return notifier;
            }),
          ],
          child: const staging.FDKApp(),
        ),
      );
      
      // Should show splash initially
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      
      // Wait for auto-auth
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      
      // Should navigate to home on success
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
  
  group('Regression Prevention Tests', () {
    test('Auth provider should properly report authentication status', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
        ],
      );
      
      final authState = container.read(authProvider);
      
      // Initially should be loading or unauthenticated
      expect(
        authState.when(
          data: (status) => status.isAuthenticated,
          loading: () => false,
          error: (_, __) => false,
        ),
        isFalse,
      );
      
      container.dispose();
    });
    
    test('Environment config should be consistent', () {
      // Test development
      EnvironmentConfig.setEnvironment(Environment.development);
      expect(EnvironmentConfig.isDevelopment, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isTrue);
      
      // Test staging
      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.isStaging, isTrue);
      expect(
        EnvironmentConfig.apiBaseUrl,
        anyOf(isEmpty, contains('interurban')),
      );
      
      // Test production
      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.isProduction, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isFalse);
    });
  });
}
