import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_bloc.dart';
import 'package:dentist_ms/features/patients/bloc/patient_event.dart';

void showDeletePatientDialog({
  required BuildContext context,
  required Map<String, dynamic> patient,
  required VoidCallback onDelete,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFFFFFFFF),
      title: const Text(
        'Supprimer le patient',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
      content: const Text(
        'Êtes-vous sûr de vouloir supprimer ce patient ?  Cette action ne peut pas être annulée.',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: Color(0xFF1E293B),
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.pop(dialogContext);

            final idValue = patient['id'];
            int? idInt;
            if (idValue == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Impossible de supprimer :  le patient n\'a pas d\'ID',
                  ),
                ),
              );
              return;
            }
            if (idValue is int) {
              idInt = idValue;
            } else {
              idInt = int.tryParse(idValue.toString());
            }

            if (idInt == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Impossible de supprimer : ID de patient invalide',
                  ),
                ),
              );
              return;
            }

            context.read<PatientBloc>().add(DeletePatient(idInt));
            onDelete();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Suppression du patient.. .')),
            );
          },
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
}
