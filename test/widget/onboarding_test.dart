// ============================================================
// Fichier : test/widget/onboarding_test.dart
// Description : Tests de l'écran d'onboarding (praticien + parent).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:orphotonie/core/database/app_database.dart';
import 'package:orphotonie/core/database/database_providers.dart';
import 'package:orphotonie/features/help/presentation/onboarding_screen.dart';
import 'package:orphotonie/features/help/data/help_content.dart';
import 'package:orphotonie/features/search/data/search_filters_model.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory()),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildApp({
    required bool isPractitioner,
    required int profileId,
    required VoidCallback onComplete,
  }) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(
        home: OnboardingScreen(
          isPractitioner: isPractitioner,
          profileId: profileId,
          onComplete: onComplete,
        ),
      ),
    );
  }

  group('OnboardingScreen — praticien', () {
    testWidgets('affiche 5 pages praticien', (tester) async {
      await tester.pumpWidget(
        buildApp(
          isPractitioner: true,
          profileId: 1,
          onComplete: () {},
        ),
      );

      // Première page
      expect(find.text('Bienvenue dans Orphotonie'), findsOneWidget);
      expect(find.text('Passer'), findsOneWidget);
      expect(find.text('Suivant'), findsOneWidget);
    });

    testWidgets('navigation entre pages avec Suivant', (tester) async {
      await tester.pumpWidget(
        buildApp(
          isPractitioner: true,
          profileId: 1,
          onComplete: () {},
        ),
      );

      // Page 1
      expect(find.text('Bienvenue dans Orphotonie'), findsOneWidget);

      // Tap suivant
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();

      // Page 2
      expect(find.text('Recherche avancée'), findsOneWidget);
    });

    testWidgets('dernière page affiche Commencer', (tester) async {
      await tester.pumpWidget(
        buildApp(
          isPractitioner: true,
          profileId: 1,
          onComplete: () {},
        ),
      );

      // Naviguer jusqu'à la dernière page (5 pages)
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Suivant'));
        await tester.pumpAndSettle();
      }

      // La dernière page doit avoir « Commencer »
      expect(find.text('Commencer'), findsOneWidget);
      expect(find.text('Suivi de progression'), findsOneWidget);
    });

    testWidgets('Passer appelle onComplete', (tester) async {
      var completed = false;
      await tester.pumpWidget(
        buildApp(
          isPractitioner: true,
          profileId: 1,
          onComplete: () => completed = true,
        ),
      );

      // Créer un profil d'abord pour la FK
      await db.into(db.profiles).insert(
            ProfilesCompanion.insert(prenom: 'Test'),
          );

      await tester.tap(find.text('Passer'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('Commencer sauvegarde onboarding_done', (tester) async {
      // Créer un profil
      final profileId = await db.into(db.profiles).insert(
            ProfilesCompanion.insert(prenom: 'Test'),
          );

      var completed = false;
      await tester.pumpWidget(
        buildApp(
          isPractitioner: true,
          profileId: profileId,
          onComplete: () => completed = true,
        ),
      );

      // Aller à la dernière page
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Suivant'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);

      // Vérifier en base
      final row = await (db.select(db.appSettings)
            ..where((t) => t.profileId.equals(profileId)))
          .getSingleOrNull();
      expect(row?.onboardingDone, isTrue);
    });
  });

  group('OnboardingScreen — parent', () {
    testWidgets('affiche 3 pages parent', (tester) async {
      await tester.pumpWidget(
        buildApp(
          isPractitioner: false,
          profileId: 1,
          onComplete: () {},
        ),
      );

      // Première page
      expect(find.text('Bienvenue !'), findsOneWidget);
    });

    testWidgets('dernière page parent est la 3e', (tester) async {
      await tester.pumpWidget(
        buildApp(
          isPractitioner: false,
          profileId: 1,
          onComplete: () {},
        ),
      );

      // 2 taps pour atteindre page 3
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Suivant'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Commencer'), findsOneWidget);
      expect(find.text('Un suivi simple'), findsOneWidget);
    });
  });

  group('HelpContent — explainFilters', () {
    test('filtres vides → message par défaut', () {
      const filters = SearchFilters();
      expect(
        explainFilters(filters),
        'Tous les mots du lexique sont affichés.',
      );
    });

    test('prévalence min → explication correcte', () {
      const filters = SearchFilters(minPreval: 90);
      expect(
        explainFilters(filters),
        contains('≥ 90 %'),
      );
    });

    test('phonèmes cibles → mentionnés', () {
      const filters = SearchFilters(targetPhonemes: ['ʃ']);
      expect(
        explainFilters(filters),
        contains('[ʃ]'),
      );
    });

    test('multiples filtres → tous mentionnés', () {
      const filters = SearchFilters(
        targetPhonemes: ['ʃ'],
        minPreval: 70,
        cgramList: ['NOM', 'ADJ'],
      );
      final result = explainFilters(filters);
      expect(result, contains('[ʃ]'));
      expect(result, contains('≥ 70 %'));
      expect(result, contains('NOM, ADJ'));
    });
  });

  group('GlossaryEntries', () {
    test('contient 10 entrées', () {
      expect(kGlossaryEntries.length, 10);
    });

    test('findGlossaryEntry trouve par clé', () {
      final entry = findGlossaryEntry('preval');
      expect(entry, isNotNull);
      expect(entry!.term, 'Prévalence');
    });

    test('findGlossaryEntry retourne null si clé inconnue', () {
      expect(findGlossaryEntry('inexistant'), isNull);
    });

    test('chaque entrée a un exemple', () {
      for (final entry in kGlossaryEntries) {
        expect(entry.example, isNotNull, reason: '${entry.key} sans exemple');
      }
    });

    test('clés uniques', () {
      final keys = kGlossaryEntries.map((e) => e.key).toSet();
      expect(keys.length, kGlossaryEntries.length);
    });
  });

  group('OnboardingPageData', () {
    test('praticien = 5 pages', () {
      expect(kPractitionerOnboarding.length, 5);
    });

    test('parent = 3 pages', () {
      expect(kParentOnboarding.length, 3);
    });
  });

  group('PedagogicalGuides', () {
    test('5 guides', () {
      expect(kPedagogicalGuides.length, 5);
    });

    test('chaque guide a au moins 3 conseils', () {
      for (final guide in kPedagogicalGuides) {
        expect(
          guide.tips.length,
          greaterThanOrEqualTo(3),
          reason: '${guide.title} a moins de 3 tips',
        );
      }
    });

    test('chaque guide a des filtres valides', () {
      for (final guide in kPedagogicalGuides) {
        expect(
          guide.suggestedFilters,
          isNotNull,
          reason: '${guide.title} sans filtres',
        );
      }
    });
  });
}
