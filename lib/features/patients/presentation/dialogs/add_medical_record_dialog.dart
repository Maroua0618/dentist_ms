import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../patients/models/patient.dart';
import '../../../billing/models/treatment.dart';

class AddMedicalRecordDialog extends StatefulWidget {
  final Patient preselectedPatient;

  const AddMedicalRecordDialog({super.key, required this.preselectedPatient});

  @override
  State<AddMedicalRecordDialog> createState() => _AddMedicalRecordDialogState();
}

class _AddMedicalRecordDialogState extends State<AddMedicalRecordDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<Treatment> treatments = [];
  List<Map<String, dynamic>> doctors = [];

  // Form state
  String recordType = 'Procedure';
  final List<String> recordTypes = ['Procedure', 'Prescription', 'Allergy'];

  // Procedure fields
  Treatment? selectedTreatment;
  int? selectedDoctorId;
  String selectedDoctorName = 'Unknown Doctor';
  DateTime selectedDate = DateTime.now();
  String notes = '';
  double? price;
  String status = 'completed';

  // Prescription fields
  List<Map<String, String>> medicationItems = [
    {
      'medication_name': '',
      'dosage': '',
      'duration': '',
      'instructions': '',
    },
  ];
  String prescriptionNotes = '';

  // Allergy fields
  String allergyName = '';
  String allergySeverity = 'Mild';
  final List<String> severities = ['Mild', 'Moderate', 'Severe'];
  String reactionDesc = '';

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final initialIndex = [
      'Procedure',
      'Prescription',
      'Allergy',
    ].indexOf(recordType);
    if (initialIndex >= 0) _tabController.index = initialIndex;
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          recordType = [
            'Procedure',
            'Prescription',
            'Allergy',
          ][_tabController.index];
        });
      }
    });
    _fetchMetadata();
  }

  Future<void> _fetchMetadata() async {
    setState(() => loading = true);
    try {
      final tResp = await Supabase.instance.client.from('treatments').select();
      final dResp = await Supabase.instance.client
          .from('users')
          .select('id, first_name, last_name')
          .eq('role', 'doctor')
          .order('first_name');

      setState(() {
        treatments = (tResp as List<dynamic>)
            .map((e) => Treatment.fromJson(e as Map<String, dynamic>))
            .toList();
        doctors = List<Map<String, dynamic>>.from(dResp);
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Failed to load metadata';
      });
    }
  }

  Future<void> _submit() async {
    setState(() => error = null);

    try {
      if (recordType == 'Procedure') {
        if (selectedTreatment == null) {
          setState(() => error = 'Please select a treatment');
          return;
        }
        final sessionDate = selectedDate.toIso8601String().split('T').first;
        final resp = await Supabase.instance.client
            .from('patient_treatments')
            .insert({
              'patient_id': widget.preselectedPatient.id,
              'treatment_id': selectedTreatment!.id,
              'doctor_id': selectedDoctorId,
              'session_date': sessionDate,
              'status': status,
              'price': price ?? selectedTreatment!.basePrice ?? 0.0,
              'notes': notes,
            })
            .select()
            .single();

        final record = {
          'type': 'procedure',
          'id': resp['id'],
          'title': selectedTreatment!.name ?? 'Procedure',
          'date': sessionDate,
          'desc': notes,
          'doctor': selectedDoctorName,
        };

        if (!mounted) return;
        Navigator.pop(context, record);
        return;
      }

      if (recordType == 'Prescription') {
        // Validate medication items
        final meds = medicationItems
            .where((m) => (m['medication_name'] ?? '').trim().isNotEmpty)
            .toList();
        if (meds.isEmpty) {
          setState(() => error = 'Please add at least one medication');
          return;
        }

        final issuedAt = DateTime.now().toIso8601String();
        final presResp = await Supabase.instance.client
            .from('prescriptions')
            .insert({
              'patient_id': widget.preselectedPatient.id,
              'doctor_id': selectedDoctorId,
              'issued_at': issuedAt,
              'notes': prescriptionNotes,
            })
            .select()
            .single();

        final presId = presResp['id'];

        for (final m in meds) {
          await Supabase.instance.client.from('prescription_items').insert({
            'prescription_id': presId,
            'medication_name': m['medication_name'],
            'dosage': m['dosage'],
            'duration': m['duration'],
            'instructions': m['instructions'],
          });
        }

        final record = {
          'type': 'prescription',
          'id': presId,
          'title': meds.map((m) => m['medication_name']).join(', '),
          'date': issuedAt,
          'desc': prescriptionNotes,
          'doctor': selectedDoctorName,
        };

        if (!mounted) return;
        Navigator.pop(context, record);
        return;
      }

      if (recordType == 'Allergy') {
        if ((allergyName.trim()).isEmpty) {
          setState(() => error = 'Please enter an allergy name');
          return;
        }

        // find or create allergy
        final existing = await Supabase.instance.client
            .from('allergies')
            .select()
            .ilike('name', allergyName)
            .maybeSingle();

        int allergyId;
        if (existing == null) {
          final ins = await Supabase.instance.client
              .from('allergies')
              .insert({'name': allergyName})
              .select()
              .single();
          allergyId = ins['id'];
        } else {
          allergyId = existing['id'];
        }

        final notesText = 'Severity: $allergySeverity\nReaction: $reactionDesc';
        final paResp = await Supabase.instance.client
            .from('patient_allergies')
            .insert({
              'patient_id': widget.preselectedPatient.id,
              'allergy_id': allergyId,
              'notes': notesText,
            })
            .select()
            .single();

        final record = {
          'type': 'allergy',
          'patient_allergy': paResp,
          'title': allergyName,
          'severity': allergySeverity,
          'desc': reactionDesc,
        };

        if (!mounted) return;
        Navigator.pop(context, record);
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Failed to save record: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dialogMaxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: loading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox(
                  height: dialogMaxHeight,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Medical Record for ${widget.preselectedPatient.fullName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Record type selector (tabs)
                        Container(
                          height: 45,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black54,
                            tabs: const [
                              Tab(text: 'Procedure'),
                              Tab(text: 'Prescription'),
                              Tab(text: 'Allergy'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Procedure form
                        if (recordType == 'Procedure') ...[
                          DropdownButtonFormField<Treatment>(
                            initialValue: selectedTreatment,
                            hint: const Text('Select treatment'),
                            items: treatments
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.name ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedTreatment = v;
                                price = v?.basePrice;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int?>(
                            initialValue: selectedDoctorId,
                            hint: const Text('Select doctor (optional)'),
                            items: doctors
                                .map(
                                  (d) => DropdownMenuItem<int?>(
                                    value: d['id'] as int?,
                                    child: Text(
                                      '${d['first_name'] ?? ''} ${d['last_name'] ?? ''}'
                                          .trim(),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                selectedDoctorId = v;
                                if (v != null) {
                                  final doc = doctors.firstWhere(
                                    (d) => d['id'] == v,
                                  );
                                  selectedDoctorName =
                                      '${doc['first_name'] ?? ''} ${doc['last_name'] ?? ''}'
                                          .trim();
                                } else {
                                  selectedDoctorName = 'Unknown Doctor';
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 3650),
                                ),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                DateFormat.yMMMMd('fr_FR').format(selectedDate),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: notes,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => notes = v,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Prescription form
                        if (recordType == 'Prescription') ...[
                          const Text(
                            'Médicaments',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: medicationItems.asMap().entries.map((
                              entry,
                            ) {
                              final idx = entry.key;
                              final item = entry.value;
                              return Column(
                                key: ValueKey(idx),
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: item['medication_name'],
                                          decoration: const InputDecoration(
                                            labelText: 'Nom du médicament',
                                          ),
                                          onChanged: (v) => setState(
                                            () =>
                                                medicationItems[idx]['medication_name'] =
                                                    v,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever),
                                        onPressed: () => setState(() {
                                          medicationItems.removeAt(idx);
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    initialValue: item['dosage'],
                                    decoration: const InputDecoration(
                                      labelText: 'Posologie',
                                    ),
                                    onChanged: (v) => setState(
                                      () => medicationItems[idx]['dosage'] = v,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    initialValue: item['duration'],
                                    decoration: const InputDecoration(
                                      labelText: 'Durée',
                                    ),
                                    onChanged: (v) => setState(
                                      () =>
                                          medicationItems[idx]['duration'] = v,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    initialValue: item['instructions'],
                                    decoration: const InputDecoration(
                                      labelText: 'Instructions supplémentaires',
                                    ),
                                    onChanged: (v) => setState(
                                      () =>
                                          medicationItems[idx]['instructions'] =
                                              v,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              );
                            }).toList(),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => setState(() {
                                  medicationItems.add({
                                    'medication_name': '',
                                    'dosage': '',
                                    'duration': '',
                                    'instructions': '',
                                  });
                                }),
                                child: const Text('Ajouter un médicament'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<int?>(
                                  initialValue: selectedDoctorId,
                                  hint: const Text(
                                    'Prescrit par (médecin) (optionnel)',
                                  ),
                                  items: doctors
                                      .map(
                                        (d) => DropdownMenuItem<int?>(
                                          value: d['id'] as int?,
                                          child: Text(
                                            '${d['first_name'] ?? ''} ${d['last_name'] ?? ''}'
                                                .trim(),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      selectedDoctorId = v;
                                      if (v != null) {
                                        final doc = doctors.firstWhere(
                                          (d) => d['id'] == v,
                                        );
                                        selectedDoctorName =
                                            '${doc['first_name'] ?? ''} ${doc['last_name'] ?? ''}'
                                                .trim();
                                      } else {
                                        selectedDoctorName = 'Unknown Doctor';
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: prescriptionNotes,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => prescriptionNotes = v,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Allergy form
                        if (recordType == 'Allergy') ...[
                          const Text(
                            'Please ensure allergy information is accurate to prevent adverse reactions.',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: allergyName,
                            decoration: const InputDecoration(
                              labelText: 'Allergy name',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => setState(() => allergyName = v),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: allergySeverity,
                            items: severities
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => allergySeverity = v ?? 'Mild'),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: reactionDesc,
                            decoration: const InputDecoration(
                              labelText: 'Reaction description',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => setState(() => reactionDesc = v),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],

                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF2B7FFF),
                                    Color(0xFF00B8DB),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _submit,
                                  borderRadius: BorderRadius.circular(8),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
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
}
