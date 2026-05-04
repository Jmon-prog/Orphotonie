// ============================================================
// Fichier : lib/features/srs/leitner_service.dart
// Description : Logique centrale du système Leitner (SRS).
//               Met à jour word_mastery après chaque tentative.
//               Calcule boîte, next_review, mastery_level.
//               Transactions Drift pour atomicité.
//               100 % hors-ligne.
// ============================================================

import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../core/database/dao/words_dao.dart';
import '../../core/database/dao/stats_dao.dart';
import 'models/srs_state_model.dart';

/// Service centralisé de répétition espacée (Leitner, 5 boîtes).
///
/// Appelé après chaque tentative dans n'importe quel jeu.
/// Met à jour `word_mastery` et `daily_stats` dans une transaction Drift.
class LeitnerService {
  LeitnerService({
    required this.wordsDao,
    required this.statsDao,
  });

  final WordsDao wordsDao;
  final StatsDao statsDao;

  /// Enregistre le résultat d'une tentative sur un mot.
  ///
  /// Met à jour la progression Leitner dans une transaction atomique.
  Future<SrsWordState> recordResult({
    required int profileId,
    required int wordId,
    required bool success,
    required bool firstTry,
    required bool hintUsed,
    required String activityType,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();

    // Transaction atomique : pas de demi-mise à jour
    return await wordsDao.attachedDatabase.transaction(() async {
      // 1. Charger ou créer l'entrée word_mastery
      final existing = await wordsDao.getMastery(wordId, profileId);

      final oldNbSeen = existing?.nbSeen ?? 0;
      final oldNbSuccess = existing?.nbSuccess ?? 0;
      final oldNbFirstTry = existing?.nbFirstTry ?? 0;
      final oldConsecutiveOk = existing?.consecutiveOk ?? 0;
      final oldBox = existing?.leitnerBox ?? 1;

      // 2. Incrémenter compteurs
      final newNbSeen = oldNbSeen + 1;
      final newNbSuccess = success ? oldNbSuccess + 1 : oldNbSuccess;
      final newNbFirstTry =
          (success && firstTry) ? oldNbFirstTry + 1 : oldNbFirstTry;

      // 3. Calculer consecutiveOk
      final newConsecutiveOk = success ? oldConsecutiveOk + 1 : 0;

      // 4. Calculer nouvelle boîte Leitner
      final newBox = computeNewBox(
        currentBox: oldBox,
        success: success,
      );

      // 5. Calculer next_review
      final nextReview = computeNextReview(
        box: newBox,
        now: currentTime,
      );

      // 6. Calculer mastery_level
      final masteryLevel = computeMasteryLevel(
        leitnerBox: newBox,
        nbSeen: newNbSeen,
        nbSuccess: newNbSuccess,
        consecutiveOk: newConsecutiveOk,
      );

      // 7. Upsert word_mastery
      await wordsDao.upsertMastery(
        WordMasteryCompanion(
          id: existing != null ? Value(existing.id) : const Value.absent(),
          profileId: Value(profileId),
          wordId: Value(wordId),
          nbSeen: Value(newNbSeen),
          nbSuccess: Value(newNbSuccess),
          nbFirstTry: Value(newNbFirstTry),
          consecutiveOk: Value(newConsecutiveOk),
          leitnerBox: Value(newBox),
          lastSeen: Value(currentTime),
          nextReview: Value(nextReview),
          masteryLevel: Value(masteryLevel.value),
        ),
      );

      // 8. Mettre à jour daily_stats
      await statsDao.recordDailyProgress(
        profileId: profileId,
        wordsSeen: 1,
        wordsSuccess: success ? 1 : 0,
        minutesPlayed: 0,
      );

      return SrsWordState(
        wordId: wordId,
        profileId: profileId,
        nbSeen: newNbSeen,
        nbSuccess: newNbSuccess,
        nbFirstTry: newNbFirstTry,
        consecutiveOk: newConsecutiveOk,
        leitnerBox: newBox,
        nextReview: nextReview,
        lastSeen: currentTime,
        masteryLevel: masteryLevel,
      );
    });
  }

  // -----------------------------------------------------------------------
  // Fonctions pures (testables indépendamment)
  // -----------------------------------------------------------------------

  /// Calcule la nouvelle boîte Leitner après une tentative.
  ///
  /// Succès → avancer d'une boîte (max 5).
  /// Échec → retour en boîte 1.
  static int computeNewBox({
    required int currentBox,
    required bool success,
  }) {
    if (success) {
      return (currentBox + 1).clamp(1, 5);
    } else {
      return 1;
    }
  }

  /// Calcule la prochaine date de révision selon la boîte.
  static DateTime computeNextReview({
    required int box,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final days = kLeitnerDelays[box] ?? 1;
    return currentTime.add(Duration(days: days));
  }

  /// Calcule le niveau de maîtrise (0–3).
  ///
  /// 0 = Nouveau (boîte 1, jamais vu)
  /// 1 = En cours (boîte 1–2, taux < 70 %)
  /// 2 = Bien (boîte 3–4)
  /// 3 = Maîtrisé (boîte 5, ≥ 3 réussites consécutives)
  static MasteryLevel computeMasteryLevel({
    required int leitnerBox,
    required int nbSeen,
    required int nbSuccess,
    required int consecutiveOk,
  }) {
    // Jamais vu
    if (nbSeen == 0) return MasteryLevel.nouveau;

    // Boîte 5 + 3 réussites consécutives
    if (leitnerBox == 5 && consecutiveOk >= 3) {
      return MasteryLevel.maitrise;
    }

    // Boîte 3–4
    if (leitnerBox >= 3 && leitnerBox <= 4) {
      return MasteryLevel.bien;
    }

    // Boîte 1–2 avec taux < 70 %
    final rate = nbSeen > 0 ? nbSuccess / nbSeen : 0.0;
    if (leitnerBox <= 2 && rate < 0.7) {
      return MasteryLevel.enCours;
    }

    // Boîte 1–2 mais bon taux — en cours quand même
    if (leitnerBox <= 2) {
      return MasteryLevel.enCours;
    }

    // Boîte 5 mais < 3 consécutives
    if (leitnerBox == 5) {
      return MasteryLevel.bien;
    }

    return MasteryLevel.enCours;
  }
}
