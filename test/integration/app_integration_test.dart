import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fixtures/test_app_harness.dart';

/// Integration tests for API connectivity and data loading.
///
/// Note: Full-app tests using FDKApp have been moved to integration_test/app_test.dart
/// because FDKApp uses ref.listen in initState, which is incompatible with
/// UncontrolledProviderScope in widget tests.
///
/// Run full-app integration tests with:
///   flutter test integration_test/app_test.dart
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
}
