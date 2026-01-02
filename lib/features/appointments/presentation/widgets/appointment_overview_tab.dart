import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';

class AppointmentOverviewTab extends StatelessWidget {
  final Appointment appointment;
  final bool isAppointmentCompleted;

  const AppointmentOverviewTab({
    super.key,
    required this.appointment,
    required this.isAppointmentCompleted,
  });

  String _getCurrentStatus() {
    return isAppointmentCompleted ? 'completed' : appointment.status;
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'EN ATTENTE';
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = _getCurrentStatus();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Remarques du rendez-vous',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            appointment.notes.isEmpty
                ? 'Aucune note ajoutée'
                : appointment.notes,
            style: TextStyle(
              fontSize: 13,
              color: appointment.notes.isEmpty
                  ? Colors.grey[500]
                  : Colors.grey[700],
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Informations rapides',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'ID du rendez-vous',
                '#APT${appointment.id.padLeft(4, '0')}',
              ),
              const Divider(height: 20),
              _buildInfoRow(
                'Statut',
                _getStatusLabel(currentStatus),
              ),
              const Divider(height: 20),
              _buildInfoRow('Type de traitement', appointment.procedure),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
