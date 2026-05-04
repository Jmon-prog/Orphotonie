// ============================================================
// Fichier : lib/features/games/memory/memory_logic.dart
// Description : Logique du jeu Memory (Jeu des paires).
//               Chaque mot est associé à une carte "mot" et une
//               carte "définition". L'enfant retourne des paires
//               pour associer le mot à sa définition.
//               100 % hors-ligne, aucune dépendance réseau.
// ============================================================

import 'dart:math';

// ---------------------------------------------------------------------------
// Modèles
// ---------------------------------------------------------------------------

/// Une carte du plateau Memory.
class MemoryCard {
  MemoryCard({
    required this.uid,
    required this.wordId,
    required this.content,
    required this.isWordSide,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  /// Identifiant unique sur le plateau (ex. "3_w", "3_d").
  final String uid;

  /// Clé de correspondance : les deux cartes d'une même paire partagent le même [wordId].
  final int wordId;

  /// Texte affiché côté face (mot ou définition).
  final String content;

  /// Vrai si cette carte représente le côté "mot", faux si c'est la "définition".
  final bool isWordSide;

  bool isFaceUp;
  bool isMatched;

  MemoryCard copyWith({bool? isFaceUp, bool? isMatched}) {
    return MemoryCard(
      uid: uid,
      wordId: wordId,
      content: content,
      isWordSide: isWordSide,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}

/// Données source d'une paire (mot + définition optionnelle).
class MemoryPairData {
  const MemoryPairData({
    required this.wordId,
    required this.mot,
    this.definition,
  });

  final int wordId;
  final String mot;

  /// Si null ou vide, les deux cartes afficheront le mot (mode simplifié).
  final String? definition;
}

/// Score d'une session Memory.
class MemoryScore {
  const MemoryScore({
    required this.pairs,
    required this.attempts,
    required this.durationMs,
  });

  /// Nombre de paires trouvées.
  final int pairs;

  /// Nombre de tentatives (chaque retournement de 2 cartes = 1 tentative).
  final int attempts;

  final int durationMs;

  /// Précision : 1.0 = chaque tentative était une bonne paire.
  double get accuracy => attempts > 0 ? (pairs / attempts).clamp(0.0, 1.0) : 0;

  /// Points : 100 par paire trouvée, -5 par tentative infructueuse.
  int get points {
    if (pairs == 0) return 0;
    final base = pairs * 100;
    final failed = (attempts - pairs).clamp(0, 9999);
    return (base - failed * 5).clamp(0, base);
  }
}

// ---------------------------------------------------------------------------
// Constructeur de plateau
// ---------------------------------------------------------------------------

/// Construit et mélange les [MemoryCard] à partir des paires données.
/// Si [wordOnly] est vrai, les deux cartes de chaque paire affichent
/// le mot (paires identiques à reconnaître). Sinon, une carte affiche
/// le mot et l'autre sa définition.
List<MemoryCard> buildMemoryCards(
  List<MemoryPairData> pairs, {
  int? seed,
  bool wordOnly = true,
}) {
  final rng = seed != null ? Random(seed) : Random();
  final cards = <MemoryCard>[];

  for (final p in pairs) {
    final hasDefinition =
        !wordOnly && p.definition != null && p.definition!.trim().isNotEmpty;

    // Carte côté mot
    cards.add(
      MemoryCard(
        uid: '${p.wordId}_w',
        wordId: p.wordId,
        content: p.mot,
        isWordSide: true,
      ),
    );

    // Carte côté définition (ou doublon du mot si wordOnly ou pas de définition)
    cards.add(
      MemoryCard(
        uid: '${p.wordId}_d',
        wordId: p.wordId,
        content: hasDefinition ? p.definition! : p.mot,
        isWordSide: !hasDefinition,
      ),
    );
  }

  cards.shuffle(rng);
  return cards;
}
