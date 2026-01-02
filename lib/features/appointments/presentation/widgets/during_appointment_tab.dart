import 'package:flutter/material.dart';

class DuringAppointmentTab extends StatelessWidget {
  final bool isAppointmentStarted;
  final bool isAppointmentCompleted;

  const DuringAppointmentTab({
    super.key,
    required this.isAppointmentStarted,
    required this.isAppointmentCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAppointmentCompleted
                ? const Color(0xFF10B981).withOpacity(0.1)
                : isAppointmentStarted
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAppointmentCompleted
                  ? const Color(0xFF10B981)
                  : isAppointmentStarted
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isAppointmentCompleted
                    ? Icons.check_circle
                    : isAppointmentStarted
                    ? Icons.check_circle
                    : Icons.info,
                color: isAppointmentCompleted
                    ? const Color(0xFF10B981)
                    : isAppointmentStarted
                    ? const Color(0xFF10B981)
                    : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isAppointmentCompleted
                      ? 'Rendez-vous Terminé'
                      : isAppointmentStarted
                      ? 'Le rendez-vous est en cours'
                      : 'Démarrez le rendez-vous pour ajouter des enregistrements',
                  style: TextStyle(
                    fontSize: 13,
                    color: isAppointmentCompleted
                        ? const Color(0xFF10B981)
                        : isAppointmentStarted
                        ? const Color(0xFF10B981)
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enregistrement audio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isAppointmentStarted && !isAppointmentCompleted)
                      ? const Color(0xFF3B82F6).withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.mic,
                  color: (isAppointmentStarted && !isAppointmentCompleted)
                      ? const Color(0xFF3B82F6)
                      : Colors.grey[400],
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enregistrer les remarques du patient',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enregistrez des notes vocales sur le rendez-vous',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: (isAppointmentStarted && !isAppointmentCompleted)
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonction d\'enregistrement à venir'),
                        ),
                      )
                    : null,
                icon: const Icon(Icons.fiber_manual_record),
                label: const Text('Démarrer l\'enregistrement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  disabledBackgroundColor: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Notes cliniques',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: isAppointmentStarted && !isAppointmentCompleted,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Ajouter des notes cliniques pendant le rendez-vous...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            filled: true,
            fillColor: (isAppointmentStarted && !isAppointmentCompleted)
                ? Colors.white
                : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 24),
        const Text(
          'Charger des fichiers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (isAppointmentStarted && !isAppointmentCompleted)
                ? Colors.grey[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: (isAppointmentStarted && !isAppointmentCompleted)
                    ? const Color(0xFF3B82F6)
                    : Colors.grey[400],
              ),
              const SizedBox(height: 12),
              const Text(
                'Glissez et déposez les fichiers ici',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ou',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: (isAppointmentStarted && !isAppointmentCompleted)
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fonction de téléchargement de fichiers à venir',
                          ),
                        ),
                      )
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Choisir des fichiers'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  disabledBackgroundColor: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
