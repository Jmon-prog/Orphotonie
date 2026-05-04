// ============================================================
// Fichier : lib/features/games/crossword/crossword_game_screen.dart
// Description : Écran principal du jeu Mots Croisés.
//               Grille interactive, panneau d'indices, barre de saisie.
//               Responsive mobile/tablette/desktop.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/audio/audio_providers.dart';
import 'crossword_generator.dart';
import 'crossword_providers.dart';
import 'crossword_state.dart';
import 'widgets/crossword_grid.dart';
import 'widgets/clues_panel.dart';
import 'widgets/word_input_bar.dart';

/// Écran du jeu Mots Croisés.
///
/// Paramètres requis :
/// - [dictionaryId] : dictionnaire source des mots
/// - [profileId] : profil enfant en cours
/// - [dictionaryName] : nom affiché dans l'AppBar
class CrosswordGameScreen extends ConsumerStatefulWidget {
  const CrosswordGameScreen({
    super.key,
    required this.dictionaryId,
    required this.profileId,
    this.dictionaryName,
  });

  final int dictionaryId;
  final int profileId;
  final String? dictionaryName;

  @override
  ConsumerState<CrosswordGameScreen> createState() =>
      _CrosswordGameScreenState();
}

class _CrosswordGameScreenState extends ConsumerState<CrosswordGameScreen> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(crosswordGameProvider.notifier).startGame(
            dictionaryId: widget.dictionaryId,
            profileId: widget.profileId,
          );
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crosswordGameProvider);
    final notifier = ref.read(crosswordGameProvider.notifier);

    // Sons de feedback
    ref.listen<CrosswordGameState>(crosswordGameProvider, (prev, next) {
      if (next.completedWords.length > (prev?.completedWords.length ?? 0)) {
        ref.read(audioFeedbackServiceProvider).playSuccess();
      }
      if (next.isFinished && !(prev?.isFinished ?? false)) {
        ref.read(audioFeedbackServiceProvider).playLevelComplete();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName ?? 'Mots Croisés'),
        actions: [
          // Timer
          if (state.startTimeMs != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      state.timerLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Score
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                '${state.totalScore} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: CrosswordKeyboardHandler(
        focusNode: _focusNode,
        onLetter: (letter) => notifier.inputLetter(letter),
        onDelete: () => notifier.deleteLetter(),
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: _buildBody(context, state, notifier),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CrosswordGameState state,
    CrosswordNotifier notifier,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final grid = state.gridData;
    if (grid == null) {
      return const Center(child: Text('Aucune grille'));
    }

    // Victoire
    if (state.isFinished) {
      return _buildVictoryScreen(context, state, notifier);
    }

    // Focus automatique pour le clavier
    _focusNode.requestFocus();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return isWide
            ? _buildWideLayout(context, state, notifier, constraints)
            : _buildNarrowLayout(context, state, notifier, constraints);
      },
    );
  }

  /// Layout large : grille à gauche, indices à droite.
  Widget _buildWideLayout(
    BuildContext context,
    CrosswordGameState state,
    CrosswordNotifier notifier,
    BoxConstraints constraints,
  ) {
    final grid = state.gridData!;
    final gridWidth = constraints.maxWidth * 0.55;
    final cellSize =
        _computeCellSize(grid, gridWidth, constraints.maxHeight - 100);

    return Column(
      children: [
        // Progression
        _buildProgressBar(state),
        Expanded(
          child: Row(
            children: [
              // Grille
              Expanded(
                flex: 55,
                child: Center(
                  child: SingleChildScrollView(
                    child: CrosswordGridWidget(
                      gridData: grid,
                      userInput: state.userInput,
                      cellStates: state.cellStates,
                      selection: state.selection,
                      cellSize: cellSize,
                      onCellTap: notifier.selectCellAt,
                    ),
                  ),
                ),
              ),
              // Indices
              Expanded(
                flex: 45,
                child: CluesPanel(
                  horizontalClues:
                      _indexedClues(grid, WordOrientation.horizontal),
                  verticalClues: _indexedClues(grid, WordOrientation.vertical),
                  completedIndices: state.completedWords,
                  selectedIndex: state.selection?.placementIndex,
                  onClueTap: (pi) => notifier.selectPlacement(pi),
                ),
              ),
            ],
          ),
        ),
        // Barre de saisie
        if (state.selectedPlacement != null && state.selection != null)
          WordInputBar(
            placement: state.selectedPlacement!,
            selection: state.selection!,
            userInput: state.userInput,
            cellStates: state.cellStates,
            isCompleted:
                state.completedWords.contains(state.selection!.placementIndex),
            onLetter: notifier.inputLetter,
            onDelete: notifier.deleteLetter,
            onHint: notifier.useHint,
          ),
      ],
    );
  }

  /// Layout étroit : grille en haut, indices en bas.
  Widget _buildNarrowLayout(
    BuildContext context,
    CrosswordGameState state,
    CrosswordNotifier notifier,
    BoxConstraints constraints,
  ) {
    final grid = state.gridData!;
    final cellSize = _computeCellSize(
      grid,
      constraints.maxWidth - 16,
      constraints.maxHeight * 0.45,
    );

    return Column(
      children: [
        _buildProgressBar(state),
        // Grille (scrollable)
        Expanded(
          flex: 50,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CrosswordGridWidget(
                    gridData: grid,
                    userInput: state.userInput,
                    cellStates: state.cellStates,
                    selection: state.selection,
                    cellSize: cellSize,
                    onCellTap: notifier.selectCellAt,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Indices
        Expanded(
          flex: 50,
          child: CluesPanel(
            horizontalClues: _indexedClues(grid, WordOrientation.horizontal),
            verticalClues: _indexedClues(grid, WordOrientation.vertical),
            completedIndices: state.completedWords,
            selectedIndex: state.selection?.placementIndex,
            onClueTap: (pi) => notifier.selectPlacement(pi),
          ),
        ),
        // Barre de saisie
        if (state.selectedPlacement != null && state.selection != null)
          WordInputBar(
            placement: state.selectedPlacement!,
            selection: state.selection!,
            userInput: state.userInput,
            cellStates: state.cellStates,
            isCompleted:
                state.completedWords.contains(state.selection!.placementIndex),
            onLetter: notifier.inputLetter,
            onDelete: notifier.deleteLetter,
            onHint: notifier.useHint,
          ),
      ],
    );
  }

  /// Barre de progression.
  Widget _buildProgressBar(CrosswordGameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            state.progressLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: state.totalWords > 0
                  ? state.foundWords / state.totalWords
                  : 0,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  /// Écran de victoire.
  Widget _buildVictoryScreen(
    BuildContext context,
    CrosswordGameState state,
    CrosswordNotifier notifier,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Bravo !',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tous les mots trouvés !',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              '${state.totalScore} points',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Temps : ${state.timerLabel}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            if (state.hintsUsed > 0)
              Text(
                '${state.hintsUsed} indice(s) utilisé(s)',
                style: TextStyle(fontSize: 14, color: Colors.orange.shade700),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Rejouer'),
                  onPressed: () {
                    notifier.startGame(
                      dictionaryId: widget.dictionaryId,
                      profileId: widget.profileId,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Calcule la taille de cellule optimale.
  double _computeCellSize(CrosswordGrid grid, double maxW, double maxH) {
    final cellW = maxW / grid.cols;
    final cellH = maxH / grid.rows;
    return cellW.clamp(28, 52).toDouble().clamp(
          28,
          cellH.clamp(28, 52).toDouble(),
        );
  }

  /// Construit les IndexedClue pour le panneau d'indices.
  List<IndexedClue> _indexedClues(
    CrosswordGrid grid,
    WordOrientation orientation,
  ) {
    final result = <IndexedClue>[];
    for (int i = 0; i < grid.placements.length; i++) {
      if (grid.placements[i].orientation == orientation) {
        result.add(IndexedClue(i, grid.placements[i]));
      }
    }
    result.sort(
      (a, b) => (a.placement.number ?? 0).compareTo(b.placement.number ?? 0),
    );
    return result;
  }
}
