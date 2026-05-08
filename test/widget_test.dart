// ============================================================
// Fichier : test/widget_test.dart
// Description : Test de smoke du widget racine OrphothonieApp.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orphotonie/core/audio/audio_providers.dart';
import 'package:orphotonie/main.dart';

void main() {
  testWidgets('OrphothonieApp se lance sans erreur',
      (WidgetTester tester) async {
    // On override ttsInitProvider pour éviter le timer issu de
    // Process.run().timeout() qui resterait en attente après le test.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsInitProvider.overrideWith((_) async {}),
        ],
        child: const OrphothonieApp(),
      ),
    );
    expect(find.byType(OrphothonieApp), findsOneWidget);
  });
}
