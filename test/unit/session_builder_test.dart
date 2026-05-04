// ============================================================
// Fichier : test/unit/session_builder_test.dart
// Description : Tests unitaires pour SessionBuilder.
//               Vérifie la sélection SRS : priorité révision,
//               nouveaux, compléments, quotas.
// ============================================================

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/core/database/app_database.dart';
import 'package:orphotonie/features/srs/session_builder.dart';

void main() {
  group('SessionBuilder', () {
    late AppDatabase db;
    late SessionBuilder builder;
    late int profileId;
    late int dictionaryId;

    setUp(() async {
      db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );
      builder = SessionBuilder(wordsDao: db.wordsDao);

      profileId = await db.into(db.profiles).insert(
            ProfilesCompanion.insert(prenom: 'Test'),
          );

      dictionaryId = await db.into(db.dictionaries).insert(
            DictionariesCompanion.insert(
              nom: 'Test Dict',
              profileId: profileId,
            ),
          );
    });

    tearDown(() => db.close());

    /// Insère N mots et retourne leurs IDs.
    Future<List<int>> insertWords(int count) async {
      final ids = <int>[];
      for (int i = 0; i < count; i++) {
        final id = await db.into(db.words).insert(
              WordsCompanion.insert(
                dictionaryId: dictionaryId,
                mot: 'MOT_$i',
              ),
            );
        ids.add(id);
      }
      return ids;
    }

    test('dictionnaire vide → session vide', () async {
      final session = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
      );
      expect(session, isEmpty);
    });

    test('tous nouveaux → sélectionnés en priorité 2', () async {
      await insertWords(5);

      final session = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        wordCount: 15,
      );

      expect(session.length, 5);
      for (final sw in session) {
        expect(sw.priority, SessionWordPriority.newWord);
        expect(sw.isNew, isTrue);
        expect(sw.needsDiscovery, isTrue);
      }
    });

    test('mots à réviser en priorité 1', () async {
      final ids = await insertWords(5);
      final now = DateTime(2026, 4, 19, 10, 0);

      // Marquer 2 mots comme "à réviser" (next_review dans le passé)
      for (int i = 0; i < 2; i++) {
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(ids[i]),
            nbSeen: const Value(3),
            nbSuccess: const Value(2),
            leitnerBox: const Value(2),
            nextReview: Value(now.subtract(const Duration(days: 1))),
            lastSeen: Value(now.subtract(const Duration(days: 3))),
            masteryLevel: const Value(1),
          ),
        );
      }

      final session = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        wordCount: 15,
        now: now,
      );

      // Les 2 premiers doivent être dueForReview
      expect(session.length, 5);
      final due = session
          .where((s) => s.priority == SessionWordPriority.dueForReview)
          .toList();
      expect(due.length, 2);

      // Les 3 autres sont newWord
      final newW = session
          .where((s) => s.priority == SessionWordPriority.newWord)
          .toList();
      expect(newW.length, 3);
    });

    test('quota respecté (max 15 par défaut)', () async {
      await insertWords(20);

      final session = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
      );

      expect(session.length, 15);
    });

    test('quota configurable (10-30)', () async {
      await insertWords(25);

      final session10 = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        wordCount: 10,
      );
      expect(session10.length, 10);

      final session25 = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        wordCount: 25,
      );
      expect(session25.length, 25);
    });

    test('quota clamped : < 10 → 10, > 30 → 30', () async {
      await insertWords(35);

      final sessionMin = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        wordCount: 5,
      );
      expect(sessionMin.length, 10);

      final sessionMax = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        wordCount: 50,
      );
      expect(sessionMax.length, 30);
    });

    test('mot boîte 5 depuis 16 jours → apparaît en session', () async {
      final ids = await insertWords(3);
      final now = DateTime(2026, 4, 19, 10, 0);

      // Mot en boîte 5, révision il y a 1 jour (dû)
      await db.wordsDao.upsertMastery(
        WordMasteryCompanion(
          profileId: Value(profileId),
          wordId: Value(ids[0]),
          nbSeen: const Value(10),
          nbSuccess: const Value(9),
          consecutiveOk: const Value(5),
          leitnerBox: const Value(5),
          nextReview: Value(now.subtract(const Duration(days: 1))),
          lastSeen: Value(now.subtract(const Duration(days: 17))),
          masteryLevel: const Value(3),
        ),
      );

      final session = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        now: now,
      );

      final dueWord = session.firstWhere(
        (s) => s.word.id == ids[0],
      );
      expect(dueWord.priority, SessionWordPriority.dueForReview);
    });

    test('fillers triés par boîte croissante', () async {
      final ids = await insertWords(3);
      final now = DateTime(2026, 4, 19, 10, 0);

      // Mettre les 3 mots en boîtes différentes avec next_review dans le futur
      for (int i = 0; i < 3; i++) {
        await db.wordsDao.upsertMastery(
          WordMasteryCompanion(
            profileId: Value(profileId),
            wordId: Value(ids[i]),
            nbSeen: Value(i + 1),
            nbSuccess: Value(i + 1),
            leitnerBox: Value(5 - i), // boîte 5, 4, 3
            nextReview: Value(now.add(const Duration(days: 10))),
            lastSeen: Value(now),
            masteryLevel: Value(i == 0 ? 3 : 2),
          ),
        );
      }

      final session = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        now: now,
      );

      // Tous sont fillers, triés par boîte croissante
      expect(session.length, 3);
      for (final sw in session) {
        expect(sw.priority, SessionWordPriority.filler);
      }
      // Boîte la plus basse en premier
      expect(session[0].mastery!.leitnerBox, 3);
      expect(session[1].mastery!.leitnerBox, 4);
      expect(session[2].mastery!.leitnerBox, 5);
    });

    test('ordre de sélection : due → new → filler', () async {
      final ids = await insertWords(6);
      final now = DateTime(2026, 4, 19, 10, 0);

      // ids[0] : à réviser
      await db.wordsDao.upsertMastery(
        WordMasteryCompanion(
          profileId: Value(profileId),
          wordId: Value(ids[0]),
          nbSeen: const Value(3),
          leitnerBox: const Value(2),
          nextReview: Value(now.subtract(const Duration(hours: 1))),
          lastSeen: Value(now.subtract(const Duration(days: 2))),
          masteryLevel: const Value(1),
        ),
      );

      // ids[1] : filler (vu, pas en retard)
      await db.wordsDao.upsertMastery(
        WordMasteryCompanion(
          profileId: Value(profileId),
          wordId: Value(ids[1]),
          nbSeen: const Value(5),
          nbSuccess: const Value(4),
          leitnerBox: const Value(3),
          nextReview: Value(now.add(const Duration(days: 3))),
          lastSeen: Value(now),
          masteryLevel: const Value(2),
        ),
      );

      // ids[2..5] : nouveaux (pas de mastery)

      final session = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        wordCount: 15,
        now: now,
      );

      expect(session.length, 6);
      // Premier = dueForReview
      expect(session[0].priority, SessionWordPriority.dueForReview);
      expect(session[0].word.id, ids[0]);

      // Ensuite les nouveaux
      final newOnes = session
          .where((s) => s.priority == SessionWordPriority.newWord)
          .toList();
      expect(newOnes.length, 4);

      // Enfin le filler
      final fillerOnes = session
          .where((s) => s.priority == SessionWordPriority.filler)
          .toList();
      expect(fillerOnes.length, 1);
      expect(fillerOnes[0].word.id, ids[1]);
    });

    test('needsDiscovery vrai pour mots jamais vus', () async {
      final ids = await insertWords(2);
      final now = DateTime(2026, 4, 19, 10, 0);

      // Un mot vu, un mot pas vu
      await db.wordsDao.upsertMastery(
        WordMasteryCompanion(
          profileId: Value(profileId),
          wordId: Value(ids[0]),
          nbSeen: const Value(1),
          leitnerBox: const Value(2),
          nextReview: Value(now.subtract(const Duration(days: 1))),
          masteryLevel: const Value(1),
        ),
      );

      final session = await builder.buildSession(
        dictionaryId: dictionaryId,
        profileId: profileId,
        now: now,
      );

      final seen = session.firstWhere((s) => s.word.id == ids[0]);
      final unseen = session.firstWhere((s) => s.word.id == ids[1]);

      expect(seen.needsDiscovery, isFalse);
      expect(unseen.needsDiscovery, isTrue);
    });
  });
}
