import 'dart:typed_data';
import 'package:dentist_ms/features/patients/bloc/patient_event.dart';
import 'package:dentist_ms/features/patients/presentation/dialogs/delete_patient_dialog.dart';
import 'package:dentist_ms/features/patients/presentation/dialogs/edit_profile_dialoge.dart';
import 'package:dentist_ms/features/patients/presentation/utils/patient_image_service.dart';
import 'package:dentist_ms/features/patients/presentation/widgets/contact_information_card.dart';
import 'package:dentist_ms/features/patients/presentation/widgets/medical_records_tab.dart';
import 'package:dentist_ms/features/patients/presentation/widgets/patient_header.dart';
import 'package:dentist_ms/features/patients/presentation/widgets/patient_stats_cards.dart';
import 'package:dentist_ms/features/patients/presentation/widgets/quick_actions_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_state.dart';
import 'package:dentist_ms/features/appointments/bloc/appointment_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_state.dart';
import 'package:dentist_ms/core/models/app_user.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({
    super.key,
    required this.patient,
    required this.onBack,
  });

  final Map<String, dynamic> patient;
  final VoidCallback onBack;

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _awaitingSave = false;
  bool _awaitingDelete = false;
  Uint8List? _cachedProfileImage;
  late PatientImageService _imageService;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with correct length based on user role
    final authState = context.read<AuthBloc>().state;
    final userRole = authState.user?.role ?? UserRole.receptionist;
    final tabLength = userRole == UserRole.receptionist ? 2 : 4;
    _tabController = TabController(length: tabLength, vsync: this);
    _imageService = PatientImageService();
    try {
      context.read<AppointmentBloc>().add(LoadAppointments());
    } catch (_) {}
    _loadPatientProfileImage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientProfileImage() async {
    final imageUrl = widget.patient['profileImageUrl'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) return;

    try {
      final imageBytes = await _imageService.loadProfileImage(imageUrl);
      if (mounted) {
        setState(() {
          _cachedProfileImage = imageBytes;
        });
      }
    } catch (e) {
      print('Error loading patient profile image: $e');
    }
  }

  Future<void> _handleImagePick() async {
    if (_isUploadingImage) return;

    final imageFile = await _imageService.pickImageFromGallery();
    if (imageFile == null) return;

    if (!mounted) return;

    setState(() => _isUploadingImage = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📤 Téléchargement de la photo...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );

    try {
      final patientId = widget.patient['id'] as int?;
      if (patientId == null) {
        throw Exception('Patient ID is required');
      }

      final imagePath = await _imageService.uploadProfileImage(
        imageFile,
        patientId,
      );

      if (imagePath != null && mounted) {
        // Update local state
        widget.patient['profileImageUrl'] = imagePath;

        // Reload the image
        await _loadPatientProfileImage();

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Photo de profil mise à jour avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Reload patients list to reflect changes
        context.read<PatientBloc>().add(LoadPatients());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _handleQuickAction(String actionName) {
    if (actionName == 'Edit Profile') {
      showEditProfileDialog(
        context: context,
        patient: widget.patient,
        onSave: () {
          setState(() => _awaitingSave = true);
        },
      );
      return;
    }

    if (actionName == 'Delete Patient') {
      showDeletePatientDialog(
        context: context,
        patient: widget.patient,
        onDelete: () {
          setState(() => _awaitingDelete = true);
          widget.onBack();
        },
      );
      return;
    }

    if (actionName == 'Add Appointment' || actionName == 'Add Medical Record') {
      // Handle these actions (import required dialogs)
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.patient['name'] ?? 'Patient inconnu';
    final String gender = widget.patient['gender'] ?? 'N/A';
    final String age = widget.patient['age']?.toString() ?? '0';
    final String dob = widget.patient['dob'] ?? 'N/A';
    final String patientId = widget.patient['id']?.toString() ?? 'N/A';

    final Map<String, dynamic> stats = widget.patient['stats'] ?? {};
    final String totalVisits = stats['visits']?.toString() ?? '0';
    final String lastVisit = stats['lastVisit'] ?? 'Jamais';
    final String primaryDentist = stats['dentist'] ?? 'Non assigné';

    final String phone = widget.patient['phone'] ?? 'Pas de téléphone';
    final String email = widget.patient['email'] ?? 'Pas d\'email';
    final String address = widget.patient['address'] ?? 'Pas d\'adresse';

    // Get current user role for access control
    final authState = context.watch<AuthBloc>().state;
    final userRole = authState.user?.role ?? UserRole.receptionist;

    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientsLoadSuccess && _awaitingSave) {
          setState(() => _awaitingSave = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Profil sauvegardé')));
        } else if (state is PatientsOperationFailure && _awaitingSave) {
          setState(() => _awaitingSave = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Échec de la sauvegarde :  ${state.message}'),
            ),
          );
        }

        if (state is PatientsLoadSuccess && _awaitingDelete) {
          setState(() => _awaitingDelete = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Patient supprimé')));
        } else if (state is PatientsOperationFailure && _awaitingDelete) {
          setState(() => _awaitingDelete = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Échec de la suppression :  ${state.message}'),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double horizontalPadding = constraints.maxWidth < 1366
                  ? 24
                  : (constraints.maxWidth < 1920 ? 32 : 48);
              double verticalPadding = constraints.maxWidth < 1366 ? 24 : 32;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PatientHeader(
                          name: name,
                          gender: gender,
                          age: age,
                          dob: dob,
                          patientId: patientId,
                          profileImage: _cachedProfileImage,
                          onBack: widget.onBack,
                          onImagePick: _isUploadingImage
                              ? () {}
                              : _handleImagePick,
                        ),
                        SizedBox(height: constraints.maxWidth < 1366 ? 24 : 32),
                        PatientStatsCards(
                          totalVisits: totalVisits,
                          lastVisit: lastVisit,
                          primaryDentist: primaryDentist,
                          constraints: constraints,
                        ),
                        SizedBox(height: constraints.maxWidth < 1366 ? 24 : 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth < 1366
                                  ? constraints.maxWidth * 0.32
                                  : constraints.maxWidth * 0.35,
                              child: Column(
                                children: [
                                  ContactInformationCard(
                                    phone: phone,
                                    email: email,
                                    address: address,
                                  ),
                                  SizedBox(
                                    height: constraints.maxWidth < 1366
                                        ? 20
                                        : 24,
                                  ),
                                  QuickActionsCard(
                                    onActionTap: _handleQuickAction,
                                    userRole: userRole,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth < 1366 ? 20 : 24,
                            ),
                            Expanded(
                              child: MedicalRecordsTabs(
                                tabController: _tabController,
                                patient: widget.patient,
                                userRole: userRole,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
