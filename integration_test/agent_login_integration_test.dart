import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/fake_auth_service.dart';
import '../test/helpers/mock_agent_login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // A basic main app wrapper for the integration test
  Widget createApp() {
    return MaterialApp(
      title: 'Agent App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AgentLoginScreen(authService: FakeAuthService()),
    );
  }

  group('Agent Login End-to-End Test', () {
    testWidgets('Full successful login flow', (WidgetTester tester) async {
      // 1. Load the app
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Verify Initial State
      expect(find.text('Agent Entry'), findsOneWidget);
      expect(find.byKey(const Key('agentIdField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);

      // 2. Try invalid submission
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Ensure validation error shows up
      expect(find.text('Agent ID cannot be empty'), findsOneWidget);

      // 3. Fill invalid Agent ID format
      await tester.enterText(find.byKey(const Key('agentIdField')), 'INVALID');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid Agent ID format'), findsOneWidget);

      // 4. Input valid Agent ID and short password
      await tester.enterText(find.byKey(const Key('agentIdField')), 'AG12345');
      await tester.enterText(find.byKey(const Key('passwordField')), 'short');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      expect(find.text('Password minimum length is 8 characters'), findsOneWidget);

      // 5. Submit valid but incorrect credentials
      await tester.enterText(find.byKey(const Key('passwordField')), 'WrongPass123!');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      
      await tester.tap(find.byKey(const Key('loginButton')));
      // Wait for network response (FakeAuthService has delay)
      await tester.pumpAndSettle(); 
      expect(find.text('Incorrect credentials'), findsOneWidget);

      // 6. Submit correct credentials and verify navigation
      await tester.enterText(find.byKey(const Key('passwordField')), 'ValidPass123!');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      
      await tester.tap(find.byKey(const Key('loginButton')));
      
      // Wait for async task and possible transitions
      await tester.pumpAndSettle();

      // Final Check: ensure Dashboard is rendered
      expect(find.text('Agent Dashboard'), findsOneWidget);
      expect(find.text('Welcome, Agent!'), findsOneWidget);
    });
  });
}
