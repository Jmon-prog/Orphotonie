// ============================================================
// Fichier : lib/features/help/help_providers.dart
// Description : Providers Riverpod pour la feature aide/onboarding.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_providers.dart';

/// Provider : l'utilisateur a-t-il terminé l'onboarding ?
///
/// Renvoie `true` si la ligne AppSettings du profil indique
/// `onboarding_done = true`, `false` sinon (y compris si pas de ligne).
final onboardingDoneProvider =
    FutureProvider.family<bool, int>((ref, profileId) async {
  final db = ref.watch(appDatabaseProvider);
  final row = await (db.select(db.appSettings)
        ..where((t) => t.profileId.equals(profileId)))
      .getSingleOrNull();
  return row?.onboardingDone ?? false;
});

/// Invalide le cache d'onboarding (après complétion).
void invalidateOnboarding(WidgetRef ref, int profileId) {
  ref.invalidate(onboardingDoneProvider(profileId));
}
