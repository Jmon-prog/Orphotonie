// ============================================================
// Fichier : lib/features/games/praticien_jeux_screen.dart
//
// Écran "Jeux" du gestionnaire.
// Liste les dictionnaires disponibles et permet de lancer
// les différents jeux pédagogiques ainsi que les fiches PDF.
// 100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_providers.dart';
import '../../core/router/app_router.dart';
import '../auth/notifiers/auth_notifier.dart';

/// Écran "Jeux" — liste les dictionnaires et propose les activités
/// pédagogiques disponibles pour chacun.
class PraticienJeuxScreen extends ConsumerWidget {
  const PraticienJeuxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final profile = switch (authState) {
      PractitionerAuth(profile: final p) => p,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeux'),
        actions: [
          Semantics(
            label: 'Paramètres',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Paramètres',
              onPressed: () => context.go(AppRoutes.parametres),
            ),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : _DictionaryPrintList(profile: profile),
    );
  }
}

// ---------------------------------------------------------------------------
// Liste des dictionnaires avec bouton d'impression
// ---------------------------------------------------------------------------

class _DictionaryPrintList extends ConsumerWidget {
  const _DictionaryPrintList({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dicsAsync = ref
        .watch(dictionariesDaoProvider)
        .watchDictionariesForPractitioner(profile.id)
        .map((list) => list);

    return StreamBuilder<List<Dictionary>>(
      stream: dicsAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final dics = snapshot.data ?? [];

        if (dics.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aucun dictionnaire',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez un dictionnaire de mots dans l\'espace\n'
                    '"Dictionnaires" pour lancer les jeux.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Aller aux dictionnaires'),
                    onPressed: () =>
                        context.go(AppRoutes.praticienDictionnaires),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: dics.length,
          itemBuilder: (ctx, i) =>
              _DictionaryPrintTile(dic: dics[i], profileId: profile.id),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tuile individuelle pour un dictionnaire
// ---------------------------------------------------------------------------

class _DictionaryPrintTile extends ConsumerStatefulWidget {
  const _DictionaryPrintTile({
    required this.dic,
    required this.profileId,
  });

  final Dictionary dic;
  final int profileId;

  @override
  ConsumerState<_DictionaryPrintTile> createState() =>
      _DictionaryPrintTileState();
}

class _DictionaryPrintTileState extends ConsumerState<_DictionaryPrintTile> {
  void _openExerciseSheet() {
    context.push(
      '/praticien/dictionnaires/${widget.dic.id}/fiches'
      '?nom=${Uri.encodeComponent(widget.dic.nom)}',
    );
  }

  void _openGame(String route) {
    final params = 'dicId=${widget.dic.id}'
        '&profileId=${widget.profileId}'
        '&dicName=${Uri.encodeComponent(widget.dic.nom)}';
    context.push('$route?$params');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            Icons.menu_book_outlined,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          widget.dic.nom,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: widget.dic.description?.isNotEmpty == true
            ? Text(
                widget.dic.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Activités classiques
                _GameButton(
                  icon: Icons.text_fields,
                  label: 'Anagramme',
                  onTap: () => _openGame(AppRoutes.anagramme),
                ),
                _GameButton(
                  icon: Icons.man,
                  label: 'Pendu',
                  onTap: () => _openGame(AppRoutes.pendu),
                ),
                _GameButton(
                  icon: Icons.text_snippet_outlined,
                  label: 'Mot lacunaire',
                  onTap: () => _openGame(AppRoutes.motLacunaire),
                ),
                _GameButton(
                  icon: Icons.grid_view_outlined,
                  label: 'Mots cachés',
                  onTap: () => _openGame(AppRoutes.motsCaches),
                ),
                _GameButton(
                  icon: Icons.grid_on_outlined,
                  label: 'Mots croisés',
                  onTap: () => _openGame(AppRoutes.motsCroises),
                ),
                // Nouvelles activités
                _GameButton(
                  icon: Icons.style_outlined,
                  label: 'Flashcard',
                  onTap: () => _openGame(AppRoutes.flashcard),
                ),
                _GameButton(
                  icon: Icons.quiz_outlined,
                  label: 'QCM Définition',
                  onTap: () => _openGame(AppRoutes.definitionQcm),
                ),
                _GameButton(
                  icon: Icons.record_voice_over_outlined,
                  label: 'Syllabes',
                  onTap: () => _openGame(AppRoutes.roueSyllabes),
                ),
                _GameButton(
                  icon: Icons.grid_view_rounded,
                  label: 'Memory',
                  onTap: () => _openGame(AppRoutes.memory),
                ),
                // Fiche PDF
                _GameButton(
                  icon: Icons.print_outlined,
                  label: 'Fiche PDF',
                  onTap: _openExerciseSheet,
                  filled: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bouton jeu compact
// ---------------------------------------------------------------------------

class _GameButton extends StatelessWidget {
  const _GameButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (filled) {
      return Semantics(
        button: true,
        label: label,
        child: FilledButton.tonalIcon(
          onPressed: onTap,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: theme.textTheme.labelMedium,
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      label: label,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: theme.textTheme.labelMedium,
        ),
      ),
    );
  }
}
