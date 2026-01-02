import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/appointment_repository.dart';
import '../presentation/models/appointment_model.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository repository;

  AppointmentBloc({required this.repository}) : super(AppointmentInitial()) {
    on<LoadAppointments>(_onLoadAppointments);
    on<AddAppointment>(_onAddAppointment);
    on<UpdateAppointment>(_onUpdateAppointment);
    on<DeleteAppointment>(_onDeleteAppointment);
  }

  Future<void> _onLoadAppointments(
      LoadAppointments event, Emitter<AppointmentState> emit) async {
    emit(AppointmentLoading());
    try {
      final appointments = await repository.getAppointments();
      emit(AppointmentLoadSuccess(appointments));
    } catch (e) {
      emit(AppointmentOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddAppointment(
      AddAppointment event, Emitter<AppointmentState> emit) async {
    try {
      await repository.addAppointment(event.appointment);
      add(LoadAppointments());
    } catch (e) {
      emit(AppointmentOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateAppointment(
      UpdateAppointment event, Emitter<AppointmentState> emit) async {
    try {
      await repository.updateAppointment(event.appointment);
      add(LoadAppointments());
    } catch (e) {
      emit(AppointmentOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteAppointment(
      DeleteAppointment event, Emitter<AppointmentState> emit) async {
    try {
      await repository.deleteAppointment(event.id);
      add(LoadAppointments());
    } catch (e) {
      emit(AppointmentOperationFailure(e.toString()));
    }
  }
}
