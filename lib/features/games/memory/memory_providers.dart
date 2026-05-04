// ============================================================
// Fichier : lib/features/games/memory/memory_providers.dart
// Description : Providers Riverpod pour le jeu Memory.
//               Gère le plateau de cartes, les sélections,
//               le score et l'enregistrement des statistiques.
//               100 % hors-ligne.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import 'memory_logic.dart';

// ---------------------------------------------------------------------------
// État
// ---------------------------------------------------------------------------

/// État complet d'une session Memory.
class MemoryGameState {
  const MemoryGameState({
    this.cards = const [],
    this.selectedUids = const [],
    this.matchedCount = 0,
    this.attempts = 0,
    this.isLoading = true,
    this.isChecking = false,
    this.isFinished = false,
    this.error,
    this.sessionId,
    this.totalPairs = 0,
    this.dictionaryId,
    this.profileId,
  });

  /// Toutes les cartes du plateau.
  final List<MemoryCard> cards;

  /// UIDs des cartes actuellement retournées (0, 1 ou 2).
  final List<String> selectedUids;

  /// Nombre de paires appariées.
  final int matchedCount;

  /// Nombre de tentatives (retournement de 2 cartes = 1 tentative).
  final int attempts;

  final bool isLoading;

  /// Vrai pendant le délai d'affichage d'une mauvaise paire.
  final bool isChecking;

  final bool isFinished;
  final String? error;
  final int? sessionId;

  /// Nombre total de paires dans la session.
  final int totalPairs;

  final int? dictionaryId;
  final int? profileId;

  /// Progression de 0 à 1.
  double get progress => totalPairs > 0 ? matchedCount / totalPairs : 0;

  /// Score courant : 100 par paire, -5 par tentative ratée.
  int get score {
    if (matchedCount == 0) return 0;
    final base = matchedCount * 100;
    final failed = (attempts - matchedCount).clamp(0, 9999);
    return (base - failed * 5).clamp(0, base);
  }

  MemoryGameState copyWith({
    List<MemoryCard>? cards,
    List<String>? selectedUids,
    int? matchedCount,
    int? attempts,
    bool? isLoading,
    bool? isChecking,
    bool? isFinished,
    String? error,
    int? sessionId,
    int? totalPairs,
    int? dictionaryId,
    int? profileId,
  }) {
    return MemoryGameState(
      cards: cards ?? this.cards,
      selectedUids: selectedUids ?? this.selectedUids,
      matchedCount: matchedCount ?? this.matchedCount,
      attempts: attempts ?? this.attempts,
      isLoading: isLoading ?? this.isLoading,
      isChecking: isChecking ?? this.isChecking,
      isFinished: isFinished ?? this.isFinished,
      error: error,
      sessionId: sessionId ?? this.sessionId,
      totalPairs: totalPairs ?? this.totalPairs,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      profileId: profileId ?? this.profileId,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Contrôleur de la session Memory.
class MemoryNotifier extends StateNotifier<MemoryGameState> {
  MemoryNotifier(this._ref) : super(const MemoryGameState());

  final Ref _ref;
  DateTime? _sessionStart;

  /// Démarre une nouvelle session avec [pairCount] paires de mots.
  Future<void> startGame({
    required int dictionaryId,
    required int profileId,
    int pairCount = 6,
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
        limit: pairCount,
      );

      if (words.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Aucun mot dans ce dictionnaire. '
              'Ajoutez des mots depuis la recherche.',
        );
        return;
      }

      // Enrichissement des définitions depuis definitions.db
      final pairs = <MemoryPairData>[];
      try {
        final defDb = await _ref.read(definitionsProvider.future);
        for (final w in words) {
          String? def = w.definition?.isNotEmpty == true ? w.definition : null;
          if (def == null || def.isEmpty) {
            final entry = await defDb.getDefinition(w.mot);
            // Préférence : def_fleches (ne contient pas le mot), sinon définition complète
            def = entry?.defFleches?.isNotEmpty == true
                ? entry!.defFleches
                : entry?.definition;
          }
          pairs.add(
            MemoryPairData(
              wordId: w.id,
              mot: w.mot,
              definition: def,
            ),
          );
        }
      } catch (_) {
        // Fallback si definitions.db indisponible
        for (final w in words) {
          pairs.add(
            MemoryPairData(
              wordId: w.id,
              mot: w.mot,
              definition: w.definition,
            ),
          );
        }
      }

      final sessionId = await statsDao.startSession(
        SessionsCompanion(
          profileId: Value(profileId),
          dictionaryId: Value(dictionaryId),
          activityType: const Value('memory'),
        ),
      );

      final cards = buildMemoryCards(pairs);

      state = state.copyWith(
        cards: cards,
        sessionId: sessionId,
        totalPairs: pairs.length,
        isLoading: false,
        matchedCount: 0,
        attempts: 0,
        selectedUids: [],
        isFinished: false,
        isChecking: false,
      );
      _sessionStart = DateTime.now();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur au démarrage : $e',
      );
    }
  }

  /// Retourne une carte identifiée par [uid].
  /// Retourne [false] si l'action est bloquée (partie terminée, vérification en cours…).
  bool selectCard(String uid) {
    if (state.isChecking || state.isFinished || state.isLoading) return false;

    final cardIndex = state.cards.indexWhere((c) => c.uid == uid);
    if (cardIndex == -1) return false;

    final card = state.cards[cardIndex];

    // Ignorer les cartes déjà appariées, face visible ou déjà sélectionnées
    if (card.isMatched || card.isFaceUp) return false;
    if (state.selectedUids.contains(uid)) return false;

    // Retourner la carte
    final updatedCards = List<MemoryCard>.from(state.cards);
    updatedCards[cardIndex] = card.copyWith(isFaceUp: true);

    final newSelected = [...state.selectedUids, uid];

    if (newSelected.length < 2) {
      state = state.copyWith(cards: updatedCards, selectedUids: newSelected);
      return true;
    }

    // Deux cartes sélectionnées → vérification
    final firstCard = updatedCards.firstWhere((c) => c.uid == newSelected[0]);
    final secondCard = updatedCards.firstWhere((c) => c.uid == newSelected[1]);
    final isMatch = firstCard.wordId == secondCard.wordId;

    if (isMatch) {
      // Paire trouvée : marquer comme appariées
      final matchedCards = updatedCards
          .map(
            (c) => c.uid == newSelected[0] || c.uid == newSelected[1]
                ? c.copyWith(isMatched: true)
                : c,
          )
          .toList();

      final newMatchedCount = state.matchedCount + 1;
      final newAttempts = state.attempts + 1;

      state = state.copyWith(
        cards: matchedCards,
        selectedUids: [],
        matchedCount: newMatchedCount,
        attempts: newAttempts,
      );

      if (newMatchedCount >= state.totalPairs) {
        _finishGame();
      }
    } else {
      // Mauvaise paire → bloquer en attendant retournement
      state = state.copyWith(
        cards: updatedCards,
        selectedUids: newSelected,
        attempts: state.attempts + 1,
        isChecking: true,
      );
    }

    return true;
  }

  /// Retourne face cachée les deux cartes non appariées.
  /// Doit être appelé depuis l'UI après le délai d'affichage.
  void resolveSelection() {
    if (!state.isChecking) return;
    final toFlipBack = state.selectedUids;
    final updatedCards = state.cards
        .map(
          (c) => toFlipBack.contains(c.uid) ? c.copyWith(isFaceUp: false) : c,
        )
        .toList();
    state = state.copyWith(
      cards: updatedCards,
      selectedUids: [],
      isChecking: false,
    );
  }

  /// Recommence une session avec le même dictionnaire.
  void restart() => startGame(
        dictionaryId: state.dictionaryId ?? 0,
        profileId: state.profileId ?? 0,
      );

  /// Termine la session et enregistre les stats.
  Future<void> _finishGame() async {
    try {
      final statsDao = _ref.read(statsDaoProvider);
      if (state.sessionId != null) {
        await statsDao.endSession(
          state.sessionId!,
          DateTime.now(),
          state.score,
        );
        if (state.profileId != null) {
          final elapsedMs = _sessionStart != null
              ? DateTime.now().difference(_sessionStart!).inMilliseconds
              : 60000;
          await statsDao.recordDailyProgress(
            profileId: state.profileId!,
            wordsSeen: state.totalPairs * 2,
            wordsSuccess: state.matchedCount,
            minutesPlayed: (elapsedMs / 60000).round().clamp(1, 999),
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

/// Provider du jeu Memory.
final memoryGameProvider =
    StateNotifierProvider<MemoryNotifier, MemoryGameState>(
  (ref) => MemoryNotifier(ref),
);
