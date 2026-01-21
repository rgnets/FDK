import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/auth/presentation/widgets/credential_approval_sheet.dart';

void main() {
  group('JSON Credential Import', () {
    testWidgets('displays mode toggle with Manual and JSON options',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ManualCredentialEntrySheet(),
          ),
        ),
      );

      // Should find the SegmentedButton with both modes
      expect(find.text('Manual'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
    });

    testWidgets('starts in Manual mode by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ManualCredentialEntrySheet(),
          ),
        ),
      );

      // Manual mode shows the form fields
      expect(find.text('Server (fqdn)'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Token'), findsOneWidget);
    });

    testWidgets('switches to JSON mode when JSON toggle is tapped',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ManualCredentialEntrySheet(),
          ),
        ),
      );

      // Tap on JSON mode
      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();

      // JSON mode should show a multi-line text field for JSON input
      expect(find.byKey(const Key('json_input_field')), findsOneWidget);
      // Manual fields should be hidden
      expect(find.text('Server (fqdn)'), findsNothing);
    });

    testWidgets('JSON mode parses valid JSON with api_key format',
        (tester) async {
      Map<String, String>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManualCredentialEntrySheet(
              onCredentialsSubmitted: (creds) {
                result = creds;
              },
            ),
          ),
        ),
      );

      // Switch to JSON mode
      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();

      // Enter valid JSON
      const validJson = '''
{
  "fqdn": "test.example.com",
  "login": "testuser",
  "api_key": "test-token-12345",
  "site_name": "Test Site"
}''';
      await tester.enterText(
        find.byKey(const Key('json_input_field')),
        validJson,
      );

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should parse successfully
      expect(result, isNotNull);
      expect(result!['fqdn'], 'test.example.com');
      expect(result!['login'], 'testuser');
      expect(result!['token'], 'test-token-12345');
      expect(result!['siteName'], 'Test Site');
    });

    testWidgets('JSON mode parses valid JSON with apiKey format',
        (tester) async {
      Map<String, String>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManualCredentialEntrySheet(
              onCredentialsSubmitted: (creds) {
                result = creds;
              },
            ),
          ),
        ),
      );

      // Switch to JSON mode
      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();

      // Enter valid JSON with apiKey format
      const validJson = '''
{
  "fqdn": "test.example.com",
  "login": "testuser",
  "apiKey": "test-token-12345",
  "siteName": "Test Site"
}''';
      await tester.enterText(
        find.byKey(const Key('json_input_field')),
        validJson,
      );

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should parse successfully with normalized keys
      expect(result, isNotNull);
      expect(result!['fqdn'], 'test.example.com');
      expect(result!['login'], 'testuser');
      expect(result!['token'], 'test-token-12345');
      expect(result!['siteName'], 'Test Site');
    });

    testWidgets('JSON mode shows error for invalid JSON syntax',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ManualCredentialEntrySheet(),
          ),
        ),
      );

      // Switch to JSON mode
      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();

      // Enter invalid JSON
      await tester.enterText(
        find.byKey(const Key('json_input_field')),
        '{ invalid json }',
      );

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should show error
      expect(find.text('Invalid JSON format'), findsOneWidget);
    });

    testWidgets('JSON mode shows error for missing required fields',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ManualCredentialEntrySheet(),
          ),
        ),
      );

      // Switch to JSON mode
      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();

      // Enter JSON missing required fields
      const incompleteJson = '''
{
  "fqdn": "test.example.com"
}''';
      await tester.enterText(
        find.byKey(const Key('json_input_field')),
        incompleteJson,
      );

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should show error about missing fields
      expect(find.textContaining('Missing required field'), findsOneWidget);
    });

    testWidgets('JSON mode ignores extra fields in JSON', (tester) async {
      Map<String, String>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManualCredentialEntrySheet(
              onCredentialsSubmitted: (creds) {
                result = creds;
              },
            ),
          ),
        ),
      );

      // Switch to JSON mode
      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();

      // Enter JSON with extra fields
      const jsonWithExtras = '''
{
  "fqdn": "test.example.com",
  "login": "testuser",
  "api_key": "test-token-12345",
  "site_name": "Test Site",
  "extra_field": "should be ignored",
  "another_extra": 12345
}''';
      await tester.enterText(
        find.byKey(const Key('json_input_field')),
        jsonWithExtras,
      );

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should parse successfully, ignoring extras
      expect(result, isNotNull);
      expect(result!['fqdn'], 'test.example.com');
      expect(result!.containsKey('extra_field'), isFalse);
    });

    testWidgets('Manual mode still works after switching modes',
        (tester) async {
      Map<String, String>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ManualCredentialEntrySheet(
              onCredentialsSubmitted: (creds) {
                result = creds;
              },
            ),
          ),
        ),
      );

      // Switch to JSON mode and back to Manual
      await tester.tap(find.text('JSON'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Manual'));
      await tester.pumpAndSettle();

      // Enter manual credentials - find TextFormFields by their labels
      final fqdnField = find.ancestor(
        of: find.text('Server (fqdn)'),
        matching: find.byType(TextFormField),
      );
      final loginField = find.ancestor(
        of: find.text('Login'),
        matching: find.byType(TextFormField),
      );
      final tokenField = find.ancestor(
        of: find.text('Token'),
        matching: find.byType(TextFormField),
      );

      await tester.enterText(fqdnField, 'zew.netlab.ninja');
      await tester.enterText(loginField, 'fieldtech');
      await tester.enterText(tokenField, '1234567890123');

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should work correctly
      expect(result, isNotNull);
      expect(result!['fqdn'], 'zew.netlab.ninja');
      expect(result!['login'], 'fieldtech');
      expect(result!['token'], '1234567890123');
    });
  });

  testWidgets('CredentialApprovalSheet toggles token visibility', (tester) async {
    const token = 'ABCDEFGHIJKLMNOP';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CredentialApprovalSheet(
            fqdn: 'zew.netlab.ninja',
            login: 'fieldtech',
            token: token,
          ),
        ),
      ),
    );

    expect(find.textContaining('••••'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();

    expect(find.text(token), findsOneWidget);
  });

  testWidgets('ManualCredentialEntrySheet validates required fields', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ManualCredentialEntrySheet(),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Server is required'), findsOneWidget);
    expect(find.text('Login is required'), findsOneWidget);
    expect(find.text('token is required'), findsOneWidget);

    // Find TextFormFields by their labels
    final fqdnField = find.ancestor(
      of: find.text('Server (fqdn)'),
      matching: find.byType(TextFormField),
    );
    final loginField = find.ancestor(
      of: find.text('Login'),
      matching: find.byType(TextFormField),
    );
    final tokenField = find.ancestor(
      of: find.text('Token'),
      matching: find.byType(TextFormField),
    );

    await tester.enterText(fqdnField, 'zew.netlab.ninja');
    await tester.enterText(loginField, 'fieldtech');
    await tester.enterText(tokenField, '1234567890');

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Server is required'), findsNothing);
    expect(find.text('Login is required'), findsNothing);
    expect(find.text('token is required'), findsNothing);
  });
}
