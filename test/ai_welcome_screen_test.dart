import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/ai_assistant/ai_welcome_screen.dart';

void main() {
  testWidgets('AI Welcome Screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AIWelcomeScreen(),
    ));

    expect(find.byIcon(Icons.smart_toy), findsOneWidget);
    expect(find.text("Hello! I'm your AI Assistant"), findsOneWidget);
    expect(find.text("Start chat"), findsOneWidget);
  });
}
