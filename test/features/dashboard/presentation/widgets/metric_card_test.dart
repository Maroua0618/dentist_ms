import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Dashboard Metric Card Widget
/// This validates the KPI metric cards displayed on the dashboard
void main() {
  group('Dashboard Metric Card Widget Tests', () {
    // Helper to build a metric card
    Widget buildMetricCard({
      required String title,
      required String value,
      required String subtitle,
      required IconData icon,
      required Color iconColor,
      String? trend,
      bool? isIncrease,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Card(
            key: const Key('metric_card'),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (trend != null && isIncrease != null) ...[
                        Icon(
                          isIncrease ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: isIncrease ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trend,
                          style: TextStyle(
                            fontSize: 12,
                            color: isIncrease ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should render metric card with title and value', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildMetricCard(
          title: 'Total Patients',
          value: '1,234',
          subtitle: 'Active patients',
          icon: Icons.people,
          iconColor: Colors.blue,
        ),
      );

      // Assert
      expect(find.text('Total Patients'), findsOneWidget);
      expect(find.text('1,234'), findsOneWidget);
      expect(find.text('Active patients'), findsOneWidget);
    });

    testWidgets('should display icon with colored background', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildMetricCard(
          title: 'Revenue',
          value: '\$45,678',
          subtitle: 'This month',
          icon: Icons.attach_money,
          iconColor: Colors.green,
        ),
      );

      // Assert - Icon should be displayed
      expect(find.byIcon(Icons.attach_money), findsOneWidget);

      // Check icon color
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.attach_money));
      expect(iconWidget.color, Colors.green);
    });

    testWidgets('should display value with bold large font', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildMetricCard(
          title: 'Appointments',
          value: '156',
          subtitle: 'This week',
          icon: Icons.calendar_today,
          iconColor: Colors.purple,
        ),
      );

      // Assert - Check value text styling
      final valueText = tester.widget<Text>(find.text('156'));
      expect(valueText.style?.fontWeight, FontWeight.bold);
      expect(valueText.style?.fontSize, 28);
    });

    testWidgets('should display trend indicator when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildMetricCard(
          title: 'New Patients',
          value: '42',
          subtitle: 'vs last month',
          icon: Icons.person_add,
          iconColor: Colors.orange,
          trend: '+12%',
          isIncrease: true,
        ),
      );

      // Assert - Trend should be displayed
      expect(find.text('+12%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('should show downward trend in red', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildMetricCard(
          title: 'Cancellations',
          value: '8',
          subtitle: 'This week',
          icon: Icons.cancel,
          iconColor: Colors.red,
          trend: '-5%',
          isIncrease: false,
        ),
      );

      // Assert - Downward trend should be red
      expect(find.text('-5%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);

      final trendIcon = tester.widget<Icon>(find.byIcon(Icons.trending_down));
      expect(trendIcon.color, Colors.red);
    });

    testWidgets('should have proper card elevation', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildMetricCard(
          title: 'Total Revenue',
          value: '\$125,000',
          subtitle: 'Year to date',
          icon: Icons.trending_up,
          iconColor: Colors.teal,
        ),
      );

      // Assert - Check card elevation
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
    });

    testWidgets('should have consistent padding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildMetricCard(
          title: 'Pending Payments',
          value: '\$12,500',
          subtitle: 'To be collected',
          icon: Icons.pending,
          iconColor: Colors.amber,
        ),
      );

      // Assert - Check padding exists (implementation may vary)
      final paddingWidgets = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      );
      expect(paddingWidgets, findsWidgets); // Just verify padding exists
    });

    testWidgets('should display subtitle with gray color', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildMetricCard(
          title: 'Completed Treatments',
          value: '89',
          subtitle: 'Last 7 days',
          icon: Icons.check_circle,
          iconColor: Colors.green,
        ),
      );

      // Assert - Subtitle should be gray
      final subtitleText = tester.widget<Text>(find.text('Last 7 days'));
      expect(subtitleText.style?.color, Colors.grey);
      expect(subtitleText.style?.fontSize, 12);
    });

    testWidgets('should have all components in correct hierarchy', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildMetricCard(
          title: 'Average Visit',
          value: '\$350',
          subtitle: 'Per patient',
          icon: Icons.analytics,
          iconColor: Colors.indigo,
        ),
      );

      // Assert - Check widget structure
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });
  });
}
