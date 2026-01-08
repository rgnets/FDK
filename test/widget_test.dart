import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/navigation/app_router.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    // Mock SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });
  
  testWidgets('App initializes and navigates from splash', (WidgetTester tester) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // Build our app with Riverpod provider scope and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const FDKApp(),
      ),
    );
    AppRouter.router.go('/splash');
    await tester.pump();
    
    // Wait for splash screen to load
    await tester.pump();
    
    // Wait for navigation to complete (2 seconds + animation)
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    
    // Should navigate to home screen in development (synthetic data)
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
