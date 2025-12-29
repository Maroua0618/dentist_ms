import 'package:flutter/material.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityControllers {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}

Widget security(BuildContext context, double width, double height, SecurityControllers controllers) {
  return Card(
    child: Padding(
      padding: EdgeInsets. symmetric(vertical: height * 0.02, horizontal: width * 0.03),
      child: Column(
        mainAxisAlignment:  MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Text("Changer le mot de passe", style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: height * 0.03),

          // Responsive layout for password fields and image
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    Column(
                      children: [
                        _buildPasswordField('Mot de passe actuel', controllers.currentPasswordController, height),
                        SizedBox(height: height * 0.02),
                        _buildPasswordField('Nouveau mot de passe', controllers.newPasswordController, height),
                        SizedBox(height: height * 0.02),
                        _buildPasswordField('Confirmer le nouveau mot de passe', controllers.confirmPasswordController, height),
                      ],
                    ),
                    SizedBox(height: height * 0.03),
                    SizedBox(
                      width:  width * 0.5,
                      height: height * 0.3,
                      child: Image.asset("assets/images/security.png"),
                    ),
                  ],
                );
              } else {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment:  CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children:  [
                            _buildPasswordField('Mot de passe actuel', controllers.currentPasswordController, height),
                            SizedBox(height: height * 0.02),
                            _buildPasswordField('Nouveau mot de passe', controllers.newPasswordController, height),
                            SizedBox(height: height * 0.02),
                            _buildPasswordField('Confirmer le nouveau mot de passe', controllers.confirmPasswordController, height),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/security.png",
                                width: width * 0.45,
                                height: height * 0.35,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: width * 0.3,
                                    height: height * 0.2,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.security, size: 50, color: Colors.grey[400]),
                                        SizedBox(height: 8),
                                        Text("Security Image", style: TextStyle(color: Colors.grey[500])),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleChangePassword(context, controllers),
              child: Text("Sauvegarder", style: AppTextStyles. bodyWhite),
            ),
          )
        ],
      ),
    ),
  );
}

// Helper method for password fields
Widget _buildPasswordField(String label, TextEditingController controller, double height) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.subtitle1),
      SizedBox(height:  height * 0.01),
      TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: '••••••••',
          filled:  true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ],
  );
}

// Handle password change
Future<void> _handleChangePassword(BuildContext context, SecurityControllers controllers) async {
  final currentPassword = controllers.currentPasswordController. text.trim();
  final newPassword = controllers.newPasswordController. text.trim();
  final confirmPassword = controllers.confirmPasswordController. text.trim();

  // Validation
  if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez remplir tous les champs'),
        backgroundColor: Colors. red,
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
        backgroundColor: Colors. red,
      ),
    );
    return;
  }

  try {
    final supabase = Supabase.instance.client;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changement en cours...')),
    );

    // Update password via Supabase
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    // Clear fields
    controllers.currentPasswordController. clear();
    controllers.newPasswordController.clear();
    controllers.confirmPasswordController.clear();

    // Show success
    if (context.mounted) {
      ScaffoldMessenger. of(context).showSnackBar(
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
          backgroundColor: Colors. red,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
