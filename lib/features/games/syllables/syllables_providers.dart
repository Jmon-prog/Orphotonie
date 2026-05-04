// ============================================================
// Fichier : lib/features/games/syllables/syllables_providers.dart
// Description : Providers Riverpod pour le jeu Roue des Syllabes.
//               Gère l'état de la session : mot courant, syllabes
//               mélangées, ordre proposé, score, session stats.
//               Découpage orthographique français (digrammes, groupes
//               consonantiques inséparables). 100 % hors-ligne.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import 'syllables_logic.dart';

// ---------------------------------------------------------------------------
// État
// ---------------------------------------------------------------------------

/// État complet d'une session Roue des Syllabes.
class SyllablesGameState {
  const SyllablesGameState({
    this.words = const [],
    this.currentIndex = 0,
    this.logic,
    this.shuffledSlots = const [],
    this.answerSlots = const [],
    this.totalScore = 0,
    this.isCorrect,
    this.isLoading = true,
    this.isFinished = false,
    this.error,
    this.sessionId,
    this.startTimeMs,
    this.dictionaryId,
    this.profileId,
  });

  final List<Word> words;
  final int currentIndex;
  final SyllablesLogic? logic;

  /// Syllabes disponibles à placer (null = déjà placée).
  final List<String?> shuffledSlots;

  /// Emplacements de la réponse (null = vide).
  final List<String?> answerSlots;
  final int totalScore;

  /// null = pas encore validé, true = correct, false = incorrect.
  final bool? isCorrect;
  final bool isLoading;
  final bool isFinished;
  final String? error;
  final int? sessionId;
  final int? startTimeMs;
  final int? dictionaryId;
  final int? profileId;

  Word? get currentWord =>
      currentIndex < words.length ? words[currentIndex] : null;

  String get progressLabel => '${currentIndex + 1} / ${words.length}';

  bool get isAnswerComplete =>
      answerSlots.isNotEmpty && answerSlots.every((s) => s != null);

  SyllablesGameState copyWith({
    List<Word>? words,
    int? currentIndex,
    SyllablesLogic? logic,
    List<String?>? shuffledSlots,
    List<String?>? answerSlots,
    int? totalScore,
    bool? isCorrect,
    bool? isLoading,
    bool? isFinished,
    String? error,
    int? sessionId,
    int? startTimeMs,
    int? dictionaryId,
    int? profileId,
  }) {
    return SyllablesGameState(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      logic: logic ?? this.logic,
      shuffledSlots: shuffledSlots ?? this.shuffledSlots,
      answerSlots: answerSlots ?? this.answerSlots,
      totalScore: totalScore ?? this.totalScore,
      isCorrect: isCorrect,
      isLoading: isLoading ?? this.isLoading,
      isFinished: isFinished ?? this.isFinished,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      profileId: profileId ?? this.profileId,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Contrôleur de la session Roue des Syllabes.
class SyllablesNotifier extends StateNotifier<SyllablesGameState> {
  SyllablesNotifier(this._ref) : super(const SyllablesGameState());

  final Ref _ref;
  DateTime? _sessionStart;

  Future<void> startGame({
    required int dictionaryId,
    required int profileId,
    int wordCount = 10,
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
          error: 'Aucun mot dans ce dictionnaire.',
        );
        return;
      }

      final sessionId = await statsDao.startSession(
        SessionsCompanion(
          profileId: Value(profileId),
          dictionaryId: Value(dictionaryId),
          activityType: const Value('syllables'),
        ),
      );

      state = state.copyWith(
        words: words,
        sessionId: sessionId,
        isLoading: false,
        totalScore: 0,
      );
      _sessionStart = DateTime.now();

      await _loadWord(0);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur au démarrage : $e',
      );
    }
  }

  Future<void> _loadWord(int index) async {
    if (index >= state.words.length) {
      await _finishGame();
      return;
    }

    final word = state.words[index];

    // Découpage orthographique français (digrammes ch/ph/ou/eau, groupes bl/tr…)
    // Pas de lookup lexique4 : syllphono est en notation phonologique (IPA-like),
    // incompatible avec un jeu d'orthographe.
    final syllables = SyllablesLogic.orthographicSplit(word.mot);

    // Passer les mots monosyllabes (pas de jeu possible)
    if (syllables.length < 2) {
      await _loadWord(index + 1);
      return;
    }

    final logic = SyllablesLogic(word.mot, syllables);
    final shuffled = logic.shuffle();

    state = state.copyWith(
      currentIndex: index,
      logic: logic,
      shuffledSlots: shuffled.cast<String?>(),
      answerSlots: List<String?>.filled(syllables.length, null),
      isCorrect: null,
      startTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Place une syllabe depuis la zone de choix vers le prochain slot vide.
  void placeSyllable(int sourceIndex) {
    if (state.isCorrect == true) return;

    final syl = state.shuffledSlots[sourceIndex];
    if (syl == null) return;

    final slots = List<String?>.from(state.answerSlots);
    final emptyIndex = slots.indexOf(null);
    if (emptyIndex == -1) return;

    slots[emptyIndex] = syl;

    final shuffled = List<String?>.from(state.shuffledSlots);
    shuffled[sourceIndex] = null;

    state = state.copyWith(shuffledSlots: shuffled, answerSlots: slots);
  }

  /// Retire une syllabe d'un slot de réponse et la remet dans la zone de choix.
  void removeSyllable(int slotIndex) {
    if (state.isCorrect == true) return;

    final syl = state.answerSlots[slotIndex];
    if (syl == null) return;

    final slots = List<String?>.from(state.answerSlots);
    slots[slotIndex] = null;

    final shuffled = List<String?>.from(state.shuffledSlots);
    final emptyIndex = shuffled.indexOf(null);
    if (emptyIndex != -1) shuffled[emptyIndex] = syl;

    state = state.copyWith(shuffledSlots: shuffled, answerSlots: slots);
  }

  Future<void> validateAnswer() async {
    final logic = state.logic;
    if (logic == null || !state.isAnswerComplete) return;

    final proposal = state.answerSlots.whereType<String>().toList();
    final result = logic.check(proposal);

    if (result == SyllablesResult.correct) {
      final points = logic.computeScore();
      state = state.copyWith(
        isCorrect: true,
        totalScore: state.totalScore + points,
      );
      await _recordAttempt(success: true);
    } else {
      state = state.copyWith(isCorrect: false);
      await _recordAttempt(success: false);
    }
  }

  Future<void> nextWord() async {
    await _loadWord(state.currentIndex + 1);
  }

  Future<void> _recordAttempt({required bool success}) async {
    try {
      final word = state.currentWord;
      if (word == null || state.sessionId == null || state.profileId == null) {
        return;
      }

      final statsDao = _ref.read(statsDaoProvider);
      final wordsDao = _ref.read(wordsDaoProvider);
      final durationMs = DateTime.now().millisecondsSinceEpoch -
          (state.startTimeMs ?? DateTime.now().millisecondsSinceEpoch);

      await statsDao.insertAttempt(
        WordAttemptsCompanion(
          sessionId: Value(state.sessionId!),
          wordId: Value(word.id),
          success: Value(success),
          firstTry: Value(success && (state.logic?.attempts ?? 1) == 1),
          hintUsed: const Value(false),
          durationMs: Value(durationMs),
        ),
      );

      final profileId = state.profileId!;
      final existing = await wordsDao.getMastery(word.id, profileId);
      final nbSeen = (existing?.nbSeen ?? 0) + 1;
      final nbSuccess = (existing?.nbSuccess ?? 0) + (success ? 1 : 0);
      final consecutiveOk = success ? (existing?.consecutiveOk ?? 0) + 1 : 0;
      final newBox = success
          ? _nextLeitnerBox(existing?.leitnerBox ?? 1, consecutiveOk)
          : _penalizeLeitnerBox(existing?.leitnerBox ?? 1);

      await wordsDao.upsertMastery(
        WordMasteryCompanion(
          id: existing != null ? Value(existing.id) : const Value.absent(),
          profileId: Value(profileId),
          wordId: Value(word.id),
          nbSeen: Value(nbSeen),
          nbSuccess: Value(nbSuccess),
          nbFirstTry: Value((existing?.nbFirstTry ?? 0) + (success ? 1 : 0)),
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

  int _penalizeLeitnerBox(int currentBox) =>
      currentBox > 1 ? currentBox - 1 : 1;

  DateTime _nextReviewDate(int box) {
    const delays = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};
    return DateTime.now().add(Duration(days: delays[box] ?? 1));
  }

  int _masteryLevel(int box) => (box - 1).clamp(0, 4);
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provider du jeu Roue des Syllabes.
final syllablesGameProvider =
    StateNotifierProvider<SyllablesNotifier, SyllablesGameState>(
  (ref) => SyllablesNotifier(ref),
);
