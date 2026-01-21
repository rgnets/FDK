import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/initialization/domain/entities/initialization_state.dart';
import 'package:rgnets_fdk/features/initialization/presentation/providers/initialization_provider.dart';
import 'package:rgnets_fdk/features/initialization/presentation/widgets/initialization_overlay.dart';

/// Test override for initialization state
class TestInitializationNotifier extends InitializationNotifier {
  TestInitializationNotifier(this._testState);

  final InitializationState _testState;

  @override
  InitializationState build() => _testState;
}

void main() {
  group('InitializationOverlay', () {
    Widget buildWidget(InitializationState state) {
      return ProviderScope(
        overrides: [
          initializationNotifierProvider.overrideWith(
            () => TestInitializationNotifier(state),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: InitializationOverlay(),
          ),
        ),
      );
    }

    testWidgets('displays logo image', (tester) async {
      await tester.pumpWidget(
        buildWidget(const InitializationState.checkingConnection()),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows "Checking connection..." during checkingConnection',
        (tester) async {
      await tester.pumpWidget(
        buildWidget(const InitializationState.checkingConnection()),
      );

      expect(find.text('Checking connection...'), findsOneWidget);
    });

    testWidgets('shows "Validating credentials..." during validatingCredentials',
        (tester) async {
      await tester.pumpWidget(
        buildWidget(const InitializationState.validatingCredentials()),
      );

      expect(find.text('Validating credentials...'), findsOneWidget);
    });

    testWidgets('shows custom operation text during loadingData', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.loadingData(
            currentOperation: 'Loading devices...',
          ),
        ),
      );

      expect(find.text('Loading devices...'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator during loading', (tester) async {
      await tester.pumpWidget(
        buildWidget(const InitializationState.loadingData()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows bytes downloaded during loadingData', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.loadingData(
            bytesDownloaded: 10240,
            currentOperation: 'Loading...',
          ),
        ),
      );

      expect(find.text('10 KB downloaded'), findsOneWidget);
    });

    testWidgets('shows error icon on error state', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.error(
            message: 'Connection failed',
            retryCount: 0,
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows error message on error state', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.error(
            message: 'Connection failed',
            retryCount: 0,
          ),
        ),
      );

      expect(find.text('Connection failed'), findsOneWidget);
    });

    testWidgets('shows retry button on error state', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.error(
            message: 'Error',
            retryCount: 0,
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.textContaining('Retry'), findsOneWidget);
    });

    testWidgets('shows scan new button on error state', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.error(
            message: 'Error',
            retryCount: 0,
          ),
        ),
      );

      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.text('Scan New'), findsOneWidget);
    });

    testWidgets('shows retry count in button text', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.error(
            message: 'Error',
            retryCount: 1,
          ),
        ),
      );

      // The retry button shows the count
      expect(find.textContaining('1'), findsWidgets);
    });

    testWidgets('has semi-transparent background', (tester) async {
      await tester.pumpWidget(
        buildWidget(const InitializationState.checkingConnection()),
      );

      // The InitializationOverlay wraps content in a Material with black54
      final materials = tester.widgetList<Material>(find.byType(Material));
      final hasBlack54Material = materials.any(
        (m) => m.color == Colors.black54,
      );
      expect(hasBlack54Material, isTrue);
    });

    testWidgets('has centered card with content', (tester) async {
      await tester.pumpWidget(
        buildWidget(const InitializationState.checkingConnection()),
      );

      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });
  });
}
