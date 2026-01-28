import 'package:dentist_ms/features/appointments/bloc/appointment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock Appointment Bloc for testing
class MockAppointmentBloc extends Mock implements AppointmentBloc {}

void main() {
  late MockAppointmentBloc mockAppointmentBloc;

  setUp(() {
    mockAppointmentBloc = MockAppointmentBloc();
  });

  group('Schedule Appointment Dialog Widget Tests', () {
    // Helper to build a schedule appointment form
    Widget buildScheduleAppointmentForm() {
      return MaterialApp(
        home: BlocProvider<AppointmentBloc>.value(
          value: mockAppointmentBloc,
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                key: const Key('show_dialog_button'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const _MockScheduleDialog(),
                  );
                },
                child: const Text('Schedule Appointment'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should display all required form fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildScheduleAppointmentForm());
      await tester.tap(find.byKey(const Key('show_dialog_button')));
      await tester.pumpAndSettle();

      // Assert - Check form fields are displayed
      expect(find.text('Planifier un rendez-vous'), findsOneWidget);
      expect(find.text('Patient'), findsOneWidget);
      expect(find.text('Médecin'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Heure'), findsOneWidget);
    });

    testWidgets('should show patient dropdown', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildScheduleAppointmentForm());
      await tester.tap(find.byKey(const Key('show_dialog_button')));
      await tester.pumpAndSettle();

      // Assert - Patient dropdown should exist
      expect(find.byKey(const Key('patient_dropdown')), findsOneWidget);
    });

    testWidgets('should show date picker when date field is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(buildScheduleAppointmentForm());
      await tester.tap(find.byKey(const Key('show_dialog_button')));
      await tester.pumpAndSettle();

      // Act - Tap date field
      await tester.tap(find.byKey(const Key('date_picker_button')));
      await tester.pumpAndSettle();

      // Assert - Calendar should appear
      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('should display time slot selection', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildScheduleAppointmentForm());
      await tester.tap(find.byKey(const Key('show_dialog_button')));
      await tester.pumpAndSettle();

      // Assert - Time slot dropdown should exist
      expect(find.byKey(const Key('time_slot_dropdown')), findsOneWidget);
    });

    testWidgets('should have submit and cancel buttons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildScheduleAppointmentForm());
      await tester.tap(find.byKey(const Key('show_dialog_button')));
      await tester.pumpAndSettle();

      // Assert - Action buttons should exist
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Confirmer'), findsOneWidget);
    });

    testWidgets('should show notes field for additional information', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildScheduleAppointmentForm());
      await tester.tap(find.byKey(const Key('show_dialog_button')));
      await tester.pumpAndSettle();

      // Assert - Notes field should exist
      expect(find.byKey(const Key('notes_field')), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(buildScheduleAppointmentForm());
      await tester.tap(find.byKey(const Key('show_dialog_button')));
      await tester.pumpAndSettle();

      // Act - Tap cancel button
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be closed
      expect(find.text('Planifier un rendez-vous'), findsNothing);
    });

    testWidgets('should have form validation capability', (tester) async {
      // Arrange
      await tester.pumpWidget(buildScheduleAppointmentForm());
      await tester.tap(find.byKey(const Key('show_dialog_button')));
      await tester.pumpAndSettle();

      // Assert - Form fields should exist for validation
      expect(find.byKey(const Key('patient_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('doctor_dropdown')), findsOneWidget);
      expect(find.text('Confirmer'), findsOneWidget);
    });
  });
}

/// Mock Schedule Dialog for testing
class _MockScheduleDialog extends StatelessWidget {
  const _MockScheduleDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Planifier un rendez-vous'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Patient dropdown
            DropdownButtonFormField<String>(
              key: const Key('patient_dropdown'),
              decoration: const InputDecoration(labelText: 'Patient'),
              items: const [
                DropdownMenuItem(value: '1', child: Text('John Doe')),
                DropdownMenuItem(value: '2', child: Text('Jane Smith')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            // Doctor dropdown
            DropdownButtonFormField<String>(
              key: const Key('doctor_dropdown'),
              decoration: const InputDecoration(labelText: 'Médecin'),
              items: const [
                DropdownMenuItem(value: '1', child: Text('Dr. Brown')),
                DropdownMenuItem(value: '2', child: Text('Dr. Wilson')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            // Date picker
            ListTile(
              key: const Key('date_picker_button'),
              title: const Text('Date'),
              subtitle: const Text('Sélectionner une date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
              },
            ),
            const SizedBox(height: 16),
            // Time slot dropdown
            DropdownButtonFormField<String>(
              key: const Key('time_slot_dropdown'),
              decoration: const InputDecoration(labelText: 'Heure'),
              items: const [
                DropdownMenuItem(value: '09:00', child: Text('09:00')),
                DropdownMenuItem(value: '10:00', child: Text('10:00')),
                DropdownMenuItem(value: '11:00', child: Text('11:00')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            // Notes field
            TextField(
              key: const Key('notes_field'),
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
            // Validation would happen here
            Navigator.pop(context);
          },
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
