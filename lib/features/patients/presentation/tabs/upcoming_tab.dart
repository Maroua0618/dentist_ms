import 'package:dentist_ms/features/appointments/bloc/appointment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/appointments/presentation/utils/appointment_utils.dart';
import 'package:dentist_ms/features/appointments/presentation/pages/appointment_detail_page.dart';
import 'package:intl/intl.dart';

class UpcomingTab extends StatelessWidget {
  final int?  patientId;
  
  const UpcomingTab({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    if (patientId == null) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Text(
            "Aucun ID de patient disponible pour les rendez-vous à venir",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        // Handle loading state
        if (state is AppointmentLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF3B82F6),
            ),
          );
        }
        
        // Handle success state
        if (state is AppointmentLoadSuccess) {
          final now = DateTime.now();
          
          // Filter upcoming appointments for this patient
          final upcoming = state.appointments
              .where((a) =>
                  a.patientId == patientId &&
                  a.status != 'cancelled' &&
                  a. appointmentDate.isAfter(now))
              .toList()
            ..sort((a, b) => a.appointmentDate.compareTo(b. appointmentDate));

          if (upcoming.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius:  BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.event_available,
                      size:  48,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Pas de rendez-vous à venir",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView. separated(
            padding: const EdgeInsets.all(12),
            itemCount: upcoming.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final apt = upcoming[index];
              final statusColor = AppointmentUtils.getStatusColor(apt.status);
              
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppointmentDetailPage(
                        appointment: apt,
                        onBack: () => context.read<AppointmentBloc>().add(
                          LoadAppointments(),
                        ),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children:  [
                      Container(
                        width: 6,
                        height: 56,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apt.procedure,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${DateFormat.yMMMMd('fr_FR').format(apt.appointmentDate)} • ${apt.time} • ${apt.doctorName}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(apt.status. toUpperCase()),
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        
        // Handle failure state
        if (state is AppointmentOperationFailure) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size:  48,
                    color:  Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Impossible de charger les rendez-vous:\n${state.error}',
                    style: const TextStyle(
                      fontSize:  14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Default fallback
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              style: BorderStyle.solid,
            ),
          ),
          child: const Center(
            child:  Text(
              'Aucun rendez-vous disponible',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }
}