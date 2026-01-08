import 'package:flutter/material.dart';
import 'package:dentist_ms/features/patients/presentation/pages/prescription_details_page.dart';

class PrescriptionsTab extends StatelessWidget {
  final List<dynamic> prescriptions;
  final String patientName;
  
  const PrescriptionsTab({
    super.key,
    required this.prescriptions,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    if (prescriptions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius:  BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Text(
            "Pas d'ordonnances",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: prescriptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final p = prescriptions[index];
        return InkWell(
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (_) => PrescriptionDetailsPage(
                  prescription: p as Map<String, dynamic>,
                  patientName: patientName,
                ),
              );
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border. all(color: const Color(0xFFE2E8F0)),
            ),
            child:  Column(
              crossAxisAlignment:  CrossAxisAlignment.start,
              children: [
                Text(
                  p['title'] ?? 'Ordonnance',
                  style:  const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Prescrit par :  ${p['doctor'] ?? 'Inconnu'} • ${p['date'] ?? ''}',
                  style: const TextStyle(
                    fontSize:  13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (p['desc'] != null && (p['desc'] as String).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    p['desc'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}