import 'package:dentist_ms/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginLeftSection extends StatelessWidget {
  const LoginLeftSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20),
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 65,
                  height: 65,
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  "Système de Gestion de Clinique Dentaire",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Heading
          const Text(
            'Gestion de Cabinet Dentaire\nNouvelle Génération',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          // Description
          const Text(
            'Rationalisez votre cabinet avec la gestion des patients,\nla planification fluide et l\'analyse avancée.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),

          const SizedBox(height: 30),

          // Feature Cards
          Row(
            children: [
              Expanded(
                child: _FeatureCard(
                  icon: "assets/icons/security.svg",
                  title: 'Sécurisé',
                  subtitle: 'Accès Basé sur les Rôles',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FeatureCard(
                  icon: "assets/icons/flash.svg",
                  title: 'Rapide',
                  subtitle: 'Basé sur le Cloud & Optimisé',
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          Row(
            children: [
              SvgPicture.asset(
                "assets/icons/security.svg",
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF00B8DB),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Protégé par des contrôles d\'accès sécurisés',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            blendMode: BlendMode.srcIn,
            child: SvgPicture.asset(icon, width: 28, height: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
