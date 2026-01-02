import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
