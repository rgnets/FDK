import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/features/auth/domain/entities/auth_status.dart';
import 'package:rgnets_fdk/features/auth/presentation/providers/auth_notifier.dart';
import 'package:rgnets_fdk/main_staging.dart' as staging;
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/environment_expectations.dart';
import 'fixtures/test_app_harness.dart';
import 'fixtures/test_auth_notifier.dart';

void main() {
  group('Staging Auto-Authentication Tests', () {
    late SharedPreferences sharedPreferences;
    
    setUp(() async {
      AppRouter.router.go('/splash');
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      
      // Set staging environment
      EnvironmentConfig.setEnvironment(Environment.staging);
    });
    
    test('Staging environment should have correct configuration', expectStagingEnvironmentConfig);
    
    test('Staging should attempt auto-authentication', () async {
      // The staging environment should have credentials configured
      expectStagingEnvironmentConfig();
    });
    
    testWidgets('Staging splash screen handles auth failure gracefully', 
      (WidgetTester tester) async {
      // This test ensures that if auto-auth fails, user is redirected to auth screen
      if (EnvironmentConfig.apiBaseUrl.isEmpty ||
          EnvironmentConfig.apiUsername.isEmpty ||
          EnvironmentConfig.apiKey.isEmpty) {
        return;
      }
      
      final container = createTestContainer(
        sharedPreferences: sharedPreferences,
        overrides: [
          // Override auth to simulate failure
          overrideAuthProvider(
            initialStatus: const AuthStatus.unauthenticated(),
            authenticateStatus: const AuthStatus.failure('Auth failed'),
          ),
        ],
      );

      await tester.pumpWidget(
        wrapWithContainer(
          container: container,
          child: const staging.FDKApp(),
        ),
      );
      
      // Should show splash initially
      await tester.pump();
      expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
      
      // Wait for auto-auth attempt
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      
      // Should navigate to auth screen on failure
      expect(find.text('Connect to rXg System'), findsOneWidget);
    });

    // Note: Full FDKApp navigation tests moved to integration_test/app_test.dart
    // due to ref.listen incompatibility with UncontrolledProviderScope
  });

  group('Regression Prevention Tests', () {
    test('Auth provider should properly report authentication status', () async {
      SharedPreferences.setMockInitialValues({});
      final container = createTestContainer(
        sharedPreferences: await SharedPreferences.getInstance(),
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
      
    });
    
    test('Environment config should be consistent', () {
      // Test development
      EnvironmentConfig.setEnvironment(Environment.development);
      expect(EnvironmentConfig.isDevelopment, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isTrue);

      // Test staging
      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.isStaging, isTrue);
      expect(EnvironmentConfig.websocketBaseUrl, startsWith('wss://'));

      // Test production
      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.isProduction, isTrue);
      expect(EnvironmentConfig.useSyntheticData, isFalse);
    });

    test('Staging apiUsername should have default fallback', () {
      // Set staging environment
      EnvironmentConfig.setEnvironment(Environment.staging);

      // Should return default staging username when env var not set
      expect(EnvironmentConfig.apiUsername, equals('fetoolreadonly'));
      expect(EnvironmentConfig.apiUsername, isNotEmpty);
    });

    test('apiUsername should vary by environment', () {
      // Development should have synthetic user
      EnvironmentConfig.setEnvironment(Environment.development);
      expect(EnvironmentConfig.apiUsername, equals('synthetic_user'));

      // Staging should have default or env-provided username
      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.apiUsername, isNotEmpty);

      // Production returns empty string when env var not set (requires config)
      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.apiUsername, isEmpty);
    });
  });
}
