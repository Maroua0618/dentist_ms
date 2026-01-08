import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientImageService {
  final ImagePicker _picker = ImagePicker();
  static final Map<String, Uint8List> _imageCache = {};

  /// Load profile image from Supabase Storage
  Future<Uint8List?> loadProfileImage(String imagePath) async {
    try {
      if (imagePath.isEmpty) return null;

      // Check cache first
      if (_imageCache.containsKey(imagePath)) {
        return _imageCache[imagePath];
      }

      // Download image bytes from Supabase Storage
      final response = await Supabase.instance.client.storage
          .from('patients-photos')
          .download(imagePath);

      // Cache the image
      _imageCache[imagePath] = response;
      return response;
    } catch (e) {
      print('Error loading patient profile image: $e');
      return null;
    }
  }

  /// Upload profile image to Supabase Storage
  Future<String?> uploadProfileImage(XFile imageFile, int patientId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExtension = imageFile.path.split('.').last;
      final fileName =
          'patient_$patientId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('patients-photos')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$fileExtension',
            ),
          );

      // Update database with new photo URL
      await Supabase.instance.client
          .from('patients')
          .update({
            'profile_image_url': fileName,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', patientId);

      // Cache the image
      _imageCache[fileName] = bytes;

      return fileName;
    } catch (e) {
      print('Error uploading patient profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Clear image cache
  static void clearCache() {
    _imageCache.clear();
  }
}
