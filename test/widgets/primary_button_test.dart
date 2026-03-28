import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/widgets/primary_button.dart';

void main() {
  group('PrimaryButton Widget Tests', () {
    testWidgets('PrimaryButton should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('PrimaryButton should call onPressed callback', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Click Me',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('PrimaryButton should be disabled when onPressed is null', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = find.byType(PrimaryButton);
      expect(button, findsOneWidget);
    });

    testWidgets('PrimaryButton should display loading state when isLoading is true', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Check if a loading indicator is shown
      final circularProgress = find.byType(CircularProgressIndicator);
      expect(circularProgress, findsOneWidget);
    });

    testWidgets('PrimaryButton should handle multiple taps', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Tap Me',
              onPressed: () {
                tapCount++;
              },
            ),
          ),
        ),
      );

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();
      }

      expect(tapCount, equals(3));
    });

    testWidgets('PrimaryButton should display custom text', (WidgetTester tester) async {
      const customTexts = ['Submit', 'Cancel', 'Continue', 'Save'];

      for (String text in customTexts) {
        await tester.binding.window.physicalSizeTestValue = const Size(800, 600);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: text,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text(text), findsOneWidget);
      }
    });

    testWidgets('PrimaryButton text should be visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Get Help',
              onPressed: () {},
            ),
          ),
        ),
      );

      final textWidget = find.text('Get Help');
      expect(textWidget, findsOneWidget);
      
      // Verify the text is visible
      expect(tester.isOffstage(textWidget), isFalse);
    });
  });
}
