import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/appointment_bloc.dart';
import '../models/appointment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/appointment_overview_tab.dart';
import '../widgets/during_appointment_tab.dart';
import '../widgets/prescriptions_tab.dart';
import '../widgets/documents_tab.dart';
import '../widgets/add_prescription_dialog.dart';

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

  Future<void> _saveClinicalData(Appointment updatedAppointment) async {
    try {
      setState(() {
        appointment = updatedAppointment;
      });
      
      context.read<AppointmentBloc>().add(
        UpdateAppointment(updatedAppointment),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Informations cliniques enregistrées'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    _buildTabButton('Documents', selectedTab == 'Documents'),
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
      return DuringAppointmentTab(
        isAppointmentStarted: isAppointmentStarted,
        isAppointmentCompleted: isAppointmentCompleted,
        appointment: appointment,
        onSave: _saveClinicalData,
      );
    } else if (selectedTab == 'Ordonnances') {
      return PrescriptionsTab(
        isLoadingPrescriptions: isLoadingPrescriptions,
        prescriptions: prescriptions,
        appointment: appointment,
        onAddPrescription: _showAddPrescriptionDialog,
      );
    } else if (selectedTab == 'Documents') {
      return DocumentsTab(appointment: appointment);
    }
    return AppointmentOverviewTab(
      appointment: appointment,
      isAppointmentCompleted: isAppointmentCompleted,
    ); // Default to Aperçu
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'pending':
        return Colors.orange;
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPrescriptionDialog(
          patientId: appointment.patientId!,
          patientName: appointment.patientName,
          appointmentId: appointment.id,
          onPrescriptionAdded: () {
            _loadPrescriptions();
          },
        );
      },
    );
  }
}
