import 'package:dentist_ms/features/dashboard/models/patients_chart_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';

class PatientRemoteDataSource {
  final SupabaseClient _client;

  // Uses the singleton Supabase instance by default
  PatientRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch all patients ordered by creation date
  Future<List<Patient>> getPatients() async {
    try {
      final response = await _client
          .from('patients')
          .select()
          .order('created_at', ascending: false);

      // Supabase returns a List<dynamic>, we map it to List<Patient>
      return (response as List).map((json) => Patient.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load patients: $e');
    }
  }

  /// Add a new patient
  Future<Patient> addPatient(Patient patient) async {
    try {
      final response = await _client
          .from('patients')
          .insert(patient.toJson())
          .select()
          .single(); // .single() returns the created object

      return Patient.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add patient: $e');
    }
  }

  /// Update an existing patient
  Future<Patient> updatePatient(Patient patient) async {
    if (patient.id == null)
      throw Exception('Patient ID is required for update');

    try {
      final response = await _client
          .from('patients')
          .update(patient.toJson())
          .eq('id', patient.id!)
          .select()
          .single();

      return Patient.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  /// Delete a patient
  Future<void> deletePatient(int id) async {
    try {
      await _client.from('patients').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete patient: $e');
    }
  }

  Future<PatientsChartData> getPatientsChartData({required int year}) async {
    try {
      print('\n=== FETCHING PATIENTS DATA FOR YEAR $year ===');

      final patientsResponse = await _client
          .from('patients')
          .select('id, created_at')
          .order('created_at', ascending: true);

      final allPatients = patientsResponse as List;
      print('Total patients in database: ${allPatients.length}');

      Map<int, int> newPatientsByMonth = {};
      int patientsBeforeYear = 0;

      for (var patient in allPatients) {
        if (patient['created_at'] != null) {
          try {
            final createdAt = DateTime.parse(patient['created_at'].toString());

            if (createdAt.year < year) {
              patientsBeforeYear++;
            } else if (createdAt.year == year) {
              final month = createdAt.month;
              newPatientsByMonth[month] = (newPatientsByMonth[month] ?? 0) + 1;
            }
          } catch (e) {
            print(
              'Error parsing patient created_at: ${patient['created_at']}, error: $e',
            );
          }
        }
      }

      print('Patients registered before $year: $patientsBeforeYear');
      print('New patients by month in $year: $newPatientsByMonth');

      List<MonthlyPatientCount> monthlyData = [];
      int cumulativeCount = patientsBeforeYear;
      int maxPatientCount = cumulativeCount;

      final monthNames = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      for (int month = 1; month <= 12; month++) {
        final newPatients = newPatientsByMonth[month] ?? 0;
        cumulativeCount += newPatients;

        if (cumulativeCount > maxPatientCount) {
          maxPatientCount = cumulativeCount;
        }

        print(
          '${monthNames[month].padRight(4)}: New=${newPatients.toString().padLeft(3)}, Cumulative=$cumulativeCount',
        );

        monthlyData.add(
          MonthlyPatientCount(
            month: month,
            year: year,
            cumulativeCount: cumulativeCount,
            newPatients: newPatients,
          ),
        );
      }

      print('\n=== SUMMARY ===');
      print('Max cumulative patient count: $maxPatientCount');

      return PatientsChartData(
        monthlyData: monthlyData,
        maxPatientCount: maxPatientCount,
      );
    } catch (e) {
      print('ERROR in getPatientsChartData: $e');
      throw Exception('Failed to load patients chart data: $e');
    }
  }
}
