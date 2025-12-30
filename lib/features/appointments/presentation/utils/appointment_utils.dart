import 'package:flutter/material.dart';
import '../models/appointment_model.dart';

class AppointmentUtils {
  static const Color confirmedColor = Color(0xFF10B981);
  static const Color pendingColor = Color(0xFF3B82F6);
  static const Color cancelledColor = Color(0xFFEF4444);

  // REMOVED: the old treatmentColors map

  /// Returns a color based on the treatment name from the database
  static Color getTreatmentColor(String procedure) {
    if (procedure.isEmpty) return const Color(0xFF6B7280);

    final normalized = procedure.trim().toLowerCase();

    switch (normalized) {
      case 'nettoyage dentaire':
        return const Color(0xFF10B981);
      case 'plombage dentaire':
        return const Color(0xFF06B6D4);
      case 'traitement de canal':
        return const Color(0xFF2563EB);
      case 'couronne':
        return const Color(0xFFA855F7);
      case 'extraction dentaire':
        return const Color(0xFFEF4444);
      case 'implant dentaire':
        return const Color(0xFF7C3AED);
      // Add more as needed when you create new treatments in Supabase
      default:
        return const Color(0xFF6B7280); // neutral gray for unknown/new treatments
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return confirmedColor;
      case 'pending':
        return pendingColor;
      case 'cancelled':
        return cancelledColor;
      default:
        return const Color(0xFF6B7280);
    }
  }

  static DateTime getAppointmentDateTime(Appointment app) {
    final timeParts = app.time.split(':');
    final hour = int.tryParse(timeParts.isNotEmpty ? timeParts[0].trim() : '0') ?? 0;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1].trim() : '0') ?? 0;
    return DateTime(
      app.appointmentDate.year,
      app.appointmentDate.month,
      app.appointmentDate.day,
      hour.clamp(0, 23),
      minute.clamp(0, 59),
    );
  }

  static String getDateKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }
}