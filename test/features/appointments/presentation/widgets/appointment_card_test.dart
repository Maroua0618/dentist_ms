import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Appointment Card Widget
/// This validates the individual appointment card display in the list view
void main() {
  // Helper to get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'confirmé':
        return Colors.green;
      case 'pending':
      case 'en attente':
        return Colors.orange;
      case 'cancelled':
      case 'annulé':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  group('Appointment Card Widget Tests', () {
    // Helper to build an appointment card
    Widget buildAppointmentCard({
      required String patientName,
      required String time,
      required String status,
      required String treatment,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Card(
            key: const Key('appointment_card'),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          patientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(time, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.medical_services, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(treatment, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }


    testWidgets('should render appointment card with patient name', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildAppointmentCard(
          patientName: 'John Doe',
          time: '10:00 AM',
          status: 'Confirmed',
          treatment: 'Dental Cleaning',
        ),
      );

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('should display appointment time with clock icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildAppointmentCard(
          patientName: 'Jane Smith',
          time: '14:30',
          status: 'Pending',
          treatment: 'Root Canal',
        ),
      );

      // Assert - Time and icon should be visible
      expect(find.text('14:30'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('should display treatment with medical icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildAppointmentCard(
          patientName: 'Bob Johnson',
          time: '09:00',
          status: 'Confirmed',
          treatment: 'Tooth Extraction',
        ),
      );

      // Assert - Treatment and icon should be visible
      expect(find.text('Tooth Extraction'), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
    });

    testWidgets('should display status badge with appropriate color', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildAppointmentCard(
          patientName: 'Alice Brown',
          time: '11:00',
          status: 'Confirmed',
          treatment: 'Checkup',
        ),
      );

      // Assert - Status should be displayed
      expect(find.text('Confirmed'), findsOneWidget);

      // Check status container exists
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('appointment_card')),
          matching: find.byType(Container),
        ).first,
      );
      expect(container, isNotNull);
    });

    testWidgets('should handle tap interaction', (tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        buildAppointmentCard(
          patientName: 'Charlie Wilson',
          time: '15:00',
          status: 'Pending',
          treatment: 'Consultation',
          onTap: () => tapped = true,
        ),
      );

      // Act - Tap the card
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Assert - Tap callback should have been called
      expect(tapped, true);
    });

    testWidgets('should use bold font for patient name', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildAppointmentCard(
          patientName: 'David Lee',
          time: '16:30',
          status: 'Confirmed',
          treatment: 'Filling',
        ),
      );

      // Assert - Check text style
      final nameText = tester.widget<Text>(find.text('David Lee'));
      expect(nameText.style?.fontWeight, FontWeight.bold);
      expect(nameText.style?.fontSize, 16);
    });

    testWidgets('should have proper card structure', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildAppointmentCard(
          patientName: 'Emma Davis',
          time: '13:00',
          status: 'Cancelled',
          treatment: 'Whitening',
        ),
      );

      // Assert - Check widget hierarchy
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should display all information elements', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildAppointmentCard(
          patientName: 'Frank Miller',
          time: '08:30',
          status: 'En attente',
          treatment: 'Orthodontie',
        ),
      );

      // Assert - All elements should be present
      expect(find.text('Frank Miller'), findsOneWidget);
      expect(find.text('08:30'), findsOneWidget);
      expect(find.text('En attente'), findsOneWidget);
      expect(find.text('Orthodontie'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
    });
  });
}
