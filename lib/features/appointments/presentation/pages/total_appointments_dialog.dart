import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../utils/appointment_utils.dart';

class TotalAppointmentsDialog extends StatefulWidget {
  final List<Appointment> appointments;

  const TotalAppointmentsDialog({super.key, required this.appointments});

  @override
  State<TotalAppointmentsDialog> createState() =>
      _TotalAppointmentsDialogState();
}

class _TotalAppointmentsDialogState extends State<TotalAppointmentsDialog> {
  late List<AppointmentWithStatus> allAppointments;
  List<AppointmentWithStatus> filteredAppointments = [];
  String searchQuery = '';
  String sortBy = 'Plus récent';
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _initializeAppointments();
  }

  void _initializeAppointments() {
    final now = DateTime.now();
    allAppointments = widget.appointments.map((app) {
      final appointmentTime = AppointmentUtils.getAppointmentDateTime(app);
      final endTime = appointmentTime.add(Duration(minutes: app.duration));

      String status;
      if (endTime.isBefore(now)) {
        status = 'Terminé';
      } else if (appointmentTime.isBefore(now) && endTime.isAfter(now)) {
        status = 'En cours';
      } else {
        status = 'À venir';
      }

      return AppointmentWithStatus(appointment: app, status: status);
    }).toList();

    _sortAndFilter();
  }

  void _sortAndFilter() {
    var list = List<AppointmentWithStatus>.from(allAppointments);

    // Search
    if (searchQuery.isNotEmpty) {
      list = list.where((item) {
        return item.appointment.patientName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            item.appointment.procedure.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            item.appointment.doctorName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Sort
    if (sortBy == 'Plus récent') {
      list.sort(
        (a, b) => b.appointment.appointmentDate.compareTo(
          a.appointment.appointmentDate,
        ),
      );
    } else {
      list.sort(
        (a, b) => a.appointment.appointmentDate.compareTo(
          b.appointment.appointmentDate,
        ),
      );
    }

    filteredAppointments = list;
    currentPage = 1;
    setState(() {});
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Terminé':
        return const Color(0xFF10B981);
      case 'En cours':
        return const Color(0xFF3B82F6);
      case 'À venir':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  int get _totalPages => (filteredAppointments.length / itemsPerPage).ceil();

  List<AppointmentWithStatus> get _paginatedAppointments {
    final start = (currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredAppointments.sublist(
      start,
      end > filteredAppointments.length ? filteredAppointments.length : end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = allAppointments.where((a) => a.status == 'À venir').length;
    final inProgress = allAppointments
        .where((a) => a.status == 'En cours')
        .length;
    final completed = allAppointments
        .where((a) => a.status == 'Terminé')
        .length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total des rendez-vous',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${allAppointments.length} rendez-vous au total',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Status Pills + Search + Sort
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
              child: Row(
                children: [
                  _buildStatusPill(
                    'À venir',
                    upcoming,
                    const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 16),
                  _buildStatusPill(
                    'En cours',
                    inProgress,
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 16),
                  _buildStatusPill(
                    'Terminé',
                    completed,
                    const Color(0xFF10B981),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: (value) {
                        searchQuery = value;
                        _sortAndFilter();
                      },
                      decoration: InputDecoration(
                        hintText: 'Rechercher patient, médecin, traitement...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: sortBy,
                    items: ['Plus récent', 'Plus ancien']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        sortBy = value;
                        _sortAndFilter();
                      }
                    },
                  ),
                ],
              ),
            ),

            // Appointments List (Cards)
            Expanded(
              child: filteredAppointments.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun rendez-vous trouvé',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      itemCount: _paginatedAppointments.length,
                      itemBuilder: (context, index) {
                        final item = _paginatedAppointments[index];
                        final app = item.appointment;
                        // ignore: unused_local_variable
                        final time = AppointmentUtils.getAppointmentDateTime(
                          app,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? Colors.grey[50]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Treatment Dot + Name
                              Column(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: app.cardColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    app.procedure,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 40),

                              // Patient
                              Expanded(
                                child: _info(
                                  'Patient',
                                  app.patientName,
                                  Icons.person,
                                ),
                              ),

                              // Doctor
                              Expanded(
                                child: _info(
                                  'Médecin',
                                  ' ${app.doctorName}',
                                  Icons.local_hospital,
                                ),
                              ),

                              // Date & Time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Date & Heure',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat(
                                        'EEE dd MMM',
                                      ).format(app.appointmentDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      app.time,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Status
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    item.status,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: _getStatusColor(item.status),
                                  ),
                                ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    color: _getStatusColor(item.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Pagination
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${filteredAppointments.length} résultats'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage > 1
                            ? () => setState(() => currentPage--)
                            : null,
                      ),
                      ...List.generate(
                        _totalPages,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: currentPage == i + 1
                                ? const Color(0xFF3B82F6)
                                : Colors.transparent,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: currentPage == i + 1
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage < _totalPages
                            ? () => setState(() => currentPage++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentWithStatus {
  final Appointment appointment;
  final String status;

  AppointmentWithStatus({required this.appointment, required this.status});
}
