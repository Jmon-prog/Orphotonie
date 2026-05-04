// ============================================================
// Fichier : lib/features/games/flashcard/flashcard_providers.dart
// Description : Providers Riverpod pour le jeu Flashcard Leitner.
//               Gère l'état de la session : mot courant, face affichée,
//               score, boîtes Leitner, enregistrement en base.
//               100 % hors-ligne.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import 'flashcard_logic.dart';

// ---------------------------------------------------------------------------
// État
// ---------------------------------------------------------------------------

/// État complet d'une session flashcard.
class FlashcardGameState {
  const FlashcardGameState({
    this.words = const [],
    this.currentIndex = 0,
    this.logic,
    this.knownCount = 0,
    this.unknownCount = 0,
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
  final FlashcardLogic? logic;
  final int knownCount;
  final int unknownCount;
  final bool isLoading;
  final bool isFinished;
  final String? error;
  final int? sessionId;
  final int? startTimeMs;
  final int? dictionaryId;
  final int? profileId;

  Word? get currentWord =>
      currentIndex < words.length ? words[currentIndex] : null;

  bool get isRevealed => logic?.isRevealed ?? false;

  String get progressLabel => '${currentIndex + 1} / ${words.length}';

  int get totalScore => knownCount * 10;

  FlashcardGameState copyWith({
    List<Word>? words,
    int? currentIndex,
    FlashcardLogic? logic,
    int? knownCount,
    int? unknownCount,
    bool? isLoading,
    bool? isFinished,
    String? error,
    int? sessionId,
    int? startTimeMs,
    int? dictionaryId,
    int? profileId,
  }) {
    return FlashcardGameState(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      logic: logic ?? this.logic,
      knownCount: knownCount ?? this.knownCount,
      unknownCount: unknownCount ?? this.unknownCount,
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

/// Contrôleur de la session Flashcard Leitner.
class FlashcardNotifier extends StateNotifier<FlashcardGameState> {
  FlashcardNotifier(this._ref) : super(const FlashcardGameState());

  final Ref _ref;
  DateTime? _sessionStart;

  /// Démarre une session avec [wordCount] mots du dictionnaire.
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
          error: 'Aucun mot dans ce dictionnaire. '
              'Ajoutez des mots depuis la recherche.',
        );
        return;
      }

      final sessionId = await statsDao.startSession(
        SessionsCompanion(
          profileId: Value(profileId),
          dictionaryId: Value(dictionaryId),
          activityType: const Value('flashcard'),
        ),
      );

      state = state.copyWith(
        words: words,
        sessionId: sessionId,
        isLoading: false,
        knownCount: 0,
        unknownCount: 0,
      );
      _sessionStart = DateTime.now();

      _loadCard(0);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur au démarrage : $e',
      );
    }
  }

  /// Charge la carte à l'index [index].
  /// Lit la définition dans definitions.db si le mot n'en a pas dans app.db.
  Future<void> _loadCard(int index) async {
    if (index >= state.words.length) {
      _finishGame();
      return;
    }

    final word = state.words[index];
    String? definition =
        word.definition?.isNotEmpty == true ? word.definition : null;

    debugPrint(
      '[Flashcard] _loadCard(${word.mot}) — def app.db: "$definition"',
    );

    // Fallback : chercher dans definitions.db
    if (definition == null || definition.isEmpty) {
      try {
        debugPrint(
          '[Flashcard] Recherche dans definitions.db pour "${word.mot}"',
        );
        final defDb = await _ref.read(definitionsProvider.future);
        final entry = await defDb.getDefinition(word.mot);
        debugPrint(
          '[Flashcard] Résultat definitions.db: entry=${entry?.mot}, def="${entry?.definition}"',
        );
        definition = entry?.definition;
      } catch (e, st) {
        debugPrint('[Flashcard] ERREUR definitions.db: $e\n$st');
      }
    }

    debugPrint(
      '[Flashcard] Définition finale pour "${word.mot}": "$definition"',
    );

    state = state.copyWith(
      currentIndex: index,
      logic: FlashcardLogic(mot: word.mot, definition: definition),
      startTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Révèle la définition de la carte courante.
  void reveal() {
    final word = state.currentWord;
    if (word == null) return;
    // Conserver la définition déjà enrichie depuis definitions.db
    final logic = FlashcardLogic(
      mot: word.mot,
      definition: state.logic?.definition,
    );
    logic.reveal();
    state = state.copyWith(logic: logic);
  }

  /// L'enfant a répondu [known] (il connaît ou non le mot).
  Future<void> answer(bool known) async {
    await _recordAttempt(success: known);

    state = state.copyWith(
      knownCount: known ? state.knownCount + 1 : state.knownCount,
      unknownCount: known ? state.unknownCount : state.unknownCount + 1,
    );

    await _loadCard(state.currentIndex + 1);
  }

  /// Enregistre la tentative dans app.db et met à jour la maîtrise Leitner.
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
          firstTry: Value(success),
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
      // Erreur silencieuse — le jeu continue
    }
  }

  /// Termine la session et enregistre les stats journalières.
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

  // ---------------------------------------------------------------------------
  // Helpers Leitner / SRS
  // ---------------------------------------------------------------------------

  int _nextLeitnerBox(int currentBox, int consecutiveOk) {
    if (consecutiveOk >= 2 && currentBox < 5) return currentBox + 1;
    return currentBox;
  }

  int _penalizeLeitnerBox(int currentBox) {
    if (currentBox > 1) return currentBox - 1;
    return 1;
  }

  DateTime _nextReviewDate(int box) {
    const delays = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};
    return DateTime.now().add(Duration(days: delays[box] ?? 1));
  }

  int _masteryLevel(int box) => (box - 1).clamp(0, 4);
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provider du jeu Flashcard Leitner.
final flashcardGameProvider =
    StateNotifierProvider<FlashcardNotifier, FlashcardGameState>(
  (ref) => FlashcardNotifier(ref),
);
