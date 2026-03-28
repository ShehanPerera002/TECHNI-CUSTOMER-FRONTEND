import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/widgets/service_card.dart';

void main() {
  group('ServiceCard Widget Tests', () {
    testWidgets('ServiceCard should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCard(
              title: 'Plumbing',
              iconPath: 'assets/icons/plumbing.svg',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Plumbing'), findsOneWidget);
    });

    testWidgets('ServiceCard should display title text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCard(
              title: 'Electrical',
              iconPath: 'assets/icons/electrical.svg',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Electrical'), findsOneWidget);
    });

    testWidgets('ServiceCard should call onTap callback', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCard(
              title: 'AC Repair',
              iconPath: 'assets/icons/ac.svg',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ServiceCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('ServiceCard should handle multiple taps', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCard(
              title: 'Carpentry',
              iconPath: 'assets/icons/carpentry.svg',
              onTap: () {
                tapCount++;
              },
            ),
          ),
        ),
      );

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(ServiceCard));
        await tester.pumpAndSettle();
      }

      expect(tapCount, equals(3));
    });

    testWidgets('ServiceCard should display different service types', 
        (WidgetTester tester) async {
      final services = [
        'Plumbing',
        'Electrical',
        'Painting',
        'Carpentry',
        'AC Repair',
        'Appliance Repair'
      ];

      for (String service in services) {
        await tester.binding.window.physicalSizeTestValue = const Size(800, 600);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ServiceCard(
                title: service,
                iconPath: 'assets/icons/${service.toLowerCase()}.svg',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text(service), findsOneWidget);
      }
    });

    testWidgets('ServiceCard should be visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCard(
              title: 'Cleaning',
              iconPath: 'assets/icons/cleaning.svg',
              onTap: () {},
            ),
          ),
        ),
      );

      final card = find.byType(ServiceCard);
      expect(card, findsOneWidget);
      expect(tester.isOffstage(card), isFalse);
    });

    testWidgets('ServiceCard should handle custom subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCard(
              title: 'Plumbing',
              subtitle: 'Fast & Reliable',
              iconPath: 'assets/icons/plumbing.svg',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.text('Fast & Reliable'), findsOneWidget);
    });

    testWidgets('ServiceCard should support disabled state', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCard(
              title: 'Plumbing',
              iconPath: 'assets/icons/plumbing.svg',
              onTap: () {
                tapped = true;
              },
              enabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ServiceCard));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('ServiceCard should display icon path', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCard(
              title: 'AC Repair',
              iconPath: 'assets/icons/ac_unit.svg',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ServiceCard), findsOneWidget);
    });

    testWidgets('ServiceCard should handle rapid taps', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServiceCard(
              title: 'Plumbing',
              iconPath: 'assets/icons/plumbing.svg',
              onTap: () {
                tapCount++;
              },
            ),
          ),
        ),
      );

      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byType(ServiceCard));
      }
      await tester.pumpAndSettle();

      expect(tapCount, equals(10));
    });
  });
}
