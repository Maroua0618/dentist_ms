import '../presentation/models/appointment_model.dart';
import '../data/appointment_remote.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments();
  Future<Appointment> addAppointment(Appointment appointment);
  Future<Appointment> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
}

class SupabaseAppointmentRepository implements AppointmentRepository {
  final AppointmentRemoteDataSource remote;

  SupabaseAppointmentRepository({required this.remote});

  @override
  Future<List<Appointment>> getAppointments() => remote.getAppointments();

  @override
  Future<Appointment> addAppointment(Appointment appointment) => remote.addAppointment(appointment);

  @override
  Future<Appointment> updateAppointment(Appointment appointment) => remote.updateAppointment(appointment);

  @override
  Future<void> deleteAppointment(String id) => remote.deleteAppointment(id);
}
