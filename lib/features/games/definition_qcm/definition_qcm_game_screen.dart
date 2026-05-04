// ============================================================
// Fichier : lib/features/games/definition_qcm/definition_qcm_game_screen.dart
// Description : Écran du jeu QCM Définition.
//               Un mot est affiché, 4 définitions proposées.
//               Feedback couleur immédiat (vert/rouge).
//               Responsive mobile/tablette/desktop. Accessible.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'definition_qcm_providers.dart';

/// Écran du jeu QCM Définition.
///
/// Paramètres requis :
/// - [dictionaryId] : dictionnaire source des mots
/// - [profileId]    : profil enfant en cours
/// - [dictionaryName] : nom affiché dans l'AppBar
class DefinitionQcmGameScreen extends ConsumerStatefulWidget {
  const DefinitionQcmGameScreen({
    super.key,
    required this.dictionaryId,
    required this.profileId,
    this.dictionaryName,
  });

  final int dictionaryId;
  final int profileId;
  final String? dictionaryName;

  @override
  ConsumerState<DefinitionQcmGameScreen> createState() =>
      _DefinitionQcmGameScreenState();
}

class _DefinitionQcmGameScreenState
    extends ConsumerState<DefinitionQcmGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(definitionQcmProvider.notifier).startGame(
            dictionaryId: widget.dictionaryId,
            profileId: widget.profileId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(definitionQcmProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName ?? 'QCM Définition'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                state.isLoading || state.questions.isEmpty
                    ? ''
                    : state.progressLabel,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.error!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : state.isFinished
                  ? _buildResults(context, state)
                  : _buildGame(context, state),
    );
  }

  Widget _buildGame(BuildContext context, DefinitionQcmState state) {
    final theme = Theme.of(context);
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 64 : 24,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barre de progression
              LinearProgressIndicator(
                value: state.questions.isEmpty
                    ? 0
                    : state.currentIndex / state.questions.length,
                minHeight: 4,
              ),
              const SizedBox(height: 24),
              // Score
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.star,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${state.totalScore} pts',
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mot cible
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: Text(
                    question.word.mot,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quelle est la définition de ce mot ?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Choix
              ...List.generate(question.choices.length, (i) {
                return _ChoiceTile(
                  text: question.choices[i],
                  index: i,
                  selectedIndex: state.selectedIndex,
                  correctIndex: question.correctIndex,
                  hasAnswered: state.hasAnswered,
                  onTap: state.hasAnswered
                      ? null
                      : () => ref
                          .read(definitionQcmProvider.notifier)
                          .selectAnswer(i),
                );
              }),
              const SizedBox(height: 24),
              // Bouton suivant (visible après réponse)
              if (state.hasAnswered)
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(definitionQcmProvider.notifier).nextQuestion(),
                  icon: const Icon(Icons.arrow_forward),
                  label: state.currentIndex + 1 >= state.questions.length
                      ? const Text('Voir les résultats')
                      : const Text('Question suivante'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResults(BuildContext context, DefinitionQcmState state) {
    final theme = Theme.of(context);
    final total = state.questions.length;
    final rate = total > 0 ? (state.correctCount / total * 100).round() : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              rate >= 70 ? Icons.emoji_events : Icons.sentiment_satisfied_alt,
              size: 72,
              color: rate >= 70 ? Colors.amber : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Session terminée !',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _ResultRow(
              label: 'Bonnes réponses',
              value: '${state.correctCount} / $total',
            ),
            _ResultRow(label: 'Taux de réussite', value: '$rate %'),
            _ResultRow(label: 'Points', value: '${state.totalScore}'),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets internes
// ---------------------------------------------------------------------------

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.text,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.hasAnswered,
    this.onTap,
  });

  final String text;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool hasAnswered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? tileColor;
    Color? textColor;
    IconData? trailingIcon;

    if (hasAnswered) {
      if (index == correctIndex) {
        tileColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        trailingIcon = Icons.check_circle;
      } else if (index == selectedIndex) {
        tileColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        trailingIcon = Icons.cancel;
      }
    }

    return Semantics(
      button: onTap != null,
      label: 'Choix ${index + 1} : $text',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: tileColor ??
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: hasAnswered && index == correctIndex
                        ? Colors.green
                        : hasAnswered && index == selectedIndex
                            ? Colors.red
                            : theme.colorScheme.primary,
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight:
                            index == selectedIndex || index == correctIndex
                                ? FontWeight.w600
                                : null,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      trailingIcon,
                      color: index == correctIndex
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
