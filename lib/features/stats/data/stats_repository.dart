// ============================================================
// Fichier : lib/features/stats/data/stats_repository.dart
// Description : Dépôt de statistiques — calculs de progression,
//               taux de réussite, mots difficiles, streaks, heatmap.
//               Requêtes Drift sur app.db. 100 % hors-ligne.
// ============================================================

import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/dao/stats_dao.dart';
import '../../../core/database/dao/words_dao.dart';

/// Activité quotidienne pour la heatmap.
class DailyActivity {
  const DailyActivity({
    required this.date,
    required this.wordsSeen,
    required this.wordsSuccess,
    required this.minutesPlayed,
  });

  final DateTime date;
  final int wordsSeen;
  final int wordsSuccess;
  final int minutesPlayed;

  /// Intensité normalisée (0.0 à 1.0) pour la heatmap.
  /// Basée sur le nombre de mots vus (max 30 = intensité maximale).
  double get intensity => (wordsSeen / 30).clamp(0.0, 1.0);
}

/// Taux de réussite par type d'activité.
class ActivityStats {
  const ActivityStats({
    required this.activityType,
    required this.totalAttempts,
    required this.successes,
  });

  final String activityType;
  final int totalAttempts;
  final int successes;

  /// Taux de réussite en pourcentage (0-100).
  double get successRate =>
      totalAttempts > 0 ? (successes / totalAttempts) * 100 : 0;
}

/// Mot avec ses statistiques de maîtrise.
class WordStats {
  const WordStats({
    required this.wordId,
    required this.mot,
    required this.nbSeen,
    required this.nbSuccess,
    required this.leitnerBox,
    required this.masteryLevel,
    this.nextReview,
    this.dictionaryName = '',
  });

  final int wordId;
  final String mot;
  final int nbSeen;
  final int nbSuccess;
  final int leitnerBox;
  final int masteryLevel;
  final DateTime? nextReview;

  /// Nom du dictionnaire source de ce mot.
  final String dictionaryName;

  /// Taux de réussite en pourcentage.
  double get successRate => nbSeen > 0 ? (nbSuccess / nbSeen) * 100 : 0;
}

/// Comparaison du taux de réussite entre la période courante et la précédente.
class PeriodComparison {
  const PeriodComparison({
    required this.currentRate,
    required this.previousRate,
  });

  final double currentRate;
  final double previousRate;

  /// Différence en points de pourcentage (positif = amélioration).
  double get delta => currentRate - previousRate;

  /// Vrai si amélioration de plus de 1 point de pourcentage.
  bool get isImproving => delta > 1.0;

  /// Vrai si régression de plus de 1 point de pourcentage.
  bool get isRegressing => delta < -1.0;
}

/// Résumé global de progression d'un profil.
class ProgressSummary {
  const ProgressSummary({
    required this.totalWordsSeen,
    required this.totalWordsSuccess,
    required this.globalSuccessRate,
    required this.wordsMastered,
    required this.wordsInProgress,
    required this.currentStreak,
    required this.activityStats,
    required this.difficultWords,
    required this.heatmap,
    this.periodComparison,
  });

  final int totalWordsSeen;
  final int totalWordsSuccess;
  final double globalSuccessRate;
  final int wordsMastered;
  final int wordsInProgress;
  final int currentStreak;
  final List<ActivityStats> activityStats;
  final List<WordStats> difficultWords;
  final List<DailyActivity> heatmap;

  /// Comparaison avec la période précédente (null si période = total ou données insuffisantes).
  final PeriodComparison? periodComparison;
}

/// Période de calcul des statistiques.
enum StatsPeriod {
  week,
  month,
  total,
}

/// Dépôt de statistiques — orchestre les requêtes et calculs.
class StatsRepository {
  StatsRepository({
    required this.statsDao,
    required this.wordsDao,
    required AppDatabase database,
  }) : _database = database;

  final StatsDao statsDao;
  final WordsDao wordsDao;
  final AppDatabase _database;

  // -------------------------------------------------------------------
  // Taux de réussite global
  // -------------------------------------------------------------------

  /// Calcule le taux de réussite global d'un profil sur une période.
  Future<double> getGlobalSuccessRate({
    required int profileId,
    required StatsPeriod period,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final since = _periodStart(period, currentTime);

    final result = await _database.customSelect(
      '''
      SELECT
        COUNT(*) as total,
        COALESCE(SUM(CASE WHEN wa.success = 1 THEN 1 ELSE 0 END), 0) as successes
      FROM word_attempts wa
      INNER JOIN sessions s ON s.id = wa.session_id
      WHERE s.profile_id = ?
        AND s.started_at >= ?
      ''',
      variables: [
        Variable.withInt(profileId),
        Variable.withDateTime(since),
      ],
      readsFrom: {statsDao.wordAttempts, statsDao.sessions},
    ).getSingle();

    final total = result.read<int>('total');
    final successes = result.read<int>('successes');
    return total > 0 ? (successes / total) * 100 : 0;
  }

  // -------------------------------------------------------------------
  // Taux par activité
  // -------------------------------------------------------------------

  /// Calcule le taux de réussite par type d'activité.
  Future<List<ActivityStats>> getActivityStats({
    required int profileId,
    required StatsPeriod period,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final since = _periodStart(period, currentTime);

    final rows = await _database.customSelect(
      '''
      SELECT
        s.activity_type,
        COUNT(*) as total,
        SUM(CASE WHEN wa.success = 1 THEN 1 ELSE 0 END) as successes
      FROM word_attempts wa
      INNER JOIN sessions s ON s.id = wa.session_id
      WHERE s.profile_id = ?
        AND s.started_at >= ?
      GROUP BY s.activity_type
      ORDER BY total DESC
      ''',
      variables: [
        Variable.withInt(profileId),
        Variable.withDateTime(since),
      ],
      readsFrom: {statsDao.wordAttempts, statsDao.sessions},
    ).get();

    return rows
        .map(
          (row) => ActivityStats(
            activityType: row.read<String>('activity_type'),
            totalAttempts: row.read<int>('total'),
            successes: row.read<int>('successes'),
          ),
        )
        .toList();
  }

  // -------------------------------------------------------------------
  // Mots difficiles (taux < 50%)
  // -------------------------------------------------------------------

  /// Retourne les mots en difficulté (taux de réussite < 50%, au moins 2 essais).
  Future<List<WordStats>> getDifficultWords({
    required int profileId,
    int minAttempts = 2,
  }) async {
    final rows = await _database.customSelect(
      '''
      SELECT
        w.id as word_id,
        w.mot,
        d.nom as dictionary_name,
        wm.nb_seen,
        wm.nb_success,
        wm.leitner_box,
        wm.mastery_level,
        wm.next_review
      FROM word_mastery wm
      INNER JOIN words w ON w.id = wm.word_id
      INNER JOIN dictionaries d ON d.id = w.dictionary_id
      WHERE wm.profile_id = ?
        AND wm.nb_seen >= ?
        AND CAST(wm.nb_success AS REAL) / wm.nb_seen < 0.5
      ORDER BY CAST(wm.nb_success AS REAL) / wm.nb_seen ASC
      LIMIT 20
      ''',
      variables: [
        Variable.withInt(profileId),
        Variable.withInt(minAttempts),
      ],
      readsFrom: {wordsDao.wordMastery, wordsDao.words, _database.dictionaries},
    ).get();

    return rows.map(_wordStatsFromRow).toList();
  }

  // -------------------------------------------------------------------
  // Mots maîtrisés / en cours
  // -------------------------------------------------------------------

  /// Nombre de mots maîtrisés (mastery_level = 3).
  Future<int> getMasteredCount(int profileId) async {
    final result = await _database.customSelect(
      '''
      SELECT COUNT(*) as cnt
      FROM word_mastery
      WHERE profile_id = ? AND mastery_level = 3
      ''',
      variables: [Variable.withInt(profileId)],
      readsFrom: {wordsDao.wordMastery},
    ).getSingle();
    return result.read<int>('cnt');
  }

  /// Nombre de mots en cours (mastery_level entre 1 et 2).
  Future<int> getInProgressCount(int profileId) async {
    final result = await _database.customSelect(
      '''
      SELECT COUNT(*) as cnt
      FROM word_mastery
      WHERE profile_id = ? AND mastery_level IN (1, 2)
      ''',
      variables: [Variable.withInt(profileId)],
      readsFrom: {wordsDao.wordMastery},
    ).getSingle();
    return result.read<int>('cnt');
  }

  // -------------------------------------------------------------------
  // Streak (jours consécutifs)
  // -------------------------------------------------------------------

  /// Calcule le streak actuel (jours consécutifs avec au moins une session).
  Future<int> getCurrentStreak({
    required int profileId,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final today =
        DateTime(currentTime.year, currentTime.month, currentTime.day);

    // Récupérer les dates uniques avec activité, triées DESC
    final rows = await _database.customSelect(
      '''
      SELECT DISTINCT date as day_ts
      FROM daily_stats
      WHERE profile_id = ? AND words_seen > 0
      ORDER BY date DESC
      ''',
      variables: [Variable.withInt(profileId)],
      readsFrom: {statsDao.dailyStats},
    ).get();

    if (rows.isEmpty) return 0;

    int streak = 0;
    var expectedDate = today;

    for (final row in rows) {
      final dayTs = row.read<int>('day_ts');
      final dayFull = DateTime.fromMillisecondsSinceEpoch(dayTs * 1000);
      final day = DateTime(dayFull.year, dayFull.month, dayFull.day);

      if (day.isAtSameMomentAs(expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else if (day.isBefore(expectedDate)) {
        // Si le premier jour n'est pas aujourd'hui, vérifier hier
        if (streak == 0 &&
            day.isAtSameMomentAs(
              expectedDate.subtract(const Duration(days: 1)),
            )) {
          streak++;
          expectedDate = day.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return streak;
  }

  // -------------------------------------------------------------------
  // Heatmap (12 mois)
  // -------------------------------------------------------------------

  /// Récupère l'activité quotidienne sur les 12 derniers mois.
  Future<List<DailyActivity>> getHeatmap({
    required int profileId,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final yearAgo = currentTime.subtract(const Duration(days: 365));

    final rows = await _database.customSelect(
      '''
      SELECT date, words_seen, words_success, minutes_played
      FROM daily_stats
      WHERE profile_id = ?
        AND date >= ?
      ORDER BY date ASC
      ''',
      variables: [
        Variable.withInt(profileId),
        Variable.withDateTime(yearAgo),
      ],
      readsFrom: {statsDao.dailyStats},
    ).get();

    return rows
        .map(
          (row) => DailyActivity(
            date: row.read<DateTime>('date'),
            wordsSeen: row.read<int>('words_seen'),
            wordsSuccess: row.read<int>('words_success'),
            minutesPlayed: row.read<int>('minutes_played'),
          ),
        )
        .toList();
  }

  // -------------------------------------------------------------------
  // Statistiques d'un mot individuel
  // -------------------------------------------------------------------

  /// Récupère les statistiques d'un mot pour un profil.
  Future<WordStats?> getWordStats({
    required int wordId,
    required int profileId,
  }) async {
    final rows = await _database.customSelect(
      '''
      SELECT
        w.id as word_id,
        w.mot,
        wm.nb_seen,
        wm.nb_success,
        wm.leitner_box,
        wm.mastery_level,
        wm.next_review
      FROM word_mastery wm
      INNER JOIN words w ON w.id = wm.word_id
      WHERE wm.word_id = ?
        AND wm.profile_id = ?
      ''',
      variables: [
        Variable.withInt(wordId),
        Variable.withInt(profileId),
      ],
      readsFrom: {wordsDao.wordMastery, wordsDao.words},
    ).get();

    if (rows.isEmpty) return null;
    return _wordStatsFromRow(rows.first);
  }

  /// Récupère l'historique des tentatives d'un mot.
  Future<List<WordAttempt>> getWordAttemptHistory({
    required int wordId,
    required int profileId,
  }) async {
    final rows = await _database.customSelect(
      '''
      SELECT wa.*
      FROM word_attempts wa
      INNER JOIN sessions s ON s.id = wa.session_id
      WHERE wa.word_id = ?
        AND s.profile_id = ?
      ORDER BY s.started_at DESC
      ''',
      variables: [
        Variable.withInt(wordId),
        Variable.withInt(profileId),
      ],
      readsFrom: {statsDao.wordAttempts, statsDao.sessions},
    ).get();

    return Future.wait(
      rows.map((row) => statsDao.wordAttempts.mapFromRow(row)),
    );
  }

  // -------------------------------------------------------------------
  // Résumé complet
  // -------------------------------------------------------------------

  /// Construit un résumé complet de la progression.
  Future<ProgressSummary> getProgressSummary({
    required int profileId,
    required StatsPeriod period,
    DateTime? now,
  }) async {
    final results = await Future.wait([
      getGlobalSuccessRate(profileId: profileId, period: period, now: now),
      getActivityStats(profileId: profileId, period: period, now: now),
      getDifficultWords(profileId: profileId),
      getMasteredCount(profileId),
      getInProgressCount(profileId),
      getCurrentStreak(profileId: profileId, now: now),
      getHeatmap(profileId: profileId, now: now),
      getPeriodComparison(profileId: profileId, period: period, now: now),
    ]);

    final globalRate = results[0] as double;
    final activities = results[1] as List<ActivityStats>;
    final difficult = results[2] as List<WordStats>;
    final mastered = results[3] as int;
    final inProgress = results[4] as int;
    final streak = results[5] as int;
    final heatmap = results[6] as List<DailyActivity>;
    final comparison = results[7] as PeriodComparison?;

    // Calculer totaux depuis la heatmap
    int totalSeen = 0;
    int totalSuccess = 0;
    for (final day in heatmap) {
      totalSeen += day.wordsSeen;
      totalSuccess += day.wordsSuccess;
    }

    return ProgressSummary(
      totalWordsSeen: totalSeen,
      totalWordsSuccess: totalSuccess,
      globalSuccessRate: globalRate,
      wordsMastered: mastered,
      wordsInProgress: inProgress,
      currentStreak: streak,
      activityStats: activities,
      difficultWords: difficult,
      heatmap: heatmap,
      periodComparison: comparison,
    );
  }

  // -------------------------------------------------------------------
  // Utilitaires privés
  // -------------------------------------------------------------------

  DateTime _periodStart(StatsPeriod period, DateTime now) {
    switch (period) {
      case StatsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case StatsPeriod.month:
        return DateTime(now.year, now.month - 1, now.day);
      case StatsPeriod.total:
        return DateTime(2000);
    }
  }

  DateTime _previousPeriodStart(StatsPeriod period, DateTime now) {
    switch (period) {
      case StatsPeriod.week:
        return now.subtract(const Duration(days: 14));
      case StatsPeriod.month:
        return DateTime(now.year, now.month - 2, now.day);
      case StatsPeriod.total:
        return DateTime(2000);
    }
  }

  /// Calcule la comparaison entre la période courante et la précédente.
  /// Retourne null si la période est [StatsPeriod.total] ou si les données
  /// sont insuffisantes pour l'une des deux périodes.
  Future<PeriodComparison?> getPeriodComparison({
    required int profileId,
    required StatsPeriod period,
    DateTime? now,
  }) async {
    if (period == StatsPeriod.total) return null;

    final currentTime = now ?? DateTime.now();
    final currentSince = _periodStart(period, currentTime);
    final previousSince = _previousPeriodStart(period, currentTime);

    final results = await Future.wait([
      _database.customSelect(
        '''
        SELECT
          COUNT(*) as total,
          COALESCE(SUM(CASE WHEN wa.success = 1 THEN 1 ELSE 0 END), 0) as successes
        FROM word_attempts wa
        INNER JOIN sessions s ON s.id = wa.session_id
        WHERE s.profile_id = ?
          AND s.started_at >= ?
        ''',
        variables: [
          Variable.withInt(profileId),
          Variable.withDateTime(currentSince),
        ],
        readsFrom: {statsDao.wordAttempts, statsDao.sessions},
      ).getSingle(),
      _database.customSelect(
        '''
        SELECT
          COUNT(*) as total,
          COALESCE(SUM(CASE WHEN wa.success = 1 THEN 1 ELSE 0 END), 0) as successes
        FROM word_attempts wa
        INNER JOIN sessions s ON s.id = wa.session_id
        WHERE s.profile_id = ?
          AND s.started_at >= ?
          AND s.started_at < ?
        ''',
        variables: [
          Variable.withInt(profileId),
          Variable.withDateTime(previousSince),
          Variable.withDateTime(currentSince),
        ],
        readsFrom: {statsDao.wordAttempts, statsDao.sessions},
      ).getSingle(),
    ]);

    final currentTotal = results[0].read<int>('total');
    final currentSuccesses = results[0].read<int>('successes');
    final previousTotal = results[1].read<int>('total');
    final previousSuccesses = results[1].read<int>('successes');

    if (currentTotal == 0 || previousTotal == 0) return null;

    return PeriodComparison(
      currentRate: (currentSuccesses / currentTotal) * 100,
      previousRate: (previousSuccesses / previousTotal) * 100,
    );
  }

  WordStats _wordStatsFromRow(QueryRow row) {
    return WordStats(
      wordId: row.read<int>('word_id'),
      mot: row.read<String>('mot'),
      nbSeen: row.read<int>('nb_seen'),
      nbSuccess: row.read<int>('nb_success'),
      leitnerBox: row.read<int>('leitner_box'),
      masteryLevel: row.read<int>('mastery_level'),
      nextReview: row.readNullable<DateTime>('next_review'),
      dictionaryName: row.readNullable<String>('dictionary_name') ?? '',
    );
  }
}
