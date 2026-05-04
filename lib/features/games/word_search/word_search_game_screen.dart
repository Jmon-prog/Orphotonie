// ============================================================
// Fichier : lib/features/games/word_search/word_search_game_screen.dart
// Description : Écran principal du jeu Mots Cachés.
//               Grille interactive, liste des mots, chronomètre.
//               Responsive mobile/tablette/desktop.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_providers.dart';
import 'word_search_generator.dart';
import 'word_search_providers.dart';
import 'word_search_state.dart';
import 'widgets/word_grid.dart';
import 'widgets/word_list_panel.dart';
import 'widgets/timer_display.dart';

/// Écran du jeu Mots Cachés.
///
/// Paramètres requis :
/// - [dictionaryId] : dictionnaire source des mots
/// - [profileId] : profil enfant en cours
/// - [dictionaryName] : nom affiché dans l'AppBar
/// - [difficulty] : difficulté (taille grille + directions)
class WordSearchGameScreen extends ConsumerStatefulWidget {
  const WordSearchGameScreen({
    super.key,
    required this.dictionaryId,
    required this.profileId,
    this.dictionaryName,
    this.difficulty = WordSearchDifficulty.normal,
  });

  final int dictionaryId;
  final int profileId;
  final String? dictionaryName;
  final WordSearchDifficulty difficulty;

  @override
  ConsumerState<WordSearchGameScreen> createState() =>
      _WordSearchGameScreenState();
}

class _WordSearchGameScreenState extends ConsumerState<WordSearchGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wordSearchGameProvider.notifier).startGame(
            dictionaryId: widget.dictionaryId,
            profileId: widget.profileId,
            difficulty: widget.difficulty,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wordSearchGameProvider);
    final notifier = ref.read(wordSearchGameProvider.notifier);

    // Sons de feedback
    ref.listen<WordSearchGameState>(wordSearchGameProvider, (prev, next) {
      if (next.foundWords.length > (prev?.foundWords.length ?? 0)) {
        ref.read(audioFeedbackServiceProvider).playSuccess();
        // Lire le dernier mot trouvé
        final tts = ref.read(ttsServiceProvider);
        if (tts.isAvailable && next.foundWords.isNotEmpty) {
          tts.speakWord(next.foundWords.last);
        }
      }
      if (next.isFinished && !(prev?.isFinished ?? false)) {
        ref.read(audioFeedbackServiceProvider).playLevelComplete();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName ?? 'Mots Cachés'),
        actions: [
          // Chronomètre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: TimerDisplay(label: state.timerLabel),
            ),
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
        ],
      ),
      body: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WordSearchGameState state,
    WordSearchNotifier notifier,
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
        final isWide = constraints.maxWidth > 700;

        // Calculer la taille des cellules pour que la grille tienne
        final gridSide = state.gridSize;
        final maxGridWidth =
            isWide ? constraints.maxWidth * 0.6 : constraints.maxWidth - 32;
        final maxGridHeight = constraints.maxHeight - 200;
        final maxDim =
            maxGridWidth < maxGridHeight ? maxGridWidth : maxGridHeight;
        final cellSize = (maxDim / gridSide).floorToDouble().clamp(44.0, 64.0);

        if (isWide) {
          return _buildWideLayout(
            context,
            state,
            notifier,
            cellSize,
          );
        }
        return _buildNarrowLayout(
          context,
          state,
          notifier,
          cellSize,
        );
      },
    );
  }

  /// Layout large (tablette/desktop) : grille à gauche, liste à droite.
  Widget _buildWideLayout(
    BuildContext context,
    WordSearchGameState state,
    WordSearchNotifier notifier,
    double cellSize,
  ) {
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grille
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: _buildGrid(state, notifier, cellSize),
              ),
            ),
          ),
          // Panneau latéral
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'À trouver',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.progressLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  WordListPanel(
                    words: state.wordsToFind,
                    foundWords: state.foundWords,
                    wordColors: state.foundWordColors,
                  ),
                  if (state.gridData?.skippedWords.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Non placés : ${state.gridData!.skippedWords.join(", ")}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Layout étroit (mobile) : grille en haut, liste en bas.
  Widget _buildNarrowLayout(
    BuildContext context,
    WordSearchGameState state,
    WordSearchNotifier notifier,
    double cellSize,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Progression
            Text(
              state.progressLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),

            // Grille
            Center(
              child: _buildGrid(state, notifier, cellSize),
            ),
            const SizedBox(height: 16),

            // Liste des mots
            WordListPanel(
              words: state.wordsToFind,
              foundWords: state.foundWords,
              wordColors: state.foundWordColors,
            ),

            if (state.gridData?.skippedWords.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                'Non placés : ${state.gridData!.skippedWords.join(", ")}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Construit la grille interactive.
  Widget _buildGrid(
    WordSearchGameState state,
    WordSearchNotifier notifier,
    double cellSize,
  ) {
    return WordGrid(
      grid: state.grid,
      gridSize: state.gridSize,
      highlightedCells: state.highlightedCells,
      currentSelection: state.currentSelection,
      onCellDown: notifier.startSelection,
      onCellMove: notifier.updateSelection,
      onSelectionEnd: notifier.endSelection,
      cellSize: cellSize,
    );
  }

  /// Écran de fin de partie (victoire).
  Widget _buildFinishScreen(
    BuildContext context,
    WordSearchGameState state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Bravo ! Tous les mots trouvés !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
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
              'Temps : ${state.timerLabel}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${state.foundWords.length} mots trouvés',
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
}
