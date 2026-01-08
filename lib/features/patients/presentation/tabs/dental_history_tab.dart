import 'package:flutter/material.dart';

class DentalHistoryTab extends StatelessWidget {
  final List<dynamic> records;
  
  const DentalHistoryTab({
    super.key,
    required this. records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text(
          "Aucun enregistrement trouvé",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(
          record['title'] ?? 'Procédure inconnue',
          record['date'] ?? 'N/A',
          record['desc'] ?? 'Aucune description fournie',
          record['doctor'] ?? 'Médecin inconnu',
        );
      },
    );
  }

  Widget _buildRecordCard(
    String title,
    String date,
    String description,
    String doctor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            children:  [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                    height: 1.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration:  BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius:  BorderRadius.circular(20),
                ),
                child:  Text(
                  doctor,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}