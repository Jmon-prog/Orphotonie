// ============================================================
// Fichier : test/widget/help_tooltip_test.dart
// Description : Tests unitaires du widget HelpTooltip.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/features/help/presentation/widgets/help_tooltip.dart';

void main() {
  group('HelpTooltip', () {
    Widget buildApp({String? glossaryKey}) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: HelpTooltip(
              term: 'Prévalence',
              shortExplanation: 'Combien de Français connaissent ce mot.',
              glossaryKey: glossaryKey,
            ),
          ),
        ),
      );
    }

    testWidgets('affiche l\'icône info', (tester) async {
      await tester.pumpWidget(buildApp());
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('Semantics contient le terme', (tester) async {
      await tester.pumpWidget(buildApp());
      final semantics = tester.getSemantics(find.byType(HelpTooltip));
      expect(semantics.label, contains('Prévalence'));
    });

    testWidgets('tap affiche le tooltip overlay', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      // Le terme doit apparaître dans l'overlay
      expect(find.text('Prévalence'), findsOneWidget);
      expect(
        find.text('Combien de Français connaissent ce mot.'),
        findsOneWidget,
      );

      // Flush du timer de fermeture automatique (4s)
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('tooltip disparaît après 4s', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(find.text('Prévalence'), findsOneWidget);

      // Avancer de 5 secondes
      await tester.pump(const Duration(seconds: 5));
      // L'overlay a été retiré
      // Note : le terme 'Prévalence' est dans le Semantics de l'icône,
      // pas dans un Text. Vérifier que l'explication a disparu.
      expect(
        find.text('Combien de Français connaissent ce mot.'),
        findsNothing,
      );
    });

    testWidgets(
        'affiche "Appui long pour en savoir plus" si glossaryKey fourni',
        (tester) async {
      await tester.pumpWidget(buildApp(glossaryKey: 'preval'));
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(
        find.text('Appui long pour en savoir plus'),
        findsOneWidget,
      );

      // Flush du timer de fermeture automatique (4s)
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('pas de "Appui long" si glossaryKey null', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();

      expect(
        find.text('Appui long pour en savoir plus'),
        findsNothing,
      );

      // Flush du timer de fermeture automatique (4s)
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
