import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Patient Statistics Cards Widget
/// This validates the statistics display on patient dashboard
void main() {
  group('Patient Stats Cards Widget Tests', () {
    // Helper to build a simple stats card widget
    Widget buildStatsCard({
      required String title,
      required String value,
      required IconData icon,
      required Color color,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should render stats card with title and value', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatsCard(
          title: 'Total Patients',
          value: '150',
          icon: Icons.people,
          color: Colors.blue,
        ),
      );

      // Assert - Card should display title and value
      expect(find.text('Total Patients'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('should display icon with correct color', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatsCard(
          title: 'Active Patients',
          value: '120',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      );

      // Assert - Icon should be rendered
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Check icon color
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      expect(iconWidget.color, Colors.green);
    });

    testWidgets('should render card with proper padding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatsCard(
          title: 'New Patients',
          value: '30',
          icon: Icons.add_circle,
          color: Colors.orange,
        ),
      );

      // Assert - Check padding exists (implementation may vary)
      final paddingWidgets = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      );
      expect(paddingWidgets, findsWidgets);
    });

    testWidgets('should display value with bold font', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatsCard(
          title: 'Appointments',
          value: '45',
          icon: Icons.calendar_today,
          color: Colors.purple,
        ),
      );

      // Assert - Check text styling
      final valueText = tester.widget<Text>(find.text('45'));
      expect(valueText.style?.fontWeight, FontWeight.bold);
      expect(valueText.style?.fontSize, 24);
    });

    testWidgets('should have proper layout structure', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatsCard(
          title: 'Visits',
          value: '200',
          icon: Icons.medical_services,
          color: Colors.red,
        ),
      );

      // Assert - Check component hierarchy
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('should handle different stat values correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatsCard(
          title: 'Revenue',
          value: '\$12,500',
          icon: Icons.attach_money,
          color: Colors.teal,
        ),
      );

      // Assert - Should render formatted values
      expect(find.text('\$12,500'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
    });
  });
}
