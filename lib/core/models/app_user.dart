import 'package:equatable/equatable.dart';

enum UserRole {
  doctor,
  receptionist,
  admin;

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role. toLowerCase(),
      orElse: () => UserRole.receptionist,
    );
  }
}

class AppUser extends Equatable {
  final int id;
  final String authId;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final bool isActive;
  final String? specialization;
  final String? phone;
  final String? profilePhotoPath;
  final DateTime? createdAt;

  const AppUser({
    required this. id,
    required this.authId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    this.specialization,
    this. phone,
    this.profilePhotoPath,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  bool get isDoctor => role == UserRole.doctor;
  bool get isReceptionist => role == UserRole. receptionist;
  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      authId: json['auth_id'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'receptionist'),
      isActive: json['is_active'] ?? true,
      specialization: json['specialization'],
      phone: json['phone'],
      profilePhotoPath: json['profile_photo_path'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'auth_id': authId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'role': role.name,
        'is_active':  isActive,
        'specialization': specialization,
        'phone': phone,
        'profile_photo_path': profilePhotoPath,
        'created_at':  createdAt?.toIso8601String(),
      };

  @override
  List<Object? > get props => [
        id,
        authId,
        email,
        firstName,
        lastName,
        role,
        isActive,
        specialization,
        phone,
        profilePhotoPath,
        createdAt,
      ];
}