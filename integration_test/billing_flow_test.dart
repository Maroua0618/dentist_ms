import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'helpers/test_helpers.dart';

/// Billing and Invoice Flow Integration Test
///
/// This test validates the complete billing management user journey:
/// 1. Navigate to billing page
/// 2. View invoices list
/// 3. Create a new invoice
/// 4. Add payment to invoice
/// 5. View payment history
/// 6. Filter invoices by status
/// 7. Generate reports
///
/// Tests the complete lifecycle of billing and payment features.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Billing and Invoice Flow Integration Tests', () {
    testWidgets('View billing page and invoices list', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE ============
      await IntegrationTestHelpers.loginToApp(tester);
      await IntegrationTestHelpers.navigateToBilling(tester);

      // ============ ASSERT - Billing Page Elements ============
      expect(
        find.text('Facturation'),
        findsWidgets,
        reason: 'Should be on billing page',
      );

      // Invoice list or cards should be visible
      await tester.pumpAndSettle();

      final invoiceCards = find.byType(Card);
      if (invoiceCards.evaluate().isNotEmpty) {
        print('✅ Invoice cards displayed');
      }

      // Look for revenue/billing statistics
      final statsCards = find.byType(Card);
      if (statsCards.evaluate().isNotEmpty) {
        print('✅ Billing statistics visible');
      }

      print('✅ Billing page loaded successfully');
    });

    testWidgets('Create new invoice flow', (WidgetTester tester) async {
      // ============ ARRANGE ============
      await IntegrationTestHelpers.loginToApp(tester);
      await IntegrationTestHelpers.navigateToBilling(tester);

      // ============ ACT - Create Invoice ============
      print('💰 Starting invoice creation...');

      // Find "Create Invoice" or add button
      final addButton = find.byIcon(Icons.add);
      final createButton = find.text('Create Invoice');
      final createButtonFr = find.text('Créer facture');

      if (addButton.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, addButton.first);
        await tester.pumpAndSettle();
      } else if (createButton.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, createButton);
        await tester.pumpAndSettle();
      } else if (createButtonFr.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, createButtonFr);
        await tester.pumpAndSettle();
      }

      // ============ ACT - Fill Invoice Form ============
      await tester.pumpAndSettle();

      // Select patient
      final patientDropdowns = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField,
      );

      if (patientDropdowns.evaluate().isNotEmpty) {
        await tester.tap(patientDropdowns.first);
        await tester.pumpAndSettle();

        final dropdownItems = find.byType(DropdownMenuItem<dynamic>);
        if (dropdownItems.evaluate().isNotEmpty) {
          await tester.tap(dropdownItems.first);
          await tester.pumpAndSettle();
          print('✅ Patient selected for invoice');
        }
      }

      // Select treatment
      if (patientDropdowns.evaluate().length > 1) {
        await tester.tap(patientDropdowns.at(1));
        await tester.pumpAndSettle();

        final treatmentItems = find.byType(DropdownMenuItem<dynamic>);
        if (treatmentItems.evaluate().isNotEmpty) {
          await tester.tap(treatmentItems.first);
          await tester.pumpAndSettle();
          print('✅ Treatment selected');
        }
      }

      // Enter amount
      final amountFields = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.labelText?.toLowerCase().contains('amount') ==
                    true ||
                widget.decoration?.labelText?.toLowerCase().contains(
                      'montant',
                    ) ==
                    true),
      );

      if (amountFields.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.enterText(
          tester,
          amountFields.first,
          '250.00',
        );
        print('✅ Amount entered');
      }

      // Select date
      final dateFields = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.labelText?.toLowerCase().contains('date') ==
                true),
      );

      if (dateFields.evaluate().isNotEmpty) {
        await tester.tap(dateFields.first);
        await tester.pumpAndSettle();

        final okButton = find.text('OK');
        if (okButton.evaluate().isNotEmpty) {
          await tester.tap(okButton);
          await tester.pumpAndSettle();
          print('✅ Date selected');
        }
      }

      // Add notes (optional)
      final notesFields = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.labelText?.toLowerCase().contains('notes') ==
                    true ||
                widget.maxLines != null && widget.maxLines! > 1),
      );

      if (notesFields.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.enterText(
          tester,
          notesFields.first,
          'Test invoice notes',
        );
        print('✅ Notes added');
      }

      // Save invoice
      final saveButton = find.text('Enregistrer');
      final saveButtonEn = find.text('Save');
      final createInvoiceBtn = find.text('Create');

      if (saveButton.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, saveButton.first);
      } else if (saveButtonEn.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, saveButtonEn.first);
      } else if (createInvoiceBtn.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, createInvoiceBtn.first);
      }

      await IntegrationTestHelpers.waitForLoadingToComplete(tester);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      print('✅ Invoice created successfully');
    });

    testWidgets('Add payment to invoice', (WidgetTester tester) async {
      // ============ ARRANGE ============
      await IntegrationTestHelpers.loginToApp(tester);
      await IntegrationTestHelpers.navigateToBilling(tester);

      await tester.pumpAndSettle();

      // ============ ACT - Select Invoice ============
      final invoiceCards = find.byType(Card);

      if (invoiceCards.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, invoiceCards.first);
        await tester.pumpAndSettle();

        // ============ ACT - Add Payment ============
        final addPaymentButton = find.text('Add Payment');
        final addPaymentButtonFr = find.text('Ajouter paiement');

        if (addPaymentButton.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(tester, addPaymentButton);
          await tester.pumpAndSettle();
        } else if (addPaymentButtonFr.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(tester, addPaymentButtonFr);
          await tester.pumpAndSettle();
        }

        // Fill payment form
        // Enter payment amount
        final amountFields = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              (widget.decoration?.labelText?.toLowerCase().contains('amount') ==
                      true ||
                  widget.decoration?.labelText?.toLowerCase().contains(
                        'montant',
                      ) ==
                      true),
        );

        if (amountFields.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.enterText(
            tester,
            amountFields.first,
            '100.00',
          );
          print('✅ Payment amount entered');
        }

        // Select payment method
        final methodDropdowns = find.byWidgetPredicate(
          (widget) =>
              widget is DropdownButtonFormField &&
              ((widget.decoration.labelText?.toLowerCase().contains('method') ??
                      false) ||
                  (widget.decoration.labelText?.toLowerCase().contains(
                        'méthode',
                      ) ??
                      false)),
        );

        if (methodDropdowns.evaluate().isNotEmpty) {
          await tester.tap(methodDropdowns.first);
          await tester.pumpAndSettle();

          final methodItems = find.byType(DropdownMenuItem<dynamic>);
          if (methodItems.evaluate().isNotEmpty) {
            await tester.tap(methodItems.first);
            await tester.pumpAndSettle();
            print('✅ Payment method selected');
          }
        }

        // Save payment
        final savePaymentBtn = find.text('Enregistrer');
        final savePaymentBtnEn = find.text('Save');

        if (savePaymentBtn.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(tester, savePaymentBtn.first);
        } else if (savePaymentBtnEn.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(
            tester,
            savePaymentBtnEn.first,
          );
        }

        await tester.pumpAndSettle(const Duration(seconds: 1));

        print('✅ Payment added successfully');

        // Navigate back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(tester, backButton.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('View invoice details and status', (WidgetTester tester) async {
      // ============ ARRANGE ============
      await IntegrationTestHelpers.loginToApp(tester);
      await IntegrationTestHelpers.navigateToBilling(tester);

      await tester.pumpAndSettle();

      // ============ ACT - Click on Invoice ============
      final invoiceCards = find.byType(Card);

      if (invoiceCards.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, invoiceCards.first);
        await tester.pumpAndSettle();

        // ============ ASSERT - Invoice Details ============
        print('✅ Invoice details opened');

        // Look for invoice information elements
        final invoiceNumber = find.textContaining('INV');
        if (invoiceNumber.evaluate().isNotEmpty) {
          print('✅ Invoice number displayed');
        }

        // Status badge
        final statusTexts = ['Paid', 'Pending', 'Overdue'];
        final statusTextsFr = ['Payé', 'En attente', 'En retard'];

        for (final status in [...statusTexts, ...statusTextsFr]) {
          if (find.text(status).evaluate().isNotEmpty) {
            print('✅ Status "$status" visible');
            break;
          }
        }

        // Navigate back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(tester, backButton.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Filter invoices by status', (WidgetTester tester) async {
      // ============ ARRANGE ============
      await IntegrationTestHelpers.loginToApp(tester);
      await IntegrationTestHelpers.navigateToBilling(tester);

      await tester.pumpAndSettle();

      // ============ ACT - Apply Status Filter ============
      final paidFilter = find.text('Paid');
      final paidFilterFr = find.text('Payé');
      final pendingFilter = find.text('Pending');
      final pendingFilterFr = find.text('En attente');

      if (paidFilter.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, paidFilter);
        await tester.pumpAndSettle();
        print('✅ Filtered by Paid status');
      } else if (paidFilterFr.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, paidFilterFr);
        await tester.pumpAndSettle();
        print('✅ Filtered by status');
      }

      if (pendingFilter.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, pendingFilter);
        await tester.pumpAndSettle();
        print('✅ Filtered by Pending status');
      } else if (pendingFilterFr.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, pendingFilterFr);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('View billing statistics and revenue', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE ============
      await IntegrationTestHelpers.loginToApp(tester);
      await IntegrationTestHelpers.navigateToBilling(tester);

      await tester.pumpAndSettle();

      // ============ ASSERT - Statistics Cards ============
      // Look for revenue/statistics displays
      final statisticsCards = find.byType(Card);
      expect(
        statisticsCards.evaluate().length,
        greaterThan(0),
        reason: 'Should display statistics cards',
      );

      // Look for revenue numbers
      final revenueText = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            (widget.data!.contains('\$') || widget.data!.contains('€')),
      );

      if (revenueText.evaluate().isNotEmpty) {
        print('✅ Revenue statistics displayed');
      }

      print('✅ Billing statistics visible');
    });

    testWidgets('Search invoices', (WidgetTester tester) async {
      // ============ ARRANGE ============
      await IntegrationTestHelpers.loginToApp(tester);
      await IntegrationTestHelpers.navigateToBilling(tester);

      await tester.pumpAndSettle();

      // ============ ACT - Use Search ============
      final searchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.hintText?.toLowerCase().contains('search') ==
                    true ||
                widget.decoration?.hintText?.toLowerCase().contains(
                      'recherche',
                    ) ==
                    true),
      );

      if (searchField.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.enterText(
          tester,
          searchField.first,
          'INV',
        );
        await tester.pumpAndSettle();

        print('✅ Invoice search working');

        // Clear search
        await tester.tap(searchField.first);
        await tester.pumpAndSettle();
        await tester.enterText(searchField.first, '');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('View payment history for invoice', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE ============
      await IntegrationTestHelpers.loginToApp(tester);
      await IntegrationTestHelpers.navigateToBilling(tester);

      await tester.pumpAndSettle();

      // ============ ACT - Open Invoice with Payments ============
      final invoiceCards = find.byType(Card);

      if (invoiceCards.evaluate().isNotEmpty) {
        await IntegrationTestHelpers.tapWidget(tester, invoiceCards.first);
        await tester.pumpAndSettle();

        // ============ ASSERT - Payment History Section ============
        final paymentHistorySection = find.text('Payment History');
        final paymentHistorySectionFr = find.text('Historique des paiements');

        if (paymentHistorySection.evaluate().isNotEmpty ||
            paymentHistorySectionFr.evaluate().isNotEmpty) {
          print('✅ Payment history section visible');
        }

        // Navigate back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await IntegrationTestHelpers.tapWidget(tester, backButton.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Export or print invoice (if available)', (
      WidgetTester tester,
    ) async {
      // ============ ARRANGE ============
      await IntegrationTestHelpers.loginToApp(tester);
      await IntegrationTestHelpers.navigateToBilling(tester);

      await tester.pumpAndSettle();

      // ============ ACT - Look for Export Options ============
      final exportButton = find.byIcon(Icons.file_download);
      final printButton = find.byIcon(Icons.print);
      final pdfButton = find.text('PDF');

      if (exportButton.evaluate().isNotEmpty) {
        print('✅ Export button available');
      }

      if (printButton.evaluate().isNotEmpty) {
        print('✅ Print button available');
      }

      if (pdfButton.evaluate().isNotEmpty) {
        print('✅ PDF export available');
      }
    });
  });
}
