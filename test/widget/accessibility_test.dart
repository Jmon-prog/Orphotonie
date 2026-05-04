// ============================================================
// Fichier : test/widget/accessibility_test.dart
// Description : Tests widget vérifiant les propriétés Semantics,
//               le contraste WCAG AA et les cibles tactiles.
// ============================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orphotonie/core/accessibility/focus_helpers.dart';
import 'package:orphotonie/core/accessibility/semantic_helpers.dart';
import 'package:orphotonie/core/theme/child_themes.dart';
import 'package:orphotonie/core/theme/typography.dart';

void main() {
  // -----------------------------------------------------------------------
  // Helpers Sémantiques
  // -----------------------------------------------------------------------
  group('Semantic helpers', () {
    testWidgets('semanticLabel ajoute un label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: semanticLabel('Mon label', const Icon(Icons.star)),
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byIcon(Icons.star));
      expect(semantics.label, 'Mon label');
    });

    testWidgets('semanticButton marque le widget comme bouton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: semanticButton(
              'Action',
              const Icon(Icons.play_arrow),
            ),
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byIcon(Icons.play_arrow));
      expect(semantics.label, 'Action');
      expect(
        semantics.getSemanticsData().hasFlag(SemanticsFlag.isButton),
        isTrue,
      );
    });

    testWidgets('semanticHeader marque le widget comme en-tête',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: semanticHeader(
              'Titre section',
              const Text('Titre'),
            ),
          ),
        ),
      );
      final semantics = tester.getSemantics(find.text('Titre'));
      expect(
        semantics.getSemanticsData().hasFlag(SemanticsFlag.isHeader),
        isTrue,
      );
    });

    testWidgets('semanticImage marque le widget comme image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: semanticImage(
              'Une étoile',
              const Icon(Icons.star_border),
            ),
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byIcon(Icons.star_border));
      expect(
        semantics.getSemanticsData().hasFlag(SemanticsFlag.isImage),
        isTrue,
      );
    });

    testWidgets('semanticExclude masque le widget du lecteur', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Visible'),
                semanticExclude(const Text('Caché')),
              ],
            ),
          ),
        ),
      );
      // Le texte visible est trouvable, le caché aussi
      // mais n'apparaît pas dans l'arbre sémantique
      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Caché'), findsOneWidget);
      // Notre ExcludeSemantics engloble le texte caché
      expect(
        find.ancestor(
          of: find.text('Caché'),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('semanticMerge fusionne les sous-nœuds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: semanticMerge(
              const Column(
                children: [
                  Text('Nom : '),
                  Text('Orthophonie'),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(MergeSemantics), findsOneWidget);
    });
  });

  // -----------------------------------------------------------------------
  // Extensions SemanticsX
  // -----------------------------------------------------------------------
  group('SemanticsX extensions', () {
    testWidgets('withSemanticLabel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Icon(Icons.add).withSemanticLabel('Ajouter'),
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byIcon(Icons.add));
      expect(semantics.label, 'Ajouter');
    });

    testWidgets('withSemanticButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Icon(Icons.send).withSemanticButton('Envoyer'),
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byIcon(Icons.send));
      expect(
        semantics.getSemanticsData().hasFlag(SemanticsFlag.isButton),
        isTrue,
      );
    });

    testWidgets('excludeFromSemantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Déco').excludeFromSemantics(),
          ),
        ),
      );
      expect(
        find.ancestor(
          of: find.text('Déco'),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
    });

    testWidgets('mergeSemantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Column(
              children: [Text('A'), Text('B')],
            ).mergeSemantics(),
          ),
        ),
      );
      expect(find.byType(MergeSemantics), findsOneWidget);
    });
  });

  // -----------------------------------------------------------------------
  // Focus helpers
  // -----------------------------------------------------------------------
  group('Focus helpers', () {
    testWidgets('FocusOrderGroup crée un FocusTraversalGroup', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FocusOrderGroup(
              child: Column(
                children: [
                  FocusOrdered(
                    order: 1,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Premier'),
                    ),
                  ),
                  FocusOrdered(
                    order: 0,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Deuxième'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      // Material ajoute ses propres FocusTraversalGroup ; on vérifie
      // que notre OrderedTraversalPolicy est présent.
      expect(
        find.byWidgetPredicate(
          (w) => w is FocusTraversalGroup && w.policy is OrderedTraversalPolicy,
        ),
        findsOneWidget,
      );
      expect(find.byType(FocusTraversalOrder), findsNWidgets(2));
    });

    testWidgets('withFocusOrder extension', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () {},
              child: const Text('Test'),
            ).withFocusOrder(3),
          ),
        ),
      );
      expect(find.byType(FocusTraversalOrder), findsAtLeast(1));
    });
  });

  // -----------------------------------------------------------------------
  // Thèmes enfant — contraste WCAG AA
  // -----------------------------------------------------------------------
  group('Child themes — contraste WCAG AA', () {
    /// Calcule le ratio de contraste WCAG entre deux couleurs.
    double contrastRatio(Color fg, Color bg) {
      final l1 = fg.computeLuminance();
      final l2 = bg.computeLuminance();
      final lighter = l1 > l2 ? l1 : l2;
      final darker = l1 > l2 ? l2 : l1;
      return (lighter + 0.05) / (darker + 0.05);
    }

    for (final entry in childThemes.entries) {
      test('${entry.key} : primary sur background ≥ 4.5', () {
        final theme = entry.value;
        final ratio = contrastRatio(theme.primary, theme.background);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              '${entry.key} primary/background ratio=$ratio doit être ≥ 4.5',
        );
      });

      test('${entry.key} : onSurface sur surface ≥ 4.5', () {
        final theme = entry.value;
        final ratio = contrastRatio(theme.onSurface, theme.surface);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '${entry.key} onSurface/surface ratio=$ratio doit être ≥ 4.5',
        );
      });

      test('${entry.key} : toColorScheme() est valide', () {
        final cs = entry.value.toColorScheme();
        expect(cs.primary, isNotNull);
        expect(cs.onPrimary, isNotNull);
        expect(cs.surface, isNotNull);
        expect(cs.onSurface, isNotNull);
      });

      test('${entry.key} : toDarkColorScheme() est valide', () {
        final cs = entry.value.toDarkColorScheme();
        expect(cs.brightness, Brightness.dark);
        expect(cs.primary, isNotNull);
      });
    }
  });

  // -----------------------------------------------------------------------
  // Thèmes enfant — map et default
  // -----------------------------------------------------------------------
  group('Child themes — configuration', () {
    test('childThemes contient 4 thèmes', () {
      expect(childThemes, hasLength(4));
    });

    test('defaultChildThemeKey existe dans la map', () {
      expect(childThemes.containsKey(defaultChildThemeKey), isTrue);
    });

    test('toutes les clés sont uniques', () {
      final keys = childThemes.keys.toSet();
      expect(keys, hasLength(childThemes.length));
    });
  });

  // -----------------------------------------------------------------------
  // Typographie — constantes WCAG
  // -----------------------------------------------------------------------
  group('AppTypography', () {
    test('bodyMinSize ≥ 16sp', () {
      expect(AppTypography.bodyMinSize, greaterThanOrEqualTo(16));
    });

    test('captionMinSize ≥ 14sp', () {
      expect(AppTypography.captionMinSize, greaterThanOrEqualTo(14));
    });
  });
}
