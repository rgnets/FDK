import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/auth/presentation/widgets/credential_approval_sheet.dart';

void main() {
  testWidgets('CredentialApprovalSheet toggles API key visibility', (tester) async {
    const apiKey = 'ABCDEFGHIJKLMNOP';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CredentialApprovalSheet(
            fqdn: 'zew.netlab.ninja',
            login: 'fieldtech',
            apiKey: apiKey,
          ),
        ),
      ),
    );

    expect(find.textContaining('••••'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pumpAndSettle();

    expect(find.text(apiKey), findsOneWidget);
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
    expect(find.text('API key is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'zew.netlab.ninja');
    await tester.enterText(find.byType(TextFormField).at(1), 'fieldtech');
    await tester.enterText(find.byType(TextFormField).at(2), '1234567890');

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Server is required'), findsNothing);
    expect(find.text('Login is required'), findsNothing);
    expect(find.text('API key is required'), findsNothing);
  });
}
