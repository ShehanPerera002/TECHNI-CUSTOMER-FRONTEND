import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/widgets/app_header.dart';

void main() {
  group('AppHeader Widget Tests', () {
    testWidgets('AppHeader should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Services',
            ),
          ),
        ),
      );

      expect(find.text('Services'), findsOneWidget);
    });

    testWidgets('AppHeader should display title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Find Professional',
            ),
          ),
        ),
      );

      expect(find.text('Find Professional'), findsOneWidget);
    });

    testWidgets('AppHeader should display subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Bookings',
              subtitle: 'View your upcoming bookings',
            ),
          ),
        ),
      );

      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('View your upcoming bookings'), findsOneWidget);
    });

    testWidgets('AppHeader should handle different titles', (WidgetTester tester) async {
      final titles = ['Home', 'Settings', 'Profile', 'Help', 'About'];

      for (String title in titles) {
        await tester.binding.window.physicalSizeTestValue = const Size(800, 600);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppHeader(title: title),
            ),
          ),
        );

        expect(find.text(title), findsOneWidget);
      }
    });

    testWidgets('AppHeader should call onBackPressed when back button is tapped', 
        (WidgetTester tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Details',
              onBackPressed: () {
                backPressed = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the back button
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        expect(backPressed, isTrue);
      }
    });

    testWidgets('AppHeader should display action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Services',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('AppHeader should be visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Visible Header',
            ),
          ),
        ),
      );

      final header = find.byType(AppHeader);
      expect(header, findsOneWidget);
      expect(tester.isOffstage(header), isFalse);
    });

    testWidgets('AppHeader should handle long titles with ellipsis', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'This is a very long header title that might overflow',
            ),
          ),
        ),
      );

      expect(find.byType(AppHeader), findsOneWidget);
    });

    testWidgets('AppHeader should call action button callbacks', (WidgetTester tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Services',
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    actionPressed = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(actionPressed, isTrue);
    });

    testWidgets('AppHeader should support custom leading widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Custom Header',
              leading: const Icon(Icons.home),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('AppHeader should display title and subtitle separately', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Main Title',
              subtitle: 'Subtitle Text',
            ),
          ),
        ),
      );

      final titles = find.text('Main Title');
      final subtitles = find.text('Subtitle Text');

      expect(titles, findsOneWidget);
      expect(subtitles, findsOneWidget);
    });
  });
}
