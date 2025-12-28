import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

Widget profil(BuildContext context, double width, double height, ProfilControllers controllers) {
  return ProfilWidget(width: width, height: height, controllers: controllers);
}

class ProfilControllers {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController profilEmailController = TextEditingController();
  final TextEditingController profilPhoneController = TextEditingController();
  final TextEditingController profilSpecializationController = TextEditingController();
  final TextEditingController profilBioController = TextEditingController();

  void dispose() {
    firstNameController. dispose();
    lastNameController. dispose();
    profilEmailController.dispose();
    profilPhoneController.dispose();
    profilSpecializationController.dispose();
    profilBioController. dispose();
  }
}

Widget profil(BuildContext context, double width, double height, ProfilControllers controllers) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, authState) {
      final user = authState.user;

      if (user == null) {
        return const Center(child: Text('User not found'));
      }

      // Populate controllers with current user data
      if (controllers.firstNameController.text.isEmpty) {
        controllers.firstNameController.text = user.firstName;
        controllers.lastNameController.text = user.lastName;
        controllers.profilEmailController.text = user.email;
        controllers.profilPhoneController.text = user.phone ??  '';
        controllers.profilSpecializationController.text = user. specialization ?? '';
      }

      return Card(
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Informations personnelles", style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: height * 0.03),

              // Profile photo section
              _buildProfilePhotoSection(context, width, height, user),

              SizedBox(height: height * 0.04),

              // Responsive fields section
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return _buildVerticalFields(context, height, width, controllers, user);
                  } else {
                    return _buildHorizontalFields(context, height, width, controllers, user);
                  }
                },
              ),

              SizedBox(height: height * 0.04),

              // Update button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleUpdateProfile(context, controllers, user. id),
                  child: Text("Mettre à jour le profil", style: AppTextStyles.bodyWhite),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

// Profile photo section
Widget _buildProfilePhotoSection(BuildContext context, double width, double height, user) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      CircleAvatar(
        radius:  width * 0.04,
        backgroundColor: const Color(0xFF4F7EFF),
        backgroundImage: user.profilePhotoPath != null 
            ? NetworkImage(user.profilePhotoPath!) 
            : null,
        child: user.profilePhotoPath == null
            ? Text(
                user.firstName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              )
            : null,
      ),
      SizedBox(width: width * 0.02),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: Implement photo upload
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo upload coming soon')),
                );
              },
              child: const Text("Change Photo"),
            ),
            SizedBox(height: height * 0.01),
            Text("JPG, PNG ou GIF.  Taille maximale: 2Mo.", style: AppTextStyles.subtitle1)
          ],
        ),
      )
    ],
  );
}

// Horizontal layout for larger screens
Widget _buildHorizontalFields(BuildContext context, double height, double width, ProfilControllers controllers, user) {
  return Column(
    children: [
      // First name and Last name
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildField('Prénom', controllers.firstNameController, height)),
          SizedBox(width: width * 0.02),
          Expanded(child:  _buildField('Nom', controllers.lastNameController, height)),
        ],
      ),
      SizedBox(height: height * 0.02),

      // Email and Phone
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildField('Email', controllers.profilEmailController, height, enabled: false)),
          SizedBox(width: width * 0.02),
          Expanded(child: _buildField('Téléphone', controllers.profilPhoneController, height)),
        ],
      ),
      SizedBox(height: height * 0.02),

      // Specialization (only for doctors)
      if (user.isDoctor)
        _buildField('Spécialisation', controllers.profilSpecializationController, height),
    ],
  );
}

// Vertical layout for small screens
Widget _buildVerticalFields(BuildContext context, double height, double width, ProfilControllers controllers, user) {
  return Column(
    children: [
      _buildField('Prénom', controllers.firstNameController, height),
      SizedBox(height: height * 0.02),
      _buildField('Nom', controllers.lastNameController, height),
      SizedBox(height: height * 0.02),
      _buildField('Email', controllers.profilEmailController, height, enabled: false),
      SizedBox(height: height * 0.02),
      _buildField('Téléphone', controllers.profilPhoneController, height),
      SizedBox(height: height * 0.02),
      if (user.isDoctor)
        _buildField('Spécialisation', controllers.profilSpecializationController, height),
    ],
  );
}

// Helper method for building fields
Widget _buildField(String label, TextEditingController controller, double height, {bool enabled = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.subtitle1),
      SizedBox(height: height * 0.01),
      TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ],
  );
}

// Handle profile update
Future<void> _handleUpdateProfile(BuildContext context, ProfilControllers controllers, int userId) async {
  try {
    final supabase = Supabase. instance.client;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mise à jour en cours.. .')),
    );

    // Update user in database
    await supabase. from('users').update({
      'first_name': controllers.firstNameController.text. trim(),
      'last_name':  controllers.lastNameController.text. trim(),
      'phone': controllers.profilPhoneController.text.trim(),
      'specialization': controllers.profilSpecializationController.text.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);

    // Show success
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload user data
      // You might want to add a refresh event to AuthBloc here
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text('Erreur:  ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }
}
