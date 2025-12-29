import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/appointment_bloc.dart';
import '../models/appointment_model.dart';
import '../utils/appointment_utils.dart';
import 'appointment_detail_page.dart';
import 'total_appointments_dialog.dart';
import '../dialogs/schedule_appointment_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime selectedDay = DateTime.now();
  DateTime calendarMonth = DateTime.now();
  String viewMode = 'Jour';
  String? hoveredAppointmentId;

  // Multi-doctor logic
  int? loggedInDoctorId;
  int? selectedFilterDoctorId;
  List<Map<String, dynamic>> doctors = [];

  List<Appointment> getTodayAppointments(List<Appointment> all) {
    final today = selectedDay;
    var dayAppointments = all.where((a) =>
    a.appointmentDate.year == today.year &&
    a.appointmentDate.month == today.month &&
    a.appointmentDate.day == today.day &&
    a.status != 'cancelled' // ← THIS LINE ADDED
).toList();
    final effectiveDoctorId = selectedFilterDoctorId ?? loggedInDoctorId;
    if (effectiveDoctorId != null) {
      dayAppointments = dayAppointments.where((a) => a.doctorId == effectiveDoctorId).toList();
    }

    return dayAppointments;
  }

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(LoadAppointments());
    _fetchDoctorsAndCurrentUser();
  }

  Future<void> _fetchDoctorsAndCurrentUser() async {
    try {
      final doctorResp = await Supabase.instance.client
          .from('users')
          .select('id, first_name, last_name')
          .eq('role', 'doctor')
          .order('first_name');

      setState(() {
        doctors = List<Map<String, dynamic>>.from(doctorResp);
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final userResp = await Supabase.instance.client
            .from('users')
            .select('id')
            .eq('auth_id', user.id)
            .eq('role', 'doctor')
            .maybeSingle();

        if (userResp != null) {
          setState(() {
            loggedInDoctorId = userResp['id'] as int;
            selectedFilterDoctorId = loggedInDoctorId;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading doctors or current user: $e');
    }
  }

  void navigateToAppointmentDetail(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailPage(
          appointment: appointment,
          onBack: () => context.read<AppointmentBloc>().add(LoadAppointments()),
        ),
      ),
    );
  }

  void showScheduleAppointmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const ScheduleAppointmentDialog(),
    );
  }

  void showTotalAppointmentsDialog(List<Appointment> appointments) {
    showDialog(
      context: context,
      builder: (BuildContext context) => TotalAppointmentsDialog(appointments: appointments),
    );
  }

  List<Appointment> getFilteredAppointments(List<Appointment> all) {
    if (viewMode == 'Jour') {
      return all
          .where((a) =>
              a.appointmentDate.year == selectedDay.year &&
              a.appointmentDate.month == selectedDay.month &&
              a.appointmentDate.day == selectedDay.day)
          .toList();
    } else if (viewMode == 'Semaine') {
      final monday = selectedDay.subtract(Duration(days: selectedDay.weekday - 1));
      return all.where((a) {
        return a.appointmentDate.isAfter(monday.subtract(const Duration(days: 1))) &&
            a.appointmentDate.isBefore(monday.add(const Duration(days: 7)));
      }).toList();
    } else {
      return all
          .where((a) =>
              a.appointmentDate.year == selectedDay.year &&
              a.appointmentDate.month == selectedDay.month)
          .toList();
    }
  }

  bool hasAppointmentsOnDay(DateTime day, List<Appointment> all) {
    return all.any((a) =>
    a.appointmentDate.year == day.year &&
    a.appointmentDate.month == day.month &&
    a.appointmentDate.day == day.day &&
    a.status != 'cancelled'); // ← THIS LINE ADDED
  }

  bool get isSingleDoctorView => selectedFilterDoctorId != null || loggedInDoctorId != null;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF3F4F6),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
          );
        } else if (state is AppointmentLoadSuccess) {
          final appointments = state.appointments;
          final filteredAppointments = getFilteredAppointments(appointments);
          final confirmed = filteredAppointments.where((a) => a.status == 'confirmed').length;
          final pending = filteredAppointments.where((a) => a.status == 'pending').length;
          final cancelled = filteredAppointments.where((a) => a.status == 'cancelled').length;
          final todayAppointments = getTodayAppointments(appointments);
          final screenWidth = MediaQuery.of(context).size.width;

          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: screenWidth < 800
                ? _buildSingleColumn(appointments, filteredAppointments, todayAppointments, confirmed, pending, cancelled, screenWidth)
                : _buildDualColumn(appointments, filteredAppointments, todayAppointments, confirmed, pending, cancelled, screenWidth),
          );
        } else if (state is AppointmentOperationFailure) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Erreur de chargement',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(state.error, style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<AppointmentBloc>().add(LoadAppointments()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(
          backgroundColor: Color(0xFFF3F4F6),
          body: Center(child: Text('Chargement...')),
        );
      },
    );
  }

  Widget _buildSingleColumn(List<Appointment> all, List<Appointment> filtered, List<Appointment> todayApps,
      int confirmed, int pending, int cancelled, double width) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(all, filtered, todayApps, confirmed, pending, cancelled, width, true),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildCalendarHeader(),
                const SizedBox(height: 16),
                _buildCalendarGrid(all),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.all(20),
            child: _buildAppointmentsList(todayApps),
          ),
        ],
      ),
    );
  }

  Widget _buildDualColumn(List<Appointment> all, List<Appointment> filtered, List<Appointment> todayApps,
      int confirmed, int pending, int cancelled, double width) {
    return Column(
      children: [
        _buildHeader(all, filtered, todayApps, confirmed, pending, cancelled, width, false),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 300,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildCalendarHeader(),
                    const SizedBox(height: 16),
                    Expanded(child: _buildCalendarGrid(all)),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF9FAFB),
                  padding: const EdgeInsets.all(24),
                  child: _buildAppointmentsList(todayApps),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(List<Appointment> all, List<Appointment> filtered, List<Appointment> todayApps,
      int confirmed, int pending, int cancelled, double width, bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 20 : 24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendrier des rendez-vous',
                    style: TextStyle(
                      fontSize: compact ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Gérer et planifier les rendez-vous',
                    style: TextStyle(fontSize: compact ? 12 : 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (width > 900) ...[
                    _buildModeButton('Jour'),
                    _buildModeButton('Semaine'),
                    _buildModeButton('Mois'),
                  ],
                  // Doctor filter REMOVED from here
                  if (width > 1050)
                    ElevatedButton.icon(
                      onPressed: () => showTotalAppointmentsDialog(all),
                      icon: Icon(Icons.list, size: compact ? 16 : 18),
                      label: Text(compact ? 'Total' : 'Total'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.list),
                      onPressed: () => showTotalAppointmentsDialog(all),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (width > 1200)
                    ElevatedButton.icon(
                      onPressed: showScheduleAppointmentDialog,
                      icon: Icon(Icons.add, size: compact ? 16 : 18),
                      label: Text(compact ? 'Nouveau' : 'Nouveau'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: showScheduleAppointmentDialog,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard('Total', '${filtered.length}', const Color(0xFF3B82F6), 'all', filtered, width),
              _buildStatCard('Confirmés', '$confirmed', AppointmentUtils.confirmedColor, 'confirmed', filtered, width),
              _buildStatCard('En attente', '$pending', AppointmentUtils.pendingColor, 'pending', filtered, width),
              _buildStatCard('Annulés', '$cancelled', AppointmentUtils.cancelledColor, 'cancelled', filtered, width),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildDoctorFilterDropdown() {
  return DropdownButton<int?>(
    value: selectedFilterDoctorId,
    hint: const Text('Tous les médecins'),
    items: [
      const DropdownMenuItem<int?>(value: null, child: Text('Tous les médecins')),
      ...doctors.map((doc) {
        final name = '${doc['first_name']} ${doc['last_name']}'.trim(); // ← Removed "Dr."
        return DropdownMenuItem<int?>(value: doc['id'] as int, child: Text(name));
      }).toList(),
    ],
    onChanged: (value) {
      setState(() {
        selectedFilterDoctorId = value;
      });
    },
    style: const TextStyle(color: Color(0xFF111827), fontSize: 14),
    dropdownColor: Colors.white,
    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF3B82F6)),
    underline: Container(height: 1, color: const Color(0xFF3B82F6)),
  );
}
  Widget _buildModeButton(String mode) {
    final isActive = viewMode == mode;
    return ElevatedButton(
      onPressed: () => setState(() => viewMode = mode),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF3B82F6) : Colors.white,
        foregroundColor: isActive ? Colors.white : Colors.grey[700],
        elevation: 0,
        side: BorderSide(color: isActive ? Colors.transparent : const Color(0xFFE5E7EB)),
      ),
      child: Text(mode),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, String type,
      List<Appointment> filtered, double width) {
    double cardWidth = width > 900 ? (width - 100) / 4 : (width - 80) / 2;
    return SizedBox(
      width: cardWidth,
      child: InkWell(
        onTap: () => showPatientListDialog(type, filtered),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(title,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Calendrier',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () => setState(() {
                calendarMonth = DateTime(calendarMonth.year, calendarMonth.month - 1);
              }),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () => setState(() {
                calendarMonth = DateTime(calendarMonth.year, calendarMonth.month + 1);
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(List<Appointment> appointments) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('MMMM yyyy').format(calendarMonth),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final firstDay = DateTime(calendarMonth.year, calendarMonth.month, 1);
              final day = index - firstDay.weekday + 2;
              if (day < 1 || day > 31) return const SizedBox();

              final date = DateTime(calendarMonth.year, calendarMonth.month, day);
              final isSelected = selectedDay.year == date.year &&
                  selectedDay.month == date.month &&
                  selectedDay.day == date.day;
              final hasAppts = hasAppointmentsOnDay(date, appointments);

              return GestureDetector(
                onTap: () => setState(() => selectedDay = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: hasAppts && !isSelected
                        ? Border.all(color: const Color(0xFF3B82F6), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actions rapides',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Trouver un créneau'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Filtrer'),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(selectedDay),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${appointments.length} rendez-vous',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            // Doctor filter moved here — above the timeline
            _buildDoctorFilterDropdown(),
          ],
        ),
        const SizedBox(height: 20),
        appointments.isEmpty
            ? Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Aucun rendez-vous planifié',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              )
            : Expanded(child: _buildTimelineView(appointments)),
      ],
    );
  }

  Widget _buildTimelineView(List<Appointment> appointments) {
    final sorted = List<Appointment>.from(appointments)
      ..sort((a, b) => a.time.compareTo(b.time));

    return SingleChildScrollView(
      child: Column(
        children: List.generate(12, (i) {
          final hour = 8 + i;
          final hourAppts = sorted.where((a) {
            final h = int.tryParse(a.time.split(':')[0]) ?? -1;
            return h == hour;
          }).toList();

          if (hourAppts.isEmpty) {
            return SizedBox(
              height: 80,
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            );
          }

          final isSingleDoctor = isSingleDoctorView;

          return SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: hourAppts.map((apt) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: InkWell(
                            onTap: () => navigateToAppointmentDetail(apt),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: apt.cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    apt.patientName,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isSingleDoctor ? apt.procedure : apt.doctorName,
                                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // showPatientListDialog and _getFilterTitle remain the same
  void showPatientListDialog(String filterType, List<Appointment> allAppointments) {
    final List<Appointment> appointmentsToShow = filterType == 'all'
        ? allAppointments
        : allAppointments.where((a) => a.status == filterType).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFilterTitle(filterType),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            '${appointmentsToShow.length} rendez-vous',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: appointmentsToShow.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text('Aucun rendez-vous trouvé',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: appointmentsToShow.length,
                          separatorBuilder: (_, __) => Divider(color: Colors.grey[200], height: 1),
                          itemBuilder: (context, index) {
                            final apt = appointmentsToShow[index];
                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                navigateToAppointmentDetail(apt);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: filterType == 'all'
                                            ? AppointmentUtils.getStatusColor(apt.status)
                                            : AppointmentUtils.getTreatmentColor(apt.procedure),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            apt.patientName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${apt.procedure} • ${apt.time}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFilterTitle(String filterType) {
    switch (filterType) {
      case 'all':
        return 'Tous les rendez-vous';
      case 'confirmed':
        return 'Rendez-vous confirmés';
      case 'pending':
        return 'Rendez-vous en attente';
      case 'cancelled':
        return 'Rendez-vous annulés';
      default:
        return 'Rendez-vous';
    }
  }
}