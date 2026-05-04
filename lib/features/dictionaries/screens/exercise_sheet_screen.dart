// ============================================================
// Fichier : lib/features/dictionaries/screens/exercise_sheet_screen.dart
// Description : Page complète de génération de fiches d'exercices imprimables.
//               Panneau gauche : configuration (type, options, bouton générer).
//               Panneau droit : aperçu de la liste de mots.
//               Responsive : onglets sur mobile, double panneau sur bureau.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../pdf/exercise_pdf_generator.dart';

// ---------------------------------------------------------------------------
// Constantes de layout
// ---------------------------------------------------------------------------

const double _kSidebarWidth = 340;
const double _kBreakpoint = 680;

// ---------------------------------------------------------------------------
// Icônes par type d'exercice
// ---------------------------------------------------------------------------

const _typeIcons = <ExerciseType, IconData>{
  ExerciseType.wordList: Icons.list_alt_rounded,
  ExerciseType.anagram: Icons.shuffle_rounded,
  ExerciseType.gapFill: Icons.text_fields_rounded,
  ExerciseType.wordSearch: Icons.grid_4x4_rounded,
  ExerciseType.crossword: Icons.grid_on_rounded,
};

// ---------------------------------------------------------------------------
// Écran principal
// ---------------------------------------------------------------------------

/// Écran "Fiches d'exercices" — configuration + aperçu côte à côte.
class ExerciseSheetScreen extends ConsumerStatefulWidget {
  const ExerciseSheetScreen({
    super.key,
    required this.dictionaryId,
    required this.dictionaryName,
  });

  final int dictionaryId;
  final String dictionaryName;

  @override
  ConsumerState<ExerciseSheetScreen> createState() =>
      _ExerciseSheetScreenState();
}

class _ExerciseSheetScreenState extends ConsumerState<ExerciseSheetScreen> {
  ExerciseType _selectedType = ExerciseType.wordList;
  bool _includeAnswerKey = true;
  bool _generating = false;

  Future<void> _generate(List<Word> words) async {
    if (_generating) return;

    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce dictionnaire ne contient aucun mot.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _generating = true);
    try {
      await ExercisePdfGenerator.generateAndOpen(
        dictionaryName: widget.dictionaryName,
        words: words,
        type: _selectedType,
        includeAnswerKey: _includeAnswerKey,
      );
    } catch (e, stack) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Erreur de génération PDF'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Type : ${_selectedType.label}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    'Message :\n$e',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    'Stack trace :\n$stack',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordsStream = ref
        .watch(wordsDaoProvider)
        .watchWordsForDictionary(widget.dictionaryId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fiches d\'exercices'),
            Text(
              widget.dictionaryName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Word>>(
        stream: wordsStream,
        builder: (context, snapshot) {
          final words = snapshot.data ?? [];
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= _kBreakpoint) {
                return _WideLayout(
                  words: words,
                  dictionaryName: widget.dictionaryName,
                  selectedType: _selectedType,
                  includeAnswerKey: _includeAnswerKey,
                  generating: _generating,
                  onTypeChanged: (t) => setState(() => _selectedType = t),
                  onAnswerKeyChanged: (v) =>
                      setState(() => _includeAnswerKey = v),
                  onGenerate: () => _generate(words),
                );
              }
              return _NarrowLayout(
                words: words,
                dictionaryName: widget.dictionaryName,
                selectedType: _selectedType,
                includeAnswerKey: _includeAnswerKey,
                generating: _generating,
                onTypeChanged: (t) => setState(() => _selectedType = t),
                onAnswerKeyChanged: (v) =>
                    setState(() => _includeAnswerKey = v),
                onGenerate: () => _generate(words),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout bureau (>= 680px) : sidebar gauche + panneau droit
// ---------------------------------------------------------------------------

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.words,
    required this.dictionaryName,
    required this.selectedType,
    required this.includeAnswerKey,
    required this.generating,
    required this.onTypeChanged,
    required this.onAnswerKeyChanged,
    required this.onGenerate,
  });

  final List<Word> words;
  final String dictionaryName;
  final ExerciseType selectedType;
  final bool includeAnswerKey;
  final bool generating;
  final ValueChanged<ExerciseType> onTypeChanged;
  final ValueChanged<bool> onAnswerKeyChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Panneau gauche de configuration ──────────────────────────────
        SizedBox(
          width: _kSidebarWidth,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: _ConfigPanel(
              words: words,
              dictionaryName: dictionaryName,
              selectedType: selectedType,
              includeAnswerKey: includeAnswerKey,
              generating: generating,
              onTypeChanged: onTypeChanged,
              onAnswerKeyChanged: onAnswerKeyChanged,
              onGenerate: onGenerate,
            ),
          ),
        ),
        // ── Panneau droit : aperçu des mots ──────────────────────────────
        Expanded(
          child: _WordPreviewPanel(words: words),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Layout mobile (< 680px) : onglets
// ---------------------------------------------------------------------------

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.words,
    required this.dictionaryName,
    required this.selectedType,
    required this.includeAnswerKey,
    required this.generating,
    required this.onTypeChanged,
    required this.onAnswerKeyChanged,
    required this.onGenerate,
  });

  final List<Word> words;
  final String dictionaryName;
  final ExerciseType selectedType;
  final bool includeAnswerKey;
  final bool generating;
  final ValueChanged<ExerciseType> onTypeChanged;
  final ValueChanged<bool> onAnswerKeyChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.tune_rounded), text: 'Configurer'),
              Tab(icon: Icon(Icons.preview_rounded), text: 'Aperçu'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ConfigPanel(
                  words: words,
                  dictionaryName: dictionaryName,
                  selectedType: selectedType,
                  includeAnswerKey: includeAnswerKey,
                  generating: generating,
                  onTypeChanged: onTypeChanged,
                  onAnswerKeyChanged: onAnswerKeyChanged,
                  onGenerate: onGenerate,
                ),
                _WordPreviewPanel(words: words),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Panneau de configuration (partagé wide + narrow)
// ---------------------------------------------------------------------------

class _ConfigPanel extends StatelessWidget {
  const _ConfigPanel({
    required this.words,
    required this.dictionaryName,
    required this.selectedType,
    required this.includeAnswerKey,
    required this.generating,
    required this.onTypeChanged,
    required this.onAnswerKeyChanged,
    required this.onGenerate,
  });

  final List<Word> words;
  final String dictionaryName;
  final ExerciseType selectedType;
  final bool includeAnswerKey;
  final bool generating;
  final ValueChanged<ExerciseType> onTypeChanged;
  final ValueChanged<bool> onAnswerKeyChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Résumé dictionnaire ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: cs.primaryContainer,
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: cs.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dictionaryName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${words.length} mot${words.length > 1 ? 's' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Sélection du type ────────────────────────────────────
                const _SectionLabel(label: 'Type d\'exercice'),
                const SizedBox(height: 10),
                ...ExerciseType.values.map(
                  (type) => _ExerciseTypeCard(
                    type: type,
                    selected: selectedType == type,
                    enabled: !generating,
                    onTap: () => onTypeChanged(type),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Options ──────────────────────────────────────────────
                const _SectionLabel(label: 'Options'),
                const SizedBox(height: 6),
                SwitchListTile(
                  value: includeAnswerKey,
                  onChanged: generating ? null : onAnswerKeyChanged,
                  title: const Text('Inclure le corrigé'),
                  subtitle: const Text(
                    'Ajoute une page de réponses à la suite.',
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // ── Bouton générer (bas, fixe) ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (generating) ...[
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 10),
              ],
              Semantics(
                label: 'Générer le PDF de la fiche d\'exercice',
                child: FilledButton.icon(
                  onPressed: generating ? null : onGenerate,
                  icon: generating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.print_rounded),
                  label: Text(
                    generating ? 'Génération…' : 'Générer le PDF',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Carte d'un type d'exercice (sélectionnable)
// ---------------------------------------------------------------------------

class _ExerciseTypeCard extends StatelessWidget {
  const _ExerciseTypeCard({
    required this.type,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final ExerciseType type;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      label: '${type.label}. ${type.instructions}',
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? cs.secondaryContainer
                : cs.surfaceContainerHighest.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? cs.secondary : cs.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _typeIcons[type]!,
                color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        color:
                            selected ? cs.onSecondaryContainer : cs.onSurface,
                      ),
                    ),
                    Text(
                      type == ExerciseType.wordSearch
                          ? 'Max. 12 mots — min. 3 lettres'
                          : type == ExerciseType.crossword
                              ? 'Nécessite des définitions pour les indices'
                              : type.instructions,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: selected
                            ? cs.onSecondaryContainer.withOpacity(0.75)
                            : cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: cs.secondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Panneau aperçu des mots (droite / onglet 2)
// ---------------------------------------------------------------------------

class _WordPreviewPanel extends StatelessWidget {
  const _WordPreviewPanel({required this.words});

  final List<Word> words;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 60,
              color: cs.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun mot dans ce dictionnaire.',
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.outline),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête du panneau
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: cs.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.preview_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Aperçu des mots',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${words.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Liste des mots
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: words.length,
            separatorBuilder: (_, __) => Divider(
              indent: 20,
              endIndent: 20,
              height: 1,
              color: cs.outlineVariant.withOpacity(0.4),
            ),
            itemBuilder: (ctx, i) => _WordPreviewTile(word: words[i]),
          ),
        ),
      ],
    );
  }
}

class _WordPreviewTile extends StatelessWidget {
  const _WordPreviewTile({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Couleur selon difficulté
    final diffColor = switch (word.difficulty) {
      1 => Colors.green,
      2 => Colors.orange,
      _ => Colors.red,
    };
    final diffLabel = switch (word.difficulty) {
      1 => 'Facile',
      2 => 'Moyen',
      _ => 'Difficile',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur de difficulté
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Tooltip(
              message: diffLabel,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: diffColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.mot,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                if (word.definition?.isNotEmpty == true) ...[
                  const SizedBox(height: 3),
                  Text(
                    word.definition!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// En-tête de section
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
