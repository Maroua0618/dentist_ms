import 'dart:io';
import 'dart:typed_data';
import 'package:dentist_ms/core/models/app_user.dart';
import 'package:dentist_ms/features/auth/bloc/auth_event.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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
  final TextEditingController profilSpecializationController = TextEditingController();
  final TextEditingController profilePhotoPathController = TextEditingController(); // ADD THIS BACK
  
  String profilePhotoPath = '';
  Uint8List? selectedImage;
  
  int? _currentUserId;
  
  static final Map<String, Uint8List> _imageCache = {};

  Future<Uint8List?> loadProfileImage(String storedPath) async {
    try {
      final file = File(storedPath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        selectedImage = bytes;
        profilePhotoPath = storedPath;
        profilePhotoPathController.text = storedPath; // UPDATE THE CONTROLLER TOO
        _imageCache[storedPath] = bytes;
        return bytes;
      }
    } catch (e) {
      print('Image not found: $e');
    }
    return null;
  }
  Future<String> saveProfileImage(File image, int userId, BuildContext context) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      
      final String userProfileDir = path.join(
        appDir.path, 
        'profile_pictures', 
        'user_$userId'
      );
        
      final Directory dir = Directory(userProfileDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Clear existing files
      final files = dir.listSync();
      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }

      final String uniqueFileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String localPath = path.join(userProfileDir, uniqueFileName);
      
      final supabase = Supabase.instance.client;
      await supabase
        .from('users')
        .update({
          'profile_photo_path': localPath,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);

      await image.copy(localPath);
      final bytes = await image.readAsBytes();
      _imageCache[localPath] = bytes;
                  
      // Update local state
      profilePhotoPath = localPath;
      profilePhotoPathController.text = localPath; // UPDATE CONTROLLER
      selectedImage = bytes;
      
      return localPath;
    } catch (e) {
      throw Exception('Failed to save profile image: $e');
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
      profilePhotoPathController.text = user.profilePhotoPath ?? ''; // SET PHOTO PATH
      
      // Clear image cache for new user
      selectedImage = null;
      profilePhotoPath = user.profilePhotoPath ?? '';
      
      // Load profile image if exists
      if (user.profilePhotoPath != null && user.profilePhotoPath!.isNotEmpty) {
        loadProfileImage(user.profilePhotoPath!);
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
      if (profilePhotoPathController.text != (user.profilePhotoPath ?? '')) {
        profilePhotoPathController.text = user.profilePhotoPath ?? '';
      }
      
      // Update image if path changed
      if (user.profilePhotoPath != null && 
          user.profilePhotoPath != profilePhotoPath &&
          user.profilePhotoPath!.isNotEmpty) {
        loadProfileImage(user.profilePhotoPath!);
      }
    }
  }
  void updateFromUser(AppUser user) {
    if (_currentUserId == user.id) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      profilPhoneController.text = user.phone ?? '';
      profilSpecializationController.text = user.specialization ?? '';
      profilePhotoPathController.text = user.profilePhotoPath ?? ''; // UPDATE PHOTO PATH
      
      // Update image if path changed
      if (user.profilePhotoPath != null && 
          user.profilePhotoPath != profilePhotoPath) {
        loadProfileImage(user.profilePhotoPath!);
      }
    }
  }
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    profilEmailController.dispose();
    profilPhoneController.dispose();
    profilSpecializationController.dispose();
    profilePhotoPathController.dispose(); // DISPOSE THE CONTROLLER
  }
}

Widget profil(BuildContext context, double width, double height, ProfilControllers controllers) {
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
    },
    builder: (context, authState) {
      final user = authState.user;

      if (user == null) {
        return const Center(child: Text('User not found'));
      }

      // Populate controllers with current user data
      controllers.resetForUser(user.id, user);
      
      return Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Informations personnelles", style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: height * 0.03),

              // Profile photo section
              _buildProfilePhotoSection(context, width, height, user, controllers),

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
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : () => _handleUpdateProfile(context, controllers, user),
                  child: authState.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Mettre à jour le profil", style: AppTextStyles.bodyWhite),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

// Profile info section
Widget _buildProfilePhotoSection(BuildContext context, double width, double height, dynamic user, ProfilControllers controllers) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      FutureBuilder<Uint8List?>(
        future: _getProfileImageFuture(controllers, user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              radius: width * 0.04,
              backgroundColor: const Color(0xFF4F7EFF),
              child: const CircularProgressIndicator(color: Colors.white),
            );
          }
          
          return GestureDetector(
            onTap: () async {
              await _pickImage(context, user.id, controllers);
            },
            child: CircleAvatar(
              radius: width * 0.04,
              backgroundColor: const Color(0xFF4F7EFF),
              backgroundImage: snapshot.hasData && snapshot.data != null
                  ? MemoryImage(snapshot.data!)
                  : null,
              child: snapshot.hasData && snapshot.data != null
                  ? null
                  : Text(
                      user.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
            ),
          );
        },
      ),
      SizedBox(width: width * 0.02),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _pickImage(context, user.id, controllers);
                // Trigger rebuild
                (context as Element).markNeedsBuild();
              },
              child: const Text("Change Photo"),
            ),
            SizedBox(height: height * 0.01),
            Text("JPG, PNG ou GIF. Taille maximale: 2Mo.", style: AppTextStyles.subtitle1)
          ],
        ),
      )
    ],
  );
}

Future<Uint8List?> _getProfileImageFuture(ProfilControllers controllers, dynamic user) async {
  // If we already have the image cached, return it
  if (controllers.selectedImage != null) {
    return controllers.selectedImage;
  }
  
  // Otherwise load it from the path
  if (user.profilePhotoPath != null && user.profilePhotoPath!.isNotEmpty) {
    return await controllers.loadProfileImage(user.profilePhotoPath!);
  }
  
  return null;
}
Widget _buildHorizontalFields(BuildContext context, double height, double width, ProfilControllers controllers, dynamic user) {
  return Column(
    children: [
      // First name and Last name
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildField('Prénom', controllers.firstNameController, height)),
          SizedBox(width: width * 0.02),
          Expanded(child: _buildField('Nom', controllers.lastNameController, height)),
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
Widget _buildVerticalFields(BuildContext context, double height, double width, ProfilControllers controllers, dynamic user) {
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

// Handle profile update using ProfilBloc
Future<void> _handleUpdateProfile(BuildContext context, ProfilControllers controllers, AppUser user) async {
  try {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mise à jour en cours...')),
    );

    // Create updated user object WITH profile photo path FROM CONTROLLER
    final updatedUser = user.copyWith(
      firstName: controllers.firstNameController.text.trim(),
      lastName: controllers.lastNameController.text.trim(),
      phone: controllers.profilPhoneController.text.trim(),
      specialization: controllers.profilSpecializationController.text.trim(),
      profilePhotoPath: controllers.profilePhotoPathController.text.trim().isNotEmpty 
          ? controllers.profilePhotoPathController.text.trim() 
          : user.profilePhotoPath,
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
Future<void> _pickImage(BuildContext context, int userId, ProfilControllers controllers) async {
  final ImagePicker picker = ImagePicker();
  
  try {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sauvegarde de la photo...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      
      try {
        // Save the image
        String path = await controllers.saveProfileImage(File(image.path), userId, context);
        
        if (path == '') throw Exception();
        
        // After saving, load the new image
        await controllers.loadProfileImage(path);

        // Get current user and update with new photo path
        final authState = context.read<AuthBloc>().state;
        if (authState.user != null) {
          final updatedUser = authState.user!.copyWith(
            profilePhotoPath: path,
            updatedAt: DateTime.now(),
          );
          
          // Update user in AuthBloc
          context.read<AuthBloc>().add(AuthUpdateProfile(updatedUser));
        }

        // Show success
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Photo sauvegardée avec succès!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la sauvegarde: $e'),
              backgroundColor: Colors.red,
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
