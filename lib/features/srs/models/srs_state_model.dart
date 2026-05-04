// ============================================================
// Fichier : lib/features/srs/models/srs_state_model.dart
// Description : Modèle d'état SRS (Leitner) pour un mot.
//               Boîte, prochaine révision, niveau de maîtrise.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/foundation.dart';

/// Délais de révision par boîte Leitner (en jours).
const Map<int, int> kLeitnerDelays = {
  1: 1,
  2: 2,
  3: 4,
  4: 8,
  5: 16,
};

/// Niveau de maîtrise d'un mot.
enum MasteryLevel {
  /// Mot jamais vu.
  nouveau(0, 'Nouveau'),

  /// Vu mais taux de réussite < 70 %.
  enCours(1, 'En cours'),

  /// Boîte 3–4, progression régulière.
  bien(2, 'Bien'),

  /// Boîte 5, au moins 3 réussites consécutives.
  maitrise(3, 'Maîtrisé');

  const MasteryLevel(this.value, this.label);
  final int value;
  final String label;

  /// Construit depuis un entier (0–3).
  static MasteryLevel fromValue(int v) {
    return MasteryLevel.values.firstWhere(
      (m) => m.value == v,
      orElse: () => MasteryLevel.nouveau,
    );
  }
}

/// État SRS d'un mot pour un profil donné.
@immutable
class SrsWordState {
  const SrsWordState({
    required this.wordId,
    required this.profileId,
    this.nbSeen = 0,
    this.nbSuccess = 0,
    this.nbFirstTry = 0,
    this.consecutiveOk = 0,
    this.leitnerBox = 1,
    this.nextReview,
    this.lastSeen,
    this.masteryLevel = MasteryLevel.nouveau,
  });

  final int wordId;
  final int profileId;
  final int nbSeen;
  final int nbSuccess;
  final int nbFirstTry;
  final int consecutiveOk;
  final int leitnerBox;
  final DateTime? nextReview;
  final DateTime? lastSeen;
  final MasteryLevel masteryLevel;

  /// Vrai si le mot n'a jamais été présenté.
  bool get isNew => nbSeen == 0;

  /// Vrai si le mot est dû pour révision.
  bool get isDueForReview {
    if (nextReview == null) return true;
    return DateTime.now().isAfter(nextReview!) ||
        DateTime.now().isAtSameMomentAs(nextReview!);
  }

  /// Taux de réussite (0.0–1.0).
  double get successRate => nbSeen > 0 ? nbSuccess / nbSeen : 0.0;

  SrsWordState copyWith({
    int? wordId,
    int? profileId,
    int? nbSeen,
    int? nbSuccess,
    int? nbFirstTry,
    int? consecutiveOk,
    int? leitnerBox,
    DateTime? Function()? nextReview,
    DateTime? Function()? lastSeen,
    MasteryLevel? masteryLevel,
  }) {
    return SrsWordState(
      wordId: wordId ?? this.wordId,
      profileId: profileId ?? this.profileId,
      nbSeen: nbSeen ?? this.nbSeen,
      nbSuccess: nbSuccess ?? this.nbSuccess,
      nbFirstTry: nbFirstTry ?? this.nbFirstTry,
      consecutiveOk: consecutiveOk ?? this.consecutiveOk,
      leitnerBox: leitnerBox ?? this.leitnerBox,
      nextReview: nextReview != null ? nextReview() : this.nextReview,
      lastSeen: lastSeen != null ? lastSeen() : this.lastSeen,
      masteryLevel: masteryLevel ?? this.masteryLevel,
    );
  }
}
