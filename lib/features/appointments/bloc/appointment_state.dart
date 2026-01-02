part of 'appointment_bloc.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoadSuccess extends AppointmentState {
  final List<Appointment> appointments;
  const AppointmentLoadSuccess(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class AppointmentOperationFailure extends AppointmentState {
  final String error;
  const AppointmentOperationFailure(this.error);

  @override
  List<Object?> get props => [error];
}
