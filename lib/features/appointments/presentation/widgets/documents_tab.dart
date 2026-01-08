import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../models/appointment_model.dart';
import 'document_viewer_dialog.dart';

class DocumentsTab extends StatefulWidget {
  final Appointment appointment;

  const DocumentsTab({super.key, required this.appointment});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  List<Map<String, dynamic>> documents = [];
  bool isLoadingDocuments = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => isLoadingDocuments = true);
    try {
      if (widget.appointment.patientId == null) {
        debugPrint('⚠️ Patient ID is null, cannot load documents');
        setState(() => isLoadingDocuments = false);
        return;
      }

      final response = await Supabase.instance.client
          .from('patient_documents')
          .select(
            '*, uploader:users!uploaded_by_user_id(first_name, last_name)',
          )
          .eq('patient_id', widget.appointment.patientId!)
          .order('uploaded_at', ascending: false);

      debugPrint('📄 Loaded ${(response as List).length} documents');

      setState(() {
        documents = List<Map<String, dynamic>>.from(response).map((doc) {
          return {
            ...doc,
            'uploader_name': (doc['uploader'] != null)
                ? '${doc['uploader']['first_name']} ${doc['uploader']['last_name']}'
                : 'Inconnu',
          };
        }).toList();
        isLoadingDocuments = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading documents: $e');
      setState(() => isLoadingDocuments = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des documents: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadDocument() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final fileExtension = fileName.split('.').last;

      // Show description dialog
      String? description = await _showDescriptionDialog();
      if (description == null) return;

      setState(() => isUploading = true);

      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userResp = await Supabase.instance.client
          .from('users')
          .select('id')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userResp == null) {
        throw Exception('User not found in database');
      }

      final userId = userResp['id'] as int;

      // Upload file to Supabase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath =
          'patient_documents/${widget.appointment.patientId}/$timestamp-$fileName';

      await Supabase.instance.client.storage
          .from('documents')
          .upload(storagePath, file);

      // Get public URL
      final fileUrl = Supabase.instance.client.storage
          .from('documents')
          .getPublicUrl(storagePath);

      // Insert record into database
      await Supabase.instance.client.from('patient_documents').insert({
        'patient_id': widget.appointment.patientId,
        'uploaded_by_user_id': userId,
        'file_name': fileName,
        'file_path': storagePath,
        'file_type': fileExtension,
        'uploaded_at': DateTime.now().toIso8601String(),
        'description': description,
        'appointment_id': int.parse(widget.appointment.id),
      });

      setState(() => isUploading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Document téléchargé avec succès'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }

      // Reload documents
      _loadDocuments();
    } catch (e) {
      setState(() => isUploading = false);
      debugPrint('❌ Error uploading document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showDescriptionDialog() async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Description du document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            hintText: 'Ex: Radio dentaire, Résultats d\'analyse...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDocument(int documentId, String filePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Delete from storage
      await Supabase.instance.client.storage.from('documents').remove([
        filePath,
      ]);

      // Delete from database
      await Supabase.instance.client
          .from('patient_documents')
          .delete()
          .eq('id', documentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Document supprimé avec succès'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }

      // Reload documents
      _loadDocuments();
    } catch (e) {
      debugPrint('❌ Error deleting document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _viewDocument(
    String filePath,
    String fileName,
    String fileType,
  ) async {
    showDialog(
      context: context,
      builder: (context) => DocumentViewerDialog(
        filePath: filePath,
        fileName: fileName,
        fileType: fileType,
      ),
    );
  }

  Future<void> _downloadDocument(String filePath, String fileName) async {
    try {
      final url = Supabase.instance.client.storage
          .from('documents')
          .getPublicUrl(filePath);

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Impossible d\'ouvrir le document');
      }
    } catch (e) {
      debugPrint('❌ Error opening document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ouverture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.blue;
      case 'doc':
      case 'docx':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingDocuments) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with upload button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Documents du patient',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            ElevatedButton.icon(
              onPressed: isUploading ? null : _uploadDocument,
              icon: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(isUploading ? 'Téléchargement...' : 'Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Documents list
        if (documents.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun document',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = documents[index];
              final fileType = doc['file_type'] as String? ?? '';
              final fileName = doc['file_name'] as String? ?? 'Document';
              final description = doc['description'] as String? ?? '';
              final uploadedAt = doc['uploaded_at'] != null
                  ? DateTime.parse(doc['uploaded_at'])
                  : DateTime.now();
              final uploaderName = doc['uploader_name'] as String? ?? 'Inconnu';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    // File icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getFileColor(fileType).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getFileIcon(fileType),
                        color: _getFileColor(fileType),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // File info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            'Téléchargé par $uploaderName • ${DateFormat('d MMM yyyy').format(uploadedAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onSelected: (value) {
                        if (value == 'view') {
                          _viewDocument(
                            doc['file_path'],
                            doc['file_name'],
                            doc['file_type'] ?? '',
                          );
                        } else if (value == 'download') {
                          _downloadDocument(doc['file_path'], doc['file_name']);
                        } else if (value == 'delete') {
                          _deleteDocument(doc['id'], doc['file_path']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 18),
                              SizedBox(width: 12),
                              Text('Voir'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              Icon(Icons.download, size: 18),
                              SizedBox(width: 12),
                              Text('Télécharger'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
