// ============================================================
// Fichier : lib/features/games/flashcard/flashcard_logic.dart
// Description : Logique du jeu Flashcard Leitner.
//               L'enfant voit le mot, dit s'il le connaît ou non.
//               Avance ou recule dans les boîtes Leitner.
//               100 % hors-ligne, aucune dépendance réseau.
// ============================================================

/// Résultat d'une flashcard.
enum FlashcardResult { known, unknown }

/// Score d'une session flashcard.
class FlashcardScore {
  const FlashcardScore({
    required this.knownCount,
    required this.unknownCount,
    required this.durationMs,
  });

  final int knownCount;
  final int unknownCount;
  final int durationMs;

  int get total => knownCount + unknownCount;

  /// Taux de réussite (0-100).
  double get successRate => total > 0 ? (knownCount / total) * 100 : 0;

  /// Points de la session (10 pts par mot connu).
  int get points => knownCount * 10;
}

/// Logique d'une carte : l'enfant révèle la définition puis juge sa réponse.
class FlashcardLogic {
  FlashcardLogic({required this.mot, this.definition});

  final String mot;
  final String? definition;

  bool _revealed = false;
  bool get isRevealed => _revealed;

  /// Révèle la définition ou le revers de la carte.
  void reveal() => _revealed = true;
}
