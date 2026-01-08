import '../models/appointment_model.dart';

// appointment_service.dart - EMPTY / DISABLED
class AppointmentService {
  Map<String, List<Appointment>> getMockAppointments() => {};

  List<Appointment> getAppointmentsForDay(DateTime day) => [];

  bool hasAppointmentsOnDay(DateTime day) => false;

  List<Appointment> getFilteredAppointments(DateTime selectedDay, String viewMode) => [];

  List<Appointment> getAllAppointments() => [];

  List<String> getPatientsList() => [];           // ← no more hardcoded patients

  List<String> getTreatmentTypes() => [];         // ← no more hardcoded treatments
}