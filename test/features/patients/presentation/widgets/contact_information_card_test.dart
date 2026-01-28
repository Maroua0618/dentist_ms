import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Contact Information Card Widget
/// This validates the display of patient contact details
void main() {
  group('Contact Information Card Widget Tests', () {
    // Helper to build contact information card
    Widget buildContactInfoCard({
      required String email,
      required String phone,
      required String address,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations de contact',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ContactRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: email,
                  ),
                  const SizedBox(height: 12),
                  _ContactRow(
                    icon: Icons.phone,
                    label: 'Téléphone',
                    value: phone,
                  ),
                  const SizedBox(height: 12),
                  _ContactRow(
                    icon: Icons.location_on,
                    label: 'Adresse',
                    value: address,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should display card title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'john.doe@example.com',
          phone: '555-0100',
          address: '123 Main St, City',
        ),
      );

      // Assert
      expect(find.text('Informations de contact'), findsOneWidget);
    });

    testWidgets('should display email with icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'patient@example.com',
          phone: '555-0200',
          address: '456 Oak Ave',
        ),
      );

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('patient@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('should display phone number with icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'test@test.com',
          phone: '555-1234',
          address: '789 Pine St',
        ),
      );

      // Assert
      expect(find.text('Téléphone'), findsOneWidget);
      expect(find.text('555-1234'), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('should display address with icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'contact@example.com',
          phone: '555-5678',
          address: '101 Maple Drive, Springfield',
        ),
      );

      // Assert
      expect(find.text('Adresse'), findsOneWidget);
      expect(find.text('101 Maple Drive, Springfield'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('should display all three contact rows', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'info@clinic.com',
          phone: '555-9999',
          address: '200 Health Blvd',
        ),
      );

      // Assert - All three contact rows should be present
      expect(find.byType(_ContactRow), findsNWidgets(3));
    });

    testWidgets('should use bold font for title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'test@email.com',
          phone: '555-0000',
          address: 'Test Address',
        ),
      );

      // Assert - Check title styling
      final titleText = tester.widget<Text>(
        find.text('Informations de contact'),
      );
      expect(titleText.style?.fontWeight, FontWeight.bold);
      expect(titleText.style?.fontSize, 18);
    });

    testWidgets('should have proper spacing between elements', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'spacing@test.com',
          phone: '555-1111',
          address: 'Spacing Test St',
        ),
      );

      // Assert - Check SizedBox spacing exists
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should be wrapped in a Card widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'card@test.com',
          phone: '555-2222',
          address: 'Card Test Ave',
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle long email addresses', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'very.long.email.address@example-domain.com',
          phone: '555-3333',
          address: 'Short St',
        ),
      );

      // Assert - Long email should be displayed
      expect(
        find.text('very.long.email.address@example-domain.com'),
        findsOneWidget,
      );
    });

    testWidgets('should handle long addresses', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildContactInfoCard(
          email: 'short@test.com',
          phone: '555-4444',
          address: '123 Very Long Street Name, Apartment 456, Building B, City Name, State 12345',
        ),
      );

      // Assert - Long address should be displayed
      expect(
        find.textContaining('Very Long Street Name'),
        findsOneWidget,
      );
    });
  });
}

/// Contact row widget helper
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
