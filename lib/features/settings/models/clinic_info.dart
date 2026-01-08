import 'package:flutter/material.dart';

class ClinicInfo {
  final String clinicName;
  final String registrationNumber;
  final String email;
  final String phone;
  final String address;
  final String about;

  ClinicInfo({
    required this.clinicName,
    required this.registrationNumber,
    required this.email,
    required this.phone,
    required this.address,
    required this.about,
  });

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
}