// ============================================================
// Fichier : lib/core/audio/audio_providers.dart
// Description : Providers Riverpod pour TtsService et
//               AudioFeedbackService. 100 % hors-ligne.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tts_service.dart';
import 'audio_feedback_service.dart';

/// Provider singleton du service TTS local.
///
/// L'initialisation est déclenchée automatiquement via [ttsInitProvider]
/// au démarrage de l'application.
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider d'initialisation TTS — à surveiller une fois au démarrage.
///
/// Initialise le backend eSpeak NG (ou fallback) en français (fr-FR).
/// Doit être écouté dans le widget racine via [ref.listen] ou [ref.watch].
final ttsInitProvider = FutureProvider<void>((ref) async {
  final tts = ref.watch(ttsServiceProvider);
  await tts.init();
});

/// Provider singleton du service de sons de feedback.
final audioFeedbackServiceProvider = Provider<AudioFeedbackService>((ref) {
  final service = AudioFeedbackService();
  ref.onDispose(() => service.dispose());
  return service;
});
