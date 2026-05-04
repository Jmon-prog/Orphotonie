// ============================================================
// Fichier : lib/features/games/definition_qcm/definition_qcm_logic.dart
// Description : Logique du jeu QCM Définition.
//               Un mot est affiché, 4 définitions proposées.
//               L'enfant choisit la bonne définition.
//               Les distracteurs sont tirés du même dictionnaire.
//               100 % hors-ligne, aucune dépendance réseau.
// ============================================================

import 'dart:math';
import '../../../core/database/app_database.dart';

/// Une question QCM : un mot + 4 réponses dont une seule est correcte.
class QcmQuestion {
  QcmQuestion({
    required this.word,
    required this.choices,
    required this.correctIndex,
  });

  /// Mot dont on cherche la définition.
  final Word word;

  /// 4 définitions proposées (mélangées).
  final List<String> choices;

  /// Index de la bonne réponse dans [choices].
  final int correctIndex;
}

/// Construit les questions QCM à partir d'une liste de mots du dictionnaire.
///
/// Chaque mot-cible doit avoir une [definition] non nulle.
/// Les 3 distracteurs sont choisis aléatoirement parmi les autres mots
/// qui ont aussi une définition.
class DefinitionQcmLogic {
  DefinitionQcmLogic({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Construit la liste de questions.
  ///
  /// [allWords] : tous les mots du dictionnaire (pour les distracteurs).
  /// [sessionWords] : mots sélectionnés par le SRS pour cette session.
  List<QcmQuestion> buildQuestions({
    required List<Word> allWords,
    required List<Word> sessionWords,
  }) {
    // Mots qui ont une définition non vide
    final withDef = allWords.where((w) => _hasDef(w)).toList();

    final questions = <QcmQuestion>[];

    for (final target in sessionWords) {
      if (!_hasDef(target)) continue;

      // Distracteurs = mots avec définition ≠ target
      final distractors = withDef.where((w) => w.id != target.id).toList()
        ..shuffle(_random);
      final picked = distractors.take(3).toList();

      if (picked.length < 3) continue; // pas assez de mots pour un QCM

      // Mélange les 4 choix
      final allChoices = [
        target.definition!,
        ...picked.map((w) => w.definition!),
      ]..shuffle(_random);

      final correctIndex = allChoices.indexOf(target.definition!);

      questions.add(
        QcmQuestion(
          word: target,
          choices: allChoices,
          correctIndex: correctIndex,
        ),
      );
    }

    return questions;
  }

  bool _hasDef(Word w) =>
      w.definition != null && w.definition!.trim().isNotEmpty;
}
