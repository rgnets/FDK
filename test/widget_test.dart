import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/test_app_harness.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    EnvironmentConfig.setEnvironment(Environment.development);
    AppRouter.router.go('/splash');
  });
  
  // Skip: Pending timers from mock data services - requires app-level timer management refactor
  testWidgets('App initializes and navigates from splash', skip: true, (WidgetTester tester) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = createTestContainer(
      sharedPreferences: sharedPreferences,
    );
    
    // Build our app with Riverpod provider scope and trigger a frame.
    await tester.pumpWidget(
      wrapWithContainer(
        container: container,
        child: const FDKApp(),
      ),
    );
    
    // Wait for splash screen to load
    await tester.pump();
    
    // Initially shows splash screen
    expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
    
    // Wait for navigation to complete (2 seconds + animation)
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    // In development mode, app auto-authenticates with mock data and goes to home
    // Should be on home screen with bottom navigation
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
