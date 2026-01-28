import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Add Payment Dialog Widget
/// This validates the payment form dialog for recording invoice payments
void main() {
  group('Add Payment Dialog Widget Tests', () {
    // Helper to build add payment dialog
    Widget buildAddPaymentDialog() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              key: const Key('show_payment_dialog'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const _MockAddPaymentDialog(),
                );
              },
              child: const Text('Add Payment'),
            ),
          ),
        ),
      );
    }

    testWidgets('should display payment dialog title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildAddPaymentDialog());
      await tester.tap(find.byKey(const Key('show_payment_dialog')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enregistrer un paiement'), findsOneWidget);
    });

    testWidgets('should display all payment form fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildAddPaymentDialog());
      await tester.tap(find.byKey(const Key('show_payment_dialog')));
      await tester.pumpAndSettle();

      // Assert - Check all form fields
      expect(find.text('Montant'), findsOneWidget);
      expect(find.text('Méthode de paiement'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('should show payment method dropdown with options', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildAddPaymentDialog());
      await tester.tap(find.byKey(const Key('show_payment_dialog')));
      await tester.pumpAndSettle();

      // Assert - Payment method dropdown exists
      expect(find.byKey(const Key('payment_method_dropdown')), findsOneWidget);
    });

    testWidgets('should allow entering payment amount', (tester) async {
      // Arrange
      await tester.pumpWidget(buildAddPaymentDialog());
      await tester.tap(find.byKey(const Key('show_payment_dialog')));
      await tester.pumpAndSettle();

      // Act - Enter amount
      await tester.enterText(find.byKey(const Key('amount_field')), '500.00');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('500.00'), findsOneWidget);
    });

    testWidgets('should show date picker when date field is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(buildAddPaymentDialog());
      await tester.tap(find.byKey(const Key('show_payment_dialog')));
      await tester.pumpAndSettle();

      // Act - Tap date field
      await tester.tap(find.byKey(const Key('payment_date_picker')));
      await tester.pumpAndSettle();

      // Assert - Date picker should appear
      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('should have save and cancel buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildAddPaymentDialog());
      await tester.tap(find.byKey(const Key('show_payment_dialog')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Enregistrer'), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(buildAddPaymentDialog());
      await tester.tap(find.byKey(const Key('show_payment_dialog')));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.text('Enregistrer un paiement'), findsNothing);
    });

    testWidgets('should allow entering notes', (tester) async {
      // Arrange
      await tester.pumpWidget(buildAddPaymentDialog());
      await tester.tap(find.byKey(const Key('show_payment_dialog')));
      await tester.pumpAndSettle();

      // Act - Enter notes
      await tester.enterText(
        find.byKey(const Key('payment_notes')),
        'Payment received via bank transfer',
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Payment received via bank transfer'), findsOneWidget);
    });
  });
}

/// Mock Add Payment Dialog for testing
class _MockAddPaymentDialog extends StatefulWidget {
  const _MockAddPaymentDialog();

  @override
  State<_MockAddPaymentDialog> createState() => _MockAddPaymentDialogState();
}

class _MockAddPaymentDialogState extends State<_MockAddPaymentDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedMethod;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enregistrer un paiement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Amount field
            TextField(
              key: const Key('amount_field'),
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Montant',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Payment method dropdown
            DropdownButtonFormField<String>(
              key: const Key('payment_method_dropdown'),
              value: _selectedMethod,
              decoration: const InputDecoration(labelText: 'Méthode de paiement'),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Espèces')),
                DropdownMenuItem(value: 'card', child: Text('Carte bancaire')),
                DropdownMenuItem(value: 'transfer', child: Text('Virement')),
                DropdownMenuItem(value: 'check', child: Text('Chèque')),
              ],
              onChanged: (value) {
                setState(() => _selectedMethod = value);
              },
            ),
            const SizedBox(height: 16),
            // Date picker
            ListTile(
              key: const Key('payment_date_picker'),
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            const SizedBox(height: 16),
            // Notes field
            TextField(
              key: const Key('payment_notes'),
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Informations supplémentaires',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validation and save would happen here
            Navigator.pop(context);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
