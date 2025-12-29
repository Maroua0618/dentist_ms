import 'package:supabase_flutter/supabase_flutter.dart';
import '../presentation/models/appointment_model.dart';

class AppointmentRemoteDataSource {
  final SupabaseClient client;

  AppointmentRemoteDataSource(this.client);

  // ------------------- GET APPOINTMENTS -------------------
  Future<List<Appointment>> getAppointments() async {
    final response = await client
        .from('appointments')
        .select('*, patients(first_name, last_name), users(first_name, last_name, role)')
        .order('start_datetime');

    return (response as List).map((json) {
      // Patient name
      final patient = json['patients'] as Map<String, dynamic>?;
      final patientName = patient != null
          ? '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}'.trim()
          : 'Unknown Patient';

      // Doctor name (from users table join)
      final doctor = json['users'] as Map<String, dynamic>?;
      final doctorName = doctor != null && doctor['role'] == 'doctor'
          ? '${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'.trim()
          : 'Unknown Doctor';

      return Appointment.fromJson({
        ...json,
        'patientName': patientName,
        'doctorName': doctorName,  // NEW
      });
    }).toList();
  }

  // ------------------- MAP TO DB -------------------
  Map<String, dynamic> _toDbMap(Appointment appointment) {
    final timeParts = appointment.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

    final startDateTime = DateTime(
      appointment.appointmentDate.year,
      appointment.appointmentDate.month,
      appointment.appointmentDate.day,
      hour,
      minute,
    );

    final endDateTime = startDateTime.add(Duration(minutes: appointment.duration));

    return {
      'patient_id': appointment.patientId,
      'doctor_id': appointment.doctorId,  // NOW SET FROM SELECTED DOCTOR
      'start_datetime': startDateTime.toIso8601String(),
      'end_datetime': endDateTime.toIso8601String(),
      'status': appointment.status,
      'diagnosis': appointment.procedure,
      'notes': appointment.notes,
    };
  }

  // ------------------- ADD APPOINTMENT -------------------
  Future<Appointment> addAppointment(Appointment appointment) async {
    // 1. Insert into appointments
    final appointmentMap = _toDbMap(appointment);
    final appointmentResponse = await client
        .from('appointments')
        .insert(appointmentMap)
        .select('*, patients(first_name, last_name), users(first_name, last_name, role)')
        .single();

    final int appointmentId = appointmentResponse['id'] as int;

    // 2. Get treatment_id by name
    final treatmentResponse = await client
        .from('treatments')
        .select('id')
        .eq('name', appointment.procedure)
        .single();

    final int treatmentId = treatmentResponse['id'] as int;

    // 3. Insert into patient_treatments
    await client.from('patient_treatments').insert({
      'patient_id': appointment.patientId,
      'treatment_id': treatmentId,
      'appointment_id': appointmentId,
      'doctor_id': appointment.doctorId,
      'session_date': appointment.appointmentDate.toIso8601String().split('T').first,
      'price': appointment.totalCost,
      'status': appointment.status,
    });

    // 4. Build response with names
    final patient = appointmentResponse['patients'] as Map<String, dynamic>?;
    final patientName = patient != null
        ? '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}'.trim()
        : 'Unknown Patient';

    final doctor = appointmentResponse['users'] as Map<String, dynamic>?;
    final doctorName = doctor != null && doctor['role'] == 'doctor'
        ? '${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'.trim()
        : 'Unknown Doctor';

    return Appointment.fromJson({
      ...appointmentResponse,
      'patientName': patientName,
      'doctorName': doctorName,
    });
  }

  // ------------------- UPDATE APPOINTMENT -------------------
  Future<Appointment> updateAppointment(Appointment appointment) async {
    final dbMap = _toDbMap(appointment);
    final response = await client
        .from('appointments')
        .update(dbMap)
        .eq('id', appointment.id)
        .select('*, patients(first_name, last_name), users(first_name, last_name, role)')
        .single();

    final patient = response['patients'] as Map<String, dynamic>?;
    final patientName = patient != null
        ? '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}'.trim()
        : 'Unknown Patient';

    final doctor = response['users'] as Map<String, dynamic>?;
    final doctorName = doctor != null && doctor['role'] == 'doctor'
        ? '${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? ''}'.trim()
        : 'Unknown Doctor';

    return Appointment.fromJson({
      ...response,
      'patientName': patientName,
      'doctorName': doctorName,
    });
  }

  // ------------------- DELETE -------------------
  Future<void> deleteAppointment(String id) async {
    await client.from('appointments').delete().eq('id', id);
  }
}