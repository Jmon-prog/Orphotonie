// ============================================================
// Fichier : lib/core/sharing/sharing_providers.dart
// Description : Providers Riverpod pour les services de partage.
//               100% hors ligne — aucun accès réseau.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'share_encoder.dart';
import 'share_decoder.dart';
import 'stats_share_encoder.dart';

/// Provider du service d'encodage pour le partage.
final shareEncoderProvider = Provider<ShareEncoder>((ref) {
  return ShareEncoder();
});

/// Provider du service de décodage pour l'import.
final shareDecoderProvider = Provider<ShareDecoder>((ref) {
  return ShareDecoder();
});

/// Provider du service d'encodage/décodage des statistiques.
final statsShareEncoderProvider = Provider<StatsShareEncoder>((ref) {
  return StatsShareEncoder();
});
