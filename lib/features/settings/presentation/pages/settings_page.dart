import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:dentist_ms/features/settings/bloc/clinic_info_cubit.dart';
import 'package:dentist_ms/features/settings/bloc/clinic_info_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/profil_widget.dart';
import '../widgets/clinic_widget.dart';
import '../widgets/security_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ClinicInfoStatus? _lastClinicStatus;

  final ClinicControllers clinicControllers = ClinicControllers();
  final ProfilControllers profilControllers = ProfilControllers();
  final SecurityControllers securityControllers = SecurityControllers();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 1,
    ); // Start at Profile
  }

  @override
  void dispose() {
    _tabController.dispose();
    clinicControllers.dispose();
    profilControllers.dispose();
    securityControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: height * 0.026,
            horizontal: width * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Paramètres",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Gérer les préférences et les configurations",
                          style: AppTextStyles.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.03),

              // TabBar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black87,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Clinique'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Profil'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Sécurité'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.02),

              // TabBarView
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Clinic Info Tab
                      Builder(
                        builder: (context) {
                          final clinicCubit = context.read<ClinicInfoCubit?>();

                          if (clinicCubit == null) {
                            return const Center(
                              child: Text(
                                'Veuillez redémarrer l\'application',
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }

                          return BlocListener<ClinicInfoCubit, ClinicInfoState>(
                            bloc: clinicCubit,
                            listenWhen: (previous, current) =>
                                previous.status != current.status ||
                                previous.clinicInfo != current.clinicInfo,
                            listener: (context, state) {
                              if (state.status == ClinicInfoStatus.loaded &&
                                  _lastClinicStatus ==
                                      ClinicInfoStatus.saving) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Informations de la clinique sauvegardées',
                                    ),
                                  ),
                                );
                              } else if (state.status ==
                                  ClinicInfoStatus.error) {
                                final message =
                                    state.errorMessage ??
                                    "Impossible d'enregistrer les informations";
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              }

                              _lastClinicStatus = state.status;
                            },
                            child:
                                BlocBuilder<ClinicInfoCubit, ClinicInfoState>(
                                  bloc: clinicCubit,
                                  builder: (context, clinicState) {
                                    return SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: clinic(
                                        context,
                                        width,
                                        height,
                                        clinicControllers,
                                        clinicState.clinicInfo,
                                        clinicState,
                                      ),
                                    );
                                  },
                                ),
                          );
                        },
                      ),

                      // Profile Tab
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: profil(
                          context,
                          width,
                          height,
                          profilControllers,
                        ),
                      ),

                      // Security Tab
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: security(
                          context,
                          width,
                          height,
                          securityControllers,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
