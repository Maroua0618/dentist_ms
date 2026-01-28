import 'package:flutter/material.dart';

class ResetPasswordDialog extends StatefulWidget {
  final Function(String email) onResetPassword;

  const ResetPasswordDialog({super.key, required this.onResetPassword});

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final _resetEmailController = TextEditingController();
  String? _resetEmailError;

  @override
  void dispose() {
    _resetEmailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleSubmit() {
    final email = _resetEmailController.text.trim();

    if (email.isEmpty) {
      setState(() => _resetEmailError = 'Veuillez entrer votre email');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _resetEmailError = 'Email invalide');
      return;
    }

    widget.onResetPassword(email);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2530),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Réinitialiser le mot de passe',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrez votre email pour recevoir un lien de réinitialisation',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _resetEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'votre.email@example.com',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: const Color(0xFF2A3441),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              errorText: _resetEmailError,
              errorStyle: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _resetEmailError != null
                      ? const Color(0xFFDC2626)
                      : Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _resetEmailError != null
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF4F7EFF),
                  width: 2,
                ),
              ),
            ),
            onChanged: (_) {
              if (_resetEmailError != null) {
                setState(() => _resetEmailError = null);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Annuler',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F7EFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Envoyer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
