import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ClinicInfo extends Equatable {
  final String clinicName;
  final String registrationNumber;
  final String email;
  final String phone;
  final String address;
  final String about;

  const ClinicInfo({
    required this.clinicName,
    required this.registrationNumber,
    required this.email,
    required this.phone,
    required this.address,
    required this.about,
  });

  factory ClinicInfo.fromJson(Map<String, dynamic> json) {
    return ClinicInfo(
      clinicName: (json['clinicName'] ?? json['clinic_name'] ?? '').toString(),
      registrationNumber:
          (json['registrationNumber'] ?? json['registration_number'] ?? '')
              .toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      about: (json['about'] ?? '').toString(),
    );
  }

  // Factory method for default values
  factory ClinicInfo.defaultValues() {
    return ClinicInfo(
      clinicName: 'Khalil clinique',
      registrationNumber: '254847254',
      email: 'Khalil_clinique@gmail.com',
      phone: '077842584',
      address: 'Ben Aknoun',
      about: 'Description de la clinique',
    );
  }

  ClinicInfo copyWith({
    String? clinicName,
    String? registrationNumber,
    String? email,
    String? phone,
    String? address,
    String? about,
  }) {
    return ClinicInfo(
      clinicName: clinicName ?? this.clinicName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      about: about ?? this.about,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinic_name': clinicName,
      'registration_number': registrationNumber,
      'email': email,
      'phone': phone,
      'address': address,
      'about': about,
    };
  }

  // Convert to controllers if needed for some fields
  Map<String, TextEditingController> toControllers() {
    return {
      'clinicName': TextEditingController(text: clinicName),
      'registrationNumber': TextEditingController(text: registrationNumber),
      'email': TextEditingController(text: email),
      'phone': TextEditingController(text: phone),
      'address': TextEditingController(text: address),
      'about': TextEditingController(text: about),
    };
  }

  @override
  List<Object?> get props => [
    clinicName,
    registrationNumber,
    email,
    phone,
    address,
    about,
  ];
}
