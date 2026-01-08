import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'profile_avatar.dart';

class PatientHeader extends StatelessWidget {
  final String name;
  final String gender;
  final String age;
  final String dob;
  final String patientId;
  final Uint8List? profileImage;
  final VoidCallback onBack;
  final VoidCallback onImagePick;

  const PatientHeader({
    super.key,
    required this.name,
    required this.gender,
    required this.age,
    required this.dob,
    required this.patientId,
    this.profileImage,
    required this.onBack,
    required this.onImagePick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatar(
          profileImage: profileImage,
          onTap: onImagePick,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize:  24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildBadge(gender, const Color(0xFF0EA5E9)),
                  const SizedBox(width: 8),
                  _buildBadge('$age years', const Color(0xFF8B5CF6)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/appointments.svg",
                    width: 16,
                    height: 16,
                    color: const Color(0xFF64748B),
                  ),
                  const SizedBox(width:  8),
                  Text(
                    'DDN :  $dob',
                    style:  const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "|",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SvgPicture.asset(
                    "assets/icons/file.svg",
                    width: 16,
                    height:  16,
                    color:  const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ID :  $patientId',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildBackButton(onBack),
      ],
    );
  }

  Widget _buildBadge(String text, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        color: bgColor. withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: bgColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text, style: TextStyle(color: bgColor)),
    );
  }

  Widget _buildBackButton(VoidCallback onBack) {
    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap:  onBack,
        borderRadius: BorderRadius.circular(24),
        hoverColor: const Color(0xFFF1F5F9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.arrow_back, size: 18, color: Color(0xFF1E293B)),
              SizedBox(width: 8),
              Text(
                'Retour aux patients',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}