import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../utils/appointment_utils.dart';

class TotalAppointmentsDialog extends StatefulWidget {
  final AppointmentService service;

  const TotalAppointmentsDialog({
    super.key,
    required this.service,
  });

  @override
  State<TotalAppointmentsDialog> createState() => _TotalAppointmentsDialogState();
}

class _TotalAppointmentsDialogState extends State<TotalAppointmentsDialog> {
  late List<Appointment> allAppointments;
  List<Appointment> filteredAppointments = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    allAppointments = widget.service.getAllAppointments();
    filteredAppointments = allAppointments;
    _searchController.addListener(_filterAppointments);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAppointments);
    _searchController.dispose();
    super.dispose();
  }

  void _filterAppointments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredAppointments = allAppointments.where((app) {
        return app.patientName.toLowerCase().contains(query) ||
            app.procedure.toLowerCase().contains(query) ||
            app.doctorName.toLowerCase().contains(query) ||
            DateFormat('MMM dd, yyyy').format(app.appointmentDate).toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 800),
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildAppointmentsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
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
                'Total Appointments',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${filteredAppointments.length} appointment${filteredAppointments.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by patient, doctor, treatment or date...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: filteredAppointments.asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;
              final appointmentDateTime = AppointmentUtils.getAppointmentDateTime(app);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.grey[50] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Colored dot + Treatment
                      Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: app.cardColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            app.procedure,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),

                      // Patient
                      _buildInfoColumn('Patient', app.patientName, Icons.person),

                      const SizedBox(width: 32),

                      // Doctor
                      _buildInfoColumn('Doctor', 'Dr. ${app.doctorName}', Icons.local_hospital),

                      const SizedBox(width: 32),

                      // Date & Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date & Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('EEE, MMM dd').format(app.appointmentDate),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            app.time,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                          ),
                        ],
                      ),

                      const SizedBox(width: 32),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppointmentUtils.getStatusColor(app.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppointmentUtils.getStatusColor(app.status)),
                        ),
                        child: Text(
                          app.status.toUpperCase(),
                          style: TextStyle(
                            color: AppointmentUtils.getStatusColor(app.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
}