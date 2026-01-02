import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/appointment_bloc.dart';
import '../utils/appointment_utils.dart';
import '../models/appointment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../patients/models/patient.dart';
import '../../../billing/models/treatment.dart';

class ScheduleAppointmentDialog extends StatefulWidget {
  final int? preselectedDoctorId;
  final Patient? preselectedPatient;

  const ScheduleAppointmentDialog({
    super.key,
    this.preselectedDoctorId,
    this.preselectedPatient,
  });

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
  int selectedDuration = 60;
  String notes = '';
  bool isSubmitting = false;
  String? errorMessage;

  List<Patient> patients = [];
  List<Map<String, dynamic>> doctors = [];
  List<Treatment> treatments = [];

  List<String> takenTimes = [];
  bool loadingTakenTimes = false;

  bool loadingPatients = true;
  bool loadingDoctors = true;
  bool loadingTreatments = true;

  @override
  void initState() {
    super.initState();
    // apply preselected patient if any
    if (widget.preselectedPatient != null) {
      selectedPatient = widget.preselectedPatient;
    }

    _fetchPatients();
    _fetchDoctors();
    _fetchTreatments();

    if (widget.preselectedDoctorId != null) {
      selectedDoctorId = widget.preselectedDoctorId;
    }
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

        // If a preselected patient was provided, try to normalize it to the fetched list
        if (widget.preselectedPatient != null) {
          final pref = widget.preselectedPatient!;
          final matched = patients.firstWhere(
            (p) => p.id == pref.id,
            orElse: () => pref,
          );
          selectedPatient = matched;
        }
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

      final List<Map<String, dynamic>> fetchedDoctors =
          List<Map<String, dynamic>>.from(resp);

      setState(() {
        doctors = fetchedDoctors;
        loadingDoctors = false;

        if (widget.preselectedDoctorId != null && doctors.isNotEmpty) {
          final doctor = doctors.firstWhere(
            (d) => d['id'] == widget.preselectedDoctorId,
            orElse: () => {'first_name': '', 'last_name': 'Inconnu'},
          );
          selectedDoctorName = '${doctor['first_name']} ${doctor['last_name']}'
              .trim();
          if (selectedDoctorName.isEmpty) {
            selectedDoctorName = 'Médecin inconnu';
          }
        }
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

  Future<void> _loadTakenTimes() async {
    if (selectedDoctorId == null ||
        selectedPatient == null ||
        selectedDate == null) {
      setState(() => takenTimes = []);
      return;
    }

    setState(() => loadingTakenTimes = true);

    try {
      final String dayStart =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}T00:00:00';
      final String dayEnd =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${(selectedDate!.day + 1).toString().padLeft(2, '0')}T00:00:00';

      final resp = await Supabase.instance.client
          .from('appointments')
          .select('start_datetime')
          .gte('start_datetime', dayStart)
          .lt('start_datetime', dayEnd)
          .or(
            'doctor_id.eq.$selectedDoctorId,patient_id.eq.${selectedPatient!.id}',
          );

      final List<String> times = (resp as List<dynamic>)
          .map((e) => (e['start_datetime'] as String).substring(11, 16))
          .toList();

      setState(() {
        takenTimes = times;
        loadingTakenTimes = false;
      });
    } catch (e) {
      debugPrint('Error loading taken times: $e');
      setState(() {
        takenTimes = [];
        loadingTakenTimes = false;
      });
    }
  }

  String _suggestNextFreeSlot(String attemptedTime) {
    final parts = attemptedTime.split(':');
    if (parts.length != 2) return '09:00';

    int attemptedHour = int.tryParse(parts[0]) ?? 8;
    int attemptedMinute = int.tryParse(parts[1]) ?? 0;

    DateTime attemptedStart = DateTime(
      2020,
      1,
      1,
      attemptedHour,
      attemptedMinute,
    );
    DateTime latestEndTime = attemptedStart;

    for (String takenTimeStr in takenTimes) {
      final tParts = takenTimeStr.split(':');
      int takenHour = int.tryParse(tParts[0]) ?? 0;
      int takenMinute = int.tryParse(tParts[1]) ?? 0;

      DateTime takenStart = DateTime(2020, 1, 1, takenHour, takenMinute);
      DateTime takenEnd = takenStart.add(const Duration(minutes: 60));

      if (takenStart.isBefore(latestEndTime.add(const Duration(minutes: 1))) ||
          takenStart.isAtSameMomentAs(latestEndTime)) {
        if (takenEnd.isAfter(latestEndTime)) {
          latestEndTime = takenEnd;
        }
      }
    }

    String nextHour = latestEndTime.hour.toString().padLeft(2, '0');
    String nextMinute = latestEndTime.minute.toString().padLeft(2, '0');

    if (latestEndTime.hour >= 18) {
      return 'tomorrow (08:00)';
    }

    return '$nextHour:$nextMinute';
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
              content: Text('Rendez-vous planifié avec succès !'),
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
                    'Planifier un nouveau rendez-vous',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      if (widget.preselectedDoctorId == null)
                        Expanded(child: _buildDoctorDropdown()),
                      if (widget.preselectedDoctorId == null)
                        const SizedBox(width: 16),
                      Expanded(child: _buildPatientAutocomplete()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: _buildTreatmentDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDurationDropdown()),
                    ],
                  ),
                  const SizedBox(height: 16),

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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isSubmitting ? null : _submitAppointment,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Planifier le rendez-vous'),
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

  void _submitAppointment() async {
    setState(() => errorMessage = null);

    if (selectedPatient == null ||
        selectedDoctorId == null ||
        selectedTreatment == null ||
        selectedDate == null ||
        (selectedTime == null && customTime.isEmpty)) {
      setState(
        () => errorMessage = 'Veuillez remplir tous les champs obligatoires',
      );
      return;
    }

    final String finalTime =
        customTime.isNotEmpty && RegExp(r'^\d{2}:\d{2}$').hasMatch(customTime)
        ? customTime
        : selectedTime ?? '09:00';

    await _loadTakenTimes();

    if (takenTimes.contains(finalTime)) {
      final nextSlot = _suggestNextFreeSlot(finalTime);
      setState(() {
        errorMessage =
            'Ce créneau horaire est déjà réservé.\n'
            'Le patient ou le médecin a un autre rendez-vous.\n'
            'Prochain créneau disponible : $nextSlot';
      });
      return;
    }

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
      cardColor: AppointmentUtils.getTreatmentColor(
        selectedTreatment!.name ?? '',
      ),
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
        const Text('Médecin', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (loadingDoctors)
          const Center(child: CircularProgressIndicator())
        else if (doctors.isEmpty)
          const Text(
            'Aucun médecin disponible',
            style: TextStyle(color: Colors.red),
          )
        else
          DropdownButtonFormField<int?>(
            value: selectedDoctorId,
            hint: const Text('Sélectionner un médecin'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: doctors.map((doc) {
              final name =
                  '${doc['first_name'] ?? ''} ${doc['last_name'] ?? ''}'.trim();
              return DropdownMenuItem<int?>(
                value: doc['id'] as int?,
                child: Text(name.isEmpty ? 'No name' : name),
              );
            }).toList(),
            onChanged: (value) async {
              setState(() {
                selectedDoctorId = value;
                selectedDoctorName = value != null
                    ? '${doctors.firstWhere((d) => d['id'] == value)['first_name']} ${doctors.firstWhere((d) => d['id'] == value)['last_name']}'
                    : 'Unknown Doctor';
                takenTimes = [];
              });
              if (value != null && selectedDate != null) {
                await _loadTakenTimes();
              }
            },
          ),
      ],
    );
  }

  Widget _buildPatientAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Patient', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (loadingPatients)
          const Center(child: CircularProgressIndicator())
        else
          Autocomplete<Patient>(
            displayStringForOption: (p) => p.fullName,
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Patient>.empty();
              }
              return patients.where(
                (p) => p.fullName.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            onSelected: (patient) => setState(() => selectedPatient = patient),
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              // If a preselected patient exists, ensure the field shows the name
              if (selectedPatient != null && controller.text.isEmpty) {
                controller.text = selectedPatient!.fullName;
              }

              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Tapez le nom du patient',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTreatmentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de traitement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        loadingTreatments
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<Treatment>(
                value: selectedTreatment,
                hint: const Text('Sélectionner un traitement'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: treatments
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppointmentUtils.getTreatmentColor(
                                  t.name ?? '',
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(t.name ?? ''),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedTreatment = value),
              ),
      ],
    );
  }

  Widget _buildDurationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Durée', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: selectedDuration,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: const [
            DropdownMenuItem(value: 15, child: Text('15 min')),
            DropdownMenuItem(value: 30, child: Text('30 min')),
            DropdownMenuItem(value: 60, child: Text('1 heure')),
            DropdownMenuItem(value: 90, child: Text('1,5 heure')),
            DropdownMenuItem(value: 120, child: Text('2 heures')),
            DropdownMenuItem(value: 150, child: Text('2,5 heures')),
            DropdownMenuItem(value: 180, child: Text('3 heures')),
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
        const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
                takenTimes = [];
              });
              if (selectedDoctorId != null) {
                await _loadTakenTimes();
              }
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Sélectionner une date',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            child: Text(
              selectedDate == null
                  ? 'Sélectionner une date'
                  : DateFormat(
                      'EEEE, MMMM d, yyyy',
                      'fr_FR',
                    ).format(selectedDate!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Heure', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (loadingTakenTimes)
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        DropdownButtonFormField<String>(
          value: selectedTime,
          hint: const Text('Sélectionner un créneau horaire'),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: List.generate(12, (i) {
            final hour = 8 + i;
            final timeStr = '${hour.toString().padLeft(2, '0')}:00';
            final isTaken = takenTimes.contains(timeStr);
            return DropdownMenuItem<String>(
              value: timeStr,
              enabled: !isTaken,
              child: Text(
                timeStr,
                style: TextStyle(color: isTaken ? Colors.grey[400] : null),
              ),
            );
          }),
          onChanged: (value) {
            setState(() {
              selectedTime = value;
              customTime = '';
            });
          },
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Ou saisissez une heure (ex : 14:30)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
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
        const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Ajouter des notes spéciales...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          onChanged: (value) => notes = value,
        ),
      ],
    );
  }
}
