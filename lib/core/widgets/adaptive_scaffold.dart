import 'package:dentist_ms/features/appointments/presentation/pages/appointments_page.dart';
import 'package:dentist_ms/features/billing/presentation/pages/billings_page.dart';
import 'package:dentist_ms/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dentist_ms/features/patients/presentation/pages/patients_page.dart';
import 'package:dentist_ms/features/settings/presentation/pages/settings_page.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          BlocBuilder<InvoiceBloc, InvoiceState>(
            builder: (context, invoiceState) {
              int invoiceCount = 0;
              if (invoiceState is InvoicesLoadSuccess) {
                invoiceCount = invoiceState.invoices.length;
              }

              return AppNavbar(
                selectedIndex: _selectedIndex,
                onItemSelected: (i) => setState(() => _selectedIndex = i),
                appointmentsN: 20,
                billingsN: invoiceCount,
              );
            },
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}
