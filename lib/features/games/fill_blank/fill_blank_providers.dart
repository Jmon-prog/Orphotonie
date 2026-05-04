// ============================================================
// Fichier : lib/features/games/fill_blank/fill_blank_providers.dart
// Description : Providers Riverpod pour le jeu Mot Lacunaire.
//               Gère l'état de la partie : mot courant, lacunes,
//               mode de jeu, score, session.
//               100 % hors-ligne.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import 'fill_blank_logic.dart';

// ---------------------------------------------------------------------------
// État de la partie
// ---------------------------------------------------------------------------

/// État complet d'une partie de Mot Lacunaire.
class FillBlankGameState {
  const FillBlankGameState({
    this.words = const [],
    this.currentIndex = 0,
    this.logic,
    this.answers = const {},
    this.choices = const [],
    this.letterPool = const [],
    this.poolPlacements = const {},
    this.totalScore = 0,
    this.isCorrect,
    this.isLoading = true,
    this.isFinished = false,
    this.error,
    this.sessionId,
    this.startTimeMs,
    this.dictionaryId,
    this.profileId,
    this.mode = FillBlankMode.freeInput,
  });

  /// Mots de la session.
  final List<Word> words;

  /// Index du mot en cours.
  final int currentIndex;

  /// Logique du mot en cours.
  final FillBlankLogic? logic;

  /// Réponses en cours : index → lettre saisie.
  final Map<int, String> answers;

  /// Propositions du mode choix multiple.
  final List<String> choices;

  /// Pool de lettres pour le mode pool.
  final List<String> letterPool;

  /// Lettres du pool placées : blankIndex → poolIndex.
  final Map<int, int> poolPlacements;

  /// Score cumulé.
  final int totalScore;

  /// Résultat dernière vérification.
  final bool? isCorrect;

  /// Chargement.
  final bool isLoading;

  /// Partie terminée.
  final bool isFinished;

  /// Erreur.
  final String? error;

  /// ID session app.db.
  final int? sessionId;

  /// Timestamp début mot courant.
  final int? startTimeMs;

  /// Dictionnaire et profil.
  final int? dictionaryId;
  final int? profileId;

  /// Mode de jeu.
  final FillBlankMode mode;

  Word? get currentWord =>
      currentIndex < words.length ? words[currentIndex] : null;

  int get hintsUsed => logic?.hintsUsed ?? 0;

  String get progressLabel => '${currentIndex + 1} / ${words.length}';

  /// Mot avec lacunes (null = à remplir).
  List<String?> get wordWithBlanks => logic?.wordWithBlanks ?? [];

  /// Toutes les lacunes remplies ?
  bool get isAnswerComplete {
    final blanks = logic?.blanks ?? [];
    final revealed = logic?.revealedPositions ?? {};
    return blanks.every(
      (b) => revealed.contains(b.index) || answers.containsKey(b.index),
    );
  }

  FillBlankGameState copyWith({
    List<Word>? words,
    int? currentIndex,
    FillBlankLogic? logic,
    Map<int, String>? answers,
    List<String>? choices,
    List<String>? letterPool,
    Map<int, int>? poolPlacements,
    int? totalScore,
    bool? isCorrect,
    bool? isLoading,
    bool? isFinished,
    String? error,
    int? sessionId,
    int? startTimeMs,
    int? dictionaryId,
    int? profileId,
    FillBlankMode? mode,
  }) {
    return FillBlankGameState(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      logic: logic ?? this.logic,
      answers: answers ?? this.answers,
      choices: choices ?? this.choices,
      letterPool: letterPool ?? this.letterPool,
      poolPlacements: poolPlacements ?? this.poolPlacements,
      totalScore: totalScore ?? this.totalScore,
      isCorrect: isCorrect,
      isLoading: isLoading ?? this.isLoading,
      isFinished: isFinished ?? this.isFinished,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      profileId: profileId ?? this.profileId,
      mode: mode ?? this.mode,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Contrôleur du jeu Mot Lacunaire.
class FillBlankNotifier extends StateNotifier<FillBlankGameState> {
  FillBlankNotifier(this._ref) : super(const FillBlankGameState());

  final Ref _ref;
  DateTime? _sessionStart;

  /// Démarre une session.
  Future<void> startGame({
    required int dictionaryId,
    required int profileId,
    int wordCount = 10,
    FillBlankMode mode = FillBlankMode.freeInput,
  }) async {
    state = state.copyWith(
      isLoading: true,
      dictionaryId: dictionaryId,
      profileId: profileId,
      mode: mode,
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
          activityType: const Value('mot_lacunaire'),
        ),
      );

      state = state.copyWith(
        words: words,
        sessionId: sessionId,
        isLoading: false,
        mode: mode,
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
    final logic = FillBlankLogic(word.mot, mode: state.mode);

    state = state.copyWith(
      currentIndex: index,
      logic: logic,
      answers: const {},
      choices: state.mode == FillBlankMode.multipleChoice
          ? logic.generateChoices()
          : const [],
      letterPool: state.mode == FillBlankMode.letterPool
          ? logic.generateLetterPool()
          : const [],
      poolPlacements: const {},
      isCorrect: null,
      startTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Met à jour une lettre saisie (mode frappe libre).
  void setLetter(int blankIndex, String letter) {
    if (state.isCorrect == true) return;
    final answers = Map<int, String>.from(state.answers);
    if (letter.isEmpty) {
      answers.remove(blankIndex);
    } else {
      answers[blankIndex] = letter.toUpperCase();
    }
    state = state.copyWith(answers: answers);
  }

  /// Sélectionne une proposition (mode choix multiple).
  Future<void> selectChoice(String choice) async {
    if (state.isCorrect == true) return;
    final logic = state.logic;
    if (logic == null) return;

    final result = logic.checkChoice(choice);

    if (result == FillBlankResult.correct) {
      final durationMs = DateTime.now().millisecondsSinceEpoch -
          (state.startTimeMs ?? DateTime.now().millisecondsSinceEpoch);
      final score = logic.computeScore(durationMs: durationMs);

      state = state.copyWith(
        isCorrect: true,
        totalScore: state.totalScore + score.points,
      );
      await _recordAttempt(score);
    } else {
      state = state.copyWith(isCorrect: false);
    }
  }

  /// Place une lettre du pool dans une lacune (mode pool).
  void placePoolLetter(int poolIndex, int blankIndex) {
    if (state.isCorrect == true) return;
    if (poolIndex < 0 || poolIndex >= state.letterPool.length) return;

    final placements = Map<int, int>.from(state.poolPlacements);
    final answers = Map<int, String>.from(state.answers);

    // Si le slot était déjà occupé, libérer l'ancien pool index
    placements.removeWhere((bIdx, pIdx) => bIdx == blankIndex);

    placements[blankIndex] = poolIndex;
    answers[blankIndex] = state.letterPool[poolIndex];

    state = state.copyWith(
      poolPlacements: placements,
      answers: answers,
    );
  }

  /// Retire une lettre du pool d'une lacune.
  void removePoolLetter(int blankIndex) {
    if (state.isCorrect == true) return;

    final placements = Map<int, int>.from(state.poolPlacements);
    final answers = Map<int, String>.from(state.answers);

    placements.remove(blankIndex);
    answers.remove(blankIndex);

    state = state.copyWith(
      poolPlacements: placements,
      answers: answers,
    );
  }

  /// Vérifie la réponse (mode frappe / pool).
  Future<void> validateAnswer() async {
    final logic = state.logic;
    if (logic == null || !state.isAnswerComplete) return;

    final result = logic.check(state.answers);

    if (result == FillBlankResult.correct) {
      final durationMs = DateTime.now().millisecondsSinceEpoch -
          (state.startTimeMs ?? DateTime.now().millisecondsSinceEpoch);
      final score = logic.computeScore(durationMs: durationMs);

      state = state.copyWith(
        isCorrect: true,
        totalScore: state.totalScore + score.points,
      );
      await _recordAttempt(score);
    } else {
      state = state.copyWith(isCorrect: false);
    }
  }

  /// Révèle une lacune (aide).
  void useHint() {
    final logic = state.logic;
    if (logic == null) return;

    final hint = logic.revealHint();
    if (hint == null) return;

    // Met à jour les answers avec la lettre révélée
    final answers = Map<int, String>.from(state.answers);
    answers[hint.index] = hint.letter;

    state = state.copyWith(
      logic: logic,
      answers: answers,
    );
  }

  /// Passe au mot suivant.
  void nextWord() {
    _loadWord(state.currentIndex + 1);
  }

  /// Enregistre la tentative.
  Future<void> _recordAttempt(FillBlankScore score) async {
    try {
      final word = state.currentWord;
      if (word == null || state.sessionId == null) return;

      final statsDao = _ref.read(statsDaoProvider);
      final wordsDao = _ref.read(wordsDaoProvider);

      await statsDao.insertAttempt(
        WordAttemptsCompanion(
          sessionId: Value(state.sessionId!),
          wordId: Value(word.id),
          success: const Value(true),
          firstTry: Value(score.firstTry),
          hintUsed: Value(score.hintsUsed > 0),
          durationMs: Value(score.durationMs),
        ),
      );

      final profileId = state.profileId;
      if (profileId == null) return;

      final existing = await wordsDao.getMastery(word.id, profileId);
      final nbSeen = (existing?.nbSeen ?? 0) + 1;
      final nbSuccess = (existing?.nbSuccess ?? 0) + 1;
      final nbFirstTry = (existing?.nbFirstTry ?? 0) + (score.firstTry ? 1 : 0);
      final consecutiveOk = (existing?.consecutiveOk ?? 0) + 1;
      final newBox = _nextLeitnerBox(
        existing?.leitnerBox ?? 1,
        consecutiveOk,
      );

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
      // Erreur silencieuse
    }
  }

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

/// Provider du jeu Mot Lacunaire.
final fillBlankGameProvider =
    StateNotifierProvider<FillBlankNotifier, FillBlankGameState>(
  (ref) => FillBlankNotifier(ref),
);
