import 'package:dentist_ms/app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_event.dart';
import 'package:dentist_ms/features/auth/data/auth_repository.dart';
import 'package:dentist_ms/features/appointments/bloc/appointment_bloc.dart';
import 'package:dentist_ms/features/appointments/data/appointment_remote.dart';
import 'package:dentist_ms/features/appointments/repositories/appointment_repository.dart';
import 'package:dentist_ms/features/settings/bloc/clinic_info_cubit.dart';
import 'package:dentist_ms/features/settings/data/clinic_info_repository.dart';
import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/data/patient_remote.dart';
import 'package:dentist_ms/features/patients/repositories/patient_repository.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_bloc.dart';
import 'package:dentist_ms/features/billing/bloc/invoice_event.dart';
import 'package:dentist_ms/features/billing/data/invoice_remote.dart';
import 'package:dentist_ms/features/billing/repositories/invoice_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  // Load environment variables
  await dotenv.load();
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing Supabase: $e');
  }

  final supabase = Supabase.instance.client;

  // Initialize repositories
  final authRepository = AuthRepository(supabase);
  final patientRemoteDataSource = PatientRemoteDataSource();
  final patientRepository = SupabasePatientRepository(
    remote: patientRemoteDataSource,
  );
  final appointmentRemoteDataSource = AppointmentRemoteDataSource(
    Supabase.instance.client,
  );
  final appointmentRepository = SupabaseAppointmentRepository(
    remote: appointmentRemoteDataSource,
  );
  final invoiceRemoteDataSource = InvoiceRemoteDataSource();
  final invoiceRepository = SupabaseInvoiceRepository(
    remote: invoiceRemoteDataSource,
  );
  final clinicInfoRepository = SupabaseClinicInfoRepository(supabase);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => authRepository),
        RepositoryProvider<SupabasePatientRepository>(
          create: (_) => patientRepository,
        ),
        RepositoryProvider<ClinicInfoRepository>(
          create: (_) => clinicInfoRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(context.read<AuthRepository>())..add(AuthStarted()),
          ),
          // Feature BLoCs
          BlocProvider<PatientBloc>(
            create: (context) => PatientBloc(
              repository: context.read<SupabasePatientRepository>(),
            ),
          ),
          BlocProvider<AppointmentBloc>(
            create: (context) =>
                AppointmentBloc(repository: appointmentRepository),
          ),
          BlocProvider<InvoiceBloc>(
            create: (context) =>
                InvoiceBloc(repository: invoiceRepository)..add(LoadInvoices()),
          ),
          BlocProvider<ClinicInfoCubit>(
            create: (context) =>
                ClinicInfoCubit(context.read<ClinicInfoRepository>())
                  ..loadClinicInfo(),
          ),
          // Add other Blocs here as your application grows
        ],
        child: const DentistApp(),
      ),
    ),
  );
}
