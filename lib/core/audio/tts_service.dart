// ============================================================
// Fichier : lib/core/audio/tts_service.dart
// Description : Service TTS centralisé — moteur local uniquement.
//               Hiérarchie : eSpeak NG FFI → eSpeak NG CLI → flutter_tts.
//               Aucune requête réseau. 100 % hors-ligne.
// ============================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Import conditionnel : sur web (dart:ffi indisponible), le stub no-op est
// utilisé — flutter_tts assure la synthèse via la Web Speech API du navigateur.
import 'espeak_ng_ffi_stub.dart' if (dart.library.ffi) 'espeak_ng_ffi.dart';

enum _TtsBackend {
  none,
  espeakFfi, // eSpeak NG via dart:ffi (priorité desktop)
  espeakCli, // eSpeak NG via sous-processus CLI (fallback)
  flutterTts, // Moteur TTS natif OS (fallback mobile / dernier recours)
}

/// Service de synthèse vocale locale.
///
/// Utilise eSpeak NG si disponible sur desktop, sinon le moteur TTS local.
class TtsService {
  TtsService();

  FlutterTts? _tts;
  Process? _espeakProcess;
  String? _espeakExecutable;
  Timer? _ffiPlayTimer;
  _TtsBackend _backend = _TtsBackend.none;
  bool _initialized = false;
  bool _available = false;

  /// Vrai pendant toute la durée d'une lecture — bloque tout nouveau lancement.
  bool _isSpeaking = false;
  double _rate = 0.8;
  double _volume = 1.0;

  final _speakingController = StreamController<bool>.broadcast();

  /// true si la voix MBROLA est active (débit réduit de 20 % pour une meilleure intelligibilité).
  bool _mbrolaActive = false;

  /// Stream indiquant si le TTS est en train de parler.
  Stream<bool> get isSpeaking => _speakingController.stream;

  /// true si un backend TTS local est disponible sur cette plateforme.
  bool get isAvailable => _available;

  /// Initialise le backend TTS en français.
  Future<void> init({double rate = 0.8, double volume = 1.0}) async {
    _rate = rate;
    _volume = volume;

    if (_initialized) {
      await setRate(rate);
      await setVolume(volume);
      return;
    }

    if (_supportsEspeakNgPreference()) {
      // Priorité 1 : eSpeak NG via FFI (chargement de la bibliothèque partagée)
      if (EspeakNgFfi.tryLoad() && EspeakNgFfi.init()) {
        // Tenter mb-fr4 (MBROLA), sinon repli sur fr+f1
        final mbOk = EspeakNgFfi.setVoice('mb-fr4');
        if (mbOk) {
          _mbrolaActive = true;
          debugPrint('TTS FFI : voix MBROLA mb-fr4 activée.');
        } else {
          final frOk = EspeakNgFfi.setVoice('fr+f1');
          debugPrint(
            frOk
                ? 'TTS FFI : mb-fr4 indisponible, repli sur fr+f1.'
                : 'TTS FFI : voix française indisponible dans eSpeak NG.',
          );
        }
        final voiceOk = mbOk || EspeakNgFfi.setVoice('fr+f1');
        EspeakNgFfi.setRate(_rateToWpm(_rate, mbrola: _mbrolaActive));
        EspeakNgFfi.setVolume(
          _volumeToAmplitude(_volume, mbrola: _mbrolaActive),
        );
        _backend = _TtsBackend.espeakFfi;
        _available = voiceOk;
        _initialized = true;
        return;
      }

      // Priorité 2 : eSpeak NG via sous-processus CLI
      final executable = await _findEspeakNgExecutable();
      if (executable != null) {
        _espeakExecutable = executable;
        _backend = _TtsBackend.espeakCli;
        _available = await _hasFrenchVoice(executable);
        _initialized = true;
        if (!_available) {
          debugPrint(
            'TTS CLI : eSpeak NG détecté mais voix française indisponible',
          );
        }
        return;
      }
    }

    // Priorité 3 : moteur TTS natif OS
    await _initFlutterTts();
  }

  Future<void> _initFlutterTts() async {
    try {
      _tts = FlutterTts();
      await _tts!.setLanguage('fr-FR');
      await _tts!.setSpeechRate(_rate);
      await _tts!.setVolume(_volume);
      await _tts!.setPitch(1.0);
      // Sur le web, awaitSpeakCompletion(true) peut bloquer — on l'active
      // uniquement sur les plateformes natives.
      if (!kIsWeb) {
        await _tts!.awaitSpeakCompletion(true);
      }

      _tts!.setStartHandler(() {
        _emitSpeaking(true);
      });
      _tts!.setCompletionHandler(() {
        _emitSpeaking(false);
      });
      _tts!.setCancelHandler(() {
        _emitSpeaking(false);
      });
      _tts!.setErrorHandler((msg) {
        debugPrint('TTS erreur : $msg');
        _emitSpeaking(false);
      });

      // Sur le web, la Web Speech API charge ses voix de façon asynchrone.
      // getVoices() retourne souvent une liste vide lors de l'init → on ne
      // bloque pas sur ce check et on considère le TTS disponible d'emblée.
      if (kIsWeb) {
        _available = true;
        _backend = _TtsBackend.flutterTts;
        debugPrint('TTS web : Web Speech API activée (fr-FR).');
      } else {
        final languages = await _tts!.getLanguages;
        final frAvailable = (languages as List).any(
          (lang) => lang.toString().toLowerCase().startsWith('fr'),
        );
        _available = frAvailable;
        _backend = frAvailable ? _TtsBackend.flutterTts : _TtsBackend.none;
        if (!frAvailable) {
          debugPrint('TTS : langue française non disponible sur cet appareil');
        }
      }

      _initialized = true;
    } catch (e) {
      debugPrint('TTS : initialisation impossible : $e');
      _available = false;
      _backend = _TtsBackend.none;
      _initialized = true;
    }
  }

  bool _supportsEspeakNgPreference() {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  Future<String?> _findEspeakNgExecutable() async {
    final candidates = Platform.isWindows
        ? const ['espeak-ng.exe', 'espeak-ng']
        : const ['espeak-ng'];

    for (final executable in candidates) {
      try {
        final result = await Process.run(
          executable,
          const ['--version'],
          runInShell: Platform.isWindows,
        ).timeout(const Duration(seconds: 2));
        if (result.exitCode == 0) {
          return executable;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Future<bool> _hasFrenchVoice(String executable) async {
    try {
      final result = await Process.run(
        executable,
        const ['--voices=fr'],
        runInShell: Platform.isWindows,
      ).timeout(const Duration(seconds: 2));
      return result.exitCode == 0 &&
          result.stdout.toString().toLowerCase().contains('fr');
    } catch (e) {
      debugPrint(
        'TTS : impossible de vérifier la voix française eSpeak NG : $e',
      );
      return false;
    }
  }

  void _emitSpeaking(bool value) {
    if (!_speakingController.isClosed) {
      _speakingController.add(value);
    }
  }

  Future<void> _speakWithEspeakNg(String text) async {
    if (_espeakExecutable == null || text.trim().isEmpty) return;
    await stop();

    final speed = (120 + ((_rate - 0.1) / 1.9) * 100).round().clamp(80, 220);
    final amplitude = (_volume * 200).round().clamp(0, 200);

    try {
      _espeakProcess = await Process.start(
        _espeakExecutable!,
        [
          '-v',
          'fr',
          '-s',
          '$speed',
          '-a',
          '$amplitude',
          text,
        ],
        runInShell: Platform.isWindows,
      );

      _isSpeaking = true;
      _emitSpeaking(true);
      unawaited(_espeakProcess!.stdout.drain<void>());
      unawaited(_espeakProcess!.stderr.drain<void>());
      unawaited(
        _espeakProcess!.exitCode.then((_) {
          _espeakProcess = null;
          _isSpeaking = false;
          _emitSpeaking(false);
        }),
      );
    } catch (e) {
      debugPrint('TTS : lancement eSpeak NG impossible : $e');
      _espeakProcess = null;
      _isSpeaking = false;
      _emitSpeaking(false);
    }
  }

  /// Lit un texte avec le moteur TTS.
  Future<void> speak(String text) async {
    if (!_available) return;
    // Bloquer tout nouveau lancement si une lecture est déjà en cours.
    if (_isSpeaking) return;
    switch (_backend) {
      case _TtsBackend.espeakFfi:
        await _speakWithEspeakFfi(text);
        return;
      case _TtsBackend.espeakCli:
        // Ignorer si un processus CLI est déjà en cours.
        if (_espeakProcess != null) return;
        await _speakWithEspeakNg(text);
        return;
      case _TtsBackend.flutterTts:
        if (_tts == null) return;
        await _tts!.stop();
        await _tts!.speak(text);
        return;
      case _TtsBackend.none:
        return;
    }
  }

  /// Lit un mot seul (prononciation orthographique normale).
  Future<void> speakWord(String mot) async {
    await speak(mot);
  }

  /// Lit un mot en utilisant ses phonèmes IPA (colonne [phono_ipa] du Lexique 4).
  ///
  /// Lorsque le backend est eSpeak NG FFI, la prononciation est forcée via
  /// SSML `<phoneme alphabet="ipa">` — plus précise pour les homographes.
  /// Sur les autres backends, retombe sur la lecture normale du [mot].
  ///
  /// Exemple :
  /// ```dart
  /// await tts.speakPhonetic(word: 'bonjour', phonoIpa: 'bɔ̃ʒuʁ');
  /// ```
  Future<void> speakPhonetic({
    required String word,
    String? phonoIpa,
  }) async {
    if (!_available) return;
    // Bloquer tout nouveau lancement si une lecture est déjà en cours.
    if (_isSpeaking) return;
    if (_backend == _TtsBackend.espeakFfi) {
      if (EspeakNgFfi.isPlaying()) return;
      _ffiPlayTimer?.cancel();
      _ffiPlayTimer = null;

      _isSpeaking = true;
      final ok = EspeakNgFfi.synthPhonetic(word: word, phonoIpa: phonoIpa);
      debugPrint(
        'TTS FFI speakPhonetic : mot="$word" ipa="$phonoIpa" synthOk=$ok',
      );
      if (!ok) {
        // Repli sur lecture normale si la synthèse phonétique échoue
        await _speakWithEspeakFfi(word);
        return;
      }
      _emitSpeaking(true);
      var checkCount = 0;
      _ffiPlayTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (timer) {
          final playing = EspeakNgFfi.isPlaying();
          if (checkCount++ < 3) {
            debugPrint('TTS FFI isPlaying() check #$checkCount : $playing');
          }
          if (!playing) {
            timer.cancel();
            _ffiPlayTimer = null;
            // Réinitialiser MBROLA sans close_MBR pour la prochaine synthèse.
            EspeakNgFfi.resetMbrola();
            _isSpeaking = false;
            _emitSpeaking(false);
          }
        },
      );
    } else {
      // CLI ou flutter_tts : lecture phonétique non disponible, mot normal
      await speak(word);
    }
  }

  /// Lit une définition.
  Future<void> speakDefinition(String definition) async {
    await speak(definition);
  }

  /// Arrête la lecture en cours.
  Future<void> stop() async {
    if (_backend == _TtsBackend.espeakFfi) {
      _ffiPlayTimer?.cancel();
      _ffiPlayTimer = null;
      EspeakNgFfi.cancel();
      _isSpeaking = false;
      _emitSpeaking(false);
      return;
    }
    if (_backend == _TtsBackend.espeakCli) {
      final process = _espeakProcess;
      if (process != null) {
        process.kill();
        _espeakProcess = null;
        _isSpeaking = false;
        _emitSpeaking(false);
      }
      return;
    }
    if (_tts != null) {
      await _tts!.stop();
    }
  }

  /// Met à jour la vitesse de lecture.
  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.1, 2.0);
    if (_backend == _TtsBackend.espeakFfi) {
      EspeakNgFfi.setRate(_rateToWpm(_rate, mbrola: _mbrolaActive));
    } else if (_backend == _TtsBackend.flutterTts && _tts != null) {
      await _tts!.setSpeechRate(_rate);
    }
  }

  /// Met à jour le volume.
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_backend == _TtsBackend.espeakFfi) {
      EspeakNgFfi.setVolume(_volumeToAmplitude(_volume, mbrola: _mbrolaActive));
    } else if (_backend == _TtsBackend.flutterTts && _tts != null) {
      await _tts!.setVolume(_volume);
    }
  }

  /// Libère les ressources.
  Future<void> dispose() async {
    await stop();
    if (_backend == _TtsBackend.espeakFfi) {
      EspeakNgFfi.terminate();
    }
    await _tts?.stop();
    await _speakingController.close();
    _ffiPlayTimer?.cancel();
    _ffiPlayTimer = null;
    _espeakProcess = null;
    _espeakExecutable = null;
    _tts = null;
    _backend = _TtsBackend.none;
  }

  // ── Méthodes privées ──────────────────────────────────────────────────────

  /// Synthèse via eSpeak NG FFI (lecture dans le thread interne d'eSpeak NG).
  Future<void> _speakWithEspeakFfi(String text) async {
    if (text.trim().isEmpty) return;
    // Ignorer si une lecture est déjà en cours — protège l'état MBROLA.
    if (_isSpeaking) return;
    if (EspeakNgFfi.isPlaying()) return;
    _ffiPlayTimer?.cancel();
    _ffiPlayTimer = null;

    _isSpeaking = true;
    final ok = EspeakNgFfi.synth(text);
    debugPrint('TTS FFI synth : texte="$text" synthOk=$ok');
    if (!ok) {
      _emitSpeaking(false);
      return;
    }

    // Surveillance de la fin de lecture par interrogation périodique
    _emitSpeaking(true);
    var checkCount = 0;
    _ffiPlayTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final playing = EspeakNgFfi.isPlaying();
      if (checkCount++ < 3) {
        debugPrint('TTS FFI isPlaying() check #$checkCount : $playing');
      }
      if (!playing) {
        timer.cancel();
        _ffiPlayTimer = null;
        // Réinitialiser MBROLA sans close_MBR pour la prochaine synthèse.
        EspeakNgFfi.resetMbrola();
        _isSpeaking = false;
        _emitSpeaking(false);
      }
    });
  }

  /// Convertit le taux Dart (0.1–2.0) en mots/minute pour eSpeak NG (80–450).
  /// Applique un facteur de 0.80 si [mbrola] est actif (synthèse diphone plus
  /// lente à articuler que la voix formant — améliore l'intelligibilité).
  static int _rateToWpm(double rate, {bool mbrola = false}) {
    final wpm = (120 + ((rate - 0.1) / 1.9) * 100).round();
    return (mbrola ? (wpm * 0.80).round() : wpm).clamp(80, 450);
  }

  /// Convertit le volume Dart (0.0–1.0) en amplitude eSpeak NG (0–200).
  /// Le niveau nominal d'eSpeak NG est 100 ; au-delà, le signal est amplifié
  /// et peut saturer, surtout avec MBROLA. Si [mbrola] est actif, le plafond
  /// est limité à 80 (80 % du nominal) pour éviter la distorsion.
  static int _volumeToAmplitude(double volume, {bool mbrola = false}) {
    final max = mbrola ? 80 : 200;
    return (volume * max).round().clamp(0, max);
  }
}
