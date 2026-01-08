import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityControllers {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}

Widget security(
  BuildContext context,
  double width,
  double height,
  SecurityControllers controllers,
) {
  return Card(
    color: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.03,
          horizontal: width * 0.04,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                SizedBox(width: width * 0.02),
                Text(
                  "Changer le mot de passe",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            Divider(color: Colors.grey.shade300, thickness: 1),
            SizedBox(height: height * 0.04),

            // Responsive layout for password fields and image
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Column(
                    children: [
                      Column(
                        children: [
                          _buildPasswordField(
                            context,
                            'Mot de passe actuel',
                            controllers.currentPasswordController,
                            height,
                            icon: Icons.lock_outline,
                          ),
                          SizedBox(height: height * 0.03),
                          _buildNewPasswordField(context, controllers, height),
                          SizedBox(height: height * 0.03),
                          _buildPasswordField(
                            context,
                            'Confirmer le nouveau mot de passe',
                            controllers.confirmPasswordController,
                            height,
                            icon: Icons.lock,
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.04),
                      Container(
                        width: width * 0.6,
                        height: height * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          "assets/images/security.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  );
                } else {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildPasswordField(
                                context,
                                'Mot de passe actuel',
                                controllers.currentPasswordController,
                                height,
                                icon: Icons.lock_outline,
                              ),
                              SizedBox(height: height * 0.03),
                              _buildNewPasswordField(
                                context,
                                controllers,
                                height,
                              ),
                              SizedBox(height: height * 0.03),
                              _buildPasswordField(
                                context,
                                'Confirmer le nouveau mot de passe',
                                controllers.confirmPasswordController,
                                height,
                                icon: Icons.lock,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: width * 0.04),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: width * 0.45,
                                height: height * 0.35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  "assets/images/security.png",
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.security,
                                            size: 60,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Security Image",
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            SizedBox(height: height * 0.05),

            // Save button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _handleChangePassword(context, controllers),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: height * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Sauvegarder",
                      style: AppTextStyles.bodyWhite.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper method for password fields
Widget _buildPasswordField(
  BuildContext context,
  String label,
  TextEditingController controller,
  double height, {
  IconData? icon,
}) {
  bool obscure = true;
  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          SizedBox(height: height * 0.01),
          TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: '••••••••',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: icon != null
                  ? Icon(icon, color: Theme.of(context).primaryColor)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                tooltip: obscure ? 'Afficher' : 'Masquer',
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => obscure = !obscure),
              ),
            ),
          ),
        ],
      );
    },
  );
}

// New password field with strength indicator (UI-only)
Widget _buildNewPasswordField(
  BuildContext context,
  SecurityControllers controllers,
  double height,
) {
  bool obscure = true;
  Color base = Theme.of(context).colorScheme.primary;
  return StatefulBuilder(
    builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nouveau mot de passe',
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          SizedBox(height: height * 0.01),
          TextField(
            controller: controllers.newPasswordController,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: '••••••••',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                Icons.lock,
                color: Theme.of(context).primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                tooltip: obscure ? 'Afficher' : 'Masquer',
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => obscure = !obscure),
              ),
            ),
          ),
          SizedBox(height: height * 0.015),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controllers.newPasswordController,
            builder: (context, value, _) {
              final text = value.text;
              final hasLen = text.length >= 6;
              final hasLetter = RegExp(r"[A-Za-z]").hasMatch(text);
              final hasNumber = RegExp(r"\d").hasMatch(text);
              final hasSpecial = RegExp(r"[^A-Za-z0-9]").hasMatch(text);
              int score = 0;
              if (hasLen) score++;
              if (hasLetter) score++;
              if (hasNumber) score++;
              if (hasSpecial) score++;
              final strength = score / 4.0;
              final Color strengthColor = [
                Colors.red,
                Colors.orange,
                Colors.amber,
                Colors.lightGreen,
                Colors.green,
              ][score];
              final String strengthLabel = [
                'Très faible',
                'Faible',
                'Moyenne',
                'Bonne',
                'Forte',
              ][score];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Strength bar
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            height: 10,
                            width: constraints.maxWidth * strength,
                            decoration: BoxDecoration(
                              color: strengthColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sécurité: $strengthLabel',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Tooltip(
                        message:
                            'Utilisez au moins 6 caractères, chiffres et symboles',
                        child: Icon(Icons.info_outline, size: 18, color: base),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _requirementChip(context, '6+ caractères', hasLen),
                      _requirementChip(context, 'Lettre', hasLetter),
                      _requirementChip(context, 'Chiffre', hasNumber),
                      _requirementChip(context, 'Symbole', hasSpecial),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      );
    },
  );
}

Widget _requirementChip(BuildContext context, String label, bool met) {
  final color = met ? Theme.of(context).primaryColor : Colors.grey;
  return Chip(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    visualDensity: VisualDensity.compact,
    backgroundColor: met
        ? color.withOpacity(0.12)
        : Colors.grey.withOpacity(0.12),
    side: BorderSide(
      color: met ? color.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
    ),
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
        ),
      ],
    ),
  );
}

// Handle password change
Future<void> _handleChangePassword(
  BuildContext context,
  SecurityControllers controllers,
) async {
  final currentPassword = controllers.currentPasswordController.text.trim();
  final newPassword = controllers.newPasswordController.text.trim();
  final confirmPassword = controllers.confirmPasswordController.text.trim();

  // Validation
  if (currentPassword.isEmpty ||
      newPassword.isEmpty ||
      confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez remplir tous les champs'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (newPassword != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Les mots de passe ne correspondent pas'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  if (newPassword.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Le mot de passe doit contenir au moins 6 caractères'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    final supabase = Supabase.instance.client;

    // Show loading
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Changement en cours...')));

    // Update password via Supabase
    await supabase.auth.updateUser(UserAttributes(password: newPassword));

    // Clear fields
    controllers.currentPasswordController.clear();
    controllers.newPasswordController.clear();
    controllers.confirmPasswordController.clear();

    // Show success
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe changé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } on AuthException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
