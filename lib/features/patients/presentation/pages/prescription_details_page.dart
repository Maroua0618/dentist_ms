import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrescriptionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> prescription;
  final String patientName;

  const PrescriptionDetailsPage({
    super.key,
    required this.prescription,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    final id = prescription['id']?.toString() ?? '';
    final date = prescription['date'] != null
        ? DateFormat.yMMMMd(
            'fr_FR',
          ).format(DateTime.parse(prescription['date']))
        : '';
    final doctor = prescription['doctor'] ?? 'Inconnu';
    final notes = prescription['desc'] ?? '';
    final items = (prescription['items'] as List<dynamic>?) ?? [];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'RX-$id',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(date, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'Nom du patient',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: patientName,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Médecin',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  initialValue: doctor,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Diagnostic',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  initialValue: notes.isNotEmpty ? notes : '—',
                  readOnly: true,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Médicaments prescrits',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),

                if (items.isEmpty)
                  const Text('—', style: TextStyle(color: Colors.black54))
                else
                  Column(
                    children: items.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final item = entry.value as Map<String, dynamic>;
                      final medName = item['medication_name'] ?? '';
                      final dosage = item['dosage'] ?? '';
                      final duration = item['duration'] ?? '';
                      final instr = item['instructions'] ?? ''; 

                      return Container(
                        key: ValueKey(item['id'] ?? 'med-$idx'),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              initialValue: medName,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: '$idx. Medication',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: dosage.toString(),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Posologie',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: duration.toString(),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Durée',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if ((instr as String).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: instr,
                                readOnly: true,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Instructions',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
