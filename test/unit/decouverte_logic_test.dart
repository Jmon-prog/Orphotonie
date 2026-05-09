// ============================================================
// Fichier : test/unit/decouverte_logic_test.dart
// Description : Tests unitaires du mode Découverte.
//               Couvre : modèles (DecouverteConfig, DecouverteWordState,
//               DecouverteSessionState), constante kDecouverteActivities,
//               et mutations pures du DecouverteNotifier (sans accès DB).
// ============================================================

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/core/database/app_database.dart';
import 'package:orphotonie/core/database/database_providers.dart';
import 'package:orphotonie/core/database/definitions_database.dart';
import 'package:orphotonie/features/decouverte/decouverte_providers.dart';
import 'package:orphotonie/features/decouverte/decouverte_session.dart';

// ---------------------------------------------------------------------------
// Helpers de test
// ---------------------------------------------------------------------------

/// Sous-classe exposant le setter protégé `state` pour seeder l'état en tests.
class _SeedableNotifier extends DecouverteNotifier {
  _SeedableNotifier(super.ref);
  void seed(DecouverteSessionState s) => state = s;
}

AppDatabase _inMemoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

/// Entrée de définition factice utilisable dans les tests.
DefinitionEntry _fakeEntry(String mot, {int niveau = 5}) => DefinitionEntry(
      mot: mot,
      definition: 'Def $mot',
      niveauDubois: niveau,
    );

void main() {
  // ── DecouverteConfig ──────────────────────────────────────────────────────
  group('DecouverteConfig', () {
    test('stocke correctement les valeurs', () {
      const cfg = DecouverteConfig(levelMin: 3, levelMax: 12, wordCount: 10);
      expect(cfg.levelMin, equals(3));
      expect(cfg.levelMax, equals(12));
      expect(cfg.wordCount, equals(10));
    });

    test('accepte les valeurs limites (niveau 1 à 43)', () {
      const cfg = DecouverteConfig(levelMin: 1, levelMax: 43, wordCount: 15);
      expect(cfg.levelMin, equals(1));
      expect(cfg.levelMax, equals(43));
    });
  });

  // ── DecouverteWordState ───────────────────────────────────────────────────
  group('DecouverteWordState', () {
    test('statut initial est unknown', () {
      final ws = DecouverteWordState(entry: _fakeEntry('CHAT'));
      expect(ws.status, equals(WordExplorationStatus.unknown));
    });

    test('copyWith change le statut', () {
      final ws = DecouverteWordState(entry: _fakeEntry('CHAT'));
      final updated = ws.copyWith(status: WordExplorationStatus.known);
      expect(updated.status, equals(WordExplorationStatus.known));
      expect(updated.entry.mot, equals('CHAT'));
    });

    test('copyWith sans argument conserve le statut', () {
      final ws = DecouverteWordState(
        entry: _fakeEntry('CHAT'),
        status: WordExplorationStatus.toLearn,
      );
      expect(ws.copyWith().status, equals(WordExplorationStatus.toLearn));
    });

    test('entry est conservé dans copyWith', () {
      final entry = _fakeEntry('ARBRE');
      final ws = DecouverteWordState(entry: entry);
      expect(
        identical(
          ws.copyWith(status: WordExplorationStatus.known).entry,
          entry,
        ),
        isTrue,
      );
    });
  });

  // ── DecouverteSessionState ────────────────────────────────────────────────
  group('DecouverteSessionState', () {
    test('empty est correctement initialisé', () {
      const s = DecouverteSessionState.empty;
      expect(s.words, isEmpty);
      expect(s.currentWordIndex, equals(0));
      expect(s.isLoading, isFalse);
      expect(s.error, isNull);
      expect(s.tempDicId, isNull);
      expect(s.config, isNull);
      expect(s.chosenActivityRoutes, isEmpty);
      expect(s.doneActivityRoutes, isEmpty);
    });

    // -- wordsToLearn --
    test('wordsToLearn retourne uniquement les mots toLearn', () {
      final words = [
        DecouverteWordState(
          entry: _fakeEntry('A'),
          status: WordExplorationStatus.toLearn,
        ),
        DecouverteWordState(
          entry: _fakeEntry('B'),
          status: WordExplorationStatus.known,
        ),
        DecouverteWordState(
          entry: _fakeEntry('C'),
          status: WordExplorationStatus.unknown,
        ),
        DecouverteWordState(
          entry: _fakeEntry('D'),
          status: WordExplorationStatus.toLearn,
        ),
      ];
      final s = DecouverteSessionState(words: words);
      expect(s.wordsToLearn.length, equals(2));
      expect(s.wordsToLearn.map((w) => w.entry.mot), containsAll(['A', 'D']));
    });

    test('wordsToLearn est vide si aucun mot toLearn', () {
      final words = [
        DecouverteWordState(
          entry: _fakeEntry('A'),
          status: WordExplorationStatus.known,
        ),
      ];
      expect(DecouverteSessionState(words: words).wordsToLearn, isEmpty);
    });

    // -- allWordsJudged --
    test('allWordsJudged est false si un mot est unknown', () {
      final words = [
        DecouverteWordState(
          entry: _fakeEntry('A'),
          status: WordExplorationStatus.known,
        ),
        DecouverteWordState(
          entry: _fakeEntry('B'),
          status: WordExplorationStatus.unknown,
        ),
      ];
      expect(DecouverteSessionState(words: words).allWordsJudged, isFalse);
    });

    test('allWordsJudged est true quand tous jugés', () {
      final words = [
        DecouverteWordState(
          entry: _fakeEntry('A'),
          status: WordExplorationStatus.known,
        ),
        DecouverteWordState(
          entry: _fakeEntry('B'),
          status: WordExplorationStatus.toLearn,
        ),
      ];
      expect(DecouverteSessionState(words: words).allWordsJudged, isTrue);
    });

    test('allWordsJudged est false si la liste est vide', () {
      expect(const DecouverteSessionState().allWordsJudged, isFalse);
    });

    // -- presentationComplete --
    test('presentationComplete est false si index < longueur', () {
      final words = [
        DecouverteWordState(entry: _fakeEntry('A')),
        DecouverteWordState(entry: _fakeEntry('B')),
      ];
      final s = DecouverteSessionState(words: words, currentWordIndex: 1);
      expect(s.presentationComplete, isFalse);
    });

    test('presentationComplete est true si index >= longueur', () {
      final words = [DecouverteWordState(entry: _fakeEntry('A'))];
      final s = DecouverteSessionState(words: words, currentWordIndex: 1);
      expect(s.presentationComplete, isTrue);
    });

    test('presentationComplete est true sur liste vide', () {
      expect(const DecouverteSessionState().presentationComplete, isTrue);
    });

    // -- progressRatio --
    test('progressRatio est 0 quand aucune activité choisie', () {
      expect(const DecouverteSessionState().progressRatio, equals(0.0));
    });

    test('progressRatio = 0.5 quand 1 activité done sur 2 choisies', () {
      const s = DecouverteSessionState(
        chosenActivityRoutes: {'/a', '/b'},
        doneActivityRoutes: {'/a'},
      );
      expect(s.progressRatio, closeTo(0.5, 0.001));
    });

    test('progressRatio = 1.0 quand toutes terminées', () {
      const s = DecouverteSessionState(
        chosenActivityRoutes: {'/a', '/b'},
        doneActivityRoutes: {'/a', '/b'},
      );
      expect(s.progressRatio, equals(1.0));
    });

    // -- doneCount / totalChosen --
    test('doneCount et totalChosen sont corrects', () {
      const s = DecouverteSessionState(
        chosenActivityRoutes: {'/a', '/b', '/c'},
        doneActivityRoutes: {'/a'},
      );
      expect(s.totalChosen, equals(3));
      expect(s.doneCount, equals(1));
    });

    // -- parcoursComplete --
    test('parcoursComplete est false si aucune activité choisie', () {
      expect(const DecouverteSessionState().parcoursComplete, isFalse);
    });

    test('parcoursComplete est false si pas toutes terminées', () {
      const s = DecouverteSessionState(
        chosenActivityRoutes: {'/a', '/b'},
        doneActivityRoutes: {'/a'},
      );
      expect(s.parcoursComplete, isFalse);
    });

    test('parcoursComplete est true quand toutes les choisies sont terminées',
        () {
      const s = DecouverteSessionState(
        chosenActivityRoutes: {'/a', '/b'},
        doneActivityRoutes: {'/a', '/b'},
      );
      expect(s.parcoursComplete, isTrue);
    });

    // -- copyWith --
    test('copyWith remplace seulement les champs spécifiés', () {
      final original = DecouverteSessionState(
        words: [DecouverteWordState(entry: _fakeEntry('A'))],
        currentWordIndex: 2,
        isLoading: false,
        tempDicId: 42,
        chosenActivityRoutes: {'/x'},
        doneActivityRoutes: {'/y'},
      );
      final copy = original.copyWith(currentWordIndex: 3);
      expect(copy.currentWordIndex, equals(3));
      expect(copy.words.length, equals(1));
      expect(copy.tempDicId, equals(42));
      expect(copy.chosenActivityRoutes, equals({'/x'}));
    });

    test('copyWith avec error=null efface l\'erreur', () {
      final s = const DecouverteSessionState(error: 'oups').copyWith();
      // error n'est pas dans le copyWith default → doit rester null
      expect(s.error, isNull);
    });
  });

  // ── kDecouverteActivities ─────────────────────────────────────────────────
  group('kDecouverteActivities', () {
    test('contient 9 activités', () {
      expect(kDecouverteActivities.length, equals(9));
    });

    test('aucune route en double', () {
      final routes = kDecouverteActivities.map((a) => a.route).toList();
      expect(routes.toSet().length, equals(routes.length));
    });

    test('toutes les routes commencent par /', () {
      for (final a in kDecouverteActivities) {
        expect(
          a.route,
          startsWith('/'),
          reason: '${a.route} devrait commencer par /',
        );
      }
    });

    test('toutes les couleurs sont non nulles et non transparentes', () {
      for (final a in kDecouverteActivities) {
        expect(
          a.color,
          isNonZero,
          reason: '${a.label} a une couleur nulle',
        );
      }
    });

    test('tous les labels sont non vides', () {
      for (final a in kDecouverteActivities) {
        expect(a.label, isNotEmpty);
        expect(a.description, isNotEmpty);
      }
    });

    test('flashcard est la première activité (progression pédagogique)', () {
      expect(kDecouverteActivities.first.icon, equals('flashcard'));
    });
  });

  // ── DecouverteNotifier (mutations pures, sans accès DB) ───────────────────
  group('DecouverteNotifier', () {
    late ProviderContainer container;
    late _SeedableNotifier notifier;

    /// État de départ typique avec 3 mots et index à 0.
    DecouverteSessionState stateWith3Words({int index = 0}) =>
        DecouverteSessionState(
          words: [
            DecouverteWordState(entry: _fakeEntry('ARBRE')),
            DecouverteWordState(entry: _fakeEntry('FLEUR')),
            DecouverteWordState(entry: _fakeEntry('NUAGE')),
          ],
          currentWordIndex: index,
        );

    setUp(() {
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            final db = _inMemoryDb();
            ref.onDispose(db.close);
            return db;
          }),
          decouverteProvider.overrideWith((ref) {
            notifier = _SeedableNotifier(ref);
            return notifier;
          }),
        ],
      );
      // Initialise le provider
      container.read(decouverteProvider.notifier);
    });

    tearDown(() => container.dispose());

    // -- judgeCurrentWord --
    test('judgeCurrentWord marque le mot courant et avance d\'un index', () {
      notifier.seed(stateWith3Words());
      container
          .read(decouverteProvider.notifier)
          .judgeCurrentWord(WordExplorationStatus.known);

      final s = container.read(decouverteProvider);
      expect(s.currentWordIndex, equals(1));
      expect(s.words[0].status, equals(WordExplorationStatus.known));
    });

    test('judgeCurrentWord marquant toLearn met à jour wordsToLearn', () {
      notifier.seed(stateWith3Words());
      container
          .read(decouverteProvider.notifier)
          .judgeCurrentWord(WordExplorationStatus.toLearn);

      expect(container.read(decouverteProvider).wordsToLearn.length, equals(1));
    });

    test('judgeCurrentWord au-delà de la liste ne modifie pas l\'état', () {
      notifier.seed(stateWith3Words(index: 3)); // déjà au bout
      container
          .read(decouverteProvider.notifier)
          .judgeCurrentWord(WordExplorationStatus.known);

      expect(container.read(decouverteProvider).currentWordIndex, equals(3));
    });

    test('judgeCurrentWord consécutifs avancent correctement', () {
      notifier.seed(stateWith3Words());
      final n = container.read(decouverteProvider.notifier);
      n.judgeCurrentWord(WordExplorationStatus.known);
      n.judgeCurrentWord(WordExplorationStatus.toLearn);
      n.judgeCurrentWord(WordExplorationStatus.known);

      final s = container.read(decouverteProvider);
      expect(s.currentWordIndex, equals(3));
      expect(s.presentationComplete, isTrue);
    });

    // -- previousWord --
    test('previousWord décrémente l\'index', () {
      notifier.seed(stateWith3Words(index: 2));
      container.read(decouverteProvider.notifier).previousWord();
      expect(container.read(decouverteProvider).currentWordIndex, equals(1));
    });

    test('previousWord à index 0 ne descend pas en négatif', () {
      notifier.seed(stateWith3Words(index: 0));
      container.read(decouverteProvider.notifier).previousWord();
      expect(container.read(decouverteProvider).currentWordIndex, equals(0));
    });

    // -- toggleActivity --
    test('toggleActivity ajoute une activité non présente', () {
      notifier.seed(const DecouverteSessionState());
      container.read(decouverteProvider.notifier).toggleActivity('/flashcard');
      expect(
        container.read(decouverteProvider).chosenActivityRoutes,
        contains('/flashcard'),
      );
    });

    test('toggleActivity retire une activité déjà présente', () {
      notifier.seed(
        const DecouverteSessionState(chosenActivityRoutes: {'/flashcard'}),
      );
      container.read(decouverteProvider.notifier).toggleActivity('/flashcard');
      expect(
        container.read(decouverteProvider).chosenActivityRoutes,
        isNot(contains('/flashcard')),
      );
    });

    test('toggleActivity n\'affecte pas les autres activités', () {
      notifier.seed(
        const DecouverteSessionState(
          chosenActivityRoutes: {'/flashcard', '/pendu'},
        ),
      );
      container.read(decouverteProvider.notifier).toggleActivity('/flashcard');
      expect(
        container.read(decouverteProvider).chosenActivityRoutes,
        contains('/pendu'),
      );
    });

    // -- markActivityDone --
    test('markActivityDone ajoute la route dans doneActivityRoutes', () {
      notifier.seed(
        const DecouverteSessionState(chosenActivityRoutes: {'/flashcard'}),
      );
      container
          .read(decouverteProvider.notifier)
          .markActivityDone('/flashcard');
      expect(
        container.read(decouverteProvider).doneActivityRoutes,
        contains('/flashcard'),
      );
    });

    test('markActivityDone ne retire pas les routes déjà done', () {
      notifier.seed(
        const DecouverteSessionState(
          chosenActivityRoutes: {'/flashcard', '/pendu'},
          doneActivityRoutes: {'/pendu'},
        ),
      );
      container
          .read(decouverteProvider.notifier)
          .markActivityDone('/flashcard');
      expect(
        container.read(decouverteProvider).doneActivityRoutes,
        containsAll(['/pendu', '/flashcard']),
      );
    });

    test('parcoursComplete après markActivityDone de la dernière activité', () {
      notifier.seed(
        const DecouverteSessionState(
          chosenActivityRoutes: {'/flashcard'},
        ),
      );
      container
          .read(decouverteProvider.notifier)
          .markActivityDone('/flashcard');
      expect(container.read(decouverteProvider).parcoursComplete, isTrue);
    });

    // -- resetSession --
    test('resetSession remet l\'état à empty', () {
      notifier.seed(
        DecouverteSessionState(
          words: [DecouverteWordState(entry: _fakeEntry('A'))],
          tempDicId: 99,
          chosenActivityRoutes: const {'/flashcard'},
          doneActivityRoutes: const {'/flashcard'},
        ),
      );
      container.read(decouverteProvider.notifier).resetSession();

      final s = container.read(decouverteProvider);
      expect(s.words, isEmpty);
      expect(s.tempDicId, isNull);
      expect(s.chosenActivityRoutes, isEmpty);
      expect(s.doneActivityRoutes, isEmpty);
    });
  });
}
