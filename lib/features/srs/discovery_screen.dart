// ============================================================
// Fichier : lib/features/srs/discovery_screen.dart
// Description : Écran de découverte d'un nouveau mot (nbSeen = 0).
//               Affiche la fiche mot (image, définition, prononciation).
//               Choix : « Je connais » → Boîte 2 / « Je découvre » → Boîte 1.
//               Responsive mobile/tablette/desktop. 100 % hors-ligne.
// ============================================================

import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_providers.dart';
import 'models/srs_state_model.dart';

/// Résultat retourné par l'écran de découverte.
enum DiscoveryResult {
  /// L'enfant connaît le mot → Boîte 2.
  known,

  /// L'enfant ne connaît pas → Boîte 1, présentation complète.
  unknown,
}

/// Écran de découverte d'un nouveau mot.
///
/// Affiché avant les jeux pour les mots avec `nbSeen == 0`.
/// Retourne [DiscoveryResult] via `Navigator.pop`.
class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({
    super.key,
    required this.word,
    required this.profileId,
  });

  /// Le mot à découvrir.
  final Word word;

  /// Profil actif.
  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Découverte'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 48 : 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Carte du mot
                      Semantics(
                        label: 'Fiche du mot ${word.mot}',
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Image du mot (si disponible)
                                if (word.imagePath != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(word.imagePath!),
                                      height: isWide ? 200 : 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                if (word.imagePath != null)
                                  const SizedBox(height: 16),

                                // Le mot
                                Semantics(
                                  header: true,
                                  child: Text(
                                    word.mot,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Définition
                                if (word.definition != null &&
                                    word.definition!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      word.definition!,
                                      style: theme.textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Question
                      Text(
                        'Est-ce que tu connais ce mot ?',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Boutons de réponse
                      if (isWide)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildKnownButton(context, ref),
                            const SizedBox(width: 16),
                            _buildUnknownButton(context, ref),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildKnownButton(context, ref),
                            const SizedBox(height: 12),
                            _buildUnknownButton(context, ref),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKnownButton(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: 'Je connais ce mot',
      child: ElevatedButton.icon(
        onPressed: () => _handleChoice(
          context,
          ref,
          DiscoveryResult.known,
        ),
        icon: const Icon(Icons.check_circle),
        label: const Text('Oui, je connais !'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUnknownButton(BuildContext context, WidgetRef ref) {
    return Semantics(
      button: true,
      label: 'Je ne connais pas ce mot',
      child: OutlinedButton.icon(
        onPressed: () => _handleChoice(
          context,
          ref,
          DiscoveryResult.unknown,
        ),
        icon: const Icon(Icons.help_outline),
        label: const Text('Non, je découvre'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// Gère le choix de l'enfant et met à jour la boîte Leitner.
  Future<void> _handleChoice(
    BuildContext context,
    WidgetRef ref,
    DiscoveryResult result,
  ) async {
    try {
      final wordsDao = ref.read(wordsDaoProvider);
      final newBox = result == DiscoveryResult.known ? 2 : 1;
      final now = DateTime.now();

      // Créer ou mettre à jour la maîtrise
      await wordsDao.upsertMastery(
        WordMasteryCompanion(
          profileId: drift.Value(profileId),
          wordId: drift.Value(word.id),
          nbSeen: const drift.Value(0),
          nbSuccess: const drift.Value(0),
          nbFirstTry: const drift.Value(0),
          consecutiveOk: const drift.Value(0),
          leitnerBox: drift.Value(newBox),
          nextReview: drift.Value(
            now.add(Duration(days: kLeitnerDelays[newBox]!)),
          ),
          lastSeen: drift.Value(now),
          masteryLevel: const drift.Value(0),
        ),
      );

      if (context.mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la sauvegarde. Réessaie !'),
          ),
        );
      }
    }
  }
}
