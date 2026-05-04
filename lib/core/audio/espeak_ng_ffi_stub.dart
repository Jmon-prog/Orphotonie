// ============================================================
// Fichier : lib/core/audio/espeak_ng_ffi_stub.dart
// Description : Stub no-op de EspeakNgFfi pour la compilation web.
//               Sur le web, le TTS est assuré par flutter_tts via la
//               Web Speech API du navigateur. Aucune fonction native
//               n'est disponible : toutes retournent false/ne font rien.
// ============================================================

/// Stub de la classe EspeakNgFfi — utilisé uniquement sur le web.
///
/// Remplace [espeak_ng_ffi.dart] qui importe dart:ffi (incompatible web).
/// L'import conditionnel dans [tts_service.dart] sélectionne ce fichier
/// lorsque dart:ffi n'est pas disponible (cible web).
class EspeakNgFfi {
  EspeakNgFfi._();

  static bool tryLoad() => false;
  static bool init() => false;
  static bool setVoice(String name) => false;
  static bool setRate(int wpm) => false;
  static bool setVolume(int amplitude) => false;
  static bool setPitch(int pitch) => false;
  static bool synth(String text) => false;
  static bool synthSsml(String ssmlText) => false;
  static bool synthPhonetic({required String word, String? phonoIpa}) => false;
  static bool cancel() => false;
  static bool resetMbrola() => false;
  static bool isPlaying() => false;
  static void synchronize() {}
  static void terminate() {}
}
