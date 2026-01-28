import 'package:flutter_test/flutter_test.dart';
import 'package:dentist_ms/core/models/app_user.dart';

void main() {
  group('AppUser Model Tests', () {
    // Test data setup
    final validUserJson = {
      'id': 1,
      'auth_id': 'auth123',
      'email': 'doctor@example.com',
      'first_name': 'John',
      'last_name': 'Doe',
      'role': 'doctor',
      'is_active': true,
      'specialization': 'Orthodontics',
      'phone': '+1234567890',
      'created_at': '2024-01-01T10:00:00Z',
      'updated_at': '2024-01-15T14:30:00Z',
      'profile_image_url': 'https://example.com/profile.jpg',
    };

    test('should create AppUser from valid JSON', () {
      // Act
      final user = AppUser.fromJson(validUserJson);

      // Assert
      expect(user.id, 1);
      expect(user.authId, 'auth123');
      expect(user.email, 'doctor@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.role, UserRole.doctor);
      expect(user.isActive, true);
      expect(user.specialization, 'Orthodontics');
      expect(user.phone, '+1234567890');
      expect(user.profileImageUrl, 'https://example.com/profile.jpg');
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('should handle JSON with missing optional fields', () {
      // Arrange
      final minimalJson = {
        'id': 2,
        'auth_id': 'auth456',
        'email': 'receptionist@example.com',
        'first_name': 'Jane',
        'last_name': 'Smith',
        'role': 'receptionist',
        'is_active': true,
      };

      // Act
      final user = AppUser.fromJson(minimalJson);

      // Assert
      expect(user.id, 2);
      expect(user.firstName, 'Jane');
      expect(user.lastName, 'Smith');
      expect(user.role, UserRole.receptionist);
      expect(user.specialization, isNull);
      expect(user.phone, isNull);
      expect(user.profileImageUrl, isNull);
    });

    test('should serialize AppUser to JSON correctly', () {
      // Arrange
      final user = AppUser(
        id: 3,
        authId: 'auth789',
        email: 'admin@example.com',
        firstName: 'Alice',
        lastName: 'Johnson',
        role: UserRole.admin,
        isActive: true,
        phone: '+9876543210',
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2024-01-15T14:30:00Z'),
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 3);
      expect(json['auth_id'], 'auth789');
      expect(json['email'], 'admin@example.com');
      expect(json['first_name'], 'Alice');
      expect(json['last_name'], 'Johnson');
      expect(json['role'], 'admin');
      expect(json['is_active'], true);
      expect(json['phone'], '+9876543210');
      expect(json['created_at'], '2024-01-01T10:00:00.000Z');
      expect(json['updated_at'], '2024-01-15T14:30:00.000Z');
    });

    test('should correctly generate full name', () {
      // Arrange
      final user = AppUser(
        id: 1,
        authId: 'auth123',
        email: 'test@example.com',
        firstName: 'Michael',
        lastName: 'Brown',
        role: UserRole.doctor,
        isActive: true,
      );

      // Act & Assert
      expect(user.fullName, 'Michael Brown');
    });

    test('should correctly identify role - doctor', () {
      // Arrange
      final doctor = AppUser(
        id: 1,
        authId: 'auth1',
        email: 'doctor@example.com',
        firstName: 'Dr.',
        lastName: 'House',
        role: UserRole.doctor,
        isActive: true,
      );

      // Act & Assert
      expect(doctor.isDoctor, true);
      expect(doctor.isReceptionist, false);
      expect(doctor.isAdmin, false);
    });

    test('should correctly identify role - receptionist', () {
      // Arrange
      final receptionist = AppUser(
        id: 2,
        authId: 'auth2',
        email: 'reception@example.com',
        firstName: 'Sarah',
        lastName: 'Connor',
        role: UserRole.receptionist,
        isActive: true,
      );

      // Act & Assert
      expect(receptionist.isDoctor, false);
      expect(receptionist.isReceptionist, true);
      expect(receptionist.isAdmin, false);
    });

    test('should correctly identify role - admin', () {
      // Arrange
      final admin = AppUser(
        id: 3,
        authId: 'auth3',
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
        isActive: true,
      );

      // Act & Assert
      expect(admin.isDoctor, false);
      expect(admin.isReceptionist, false);
      expect(admin.isAdmin, true);
    });

    test('should create copy with updated fields', () {
      // Arrange
      final original = AppUser(
        id: 1,
        authId: 'auth123',
        email: 'original@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.doctor,
        isActive: true,
      );

      // Act
      final updated = original.copyWith(
        email: 'updated@example.com',
        phone: '+1111111111',
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.authId, original.authId);
      expect(updated.email, 'updated@example.com'); // Updated
      expect(updated.firstName, original.firstName);
      expect(updated.lastName, original.lastName);
      expect(updated.phone, '+1111111111'); // Updated
    });

    test('UserRole.fromString should parse role strings correctly', () {
      // Act & Assert
      expect(UserRole.fromString('doctor'), UserRole.doctor);
      expect(UserRole.fromString('Doctor'), UserRole.doctor);
      expect(UserRole.fromString('DOCTOR'), UserRole.doctor);
      expect(UserRole.fromString('receptionist'), UserRole.receptionist);
      expect(UserRole.fromString('admin'), UserRole.admin);
    });

    test(
      'UserRole.fromString should return receptionist for unknown roles',
      () {
        // Act & Assert
        expect(UserRole.fromString('unknown'), UserRole.receptionist);
        expect(UserRole.fromString(''), UserRole.receptionist);
        expect(UserRole.fromString('invalid_role'), UserRole.receptionist);
      },
    );

    test('AppUser should support equality comparison', () {
      // Arrange
      final user1 = AppUser(
        id: 1,
        authId: 'auth123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.doctor,
        isActive: true,
      );

      final user2 = AppUser(
        id: 1,
        authId: 'auth123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.doctor,
        isActive: true,
      );

      final user3 = AppUser(
        id: 2, // Different ID
        authId: 'auth123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.doctor,
        isActive: true,
      );

      // Act & Assert
      expect(user1, equals(user2)); // Same properties
      expect(user1, isNot(equals(user3))); // Different ID
    });
  });
}
