import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/widgets/input_field.dart';

void main() {
  group('InputField Widget Tests', () {
    testWidgets('InputField should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Enter name',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.byType(CustomInputField), findsOneWidget);
    });

    testWidgets('InputField should display hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Enter your email',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('InputField should accept text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Enter text',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello World');
      expect(controller.text, equals('Hello World'));
    });

    testWidgets('InputField should handle empty input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Enter text',
              controller: controller,
            ),
          ),
        ),
      );

      expect(controller.text, isEmpty);
    });

    testWidgets('InputField should clear text when controller is cleared', 
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Enter text',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Some text');
      expect(controller.text, equals('Some text'));

      controller.clear();
      await tester.pumpAndSettle();

      expect(controller.text, isEmpty);
    });

    testWidgets('InputField should support different input types', (WidgetTester tester) async {
      final emailController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Enter email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test@example.com');
      expect(emailController.text, equals('test@example.com'));
    });

    testWidgets('InputField should show error message when provided', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Enter name',
              controller: TextEditingController(),
              errorText: 'Name is required',
            ),
          ),
        ),
      );

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('InputField should use custom label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('InputField should handle focus changes', (WidgetTester tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Enter text',
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        ),
      );

      expect(focusNode.hasFocus, isFalse);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('InputField should be disabled when enabled is false', 
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Disabled field',
              controller: controller,
              enabled: false,
            ),
          ),
        ),
      );

      expect(find.byType(CustomInputField), findsOneWidget);
    });

    testWidgets('InputField should update text programmatically', 
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomInputField(
              hint: 'Enter text',
              controller: controller,
            ),
          ),
        ),
      );

      controller.text = 'Programmatic text';
      await tester.pumpAndSettle();

      expect(find.text('Programmatic text'), findsOneWidget);
    });
  });
}
