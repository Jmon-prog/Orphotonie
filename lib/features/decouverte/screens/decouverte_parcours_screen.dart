// ============================================================
// Fichier : lib/features/decouverte/screens/decouverte_parcours_screen.dart
// Description : Écran de parcours d'activités du mode Découverte.
//               Affiche les activités choisies avec barre de progression,
//               permet de les lancer et de cocher celles terminées.
//               Propose de sauvegarder ou supprimer la liste à la fin.
//               Responsive. 100 % hors ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:drift/drift.dart' show Value;
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/router/app_router.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../decouverte_providers.dart';
import '../decouverte_session.dart';

class DecouverteParcourstScreen extends ConsumerStatefulWidget {
  const DecouverteParcourstScreen({
    super.key,
    required this.profileId,
  });

  final int profileId;

  @override
  ConsumerState<DecouverteParcourstScreen> createState() =>
      _DecouverteParcourstScreenState();
}

class _DecouverteParcourstScreenState
    extends ConsumerState<DecouverteParcourstScreen> {
  bool _building = false;

  @override
  void initState() {
    super.initState();
    // Crée le dictionnaire temporaire si ce n'est pas encore fait
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureBuilt());
  }

  Future<void> _ensureBuilt() async {
    final session = ref.read(decouverteProvider);
    if (session.tempDicId == null && !session.isLoading) {
      setState(() => _building = true);
      await ref
          .read(decouverteProvider.notifier)
          .buildParcours(widget.profileId);
      if (mounted) setState(() => _building = false);
    }
  }

  /// Lance un jeu depuis le parcours.
  /// Marque automatiquement l'activité comme terminée au retour.
  void _launchActivity(
    BuildContext context,
    DecouverteActivity activity,
    int dicId,
  ) {
    final uri = Uri(
      path: activity.route,
      queryParameters: {
        'dicId': dicId.toString(),
        'profileId': widget.profileId.toString(),
        'dicName': 'Découverte',
      },
    );
    context.push(uri.toString()).then((_) {
      if (mounted) {
        ref.read(decouverteProvider.notifier).markActivityDone(activity.route);
      }
    });
  }

  /// Propose de sauvegarder le dictionnaire ou de le supprimer.
  Future<void> _handleEnd() async {
    final session = ref.read(decouverteProvider);
    final dicId = session.tempDicId;

    if (dicId == null) {
      await ref.read(decouverteProvider.notifier).endSession();
      if (!mounted) return;
      context.go(AppRoutes.childHome);
      return;
    }

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminer la session'),
        content: const Text(
          'Veux-tu garder cette liste de mots pour y rejouer plus tard ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Non, supprimer'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Oui, sauvegarder'),
          ),
        ],
      ),
    );

    if (save == true) {
      // Demander un nom pour la liste
      final nameCtrl = TextEditingController(text: 'Découverte');
      if (!mounted) return;
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Nom de la liste'),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nom',
              hintText: 'Ex: Animaux, Niveau CP…',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(nameCtrl.text.trim()),
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      );

      if (name != null && name.isNotEmpty) {
        // Renommer le dictionnaire et l'assigner à l'enfant
        try {
          final praticienId =
              ref.read(currentPractitionerProvider)?.id ?? widget.profileId;
          final db = ref.read(appDatabaseProvider);
          // Changer le profileId pour appartenir au praticien + renommer
          await db.dictionariesDao.updateDictionary(
            DictionariesCompanion(
              id: Value(dicId),
              nom: Value(name),
              profileId: Value(praticienId),
            ),
          );
          // Créer l'assignation enfant
          await db.dictionaryAssignmentsDao.assignDictionary(
            dicId,
            widget.profileId,
          );
        } catch (_) {
          // En cas d'erreur, on supprime quand même
          await ref.read(decouverteProvider.notifier).endSession();
          if (!mounted) return;
          context.go(AppRoutes.childHome);
          return;
        }
        // Ne pas supprimer le dictionnaire — le notifier nettoie juste l'état
        ref.read(decouverteProvider.notifier).resetSession();
        if (!mounted) return;
        context.go(AppRoutes.childHome);
        return;
      }
    }

    // Supprimer + réinitialiser
    await ref.read(decouverteProvider.notifier).endSession();
    if (!mounted) return;
    context.go(AppRoutes.childHome);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(decouverteProvider);

    // Erreur lors de la construction du parcours
    if (!_building &&
        !session.isLoading &&
        session.tempDicId == null &&
        session.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon parcours')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  session.error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.childHome),
                  child: const Text('Retour à l\'accueil'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_building || session.isLoading || session.tempDicId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dicId = session.tempDicId!;
    final wordsLabel = session.wordsToLearn.isNotEmpty
        ? '${session.wordsToLearn.length} mot(s) à travailler'
        : '${session.words.length} mot(s)';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _handleEnd();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon parcours'),
          leading: BackButton(onPressed: () => _handleEnd()),
          actions: [
            TextButton.icon(
              onPressed: () => _handleEnd(),
              icon: const Icon(Icons.flag_rounded),
              label: const Text('Terminer'),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 16,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── En-tête résumé ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primaryContainer.withAlpha(70),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.explore_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                wordsLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Progression globale
                            Text(
                              '${session.doneCount}/${session.totalChosen}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Barre de progression
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: session.progressRatio,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Titre ────────────────────────────────────────────────
                      Text(
                        'Choisis tes activités',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Coche celles que tu veux faire, puis appuie pour jouer.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Grille des activités ─────────────────────────────────
                      ...kDecouverteActivities.map((activity) {
                        final isChosen = session.chosenActivityRoutes
                            .contains(activity.route);
                        final isDone =
                            session.doneActivityRoutes.contains(activity.route);
                        return _ActivityTile(
                          activity: activity,
                          isChosen: isChosen,
                          isDone: isDone,
                          onToggle: () => ref
                              .read(decouverteProvider.notifier)
                              .toggleActivity(activity.route),
                          onPlay: isChosen
                              ? () => _launchActivity(
                                    context,
                                    activity,
                                    dicId,
                                  )
                              : null,
                        );
                      }),

                      const SizedBox(height: 24),

                      // ── Bouton terminer ──────────────────────────────────────
                      if (session.parcoursComplete) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 40,
                                color: theme.colorScheme.tertiary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bravo ! Tu as terminé ton parcours !',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _handleEnd(),
                          icon: const Icon(Icons.flag_rounded),
                          label: const Text('Terminer la session'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
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
}

// ---------------------------------------------------------------------------
// Tuile d'activité
// ---------------------------------------------------------------------------

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.isChosen,
    required this.isDone,
    required this.onToggle,
    this.onPlay,
  });

  final DecouverteActivity activity;
  final bool isChosen;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback? onPlay;

  static IconData _iconForName(String name) {
    switch (name) {
      case 'flashcard':
        return Icons.style_rounded;
      case 'qcm':
        return Icons.quiz_rounded;
      case 'memory':
        return Icons.grid_view_rounded;
      case 'anagramme':
        return Icons.swap_horiz_rounded;
      case 'pendu':
        return Icons.text_fields_rounded;
      case 'syllabes':
        return Icons.record_voice_over_rounded;
      case 'mot_lacunaire':
        return Icons.edit_rounded;
      case 'mots_caches':
        return Icons.search_rounded;
      case 'mots_croises':
        return Icons.grid_on_rounded;
      default:
        return Icons.games_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(activity.color);

    return Semantics(
      label: '${activity.label}. ${activity.description}. '
          '${isDone ? "Terminé." : isChosen ? "Sélectionné." : "Non sélectionné."}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDone
                ? theme.colorScheme.tertiary
                : isChosen
                    ? color.withAlpha(180)
                    : theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        color: isDone
            ? theme.colorScheme.tertiaryContainer.withAlpha(80)
            : isChosen
                ? color.withAlpha(18)
                : theme.colorScheme.surfaceContainerHighest.withAlpha(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Checkbox de sélection
              Checkbox(
                value: isChosen,
                onChanged: (_) => onToggle(),
                activeColor: color,
              ),

              // Icône de l'activité
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withAlpha(isChosen ? 50 : 25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForName(activity.icon),
                  color: color.withAlpha(isChosen ? 220 : 120),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Nom + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isChosen
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withAlpha(130),
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      activity.description,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(110),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Boutons Jouer / Terminé
              if (isDone)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.tertiary,
                  size: 28,
                )
              else if (onPlay != null)
                IconButton(
                  icon: const Icon(Icons.play_arrow_rounded),
                  color: color,
                  tooltip: 'Jouer',
                  onPressed: onPlay,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
