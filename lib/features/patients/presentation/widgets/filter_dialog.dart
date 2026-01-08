import 'package:dentist_ms/features/patients/models/patient_filter.dart';
import 'package:flutter/material.dart';

class PatientFilterDialog extends StatefulWidget {
  final PatientFilter initialFilter;

  const PatientFilterDialog({super.key, required this.initialFilter});

  @override
  State<PatientFilterDialog> createState() => _PatientFilterDialogState();
}

class _PatientFilterDialogState extends State<PatientFilterDialog> {
  late String? _filterStatus;
  late String? _filterGender;
  late String? _filterBloodType;
  late DateTime? _filterDateFrom;
  late DateTime? _filterDateTo;

  @override
  void initState() {
    super.initState();
    _filterStatus = widget.initialFilter.status;
    _filterGender = widget.initialFilter.gender;
    _filterBloodType = widget.initialFilter.bloodType;
    _filterDateFrom = widget.initialFilter.dateFrom;
    _filterDateTo = widget.initialFilter.dateTo;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4F7EFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_alt, color: Color(0xFF4F7EFF)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Filtres',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer les patients par: ',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Status filter
              DropdownButtonFormField<String>(
                value: _filterStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  prefixIcon: Icon(Icons.check_circle_outline),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tous')),
                  DropdownMenuItem(value: 'active', child: Text('Actif')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactif')),
                ],
                onChanged: (value) {
                  setState(() => _filterStatus = value);
                },
              ),

              const SizedBox(height: 16),

              // Gender filter
              DropdownButtonFormField<String>(
                value: _filterGender,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tous')),
                  DropdownMenuItem(value: 'male', child: Text('Homme')),
                  DropdownMenuItem(value: 'female', child: Text('Femme')),
                ],
                onChanged: (value) {
                  setState(() => _filterGender = value);
                },
              ),

              const SizedBox(height: 16),

              // Blood type filter
              DropdownButtonFormField<String>(
                value: _filterBloodType,
                decoration: const InputDecoration(
                  labelText: 'Groupe sanguin',
                  prefixIcon: Icon(Icons.bloodtype_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tous')),
                  DropdownMenuItem(value: 'O+', child: Text('O+')),
                  DropdownMenuItem(value: 'O-', child: Text('O-')),
                  DropdownMenuItem(value: 'A+', child: Text('A+')),
                  DropdownMenuItem(value: 'A-', child: Text('A-')),
                  DropdownMenuItem(value: 'B+', child: Text('B+')),
                  DropdownMenuItem(value: 'B-', child: Text('B-')),
                  DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                  DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                ],
                onChanged: (value) {
                  setState(() => _filterBloodType = value);
                },
              ),

              const SizedBox(height: 20),
              const Text(
                'Date d\'enregistrement: ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Date range
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _filterDateFrom ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _filterDateFrom = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _filterDateFrom != null
                            ? _filterDateFrom!
                                  .toIso8601String()
                                  .split('T')
                                  .first
                            : 'De',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _filterDateTo ?? DateTime.now(),
                          firstDate: _filterDateFrom ?? DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _filterDateTo = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _filterDateTo != null
                            ? _filterDateTo!.toIso8601String().split('T').first
                            : 'À',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _filterStatus = null;
              _filterGender = null;
              _filterBloodType = null;
              _filterDateFrom = null;
              _filterDateTo = null;
            });
          },
          child: const Text('Réinitialiser'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final filter = PatientFilter(
              status: _filterStatus,
              gender: _filterGender,
              bloodType: _filterBloodType,
              dateFrom: _filterDateFrom,
              dateTo: _filterDateTo,
            );
            Navigator.pop(context, filter);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F7EFF),
            foregroundColor: Colors.white,
          ),
          child: const Text('Appliquer'),
        ),
      ],
    );
  }
}
