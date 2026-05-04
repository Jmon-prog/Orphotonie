// ============================================================
// Fichier : lib/features/games/anagram/anagram_providers.dart
// Description : Providers Riverpod pour le jeu Anagramme.
//               Gère l'état de la partie : mot courant, lettres mélangées,
//               réponse de l'enfant, score, session.
//               100 % hors-ligne.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import 'anagram_logic.dart';

// ---------------------------------------------------------------------------
// État de la partie
// ---------------------------------------------------------------------------

/// État complet d'une partie d'anagramme.
class AnagramGameState {
  const AnagramGameState({
    this.words = const [],
    this.currentIndex = 0,
    this.logic,
    this.shuffledLetters = const [],
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

  /// Mots de la session (sélectionnés par le SRS).
  final List<Word> words;

  /// Index du mot en cours dans [words].
  final int currentIndex;

  /// Logique du mot en cours.
  final AnagramLogic? logic;

  /// Lettres mélangées (zone du haut).
  final List<String?> shuffledLetters;

  /// Emplacements de réponse (zone du bas).
  final List<String?> answerSlots;

  /// Score cumulé de la session.
  final int totalScore;

  /// Résultat de la dernière vérification (null = pas encore vérifié).
  final bool? isCorrect;

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

  /// Mot courant (raccourci).
  Word? get currentWord =>
      currentIndex < words.length ? words[currentIndex] : null;

  /// Nombre d'indices utilisés pour le mot courant.
  int get hintsUsed => logic?.hintsUsed ?? 0;

  /// Progression (ex: "3 / 10").
  String get progressLabel => '${currentIndex + 1} / ${words.length}';

  /// La réponse est complète (tous les slots remplis).
  bool get isAnswerComplete =>
      answerSlots.isNotEmpty && answerSlots.every((s) => s != null);

  AnagramGameState copyWith({
    List<Word>? words,
    int? currentIndex,
    AnagramLogic? logic,
    List<String?>? shuffledLetters,
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
    return AnagramGameState(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      logic: logic ?? this.logic,
      shuffledLetters: shuffledLetters ?? this.shuffledLetters,
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

/// Contrôleur du jeu Anagramme.
class AnagramNotifier extends StateNotifier<AnagramGameState> {
  AnagramNotifier(this._ref) : super(const AnagramGameState());

  final Ref _ref;
  DateTime? _sessionStart;

  /// Démarre une session de jeu avec [wordCount] mots du dictionnaire.
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
          activityType: const Value('anagramme'),
        ),
      );

      state = state.copyWith(
        words: words,
        sessionId: sessionId,
        isLoading: false,
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

  /// Charge le mot à l'index [index] et mélange ses lettres.
  void _loadWord(int index) {
    if (index >= state.words.length) {
      _finishGame();
      return;
    }

    final word = state.words[index];
    final logic = AnagramLogic(word.mot);
    final shuffled = logic.shuffle();

    state = state.copyWith(
      currentIndex: index,
      logic: logic,
      shuffledLetters: shuffled.cast<String?>(),
      answerSlots: List<String?>.filled(word.mot.length, null),
      isCorrect: null,
      startTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Place une lettre depuis la zone mélangée vers le prochain slot vide.
  void placeLetter(int sourceIndex) {
    if (state.isCorrect == true) return; // mot déjà validé

    final letter = state.shuffledLetters[sourceIndex];
    if (letter == null) return;

    // Trouve le prochain slot vide
    final slots = List<String?>.from(state.answerSlots);
    final emptyIndex = slots.indexOf(null);
    if (emptyIndex == -1) return;

    slots[emptyIndex] = letter;

    final shuffled = List<String?>.from(state.shuffledLetters);
    shuffled[sourceIndex] = null;

    state = state.copyWith(
      shuffledLetters: shuffled,
      answerSlots: slots,
    );
  }

  /// Retire une lettre d'un slot de réponse et la remet dans la zone mélangée.
  void removeLetter(int slotIndex) {
    if (state.isCorrect == true) return;

    final letter = state.answerSlots[slotIndex];
    if (letter == null) return;

    final slots = List<String?>.from(state.answerSlots);
    slots[slotIndex] = null;

    // Remet la lettre dans le premier emplacement vide de la zone mélangée
    final shuffled = List<String?>.from(state.shuffledLetters);
    final emptyIndex = shuffled.indexOf(null);
    if (emptyIndex != -1) {
      shuffled[emptyIndex] = letter;
    }

    state = state.copyWith(
      shuffledLetters: shuffled,
      answerSlots: slots,
    );
  }

  /// Vérifie la réponse de l'enfant.
  Future<void> validateAnswer() async {
    final logic = state.logic;
    if (logic == null || !state.isAnswerComplete) return;

    final proposal = state.answerSlots.whereType<String>().toList();
    final result = logic.check(proposal);

    if (result == AnagramResult.correct) {
      final durationMs = DateTime.now().millisecondsSinceEpoch -
          (state.startTimeMs ?? DateTime.now().millisecondsSinceEpoch);
      final score = logic.computeScore(durationMs: durationMs);

      state = state.copyWith(
        isCorrect: true,
        totalScore: state.totalScore + score.points,
      );

      // Enregistre la tentative et met à jour la maîtrise
      await _recordAttempt(score);
    } else {
      state = state.copyWith(isCorrect: false);
    }
  }

  /// Enregistre la tentative dans app.db.
  Future<void> _recordAttempt(AnagramScore score) async {
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
          success: const Value(true),
          firstTry: Value(score.firstTry),
          hintUsed: Value(score.hintsUsed > 0),
          durationMs: Value(score.durationMs),
        ),
      );

      // Maîtrise
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
      // Erreur silencieuse — le jeu continue
    }
  }

  /// Révèle un indice (prochaine lettre).
  void useHint() {
    final logic = state.logic;
    if (logic == null) return;

    // Passe les slots actuels pour que revealHint saute les positions
    // déjà correctement remplies par l'utilisateur.
    final hint = logic.revealHint(state.answerSlots);
    if (hint == null) return;

    // Place la lettre révélée dans le bon slot
    final slots = List<String?>.from(state.answerSlots);
    final shuffled = List<String?>.from(state.shuffledLetters);
    // slots[hint.index] != hint.letter garanti par revealHint (sécurité).
    if (slots[hint.index] == hint.letter) return;

    // Si le slot contient une mauvaise lettre, la remettre dans la zone mélangée
    if (slots[hint.index] != null) {
      final wrongLetter = slots[hint.index]!;
      final emptyIdx = shuffled.indexOf(null);
      if (emptyIdx != -1) shuffled[emptyIdx] = wrongLetter;
    }

    // Place la lettre correcte dans le slot
    slots[hint.index] = hint.letter;

    // Retire la lettre de la zone mélangée, ou d'un autre slot si elle n'y est pas
    // (cas où toutes les lettres sont déjà placées par l'utilisateur)
    final sourceIdx = shuffled.indexOf(hint.letter);
    if (sourceIdx != -1) {
      shuffled[sourceIdx] = null;
    } else {
      // La lettre est dans un autre slot → on la retire de là
      for (int i = 0; i < slots.length; i++) {
        if (i != hint.index && slots[i] == hint.letter) {
          slots[i] = null;
          break;
        }
      }
    }

    state = state.copyWith(
      shuffledLetters: shuffled,
      answerSlots: slots,
    );
  }

  /// Passe au mot suivant.
  void nextWord() {
    _loadWord(state.currentIndex + 1);
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

  /// Calcule la prochaine boîte Leitner (1-5).
  int _nextLeitnerBox(int currentBox, int consecutiveOk) {
    if (consecutiveOk >= 2 && currentBox < 5) return currentBox + 1;
    return currentBox;
  }

  /// Date de prochaine révision selon la boîte.
  DateTime _nextReviewDate(int box) {
    final delays = {1: 1, 2: 3, 3: 7, 4: 14, 5: 30};
    return DateTime.now().add(Duration(days: delays[box] ?? 1));
  }

  /// Niveau de maîtrise (0-4) depuis la boîte Leitner.
  int _masteryLevel(int box) => (box - 1).clamp(0, 4);
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provider du jeu Anagramme.
final anagramGameProvider =
    StateNotifierProvider<AnagramNotifier, AnagramGameState>(
  (ref) => AnagramNotifier(ref),
);
