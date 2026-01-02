import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/appointment_bloc.dart';
import '../models/appointment_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/features/settings/models/clinicInfo.dart';
import 'dart:typed_data';

class AppointmentDetailPage extends StatefulWidget {
  final Appointment appointment;
  final VoidCallback onBack;

  const AppointmentDetailPage({
    super.key,
    required this.appointment,
    required this.onBack,
  });

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  late Appointment appointment;
  String selectedTab = 'Aperçu';
  bool isAppointmentStarted = false;
  bool isAppointmentCompleted = false;
  DateTime? appointmentStartTime;
  DateTime? appointmentEndTime;
  List<Map<String, dynamic>> prescriptions = [];
  bool isLoadingPrescriptions = false;

  @override
  void initState() {
    super.initState();
    appointment = widget.appointment;
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() => isLoadingPrescriptions = true);
    try {
      if (appointment.patientId == null) {
        debugPrint('⚠️ Patient ID is null, cannot load prescriptions');
        setState(() => isLoadingPrescriptions = false);
        return;
      }
      
      debugPrint('🔍 Loading prescriptions for patient_id: ${appointment.patientId}');
      
      final response = await Supabase.instance.client
          .from('prescriptions')
          .select('*, prescription_items(*), doctor:users(first_name,last_name)')
          .eq('patient_id', appointment.patientId!);

      debugPrint('📋 Loaded ${(response as List).length} prescriptions');

      setState(() {
        prescriptions = List<Map<String, dynamic>>.from(response).map((p) {
          return {
            ...p,
            'doctor': (p['doctor'] != null)
                ? '${p['doctor']['first_name']} ${p['doctor']['last_name']}'
                : 'Inconnu',
            'items': p['prescription_items'] ?? [],
          };
        }).toList();
        isLoadingPrescriptions = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading prescriptions: $e');
      setState(() => isLoadingPrescriptions = false);
    }
  }

  String _getAppointmentDuration() {
    if (appointmentStartTime != null && appointmentEndTime != null) {
      final duration = appointmentEndTime!.difference(appointmentStartTime!);
      final minutes = duration.inMinutes;
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (hours > 0) {
        return '$hours h ${remainingMinutes}m';
      }
      return '${remainingMinutes}m';
    }
    return '${appointment.duration}m';
  }

  void _startAppointment() {
    setState(() {
      isAppointmentStarted = true;
      appointmentStartTime = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Rendez-vous démarré!'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _completeAppointment() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Terminer le rendez-vous',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Prêt à marquer comme terminé?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Durée du rendez-vous: ${_getAppointmentDuration()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résumé du rendez-vous',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Patient', appointment.patientName),
                    const Divider(height: 16),
                    _buildSummaryRow('Intervention', appointment.procedure),
                    const Divider(height: 16),
                    _buildSummaryRow('Statut', 'Terminé'),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      'Heure de début',
                      DateFormat(
                        'HH:mm',
                      ).format(appointmentStartTime ?? DateTime.now()),
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow(
                      'Heure de fin',
                      DateFormat('HH:mm').format(DateTime.now()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isAppointmentCompleted = true;
                        appointmentEndTime = DateTime.now();
                        appointment.status = 'completed';
                      });
                      context.read<AppointmentBloc>().add(
                        UpdateAppointment(appointment),
                      );
                      Navigator.pop(context);

                      // Show the snackbar on the next frame to avoid using a deactivated context
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Rendez-vous terminé avec succès!'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      });
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Marquer comme terminé'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentStatus = isAppointmentCompleted
        ? 'completed'
        : appointment.status;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () {
            // Pop this page first, then run the parent callback after the frame to avoid
            // looking up ancestors from a deactivated context.
            Navigator.pop(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                widget.onBack();
              } catch (_) {}
            });
          },
        ),
        title: const Text(
          'Détails du rendez-vous',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(currentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentStatus == 'pending'
                      ? 'EN ATTENTE'
                      : currentStatus == 'confirmed'
                      ? 'CONFIRMÉ'
                      : currentStatus == 'completed'
                      ? 'TERMINÉ'
                      : 'ANNULÉ',
                  style: TextStyle(
                    color: _getStatusColor(currentStatus),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.patientName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: appointment.cardColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                appointment.procedure,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: appointment.cardColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: isAppointmentCompleted
                            ? null
                            : () => _showEditAppointmentDialog(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isAppointmentCompleted
                                ? Colors.grey[200]
                                : const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: isAppointmentCompleted
                                ? Colors.grey[400]
                                : const Color(0xFF3B82F6),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.calendar_today,
                          'Date',
                          DateFormat(
                            'MMM d, yyyy',
                          ).format(appointment.appointmentDate),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.access_time,
                          'Heure',
                          appointment.time,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.schedule,
                          'Durée',
                          _getAppointmentDuration(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildClickableStatusCard(
                        'En attente',
                        currentStatus == 'pending',
                        const Color(0xFF3B82F6),
                        'pending',
                      ),
                      _buildClickableStatusCard(
                        'Confirmé',
                        currentStatus == 'confirmed',
                        const Color(0xFF10B981),
                        'confirmed',
                      ),
                      _buildClickableStatusCard(
                        'Terminé',
                        currentStatus == 'completed',
                        const Color(0xFF10B981),
                        'completed',
                      ),
                      _buildClickableStatusCard(
                        'Annulé',
                        currentStatus == 'cancelled',
                        const Color(0xFFEF4444),
                        'cancelled',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabButton('Aperçu', selectedTab == 'Aperçu'),
                    _buildTabButton(
                      'Pendant le rendez-vous',
                      selectedTab == 'Pendant le rendez-vous',
                    ),
                    _buildTabButton('Ordonnances', selectedTab == 'Ordonnances'),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 1),
              padding: const EdgeInsets.all(24),
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: isAppointmentCompleted
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: const Color(0xFF10B981),
              icon: const Icon(Icons.check_circle),
              label: const Text('Terminé'),
            )
          : isAppointmentStarted
          ? FloatingActionButton.extended(
              onPressed: _completeAppointment,
              backgroundColor: const Color(0xFF10B981),
              icon: const Icon(Icons.check_circle),
              label: const Text('Terminer le rendez-vous'),
            )
          : FloatingActionButton.extended(
              onPressed: _startAppointment,
              backgroundColor: const Color(0xFF3B82F6),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Démarrer le rendez-vous'),
            ),
    );
  }

  Widget _buildClickableStatusCard(
    String label,
    bool isActive,
    Color color,
    String statusValue,
  ) {
    return GestureDetector(
      onTap: isAppointmentCompleted
          ? null
          : () {
              setState(() {
                appointment.status = statusValue;
                if (statusValue == 'completed') isAppointmentCompleted = true;
              });
              context.read<AppointmentBloc>().add(
                UpdateAppointment(appointment),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Statut mis à jour : $label'),
                    backgroundColor: color,
                  ),
                );
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : const Color(0xFFE5E7EB),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? color : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF3B82F6) : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (selectedTab == 'Pendant le rendez-vous') {
      return _buildDuringAppointmentTab();
    } else if (selectedTab == 'Ordonnances') {
      return _buildPrescriptionsTab();
    }
    return _buildOverviewTab(); // Default to Aperçu
  }

  Widget _buildOverviewTab() {
    final String currentStatus = isAppointmentCompleted
        ? 'completed'
        : appointment.status;
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
                currentStatus == 'pending'
                    ? 'EN ATTENTE'
                    : currentStatus == 'confirmed'
                    ? 'CONFIRMÉ'
                    : currentStatus == 'completed'
                    ? 'TERMINÉ'
                    : 'ANNULÉ',
              ),
              const Divider(height: 20),
              _buildInfoRow('Type de traitement', appointment.procedure),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDuringAppointmentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAppointmentCompleted
                ? const Color(0xFF10B981).withOpacity(0.1)
                : isAppointmentStarted
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAppointmentCompleted
                  ? const Color(0xFF10B981)
                  : isAppointmentStarted
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isAppointmentCompleted
                    ? Icons.check_circle
                    : isAppointmentStarted
                    ? Icons.check_circle
                    : Icons.info,
                color: isAppointmentCompleted
                    ? const Color(0xFF10B981)
                    : isAppointmentStarted
                    ? const Color(0xFF10B981)
                    : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isAppointmentCompleted
                      ? 'Rendez-vous terminé'
                      : isAppointmentStarted
                      ? 'Le rendez-vous est en cours'
                      : 'Démarrez le rendez-vous pour ajouter des enregistrements',
                  style: TextStyle(
                    fontSize: 13,
                    color: isAppointmentCompleted
                        ? const Color(0xFF10B981)
                        : isAppointmentStarted
                        ? const Color(0xFF10B981)
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enregistrement audio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isAppointmentStarted && !isAppointmentCompleted)
                      ? const Color(0xFF3B82F6).withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.mic,
                  color: (isAppointmentStarted && !isAppointmentCompleted)
                      ? const Color(0xFF3B82F6)
                      : Colors.grey[400],
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enregistrer les remarques du patient',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enregistrez des notes vocales sur le rendez-vous',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: (isAppointmentStarted && !isAppointmentCompleted)
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonction d\'enregistrement à venir'),
                        ),
                      )
                    : null,
                icon: const Icon(Icons.fiber_manual_record),
                label: const Text('Démarrer l\'enregistrement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  disabledBackgroundColor: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Notes cliniques',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: isAppointmentStarted && !isAppointmentCompleted,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Ajouter des notes cliniques pendant le rendez-vous...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            filled: true,
            fillColor: (isAppointmentStarted && !isAppointmentCompleted)
                ? Colors.white
                : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 24),
        const Text(
          'Charger des fichiers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (isAppointmentStarted && !isAppointmentCompleted)
                ? Colors.grey[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: (isAppointmentStarted && !isAppointmentCompleted)
                    ? const Color(0xFF3B82F6)
                    : Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text(
                'Glissez et déposez les fichiers ici',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ou',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: (isAppointmentStarted && !isAppointmentCompleted)
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fonction de téléchargement de fichiers à venir',
                          ),
                        ),
                      )
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Choisir des fichiers'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  disabledBackgroundColor: Colors.grey[300],
                ),
              ),
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

  void _showEditAppointmentDialog() {
    final patientNameController = TextEditingController(
      text: appointment.patientName,
    );
    final procedureController = TextEditingController(
      text: appointment.procedure,
    );
    final notesController = TextEditingController(text: appointment.notes);
    String selectedStatus = appointment.status;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Modifier le rendez-vous',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDialogTextField(
                    'Nom du patient',
                    patientNameController,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField('Intervention', procedureController),
                  const SizedBox(height: 16),
                  const Text(
                    'Statut',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    items: ['confirmed', 'pending', 'cancelled', 'completed']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedStatus = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ajouter des notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          appointment = Appointment(
                            id: appointment.id,
                            patientId: appointment.patientId,
                            patientName: patientNameController.text,
                            procedure: procedureController.text,
                            time: appointment.time,
                            duration: appointment.duration,
                            status: selectedStatus,
                            cardColor: appointment.cardColor,
                            appointmentDate: appointment.appointmentDate,
                            notes: notesController.text,
                            files: appointment.files,
                            remarks: appointment.remarks,
                            payments: appointment.payments,
                            totalCost: appointment.totalCost,
                          );
                          setState(() {});
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rendez-vous mis à jour!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildPrescriptionsTab() {
    if (isLoadingPrescriptions) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ordonnances',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddPrescriptionDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter Ordonnance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (prescriptions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 100),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune ordonnance disponible',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cliquez sur "Ajouter Ordonnance" pour commencer',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          )
        else
          _buildPrescriptionsList(),
      ],
    );
  }

  Widget _buildPrescriptionsList() {

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        final date = prescription['issued_at'] != null
            ? DateFormat('d MMMM yyyy').format(DateTime.parse(prescription['issued_at']))
            : '';
        final items = (prescription['items'] as List<dynamic>?) ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RX-${prescription['id']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _viewPrescriptionPDF(prescription),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Voir PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChipSmall(
                      Icons.person,
                      'Médecin',
                      prescription['doctor'] ?? 'Inconnu',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChipSmall(
                      Icons.medication,
                      'Médicaments',
                      '${items.length}',
                    ),
                  ),
                ],
              ),
              if (prescription['notes'] != null && prescription['notes'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diagnostic',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prescription['notes'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (items.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Médicaments prescrits',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                ...items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$idx. ${item['medication_name'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dosage: ${item['dosage'] ?? ''} • Voie: ${_getRouteLabel(item['route'] ?? 'oral')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fréquence: ${item['frequency'] ?? ''} • Durée: ${item['duration'] ?? ''}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (item['instructions'] != null &&
                            item['instructions'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Instructions: ${item['instructions']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChipSmall(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _viewPrescriptionPDF(Map<String, dynamic> prescription) async {
    try {
      final pdfData = await _generatePrescriptionPDFData(prescription);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ordonnance PDF',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Printing.layoutPdf(
                                onLayout: (format) async => pdfData,
                              );
                            },
                            icon: const Icon(Icons.print, size: 18),
                            label: const Text('Imprimer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PdfPreview(
                    build: (format) async => pdfData,
                    allowPrinting: true,
                    allowSharing: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error viewing PDF: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'affichage du PDF: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  String _getRouteLabelForPDF(String route) {
    switch (route) {
      case 'oral':
        return 'Oral (par la bouche)';
      case 'topical':
        return 'Topique (local)';
      case 'sublingual':
        return 'Sublingual (sous la langue)';
      case 'injection':
        return 'Injection';
      case 'intravenous':
        return 'Intraveineux (IV)';
      case 'intramuscular':
        return 'Intramusculaire (IM)';
      case 'buccal':
        return 'Buccal (joue)';
      case 'gargle':
        return 'Gargarisme';
      default:
        return route;
    }
  }

  Future<Uint8List> _generatePrescriptionPDFData(Map<String, dynamic> prescription) async {
    final pdf = pw.Document();
    final clinicInfo = ClinicInfo.defaultValues();
    
    final items = (prescription['items'] as List<dynamic>?) ?? [];
    final date = prescription['issued_at'] != null
        ? DateFormat('d MMMM yyyy').format(DateTime.parse(prescription['issued_at']))
        : DateFormat('d MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with clinic info
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      clinicInfo.clinicName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Tél: ${clinicInfo.phone}',
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              'Email: ${clinicInfo.email}',
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              'Adresse: ${clinicInfo.address}',
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue200,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            date,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Ordonnance title
              pw.Center(
                child: pw.Text(
                  'ORDONNANCE MÉDICALE',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'N° RX-${prescription['id']}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Patient and Doctor Info
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Patient(e):',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                appointment.patientName,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 20),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Médecin:',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey700,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                prescription['doctor'] ?? 'Dr. ${appointment.doctorName}',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (prescription['notes'] != null &&
                        prescription['notes'].toString().isNotEmpty) ...[
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Diagnostic:',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        prescription['notes'],
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Medications section
              pw.Text(
                'MÉDICAMENTS PRESCRITS',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 16),
              
              ...items.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value as Map<String, dynamic>;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.blue200, width: 1),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$idx. ${item['medication_name'] ?? ''}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Dosage:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                                pw.Text(
                                  item['dosage'] ?? '',
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Fréquence:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                                pw.Text(
                                  item['frequency'] ?? '',
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 12),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Durée:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                                pw.Text(
                                  item['duration'] ?? '',
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Voie:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                                pw.Text(
                                  _getRouteLabelForPDF(item['route'] ?? 'oral'),
                                  style: const pw.TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          pw.Expanded(flex: 2, child: pw.SizedBox()),
                        ],
                      ),
                      if (item['instructions'] != null &&
                          item['instructions'].toString().isNotEmpty) ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Instructions:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          item['instructions'],
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey800,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Généré le: ${DateFormat('d MMMM yyyy à HH:mm').format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Signature et cachet du médecin',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  void _showAddPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPrescriptionDialog(
        patientId: appointment.patientId!,
        patientName: appointment.patientName,
        appointmentId: appointment.id,
        onPrescriptionAdded: () {
          _loadPrescriptions();
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getRouteLabel(String route) {
    switch (route) {
      case 'oral':
        return 'Oral';
      case 'topical':
        return 'Topique';
      case 'sublingual':
        return 'Sublingual';
      case 'injection':
        return 'Injection';
      case 'intravenous':
        return 'IV';
      case 'intramuscular':
        return 'IM';
      case 'buccal':
        return 'Buccal';
      case 'gargle':
        return 'Gargarisme';
      default:
        return route;
    }
  }
}

// Dialog for adding new prescriptions
class AddPrescriptionDialog extends StatefulWidget {
  final int patientId;
  final String patientName;
  final String appointmentId;
  final VoidCallback onPrescriptionAdded;

  const AddPrescriptionDialog({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.appointmentId,
    required this.onPrescriptionAdded,
  });

  @override
  State<AddPrescriptionDialog> createState() => _AddPrescriptionDialogState();
}

class _AddPrescriptionDialogState extends State<AddPrescriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosticController = TextEditingController();
  final List<Map<String, dynamic>> _medications = [];
  List<Map<String, dynamic>> _availableMedications = [];
  bool _isSaving = false;
  bool _isLoadingMedications = true;

  final List<Map<String, String>> _routeOptions = const [
    {'value': 'oral', 'label': 'Oral (par la bouche)'},
    {'value': 'topical', 'label': 'Topique (local)'},
    {'value': 'sublingual', 'label': 'Sublingual (sous la langue)'},
    {'value': 'injection', 'label': 'Injection'},
    {'value': 'intravenous', 'label': 'Intraveineux (IV)'},
    {'value': 'intramuscular', 'label': 'Intramusculaire (IM)'},
    {'value': 'buccal', 'label': 'Buccal (joue)'},
    {'value': 'gargle', 'label': 'Gargarisme'},
  ];

  String _getRouteLabelForField(String routeValue) {
    final route = _routeOptions.firstWhere(
      (r) => r['value'] == routeValue,
      orElse: () => {'value': 'oral', 'label': 'Oral (par la bouche)'},
    );
    return route['label']!;
  }

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _addMedication();
  }

  Future<void> _loadMedications() async {
    try {
      final response = await Supabase.instance.client
          .from('medications')
          .select('*')
          .order('name');
      
      setState(() {
        _availableMedications = List<Map<String, dynamic>>.from(response);
        _isLoadingMedications = false;
      });
      debugPrint('📋 Loaded ${_availableMedications.length} medications from database');
    } catch (e) {
      debugPrint('❌ Error loading medications: $e');
      setState(() => _isLoadingMedications = false);
    }
  }

  @override
  void dispose() {
    _diagnosticController.dispose();
    for (var med in _medications) {
      (med['nameController'] as TextEditingController?)?.dispose();
      (med['dosageController'] as TextEditingController?)?.dispose();
      (med['durationController'] as TextEditingController?)?.dispose();
      (med['frequencyController'] as TextEditingController?)?.dispose();
      (med['instructionsController'] as TextEditingController?)?.dispose();
      (med['routeController'] as TextEditingController?)?.dispose();
    }
    super.dispose();
  }

  void _addMedication() {
    setState(() {
      _medications.add({
        'medicationId': null,
        'nameController': TextEditingController(),
        'dosageController': TextEditingController(),
        'durationController': TextEditingController(),
        'frequencyController': TextEditingController(),
        'instructionsController': TextEditingController(),
        'routeController': TextEditingController(text: 'Oral (par la bouche)'),
        'form': '',
        'route': 'oral',
      });
    });
  }

  void _removeMedication(int index) {
    if (_medications.length > 1) {
      setState(() {
        (_medications[index]['nameController'] as TextEditingController?)?.dispose();
        (_medications[index]['dosageController'] as TextEditingController?)?.dispose();
        (_medications[index]['durationController'] as TextEditingController?)?.dispose();
        (_medications[index]['frequencyController'] as TextEditingController?)?.dispose();
        (_medications[index]['instructionsController'] as TextEditingController?)?.dispose();
        (_medications[index]['routeController'] as TextEditingController?)?.dispose();
        _medications.removeAt(index);
      });
    }
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      debugPrint('💊 Saving prescription for patient: ${widget.patientId}');
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'Utilisateur non connecté';

      debugPrint('👤 Current user email: ${user.email}');
      
      // Get doctor ID from users table using email
      final userResp = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('email', user.email!)
          .maybeSingle();

      if (userResp == null) {
        debugPrint('❌ User not found in users table for email: ${user.email}');
        throw 'Utilisateur introuvable dans la base de données';
      }

      final doctorId = userResp['id'] as int;
      debugPrint('✅ Doctor ID: $doctorId');

      // Insert prescription with correct field names
      debugPrint('📝 Inserting prescription...');
      final prescriptionResp = await Supabase.instance.client
          .from('prescriptions')
          .insert({
            'patient_id': widget.patientId,
            'doctor_id': doctorId,
            'appointment_id': int.parse(widget.appointmentId),
            'issued_at': DateTime.now().toIso8601String(),
            'notes': _diagnosticController.text,
          })
          .select()
          .single();

      debugPrint('✅ Prescription created with ID: ${prescriptionResp['id']}');

      final prescriptionId = prescriptionResp['id'] as int;

      // Insert prescription items
      debugPrint('💊 Inserting ${_medications.length} medications...');
      for (var med in _medications) {
        final nameController = med['nameController'] as TextEditingController;
        if (nameController.text.isNotEmpty) {
          int? medicationId = med['medicationId'];
          
          // If no medication ID, create new medication in database
          if (medicationId == null) {
            debugPrint('  🆕 Creating new medication: ${nameController.text}');
            final newMedResp = await Supabase.instance.client
                .from('medications')
                .insert({
                  'name': nameController.text,
                  'form': med['form'] ?? '',
                  'strength': (med['dosageController'] as TextEditingController).text,
                  'default_route': med['route'] ?? 'oral',
                  'default_instructions': (med['instructionsController'] as TextEditingController).text,
                  'created_at': DateTime.now().toIso8601String(),
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .select()
                .single();
            medicationId = newMedResp['id'] as int;
            debugPrint('  ✅ New medication created with ID: $medicationId');
          }
          
          await Supabase.instance.client.from('prescription_items').insert({
            'prescription_id': prescriptionId,
            'medication_id': medicationId,
            'medication_name': nameController.text,
            'dosage': (med['dosageController'] as TextEditingController).text,
            'route': med['route'] ?? 'oral',
            'frequency': (med['frequencyController'] as TextEditingController).text,
            'duration': (med['durationController'] as TextEditingController).text,
            'instructions': (med['instructionsController'] as TextEditingController).text,
          });
          debugPrint('  ✓ Added: ${nameController.text}');
        }
      }
      
      debugPrint('✅ All prescription items saved successfully');
      debugPrint('🔄 Reloading prescriptions...');

      if (!mounted) return;
      
      Navigator.pop(context);
      widget.onPrescriptionAdded();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Ordonnance créée avec succès!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      debugPrint('Error saving prescription: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nouvelle Ordonnance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Patient: ${widget.patientName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Diagnostic',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _diagnosticController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Description du diagnostic...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Médicaments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addMedication,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Ajouter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._medications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final med = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Médicament ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_medications.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Color(0xFFEF4444)),
                                      onPressed: () => _removeMedication(index),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Autocomplete<Map<String, dynamic>>(
                                displayStringForOption: (option) => option['name'],
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<Map<String, dynamic>>.empty();
                                  }
                                  return _availableMedications.where((medication) {
                                    return medication['name']
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase());
                                  });
                                },
                                onSelected: (Map<String, dynamic> selection) {
                                  setState(() {
                                    med['medicationId'] = selection['id'];
                                    (med['nameController'] as TextEditingController).text = selection['name'];
                                    med['form'] = selection['form'] ?? '';
                                    med['route'] = selection['default_route'] ?? 'oral';
                                    // Set route controller text with label
                                    (med['routeController'] as TextEditingController).text = _getRouteLabelForField(selection['default_route'] ?? 'oral');
                                    if (selection['strength'] != null && selection['strength'].toString().isNotEmpty) {
                                      (med['dosageController'] as TextEditingController).text = selection['strength'];
                                    }
                                    if (selection['default_instructions'] != null && 
                                        selection['default_instructions'].toString().isNotEmpty) {
                                      (med['instructionsController'] as TextEditingController).text = 
                                          selection['default_instructions'];
                                    }
                                  });
                                  debugPrint('✅ Selected medication: ${selection['name']} (ID: ${selection['id']})');
                                },
                                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                  // Sync with our controller
                                  if (controller.text.isEmpty && 
                                      (med['nameController'] as TextEditingController).text.isNotEmpty) {
                                    controller.text = (med['nameController'] as TextEditingController).text;
                                  }
                                  
                                  return TextFormField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Nom du médicament *',
                                      hintText: 'Rechercher ou ajouter...',
                                      prefixIcon: const Icon(Icons.search, size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      (med['nameController'] as TextEditingController).text = value;
                                      // Reset medication ID if text changes
                                      if (med['medicationId'] != null) {
                                        setState(() => med['medicationId'] = null);
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Requis';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: med['dosageController'],
                                      decoration: InputDecoration(
                                        labelText: 'Dosage *',
                                        hintText: 'Ex: 500mg',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        isDense: true,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Requis';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: med['frequencyController'],
                                      decoration: InputDecoration(
                                        labelText: 'Fréquence *',
                                        hintText: 'Ex: 3x/jour',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        isDense: true,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Requis';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: med['durationController'],
                                decoration: InputDecoration(
                                  labelText: 'Durée *',
                                  hintText: 'Ex: 7 jours, 2 semaines',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requis';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Autocomplete<Map<String, String>>(
                                displayStringForOption: (option) => option['label']!,
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return _routeOptions;
                                  }
                                  return _routeOptions.where((route) {
                                    return route['label']!
                                        .toLowerCase()
                                        .contains(textEditingValue.text.toLowerCase());
                                  });
                                },
                                onSelected: (Map<String, String> selection) {
                                  setState(() {
                                    med['route'] = selection['value']!;
                                    (med['routeController'] as TextEditingController).text = selection['label']!;
                                  });
                                },
                                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                                  // Sync with our controller
                                  if (controller.text.isEmpty && 
                                      (med['routeController'] as TextEditingController).text.isNotEmpty) {
                                    controller.text = (med['routeController'] as TextEditingController).text;
                                  }
                                  
                                  return TextFormField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Voie d\'administration *',
                                      hintText: 'Rechercher...',
                                      prefixIcon: const Icon(Icons.route, size: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      (med['routeController'] as TextEditingController).text = value;
                                      // Find matching route value
                                      final matchingRoute = _routeOptions.firstWhere(
                                        (route) => route['label'] == value,
                                        orElse: () => {'value': 'oral', 'label': 'Oral (par la bouche)'},
                                      );
                                      setState(() => med['route'] = matchingRoute['value']!);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Requis';
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: med['instructionsController'],
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'Instructions',
                                  hintText: 'Ex: Prendre après les repas',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _savePrescription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

