// ============================================================
// Fichier : lib/features/games/definition_qcm/definition_qcm_providers.dart
// Description : Providers Riverpod pour le jeu QCM Définition.
//               Gère l'état de la session : question courante,
//               réponse sélectionnée, score, session stats.
//               100 % hors-ligne.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import 'definition_qcm_logic.dart';

// ---------------------------------------------------------------------------
// État
// ---------------------------------------------------------------------------

/// État complet d'une session QCM Définition.
class DefinitionQcmState {
  const DefinitionQcmState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedIndex,
    this.totalScore = 0,
    this.correctCount = 0,
    this.isLoading = true,
    this.isFinished = false,
    this.error,
    this.sessionId,
    this.startTimeMs,
    this.dictionaryId,
    this.profileId,
  });

  final List<QcmQuestion> questions;
  final int currentIndex;

  /// Index de la réponse choisie par l'enfant (null = pas encore répondu).
  final int? selectedIndex;
  final int totalScore;
  final int correctCount;
  final bool isLoading;
  final bool isFinished;
  final String? error;
  final int? sessionId;
  final int? startTimeMs;
  final int? dictionaryId;
  final int? profileId;

  QcmQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get hasAnswered => selectedIndex != null;

  bool get isCorrect =>
      selectedIndex != null && selectedIndex == currentQuestion?.correctIndex;

  String get progressLabel => '${currentIndex + 1} / ${questions.length}';

  DefinitionQcmState copyWith({
    List<QcmQuestion>? questions,
    int? currentIndex,
    int? selectedIndex,
    bool clearSelected = false,
    int? totalScore,
    int? correctCount,
    bool? isLoading,
    bool? isFinished,
    String? error,
    int? sessionId,
    int? startTimeMs,
    int? dictionaryId,
    int? profileId,
  }) {
    return DefinitionQcmState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedIndex:
          clearSelected ? null : (selectedIndex ?? this.selectedIndex),
      totalScore: totalScore ?? this.totalScore,
      correctCount: correctCount ?? this.correctCount,
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

/// Contrôleur de la session QCM Définition.
class DefinitionQcmNotifier extends StateNotifier<DefinitionQcmState> {
  DefinitionQcmNotifier(this._ref) : super(const DefinitionQcmState());

  final Ref _ref;
  DateTime? _sessionStart;

  /// Démarre une session avec des mots sélectionnés par le SRS.
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

      // Mots SRS pour la session (candidats-cibles)
      final sessionWords = await wordsDao.selectWordsForSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        limit: wordCount,
      );

      if (sessionWords.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Aucun mot dans ce dictionnaire.',
        );
        return;
      }

      // Tous les mots du dictionnaire (pour les distracteurs)
      final allWordsRaw =
          await wordsDao.watchWordsForDictionary(dictionaryId).first;

      // Résoudre la définition à afficher dans le QCM.
      // Priorité : def_fleches (style mots fléchés, courte et sans le mot)
      //          > def_croises (style mots croisés)
      //          > def_complete (définition longue)
      //          > définition saisie manuellement dans app.db
      // On consulte toujours definitions.db en premier, indépendamment de
      // ce qui est stocké dans app.db.
      final defDb = await _ref.read(definitionsProvider.future);
      Future<Word> enrich(Word w) async {
        try {
          final entry = await defDb.getDefinition(w.mot);
          if (entry != null) {
            final def = (entry.defFleches?.trim().isNotEmpty == true)
                ? entry.defFleches
                : (entry.defCroises?.trim().isNotEmpty == true)
                    ? entry.defCroises
                    : (entry.definition?.trim().isNotEmpty == true)
                        ? entry.definition
                        : null;
            if (def != null) {
              return w.copyWith(definition: Value(def));
            }
          }
        } catch (_) {}
        // Repli : définition saisie manuellement dans app.db
        return w;
      }

      final allWords = await Future.wait(allWordsRaw.map(enrich));
      final sessionWordsEnriched = await Future.wait(sessionWords.map(enrich));

      final questions = DefinitionQcmLogic().buildQuestions(
        allWords: allWords,
        sessionWords: sessionWordsEnriched,
      );

      if (questions.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Les mots de ce dictionnaire n\'ont pas de définitions.\n'
              'Ajoutez des définitions depuis la liste des mots.',
        );
        return;
      }

      final sessionId = await statsDao.startSession(
        SessionsCompanion(
          profileId: Value(profileId),
          dictionaryId: Value(dictionaryId),
          activityType: const Value('definition_qcm'),
        ),
      );

      state = state.copyWith(
        questions: questions,
        sessionId: sessionId,
        isLoading: false,
        totalScore: 0,
        correctCount: 0,
        currentIndex: 0,
        clearSelected: true,
        startTimeMs: DateTime.now().millisecondsSinceEpoch,
      );
      _sessionStart = DateTime.now();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur au démarrage : $e',
      );
    }
  }

  /// L'enfant a sélectionné la réponse à l'index [index].
  Future<void> selectAnswer(int index) async {
    if (state.hasAnswered) return; // déjà répondu

    final question = state.currentQuestion;
    if (question == null) return;

    final correct = index == question.correctIndex;
    final points = correct ? 20 : 0;

    state = state.copyWith(
      selectedIndex: index,
      totalScore: state.totalScore + points,
      correctCount: correct ? state.correctCount + 1 : state.correctCount,
    );

    await _recordAttempt(success: correct);
  }

  /// Passe à la question suivante.
  void nextQuestion() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      _finishGame();
      return;
    }
    state = state.copyWith(
      currentIndex: nextIndex,
      clearSelected: true,
      startTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _recordAttempt({required bool success}) async {
    try {
      final question = state.currentQuestion;
      if (question == null ||
          state.sessionId == null ||
          state.profileId == null) {
        return;
      }

      final statsDao = _ref.read(statsDaoProvider);
      final wordsDao = _ref.read(wordsDaoProvider);
      final durationMs = DateTime.now().millisecondsSinceEpoch -
          (state.startTimeMs ?? DateTime.now().millisecondsSinceEpoch);

      await statsDao.insertAttempt(
        WordAttemptsCompanion(
          sessionId: Value(state.sessionId!),
          wordId: Value(question.word.id),
          success: Value(success),
          firstTry: Value(success),
          hintUsed: const Value(false),
          durationMs: Value(durationMs),
        ),
      );

      final profileId = state.profileId!;
      final existing = await wordsDao.getMastery(question.word.id, profileId);
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
          wordId: Value(question.word.id),
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
      // Erreur silencieuse — le jeu continue
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
            wordsSeen: state.questions.length,
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

/// Provider du jeu QCM Définition.
final definitionQcmProvider =
    StateNotifierProvider<DefinitionQcmNotifier, DefinitionQcmState>(
  (ref) => DefinitionQcmNotifier(ref),
);
