import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/appointment_bloc.dart';
import '../utils/appointment_utils.dart';
import '../models/appointment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../patients/models/patient.dart';
import '../../../billing/models/treatment.dart';

class ScheduleAppointmentDialog extends StatefulWidget {
  const ScheduleAppointmentDialog({super.key});

  @override
  State<ScheduleAppointmentDialog> createState() =>
      _ScheduleAppointmentDialogState();
}

class _ScheduleAppointmentDialogState extends State<ScheduleAppointmentDialog> {
  Patient? selectedPatient;
  int? selectedDoctorId;
  String selectedDoctorName = 'Unknown Doctor';
  Treatment? selectedTreatment;
  DateTime? selectedDate;
  String? selectedTime;
  String customTime = '';
  int selectedDuration = 60; // default 1h
  String notes = '';
  bool isSubmitting = false;
  String? errorMessage;

  List<Patient> patients = [];
  List<Map<String, dynamic>> doctors = []; // id, first_name, last_name
  List<Treatment> treatments = [];

  bool loadingPatients = true;
  bool loadingDoctors = true;
  bool loadingTreatments = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _fetchDoctors();
    _fetchTreatments();
  }

  Future<void> _fetchPatients() async {
    setState(() => loadingPatients = true);
    try {
      final resp = await Supabase.instance.client.from('patients').select();
      setState(() {
        patients = (resp as List<dynamic>)
            .map((e) => Patient.fromJson(e as Map<String, dynamic>))
            .toList();
        loadingPatients = false;
      });
    } catch (e) {
      debugPrint('Error fetching patients: $e');
      setState(() {
        loadingPatients = false;
        errorMessage = 'Failed to load patients';
      });
    }
  }

  Future<void> _fetchDoctors() async {
    setState(() => loadingDoctors = true);
    try {
      final resp = await Supabase.instance.client
          .from('users')
          .select('id, first_name, last_name')
          .eq('role', 'doctor')
          .order('first_name');

      setState(() {
        doctors = List<Map<String, dynamic>>.from(resp);
        loadingDoctors = false;
      });
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
      setState(() {
        loadingDoctors = false;
        errorMessage = 'Failed to load doctors';
      });
    }
  }

  Future<void> _fetchTreatments() async {
    setState(() => loadingTreatments = true);
    try {
      final resp = await Supabase.instance.client.from('treatments').select();
      setState(() {
        treatments = (resp as List<dynamic>)
            .map((e) => Treatment.fromJson(e as Map<String, dynamic>))
            .toList();
        loadingTreatments = false;
      });
    } catch (e) {
      debugPrint('Error fetching treatments: $e');
      setState(() {
        loadingTreatments = false;
        errorMessage = 'Failed to load treatments';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentOperationFailure) {
          setState(() {
            isSubmitting = false;
            errorMessage = state.error;
          });
        } else if (state is AppointmentLoadSuccess && isSubmitting) {
          setState(() {
            isSubmitting = false;
            errorMessage = null;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment scheduled successfully!'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule New Appointment',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Doctor + Patient
                  Row(
                    children: [
                      Expanded(child: _buildDoctorDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPatientAutocomplete()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Treatment + Duration
                  Row(
                    children: [
                      Expanded(child: _buildTreatmentDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDurationDropdown()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date + Time
                  Row(
                    children: [
                      Expanded(child: _buildDateField()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTimeInput()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildNotesField(),
                  const SizedBox(height: 32),

                  if (errorMessage != null)
                    Text(errorMessage!, style: const TextStyle(color: Colors.red)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isSubmitting ? null : _submitAppointment,
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Schedule Appointment'),
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

  void _submitAppointment() {
    setState(() => errorMessage = null);

    if (selectedPatient == null ||
        selectedDoctorId == null ||
        selectedTreatment == null ||
        selectedDate == null ||
        (selectedTime == null && customTime.isEmpty)) {
      setState(() => errorMessage = 'Please fill all required fields');
      return;
    }

    final String finalTime = customTime.isNotEmpty && RegExp(r'^\d{2}:\d{2}$').hasMatch(customTime)
        ? customTime
        : selectedTime ?? '09:00';

    setState(() => isSubmitting = true);

    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: selectedPatient!.id,
      patientName: selectedPatient!.fullName,
      doctorId: selectedDoctorId,
      doctorName: selectedDoctorName,
      procedure: selectedTreatment!.name ?? '',
      time: finalTime,
      duration: selectedDuration,
      status: 'pending',
      cardColor: AppointmentUtils.getTreatmentColor(selectedTreatment!.name ?? ''),
      appointmentDate: selectedDate!,
      notes: notes,
      totalCost: selectedTreatment!.basePrice ?? 0.0,
    );

    context.read<AppointmentBloc>().add(AddAppointment(appointment));
  }

  Widget _buildDoctorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Doctor'),
        const SizedBox(height: 8),
        if (loadingDoctors)
          const Center(child: CircularProgressIndicator())
        else if (doctors.isEmpty)
          const Text('No doctors available', style: TextStyle(color: Colors.red))
        else
          DropdownButtonFormField<int>(
            value: selectedDoctorId,
            hint: const Text('Select doctor'),
            items: doctors.map((doc) {
              final name = '${doc['first_name'] ?? ''} ${doc['last_name'] ?? ''}'.trim();
              return DropdownMenuItem<int>(
                value: doc['id'] as int,
                child: Text(name.isEmpty ? 'No name' : name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDoctorId = value;
                selectedDoctorName = doctors
                    .firstWhere((d) => d['id'] == value)
                    ['first_name'] + ' ' + doctors.firstWhere((d) => d['id'] == value)['last_name'];
              });
            },
          ),
      ],
    );
  }

  Widget _buildPatientAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Patient'),
        const SizedBox(height: 8),
        if (loadingPatients)
          const Center(child: CircularProgressIndicator())
        else
          Autocomplete<Patient>(
            displayStringForOption: (p) => p.fullName,
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<Patient>.empty();
              return patients.where((p) => p.fullName.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (patient) => setState(() => selectedPatient = patient),
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) => TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(hintText: 'Type patient name'),
            ),
          ),
      ],
    );
  }

  Widget _buildTreatmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Treatment Type'),
        const SizedBox(height: 8),
        loadingTreatments
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<Treatment>(
                value: selectedTreatment,
                hint: const Text('Select treatment'),
                items: treatments.map((t) => DropdownMenuItem(
                      value: t,
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: AppointmentUtils.getTreatmentColor(t.name ?? ''), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(t.name ?? ''),
                        ],
                      ),
                    )).toList(),
                onChanged: (value) => setState(() => selectedTreatment = value),
              ),
      ],
    );
  }

  Widget _buildDurationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Duration'),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedDuration,
          items: const [
            DropdownMenuItem(value: 15, child: Text('15 min')),
            DropdownMenuItem(value: 30, child: Text('30 min')),
            DropdownMenuItem(value: 60, child: Text('1 hour')),
            DropdownMenuItem(value: 90, child: Text('1.5 hours')),
            DropdownMenuItem(value: 120, child: Text('2 hours')),
            DropdownMenuItem(value: 150, child: Text('2.5 hours')),
            DropdownMenuItem(value: 180, child: Text('3 hours')),
          ],
          onChanged: (value) => setState(() => selectedDuration = value ?? 60),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => selectedDate = picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(hintText: 'Select date'),
            child: Text(selectedDate == null ? '' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Time'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedTime,
          hint: const Text('Select time slot'),
          items: List.generate(12, (i) {
            final hour = 8 + i;
            final timeStr = '${hour.toString().padLeft(2, '0')}:00';
            return DropdownMenuItem(value: timeStr, child: Text(timeStr));
          }),
          onChanged: (value) => setState(() => selectedTime = value),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(hintText: 'Or type time (e.g. 14:30)'),
          onChanged: (value) {
            customTime = value.trim();
          },
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notes'),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Add any special notes...'),
          onChanged: (value) => notes = value,
        ),
      ],
    );
  }
}