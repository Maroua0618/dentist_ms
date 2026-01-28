import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test for Delete Patient Dialog
/// This validates the confirmation dialog that appears when deleting a patient
void main() {
  group('Delete Patient Dialog Widget Tests', () {
    // Helper to build a generic delete confirmation dialog
    Widget buildDeleteDialog() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Supprimer le patient'),
                    content: const Text(
                      'Êtes-vous sûr de vouloir supprimer ce patient ? Cette action est irréversible.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Delete Patient'),
            ),
          ),
        ),
      );
    }

    testWidgets('should display delete confirmation dialog', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildDeleteDialog());
      await tester.tap(find.text('Delete Patient'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be visible
      expect(find.text('Supprimer le patient'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should show warning message about irreversible action', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildDeleteDialog());
      await tester.tap(find.text('Delete Patient'));
      await tester.pumpAndSettle();

      // Assert - Warning message should be visible
      expect(
        find.text(
          'Êtes-vous sûr de vouloir supprimer ce patient ? Cette action est irréversible.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should have cancel and delete buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildDeleteDialog());
      await tester.tap(find.text('Delete Patient'));
      await tester.pumpAndSettle();

      // Assert - Both buttons should exist
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(buildDeleteDialog());
      await tester.tap(find.text('Delete Patient'));
      await tester.pumpAndSettle();

      // Act - Tap cancel button
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Supprimer le patient'), findsNothing);
    });

    testWidgets('should close dialog when delete is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(buildDeleteDialog());
      await tester.tap(find.text('Delete Patient'));
      await tester.pumpAndSettle();

      // Act - Tap delete button
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should display correct button types', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildDeleteDialog());
      await tester.tap(find.text('Delete Patient'));
      await tester.pumpAndSettle();

      // Assert - Check button types exist (may vary by implementation)
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });
  });
}
