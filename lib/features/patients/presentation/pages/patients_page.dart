import 'package:dentist_ms/features/patients/presentation/pages/patient_profile.dart';
import 'package:dentist_ms/features/patients/presentation/pages/patients_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  Map<String, dynamic>? selectedPatient;

  Future<void> selectPatient(Map<String, dynamic> patient) async {
    // Fetch full patient details (including prescriptions, allergies, treatments)
    final id = patient['id'];
    if (id == null) {
      setState(() => selectedPatient = patient);
      return;
    }

    // show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final resp = await Supabase.instance.client
          .from('patients')
          .select(
            '*, prescriptions(*, prescription_items(*), doctor:users(first_name,last_name)), patient_allergies(*, allergy:allergies(*)), patient_treatments(*, treatment:treatments(*), doctor:users(first_name,last_name))',
          )
          .eq('id', id)
          .maybeSingle();

      Navigator.of(context).pop();

      if (resp == null) {
        setState(() => selectedPatient = patient);
        return;
      }

      final Map<String, dynamic> full = {};
      full['id'] = resp['id'];
      full['name'] = '${resp['first_name'] ?? ''} ${resp['last_name'] ?? ''}'
          .trim();
      full['gender'] = resp['gender'];
      full['dob'] = resp['date_of_birth'];
      full['phone'] = resp['phone1'];
      full['email'] = resp['email'];
      full['address'] = resp['address'];
      full['status'] = resp['status'];

      final List<dynamic> treatments =
          resp['patient_treatments'] as List<dynamic>? ?? [];
      full['stats'] = {
        'visits': treatments.length,
        'lastVisit': treatments.isNotEmpty
            ? treatments.last['session_date']
            : null,
        'dentist': treatments.isNotEmpty && treatments.last['doctor'] != null
            ? '${treatments.last['doctor']['first_name'] ?? ''} ${treatments.last['doctor']['last_name'] ?? ''}'
                  .trim()
            : null,
      };

      full['dentalHistory'] = treatments.map((t) {
        final tr = t as Map<String, dynamic>;
        final doctor = tr['doctor'];
        return {
          'id': tr['id'],
          'title': tr['treatment'] != null
              ? tr['treatment']['name']
              : 'Procedure',
          'date': tr['session_date'],
          'desc': tr['notes'],
          'doctor': doctor != null
              ? '${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'
                    .trim()
              : 'Unknown',
        };
      }).toList();

      final List<dynamic> prescriptions =
          resp['prescriptions'] as List<dynamic>? ?? [];
      full['prescriptions'] = prescriptions.map((p) {
        final pr = p as Map<String, dynamic>;
        final doctor = pr['doctor'];
        return {
          'id': pr['id'],
          'title':
              (pr['prescription_items'] as List<dynamic>?)
                  ?.map((i) => i['medication_name'])
                  .where((e) => e != null)
                  .join(', ') ??
              'Prescription',
          'date': pr['issued_at'],
          'desc': pr['notes'],
          'doctor': doctor != null
              ? '${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'
                    .trim()
              : 'Unknown',
          'items': pr['prescription_items'] ?? [],
        };
      }).toList();

      final List<dynamic> pas =
          resp['patient_allergies'] as List<dynamic>? ?? [];
      full['allergies'] = pas.map((pa) {
        final map = pa as Map<String, dynamic>;
        final allergy = map['allergy'];
        final notes = map['notes']?.toString() ?? '';
        String severity = '';
        String reaction = '';
        if (notes.isNotEmpty) {
          final parts = notes.split('\n');
          if (parts.isNotEmpty)
            severity = parts.first.replaceFirst('Severity: ', '');
          if (parts.length > 1)
            reaction = parts
                .sublist(1)
                .join('\n')
                .replaceFirst('Reaction: ', '');
        }
        return {
          'id': map['id'],
          'title': allergy != null ? allergy['name'] : '',
          'severity': severity,
          'desc': reaction,
        };
      }).toList();

      setState(() => selectedPatient = full);
    } catch (e) {
      Navigator.of(context).pop();
      setState(() => selectedPatient = patient);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load patient details: $e')),
      );
    }
  }

  void backToTable() {
    setState(() {
      selectedPatient = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedPatient == null
        ? PatientsDashboard(onPatientSelected: selectPatient)
        : PatientDetailScreen(patient: selectedPatient!, onBack: backToTable);
  }
}
