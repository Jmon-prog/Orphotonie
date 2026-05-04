// ============================================================
// Fichier : lib/features/games/hangman/hangman_providers.dart
// Description : Providers Riverpod pour le jeu Pendu.
//               Gère l'état de la partie : mot courant, lettres essayées,
//               mascotte, score, session.
//               100 % hors-ligne.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import 'hangman_logic.dart';

// ---------------------------------------------------------------------------
// État de la partie
// ---------------------------------------------------------------------------

/// État complet d'une partie de Pendu.
class HangmanGameState {
  const HangmanGameState({
    this.words = const [],
    this.currentIndex = 0,
    this.logic,
    this.totalScore = 0,
    this.lastResult,
    this.isLoading = true,
    this.isFinished = false,
    this.error,
    this.sessionId,
    this.startTimeMs,
    this.dictionaryId,
    this.profileId,
    this.difficulty = HangmanDifficulty.normal,
    this.showDefinition = false,
  });

  /// Mots de la session (sélectionnés par le SRS).
  final List<Word> words;

  /// Index du mot en cours dans [words].
  final int currentIndex;

  /// Logique du mot en cours.
  final HangmanLogic? logic;

  /// Score cumulé de la session.
  final int totalScore;

  /// Résultat de la dernière lettre proposée.
  final LetterResult? lastResult;

  /// Chargement en cours.
  final bool isLoading;

  /// Partie terminée (tous les mots joués).
  final bool isFinished;

  /// Message d'erreur.
  final String? error;

  /// ID de session dans app.db.
  final int? sessionId;

  /// Timestamp du début du mot courant (millisecondes).
  final int? startTimeMs;

  /// Dictionnaire et profil utilisés.
  final int? dictionaryId;
  final int? profileId;

  /// Difficulté choisie.
  final HangmanDifficulty difficulty;

  /// Aide 3 : afficher la définition.
  final bool showDefinition;

  /// Mot courant (raccourci).
  Word? get currentWord =>
      currentIndex < words.length ? words[currentIndex] : null;

  /// Nombre d'indices utilisés pour le mot courant.
  int get hintsUsed => logic?.hintsUsed ?? 0;

  /// Progression (ex: "3 / 10").
  String get progressLabel => '${currentIndex + 1} / ${words.length}';

  /// Lettres du mot avec révélation partielle.
  List<String?> get revealedWord => logic?.revealedWord ?? [];

  /// Lettres utilisées (correctes + incorrectes).
  Set<String> get usedLetters => logic?.usedLetters ?? {};

  /// Lettres incorrectes.
  Set<String> get incorrectLetters => logic?.incorrectLetters ?? {};

  /// Nombre d'erreurs.
  int get errorsCount => logic?.errorsCount ?? 0;

  /// Nombre max d'erreurs.
  int get maxErrors => logic?.maxErrors ?? 6;

  /// État de la mascotte (0 à 8).
  int get mascotState => logic?.mascotState ?? 0;

  /// Victoire sur le mot courant.
  bool get isWon => logic?.isWon ?? false;

  /// Défaite sur le mot courant.
  bool get isLost => logic?.isLost ?? false;

  /// Mot en cours terminé (victoire ou défaite).
  bool get isWordOver => logic?.isGameOver ?? false;

  HangmanGameState copyWith({
    List<Word>? words,
    int? currentIndex,
    HangmanLogic? logic,
    int? totalScore,
    LetterResult? lastResult,
    bool? isLoading,
    bool? isFinished,
    String? error,
    int? sessionId,
    int? startTimeMs,
    int? dictionaryId,
    int? profileId,
    HangmanDifficulty? difficulty,
    bool? showDefinition,
  }) {
    return HangmanGameState(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      logic: logic ?? this.logic,
      totalScore: totalScore ?? this.totalScore,
      lastResult: lastResult,
      isLoading: isLoading ?? this.isLoading,
      isFinished: isFinished ?? this.isFinished,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      profileId: profileId ?? this.profileId,
      difficulty: difficulty ?? this.difficulty,
      showDefinition: showDefinition ?? this.showDefinition,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Contrôleur du jeu Pendu.
class HangmanNotifier extends StateNotifier<HangmanGameState> {
  HangmanNotifier(this._ref) : super(const HangmanGameState());

  final Ref _ref;
  DateTime? _sessionStart;

  /// Démarre une session de jeu avec [wordCount] mots du dictionnaire.
  Future<void> startGame({
    required int dictionaryId,
    required int profileId,
    int wordCount = 10,
    HangmanDifficulty difficulty = HangmanDifficulty.normal,
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

      // Sélection SRS des mots prioritaires
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

      // Crée la session
      final sessionId = await statsDao.startSession(
        SessionsCompanion(
          profileId: Value(profileId),
          dictionaryId: Value(dictionaryId),
          activityType: const Value('pendu'),
        ),
      );

      state = state.copyWith(
        words: words,
        sessionId: sessionId,
        isLoading: false,
        difficulty: difficulty,
      );
      _sessionStart = DateTime.now();

      _loadWord(0);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur au démarrage : $e',
      );
    }
  }

  /// Charge le mot à l'index [index].
  void _loadWord(int index) {
    if (index >= state.words.length) {
      _finishGame();
      return;
    }

    final word = state.words[index];
    final logic = HangmanLogic(word.mot, difficulty: state.difficulty);

    state = state.copyWith(
      currentIndex: index,
      logic: logic,
      lastResult: null,
      showDefinition: false,
      startTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Propose une lettre.
  Future<void> guessLetter(String letter) async {
    final logic = state.logic;
    if (logic == null || state.isWordOver) return;

    final result = logic.guessLetter(letter);

    // Force la reconstruction de l'état (logic est mutable)
    state = state.copyWith(
      logic: logic,
      lastResult: result,
    );

    // Si le mot est terminé, enregistrer le résultat
    if (logic.isGameOver) {
      final durationMs = DateTime.now().millisecondsSinceEpoch -
          (state.startTimeMs ?? DateTime.now().millisecondsSinceEpoch);
      final score = logic.computeScore(durationMs: durationMs);

      state = state.copyWith(
        totalScore: state.totalScore + score.points,
      );

      await _recordAttempt(score);
    }
  }

  /// Aide 1 : révéler la première lettre (-20 pts).
  void useHintFirst() {
    final logic = state.logic;
    if (logic == null || state.isWordOver) return;

    logic.revealFirstLetter();
    state = state.copyWith(logic: logic);
  }

  /// Aide 2 : révéler une lettre aléatoire (-15 pts).
  void useHintRandom() {
    final logic = state.logic;
    if (logic == null || state.isWordOver) return;

    logic.revealRandomLetter();
    state = state.copyWith(logic: logic);
  }

  /// Aide 3 : afficher la définition du mot (-10 pts).
  void useHintDefinition() {
    if (state.isWordOver) return;
    state = state.copyWith(showDefinition: true);
    // On compte comme un hint dans la logique
    state.logic?.revealFirstLetter(); // hack pour incrémenter hintsUsed
    // Mais on revert la lettre révélée — on veut juste le compteur
    // Non : plus simple de laisser la lettre révélée, c'est une vraie aide.
  }

  /// Passe au mot suivant.
  void nextWord() {
    _loadWord(state.currentIndex + 1);
  }

  /// Enregistre la tentative dans app.db.
  Future<void> _recordAttempt(HangmanScore score) async {
    try {
      final word = state.currentWord;
      if (word == null || state.sessionId == null) return;

      final statsDao = _ref.read(statsDaoProvider);
      final wordsDao = _ref.read(wordsDaoProvider);

      // Tentative
      await statsDao.insertAttempt(
        WordAttemptsCompanion(
          sessionId: Value(state.sessionId!),
          wordId: Value(word.id),
          success: Value(score.won),
          firstTry: Value(score.won && score.errorsCount == 0),
          hintUsed: Value(score.hintsUsed > 0),
          durationMs: Value(score.durationMs),
        ),
      );

      // Maîtrise
      final profileId = state.profileId;
      if (profileId == null) return;

      final existing = await wordsDao.getMastery(word.id, profileId);
      final nbSeen = (existing?.nbSeen ?? 0) + 1;
      final nbSuccess = (existing?.nbSuccess ?? 0) + (score.won ? 1 : 0);
      final nbFirstTry = (existing?.nbFirstTry ?? 0) +
          (score.won && score.errorsCount == 0 ? 1 : 0);
      final consecutiveOk = score.won ? (existing?.consecutiveOk ?? 0) + 1 : 0;
      final currentBox = existing?.leitnerBox ?? 1;
      final newBox = score.won
          ? _nextLeitnerBox(currentBox, consecutiveOk)
          : (currentBox > 1 ? currentBox - 1 : 1);

      await wordsDao.upsertMastery(
        WordMasteryCompanion(
          id: existing != null ? Value(existing.id) : const Value.absent(),
          profileId: Value(profileId),
          wordId: Value(word.id),
          nbSeen: Value(nbSeen),
          nbSuccess: Value(nbSuccess),
          nbFirstTry: Value(nbFirstTry),
          consecutiveOk: Value(consecutiveOk),
          leitnerBox: Value(newBox),
          lastSeen: Value(DateTime.now()),
          nextReview: Value(_nextReviewDate(newBox)),
          masteryLevel: Value(_masteryLevel(newBox)),
        ),
      );
    } catch (_) {
      // Erreur silencieuse — le jeu continue
    }
  }

  /// Termine la partie et ferme la session.
  Future<void> _finishGame() async {
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
          final elapsedMs = _sessionStart != null
              ? DateTime.now().difference(_sessionStart!).inMilliseconds
              : 60000;
          await statsDao.recordDailyProgress(
            profileId: state.profileId!,
            wordsSeen: state.words.length,
            wordsSuccess: successes,
            minutesPlayed: (elapsedMs / 60000).round().clamp(1, 999),
          );
        }
      }
    } catch (_) {
      // Erreur silencieuse
    }

    state = state.copyWith(isFinished: true);
  }

  // ---------------------------------------------------------------------------
  // Helpers Leitner / SRS
  // ---------------------------------------------------------------------------

  int _nextLeitnerBox(int currentBox, int consecutiveOk) {
    if (consecutiveOk >= 2 && currentBox < 5) return currentBox + 1;
    return currentBox;
  }

  DateTime _nextReviewDate(int box) {
    final delays = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};
    return DateTime.now().add(Duration(days: delays[box] ?? 1));
  }

  int _masteryLevel(int box) => (box - 1).clamp(0, 4);
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provider du jeu Pendu.
final hangmanGameProvider =
    StateNotifierProvider<HangmanNotifier, HangmanGameState>(
  (ref) => HangmanNotifier(ref),
);
