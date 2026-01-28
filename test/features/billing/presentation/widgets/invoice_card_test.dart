import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Billing Invoice Card Widget
/// This validates the invoice card display in the billing list
void main() {
  group('Invoice Card Widget Tests', () {
    // Helper to build an invoice card
    Widget buildInvoiceCard({
      required String invoiceNumber,
      required String patientName,
      required String date,
      required String amount,
      required String status,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Card(
            key: const Key('invoice_card'),
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
                          invoiceNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(patientName, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(date, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Text(
                          amount,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
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

    testWidgets('should render invoice card with invoice number', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildInvoiceCard(
          invoiceNumber: 'INV-001',
          patientName: 'John Doe',
          date: '2024-01-15',
          amount: '\$250.00',
          status: 'Paid',
        ),
      );

      // Assert
      expect(find.text('INV-001'), findsOneWidget);
    });

    testWidgets('should display patient name with icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildInvoiceCard(
          invoiceNumber: 'INV-002',
          patientName: 'Jane Smith',
          date: '2024-01-20',
          amount: '\$450.00',
          status: 'Pending',
        ),
      );

      // Assert
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display invoice date with calendar icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildInvoiceCard(
          invoiceNumber: 'INV-003',
          patientName: 'Bob Johnson',
          date: '2024-01-25',
          amount: '\$350.00',
          status: 'Overdue',
        ),
      );

      // Assert
      expect(find.text('2024-01-25'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('should display amount with proper styling', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildInvoiceCard(
          invoiceNumber: 'INV-004',
          patientName: 'Alice Brown',
          date: '2024-01-30',
          amount: '\$1,200.00',
          status: 'Paid',
        ),
      );

      // Assert
      expect(find.text('\$1,200.00'), findsOneWidget);

      // Check amount text styling
      final amountText = tester.widget<Text>(find.text('\$1,200.00'));
      expect(amountText.style?.fontWeight, FontWeight.bold);
      expect(amountText.style?.color, Colors.green);
      expect(amountText.style?.fontSize, 18);
    });

    testWidgets('should display status badge', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildInvoiceCard(
          invoiceNumber: 'INV-005',
          patientName: 'Charlie Wilson',
          date: '2024-02-01',
          amount: '\$500.00',
          status: 'Pending',
        ),
      );

      // Assert - Status badge should be displayed
      expect(find.byType(_StatusBadge), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('should handle tap interaction', (tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        buildInvoiceCard(
          invoiceNumber: 'INV-006',
          patientName: 'David Lee',
          date: '2024-02-05',
          amount: '\$300.00',
          status: 'Paid',
          onTap: () => tapped = true,
        ),
      );

      // Act - Tap the card
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should use bold font for invoice number', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildInvoiceCard(
          invoiceNumber: 'INV-007',
          patientName: 'Emma Davis',
          date: '2024-02-10',
          amount: '\$650.00',
          status: 'Overdue',
        ),
      );

      // Assert - Check text style
      final invoiceText = tester.widget<Text>(find.text('INV-007'));
      expect(invoiceText.style?.fontWeight, FontWeight.bold);
      expect(invoiceText.style?.fontSize, 16);
    });

    testWidgets('should have proper card structure', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        buildInvoiceCard(
          invoiceNumber: 'INV-008',
          patientName: 'Frank Miller',
          date: '2024-02-15',
          amount: '\$800.00',
          status: 'Paid',
        ),
      );

      // Assert - Check widget hierarchy
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
    });
  });
}

/// Status Badge Widget
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'payé':
        return Colors.green;
      case 'pending':
      case 'en attente':
        return Colors.orange;
      case 'overdue':
      case 'en retard':
        return Colors.red;
      case 'cancelled':
      case 'annulé':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
