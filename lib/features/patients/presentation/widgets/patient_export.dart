import 'package:flutter/material.dart';

class PatientExportDialog extends StatelessWidget {
  final VoidCallback onExportCSV;
  final VoidCallback onExportExcel;
  final VoidCallback onExportPDF;

  const PatientExportDialog({
    super.key,
    required this.onExportCSV,
    required this.onExportExcel,
    required this.onExportPDF,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.file_download, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Exporter les données',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choisissez le format d\'exportation: ',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          _buildExportOption(
            context: context,
            icon: Icons.table_chart,
            title: 'CSV',
            subtitle: 'Fichier texte séparé par des virgules',
            color: const Color(0xFF059669),
            onTap: () {
              Navigator.pop(context);
              onExportCSV();
            },
          ),

          const SizedBox(height: 12),

          _buildExportOption(
            context: context,
            icon: Icons.description,
            title: 'Excel',
            subtitle: 'Feuille de calcul Microsoft Excel',
            color: const Color(0xFF10B981),
            onTap: () {
              Navigator.pop(context);
              onExportExcel();
            },
          ),

          const SizedBox(height: 12),

          _buildExportOption(
            context: context,
            icon: Icons.picture_as_pdf,
            title: 'PDF',
            subtitle: 'Document portable',
            color: const Color(0xFFDC2626),
            onTap: () {
              Navigator.pop(context);
              onExportPDF();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
