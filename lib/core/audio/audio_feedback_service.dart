// ============================================================
// Fichier : lib/core/audio/audio_feedback_service.dart
// Description : Service de sons de feedback embarqués.
//               Utilise audioplayers pour lire les MP3 depuis assets/.
//               Aucun réseau. 100 % hors-ligne.
// ============================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sons de feedback embarqués dans assets/sounds/.
///
/// Chaque son est pré-chargé pour minimiser la latence.
class AudioFeedbackService {
  AudioFeedbackService({@visibleForTesting AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// Active ou désactive les sons de feedback.
  bool enabled = true;

  /// Joue le son de bonne réponse.
  Future<void> playSuccess() => _play('sounds/success.mp3');

  /// Joue le son de mauvaise réponse.
  Future<void> playError() => _play('sounds/error.mp3');

  /// Joue le son d'encouragement.
  Future<void> playEncouragement() => _play('sounds/encouragement_1.mp3');

  /// Joue le son de fin de session/niveau.
  Future<void> playLevelComplete() => _play('sounds/level_complete.mp3');

  /// Joue le son de sélection (tick).
  Future<void> playTick() => _play('sounds/tick.mp3');

  Future<void> _play(String assetPath) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('AudioFeedback : impossible de jouer $assetPath : $e');
    }
  }

  /// Libère les ressources.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
