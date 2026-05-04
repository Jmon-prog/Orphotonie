// ============================================================
// Fichier : lib/features/games/word_search/word_search_providers.dart
// Description : Providers Riverpod pour le jeu Mots Cachés.
//               Gère l'état de la partie : grille, sélection,
//               mots trouvés, chronomètre, session.
//               100 % hors-ligne.
// ============================================================

import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import 'word_search_generator.dart';
import 'word_search_state.dart';

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Contrôleur du jeu Mots Cachés.
class WordSearchNotifier extends StateNotifier<WordSearchGameState> {
  WordSearchNotifier(this._ref) : super(const WordSearchGameState());

  final Ref _ref;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Démarre une session.
  Future<void> startGame({
    required int dictionaryId,
    required int profileId,
    int wordCount = 6,
    WordSearchDifficulty difficulty = WordSearchDifficulty.normal,
  }) async {
    state = state.copyWith(
      isLoading: true,
      dictionaryId: dictionaryId,
      profileId: profileId,
      difficulty: difficulty,
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
          error: 'Aucun mot dans ce dictionnaire. '
              'Ajoutez des mots depuis la recherche.',
        );
        return;
      }

      final sessionId = await statsDao.startSession(
        SessionsCompanion(
          profileId: Value(profileId),
          dictionaryId: Value(dictionaryId),
          activityType: const Value('mots_caches'),
        ),
      );

      // Générer la grille
      final generator = WordSearchGenerator(difficulty: difficulty);
      final wordStrings = words.map((w) => w.mot).toList();
      final gridData = generator.generate(wordStrings);

      state = state.copyWith(
        gridData: gridData,
        sessionId: sessionId,
        isLoading: false,
        startTimeMs: DateTime.now().millisecondsSinceEpoch,
        elapsedSeconds: 0,
        foundWords: const {},
        foundWordColors: const {},
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur au démarrage : $e',
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

  /// Début de sélection (appui / clic).
  void startSelection(int row, int col) {
    if (state.isFinished || state.allFound) return;
    state = state.copyWith(
      currentSelection: [(row, col)],
      isSelecting: true,
    );
  }

  /// Mise à jour de la sélection (glissement).
  void updateSelection(int row, int col) {
    if (!state.isSelecting) return;
    if (state.currentSelection.isEmpty) return;

    final start = state.currentSelection.first;
    final cells = WordSearchGenerator.cellsBetween(
      start.$1,
      start.$2,
      row,
      col,
    );

    if (cells.isNotEmpty) {
      state = state.copyWith(currentSelection: cells);
    }
  }

  /// Fin de sélection (relâchement).
  Future<void> endSelection() async {
    if (!state.isSelecting) return;

    final selection = state.currentSelection;
    state = state.copyWith(
      isSelecting: false,
      currentSelection: const [],
    );

    if (selection.length < 2) return;
    if (!WordSearchGenerator.isValidSelection(selection)) return;

    final gridData = state.gridData;
    if (gridData == null) return;

    // Vérifier si la sélection correspond à un mot
    final found = WordSearchGenerator.checkSelection(
      selection,
      gridData.placedWords,
    );

    if (found != null && !state.foundWords.contains(found.word)) {
      state = state.withFoundWord(found.word);

      // Points : 10 pts par lettre
      final points = found.word.length * 10;
      state = state.copyWith(
        totalScore: state.totalScore + points,
      );

      await _recordAttempt(found);

      // Victoire ?
      if (state.allFound) {
        await _finishGame();
      }
    }
  }

  /// Enregistre la découverte d'un mot.
  Future<void> _recordAttempt(PlacedWord placed) async {
    try {
      if (state.sessionId == null) return;

      final statsDao = _ref.read(statsDaoProvider);

      // Enregistrer la tentative
      final dictionaryId = state.dictionaryId;
      final profileId = state.profileId;
      if (dictionaryId == null || profileId == null) return;

      await statsDao.insertAttempt(
        WordAttemptsCompanion(
          sessionId: Value(state.sessionId!),
          wordId: const Value(0), // Pas d'ID mot spécifique en mots cachés
          success: const Value(true),
          firstTry: const Value(true),
          hintUsed: const Value(false),
          durationMs: Value(state.elapsedSeconds * 1000),
        ),
      );
    } catch (_) {
      // Erreur silencieuse
    }
  }

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
            wordsSeen: state.gridData?.placedWords.length ?? 0,
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

/// Provider du jeu Mots Cachés.
final wordSearchGameProvider =
    StateNotifierProvider<WordSearchNotifier, WordSearchGameState>(
  (ref) => WordSearchNotifier(ref),
);
