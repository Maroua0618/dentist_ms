import 'package:dentist_ms/features/patients/models/patient.dart';

/// Filters patients by query matching name, id, email, or phone (case-insensitive).
List<Patient> filterPatients(String query, List<Patient> patients) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return patients;

  return patients.where((p) {
    final first = p.firstName?.toLowerCase() ?? '';
    final last = p.lastName?.toLowerCase() ?? '';
    final full = ('$first ${last}').trim();
    final idStr = p.id != null ? 'p${p.id}'.toLowerCase() : '';
    final email = p.email?.toLowerCase() ?? '';
    final phone = p.phone1?.toLowerCase() ?? '';

    return full.contains(q) ||
        idStr.contains(q) ||
        email.contains(q) ||
        phone.contains(q);
  }).toList();
}
