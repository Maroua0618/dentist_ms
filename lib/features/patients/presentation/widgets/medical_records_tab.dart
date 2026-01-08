import 'package:flutter/material.dart';
import '../tabs/allgeries_tab.dart';
import '../tabs/dental_history_tab.dart';
import '../tabs/prescriptions_tab.dart';
import '../tabs/upcoming_tab.dart';

class MedicalRecordsTabs extends StatelessWidget {
  final TabController tabController;
  final Map<String, dynamic> patient;

  const MedicalRecordsTabs({
    super.key,
    required this.tabController,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic patientIdRaw = patient['id'];
    int?  patientInt;
    if (patientIdRaw != null) {
      if (patientIdRaw is int) {
        patientInt = patientIdRaw;
      } else {
        patientInt = int.tryParse(patientIdRaw.toString());
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.description_outlined,
                size: 24,
                color: Color(0xFF1E293B),
              ),
              SizedBox(width:  8),
              Text(
                'Dossiers médicaux',
                style:  TextStyle(
                  fontSize:  18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 45,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment. centerLeft,
                  end:  Alignment.centerRight,
                  colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius:  4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Histo dentaire'),
                Tab(text:  'Ordonnances'),
                Tab(text: 'Allergies'),
                Tab(text: 'À venir'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                DentalHistoryTab(
                  records: (patient['dentalHistory'] as List<dynamic>?) ?? [],
                ),
                PrescriptionsTab(
                  prescriptions: (patient['prescriptions'] as List<dynamic>?) ?? [],
                  patientName: patient['name'] ?? 'Patient inconnu',
                ),
                AllergiesTab(
                  allergies:  (patient['allergies'] as List<dynamic>?) ?? [],
                ),
                UpcomingTab(patientId: patientInt),
              ],
            ),
          ),
        ],
      ),
    );
  }
}