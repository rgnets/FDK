import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
    
    // Wait for splash screen to load
    await tester.pump();
    await tester.pumpAndSettle();
    
    // Initially shows splash screen
    expect(find.text('RG Nets Field Deployment Kit'), findsOneWidget);
    
    // Wait for navigation to complete (2 seconds + animation)
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // Should navigate to auth screen (since no credentials stored)
    expect(find.text('Connect to rXg System'), findsOneWidget);
  });
}