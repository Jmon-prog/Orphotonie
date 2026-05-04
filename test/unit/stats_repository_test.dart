// ============================================================
// Fichier : test/unit/stats_repository_test.dart
// Description : Tests unitaires pour StatsRepository.
//               Taux de réussite, activité, mots difficiles,
//               streak, heatmap — base en mémoire.
// ============================================================

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/core/database/app_database.dart';
import 'package:orphotonie/features/stats/data/stats_repository.dart';

void main() {
  group('StatsRepository', () {
    late AppDatabase db;
    late StatsRepository repo;
    late int profileId;
    late int dictionaryId;
    late int wordId1;
    late int wordId2;
    late int wordId3;

    setUp(() async {
      db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      repo = StatsRepository(
        statsDao: db.statsDao,
        wordsDao: db.wordsDao,
        database: db,
      );

      profileId = await db.into(db.profiles).insert(
            ProfilesCompanion.insert(prenom: 'Thomas'),
          );

      dictionaryId = await db.into(db.dictionaries).insert(
            DictionariesCompanion.insert(
              nom: 'Test Dict',
              profileId: profileId,
            ),
          );

      wordId1 = await db.into(db.words).insert(
            WordsCompanion.insert(dictionaryId: dictionaryId, mot: 'CHAT'),
          );
      wordId2 = await db.into(db.words).insert(
            WordsCompanion.insert(dictionaryId: dictionaryId, mot: 'CHIEN'),
          );
      wordId3 = await db.into(db.words).insert(
            WordsCompanion.insert(
              dictionaryId: dictionaryId,
              mot: 'CHRYSANTHÈME',
            ),
          );
    });

    tearDown(() => db.close());

    /// Crée une session et insère des tentatives.
    Future<void> insertAttempts({
      required String activityType,
      required List<({int wordId, bool success})> attempts,
      DateTime? startedAt,
    }) async {
      final sessionId = await db.statsDao.startSession(
        SessionsCompanion.insert(
          profileId: profileId,
          dictionaryId: dictionaryId,
          activityType: activityType,
          startedAt: Value(startedAt ?? DateTime.now()),
        ),
      );

      for (final a in attempts) {
        await db.statsDao.insertAttempt(
          WordAttemptsCompanion.insert(
            sessionId: sessionId,
            wordId: a.wordId,
            success: Value(a.success),
          ),
        );
      }
    }

    // -----------------------------------------------------------------
    // Taux de réussite global
    // -----------------------------------------------------------------
    group('getGlobalSuccessRate', () {
      test('0% quand aucune tentative', () async {
        final rate = await repo.getGlobalSuccessRate(
          profileId: profileId,
          period: StatsPeriod.total,
        );
        expect(rate, 0);
      });

      test('calcul correct avec tentatives mixtes', () async {
        await insertAttempts(
          activityType: 'anagramme',
          attempts: [
            (wordId: wordId1, success: true),
            (wordId: wordId1, success: true),
            (wordId: wordId1, success: false),
            (wordId: wordId2, success: true),
            (wordId: wordId2, success: false),
          ],
        );

        final rate = await repo.getGlobalSuccessRate(
          profileId: profileId,
          period: StatsPeriod.total,
        );
        // 3 succès / 5 tentatives = 60%
        expect(rate, closeTo(60, 0.1));
      });

      test('filtrage par période (semaine)', () async {
        final now = DateTime(2026, 4, 19, 10, 0);

        // Tentatives dans la semaine
        await insertAttempts(
          activityType: 'anagramme',
          attempts: [
            (wordId: wordId1, success: true),
            (wordId: wordId1, success: true),
          ],
          startedAt: now.subtract(const Duration(days: 2)),
        );

        // Tentatives hors semaine (10 jours avant)
        await insertAttempts(
          activityType: 'anagramme',
          attempts: [
            (wordId: wordId1, success: false),
            (wordId: wordId1, success: false),
            (wordId: wordId1, success: false),
          ],
          startedAt: now.subtract(const Duration(days: 10)),
        );

        final rate = await repo.getGlobalSuccessRate(
          profileId: profileId,
          period: StatsPeriod.week,
          now: now,
        );
        // Seules les 2 tentatives récentes comptent → 100%
        expect(rate, closeTo(100, 0.1));
      });
    });

    // -----------------------------------------------------------------
    // Taux par activité
    // -----------------------------------------------------------------
    group('getActivityStats', () {
      test('différencie les activités', () async {
        await insertAttempts(
          activityType: 'anagramme',
          attempts: [
            (wordId: wordId1, success: true),
            (wordId: wordId1, success: true),
            (wordId: wordId1, success: false),
          ],
        );

        await insertAttempts(
          activityType: 'pendu',
          attempts: [
            (wordId: wordId1, success: false),
            (wordId: wordId1, success: false),
          ],
        );

        final stats = await repo.getActivityStats(
          profileId: profileId,
          period: StatsPeriod.total,
        );

        expect(stats.length, 2);

        final anagramme = stats.firstWhere(
          (s) => s.activityType == 'anagramme',
        );
        expect(anagramme.totalAttempts, 3);
        expect(anagramme.successes, 2);
        expect(anagramme.successRate, closeTo(66.67, 0.1));

        final pendu = stats.firstWhere(
          (s) => s.activityType == 'pendu',
        );
        expect(pendu.totalAttempts, 2);
        expect(pendu.successes, 0);
        expect(pendu.successRate, 0);
      });
    });

    // -----------------------------------------------------------------
    // Mots difficiles
    // -----------------------------------------------------------------
    group('getDifficultWords', () {
      test('retourne les mots avec taux < 50%', () async {
        // Mot 1 : 4/5 = 80% (pas difficile)
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(wordId1),
            nbSeen: const Value(5),
            nbSuccess: const Value(4),
            leitnerBox: const Value(3),
            masteryLevel: const Value(2),
          ),
        );

        // Mot 2 : 1/4 = 25% (difficile)
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(wordId2),
            nbSeen: const Value(4),
            nbSuccess: const Value(1),
            leitnerBox: const Value(1),
            masteryLevel: const Value(1),
          ),
        );

        // Mot 3 : 2/8 = 25% (difficile)
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(wordId3),
            nbSeen: const Value(8),
            nbSuccess: const Value(2),
            leitnerBox: const Value(1),
            masteryLevel: const Value(1),
          ),
        );

        final difficult = await repo.getDifficultWords(
          profileId: profileId,
        );

        expect(difficult.length, 2);
        // Triés par taux croissant
        expect(difficult[0].mot, 'CHIEN'); // 25%
        expect(difficult[1].mot, 'CHRYSANTHÈME'); // 25%
      });

      test('ignore les mots avec < 2 tentatives', () async {
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(wordId1),
            nbSeen: const Value(1),
            nbSuccess: const Value(0),
            leitnerBox: const Value(1),
            masteryLevel: const Value(0),
          ),
        );

        final difficult = await repo.getDifficultWords(
          profileId: profileId,
        );
        expect(difficult, isEmpty);
      });
    });

    // -----------------------------------------------------------------
    // Mots maîtrisés / en cours
    // -----------------------------------------------------------------
    group('getMasteredCount / getInProgressCount', () {
      test('compte correctement', () async {
        // Mot 1 : maîtrisé (level 3)
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(wordId1),
            nbSeen: const Value(10),
            nbSuccess: const Value(9),
            leitnerBox: const Value(5),
            masteryLevel: const Value(3),
          ),
        );

        // Mot 2 : en cours (level 1)
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(wordId2),
            nbSeen: const Value(3),
            nbSuccess: const Value(1),
            leitnerBox: const Value(1),
            masteryLevel: const Value(1),
          ),
        );

        // Mot 3 : bien (level 2)
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(wordId3),
            nbSeen: const Value(5),
            nbSuccess: const Value(4),
            leitnerBox: const Value(3),
            masteryLevel: const Value(2),
          ),
        );

        final mastered = await repo.getMasteredCount(profileId);
        expect(mastered, 1);

        final inProgress = await repo.getInProgressCount(profileId);
        expect(inProgress, 2); // level 1 et 2
      });
    });

    // -----------------------------------------------------------------
    // Streak
    // -----------------------------------------------------------------
    group('getCurrentStreak', () {
      test('0 quand aucune activité', () async {
        final streak = await repo.getCurrentStreak(profileId: profileId);
        expect(streak, 0);
      });

      test('compte les jours consécutifs', () async {
        final now = DateTime(2026, 4, 19, 10, 0);

        // 3 jours consécutifs : 17, 18, 19 avril
        for (int i = 2; i >= 0; i--) {
          final day = DateTime(2026, 4, 19 - i);
          await db.into(db.dailyStats).insert(
                DailyStatsCompanion.insert(
                  profileId: profileId,
                  date: day,
                  wordsSeen: const Value(5),
                ),
              );
        }

        final streak = await repo.getCurrentStreak(
          profileId: profileId,
          now: now,
        );
        expect(streak, 3);
      });

      test('s\'arrête au premier jour manquant', () async {
        final now = DateTime(2026, 4, 19, 10, 0);

        // Jours 19, 18, 16 (manque le 17)
        for (final dayNum in [19, 18, 16]) {
          await db.into(db.dailyStats).insert(
                DailyStatsCompanion.insert(
                  profileId: profileId,
                  date: DateTime(2026, 4, dayNum),
                  wordsSeen: const Value(5),
                ),
              );
        }

        final streak = await repo.getCurrentStreak(
          profileId: profileId,
          now: now,
        );
        expect(streak, 2); // 19 et 18 seulement
      });

      test('streak commence hier si pas joué aujourd\'hui', () async {
        final now = DateTime(2026, 4, 19, 10, 0);

        // Jours 18, 17, 16 (pas aujourd'hui 19)
        for (final dayNum in [18, 17, 16]) {
          await db.into(db.dailyStats).insert(
                DailyStatsCompanion.insert(
                  profileId: profileId,
                  date: DateTime(2026, 4, dayNum),
                  wordsSeen: const Value(5),
                ),
              );
        }

        final streak = await repo.getCurrentStreak(
          profileId: profileId,
          now: now,
        );
        expect(streak, 3); // 18, 17, 16
      });
    });

    // -----------------------------------------------------------------
    // Heatmap
    // -----------------------------------------------------------------
    group('getHeatmap', () {
      test('retourne les 12 derniers mois', () async {
        final now = DateTime(2026, 4, 19, 10, 0);

        // Insérer 3 jours d'activité
        for (int i = 0; i < 3; i++) {
          await db.into(db.dailyStats).insert(
                DailyStatsCompanion.insert(
                  profileId: profileId,
                  date: now.subtract(Duration(days: i * 30)),
                  wordsSeen: Value(10 + i),
                  wordsSuccess: Value(8 + i),
                  minutesPlayed: Value(5 + i),
                ),
              );
        }

        final heatmap = await repo.getHeatmap(
          profileId: profileId,
          now: now,
        );

        expect(heatmap.length, 3);
        // Trié ASC par date
        expect(heatmap.first.date.isBefore(heatmap.last.date), isTrue);
      });
    });

    // -----------------------------------------------------------------
    // Statistiques d'un mot
    // -----------------------------------------------------------------
    group('getWordStats', () {
      test('retourne null si mot jamais vu', () async {
        final stats = await repo.getWordStats(
          wordId: wordId1,
          profileId: profileId,
        );
        expect(stats, isNull);
      });

      test('retourne les stats correctes', () async {
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(wordId1),
            nbSeen: const Value(10),
            nbSuccess: const Value(7),
            leitnerBox: const Value(3),
            masteryLevel: const Value(2),
          ),
        );

        final stats = await repo.getWordStats(
          wordId: wordId1,
          profileId: profileId,
        );

        expect(stats, isNotNull);
        expect(stats!.mot, 'CHAT');
        expect(stats.nbSeen, 10);
        expect(stats.nbSuccess, 7);
        expect(stats.successRate, 70);
        expect(stats.leitnerBox, 3);
      });
    });

    // -----------------------------------------------------------------
    // Résumé complet
    // -----------------------------------------------------------------
    group('getProgressSummary', () {
      test('construit un résumé complet', () async {
        // Créer quelques données
        await insertAttempts(
          activityType: 'anagramme',
          attempts: [
            (wordId: wordId1, success: true),
            (wordId: wordId2, success: false),
          ],
        );

        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(wordId1),
            nbSeen: const Value(5),
            nbSuccess: const Value(4),
            leitnerBox: const Value(3),
            masteryLevel: const Value(2),
          ),
        );

        final summary = await repo.getProgressSummary(
          profileId: profileId,
          period: StatsPeriod.total,
        );

        expect(summary.globalSuccessRate, closeTo(50, 0.1));
        expect(summary.activityStats.length, 1);
        expect(summary.activityStats.first.activityType, 'anagramme');
        expect(summary.wordsInProgress, 1);
      });
    });

    // -----------------------------------------------------------------
    // DailyActivity
    // -----------------------------------------------------------------
    group('DailyActivity', () {
      test('intensité normalisée correctement', () {
        final epoch = DateTime(2026, 1, 1);

        final day0 = DailyActivity(
          date: epoch,
          wordsSeen: 0,
          wordsSuccess: 0,
          minutesPlayed: 0,
        );
        expect(day0.intensity, 0.0);

        final day15 = DailyActivity(
          date: epoch,
          wordsSeen: 15,
          wordsSuccess: 10,
          minutesPlayed: 5,
        );
        expect(day15.intensity, 0.5);

        final day50 = DailyActivity(
          date: epoch,
          wordsSeen: 50,
          wordsSuccess: 30,
          minutesPlayed: 20,
        );
        expect(day50.intensity, 1.0); // Clampé à 1.0
      });
    });
  });
}
