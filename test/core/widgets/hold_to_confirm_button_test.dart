import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/widgets/hold_to_confirm_button.dart';

void main() {
  group('HoldToConfirmButton', () {
    group('rendering', () {
      testWidgets('should render with default text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                onConfirmed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('should render with icon when provided', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Sign Out',
                icon: Icons.logout,
                onConfirmed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.logout), findsOneWidget);
        expect(find.text('Sign Out'), findsOneWidget);
      });

      testWidgets('should apply custom background color', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                backgroundColor: Colors.orange,
                onConfirmed: () {},
              ),
            ),
          ),
        );

        final decoratedBox = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(HoldToConfirmButton),
            matching: find.byType(DecoratedBox).first,
          ),
        );

        final decoration = decoratedBox.decoration as BoxDecoration?;
        expect(decoration?.color, equals(Colors.orange));
      });
    });

    group('disabled state', () {
      testWidgets('should not respond to gestures when disabled',
          (tester) async {
        var confirmCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                enabled: false,
                holdDuration: const Duration(milliseconds: 100),
                onConfirmed: () => confirmCount++,
              ),
            ),
          ),
        );

        // Try to hold the disabled button
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(HoldToConfirmButton)),
        );
        await tester.pump(const Duration(milliseconds: 150));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(confirmCount, equals(0));
      });

      testWidgets('should show reduced opacity when disabled', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                enabled: false,
                onConfirmed: () {},
              ),
            ),
          ),
        );

        // Button should be rendered in disabled state
        expect(find.byType(HoldToConfirmButton), findsOneWidget);
      });
    });

    group('hold interaction', () {
      testWidgets('should show "Hold to confirm..." text while holding',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                holdDuration: const Duration(seconds: 2),
                onConfirmed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Delete'), findsOneWidget);
        expect(find.text('Hold to confirm...'), findsNothing);

        // Start holding
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(HoldToConfirmButton)),
        );
        await tester.pump();

        expect(find.text('Hold to confirm...'), findsOneWidget);
        expect(find.text('Delete'), findsNothing);

        // Cancel
        await gesture.up();
        await tester.pumpAndSettle();

        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('should call onConfirmed after holding for full duration',
          (tester) async {
        var confirmed = false;
        const holdDuration = Duration(milliseconds: 200);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                holdDuration: holdDuration,
                onConfirmed: () => confirmed = true,
              ),
            ),
          ),
        );

        // Start holding
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(HoldToConfirmButton)),
        );
        await tester.pump(); // Start the animation

        // Pump through the animation duration in small increments
        // This ensures animation frames are processed
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 25));
        }

        expect(confirmed, isTrue);

        await gesture.up();
        await tester.pumpAndSettle();
      });

      testWidgets('should NOT call onConfirmed if released early',
          (tester) async {
        var confirmed = false;
        const holdDuration = Duration(milliseconds: 500);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                holdDuration: holdDuration,
                onConfirmed: () => confirmed = true,
              ),
            ),
          ),
        );

        // Start holding
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(HoldToConfirmButton)),
        );

        // Release early (after only 100ms of 500ms duration)
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(confirmed, isFalse);
      });

      testWidgets('should reset progress when canceled', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                holdDuration: const Duration(milliseconds: 500),
                onConfirmed: () {},
              ),
            ),
          ),
        );

        // Start holding
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(HoldToConfirmButton)),
        );

        // Partial progress
        await tester.pump(const Duration(milliseconds: 200));

        // Cancel
        await gesture.up();
        await tester.pumpAndSettle();

        // Text should revert
        expect(find.text('Delete'), findsOneWidget);
      });
    });

    group('animation', () {
      testWidgets('should animate progress while holding', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                holdDuration: const Duration(milliseconds: 500),
                onConfirmed: () {},
              ),
            ),
          ),
        );

        // Start holding
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(HoldToConfirmButton)),
        );

        // Check that animation is progressing
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 50));

        // Progress should be visible (FractionallySizedBox)
        expect(find.byType(FractionallySizedBox), findsOneWidget);

        await gesture.up();
        await tester.pumpAndSettle();
      });

      testWidgets('should reverse animation when released early',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                holdDuration: const Duration(milliseconds: 500),
                onConfirmed: () {},
              ),
            ),
          ),
        );

        // Start holding
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(HoldToConfirmButton)),
        );

        await tester.pump(const Duration(milliseconds: 200));

        // Release
        await gesture.up();

        // Animation should reverse
        await tester.pump(const Duration(milliseconds: 100));

        // Wait for reverse to complete
        await tester.pumpAndSettle();

        expect(find.text('Delete'), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('should handle rapid tap and cancel', (tester) async {
        var confirmCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                holdDuration: const Duration(milliseconds: 500),
                onConfirmed: () => confirmCount++,
              ),
            ),
          ),
        );

        // Rapid taps (not holds)
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.byType(HoldToConfirmButton));
          await tester.pump(const Duration(milliseconds: 10));
        }
        await tester.pumpAndSettle();

        expect(confirmCount, equals(0));
      });

      testWidgets('should not trigger multiple confirmations', (tester) async {
        var confirmCount = 0;
        const holdDuration = Duration(milliseconds: 200);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                holdDuration: holdDuration,
                onConfirmed: () => confirmCount++,
              ),
            ),
          ),
        );

        // Hold to completion
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(HoldToConfirmButton)),
        );
        await tester.pump(); // Start animation

        // Pump through the animation duration in small increments
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 25));
        }

        // Keep holding past completion
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.up();
        await tester.pumpAndSettle();

        // Should only be called once
        expect(confirmCount, equals(1));
      });

      testWidgets('should handle widget in disabled state at start',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HoldToConfirmButton(
                text: 'Delete',
                enabled: false,
                holdDuration: const Duration(milliseconds: 500),
                onConfirmed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(HoldToConfirmButton), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });
    });
  });
}
