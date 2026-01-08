import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PatientStatsCards extends StatelessWidget {
  final String totalVisits;
  final String lastVisit;
  final String primaryDentist;
  final BoxConstraints constraints;

  const PatientStatsCards({
    super.key,
    required this.totalVisits,
    required this.lastVisit,
    required this.primaryDentist,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    bool isCompact = constraints.maxWidth < 1366;
    double spacing = isCompact ? 16 : 24;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Visites totales',
            totalVisits,
            "assets/icons/calendar.svg",
            const LinearGradient(
              begin: Alignment(-0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [Color(0xFF2B7FFF), Color(0xFF00B8DA)],
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildStatCard(
            'Dernière visite',
            lastVisit,
            "assets/icons/watch.svg",
            const LinearGradient(
              begin:  Alignment(-0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [Color(0xFF00BC7C), Color(0xFF00BBA6)],
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildStatCard(
            'Dentiste principal',
            primaryDentist,
            "assets/icons/doctor.svg",
            const LinearGradient(
              begin:  Alignment(-0.00, 0.00),
              end: Alignment(1.00, 1.00),
              colors: [Color(0xFF8D51FF), Color(0xFFAC46FF)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String icon,
    LinearGradient bgcolor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius:  BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF64748B),
                  height:  1.4,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  height: 1.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: bgcolor,
              borderRadius:  BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}