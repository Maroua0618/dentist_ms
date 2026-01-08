import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_event.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';

void showEditProfileDialog({
  required BuildContext context,
  required Map<String, dynamic> patient,
  required VoidCallback onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: patient['name'] ?? '');
  final phoneController = TextEditingController(text: patient['phone'] ?? '');
  final emailController = TextEditingController(text: patient['email'] ?? '');
  final addressController = TextEditingController(text: patient['address'] ?? '');
  final dobController = TextEditingController(text: patient['dob'] ?? '');
  
  final List<String> genders = ['Femme', 'Homme', 'Autre'];
  final rawGender = (patient['gender'] ?? '').toString();
  String genderValue = genders.firstWhere(
    (g) => g.toLowerCase() == rawGender.toLowerCase(),
    orElse: () => genders.first,
  );

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text(
            'Modifier le profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child:  Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Le nom est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: genderValue,
                            decoration: const InputDecoration(
                              labelText: 'Sexe',
                            ),
                            items:  const [
                              DropdownMenuItem(
                                value: 'Femme',
                                child: Text('Femme'),
                              ),
                              DropdownMenuItem(
                                value:  'Homme',
                                child: Text('Homme'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => genderValue = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller:  dobController,
                            decoration: InputDecoration(
                              labelText: 'Date de naissance (AAAA-MM-JJ)',
                              hintText: 'AAAA-MM-JJ ou sélectionner du calendrier',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  final today = DateTime.now();
                                  final initial = DateTime. tryParse(dobController.text) ??
                                      DateTime(today.year - 25);
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate:  initial,
                                    firstDate: DateTime(1900),
                                    lastDate: today,
                                  );
                                  if (picked != null) {
                                    dobController.text = picked.toIso8601String().split('T').first;
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La date de naissance est requise';
                              }
                              final v = value.trim();
                              final ok = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v) &&
                                  DateTime.tryParse(v) != null;
                              if (!ok) {
                                return 'Entrez une date valide au format AAAA-MM-JJ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller:  phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(v. trim())) {
                          return 'Entrez un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height:  12),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed:  () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?. validate() ?? false) {
                  final name = nameController.text.trim();
                  final dobText = dobController.text.trim();
                  DateTime? parsedDob;
                  if (dobText.isNotEmpty && DateTime.tryParse(dobText) != null) {
                    parsedDob = DateTime. tryParse(dobText)!;
                  }

                  patient['name'] = name;
                  patient['gender'] = genderValue;
                  patient['phone'] = phoneController.text.trim();
                  patient['email'] = emailController.text.trim();
                  patient['address'] = addressController.text.trim();
                  
                  if (parsedDob != null) {
                    patient['dob'] = parsedDob.toIso8601String().split('T').first;
                    final today = DateTime.now();
                    int age = today.year - parsedDob.year;
                    if (today.month < parsedDob.month ||
                        (today.month == parsedDob.month && today.day < parsedDob. day)) {
                      age--;
                    }
                    patient['age'] = age;
                  }

                  final idValue = patient['id'];
                  int? idInt;
                  if (idValue != null) {
                    if (idValue is int) {
                      idInt = idValue;
                    } else {
                      idInt = int.tryParse(idValue. toString());
                    }
                  }

                  final parts = name.split(RegExp('\\s+'));
                  final firstName = parts.isNotEmpty ? parts. first : '';
                  final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

                  final updatedPatient = Patient(
                    id: idInt,
                    firstName: firstName,
                    lastName:  lastName,
                    gender: genderValue,
                    dateOfBirth: parsedDob,
                    phone1: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    address: addressController. text.trim(),
                    status: patient['status']?.toString() ?? 'active',
                    profileImageUrl: patient['profileImageUrl'] as String?,
                  );

                  context.read<PatientBloc>().add(UpdatePatient(updatedPatient));
                  onSave();

                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enregistrement du profil.. .')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
              ),
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      );
    },
  );
}