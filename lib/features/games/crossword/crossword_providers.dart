// ============================================================
// Fichier : lib/features/games/crossword/crossword_providers.dart
// Description : Providers Riverpod pour le jeu Mots Croisés.
//               Gère l'état de la partie : grille, saisie,
//               sélection, validation, chronomètre, session.
//               100 % hors-ligne.
// ============================================================

import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/string_utils.dart';
import '../../../features/dictionaries/services/definitions_service.dart';
import 'crossword_generator.dart';
import 'crossword_state.dart';

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Contrôleur du jeu Mots Croisés.
class CrosswordNotifier extends StateNotifier<CrosswordGameState> {
  CrosswordNotifier(this._ref) : super(const CrosswordGameState());

  final Ref _ref;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Démarre une session de mots croisés.
  Future<void> startGame({
    required int dictionaryId,
    required int profileId,
    int wordCount = 6,
  }) async {
    state = state.copyWith(
      isLoading: true,
      dictionaryId: dictionaryId,
      profileId: profileId,
    );

    try {
      final wordsDao = _ref.read(wordsDaoProvider);
      final statsDao = _ref.read(statsDaoProvider);

      final words = await wordsDao.selectWordsForSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        limit: wordCount,
      );

      if (words.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: () => 'Aucun mot dans ce dictionnaire. '
              'Ajoutez des mots depuis la recherche.',
        );
        return;
      }

      final sessionId = await statsDao.startSession(
        SessionsCompanion(
          profileId: Value(profileId),
          dictionaryId: Value(dictionaryId),
          activityType: const Value('mots_croises'),
        ),
      );

      // Préparer les entrées avec définitions croisées.
      // Si le mot n'a pas de définition stockée, on consulte definitions.db.
      final defService = _ref.read(definitionsServiceProvider);
      final entries = <CrosswordEntry>[];
      for (final w in words) {
        String clue;
        if (w.defCroises?.isNotEmpty == true) {
          clue = w.defCroises!;
        } else if (w.definition?.isNotEmpty == true) {
          clue = w.definition!;
        } else {
          // Fallback : cherche dans definitions.db
          final defEntry = await defService.findDefinition(w.mot);
          clue = defEntry?.defCroises?.isNotEmpty == true
              ? defEntry!.defCroises!
              : defEntry?.defComplete?.isNotEmpty == true
                  ? defEntry!.defComplete!
                  : '?';
        }
        entries.add(CrosswordEntry(word: w.mot, clue: clue));
      }

      // Générer la grille
      final generator = CrosswordGenerator();
      final gridData = generator.generate(entries);

      if (gridData.placements.length < 2) {
        state = state.copyWith(
          isLoading: false,
          error: () => 'Impossible de croiser suffisamment de mots. '
              'Essayez un autre dictionnaire.',
        );
        return;
      }

      state = state.copyWith(
        gridData: gridData,
        sessionId: () => sessionId,
        isLoading: false,
        startTimeMs: DateTime.now().millisecondsSinceEpoch,
        elapsedSeconds: 0,
        userInput: const {},
        cellStates: const {},
        completedWords: const {},
        totalScore: 0,
        hintsUsed: 0,
        isFinished: false,
        error: () => null,
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'Erreur au démarrage : $e',
      );
    }
  }

  /// Démarre le chronomètre.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      state = state.copyWith(
        elapsedSeconds: state.elapsedSeconds + 1,
      );
    });
  }

  /// Sélectionne un mot dans la grille.
  void selectPlacement(int placementIndex, {int cellIndex = 0}) {
    if (state.isFinished) return;
    final grid = state.gridData;
    if (grid == null) return;
    if (placementIndex < 0 || placementIndex >= grid.placements.length) return;

    state = state.copyWith(
      selection: () => CrosswordSelection(
        placementIndex: placementIndex,
        cellIndex: cellIndex,
      ),
    );
  }

  /// Sélectionne un mot par clic sur une cellule.
  /// Si la cellule appartient à 2 mots (intersection), alterne.
  void selectCellAt(int row, int col) {
    if (state.isFinished) return;
    final grid = state.gridData;
    if (grid == null) return;

    // Trouver les mots passant par cette cellule
    final candidates = <(int, int)>[]; // (placementIndex, cellIndex)
    for (int pi = 0; pi < grid.placements.length; pi++) {
      final p = grid.placements[pi];
      final cells = p.cells;
      for (int ci = 0; ci < cells.length; ci++) {
        if (cells[ci] == (row, col)) {
          candidates.add((pi, ci));
        }
      }
    }

    if (candidates.isEmpty) return;

    // Si déjà sur un de ces mots, passer au suivant (toggle H/V)
    if (state.selection != null && candidates.length > 1) {
      final currentPi = state.selection!.placementIndex;
      final next = candidates.firstWhere(
        (c) => c.$1 != currentPi,
        orElse: () => candidates.first,
      );
      selectPlacement(next.$1, cellIndex: next.$2);
    } else {
      selectPlacement(
        candidates.first.$1,
        cellIndex: candidates.first.$2,
      );
    }
  }

  /// Saisie d'une lettre dans la cellule sélectionnée.
  void inputLetter(String letter) {
    if (state.isFinished) return;
    final sel = state.selection;
    if (sel == null) return;
    final grid = state.gridData;
    if (grid == null) return;

    final placement = grid.placements[sel.placementIndex];
    final cells = placement.cells;
    if (sel.cellIndex >= cells.length) return;

    final (row, col) = cells[sel.cellIndex];
    final normalizedLetter = letter.toUpperCase();

    // Mettre à jour la saisie
    final newInput = Map<(int, int), String>.from(state.userInput);
    newInput[(row, col)] = normalizedLetter;

    final newCellStates = Map<(int, int), CellState>.from(state.cellStates);
    newCellStates[(row, col)] = CellState.filled;

    // Avancer au prochain slot vide dans le même mot
    int nextCell = sel.cellIndex + 1;
    while (nextCell < cells.length) {
      final (nr, nc) = cells[nextCell];
      final st = newCellStates[(nr, nc)];
      if (st == null || st == CellState.empty) break;
      if (st == CellState.filled) break; // Permettre la réécriture
      nextCell++;
    }
    if (nextCell >= cells.length) nextCell = sel.cellIndex;

    state = state.copyWith(
      userInput: newInput,
      cellStates: newCellStates,
      selection: () => sel.copyWith(cellIndex: nextCell),
    );

    // Vérifier si le mot est complet
    _checkWordCompletion(sel.placementIndex);
  }

  /// Efface la lettre dans la cellule sélectionnée.
  void deleteLetter() {
    if (state.isFinished) return;
    final sel = state.selection;
    if (sel == null) return;
    final grid = state.gridData;
    if (grid == null) return;

    final placement = grid.placements[sel.placementIndex];
    final cells = placement.cells;
    if (sel.cellIndex >= cells.length) return;

    final (row, col) = cells[sel.cellIndex];

    // Si la case actuelle est vide, reculer
    final currentState = state.cellStates[(row, col)];
    int targetCell = sel.cellIndex;
    if (currentState == null || currentState == CellState.empty) {
      // Reculer
      targetCell = sel.cellIndex - 1;
      if (targetCell < 0) return;
    }

    final (tr, tc) = cells[targetCell];
    // Ne pas effacer les cases révélées ou correctes
    final targetState = state.cellStates[(tr, tc)];
    if (targetState == CellState.correct || targetState == CellState.revealed) {
      return;
    }

    final newInput = Map<(int, int), String>.from(state.userInput)
      ..remove((tr, tc));
    final newCellStates = Map<(int, int), CellState>.from(state.cellStates);
    newCellStates[(tr, tc)] = CellState.empty;

    state = state.copyWith(
      userInput: newInput,
      cellStates: newCellStates,
      selection: () => sel.copyWith(cellIndex: targetCell),
    );
  }

  /// Vérifie si un mot est entièrement et correctement rempli.
  void _checkWordCompletion(int placementIndex) {
    final grid = state.gridData;
    if (grid == null) return;
    if (state.completedWords.contains(placementIndex)) return;

    final placement = grid.placements[placementIndex];
    final cells = placement.cells;

    // Vérifier que toutes les cases sont remplies correctement
    bool allCorrect = true;
    bool allFilled = true;
    for (int i = 0; i < cells.length; i++) {
      final (r, c) = cells[i];
      final input = state.userInput[(r, c)];
      final cellState = state.cellStates[(r, c)];

      if (input == null &&
          cellState != CellState.correct &&
          cellState != CellState.revealed) {
        allFilled = false;
        break;
      }

      final expected = placement.word[i];
      final actual = (input ?? grid.grid[r][c]) ?? '';
      // Comparaison insensible aux diacritiques : l'utilisateur tape A-Z
      // mais la grille peut contenir È, É, À, etc.
      if (stripAccents(actual) != stripAccents(expected)) {
        allCorrect = false;
      }
    }

    if (!allFilled) return;

    if (allCorrect) {
      // Mot correct !
      final newCompleted = Set<int>.from(state.completedWords)
        ..add(placementIndex);

      // Marquer les cellules comme correctes
      final newCellStates = Map<(int, int), CellState>.from(state.cellStates);
      for (final cell in cells) {
        newCellStates[cell] = CellState.correct;
      }

      // Points : 10 pts par lettre
      final points = placement.word.length * 10;

      state = state.copyWith(
        completedWords: newCompleted,
        cellStates: newCellStates,
        totalScore: state.totalScore + points,
      );

      _recordAttempt(placement, success: true);

      // Vérifier victoire
      if (state.allFound) {
        _finishGame();
      }
    }
  }

  /// Utilise un indice : révèle une lettre du mot sélectionné.
  void useHint() {
    if (state.isFinished) return;
    final sel = state.selection;
    if (sel == null) return;
    final grid = state.gridData;
    if (grid == null) return;
    if (state.completedWords.contains(sel.placementIndex)) return;

    final placement = grid.placements[sel.placementIndex];
    final cells = placement.cells;

    // Trouver la première case non résolue
    int? targetIndex;
    for (int i = 0; i < cells.length; i++) {
      final st = state.cellStates[cells[i]];
      if (st != CellState.correct && st != CellState.revealed) {
        targetIndex = i;
        break;
      }
    }

    if (targetIndex == null) return;

    final (r, c) = cells[targetIndex];
    final letter = placement.word[targetIndex];

    final newInput = Map<(int, int), String>.from(state.userInput);
    newInput[(r, c)] = letter;
    final newCellStates = Map<(int, int), CellState>.from(state.cellStates);
    newCellStates[(r, c)] = CellState.revealed;

    state = state.copyWith(
      userInput: newInput,
      cellStates: newCellStates,
      hintsUsed: state.hintsUsed + 1,
      totalScore: (state.totalScore - 20).clamp(0, 999999),
    );

    // Re-vérifier complétion
    _checkWordCompletion(sel.placementIndex);
  }

  /// Enregistre une tentative.
  Future<void> _recordAttempt(
    CrosswordPlacement placement, {
    required bool success,
  }) async {
    try {
      if (state.sessionId == null) return;
      final statsDao = _ref.read(statsDaoProvider);

      await statsDao.insertAttempt(
        WordAttemptsCompanion(
          sessionId: Value(state.sessionId!),
          wordId: const Value(0),
          success: Value(success),
          firstTry: const Value(true),
          hintUsed: Value(state.hintsUsed > 0),
          durationMs: Value(state.elapsedSeconds * 1000),
        ),
      );
    } catch (_) {
      // Erreur silencieuse
    }
  }

  /// Termine la partie.
  Future<void> _finishGame() async {
    _timer?.cancel();
    try {
      if (state.sessionId != null) {
        final statsDao = _ref.read(statsDaoProvider);
        await statsDao.endSession(
          state.sessionId!,
          DateTime.now(),
          state.totalScore,
        );
        // Statistiques journalières
        if (state.profileId != null) {
          final attempts =
              await statsDao.getAttemptsForSession(state.sessionId!);
          final successes = attempts.where((a) => a.success).length;
          await statsDao.recordDailyProgress(
            profileId: state.profileId!,
            wordsSeen: state.totalWords,
            wordsSuccess: successes,
            minutesPlayed: (state.elapsedSeconds ~/ 60).clamp(1, 999),
          );
        }
      }
    } catch (_) {
      // Erreur silencieuse
    }
    state = state.copyWith(isFinished: true);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provider du jeu Mots Croisés.
final crosswordGameProvider =
    StateNotifierProvider<CrosswordNotifier, CrosswordGameState>(
  (ref) => CrosswordNotifier(ref),
);
