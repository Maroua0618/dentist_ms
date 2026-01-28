import 'package:dentist_ms/features/auth/presentation/widgets/login_gradient_button.dart';
import 'package:flutter/material.dart';

class LoginFacialTab extends StatelessWidget {
  const LoginFacialTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Text(
              'Connexion sécurisée',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La reconnaissance faciale est actuellement désactivée.\nVeuillez utiliser l\'onglet Email pour vous connecter.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.grey.withValues(alpha: 0.2),
                Colors.grey.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 3),
              ),
              child: const Center(
                child: Icon(
                  Icons.face_retouching_off,
                  size: 45,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        LoginGradientButton(
          text: 'Fonctionnalité désactivée',
          onPressed: () {
            // Do nothing - feature is disabled
          },
        ),
      ],
    );
  }
}
