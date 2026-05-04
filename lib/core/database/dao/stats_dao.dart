// ============================================================
// Fichier : lib/core/database/dao/stats_dao.dart
// Description : DAO Drift pour les statistiques et le journal quotidien.
//               Alimente la heatmap de progression et les bilans de session.
// ============================================================

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sessions_table.dart';
import '../tables/word_attempts_table.dart';
import '../tables/daily_stats_table.dart';

part 'stats_dao.g.dart';

@DriftAccessor(tables: [Sessions, WordAttempts, DailyStats])
class StatsDao extends DatabaseAccessor<AppDatabase> with _$StatsDaoMixin {
  StatsDao(super.db);

  // --- Sessions ---

  /// Crée une nouvelle session et retourne son identifiant.
  Future<int> startSession(SessionsCompanion entry) =>
      into(sessions).insert(entry);

  /// Ferme une session en enregistrant son heure de fin et son score.
  Future<void> endSession(int sessionId, DateTime endedAt, int score) async {
    await (update(sessions)..where((s) => s.id.equals(sessionId))).write(
      SessionsCompanion(
        endedAt: Value(endedAt),
        score: Value(score),
      ),
    );
  }

  /// Flux réactif des sessions d'un profil, du plus récent au plus ancien.
  Stream<List<Session>> watchSessionsForProfile(int profileId) =>
      (select(sessions)
            ..where((s) => s.profileId.equals(profileId))
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
          .watch();

  // --- Tentatives ---

  /// Enregistre une tentative dans une session.
  Future<int> insertAttempt(WordAttemptsCompanion entry) =>
      into(wordAttempts).insert(entry);

  /// Récupère toutes les tentatives d'une session.
  Future<List<WordAttempt>> getAttemptsForSession(int sessionId) =>
      (select(wordAttempts)..where((a) => a.sessionId.equals(sessionId))).get();

  // --- Statistiques quotidiennes ---

  /// Flux réactif des stats des 30 derniers jours (heatmap).
  Stream<List<DailyStat>> watchRecentStats(int profileId) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return (select(dailyStats)
          ..where(
            (d) =>
                d.profileId.equals(profileId) &
                d.date.isBiggerOrEqualValue(thirtyDaysAgo),
          )
          ..orderBy([(d) => OrderingTerm.asc(d.date)]))
        .watch();
  }

  /// Incrémente les statistiques du jour pour un profil (upsert).
  Future<void> recordDailyProgress({
    required int profileId,
    required int wordsSeen,
    required int wordsSuccess,
    required int minutesPlayed,
  }) async {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final existing = await (select(dailyStats)
          ..where(
            (d) => d.profileId.equals(profileId) & d.date.equals(today),
          ))
        .getSingleOrNull();

    if (existing == null) {
      await into(dailyStats).insert(
        DailyStatsCompanion.insert(
          profileId: profileId,
          date: today,
          wordsSeen: Value(wordsSeen),
          wordsSuccess: Value(wordsSuccess),
          minutesPlayed: Value(minutesPlayed),
        ),
      );
    } else {
      await (update(dailyStats)
            ..where(
              (d) => d.profileId.equals(profileId) & d.date.equals(today),
            ))
          .write(
        DailyStatsCompanion(
          wordsSeen: Value(existing.wordsSeen + wordsSeen),
          wordsSuccess: Value(existing.wordsSuccess + wordsSuccess),
          minutesPlayed: Value(existing.minutesPlayed + minutesPlayed),
        ),
      );
    }
  }
}
