import 'dart:async';
import 'dart:typed_data';
import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:dentist_ms/features/patients/models/patient_filter.dart';
import 'package:dentist_ms/features/patients/presentation/utils/patient_export.dart';
import 'package:dentist_ms/features/patients/presentation/utils/patient_filter_util.dart';
import 'package:dentist_ms/features/patients/presentation/widgets/filter_dialog.dart';
import 'package:dentist_ms/features/patients/presentation/widgets/patient_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_event.dart';
import 'package:dentist_ms/features/patients/bloc/patient_state.dart';
import 'package:dentist_ms/features/patients/models/patient.dart';
import 'package:dentist_ms/features/patients/presentation/utils/patient_search.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientsDashboard extends StatefulWidget {
  const PatientsDashboard({super.key, required this.onPatientSelected});
  final Function(Map<String, dynamic>) onPatientSelected;

  @override
  State<PatientsDashboard> createState() => _PatientsDashboardState();
}

class _PatientsDashboardState extends State<PatientsDashboard> {
  var totalPatients = 0;
  var activePatients = 0;
  var newPatients = 0;
  var balance = 0;
  String _statusValue = 'active';
  String _bloodType = 'O+';
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String _genderValue = 'Female';
  final TextEditingController _insuranceProviderController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;

  PatientFilter _currentFilter = const PatientFilter();

  // Cache for patient profile images
  final Map<String, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    // Load patients from repository via bloc
    // Make sure a PatientBloc is provided above this widget.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientBloc>().add(LoadPatients());
    });
  }

  Future<Uint8List?> _loadPatientImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;

    // Check cache first
    if (_imageCache.containsKey(imagePath)) {
      return _imageCache[imagePath];
    }

    try {
      final response = await Supabase.instance.client.storage
          .from('patients-photos')
          .download(imagePath);

      _imageCache[imagePath] = response;
      return response;
    } catch (e) {
      print('Error loading patient image: $e');
      return null;
    }
  }

  void _showFilterDialog() async {
    final filter = await showDialog<PatientFilter>(
      context: context,
      builder: (context) => PatientFilterDialog(initialFilter: _currentFilter),
    );

    if (filter != null) {
      setState(() => _currentFilter = filter);
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => PatientExportDialog(
        onExportCSV: _exportToCSV,
        onExportExcel: _exportToExcel,
        onExportPDF: _exportToPDF,
      ),
    );
  }

  Future<void> _exportToCSV() async {
    try {
      final state = context.read<PatientBloc>().state;
      if (state is! PatientsLoadSuccess) return;

      final patients = PatientFilterUtil.applyFilters(
        filterPatients(_searchQuery, state.patients),
        _currentFilter,
      );

      final filePath = await PatientExportService.exportToCSV(patients);

      if (mounted) {
        _showSuccessSnackBar(filePath, 'CSV');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur d\'exportation CSV:  $e');
      }
    }
  }

  Future<void> _exportToExcel() async {
    try {
      final state = context.read<PatientBloc>().state;
      if (state is! PatientsLoadSuccess) return;

      final patients = PatientFilterUtil.applyFilters(
        filterPatients(_searchQuery, state.patients),
        _currentFilter,
      );

      final filePath = await PatientExportService.exportToExcel(patients);

      if (mounted) {
        _showSuccessSnackBar(filePath, 'Excel');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur d\'exportation Excel: $e');
      }
    }
  }

  Future<void> _exportToPDF() async {
    try {
      final state = context.read<PatientBloc>().state;
      if (state is! PatientsLoadSuccess) return;

      final patients = PatientFilterUtil.applyFilters(
        filterPatients(_searchQuery, state.patients),
        _currentFilter,
      );

      final filePath = await PatientExportService.exportToPDF(patients);

      if (mounted) {
        _showSuccessSnackBar(filePath, 'PDF');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur d\'exportation PDF: $e');
      }
    }
  }

  void _showSuccessSnackBar(String filePath, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('$format exporté avec succès')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ouvrir',
          textColor: Colors.white,
          onPressed: () async {
            await PatientExportService.openFileInExplorer(filePath);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientsLoadSuccess) {
          // Update summary stats from loaded patients
          final patients = state.patients;
          final total = patients.length;
          print(total);
          final active = patients
              .where((p) => (p.status ?? '').toLowerCase() == 'active')
              .length;
          final newCount = patients.where((p) {
            if (p.createdAt == null) return false;
            return p.createdAt!.isAfter(
              DateTime.now().subtract(const Duration(days: 30)),
            );
          }).length;

          // We don't have a balance field in the Patient model here;
          // leave balance as-is or set to 0 if you prefer.
          setState(() {
            totalPatients = total;
            activePatients = active;
            newPatients = newCount;
          });

          // keep balance unchanged
        } else if (state is PatientsOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('L\'opération a échoué : ${state.message}')),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header Section
                Row(
                  children: [
                    // Text Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gestion des patients",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Gérer et consulter tous les dossiers des patients",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Add Patient Button
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          // Small screen - button goes below
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            child: Container(
                              decoration: AppColors.selectedPage,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  _showAddPatientDialog();
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      "Ajouter un patient",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Normal screen
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                _showAddPatientDialog();
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.add, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    "Add New Patient",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      'Total des patients',
                      totalPatients,
                      "assets/icons/person.svg",
                      AppColors.cardBlue,
                    ),
                    _buildStatCard(
                      'Patients actifs',
                      activePatients,
                      "assets/icons/pfp.svg",
                      AppColors.cardGreen,
                    ),
                    _buildStatCard(
                      'Nouveau ce mois',
                      newPatients,
                      "assets/icons/plus.svg",
                      AppColors.cardPurple,
                    ),
                    _buildStatCard(
                      'Solde en attente',
                      balance,
                      "assets/icons/dollar.svg",
                      AppColors.cardOrange,
                      isMoney: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search and Filter Row
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment
                        .stretch, // This stretches the buttons vertically
                    children: [
                      // Search Field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(
                            fontSize: 14,
                          ), // Base text size
                          decoration: InputDecoration(
                            hintText:
                                'Rechercher des patients par nom, ID ou email...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[500],
                              size: 22,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            // Using padding to define the natural height rather than fixed pixels
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            // Debounce to avoid excessive rebuilds
                            if (_searchDebounce?.isActive ?? false) {
                              _searchDebounce!.cancel();
                            }
                            _searchDebounce = Timer(
                              const Duration(milliseconds: 250),
                              () {
                                setState(() {
                                  _searchQuery = value.trim();
                                });
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Filters Button
                      ElevatedButton.icon(
                        onPressed: _showFilterDialog,
                        icon: const Icon(Icons.filter_alt_outlined, size: 18),
                        label: const Text("Filtres"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1A2332),
                          elevation: 0,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // Horizontal padding only; vertical is handled by the stretch
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Export Button
                      ElevatedButton.icon(
                        onPressed: _showExportDialog,
                        icon: const Icon(Icons.arrow_upward, size: 18),
                        label: const Text("Exporter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1A2332),
                          elevation: 0,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Patients List container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: BlocBuilder<PatientBloc, PatientState>(
                      builder: (context, state) {
                        if (state is PatientsLoadInProgress) {
                          return SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (state is PatientsLoadSuccess) {
                          final patients = state.patients;
                          final filteredPatients =
                              PatientFilterUtil.applyFilters(
                                filterPatients(_searchQuery, patients),
                                _currentFilter,
                              );

                          if (filteredPatients.isEmpty) {
                            return SizedBox(
                              height: 150,
                              child: Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'Aucun patient disponible'
                                      : 'Aucun patient ne correspond à "$_searchQuery"',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    columnSpacing: 24,
                                    horizontalMargin: 16,
                                    dataRowMaxHeight: 80,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'Patient',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Contact',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Last Visit',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Upcoming',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Status',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Balance',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: filteredPatients.map((patient) {
                                      return _buildPatientRowFromPatient(
                                        patient: patient,
                                        onRowTap: widget.onPatientSelected,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        if (state is PatientsOperationFailure) {
                          return SizedBox(
                            height: 120,
                            child: Center(
                              child: Text('Échec du chargement des patients'),
                            ),
                          );
                        }

                        // default / initial
                        return DataTable(
                          showCheckboxColumn: false,
                          columnSpacing: 24,
                          horizontalMargin: 16,
                          dataRowMaxHeight: 80,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Patient',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Contact',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Last Visit',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Upcoming',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Balance',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: const [],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildPatientRowFromPatient({
    required Patient patient,
    required void Function(Map<String, dynamic>) onRowTap,
  }) {
    final fullName = [
      patient.firstName ?? '',
      patient.lastName ?? '',
    ].where((s) => s.trim().isNotEmpty).join(' ').trim();
    final displayName = fullName.isEmpty ? 'Unknown' : fullName;
    final idString = patient.id != null ? 'P${patient.id}' : '-';
    final email = patient.email ?? '-';
    final contact = patient.phone1 ?? '-';
    final lastVisit = patient.updatedAt != null
        ? patient.updatedAt!.toIso8601String().split('T').first
        : '-';
    final upcoming = '-';
    final status = patient.status ?? 'active';
    final balanceVal = 0; // Patient model does not include balance, default 0

    return DataRow(
      onSelectChanged: (_) {
        onRowTap({
          'name': displayName,
          'id': patient.id, // pass numeric id for persistence
          'idString': idString,
          'gender': patient.gender ?? '',
          'dob': patient.dateOfBirth != null
              ? patient.dateOfBirth!.toIso8601String().split('T').first
              : '',
          'phone': patient.phone1 ?? '',
          'email': email,
          'contact': contact,
          'lastVisit': lastVisit,
          'upcoming': upcoming,
          'status': status,
          'balance': balanceVal,
          'profileImageUrl': patient.profileImageUrl, // ADD THIS
        });
      },
      cells: [
        DataCell(
          Row(
            children: [
              // Updated avatar with image support
              FutureBuilder<Uint8List?>(
                future: _loadPatientImage(patient.profileImageUrl),
                builder: (context, snapshot) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: snapshot.hasData && snapshot.data != null
                          ? null
                          : const LinearGradient(
                              begin: Alignment(-0.00, -0.00),
                              end: Alignment(1.00, 1.00),
                              colors: [Color(0xFF50A2FF), Color(0xFFC17AFF)],
                            ),
                      borderRadius: BorderRadius.circular(30),
                      image: snapshot.hasData && snapshot.data != null
                          ? DecorationImage(
                              image: MemoryImage(snapshot.data!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: snapshot.hasData && snapshot.data != null
                        ? null
                        : Center(
                            child: Text(
                              getAvatarText(displayName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    idString,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/phone.svg",
                    color: Colors.grey[600],
                    width: 12,
                    height: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(contact),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/email.svg",
                    color: Colors.grey[600],
                    width: 12,
                    height: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(lastVisit)),
        DataCell(Text(upcoming)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status.toLowerCase() == 'active'
                  ? const Color(0xff00BC7D)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: status.toLowerCase() == 'active'
                    ? AppColors.white
                    : AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            balanceVal == 0 ? '\$0' : '\$$balanceVal',
            style: TextStyle(
              color: balanceVal == 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String getAvatarText(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    final nameParts = trimmed
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    final f = nameParts.isNotEmpty ? nameParts.first[0] : '';
    final l = nameParts.length > 1 ? nameParts.last[0] : '';
    return (f + l).toUpperCase();
  }

  Widget _buildStatCard(
    String title,
    int value,
    String icon,
    Color color, {
    bool isMoney = false,
  }) {
    return Expanded(
      child: Card(
        elevation: 3.5,
        shadowColor: Colors.grey.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMoney ? '\$$value' : value.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  icon,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp('\\s+'));
    if (parts.isEmpty) return 'NN';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
*/
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _dateOfBirthController.dispose();
    _insuranceProviderController.dispose();
    _allergiesController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _showAddPatientDialog() {
    _nameController.clear();
    _addressController.clear();
    _emailController.clear();
    _contactController.clear();
    _dateOfBirthController.clear();
    _genderValue = 'Female';
    _allergiesController.clear();
    _statusValue = 'active';
    _bloodType = 'O+';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Ajouter un patient',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Ajouter un nouveau patient au système avec ses informations personnelles et médicales',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        if (value.trim().length < 2) {
                          return 'Entrez un nom valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'adresse est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'email est obligatoire';
                        }
                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Entrez un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(labelText: 'Contact'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le contact est obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _insuranceProviderController,
                            decoration: const InputDecoration(
                              labelText: 'Fournisseur d\'assurance',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le fournisseur d\'assurance est obligatoire';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _dateOfBirthController,
                            decoration: InputDecoration(
                              labelText: 'Date de naissance (AAAA-MM-JJ)',
                              hintText:
                                  'AAAA-MM-JJ ou choisir dans le calendrier',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  final today = DateTime.now();
                                  final initial =
                                      DateTime.tryParse(
                                        _dateOfBirthController.text,
                                      ) ??
                                      DateTime(today.year - 25);
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: initial,
                                    firstDate: DateTime(1900),
                                    lastDate: today,
                                  );
                                  if (picked != null) {
                                    _dateOfBirthController.text = picked
                                        .toIso8601String()
                                        .split('T')
                                        .first;
                                  }
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La date de naissance est obligatoire';
                              }
                              final v = value.trim();
                              final ok =
                                  RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v) &&
                                  DateTime.tryParse(v) != null;
                              if (!ok) {
                                return 'Entrez une date valide au format AAAA-MM-JJ';
                              }
                              // Note: simple check - YYYY-MM-DD
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _genderValue,
                            decoration: const InputDecoration(
                              labelText: 'Genre',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Femme'),
                              ),
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Homme'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _genderValue = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _statusValue,
                            decoration: const InputDecoration(
                              labelText: 'Statut',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Actif'),
                              ),
                              DropdownMenuItem(
                                value: 'inactive',
                                child: Text('Inactif'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _statusValue = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _bloodType,
                            decoration: const InputDecoration(
                              labelText: 'Groupe sanguin',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'O+', child: Text('O+')),
                              DropdownMenuItem(value: 'O-', child: Text('O-')),
                              DropdownMenuItem(value: 'A+', child: Text('A+')),
                              DropdownMenuItem(value: 'A-', child: Text('A-')),
                              DropdownMenuItem(value: 'B+', child: Text('B+')),
                              DropdownMenuItem(value: 'B-', child: Text('B-')),
                              DropdownMenuItem(
                                value: 'AB+',
                                child: Text('AB+'),
                              ),
                              DropdownMenuItem(
                                value: 'AB-',
                                child: Text('AB-'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _bloodType = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'Allergies',
                        hintText: 'List any allergies',
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Build Patient model and dispatch AddPatient via bloc
                    final fullName = _nameController.text.trim();
                    String firstName = '';
                    String lastName = '';
                    final parts = fullName.split(RegExp('\\s+'));
                    if (parts.isNotEmpty) {
                      firstName = parts.first;
                      if (parts.length > 1) {
                        lastName = parts.sublist(1).join(' ');
                      }
                    }

                    DateTime? dob;
                    if (_dateOfBirthController.text.trim().isNotEmpty) {
                      try {
                        dob = DateTime.tryParse(
                          _dateOfBirthController.text.trim(),
                        );
                      } catch (_) {
                        dob = null;
                      }
                    }

                    final patient = Patient(
                      firstName: firstName,
                      lastName: lastName,
                      gender: _genderValue,
                      dateOfBirth: dob,
                      bloodType: _bloodType,
                      phone1: _contactController.text.trim(),
                      email: _emailController.text.trim(),
                      address: _addressController.text.trim(),
                      status: _statusValue,
                    );

                    // Dispatch to bloc
                    context.read<PatientBloc>().add(AddPatient(patient));

                    Navigator.of(context).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Patient ajouté')),
                      );
                    }
                  }
                },
                child: const Text('Créer un patient'),
              ),
            ),
          ],
        );
      },
    );
  }
}
