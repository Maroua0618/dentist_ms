import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dentist_ms/core/services/image_upload_service.dart';
import 'package:dentist_ms/core/constants/app_colors.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? currentImageUrl;
  final double radius;
  final Function(String imageUrl) onImageUploaded;
  final String uploadFolder; // 'patients/' or 'users/'
  final String fileName;

  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    this.radius = 50,
    required this.onImageUploaded,
    required this.uploadFolder,
    required this.fileName,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImageUploadService _imageService = ImageUploadService();
  bool _isUploading = false;
  XFile? _selectedImage;

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap:  () async {
                Navigator.pop(context);
                await _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      setState(() => _isUploading = true);

      XFile? image;
      if (source == ImageSource.gallery) {
        image = await _imageService.pickImageFromGallery();
      } else {
        image = await _imageService.pickImageFromCamera();
      }

      if (image == null) {
        setState(() => _isUploading = false);
        return;
      }

      setState(() => _selectedImage = image);

      // Upload to Supabase
      final imageUrl = await _imageService.uploadImage(
        imageFile: image,
        folderPath: widget.uploadFolder,
        fileName: widget.fileName,
      );

      // Notify parent
      widget.onImageUploaded(imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully! '),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text('Failed to upload image: $e'),
            backgroundColor: Colors. red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius:  widget.radius,
          backgroundColor: AppColors.primary. withOpacity(0.1),
          backgroundImage: _getImageProvider(),
          child: _getPlaceholder(),
        ),
        if (_isUploading)
          Positioned. fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap:  _isUploading ? null : _showImageSourceDialog,
            child:  Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider?  _getImageProvider() {
    if (_selectedImage != null) {
      return FileImage(File(_selectedImage!.path));
    } else if (widget.currentImageUrl != null &&
        widget.currentImageUrl! .isNotEmpty) {
      return NetworkImage(widget.currentImageUrl! );
    }
    return null;
  }

  Widget?  _getPlaceholder() {
    if (_selectedImage == null && 
        (widget.currentImageUrl == null || widget.currentImageUrl!.isEmpty)) {
      return Icon(
        Icons.person,
        size: widget.radius,
        color: AppColors.primary. withOpacity(0.5),
      );
    }
    return null;
  }
}