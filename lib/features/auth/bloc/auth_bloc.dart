import 'dart:async';
import 'package:dentist_ms/features/auth/data/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/models/permissions.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthUpdateProfile>(_onUpdateProfile);


    _authSubscription = _authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          permissions:  Permissions.fromRole(user.role),
        ));
      } else {
        emit(state. copyWith(status: AuthStatus. unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await _authRepository.signIn(event.email, event.password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        permissions: Permissions.fromRole(user.role),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e. toString(),
      ));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state. copyWith(status: AuthStatus. loading));

    try {
      await _authRepository.signOut();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        permissions: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository. resetPassword(event.email);
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        permissions: Permissions.fromRole(user.role),
      ));
    } else {
      emit(state. copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        permissions: null,
      ));
    }
  }

  Future<void> _onUpdateProfile(AuthUpdateProfile event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      // You need to add updateUser method to your AuthRepository
      final updatedUser = await _authRepository.updateUser(event.updatedUser);
      
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
        permissions: Permissions.fromRole(updatedUser.role),
      ));
      
      // Show success (optional)
      // You can handle this in the UI instead
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to update profile: $e',
      ));
    }
  }
  
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}