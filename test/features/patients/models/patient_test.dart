import 'package:flutter_test/flutter_test.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';

void main() {
  group('Patient Model Tests', () {
    // Test data setup
    final validPatientJson = {
      'id': 1,
      'first_name': 'Alice',
      'last_name': 'Smith',
      'gender': 'Female',
      'date_of_birth': '1990-05-15',
      'blood_type': 'O+',
      'phone1': '+1234567890',
      'phone2': '+0987654321',
      'email': 'alice.smith@example.com',
      'address': '123 Main St',
      'city': 'New York',
      'status': 'active',
      'created_at': '2024-01-01T10:00:00Z',
      'updated_at': '2024-01-15T14:30:00Z',
      'profile_image_url': 'https://example.com/alice.jpg',
    };

    test('should create Patient from valid JSON', () {
      // Act
      final patient = Patient.fromJson(validPatientJson);

      // Assert
      expect(patient.id, 1);
      expect(patient.firstName, 'Alice');
      expect(patient.lastName, 'Smith');
      expect(patient.gender, 'Female');
      expect(patient.dateOfBirth, DateTime.parse('1990-05-15'));
      expect(patient.bloodType, 'O+');
      expect(patient.phone1, '+1234567890');
      expect(patient.phone2, '+0987654321');
      expect(patient.email, 'alice.smith@example.com');
      expect(patient.address, '123 Main St');
      expect(patient.city, 'New York');
      expect(patient.status, 'active');
      expect(patient.profileImageUrl, 'https://example.com/alice.jpg');
    });

    test('should handle JSON with null/missing fields gracefully', () {
      // Arrange
      final minimalJson = {'id': 2, 'first_name': 'Bob', 'last_name': 'Jones'};

      // Act
      final patient = Patient.fromJson(minimalJson);

      // Assert
      expect(patient.id, 2);
      expect(patient.firstName, 'Bob');
      expect(patient.lastName, 'Jones');
      expect(patient.gender, isNull);
      expect(patient.dateOfBirth, isNull);
      expect(patient.bloodType, isNull);
      expect(patient.email, isNull);
      expect(patient.profileImageUrl, isNull);
    });

    test('should serialize Patient to JSON correctly', () {
      // Arrange
      final patient = Patient(
        id: 3,
        firstName: 'Carlos',
        lastName: 'Lopez',
        gender: 'Male',
        dateOfBirth: DateTime.parse('1985-03-20'),
        phone1: '+1111111111',
        email: 'carlos@example.com',
        city: 'Los Angeles',
        status: 'active',
      );

      // Act
      final json = patient.toJson();

      // Assert
      expect(json['id'], 3);
      expect(json['first_name'], 'Carlos');
      expect(json['last_name'], 'Lopez');
      expect(json['gender'], 'Male');
      expect(json['date_of_birth'], '1985-03-20');
      expect(json['phone1'], '+1111111111');
      expect(json['email'], 'carlos@example.com');
      expect(json['city'], 'Los Angeles');
      expect(json['status'], 'active');
    });

    test('should generate correct full name', () {
      // Test case 1: Both names present
      final patient1 = Patient(firstName: 'John', lastName: 'Doe');
      expect(patient1.fullName, 'John Doe');

      // Test case 2: Only first name
      final patient2 = Patient(firstName: 'Jane', lastName: '');
      expect(patient2.fullName, 'Jane');

      // Test case 3: Only last name
      final patient3 = Patient(firstName: '', lastName: 'Smith');
      expect(patient3.fullName, 'Smith');

      // Test case 4: Both empty
      final patient4 = Patient(firstName: '', lastName: '');
      expect(patient4.fullName, 'Unknown Patient');

      // Test case 5: Both null
      final patient5 = Patient();
      expect(patient5.fullName, 'Unknown Patient');

      // Test case 6: Names with whitespace
      final patient6 = Patient(firstName: '  Alice  ', lastName: '  Brown  ');
      expect(patient6.fullName, 'Alice Brown');
    });

    test('should create copy with updated fields', () {
      // Arrange
      final original = Patient(
        id: 1,
        firstName: 'Original',
        lastName: 'Patient',
        email: 'original@example.com',
        phone1: '+1111111111',
        status: 'active',
      );

      // Act
      final updated = original.copyWith(
        email: 'updated@example.com',
        phone2: '+2222222222',
        status: 'inactive',
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.firstName, original.firstName);
      expect(updated.lastName, original.lastName);
      expect(updated.email, 'updated@example.com'); // Updated
      expect(updated.phone1, original.phone1); // Unchanged
      expect(updated.phone2, '+2222222222'); // Updated
      expect(updated.status, 'inactive'); // Updated
    });

    test('should handle invalid date formats gracefully', () {
      // Arrange
      final jsonWithInvalidDate = {
        'id': 5,
        'first_name': 'Test',
        'last_name': 'User',
        'date_of_birth': 'invalid-date',
      };

      // Act
      final patient = Patient.fromJson(jsonWithInvalidDate);

      // Assert
      expect(patient.dateOfBirth, isNull);
    });

    test('should serialize date of birth correctly', () {
      // Arrange
      final patient = Patient(
        dateOfBirth: DateTime.parse('1995-12-25T10:30:00Z'),
      );

      // Act
      final json = patient.toJson();

      // Assert - Should only include date part, not time
      expect(json['date_of_birth'], '1995-12-25');
    });

    test(
      'should set default status to active when serializing without status',
      () {
        // Arrange
        final patient = Patient(firstName: 'Test', lastName: 'Patient');

        // Act
        final json = patient.toJson();

        // Assert
        expect(json['status'], 'active');
      },
    );

    test('should support equality comparison', () {
      // Arrange
      final patient1 = const Patient(
        id: 1,
        firstName: 'Test',
        lastName: 'Patient',
        email: 'test@example.com',
      );

      final patient2 = const Patient(
        id: 1,
        firstName: 'Test',
        lastName: 'Patient',
        email: 'test@example.com',
      );

      final patient3 = const Patient(
        id: 2, // Different ID
        firstName: 'Test',
        lastName: 'Patient',
        email: 'test@example.com',
      );

      // Act & Assert
      expect(patient1, equals(patient2)); // Same properties
      expect(patient1, isNot(equals(patient3))); // Different ID
    });

    test('should serialize null id correctly for new patients', () {
      // Arrange - Patient without ID (new patient)
      final newPatient = Patient(
        firstName: 'New',
        lastName: 'Patient',
        email: 'new@example.com',
      );

      // Act
      final json = newPatient.toJson();

      // Assert - ID should not be in JSON when null
      expect(json.containsKey('id'), false);
    });
  });
}
