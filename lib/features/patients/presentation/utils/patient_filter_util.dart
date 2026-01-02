import 'package:dentist_ms/features/patients/models/patient.dart';
import 'package:dentist_ms/features/patients/models/patient_filter.dart';

class PatientFilterUtil {
  static List<Patient> applyFilters(
    List<Patient> patients,
    PatientFilter filter,
  ) {
    var filtered = patients;

    if (filter.status != null) {
      filtered = filtered
          .where(
            (p) =>
                (p.status ?? '').toLowerCase() == filter.status!.toLowerCase(),
          )
          .toList();
    }

    if (filter.gender != null) {
      filtered = filtered
          .where(
            (p) =>
                (p.gender ?? '').toLowerCase() == filter.gender!.toLowerCase(),
          )
          .toList();
    }

    if (filter.bloodType != null) {
      filtered = filtered
          .where((p) => (p.bloodType ?? '') == filter.bloodType)
          .toList();
    }

    if (filter.dateFrom != null) {
      filtered = filtered
          .where(
            (p) =>
                p.createdAt != null && p.createdAt!.isAfter(filter.dateFrom!),
          )
          .toList();
    }

    if (filter.dateTo != null) {
      filtered = filtered
          .where(
            (p) => p.createdAt != null && p.createdAt!.isBefore(filter.dateTo!),
          )
          .toList();
    }

    return filtered;
  }
}
