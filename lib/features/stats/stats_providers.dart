// ============================================================
// Fichier : lib/features/stats/stats_providers.dart
// Description : Providers Riverpod pour les statistiques.
//               Expose StatsRepository et les résumés de progression.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_providers.dart';
import 'data/stats_repository.dart';

/// Provider du dépôt de statistiques.
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(
    statsDao: ref.watch(statsDaoProvider),
    wordsDao: ref.watch(wordsDaoProvider),
    database: ref.watch(appDatabaseProvider),
  );
});
