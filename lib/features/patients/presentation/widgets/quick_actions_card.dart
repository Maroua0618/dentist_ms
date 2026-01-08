import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickActionsCard({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment. topLeft,
          end:  Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0x0D8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x338B5CF6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.flash_on,
                size: 24,
                color: Color(0xFF1E293B),
              ),
              SizedBox(width: 8),
              Text(
                'Actions rapides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Ajouter un rendez-vous',
            Icons.calendar_month,
            true,
            () => onActionTap('Add Appointment'),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Ajouter un dossier médical',
            Icons.note_add,
            false,
            () => onActionTap('Add Medical Record'),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Modifier le profil',
            Icons.edit_outlined,
            false,
            () => onActionTap('Edit Profile'),
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Supprimer le patient',
            Icons.delete_forever,
            false,
            () => onActionTap('Delete Patient'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    bool isPrimary,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:  onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isPrimary ?  const Color(0xFF3B82F6) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                      blurRadius:  8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? const Color(0xFFFFFFFF) : const Color(0xFF1E293B),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? const Color(0xFFFFFFFF) : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}