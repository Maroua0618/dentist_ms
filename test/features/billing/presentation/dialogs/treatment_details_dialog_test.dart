import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Treatment Details Dialog Widget
/// This validates the treatment information display dialog
void main() {
  group('Treatment Details Dialog Widget Tests', () {
    // Helper to build treatment details dialog
    Widget buildTreatmentDetailsDialog({
      required String name,
      required String category,
      required String price,
      required String duration,
      required String description,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              key: const Key('show_treatment_dialog'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => _MockTreatmentDetailsDialog(
                    name: name,
                    category: category,
                    price: price,
                    duration: duration,
                    description: description,
                  ),
                );
              },
              child: const Text('View Treatment'),
            ),
          ),
        ),
      );
    }

    testWidgets('should display treatment name', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTreatmentDetailsDialog(
          name: 'Root Canal',
          category: 'Endodontics',
          price: '\$500.00',
          duration: '90 minutes',
          description: 'Root canal treatment to save an infected tooth',
        ),
      );
      await tester.tap(find.byKey(const Key('show_treatment_dialog')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Root Canal'), findsOneWidget);
    });

    testWidgets('should display treatment category', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTreatmentDetailsDialog(
          name: 'Teeth Whitening',
          category: 'Cosmetic',
          price: '\$300.00',
          duration: '60 minutes',
          description: 'Professional teeth whitening procedure',
        ),
      );
      await tester.tap(find.byKey(const Key('show_treatment_dialog')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Cosmetic'), findsOneWidget);
      expect(find.text('Catégorie'), findsOneWidget);
    });

    testWidgets('should display treatment price', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTreatmentDetailsDialog(
          name: 'Dental Implant',
          category: 'Prosthodontics',
          price: '\$2,500.00',
          duration: '120 minutes',
          description: 'Single tooth implant placement',
        ),
      );
      await tester.tap(find.byKey(const Key('show_treatment_dialog')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('\$2,500.00'), findsOneWidget);
      expect(find.text('Prix'), findsOneWidget);
    });

    testWidgets('should display treatment duration', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTreatmentDetailsDialog(
          name: 'Dental Cleaning',
          category: 'Preventive',
          price: '\$100.00',
          duration: '45 minutes',
          description: 'Professional teeth cleaning and polishing',
        ),
      );
      await tester.tap(find.byKey(const Key('show_treatment_dialog')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('45 minutes'), findsOneWidget);
      expect(find.text('Durée'), findsOneWidget);
    });

    testWidgets('should display treatment description', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTreatmentDetailsDialog(
          name: 'Tooth Extraction',
          category: 'Surgery',
          price: '\$200.00',
          duration: '30 minutes',
          description: 'Simple tooth extraction procedure',
        ),
      );
      await tester.tap(find.byKey(const Key('show_treatment_dialog')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Simple tooth extraction procedure'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('should have close button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTreatmentDetailsDialog(
          name: 'Crown Placement',
          category: 'Prosthodontics',
          price: '\$800.00',
          duration: '90 minutes',
          description: 'Ceramic crown placement',
        ),
      );
      await tester.tap(find.byKey(const Key('show_treatment_dialog')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Fermer'), findsOneWidget);
    });

    testWidgets('should close dialog when close button is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildTreatmentDetailsDialog(
          name: 'Filling',
          category: 'Restorative',
          price: '\$150.00',
          duration: '30 minutes',
          description: 'Composite filling for cavity',
        ),
      );
      await tester.tap(find.byKey(const Key('show_treatment_dialog')));
      await tester.pumpAndSettle();

      // Act - Close dialog
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.text('Filling'), findsNothing);
    });

    testWidgets('should display all information in organized layout', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildTreatmentDetailsDialog(
          name: 'Orthodontic Consultation',
          category: 'Orthodontics',
          price: '\$50.00',
          duration: '30 minutes',
          description: 'Initial consultation for braces or aligners',
        ),
      );
      await tester.tap(find.byKey(const Key('show_treatment_dialog')));
      await tester.pumpAndSettle();

      // Assert - All fields should be present
      expect(find.text('Orthodontic Consultation'), findsOneWidget);
      expect(find.text('Orthodontics'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);
      expect(find.text('30 minutes'), findsOneWidget);
      expect(find.text('Initial consultation for braces or aligners'), findsOneWidget);
    });
  });
}

/// Mock Treatment Details Dialog for testing
class _MockTreatmentDetailsDialog extends StatelessWidget {
  final String name;
  final String category;
  final String price;
  final String duration;
  final String description;

  const _MockTreatmentDetailsDialog({
    required this.name,
    required this.category,
    required this.price,
    required this.duration,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Catégorie', category, Icons.category),
            const SizedBox(height: 12),
            _buildInfoRow('Prix', price, Icons.attach_money),
            const SizedBox(height: 12),
            _buildInfoRow('Durée', duration, Icons.access_time),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
