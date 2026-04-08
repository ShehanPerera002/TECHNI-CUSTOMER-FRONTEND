import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/ai_assistant/ai_chat_screen.dart';

void main() {
  testWidgets('AI Chat Screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AIChatScreen(),
    ));

    expect(find.text("AI: Hello! How can I help you today"), findsOneWidget);
    expect(find.text("Describe your problem..."), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });
}
