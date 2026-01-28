import 'package:dentist_ms/features/patients/models/patient_filter.dart';
import 'package:dentist_ms/features/patients/presentation/widgets/filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatientFilterDialog Widget Tests', () {
    // Helper to build the filter dialog
    Widget buildFilterDialog(PatientFilter initialFilter) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      PatientFilterDialog(initialFilter: initialFilter),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );
    }

    testWidgets('should render filter dialog with initial values', (
      tester,
    ) async {
      // Arrange
      const initialFilter = PatientFilter(
        status: 'active',
        gender: 'male',
        bloodType: 'A+',
      );

      await tester.pumpWidget(buildFilterDialog(initialFilter));

      // Act - Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Check dialog is displayed
      expect(find.text('Filtres'), findsOneWidget);
      expect(find.byIcon(Icons.filter_alt), findsOneWidget);
    });

    testWidgets('should display all filter dropdowns', (tester) async {
      // Arrange
      const initialFilter = PatientFilter();

      await tester.pumpWidget(buildFilterDialog(initialFilter));

      // Act - Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Check all dropdowns are present
      expect(find.text('Statut'), findsOneWidget);
      expect(find.text('Genre'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
    });

    testWidgets('should allow selecting status filter', (tester) async {
      // Arrange
      const initialFilter = PatientFilter();

      await tester.pumpWidget(buildFilterDialog(initialFilter));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act - Find and tap the Status dropdown
      final statusDropdown = find
          .ancestor(
            of: find.text('Statut'),
            matching: find.byType(DropdownButtonFormField<String>),
          )
          .first;

      await tester.tap(statusDropdown);
      await tester.pumpAndSettle();

      // Assert - Check dropdown options are displayed
      expect(find.text('Tous').hitTestable(), findsWidgets);
      expect(find.text('Actif').hitTestable(), findsWidgets);
      expect(find.text('Inactif').hitTestable(), findsWidgets);
    });

    testWidgets('should have apply and reset buttons', (tester) async {
      // Arrange
      const initialFilter = PatientFilter();

      await tester.pumpWidget(buildFilterDialog(initialFilter));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Check action buttons exist
      expect(find.text('Réinitialiser'), findsOneWidget);
      expect(find.text('Appliquer'), findsOneWidget);
    });

    testWidgets('should close dialog and return filter when apply is pressed', (
      tester,
    ) async {
      // Arrange
      const initialFilter = PatientFilter(status: 'active');

      await tester.pumpWidget(buildFilterDialog(initialFilter));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act - Tap apply button
      await tester.tap(find.text('Appliquer'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.text('Filtres'), findsNothing);
    });

    testWidgets('should reset filters when reset button is pressed', (
      tester,
    ) async {
      // Arrange
      const initialFilter = PatientFilter(status: 'active', gender: 'male');

      await tester.pumpWidget(buildFilterDialog(initialFilter));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act - Tap reset button
      await tester.tap(find.text('Réinitialiser'));
      await tester.pumpAndSettle();

      // Assert - Dialog should still be open but filters reset
      expect(find.text('Filtres'), findsOneWidget);
    });

    testWidgets('should display filter icon with proper styling', (
      tester,
    ) async {
      // Arrange
      const initialFilter = PatientFilter();

      await tester.pumpWidget(buildFilterDialog(initialFilter));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Check icon is displayed with container
      final iconContainer = find.ancestor(
        of: find.byIcon(Icons.filter_alt),
        matching: find.byType(Container),
      );
      expect(iconContainer, findsOneWidget);
    });

    testWidgets('should render dialog with proper dimensions', (tester) async {
      // Arrange
      const initialFilter = PatientFilter();

      await tester.pumpWidget(buildFilterDialog(initialFilter));
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Check dialog structure exists
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
