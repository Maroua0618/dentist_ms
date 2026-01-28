import 'package:flutter_test/flutter_test.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';
import 'package:dentist_ms/features/patients/models/patient_filter.dart';
import 'package:dentist_ms/features/patients/presentation/utils/patient_filter_util.dart';

void main() {
  group('PatientFilterUtil Tests', () {
    // Test data setup
    final patients = [
      Patient(
        id: 1,
        firstName: 'Alice',
        lastName: 'Smith',
        gender: 'Female',
        bloodType: 'O+',
        status: 'active',
        createdAt: DateTime.parse('2024-01-15'),
      ),
      Patient(
        id: 2,
        firstName: 'Bob',
        lastName: 'Jones',
        gender: 'Male',
        bloodType: 'A+',
        status: 'active',
        createdAt: DateTime.parse('2024-02-20'),
      ),
      Patient(
        id: 3,
        firstName: 'Charlie',
        lastName: 'Brown',
        gender: 'Male',
        bloodType: 'B+',
        status: 'inactive',
        createdAt: DateTime.parse('2024-03-10'),
      ),
      Patient(
        id: 4,
        firstName: 'Diana',
        lastName: 'Prince',
        gender: 'Female',
        bloodType: 'AB+',
        status: 'active',
        createdAt: DateTime.parse('2024-04-05'),
      ),
    ];

    test('should return all patients when filter is empty', () {
      // Arrange
      const filter = PatientFilter();

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, patients.length);
      expect(result, equals(patients));
    });

    test('should filter by status - active', () {
      // Arrange
      const filter = PatientFilter(status: 'active');

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, 3);
      expect(result.every((p) => p.status == 'active'), true);
      expect(result.map((p) => p.id).toList(), [1, 2, 4]);
    });

    test('should filter by status - inactive', () {
      // Arrange
      const filter = PatientFilter(status: 'inactive');

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 3);
      expect(result.first.status, 'inactive');
    });

    test('should filter by status case-insensitively', () {
      // Arrange
      const filter = PatientFilter(status: 'ACTIVE');

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, 3);
      expect(result.every((p) => p.status?.toLowerCase() == 'active'), true);
    });

    test('should filter by gender - Male', () {
      // Arrange
      const filter = PatientFilter(gender: 'Male');

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, 2);
      expect(result.map((p) => p.id).toList(), [2, 3]);
      expect(result.every((p) => p.gender == 'Male'), true);
    });

    test('should filter by gender - Female', () {
      // Arrange
      const filter = PatientFilter(gender: 'Female');

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, 2);
      expect(result.map((p) => p.id).toList(), [1, 4]);
      expect(result.every((p) => p.gender == 'Female'), true);
    });

    test('should filter by gender case-insensitively', () {
      // Arrange
      const filter = PatientFilter(gender: 'female');

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, 2);
      expect(result.every((p) => p.gender?.toLowerCase() == 'female'), true);
    });

    test('should filter by blood type', () {
      // Arrange
      const filter = PatientFilter(bloodType: 'A+');

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 2);
      expect(result.first.bloodType, 'A+');
    });

    test('should filter by multiple blood types', () {
      // Arrange - Test each blood type
      const filterO = PatientFilter(bloodType: 'O+');
      const filterA = PatientFilter(bloodType: 'A+');
      const filterB = PatientFilter(bloodType: 'B+');
      const filterAB = PatientFilter(bloodType: 'AB+');

      // Act & Assert
      expect(PatientFilterUtil.applyFilters(patients, filterO).length, 1);
      expect(PatientFilterUtil.applyFilters(patients, filterA).length, 1);
      expect(PatientFilterUtil.applyFilters(patients, filterB).length, 1);
      expect(PatientFilterUtil.applyFilters(patients, filterAB).length, 1);
    });

    test('should filter by date from (after specific date)', () {
      // Arrange
      final filter = PatientFilter(dateFrom: DateTime.parse('2024-02-01'));

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert - Patients created after Feb 1, 2024
      expect(result.length, 3);
      expect(result.map((p) => p.id).toList(), [2, 3, 4]);
    });

    test('should filter by date to (before specific date)', () {
      // Arrange
      final filter = PatientFilter(dateTo: DateTime.parse('2024-03-01'));

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert - Patients created before March 1, 2024
      expect(result.length, 2);
      expect(result.map((p) => p.id).toList(), [1, 2]);
    });

    test('should filter by date range', () {
      // Arrange
      final filter = PatientFilter(
        dateFrom: DateTime.parse('2024-02-01'),
        dateTo: DateTime.parse('2024-04-01'),
      );

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert - Patients created between Feb 1 and April 1, 2024
      expect(result.length, 2);
      expect(result.map((p) => p.id).toList(), [2, 3]);
    });

    test('should combine multiple filters - status and gender', () {
      // Arrange
      const filter = PatientFilter(status: 'active', gender: 'Female');

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, 2);
      expect(result.map((p) => p.id).toList(), [1, 4]);
      expect(
        result.every((p) => p.status == 'active' && p.gender == 'Female'),
        true,
      );
    });

    test(
      'should combine multiple filters - status, gender, and blood type',
      () {
        // Arrange
        const filter = PatientFilter(
          status: 'active',
          gender: 'Female',
          bloodType: 'O+',
        );

        // Act
        final result = PatientFilterUtil.applyFilters(patients, filter);

        // Assert
        expect(result.length, 1);
        expect(result.first.id, 1);
      },
    );

    test('should combine all filters', () {
      // Arrange
      final filter = PatientFilter(
        status: 'active',
        gender: 'Female',
        bloodType: 'AB+',
        dateFrom: DateTime.parse('2024-04-01'),
        dateTo: DateTime.parse('2024-05-01'),
      );

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 4);
    });

    test('should return empty list when no patients match filters', () {
      // Arrange
      const filter = PatientFilter(
        status: 'archived', // No patient has this status
      );

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert
      expect(result, isEmpty);
    });

    test('should handle patients without createdAt when filtering by date', () {
      // Arrange
      final patientsWithNullDates = [
        const Patient(id: 1, firstName: 'Test', lastName: 'User'),
        Patient(
          id: 2,
          firstName: 'Valid',
          lastName: 'Date',
          createdAt: DateTime.parse('2024-03-15'),
        ),
      ];

      final filter = PatientFilter(dateFrom: DateTime.parse('2024-01-01'));

      // Act
      final result = PatientFilterUtil.applyFilters(
        patientsWithNullDates,
        filter,
      );

      // Assert - Only patient with valid date should be included
      expect(result.length, 1);
      expect(result.first.id, 2);
    });

    test('should handle patients without status when filtering by status', () {
      // Arrange
      final patientsWithNullStatus = [
        const Patient(id: 1, firstName: 'No', lastName: 'Status'),
        const Patient(
          id: 2,
          firstName: 'Has',
          lastName: 'Status',
          status: 'active',
        ),
      ];

      const filter = PatientFilter(status: 'active');

      // Act
      final result = PatientFilterUtil.applyFilters(
        patientsWithNullStatus,
        filter,
      );

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 2);
    });

    test('should handle empty patient list', () {
      // Arrange
      final emptyList = <Patient>[];
      const filter = PatientFilter(status: 'active');

      // Act
      final result = PatientFilterUtil.applyFilters(emptyList, filter);

      // Assert
      expect(result, isEmpty);
    });

    test('should preserve original list order when filtering', () {
      // Arrange
      const filter = PatientFilter(gender: 'Male');

      // Act
      final result = PatientFilterUtil.applyFilters(patients, filter);

      // Assert - Should maintain order: Bob (2), Charlie (3)
      expect(result.map((p) => p.id).toList(), [2, 3]);
    });
  });
}
