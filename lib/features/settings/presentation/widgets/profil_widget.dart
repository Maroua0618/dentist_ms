import 'dart:typed_data';
import 'package:dentist_ms/core/models/app_user.dart';
import 'package:dentist_ms/features/auth/bloc/auth_event.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/core/constants/app_text_styles.dart';
import 'package:dentist_ms/features/auth/bloc/auth_bloc.dart';
import 'package:dentist_ms/features/auth/bloc/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class ProfilControllers {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController profilEmailController = TextEditingController();
  final TextEditingController profilPhoneController = TextEditingController();
  final TextEditingController profilSpecializationController =
      TextEditingController();

  String? profileImageUrl;
  Uint8List? cachedImageBytes;

  int? _currentUserId;

  /// Load profile image from Supabase Storage
  Future<Uint8List?> loadProfileImage(String imageUrl) async {
    try {
      // If we already have it cached, return it
      if (cachedImageBytes != null && profileImageUrl == imageUrl) {
        return cachedImageBytes;
      }

      // Download image bytes from Supabase Storage URL
      final response = await Supabase.instance.client.storage
          .from('profile-images')
          .download(imageUrl);

      cachedImageBytes = response;
      profileImageUrl = imageUrl;
      return response;
    } catch (e) {
      print('Error loading profile image: $e');
      return null;
    }
  }

  /// Upload profile image to Supabase Storage
  Future<String?> uploadProfileImage(XFile imageFile, int userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExtension = imageFile.path.split('.').last;
      final fileName =
          'user_$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Delete old image if exists
      if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
        try {
          await Supabase.instance.client.storage.from('profile-images').remove([
            profileImageUrl!,
          ]);
        } catch (e) {
          print('Could not delete old image: $e');
        }
      }

      // Upload new image to Supabase Storage
      await Supabase.instance.client.storage
          .from('profile-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$fileExtension',
            ),
          );

      // Get the public URL
      final publicUrl = Supabase.instance.client.storage
          .from('profile-images')
          .getPublicUrl(fileName);

      // Update database with new photo URL
      await Supabase.instance.client
          .from('users')
          .update({
            'profile_photo_path': fileName, // Store the path, not the full URL
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Cache the image
      cachedImageBytes = bytes;
      profileImageUrl = fileName;

      return fileName;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  void resetForUser(int userId, AppUser user) {
    // Always update when user ID changes
    if (_currentUserId != userId) {
      _currentUserId = userId;

      // Clear and set new values
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      profilEmailController.text = user.email;
      profilPhoneController.text = user.phone ?? '';
      profilSpecializationController.text = user.specialization ?? '';

      // Clear image cache for new user
      cachedImageBytes = null;
      profileImageUrl = user.profileImageUrl;

      // Load profile image if exists
      if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
        loadProfileImage(user.profileImageUrl!);
      }
    } else {
      // Same user, just update if values differ
      if (firstNameController.text != user.firstName) {
        firstNameController.text = user.firstName;
      }
      if (lastNameController.text != user.lastName) {
        lastNameController.text = user.lastName;
      }
      if (profilPhoneController.text != (user.phone ?? '')) {
        profilPhoneController.text = user.phone ?? '';
      }
      if (profilSpecializationController.text != (user.specialization ?? '')) {
        profilSpecializationController.text = user.specialization ?? '';
      }

      // Update image if path changed
      if (user.profileImageUrl != profileImageUrl &&
          user.profileImageUrl != null &&
          user.profileImageUrl!.isNotEmpty) {
        cachedImageBytes = null; // Clear cache
        loadProfileImage(user.profileImageUrl!);
      }
    }
  }

  void updateFromUser(AppUser user) {
    if (_currentUserId == user.id) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      profilPhoneController.text = user.phone ?? '';
      profilSpecializationController.text = user.specialization ?? '';

      // Update image if path changed
      if (user.profileImageUrl != profileImageUrl) {
        cachedImageBytes = null; // Clear cache
        if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
          loadProfileImage(user.profileImageUrl!);
        }
      }
    }
  }

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    profilEmailController.dispose();
    profilPhoneController.dispose();
    profilSpecializationController.dispose();
  }
}

Widget profil(
  BuildContext context,
  double width,
  double height,
  ProfilControllers controllers,
) {
  return BlocConsumer<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state.status == AuthStatus.error && state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (state.status == AuthStatus.authenticated && state.user != null) {
        // Success message for profile update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil mis à jour avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    },
    builder: (context, authState) {
      final user = authState.user;

      if (user == null) {
        return const Center(child: Text('User not found'));
      }

      // Populate controllers with current user data
      controllers.resetForUser(user.id, user);

      return Card(
        elevation: 8,
        shadowColor: Colors.black26,
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
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      "Informations personnelles",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),

                // Profile photo section
                _buildProfilePhotoSection(
                  context,
                  width,
                  height,
                  user,
                  controllers,
                ),

                SizedBox(height: height * 0.05),

                Divider(color: Colors.grey.shade300, thickness: 1),

                SizedBox(height: height * 0.03),

                // Responsive fields section
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return _buildVerticalFields(
                        context,
                        height,
                        width,
                        controllers,
                        user,
                      );
                    } else {
                      return _buildHorizontalFields(
                        context,
                        height,
                        width,
                        controllers,
                        user,
                      );
                    }
                  },
                ),

                SizedBox(height: height * 0.05),

                // Update button
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
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : () =>
                              _handleUpdateProfile(context, controllers, user),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: height * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: authState.status == AuthStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Mettre à jour le profil",
                            style: AppTextStyles.bodyWhite.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Profile photo section
Widget _buildProfilePhotoSection(
  BuildContext context,
  double width,
  double height,
  AppUser user,
  ProfilControllers controllers,
) {
  return Container(
    padding: EdgeInsets.all(width * 0.02),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            FutureBuilder<Uint8List?>(
              future: _getProfileImageFuture(controllers, user),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    radius: width * 0.05,
                    backgroundColor: const Color(0xFF4F7EFF),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => _pickImage(context, user, controllers),
                  child: CircleAvatar(
                    radius: width * 0.05,
                    backgroundColor: const Color(0xFF4F7EFF),
                    backgroundImage: snapshot.hasData && snapshot.data != null
                        ? MemoryImage(snapshot.data!)
                        : null,
                    child: snapshot.hasData && snapshot.data != null
                        ? null
                        : Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                  ),
                );
              },
            ),

          ],
        ),
        SizedBox(width: width * 0.03),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(context, user, controllers),
                icon: const Icon(Icons.photo_camera, size: 18),
                label: const Text("Changer la photo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                "JPG, PNG ou GIF. Taille maximale: 2Mo.",
                style: AppTextStyles.subtitle1.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<Uint8List?> _getProfileImageFuture(
  ProfilControllers controllers,
  AppUser user,
) async {
  // If we already have the image cached, return it
  if (controllers.cachedImageBytes != null) {
    return controllers.cachedImageBytes;
  }

  // Otherwise load it from Supabase Storage
  if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
    return await controllers.loadProfileImage(user.profileImageUrl!);
  }

  return null;
}

Widget _buildHorizontalFields(
  BuildContext context,
  double height,
  double width,
  ProfilControllers controllers,
  AppUser user,
) {
  return Column(
    children: [
      // First name and Last name
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildField(
              context,
              'Prénom',
              controllers.firstNameController,
              height,
              icon: Icons.person,
            ),
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: _buildField(
              context,
              'Nom',
              controllers.lastNameController,
              height,
              icon: Icons.person_outline,
            ),
          ),
        ],
      ),
      SizedBox(height: height * 0.03),

      // Email and Phone
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildField(
              context,
              'Email',
              controllers.profilEmailController,
              height,
              enabled: false,
              icon: Icons.email,
            ),
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: _buildField(
              context,
              'Téléphone',
              controllers.profilPhoneController,
              height,
              icon: Icons.phone,
            ),
          ),
        ],
      ),
      SizedBox(height: height * 0.03),

      // Specialization (only for doctors)
      if (user.isDoctor)
        _buildField(
          context,
          'Spécialisation',
          controllers.profilSpecializationController,
          height,
          icon: Icons.medical_services,
        ),
    ],
  );
}

Widget _buildVerticalFields(
  BuildContext context,
  double height,
  double width,
  ProfilControllers controllers,
  AppUser user,
) {
  return Column(
    children: [
      _buildField(
        context,
        'Prénom',
        controllers.firstNameController,
        height,
        icon: Icons.person,
      ),
      SizedBox(height: height * 0.03),
      _buildField(
        context,
        'Nom',
        controllers.lastNameController,
        height,
        icon: Icons.person_outline,
      ),
      SizedBox(height: height * 0.03),
      _buildField(
        context,
        'Email',
        controllers.profilEmailController,
        height,
        enabled: false,
        icon: Icons.email,
      ),
      SizedBox(height: height * 0.03),
      _buildField(
        context,
        'Téléphone',
        controllers.profilPhoneController,
        height,
        icon: Icons.phone,
      ),
      SizedBox(height: height * 0.03),
      if (user.isDoctor)
        _buildField(
          context,
          'Spécialisation',
          controllers.profilSpecializationController,
          height,
          icon: Icons.medical_services,
        ),
    ],
  );
}

Widget _buildField(
  BuildContext context,
  String label,
  TextEditingController controller,
  double height, {
  bool enabled = true,
  IconData? icon,
}) {
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
        enabled: enabled,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
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
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    ],
  );
}

// Handle profile update
Future<void> _handleUpdateProfile(
  BuildContext context,
  ProfilControllers controllers,
  AppUser user,
) async {
  try {
    // Create updated user object with profile photo path
    final updatedUser = user.copyWith(
      firstName: controllers.firstNameController.text.trim(),
      lastName: controllers.lastNameController.text.trim(),
      phone: controllers.profilPhoneController.text.trim(),
      specialization: controllers.profilSpecializationController.text.trim(),
      profileImageUrl: controllers.profileImageUrl ?? user.profileImageUrl,
      updatedAt: DateTime.now(),
    );

    // Update user through AuthBloc
    context.read<AuthBloc>().add(AuthUpdateProfile(updatedUser));
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

// Pick and upload image
Future<void> _pickImage(
  BuildContext context,
  AppUser user,
  ProfilControllers controllers,
) async {
  final ImagePicker picker = ImagePicker();

  try {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📤 Téléchargement de la photo...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      try {
        // Upload the image to Supabase Storage
        final imagePath = await controllers.uploadProfileImage(image, user.id);

        if (imagePath == null) {
          throw Exception('Failed to upload image');
        }

        // Update user with new photo path
        final updatedUser = user.copyWith(
          profileImageUrl: imagePath,
          updatedAt: DateTime.now(),
        );

        // Update through AuthBloc
        if (context.mounted) {
          context.read<AuthBloc>().add(AuthUpdateProfile(updatedUser));

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Photo de profil mise à jour avec succès!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
