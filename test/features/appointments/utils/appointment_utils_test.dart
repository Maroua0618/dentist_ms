import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dentist_ms/features/appointments/presentation/utils/appointment_utils.dart';
import 'package:dentist_ms/features/appointments/presentation/models/appointment_model.dart';

void main() {
  group('AppointmentUtils Tests', () {
    group('Treatment Color Tests', () {
      test('should return correct color for "nettoyage dentaire"', () {
        // Act
        final color = AppointmentUtils.getTreatmentColor('Nettoyage dentaire');

        // Assert
        expect(color, const Color(0xFF10B981));
      });

      test('should return correct color for "plombage dentaire"', () {
        // Act
        final color = AppointmentUtils.getTreatmentColor('Plombage dentaire');

        // Assert
        expect(color, const Color(0xFF06B6D4));
      });

      test('should return correct color for "traitement de canal"', () {
        // Act
        final color = AppointmentUtils.getTreatmentColor('Traitement de canal');

        // Assert
        expect(color, const Color(0xFF2563EB));
      });

      test('should return correct color for "couronne"', () {
        // Act
        final color = AppointmentUtils.getTreatmentColor('Couronne');

        // Assert
        expect(color, const Color(0xFFA855F7));
      });

      test('should return correct color for "extraction dentaire"', () {
        // Act
        final color = AppointmentUtils.getTreatmentColor('Extraction dentaire');

        // Assert
        expect(color, const Color(0xFFEF4444));
      });

      test('should return correct color for "implant dentaire"', () {
        // Act
        final color = AppointmentUtils.getTreatmentColor('Implant dentaire');

        // Assert
        expect(color, const Color(0xFF7C3AED));
      });

      test('should be case-insensitive', () {
        // Act
        final color1 = AppointmentUtils.getTreatmentColor('NETTOYAGE DENTAIRE');
        final color2 = AppointmentUtils.getTreatmentColor('nettoyage dentaire');
        final color3 = AppointmentUtils.getTreatmentColor('Nettoyage Dentaire');

        // Assert - All should return the same color
        expect(color1, const Color(0xFF10B981));
        expect(color2, const Color(0xFF10B981));
        expect(color3, const Color(0xFF10B981));
      });

      test('should handle extra whitespace', () {
        // Act
        final color = AppointmentUtils.getTreatmentColor('  Couronne  ');

        // Assert
        expect(color, const Color(0xFFA855F7));
      });

      test('should return default gray color for unknown treatment', () {
        // Act
        final color = AppointmentUtils.getTreatmentColor('Unknown Treatment');

        // Assert
        expect(color, const Color(0xFF6B7280));
      });

      test('should return default gray color for empty string', () {
        // Act
        final color = AppointmentUtils.getTreatmentColor('');

        // Assert
        expect(color, const Color(0xFF6B7280));
      });
    });

    group('Status Color Tests', () {
      test('should return green for confirmed status', () {
        // Act
        final color = AppointmentUtils.getStatusColor('confirmed');

        // Assert
        expect(color, AppointmentUtils.confirmedColor);
        expect(color, const Color(0xFF10B981));
      });

      test('should return blue for pending status', () {
        // Act
        final color = AppointmentUtils.getStatusColor('pending');

        // Assert
        expect(color, AppointmentUtils.pendingColor);
        expect(color, const Color(0xFF3B82F6));
      });

      test('should return red for cancelled status', () {
        // Act
        final color = AppointmentUtils.getStatusColor('cancelled');

        // Assert
        expect(color, AppointmentUtils.cancelledColor);
        expect(color, const Color(0xFFEF4444));
      });

      test('should be case-insensitive for status colors', () {
        // Act
        final color1 = AppointmentUtils.getStatusColor('CONFIRMED');
        final color2 = AppointmentUtils.getStatusColor('Confirmed');
        final color3 = AppointmentUtils.getStatusColor('confirmed');

        // Assert
        expect(color1, const Color(0xFF10B981));
        expect(color2, const Color(0xFF10B981));
        expect(color3, const Color(0xFF10B981));
      });

      test('should return default gray for unknown status', () {
        // Act
        final color = AppointmentUtils.getStatusColor('unknown');

        // Assert
        expect(color, const Color(0xFF6B7280));
      });
    });

    group('DateTime Conversion Tests', () {
      test('should correctly combine date and time', () {
        // Arrange
        final appointment = Appointment(
          id: '1',
          patientId: 101,
          appointmentDate: DateTime(2024, 3, 15),
          time: '14:30',
          duration: 30,
          patientName: 'John Doe',
          doctorName: 'Dr. Smith',
          procedure: 'Checkup',
          status: 'confirmed',
          cardColor: const Color(0xFF10B981),
        );

        // Act
        final dateTime = AppointmentUtils.getAppointmentDateTime(appointment);

        // Assert
        expect(dateTime.year, 2024);
        expect(dateTime.month, 3);
        expect(dateTime.day, 15);
        expect(dateTime.hour, 14);
        expect(dateTime.minute, 30);
      });

      test('should handle morning time (single digit hour)', () {
        // Arrange
        final appointment = Appointment(
          id: '2',
          patientId: 102,
          appointmentDate: DateTime(2024, 5, 20),
          time: '9:00',
          duration: 45,
          patientName: 'Jane Doe',
          doctorName: 'Dr. Jones',
          procedure: 'Cleaning',
          status: 'pending',
          cardColor: const Color(0xFF3B82F6),
        );

        // Act
        final dateTime = AppointmentUtils.getAppointmentDateTime(appointment);

        // Assert
        expect(dateTime.hour, 9);
        expect(dateTime.minute, 0);
      });

      test('should handle time with extra spaces', () {
        // Arrange
        final appointment = Appointment(
          id: '3',
          patientId: 103,
          appointmentDate: DateTime(2024, 6, 10),
          time: ' 16 : 45 ',
          duration: 60,
          patientName: 'Bob Smith',
          doctorName: 'Dr. Brown',
          procedure: 'Filling',
          status: 'confirmed',
          cardColor: const Color(0xFF06B6D4),
        );

        // Act
        final dateTime = AppointmentUtils.getAppointmentDateTime(appointment);

        // Assert
        expect(dateTime.hour, 16);
        expect(dateTime.minute, 45);
      });

      test('should clamp invalid hour to valid range', () {
        // Arrange
        final appointment = Appointment(
          id: '4',
          patientId: 104,
          appointmentDate: DateTime(2024, 7, 5),
          time: '25:30', // Invalid hour
          duration: 30,
          patientName: 'Alice Johnson',
          doctorName: 'Dr. White',
          procedure: 'Extraction',
          status: 'pending',
          cardColor: const Color(0xFFEF4444),
        );

        // Act
        final dateTime = AppointmentUtils.getAppointmentDateTime(appointment);

        // Assert - Hour should be clamped to 23
        expect(dateTime.hour, 23);
        expect(dateTime.minute, 30);
      });

      test('should clamp invalid minute to valid range', () {
        // Arrange
        final appointment = Appointment(
          id: '5',
          patientId: 105,
          appointmentDate: DateTime(2024, 8, 12),
          time: '14:99', // Invalid minute
          duration: 30,
          patientName: 'Charlie Davis',
          doctorName: 'Dr. Green',
          procedure: 'Crown',
          status: 'confirmed',
          cardColor: const Color(0xFFA855F7),
        );

        // Act
        final dateTime = AppointmentUtils.getAppointmentDateTime(appointment);

        // Assert - Minute should be clamped to 59
        expect(dateTime.hour, 14);
        expect(dateTime.minute, 59);
      });

      test('should handle malformed time string gracefully', () {
        // Arrange
        final appointment = Appointment(
          id: '6',
          patientId: 106,
          appointmentDate: DateTime(2024, 9, 25),
          time: 'invalid', // Malformed time
          duration: 30,
          patientName: 'Diana Prince',
          doctorName: 'Dr. Black',
          procedure: 'Implant',
          status: 'pending',
          cardColor: const Color(0xFF7C3AED),
        );

        // Act
        final dateTime = AppointmentUtils.getAppointmentDateTime(appointment);

        // Assert - Should default to 00:00
        expect(dateTime.hour, 0);
        expect(dateTime.minute, 0);
      });

      test('should handle midnight (00:00) correctly', () {
        // Arrange
        final appointment = Appointment(
          id: '7',
          patientId: 107,
          appointmentDate: DateTime(2024, 10, 1),
          time: '00:00',
          duration: 30,
          patientName: 'Eve Wilson',
          doctorName: 'Dr. Gray',
          procedure: 'Consultation',
          status: 'confirmed',
          cardColor: const Color(0xFF10B981),
        );

        // Act
        final dateTime = AppointmentUtils.getAppointmentDateTime(appointment);

        // Assert
        expect(dateTime.hour, 0);
        expect(dateTime.minute, 0);
      });

      test('should handle end of day (23:59) correctly', () {
        // Arrange
        final appointment = Appointment(
          id: '8',
          patientId: 108,
          appointmentDate: DateTime(2024, 11, 15),
          time: '23:59',
          duration: 30,
          patientName: 'Frank Miller',
          doctorName: 'Dr. Blue',
          procedure: 'Emergency',
          status: 'confirmed',
          cardColor: const Color(0xFFEF4444),
        );

        // Act
        final dateTime = AppointmentUtils.getAppointmentDateTime(appointment);

        // Assert
        expect(dateTime.hour, 23);
        expect(dateTime.minute, 59);
      });
    });

    group('Date Key Generation Tests', () {
      test('should generate correct date key for standard date', () {
        // Arrange
        final date = DateTime(2024, 3, 15);

        // Act
        final key = AppointmentUtils.getDateKey(date);

        // Assert
        expect(key, '2024-03-15');
      });

      test('should pad single-digit month with zero', () {
        // Arrange
        final date = DateTime(2024, 5, 20);

        // Act
        final key = AppointmentUtils.getDateKey(date);

        // Assert
        expect(key, '2024-05-20');
      });

      test('should pad single-digit day with zero', () {
        // Arrange
        final date = DateTime(2024, 12, 5);

        // Act
        final key = AppointmentUtils.getDateKey(date);

        // Assert
        expect(key, '2024-12-05');
      });

      test('should handle first day of year', () {
        // Arrange
        final date = DateTime(2024, 1, 1);

        // Act
        final key = AppointmentUtils.getDateKey(date);

        // Assert
        expect(key, '2024-01-01');
      });

      test('should handle last day of year', () {
        // Arrange
        final date = DateTime(2024, 12, 31);

        // Act
        final key = AppointmentUtils.getDateKey(date);

        // Assert
        expect(key, '2024-12-31');
      });

      test('should ignore time component', () {
        // Arrange
        final date1 = DateTime(2024, 6, 15, 0, 0, 0);
        final date2 = DateTime(2024, 6, 15, 23, 59, 59);

        // Act
        final key1 = AppointmentUtils.getDateKey(date1);
        final key2 = AppointmentUtils.getDateKey(date2);

        // Assert - Both should produce same key
        expect(key1, '2024-06-15');
        expect(key2, '2024-06-15');
        expect(key1, equals(key2));
      });

      test('should handle leap year date', () {
        // Arrange - Feb 29 in a leap year
        final date = DateTime(2024, 2, 29);

        // Act
        final key = AppointmentUtils.getDateKey(date);

        // Assert
        expect(key, '2024-02-29');
      });
    });
  });
}
