import 'package:dentist_ms/features/appointments/presentation/pages/appointments_page.dart';
import 'package:dentist_ms/features/billing/presentation/pages/billings_page.dart';
import 'package:dentist_ms/features/patients/presentation/pages/patients_page.dart';
import 'package:dentist_ms/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dentist_ms/features/settings/presentation/pages/settings_page.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_state.dart';
import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_state.dart';
import 'package:dentist_ms/features/appointments/bloc/appointment_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_navbar.dart';

class AdaptiveScaffold extends StatefulWidget {
  final int initialIndex;

  const AdaptiveScaffold({super.key, this.initialIndex = 0});

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  late int _selectedIndex;
  int _patientsCount = 0;
  int _appointmentsCount = 0;
  int _invoiceCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const PatientsPage();
      case 2:
        return const AppointmentPage();
      case 3:
        return const BillingsPageWrapper();
      case 4:
        return const SettingsPage();
      default:
        return const Center(child: Text('Page inconnue'));
    }
  }

  int _getTodayAppointmentsCount(
    AppointmentLoadSuccess state,
    AuthState authState,
  ) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

    var todayAppointments = state.appointments
        .where(
          (appointment) =>
              appointment.appointmentDate.isAfter(todayStart) &&
              appointment.appointmentDate.isBefore(todayEnd),
        )
        .toList();

    // If user is a doctor, show only their appointments
    if (authState.isDoctor && authState.user != null) {
      todayAppointments = todayAppointments
          .where((appointment) => appointment.doctorId == authState.user!.id)
          .toList();
    }
    // If receptionist or admin, show all appointments

    return todayAppointments.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<PatientBloc, PatientState>(
            listener: (context, state) {
              if (state is PatientsLoadSuccess) {
                setState(() => _patientsCount = state.patients.length);
              }
            },
          ),
          BlocListener<AppointmentBloc, AppointmentState>(
            listener: (context, state) {
              if (state is AppointmentLoadSuccess) {
                final authState = context.read<AuthBloc>().state;
                setState(
                  () => _appointmentsCount = _getTodayAppointmentsCount(
                    state,
                    authState,
                  ),
                );
              }
            },
          ),
          BlocListener<InvoiceBloc, InvoiceState>(
            listener: (context, state) {
              if (state is InvoicesLoadSuccess) {
                setState(() => _invoiceCount = state.invoices.length);
              }
            },
          ),
        ],
        child: Row(
          children: [
            AppNavbar(
              selectedIndex: _selectedIndex,
              onItemSelected: (i) => setState(() => _selectedIndex = i),
              appointmentsN: _appointmentsCount,
              billingsN: _invoiceCount,
              patientsN: _patientsCount,
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
