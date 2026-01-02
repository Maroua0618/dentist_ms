import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DocumentViewerDialog extends StatefulWidget {
  final String filePath;
  final String fileName;
  final String fileType;

  const DocumentViewerDialog({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.fileType,
  });

  @override
  State<DocumentViewerDialog> createState() => _DocumentViewerDialogState();
}

class _DocumentViewerDialogState extends State<DocumentViewerDialog> {
  bool isLoading = true;
  String? localFilePath;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      setState(() => isLoading = true);

      // Get the public URL
      final url = Supabase.instance.client.storage
          .from('documents')
          .getPublicUrl(widget.filePath);

      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Échec du téléchargement du document');
      }

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${widget.fileName}');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        localFilePath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _openExternally() async {
    if (localFilePath == null) return;

    try {
      final uri = Uri.file(localFilePath!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImageViewer() {
    if (localFilePath == null) return const SizedBox();
    
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.file(
          File(localFilePath!),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPdfPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 24),
          Text(
            widget.fileName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Fichier PDF',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Ouvrir dans le lecteur PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 80, color: Colors.indigo.shade400),
          const SizedBox(height: 24),
          Text(
            widget.fileName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Document ${widget.fileType.toUpperCase()}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Ouvrir dans l\'application'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewer() {
    final fileType = widget.fileType.toLowerCase();
    
    if (fileType == 'jpg' || fileType == 'jpeg' || fileType == 'png') {
      return _buildImageViewer();
    } else if (fileType == 'pdf') {
      return _buildPdfPlaceholder();
    } else {
      return _buildDocPlaceholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visualisation du document',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.fileName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Fermer',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF3B82F6)),
                          SizedBox(height: 16),
                          Text('Chargement du document...'),
                        ],
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur de chargement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                errorMessage!,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _buildViewer(),
            ),

            // Footer buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (localFilePath != null)
                  TextButton.icon(
                    onPressed: _openExternally,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Ouvrir en externe'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                    ),
                  ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                  ),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
