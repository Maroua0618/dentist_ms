import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ContactInformationCard extends StatelessWidget {
  final String phone;
  final String email;
  final String address;

  const ContactInformationCard({
    super.key,
    required this.phone,
    required this. email,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets. all(20),
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
            children: [
              SvgPicture.asset(
                "assets/icons/person.svg",
                width: 24,
                height: 24,
                color: const Color(0xFF0EA5E9),
              ),
              const SizedBox(width:  8),
              const Text(
                'Informations de contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            "assets/icons/phone.svg",
            'Téléphone',
            phone,
            const Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            "assets/icons/email.svg",
            'E-mail',
            email,
            const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            "assets/icons/location.svg",
            'Adresse',
            address,
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    String icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets. all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:  const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFF1E293B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}