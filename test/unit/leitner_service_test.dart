// ============================================================
// Fichier : test/unit/leitner_service_test.dart
// Description : Tests unitaires pour le service Leitner (SRS).
//               Tests des fonctions pures + tests d'intégration
//               avec base en mémoire.
// ============================================================

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/core/database/app_database.dart';
import 'package:orphotonie/features/srs/leitner_service.dart';
import 'package:orphotonie/features/srs/models/srs_state_model.dart';

void main() {
  group('LeitnerService — fonctions pures', () {
    // -----------------------------------------------------------------
    // computeNewBox
    // -----------------------------------------------------------------
    group('computeNewBox', () {
      test('succès boîte 1 → boîte 2', () {
        expect(
          LeitnerService.computeNewBox(currentBox: 1, success: true),
          2,
        );
      });

      test('succès boîte 2 → boîte 3', () {
        expect(
          LeitnerService.computeNewBox(currentBox: 2, success: true),
          3,
        );
      });

      test('succès boîte 4 → boîte 5', () {
        expect(
          LeitnerService.computeNewBox(currentBox: 4, success: true),
          5,
        );
      });

      test('succès boîte 5 → reste boîte 5 (max)', () {
        expect(
          LeitnerService.computeNewBox(currentBox: 5, success: true),
          5,
        );
      });

      test('échec boîte 1 → boîte 1', () {
        expect(
          LeitnerService.computeNewBox(currentBox: 1, success: false),
          1,
        );
      });

      test('échec boîte 3 → boîte 1', () {
        expect(
          LeitnerService.computeNewBox(currentBox: 3, success: false),
          1,
        );
      });

      test('échec boîte 5 → boîte 1', () {
        expect(
          LeitnerService.computeNewBox(currentBox: 5, success: false),
          1,
        );
      });

      test('échec boîte 4 → retour boîte 1', () {
        expect(
          LeitnerService.computeNewBox(currentBox: 4, success: false),
          1,
        );
      });
    });

    // -----------------------------------------------------------------
    // computeNextReview
    // -----------------------------------------------------------------
    group('computeNextReview', () {
      final now = DateTime(2026, 4, 19, 10, 0);

      test('boîte 1 → +1 jour', () {
        final result = LeitnerService.computeNextReview(box: 1, now: now);
        expect(result, DateTime(2026, 4, 20, 10, 0));
      });

      test('boîte 2 → +2 jours', () {
        final result = LeitnerService.computeNextReview(box: 2, now: now);
        expect(result, DateTime(2026, 4, 21, 10, 0));
      });

      test('boîte 3 → +4 jours', () {
        final result = LeitnerService.computeNextReview(box: 3, now: now);
        expect(result, DateTime(2026, 4, 23, 10, 0));
      });

      test('boîte 4 → +8 jours', () {
        final result = LeitnerService.computeNextReview(box: 4, now: now);
        expect(result, DateTime(2026, 4, 27, 10, 0));
      });

      test('boîte 5 → +16 jours', () {
        final result = LeitnerService.computeNextReview(box: 5, now: now);
        expect(result, DateTime(2026, 5, 5, 10, 0));
      });
    });

    // -----------------------------------------------------------------
    // computeMasteryLevel
    // -----------------------------------------------------------------
    group('computeMasteryLevel', () {
      test('nbSeen = 0 → nouveau', () {
        expect(
          LeitnerService.computeMasteryLevel(
            leitnerBox: 1,
            nbSeen: 0,
            nbSuccess: 0,
            consecutiveOk: 0,
          ),
          MasteryLevel.nouveau,
        );
      });

      test('boîte 1, taux < 70% → en cours', () {
        expect(
          LeitnerService.computeMasteryLevel(
            leitnerBox: 1,
            nbSeen: 10,
            nbSuccess: 5,
            consecutiveOk: 0,
          ),
          MasteryLevel.enCours,
        );
      });

      test('boîte 2, taux >= 70% → en cours', () {
        expect(
          LeitnerService.computeMasteryLevel(
            leitnerBox: 2,
            nbSeen: 10,
            nbSuccess: 8,
            consecutiveOk: 2,
          ),
          MasteryLevel.enCours,
        );
      });

      test('boîte 3 → bien', () {
        expect(
          LeitnerService.computeMasteryLevel(
            leitnerBox: 3,
            nbSeen: 5,
            nbSuccess: 4,
            consecutiveOk: 2,
          ),
          MasteryLevel.bien,
        );
      });

      test('boîte 4 → bien', () {
        expect(
          LeitnerService.computeMasteryLevel(
            leitnerBox: 4,
            nbSeen: 8,
            nbSuccess: 7,
            consecutiveOk: 3,
          ),
          MasteryLevel.bien,
        );
      });

      test('boîte 5, consecutiveOk >= 3 → maîtrisé', () {
        expect(
          LeitnerService.computeMasteryLevel(
            leitnerBox: 5,
            nbSeen: 10,
            nbSuccess: 9,
            consecutiveOk: 5,
          ),
          MasteryLevel.maitrise,
        );
      });

      test('boîte 5, consecutiveOk < 3 → bien', () {
        expect(
          LeitnerService.computeMasteryLevel(
            leitnerBox: 5,
            nbSeen: 6,
            nbSuccess: 5,
            consecutiveOk: 2,
          ),
          MasteryLevel.bien,
        );
      });

      test('boîte 5, consecutiveOk = 3 → maîtrisé (seuil exact)', () {
        expect(
          LeitnerService.computeMasteryLevel(
            leitnerBox: 5,
            nbSeen: 5,
            nbSuccess: 5,
            consecutiveOk: 3,
          ),
          MasteryLevel.maitrise,
        );
      });
    });
  });

  // -------------------------------------------------------------------
  // Tests d'intégration avec base en mémoire
  // -------------------------------------------------------------------
  group('LeitnerService — intégration DB', () {
    late AppDatabase db;
    late LeitnerService service;
    late int profileId;
    late int dictionaryId;
    late int wordId;

    setUp(() async {
      db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      service = LeitnerService(
        wordsDao: db.wordsDao,
        statsDao: db.statsDao,
      );

      // Créer un profil
      profileId = await db.into(db.profiles).insert(
            ProfilesCompanion.insert(
              prenom: 'Test',
            ),
          );

      // Créer un dictionnaire
      dictionaryId = await db.into(db.dictionaries).insert(
            DictionariesCompanion.insert(
              nom: 'Test Dict',
              profileId: profileId,
            ),
          );

      // Créer un mot
      wordId = await db.into(db.words).insert(
            WordsCompanion.insert(
              dictionaryId: dictionaryId,
              mot: 'CHAT',
            ),
          );
    });

    tearDown(() => db.close());

    test('premier succès → boîte 2, next_review = +2j', () async {
      final now = DateTime(2026, 4, 19, 10, 0);
      final result = await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: true,
        firstTry: true,
        hintUsed: false,
        activityType: 'anagramme',
        now: now,
      );

      expect(result.leitnerBox, 2);
      expect(result.nbSeen, 1);
      expect(result.nbSuccess, 1);
      expect(result.nbFirstTry, 1);
      expect(result.consecutiveOk, 1);
      expect(result.nextReview, DateTime(2026, 4, 21, 10, 0));
      expect(result.masteryLevel, MasteryLevel.enCours);
    });

    test('premier échec → boîte 1, next_review = +1j', () async {
      final now = DateTime(2026, 4, 19, 10, 0);
      final result = await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: false,
        firstTry: false,
        hintUsed: false,
        activityType: 'pendu',
        now: now,
      );

      expect(result.leitnerBox, 1);
      expect(result.nbSeen, 1);
      expect(result.nbSuccess, 0);
      expect(result.consecutiveOk, 0);
      expect(result.nextReview, DateTime(2026, 4, 20, 10, 0));
    });

    test('succès sur boîte 2 → boîte 3, next_review = +4j', () async {
      final now = DateTime(2026, 4, 19, 10, 0);

      // Premier succès → boîte 2
      await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: true,
        firstTry: true,
        hintUsed: false,
        activityType: 'anagramme',
        now: now,
      );

      // Deuxième succès → boîte 3
      final result = await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: true,
        firstTry: true,
        hintUsed: false,
        activityType: 'anagramme',
        now: now,
      );

      expect(result.leitnerBox, 3);
      expect(result.nbSeen, 2);
      expect(result.nbSuccess, 2);
      expect(result.nextReview, DateTime(2026, 4, 23, 10, 0));
      expect(result.masteryLevel, MasteryLevel.bien);
    });

    test('échec sur boîte 4 → retour boîte 1, next_review = demain', () async {
      final now = DateTime(2026, 4, 19, 10, 0);

      // Monter jusqu'à boîte 4 (3 succès)
      for (int i = 0; i < 3; i++) {
        await service.recordResult(
          profileId: profileId,
          wordId: wordId,
          success: true,
          firstTry: true,
          hintUsed: false,
          activityType: 'test',
          now: now,
        );
      }

      // Vérifier boîte 4
      final before = await db.wordsDao.getMastery(wordId, profileId);
      expect(before!.leitnerBox, 4);

      // Échec → retour boîte 1
      final result = await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: false,
        firstTry: false,
        hintUsed: false,
        activityType: 'test',
        now: now,
      );

      expect(result.leitnerBox, 1);
      expect(result.consecutiveOk, 0);
      expect(result.nextReview, DateTime(2026, 4, 20, 10, 0));
    });

    test('word_mastery persisté en DB', () async {
      await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: true,
        firstTry: true,
        hintUsed: false,
        activityType: 'test',
      );

      final mastery = await db.wordsDao.getMastery(wordId, profileId);
      expect(mastery, isNotNull);
      expect(mastery!.nbSeen, 1);
      expect(mastery.nbSuccess, 1);
      expect(mastery.leitnerBox, 2);
    });

    test('daily_stats mis à jour après tentative', () async {
      await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: true,
        firstTry: true,
        hintUsed: false,
        activityType: 'test',
      );

      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final stats = await (db.select(db.dailyStats)
            ..where(
              (d) => d.profileId.equals(profileId) & d.date.equals(today),
            ))
          .getSingleOrNull();

      expect(stats, isNotNull);
      expect(stats!.wordsSeen, 1);
      expect(stats.wordsSuccess, 1);
    });

    test('firstTry non compté si hintUsed ou pas premier essai', () async {
      final result = await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: true,
        firstTry: false,
        hintUsed: true,
        activityType: 'test',
      );

      expect(result.nbFirstTry, 0);
    });

    test('progression complète : boîte 1 → 5 → maîtrisé', () async {
      final now = DateTime(2026, 4, 19, 10, 0);

      // 4 succès pour atteindre boîte 5
      for (int i = 0; i < 4; i++) {
        await service.recordResult(
          profileId: profileId,
          wordId: wordId,
          success: true,
          firstTry: true,
          hintUsed: false,
          activityType: 'test',
          now: now,
        );
      }

      final before = await db.wordsDao.getMastery(wordId, profileId);
      expect(before!.leitnerBox, 5);
      // 4 consecutiveOk, mais masteryLevel peut encore être 'bien' si < 3
      // Ici 4 >= 3, donc maîtrisé

      // Un succès de plus en boîte 5
      final result = await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: true,
        firstTry: true,
        hintUsed: false,
        activityType: 'test',
        now: now,
      );

      expect(result.leitnerBox, 5);
      expect(result.consecutiveOk, 5);
      expect(result.masteryLevel, MasteryLevel.maitrise);
      expect(result.nextReview, DateTime(2026, 5, 5, 10, 0));
    });

    test('plusieurs mots indépendants', () async {
      // Créer un 2e mot
      final wordId2 = await db.into(db.words).insert(
            WordsCompanion.insert(
              dictionaryId: dictionaryId,
              mot: 'CHIEN',
            ),
          );

      // Succès sur mot 1
      await service.recordResult(
        profileId: profileId,
        wordId: wordId,
        success: true,
        firstTry: true,
        hintUsed: false,
        activityType: 'test',
      );

      // Échec sur mot 2
      await service.recordResult(
        profileId: profileId,
        wordId: wordId2,
        success: false,
        firstTry: false,
        hintUsed: false,
        activityType: 'test',
      );

      final m1 = await db.wordsDao.getMastery(wordId, profileId);
      final m2 = await db.wordsDao.getMastery(wordId2, profileId);

      expect(m1!.leitnerBox, 2);
      expect(m2!.leitnerBox, 1);
    });
  });
}
