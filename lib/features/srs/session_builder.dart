// ============================================================
// Fichier : lib/features/srs/session_builder.dart
// Description : Construction de la liste de mots pour une session.
//               Priorité SRS : révision → nouveaux → complément.
//               100 % hors-ligne.
// ============================================================

import '../../core/database/app_database.dart';
import '../../core/database/dao/words_dao.dart';

/// Mot sélectionné pour une session, avec ses métadonnées SRS.
class SessionWord {
  const SessionWord({
    required this.word,
    this.mastery,
    required this.priority,
  });

  /// Le mot.
  final Word word;

  /// Maîtrise actuelle (null si jamais vu).
  final WordMasteryData? mastery;

  /// Priorité de sélection.
  final SessionWordPriority priority;

  /// Vrai si le mot n'a jamais été vu.
  bool get isNew => mastery == null || mastery!.nbSeen == 0;

  /// Vrai si le mot doit être découvert avant de jouer.
  bool get needsDiscovery => isNew;
}

/// Priorité de sélection d'un mot dans une session.
enum SessionWordPriority {
  /// Révision en retard (next_review <= maintenant).
  dueForReview,

  /// Nouveau mot (boîte 1, jamais vu).
  newWord,

  /// Complément pour atteindre le quota.
  filler,
}

/// Construit la liste de mots pour une session de jeu.
///
/// Applique l'algorithme de sélection SRS :
/// 1. Mots dont next_review <= maintenant (à réviser)
/// 2. Mots boîte 1 jamais vus (nouveaux)
/// 3. Autres mots pour compléter le quota
class SessionBuilder {
  SessionBuilder({required this.wordsDao});

  final WordsDao wordsDao;

  /// Quota par défaut de mots par session.
  static const int defaultWordCount = 15;

  /// Limites configurables par le praticien.
  static const int minWordCount = 10;
  static const int maxWordCount = 30;

  /// Construit une session de [wordCount] mots.
  ///
  /// Retourne les mots triés par priorité SRS.
  Future<List<SessionWord>> buildSession({
    required int dictionaryId,
    required int profileId,
    int wordCount = defaultWordCount,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final clampedCount = wordCount.clamp(minWordCount, maxWordCount);

    // Récupérer tous les mots du dictionnaire
    final allWords = await _getAllWords(dictionaryId);

    if (allWords.isEmpty) return [];

    // Récupérer les maîtrises existantes
    final masteries = <int, WordMasteryData>{};
    for (final word in allWords) {
      final m = await wordsDao.getMastery(word.id, profileId);
      if (m != null) masteries[word.id] = m;
    }

    // Catégoriser
    final dueForReview = <SessionWord>[];
    final newWords = <SessionWord>[];
    final fillers = <SessionWord>[];

    for (final word in allWords) {
      final mastery = masteries[word.id];

      if (mastery != null &&
          mastery.nextReview != null &&
          !mastery.nextReview!.isAfter(currentTime)) {
        // Priorité 1 : à réviser (next_review <= maintenant)
        dueForReview.add(
          SessionWord(
            word: word,
            mastery: mastery,
            priority: SessionWordPriority.dueForReview,
          ),
        );
      } else if (mastery == null || mastery.nbSeen == 0) {
        // Priorité 2 : nouveau mot
        newWords.add(
          SessionWord(
            word: word,
            mastery: mastery,
            priority: SessionWordPriority.newWord,
          ),
        );
      } else {
        // Priorité 3 : complément
        fillers.add(
          SessionWord(
            word: word,
            mastery: mastery,
            priority: SessionWordPriority.filler,
          ),
        );
      }
    }

    // Trier les révisions par retard (les plus en retard d'abord)
    dueForReview.sort((a, b) {
      final aReview = a.mastery?.nextReview ?? currentTime;
      final bReview = b.mastery?.nextReview ?? currentTime;
      return aReview.compareTo(bReview);
    });

    // Trier les fillers par boîte croissante (les moins avancés d'abord)
    fillers.sort((a, b) {
      final aBox = a.mastery?.leitnerBox ?? 1;
      final bBox = b.mastery?.leitnerBox ?? 1;
      return aBox.compareTo(bBox);
    });

    // Assembler selon le quota
    final result = <SessionWord>[];

    // 1. Ajouter les mots à réviser
    for (final sw in dueForReview) {
      if (result.length >= clampedCount) break;
      result.add(sw);
    }

    // 2. Ajouter les nouveaux mots
    for (final sw in newWords) {
      if (result.length >= clampedCount) break;
      result.add(sw);
    }

    // 3. Compléter avec les fillers
    for (final sw in fillers) {
      if (result.length >= clampedCount) break;
      result.add(sw);
    }

    return result;
  }

  /// Récupère tous les mots d'un dictionnaire.
  Future<List<Word>> _getAllWords(int dictionaryId) async {
    return (wordsDao.select(wordsDao.words)
          ..where((w) => w.dictionaryId.equals(dictionaryId)))
        .get();
  }
}
