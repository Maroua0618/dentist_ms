import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  AuthResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthUserChanged extends AuthEvent {
  final dynamic user;

  AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}