import 'package:dentist_ms/core/constants/app_routes.dart';
import 'package:dentist_ms/core/theme/app_theme.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_state.dart';
import 'package:dentist_ms/features/auth/presentation/pages/login_page.dart';
import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_event.dart';
import 'package:dentist_ms/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DentistApp extends StatelessWidget {
  const DentistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Système de gestion des dentistes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

/// AuthWrapper - Determines initial screen based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Load patients when authenticated
        if (state.status == AuthStatus.authenticated) {
          context.read<PatientBloc>().add(LoadPatients());
        }
      },
      builder: (context, state) {
        // Loading state
        if (state.status == AuthStatus.initial ||
            state.status == AuthStatus.loading) {
          return const _LoadingScreen();
        }

        // Authenticated - navigate to dashboard
        if (state. status == AuthStatus.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboardShell,
              (route) => false,
            );
          });
          return const _LoadingScreen();
        }

        // Unauthenticated - show login
        return const LoginPage();
      },
    );
  }
}

/// Loading screen
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F7EFF), Color(0xFF9D6CFF)],
                ),
                borderRadius: BorderRadius. circular(20),
              ),
              child:  const Icon(
                Icons.local_hospital,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F7EFF)),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height:  24),
            Text(
              "Khelil's Dental Center",
              style: TextStyle(
                color: Colors.white. withOpacity(0.9),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}