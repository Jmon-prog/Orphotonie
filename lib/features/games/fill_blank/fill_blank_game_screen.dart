// ============================================================
// Fichier : lib/features/games/fill_blank/fill_blank_game_screen.dart
// Description : Écran principal du jeu Mot Lacunaire.
//               3 modes : frappe libre, choix multiple, pool de lettres.
//               Affichage du mot avec lacunes, score, aides.
//               Responsive mobile/tablette/desktop.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_providers.dart';
import 'fill_blank_logic.dart';
import 'fill_blank_providers.dart';
import 'widgets/word_with_blanks.dart';
import 'widgets/free_input_mode.dart';
import 'widgets/multiple_choice_mode.dart';
import 'widgets/letter_pool_mode.dart';

/// Écran du jeu Mot Lacunaire.
///
/// Paramètres requis :
/// - [dictionaryId] : dictionnaire source des mots
/// - [profileId] : profil enfant en cours
/// - [dictionaryName] : nom affiché dans l'AppBar
/// - [mode] : mode de jeu
class FillBlankGameScreen extends ConsumerStatefulWidget {
  const FillBlankGameScreen({
    super.key,
    required this.dictionaryId,
    required this.profileId,
    this.dictionaryName,
    this.mode = FillBlankMode.freeInput,
  });

  final int dictionaryId;
  final int profileId;
  final String? dictionaryName;
  final FillBlankMode mode;

  @override
  ConsumerState<FillBlankGameScreen> createState() =>
      _FillBlankGameScreenState();
}

class _FillBlankGameScreenState extends ConsumerState<FillBlankGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fillBlankGameProvider.notifier).startGame(
            dictionaryId: widget.dictionaryId,
            profileId: widget.profileId,
            mode: widget.mode,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fillBlankGameProvider);
    final notifier = ref.read(fillBlankGameProvider.notifier);

    // Sons de feedback
    ref.listen<FillBlankGameState>(fillBlankGameProvider, (prev, next) {
      if (next.isCorrect == true && prev?.isCorrect != true) {
        ref.read(audioFeedbackServiceProvider).playSuccess();
        final tts = ref.read(ttsServiceProvider);
        if (tts.isAvailable && next.currentWord != null) {
          tts.speakWord(next.currentWord!.mot);
        }
      } else if (next.isCorrect == false && prev?.isCorrect != false) {
        ref.read(audioFeedbackServiceProvider).playError();
      }
      if (next.isFinished && !(prev?.isFinished ?? false)) {
        ref.read(audioFeedbackServiceProvider).playLevelComplete();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName ?? 'Mot Lacunaire'),
        actions: [
          // Bouton TTS
          Builder(
            builder: (context) {
              final tts = ref.watch(ttsServiceProvider);
              return IconButton(
                onPressed: tts.isAvailable && state.currentWord != null
                    ? () => tts.speakWord(state.currentWord!.mot)
                    : null,
                icon: const Icon(Icons.volume_up),
                tooltip:
                    tts.isAvailable ? 'Écouter le mot' : 'TTS non disponible',
              );
            },
          ),
          // Score
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                '⭐ ${state.totalScore} pts',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          // Aide
          if (!state.isFinished && !state.isLoading && state.isCorrect != true)
            IconButton(
              onPressed: () => notifier.useHint(),
              icon: const Icon(Icons.lightbulb_outline),
              tooltip: 'Révéler une lettre (-15 pts)',
            ),
        ],
      ),
      body: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FillBlankGameState state,
    FillBlankNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
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

    if (state.isFinished) {
      return _buildFinishScreen(context, state);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final tileSize = isWide ? 52.0 : 44.0;

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 680,
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── En-tête : progression + mode ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.progressLabel,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        Chip(
                          label: Text(_modeLabel(state.mode)),
                          avatar: Icon(_modeIcon(state.mode), size: 16),
                          visualDensity: VisualDensity.compact,
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Carte principale du jeu ──
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 32 : 20,
                          vertical: 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image du mot
                            if (state.currentWord?.imagePath != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  state.currentWord!.imagePath!,
                                  height: isWide ? 160 : 110,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Définition
                            if (state.currentWord?.definition != null &&
                                state.currentWord!.definition!.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      size: 18,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        state.currentWord!.definition!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // ── Mot avec lacunes (grande taille) ──
                            WordWithBlanks(
                              display: state.wordWithBlanks,
                              answers: state.answers,
                              revealedPositions:
                                  state.logic?.revealedPositions ?? const {},
                              isCorrect: state.isCorrect,
                              tileSize: tileSize + 4,
                            ),

                            const SizedBox(height: 32),

                            // ── Zone de saisie ──
                            _buildModeWidget(
                              context,
                              state,
                              notifier,
                              isWide,
                              tileSize,
                            ),

                            // Aides utilisées
                            if (state.hintsUsed > 0) ...[
                              const SizedBox(height: 12),
                              Text(
                                '${state.hintsUsed} aide${state.hintsUsed > 1 ? 's' : ''} utilisée${state.hintsUsed > 1 ? 's' : ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.orange),
                              ),
                            ],

                            // Feedback correct/incorrect
                            if (state.isCorrect != null) ...[
                              const SizedBox(height: 16),
                              _buildFeedback(context, state),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Bouton d'action ──
                    _buildActions(context, state, notifier),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget du mode de jeu.
  Widget _buildModeWidget(
    BuildContext context,
    FillBlankGameState state,
    FillBlankNotifier notifier,
    bool isWide,
    double tileSize,
  ) {
    final logic = state.logic;
    if (logic == null) return const SizedBox.shrink();

    switch (state.mode) {
      case FillBlankMode.freeInput:
        final blankIndices = logic.blanks
            .where((b) => !logic.revealedPositions.contains(b.index))
            .map((b) => b.index)
            .toList();
        // ValueKey(currentIndex) force la recréation du State à chaque
        // nouveau mot — évite que les TextEditingControllers gardent le
        // texte du mot précédent.
        return FreeInputMode(
          key: ValueKey('free_${state.currentIndex}'),
          blankIndices: blankIndices,
          onLetterChanged: notifier.setLetter,
          isCorrect: state.isCorrect,
          tileSize: tileSize,
        );

      case FillBlankMode.multipleChoice:
        final correct = logic.blanks.map((b) => b.letter).join();
        return MultipleChoiceMode(
          choices: state.choices,
          onChoiceSelected: notifier.selectChoice,
          isCorrect: state.isCorrect,
          correctAnswer: state.isCorrect == false ? correct : null,
        );

      case FillBlankMode.letterPool:
        final blankIndices = logic.blanks
            .where((b) => !logic.revealedPositions.contains(b.index))
            .map((b) => b.index)
            .toList();
        return LetterPoolMode(
          key: ValueKey('pool_${state.currentIndex}'),
          pool: state.letterPool,
          blankIndices: blankIndices,
          placements: state.poolPlacements,
          onLetterPlaced: notifier.placePoolLetter,
          onLetterRemoved: notifier.removePoolLetter,
          isCorrect: state.isCorrect,
          tileSize: tileSize,
        );
    }
  }

  /// Feedback visuel après vérification.
  Widget _buildFeedback(BuildContext context, FillBlankGameState state) {
    final isCorrect = state.isCorrect == true;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            isCorrect ? 'Bravo !' : 'Essaie encore !',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }

  /// Boutons d'action.
  Widget _buildActions(
    BuildContext context,
    FillBlankGameState state,
    FillBlankNotifier notifier,
  ) {
    // Après réponse correcte → bouton mot suivant
    if (state.isCorrect == true) {
      return FilledButton.icon(
        onPressed: () => notifier.nextWord(),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Mot suivant'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(200, 48),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Mode frappe / pool → bouton vérifier
    if (state.mode != FillBlankMode.multipleChoice) {
      return FilledButton.icon(
        onPressed:
            state.isAnswerComplete ? () => notifier.validateAnswer() : null,
        icon: const Icon(Icons.check),
        label: const Text('Vérifier'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(200, 48),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Écran de fin de partie.
  Widget _buildFinishScreen(BuildContext context, FillBlankGameState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Partie terminée !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.totalScore} points',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.words.length} mots • Mode : ${_modeLabel(state.mode)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Label du mode de jeu.
  String _modeLabel(FillBlankMode mode) {
    switch (mode) {
      case FillBlankMode.freeInput:
        return 'Frappe libre';
      case FillBlankMode.multipleChoice:
        return 'Choix multiple';
      case FillBlankMode.letterPool:
        return 'Lettres mélangées';
    }
  }

  /// Icône du mode de jeu.
  IconData _modeIcon(FillBlankMode mode) {
    switch (mode) {
      case FillBlankMode.freeInput:
        return Icons.keyboard;
      case FillBlankMode.multipleChoice:
        return Icons.quiz;
      case FillBlankMode.letterPool:
        return Icons.drag_indicator;
    }
  }
}
