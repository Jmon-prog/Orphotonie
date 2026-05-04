// ============================================================
// Fichier : lib/features/srs/srs_providers.dart
// Description : Providers Riverpod pour le système SRS (Leitner).
//               Expose LeitnerService et SessionBuilder.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_providers.dart';
import 'leitner_service.dart';
import 'session_builder.dart';

/// Provider du service Leitner centralisé.
final leitnerServiceProvider = Provider<LeitnerService>((ref) {
  return LeitnerService(
    wordsDao: ref.watch(wordsDaoProvider),
    statsDao: ref.watch(statsDaoProvider),
  );
});

/// Provider du constructeur de session SRS.
final sessionBuilderProvider = Provider<SessionBuilder>((ref) {
  return SessionBuilder(wordsDao: ref.watch(wordsDaoProvider));
});
