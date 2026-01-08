import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  final SupabaseClient _client;
  final ImagePicker _picker = ImagePicker();

  ImageUploadService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }


  Future<String> uploadImage({
    required XFile imageFile,
    String bucketName = 'profile-images',
    String? folderPath,
    required String fileName,
  }) async {
    try {
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Construct the full path
      final String fullPath = folderPath != null
          ? '$folderPath$fileName'
          : fileName;

      // Upload to Supabase Storage
      await _client.storage
          .from(bucketName)
          .uploadBinary(
            fullPath,
            bytes,
            fileOptions: FileOptions(
              upsert: true, // Overwrite if exists
              contentType: 'image/${imageFile.path.split('. ').last}',
            ),
          );

      // Get public URL
      final String publicUrl = _client.storage
          .from(bucketName)
          .getPublicUrl(fullPath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete image from Supabase Storage
  Future<void> deleteImage({
    required String imageUrl,
    String bucketName = 'profile-images',
  }) async {
    try {
      // Extract the file path from the public URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the bucket name index and get the path after it
      final bucketIndex = pathSegments.indexOf(bucketName);
      if (bucketIndex == -1) {
        throw Exception('Invalid image URL format');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      // Delete from storage
      await _client.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Show image picker dialog (Gallery or Camera)
  Future<XFile?> showImageSourceDialog({
    required Future<void> Function() onGalleryTap,
    required Future<void> Function() onCameraTap,
  }) async {
    return null;
  }
}
