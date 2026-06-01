import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/features/initialization/domain/entities/initialization_state.dart';
import 'package:rgnets_fdk/features/initialization/presentation/providers/initialization_provider.dart';
import 'package:rgnets_fdk/features/initialization/presentation/providers/seed_checklist_provider.dart';
import 'package:rgnets_fdk/features/initialization/presentation/widgets/initialization_overlay.dart';

/// Test override for initialization state
class TestInitializationNotifier extends InitializationNotifier {
  TestInitializationNotifier(this._testState);

  final InitializationState _testState;

  @override
  InitializationState build() => _testState;
}

/// Test override that pins the checklist to a fixed set of rows.
class TestSeedChecklistNotifier extends SeedChecklistNotifier {
  TestSeedChecklistNotifier(this._items);

  final List<SeedItem> _items;

  @override
  List<SeedItem> build() => _items;
}

void main() {
  group('InitializationOverlay', () {
    Widget buildWidget(
      InitializationState state, {
      List<SeedItem>? checklist,
    }) {
      return ProviderScope(
        overrides: [
          initializationNotifierProvider.overrideWith(
            () => TestInitializationNotifier(state),
          ),
          if (checklist != null)
            seedChecklistProvider.overrideWith(
              () => TestSeedChecklistNotifier(checklist),
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

    testWidgets('shows "Loading app…" title during loading states',
        (tester) async {
      for (final state in const [
        InitializationState.checkingConnection(),
        InitializationState.validatingCredentials(),
        InitializationState.loadingData(),
      ]) {
        await tester.pumpWidget(buildWidget(state));
        expect(find.text('Loading app…'), findsOneWidget);
      }
    });

    testWidgets('renders a checklist row for every seed resource',
        (tester) async {
      await tester.pumpWidget(
        buildWidget(const InitializationState.loadingData()),
      );

      for (final label in const [
        'Access Points',
        'Switches',
        'ONTs',
        'WLAN Controllers',
        'Rooms',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('shows overall "X of Y ready" progress', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.loadingData(),
          checklist: const [
            SeedItem(
              resourceType: 'access_points',
              label: 'Access Points',
              status: SeedItemStatus.done,
              count: 7,
            ),
            SeedItem(
              resourceType: 'pms_rooms',
              label: 'Rooms',
              status: SeedItemStatus.loading,
            ),
          ],
        ),
      );

      expect(find.text('1 of 2 ready'), findsOneWidget);
      // The done row surfaces its item count.
      expect(find.text('7'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows "Finalizing…" once every row is resolved', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.loadingData(),
          checklist: const [
            SeedItem(
              resourceType: 'access_points',
              label: 'Access Points',
              status: SeedItemStatus.done,
              count: 3,
            ),
            SeedItem(
              resourceType: 'pms_rooms',
              label: 'Rooms',
              status: SeedItemStatus.done,
              count: 5,
            ),
          ],
        ),
      );

      // All rows resolved but state is still loadingData (persist in progress):
      // the overlay must read as finalizing, not stuck at "2 of 2 ready".
      expect(find.text('Finalizing…'), findsOneWidget);
      expect(find.textContaining('ready'), findsNothing);
    });

    testWidgets('a loading row shows a spinner', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.loadingData(),
          checklist: const [
            SeedItem(
              resourceType: 'access_points',
              label: 'Access Points',
              status: SeedItemStatus.loading,
            ),
          ],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('a failed row is marked Failed', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          const InitializationState.loadingData(),
          checklist: const [
            SeedItem(
              resourceType: 'wlan_devices',
              label: 'WLAN Controllers',
              status: SeedItemStatus.failed,
            ),
          ],
        ),
      );

      expect(find.text('Failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('has an opaque background so the app behind is hidden',
        (tester) async {
      await tester.pumpWidget(
        buildWidget(const InitializationState.checkingConnection()),
      );

      final materials = tester.widgetList<Material>(find.byType(Material));
      expect(
        materials.any((m) => m.color == AppColors.backgroundDark),
        isTrue,
      );
    });

    testWidgets('has centered card with content', (tester) async {
      await tester.pumpWidget(
        buildWidget(const InitializationState.checkingConnection()),
      );

      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });

    group('error state', () {
      testWidgets('shows error icon', (tester) async {
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

      testWidgets('shows error message', (tester) async {
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

      testWidgets('shows retry button with count', (tester) async {
        await tester.pumpWidget(
          buildWidget(
            const InitializationState.error(
              message: 'Error',
              retryCount: 1,
            ),
          ),
        );

        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(find.textContaining('Retry'), findsOneWidget);
        expect(find.textContaining('1'), findsWidgets);
      });

      testWidgets('shows scan new button', (tester) async {
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
    });
  });
}
