// ============================================================
// Fichier : lib/features/games/syllables/syllables_game_screen.dart
// Description : Écran du jeu Roue des Syllabes.
//               Les syllabes du mot sont mélangées dans une rangée.
//               L'enfant les tape dans l'ordre pour reconstituer le mot.
//               Feedback visuel vert/rouge, score, progression.
//               Responsive mobile/tablette/desktop. 100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'syllables_providers.dart';

/// Écran du jeu Roue des Syllabes.
///
/// Paramètres requis :
/// - [dictionaryId] : dictionnaire source des mots
/// - [profileId] : profil enfant en cours
/// - [dictionaryName] : nom affiché dans l'AppBar
class SyllablesGameScreen extends ConsumerStatefulWidget {
  const SyllablesGameScreen({
    super.key,
    required this.dictionaryId,
    required this.profileId,
    this.dictionaryName,
  });

  final int dictionaryId;
  final int profileId;
  final String? dictionaryName;

  @override
  ConsumerState<SyllablesGameScreen> createState() =>
      _SyllablesGameScreenState();
}

class _SyllablesGameScreenState extends ConsumerState<SyllablesGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackAnim;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _feedbackAnim = CurvedAnimation(
      parent: _feedbackCtrl,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syllablesGameProvider.notifier).startGame(
            dictionaryId: widget.dictionaryId,
            profileId: widget.profileId,
          );
    });
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _runFeedbackAnimation() {
    _feedbackCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(syllablesGameProvider);

    // Déclencher animation quand résultat disponible
    ref.listen<SyllablesGameState>(syllablesGameProvider, (prev, next) {
      if (prev?.isCorrect == null && next.isCorrect != null) {
        _runFeedbackAnimation();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName ?? 'Roue des Syllabes'),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorView(error: state.error!, onRetry: _retry)
              : state.isFinished
                  ? _ResultsView(
                      state: state,
                      onReplay: _replay,
                      onQuit: _quit,
                    )
                  : _GameView(
                      state: state,
                      feedbackAnim: _feedbackAnim,
                      onPlace: _placeSyllable,
                      onRemove: _removeSyllable,
                      onValidate: _validate,
                      onNext: _nextWord,
                    ),
    );
  }

  void _retry() {
    ref.read(syllablesGameProvider.notifier).startGame(
          dictionaryId: widget.dictionaryId,
          profileId: widget.profileId,
        );
  }

  void _replay() {
    ref.read(syllablesGameProvider.notifier).startGame(
          dictionaryId: widget.dictionaryId,
          profileId: widget.profileId,
        );
  }

  void _quit() {
    if (mounted) Navigator.of(context).pop();
  }

  void _placeSyllable(int sourceIndex) {
    ref.read(syllablesGameProvider.notifier).placeSyllable(sourceIndex);
  }

  void _removeSyllable(int slotIndex) {
    ref.read(syllablesGameProvider.notifier).removeSyllable(slotIndex);
  }

  Future<void> _validate() async {
    await ref.read(syllablesGameProvider.notifier).validateAnswer();
  }

  Future<void> _nextWord() async {
    await ref.read(syllablesGameProvider.notifier).nextWord();
  }
}

// ---------------------------------------------------------------------------
// Vue principale du jeu
// ---------------------------------------------------------------------------

class _GameView extends StatelessWidget {
  const _GameView({
    required this.state,
    required this.feedbackAnim,
    required this.onPlace,
    required this.onRemove,
    required this.onValidate,
    required this.onNext,
  });

  final SyllablesGameState state;
  final Animation<double> feedbackAnim;
  final void Function(int) onPlace;
  final void Function(int) onRemove;
  final VoidCallback onValidate;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final word = state.currentWord;
    if (word == null) return const SizedBox.shrink();

    final isCorrect = state.isCorrect;

    // Couleur de feedback
    Color feedbackColor;
    String feedbackMsg;
    if (isCorrect == true) {
      feedbackColor = Colors.green;
      feedbackMsg = 'Bravo ! +${state.logic?.computeScore() ?? 0} pts';
    } else if (isCorrect == false) {
      feedbackColor = Colors.red;
      feedbackMsg = 'Réessaie !';
    } else {
      feedbackColor = Colors.transparent;
      feedbackMsg = '';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progression + score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.progressLabel,
                  style: theme.textTheme.bodySmall,
                ),
                Chip(
                  label: Text(
                    '${state.totalScore} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: colorScheme.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Instruction
            Text(
              'Remets les syllabes dans l\'ordre',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Mot brouillé (syllabes source)
            _SyllablesRow(
              syllables: state.shuffledSlots,
              onTap: isCorrect == true ? null : onPlace,
              isPrimary: true,
            ),
            const SizedBox(height: 32),

            // Emplacements de la réponse
            _AnswerRow(
              slots: state.answerSlots,
              isCorrect: isCorrect,
              feedbackAnim: feedbackAnim,
              onRemove: isCorrect == true ? null : onRemove,
            ),
            const SizedBox(height: 24),

            // Feedback textuel animé
            if (feedbackMsg.isNotEmpty)
              AnimatedBuilder(
                animation: feedbackAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: feedbackAnim.value,
                    child: child,
                  );
                },
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: feedbackColor.withValues(alpha: 0.15),
                      border: Border.all(color: feedbackColor),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Text(
                      feedbackMsg,
                      style: TextStyle(
                        color: feedbackColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

            const Spacer(),

            // Bouton action
            if (isCorrect == null)
              Semantics(
                button: true,
                label: 'Valider la réponse',
                child: ElevatedButton.icon(
                  onPressed: state.isAnswerComplete ? onValidate : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Valider'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              )
            else
              Semantics(
                button: true,
                label: 'Mot suivant',
                child: ElevatedButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Mot suivant'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rangée de syllabes source (zone de choix)
// ---------------------------------------------------------------------------

class _SyllablesRow extends StatelessWidget {
  const _SyllablesRow({
    required this.syllables,
    required this.isPrimary,
    this.onTap,
  });

  final List<String?> syllables;
  final bool isPrimary;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(syllables.length, (i) {
        final syl = syllables[i];
        return Semantics(
          button: syl != null && onTap != null,
          label: syl != null ? 'Syllabe $syl' : 'Emplacement vide',
          child: GestureDetector(
            onTap: syl != null && onTap != null ? () => onTap!(i) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(minWidth: 52),
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: syl != null
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: syl == null
                    ? Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.4),
                        style: BorderStyle.solid,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: syl != null
                  ? Text(
                      syl,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Rangée de la réponse (slots)
// ---------------------------------------------------------------------------

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.slots,
    required this.isCorrect,
    required this.feedbackAnim,
    this.onRemove,
  });

  final List<String?> slots;
  final bool? isCorrect;
  final Animation<double> feedbackAnim;
  final void Function(int)? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color borderColor;
    if (isCorrect == true) {
      borderColor = Colors.green;
    } else if (isCorrect == false) {
      borderColor = Colors.red;
    } else {
      borderColor = colorScheme.outline;
    }

    return AnimatedBuilder(
      animation: feedbackAnim,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        );
      },
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: List.generate(slots.length, (i) {
          final syl = slots[i];
          return Semantics(
            button: syl != null && onRemove != null,
            label: syl != null ? 'Retirer la syllabe $syl' : 'Slot vide',
            child: GestureDetector(
              onTap:
                  syl != null && onRemove != null ? () => onRemove!(i) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minWidth: 52),
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: syl != null
                      ? (isCorrect == true
                          ? Colors.green.shade100
                          : isCorrect == false
                              ? Colors.red.shade100
                              : colorScheme.secondaryContainer)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: syl != null
                        ? Colors.transparent
                        : colorScheme.outline.withValues(alpha: 0.6),
                  ),
                ),
                alignment: Alignment.center,
                child: syl != null
                    ? Text(
                        syl,
                        style: TextStyle(
                          color: isCorrect == true
                              ? Colors.green.shade800
                              : isCorrect == false
                                  ? Colors.red.shade800
                                  : colorScheme.onSecondaryContainer,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(Icons.add, size: 20, color: Colors.grey),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Écran de résultats
// ---------------------------------------------------------------------------

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.state,
    required this.onReplay,
    required this.onQuit,
  });

  final SyllablesGameState state;
  final VoidCallback onReplay;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final total = state.words.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 80,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Partie terminée !',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$total mot${total > 1 ? 's' : ''} travaillé${total > 1 ? 's' : ''}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    '${state.totalScore}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'points',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Rejouer',
                    child: OutlinedButton.icon(
                      onPressed: onReplay,
                      icon: const Icon(Icons.replay),
                      label: const Text('Rejouer'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Quitter',
                    child: ElevatedButton.icon(
                      onPressed: onQuit,
                      icon: const Icon(Icons.check),
                      label: const Text('Terminer'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vue erreur
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
