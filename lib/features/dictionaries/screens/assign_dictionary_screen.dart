// ============================================================
// Fichier : lib/features/dictionaries/screens/assign_dictionary_screen.dart
// Description : Écran de gestion des assignations d'un dictionnaire.
//               Le praticien coche/décoche les enfants auxquels le dictionnaire
//               est accessible en lecture seule.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/shimmer_list.dart';

/// Écran permettant au praticien d'assigner ou retirer un dictionnaire
/// pour un ou plusieurs enfants.
class AssignDictionaryScreen extends ConsumerWidget {
  const AssignDictionaryScreen({super.key, required this.dictionary});

  final Dictionary dictionary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Flux des IDs d'enfants actuellement assignés
    final assignedIdsStream = ref
        .watch(dictionaryAssignmentsDaoProvider)
        .watchAssignedChildIds(dictionary.id);

    // Flux de tous les enfants du praticien connecté
    final enfantsStream =
        ref.watch(profilesDaoProvider).watchProfilesByType('enfant');

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Assigner le dictionnaire',
        subtitle: dictionary.nom,
      ),
      body: StreamBuilder<List<int>>(
        stream: assignedIdsStream,
        builder: (context, assignedSnap) {
          return StreamBuilder<List<Profile>>(
            stream: enfantsStream,
            builder: (context, enfantsSnap) {
              if (enfantsSnap.connectionState == ConnectionState.waiting ||
                  assignedSnap.connectionState == ConnectionState.waiting) {
                return const ShimmerListView();
              }

              final enfants = enfantsSnap.data ?? [];
              final assignedIds = assignedSnap.data ?? [];

              if (enfants.isEmpty) {
                return const EmptyState(
                  icon: Icons.child_care_outlined,
                  title: 'Aucun profil enfant',
                  description:
                      'Créez d\'abord un profil enfant pour assigner des dictionnaires.',
                );
              }

              return Column(
                children: [
                  // En-tête explicatif
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Les enfants cochés voient ce dictionnaire en lecture seule.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Liste des enfants avec case à cocher
                  Expanded(
                    child: ListView.builder(
                      itemCount: enfants.length,
                      itemBuilder: (context, i) {
                        final enfant = enfants[i];
                        final isAssigned = assignedIds.contains(enfant.id);
                        return _EnfantAssignTile(
                          enfant: enfant,
                          isAssigned: isAssigned,
                          dictionaryId: dictionary.id,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tuile enfant avec toggle d'assignation
// ---------------------------------------------------------------------------

class _EnfantAssignTile extends ConsumerWidget {
  const _EnfantAssignTile({
    required this.enfant,
    required this.isAssigned,
    required this.dictionaryId,
  });

  final Profile enfant;
  final bool isAssigned;
  final int dictionaryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.read(dictionaryAssignmentsDaoProvider);

    return Semantics(
      label:
          '${enfant.prenom} — ${isAssigned ? 'assigné' : 'non assigné'}. Appuyer pour basculer.',
      child: CheckboxListTile(
        secondary: ProfileAvatar(
          profileId: enfant.id,
          prenom: enfant.prenom,
          avatarPath: enfant.avatarPath,
        ),
        title: Text(enfant.prenom),
        subtitle: isAssigned
            ? const Text(
                'Accès lecture seule activé',
                style: TextStyle(color: Colors.green),
              )
            : const Text('Pas d\'accès'),
        value: isAssigned,
        onChanged: (_) async {
          try {
            if (isAssigned) {
              await dao.unassignDictionary(dictionaryId, enfant.id);
            } else {
              await dao.assignDictionary(dictionaryId, enfant.id);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur : $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
