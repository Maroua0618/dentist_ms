import 'package:equatable/equatable.dart';
import 'package:dentist_ms/core/models/app_user.dart';
import 'package:dentist_ms/core/models/permissions.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;
  final Permissions? permissions;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.permissions,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isDoctor => user?.isDoctor ?? false;
  bool get isReceptionist => user?.isReceptionist ?? false;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    Permissions? permissions,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      permissions: permissions ?? this.permissions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, permissions, errorMessage];
}
