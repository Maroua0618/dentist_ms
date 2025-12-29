// lib/dialogs/patient_list_dialog.dart

import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../utils/appointment_utils.dart';

class PatientListDialog extends StatelessWidget {
  final String filterType;
  final List<Appointment> appointments;
  final AppointmentService service; // kept for compatibility, not used
  final Function(Appointment) onAppointmentTap;

  const PatientListDialog({
    super.key,
    required this.filterType,
    required this.appointments,
    required this.service,
    required this.onAppointmentTap,
  });

  List<Appointment> _getFilteredAppointments() {
    if (filterType == 'all') return appointments;
    return appointments.where((a) => a.status == filterType).toList();
  }

  String _getFilterTitle() {
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

  @override
  Widget build(BuildContext context) {
    final appointmentsToShow = _getFilteredAppointments();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
                        _getFilterTitle(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
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

            // List
            Expanded(
              child: appointmentsToShow.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('Aucun rendez-vous trouvé', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: appointmentsToShow.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      itemBuilder: (context, index) {
                        final appointment = appointmentsToShow[index];
                        final treatmentColor = AppointmentUtils.getTreatmentColor(appointment.procedure);
                        final statusColor = AppointmentUtils.getStatusColor(appointment.status);
                        final indicatorColor = filterType == 'all' ? statusColor : treatmentColor;

                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            onAppointmentTap(appointment);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Container(width: 4, height: 68, color: indicatorColor),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              appointment.patientName,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (filterType == 'all')
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                              child: Text(
                                                appointment.status[0].toUpperCase() + appointment.status.substring(1),
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // DOCTOR NAME — THIS IS THE KEY LINE
                                      Text(
                                        appointment.doctorName,
                                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.medical_services_outlined, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(appointment.procedure, style: TextStyle(fontSize: 13, color: Colors.grey[700]), overflow: TextOverflow.ellipsis),
                                          ),
                                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                          const SizedBox(width: 6),
                                          Text(appointment.time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
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
  }
}