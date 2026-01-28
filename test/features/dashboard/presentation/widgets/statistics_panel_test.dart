import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Dashboard Statistics Panel Widget
/// This validates the statistics overview panel with multiple metrics
void main() {
  group('Dashboard Statistics Panel Widget Tests', () {
    // Helper to build a statistics panel
    Widget buildStatisticsPanel({
      required List<Map<String, dynamic>> stats,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistiques',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...stats.map((stat) => _StatItem(
                        label: stat['label'] as String,
                        value: stat['value'] as String,
                        icon: stat['icon'] as IconData,
                        color: stat['color'] as Color,
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should display panel title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatisticsPanel(stats: []),
      );

      // Assert
      expect(find.text('Statistiques'), findsOneWidget);
    });

    testWidgets('should display all statistics items', (tester) async {
      // Arrange
      final stats = [
        {
          'label': 'Total Patients',
          'value': '1,234',
          'icon': Icons.people,
          'color': Colors.blue,
        },
        {
          'label': 'Appointments Today',
          'value': '15',
          'icon': Icons.calendar_today,
          'color': Colors.green,
        },
        {
          'label': 'Revenue This Month',
          'value': '\$45,678',
          'icon': Icons.attach_money,
          'color': Colors.orange,
        },
      ];

      // Act
      await tester.pumpWidget(buildStatisticsPanel(stats: stats));

      // Assert - All stats should be displayed
      expect(find.text('Total Patients'), findsOneWidget);
      expect(find.text('1,234'), findsOneWidget);
      expect(find.text('Appointments Today'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('Revenue This Month'), findsOneWidget);
      expect(find.text('\$45,678'), findsOneWidget);
    });

    testWidgets('should display icons for each statistic', (tester) async {
      // Arrange
      final stats = [
        {
          'label': 'New Patients',
          'value': '42',
          'icon': Icons.person_add,
          'color': Colors.purple,
        },
      ];

      // Act
      await tester.pumpWidget(buildStatisticsPanel(stats: stats));

      // Assert - Icon should be present
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('should use proper text styling for title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatisticsPanel(stats: []),
      );

      // Assert - Check title styling
      final titleText = tester.widget<Text>(find.text('Statistiques'));
      expect(titleText.style?.fontSize, 20);
      expect(titleText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should display statistics in vertical layout', (tester) async {
      // Arrange
      final stats = [
        {
          'label': 'Stat 1',
          'value': '100',
          'icon': Icons.star,
          'color': Colors.blue,
        },
        {
          'label': 'Stat 2',
          'value': '200',
          'icon': Icons.favorite,
          'color': Colors.red,
        },
      ];

      // Act
      await tester.pumpWidget(buildStatisticsPanel(stats: stats));

      // Assert - Should use Column layout
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have proper padding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatisticsPanel(stats: []),
      );

      // Assert - Check padding exists
      final paddingWidgets = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      );
      expect(paddingWidgets, findsWidgets);
    });

    testWidgets('should handle empty statistics list', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildStatisticsPanel(stats: []),
      );

      // Assert - Should still render title
      expect(find.text('Statistiques'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display multiple statistics correctly', (tester) async {
      // Arrange
      final stats = [
        {
          'label': 'Active Patients',
          'value': '987',
          'icon': Icons.check_circle,
          'color': Colors.green,
        },
        {
          'label': 'Pending Appointments',
          'value': '23',
          'icon': Icons.pending,
          'color': Colors.orange,
        },
        {
          'label': 'Completed Treatments',
          'value': '156',
          'icon': Icons.done_all,
          'color': Colors.blue,
        },
      ];

      // Act
      await tester.pumpWidget(buildStatisticsPanel(stats: stats));

      // Assert - Count stat items
      expect(find.byType(_StatItem), findsNWidgets(3));
    });
  });
}

/// Internal stat item widget for display
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
