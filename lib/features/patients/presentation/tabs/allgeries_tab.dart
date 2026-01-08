import 'package:flutter/material.dart';

class AllergiesTab extends StatelessWidget {
  final List<dynamic> allergies;
  
  const AllergiesTab({
    super. key,
    required this.allergies,
  });

  @override
  Widget build(BuildContext context) {
    if (allergies.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child:  Text(
            "Aucune allergie enregistrée",
            style:  TextStyle(
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
      itemCount: allergies.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      padding: const EdgeInsets.all(12),
      itemBuilder:  (context, index) {
        final a = allergies[index];
        final severity = a['severity']?.toString() ?? '';
        
        Color severityColor;
        switch (severity. toLowerCase()) {
          case 'élevée':
          case 'haute':
          case 'high':
            severityColor = const Color(0xFFEF4444);
            break;
          case 'moyenne':
          case 'medium':
            severityColor = const Color(0xFFF59E0B);
            break;
          case 'faible':
          case 'low':
            severityColor = const Color(0xFF10B981);
            break;
          default:
            severityColor = const Color(0xFF64748B);
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child:  Text(
                      a['title'] ?? 'Allergie',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (severity.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor. withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: severityColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        severity,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:  FontWeight.w600,
                          color: severityColor,
                        ),
                      ),
                    ),
                ],
              ),
              if (a['desc'] != null && (a['desc'] as String).isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  a['desc'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:  FontWeight.normal,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}