import 'package:flutter/material.dart';
import '../models/appointment_model.dart';

class DuringAppointmentTab extends StatefulWidget {
  final bool isAppointmentStarted;
  final bool isAppointmentCompleted;
  final Appointment appointment;
  final Function(Appointment) onSave;

  const DuringAppointmentTab({
    super.key,
    required this.isAppointmentStarted,
    required this.isAppointmentCompleted,
    required this.appointment,
    required this.onSave,
  });

  @override
  State<DuringAppointmentTab> createState() => _DuringAppointmentTabState();
}

class _DuringAppointmentTabState extends State<DuringAppointmentTab> {
  final TextEditingController _complaintsController = TextEditingController();
  final TextEditingController _findingsController = TextEditingController();
  final TextEditingController _treatmentDoneController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<String> selectedTeeth = [];

  @override
  void initState() {
    super.initState();
    // Load existing data from appointment
    _complaintsController.text = widget.appointment.patientComplaints ?? '';
    _findingsController.text = widget.appointment.clinicalFindings ?? '';
    _treatmentDoneController.text = widget.appointment.treatmentPerformed ?? '';
    _notesController.text = widget.appointment.notes;

    // Load selected teeth
    if (widget.appointment.teethTreated != null &&
        widget.appointment.teethTreated!.isNotEmpty) {
      selectedTeeth = widget.appointment.teethTreated!
          .split(',')
          .map((e) => e.trim())
          .toList();
    }
  }

  @override
  void dispose() {
    _complaintsController.dispose();
    _findingsController.dispose();
    _treatmentDoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isAppointmentCompleted
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : widget.isAppointmentStarted
            ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isAppointmentCompleted
              ? const Color(0xFF10B981)
              : widget.isAppointmentStarted
              ? const Color(0xFF3B82F6)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.isAppointmentCompleted
                ? Icons.check_circle
                : widget.isAppointmentStarted
                ? Icons.timer
                : Icons.info_outline,
            color: widget.isAppointmentCompleted
                ? const Color(0xFF10B981)
                : widget.isAppointmentStarted
                ? const Color(0xFF3B82F6)
                : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isAppointmentCompleted
                  ? '✓ Rendez-vous terminé'
                  : widget.isAppointmentStarted
                  ? 'Rendez-vous en cours - Enregistrez les informations cliniques'
                  : 'Démarrez le rendez-vous pour enregistrer les détails',
              style: TextStyle(
                fontSize: 13,
                color: widget.isAppointmentCompleted
                    ? const Color(0xFF10B981)
                    : widget.isAppointmentStarted
                    ? const Color(0xFF3B82F6)
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 3,
  }) {
    return TextField(
      controller: controller,
      enabled: widget.isAppointmentStarted && !widget.isAppointmentCompleted,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
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
        fillColor:
            (widget.isAppointmentStarted && !widget.isAppointmentCompleted)
            ? Colors.white
            : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  Widget _buildToothSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (widget.isAppointmentStarted && !widget.isAppointmentCompleted)
            ? Colors.grey[50]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sélectionnez les dents traitées',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),

          // Upper Teeth (1-16)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Maxillaire supérieur',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(16, (index) {
              final toothNumber = index + 1;
              return _buildTooth(toothNumber);
            }),
          ),
          const SizedBox(height: 24),

          // Lower Teeth (17-32)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(16, (index) {
              final toothNumber = index + 17;
              return _buildTooth(toothNumber);
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Maxillaire inférieur',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (selectedTeeth.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sélectionnées: ${selectedTeeth.join(", ")}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTooth(int toothNumber) {
    final isSelected = selectedTeeth.contains(toothNumber.toString());
    return GestureDetector(
      onTap: (widget.isAppointmentStarted && !widget.isAppointmentCompleted)
          ? () {
              setState(() {
                if (isSelected) {
                  selectedTeeth.remove(toothNumber.toString());
                } else {
                  selectedTeeth.add(toothNumber.toString());
                }
              });
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            // Tooth shape
            Container(
              width: 28,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                toothNumber.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),

          // Patient Complaints
          _buildSectionTitle('Plaintes du patient', Icons.record_voice_over),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _complaintsController,
            hint: 'Notez les plaintes et symptômes du patient...',
          ),
          const SizedBox(height: 24),

          // Clinical Findings
          _buildSectionTitle('Observations cliniques', Icons.search),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _findingsController,
            hint: 'Décrivez les observations cliniques et le diagnostic...',
          ),
          const SizedBox(height: 24),

          // Teeth Selector
          _buildSectionTitle('Dents concernées', Icons.grid_on),
          const SizedBox(height: 12),
          _buildToothSelector(),
          const SizedBox(height: 24),

          // Treatment Done
          _buildSectionTitle('Traitement effectué', Icons.medical_services),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _treatmentDoneController,
            hint: 'Décrivez le traitement effectué pendant la visite...',
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          // Additional Notes
          _buildSectionTitle('Notes supplémentaires', Icons.notes),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _notesController,
            hint: 'Ajoutez des notes supplémentaires, recommandations, etc...',
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Save Button
          if (widget.isAppointmentStarted && !widget.isAppointmentCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final updatedAppointment = widget.appointment.copyWith(
                    patientComplaints: _complaintsController.text,
                    clinicalFindings: _findingsController.text,
                    teethTreated: selectedTeeth.join(', '),
                    treatmentPerformed: _treatmentDoneController.text,
                    notes: _notesController.text,
                  );
                  widget.onSave(updatedAppointment);
                },
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer les informations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
