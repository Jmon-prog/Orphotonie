// ============================================================
// Fichier : test/widget_test.dart
// Description : Test de smoke du widget racine OrphothonieApp.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('OrphothonieApp se lance sans erreur', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: OrphothonieApp()),
    );
    expect(find.byType(OrphothonieApp), findsOneWidget);
  });
}
