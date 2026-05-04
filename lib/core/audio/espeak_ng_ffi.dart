// ============================================================
// Fichier : lib/core/audio/espeak_ng_ffi.dart
// Description : Liaison FFI vers la bibliothèque eSpeak NG.
//               Charge dynamiquement libespeak-ng (.dll/.so/.dylib)
//               et expose les fonctions de synthèse vocale locale.
//               Utilisé uniquement sur desktop (Windows/Linux/macOS).
//               Aucune requête réseau. 100 % hors-ligne.
// ============================================================

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

// ── Constantes eSpeak NG ─────────────────────────────────────────────────────

/// Mode de sortie audio : eSpeak NG gère lui-même la lecture audio.
const int _kEnoutputModeSpeakAudio = 0x0002;

/// Statut OK retourné par les fonctions espeak_ng_*.
const int _kEnsOk = 0;

/// Paramètre : débit de parole en mots par minute (80–450, défaut 175).
const int _kParamRate = 1;

/// Paramètre : volume / amplitude (0–200, défaut 100).
const int _kParamVolume = 2;

/// Paramètre : hauteur de la voix (0–100, défaut 50).
const int _kParamPitch = 3;

/// Type de position : en caractères dans le texte.
const int _kPosCharacter = 1;

/// Drapeau de synthèse : le texte fourni est encodé en UTF-8.
const int _kFlagCharsUtf8 = 1;

/// Drapeau de synthèse : le texte est du SSML (balises XML, ex. <phoneme>).
const int _kFlagSsml = 0x10;

// ── Types natifs (espeak_ng.h + speak_lib.h) ────────────────────────────────

// void espeak_ng_InitializePath(const char *path)
typedef _InitPathC = Void Function(Pointer<Utf8> path);
typedef _InitPathDart = void Function(Pointer<Utf8> path);

// espeak_ng_STATUS espeak_ng_Initialize(espeak_ng_ERROR_CONTEXT *context)
typedef _InitializeC = Int32 Function(Pointer<Void> context);
typedef _InitializeDart = int Function(Pointer<Void> context);

// espeak_ng_STATUS espeak_ng_InitializeOutput(mode, bufLen, device)
typedef _InitOutputC = Int32 Function(
  Int32 mode,
  Int32 bufLen,
  Pointer<Utf8> device,
);
typedef _InitOutputDart = int Function(
  int mode,
  int bufLen,
  Pointer<Utf8> device,
);

// espeak_ng_STATUS espeak_ng_SetVoiceByName(const char *name)
typedef _SetVoiceC = Int32 Function(Pointer<Utf8> name);
typedef _SetVoiceDart = int Function(Pointer<Utf8> name);

// espeak_ng_STATUS espeak_ng_SetParameter(parameter, value, relative)
typedef _SetParamC = Int32 Function(Int32 param, Int32 value, Int32 relative);
typedef _SetParamDart = int Function(int param, int value, int relative);

// espeak_ng_STATUS espeak_ng_Synthesize(text, size, position, positionType,
//                                       endPosition, flags, uid, userData)
typedef _SynthC = Int32 Function(
  Pointer<Void> text,
  IntPtr size,
  Uint32 position,
  Int32 positionType,
  Uint32 endPosition,
  Uint32 flags,
  Pointer<Void> uid,
  Pointer<Void> userData,
);
typedef _SynthDart = int Function(
  Pointer<Void> text,
  int size,
  int position,
  int positionType,
  int endPosition,
  int flags,
  Pointer<Void> uid,
  Pointer<Void> userData,
);

// espeak_ng_STATUS espeak_ng_Cancel(void)
typedef _CancelC = Int32 Function();
typedef _CancelDart = int Function();

// espeak_ng_STATUS espeak_ng_Synchronize(void)
typedef _SynchronizeC = Int32 Function();
typedef _SynchronizeDart = int Function();

// espeak_ng_STATUS espeak_ng_Terminate(void)
typedef _TerminateC = Int32 Function();
typedef _TerminateDart = int Function();

// int espeak_IsPlaying(void)  — speak_lib.h, exporté même par libespeak-ng
typedef _IsPlayingC = Int32 Function();
typedef _IsPlayingDart = int Function();

// ── Classe FFI ────────────────────────────────────────────────────────────────

/// Liaisons FFI statiques vers eSpeak NG.
///
/// Usage typique :
/// ```dart
/// if (EspeakNgFfi.tryLoad()) {
///   if (EspeakNgFfi.init()) {
///     EspeakNgFfi.setVoice('fr');
///     EspeakNgFfi.setRate(175);
///     EspeakNgFfi.setVolume(100);
///     EspeakNgFfi.synth('Bonjour');
///   }
/// }
/// ```
class EspeakNgFfi {
  EspeakNgFfi._();

  static DynamicLibrary? _lib;
  static bool _initialized = false;

  // Pointeurs de fonctions résolus au chargement
  static _InitPathDart? _ngInitializePath;
  static _InitializeDart? _ngInitialize;
  static _InitOutputDart? _ngInitializeOutput;
  static _SetVoiceDart? _ngSetVoiceByName;
  static _SetParamDart? _ngSetParameter;
  static _SynthDart? _ngSynthesize;
  static _CancelDart? _ngCancel;
  static _SynchronizeDart? _ngSynchronize;
  static _TerminateDart? _ngTerminate;
  static _IsPlayingDart? _espeakIsPlaying;

  // Chemin de données détecté lors du chargement (null = chemin système)
  static String? _detectedDataPath;

  // Voix courante — conservée pour la re-sélectionner après espeak_ng_Cancel()
  // qui appelle close_MBR() et perd l'état interne MBROLA.
  static String? _currentVoice;

  // ── API publique ────────────────────────────────────────────────────────────

  /// Tente de charger la bibliothèque partagée eSpeak NG.
  ///
  /// Parcourt les emplacements courants (PATH système puis chemins connus).
  /// Retourne `true` si la bibliothèque et tous les symboles sont résolus.
  static bool tryLoad() {
    if (_lib != null) return true;

    for (final candidate in _candidates()) {
      try {
        // Sur Windows, pré-charger mbrola.dll AVANT libespeak-ng.dll.
        // Quand libespeak-ng.dll appelle LoadLibraryA("mbrola.dll"), Windows
        // retrouve la DLL déjà chargée dans l'espace du processus.
        if (Platform.isWindows) {
          final mbrolaPath =
              '${File(candidate.libPath).parent.path}\\mbrola.dll';
          if (File(mbrolaPath).existsSync()) {
            try {
              DynamicLibrary.open(mbrolaPath);
              debugPrint('TTS FFI : mbrola.dll pré-chargé : $mbrolaPath');
            } catch (e) {
              debugPrint('TTS FFI : mbrola.dll pré-chargement échoué : $e');
            }
          }
        }

        final lib = DynamicLibrary.open(candidate.libPath);
        if (_resolveSymbols(lib)) {
          _lib = lib;
          _detectedDataPath = candidate.dataPath;
          debugPrint(
            'TTS FFI : bibliothèque eSpeak NG chargée : ${candidate.libPath}',
          );
          return true;
        }
        // Symboles manquants — fermer et essayer le suivant
      } catch (_) {
        continue;
      }
    }

    debugPrint('TTS FFI : bibliothèque eSpeak NG introuvable.');
    return false;
  }

  /// Initialise le moteur eSpeak NG.
  ///
  /// À appeler après [tryLoad]. Retourne `true` si l'initialisation réussit.
  /// Un appel répété retourne directement l'état courant.
  static bool init() {
    if (_lib == null) return false;
    if (_initialized) return true;

    try {
      // Chemin des données vocales (null → chemin compilé par défaut)
      final dp = _detectedDataPath;
      if (dp != null) {
        final ptr = dp.toNativeUtf8();
        try {
          _ngInitializePath!(ptr);
        } finally {
          malloc.free(ptr);
        }
      } else {
        _ngInitializePath!(Pointer<Utf8>.fromAddress(0));
      }

      // Initialisation principale
      final initStatus = _ngInitialize!(Pointer<Void>.fromAddress(0));
      if (initStatus != _kEnsOk) {
        debugPrint(
          'TTS FFI : espeak_ng_Initialize a échoué (code=$initStatus)',
        );
        return false;
      }

      // Activation de la sortie audio intégrée (eSpeak NG gère l'audio)
      final outStatus = _ngInitializeOutput!(
        _kEnoutputModeSpeakAudio,
        0,
        Pointer<Utf8>.fromAddress(0),
      );
      if (outStatus != _kEnsOk) {
        debugPrint(
          'TTS FFI : espeak_ng_InitializeOutput a échoué (code=$outStatus)',
        );
        return false;
      }

      _initialized = true;
      debugPrint('TTS FFI : moteur eSpeak NG initialisé.');
      return true;
    } catch (e) {
      debugPrint("TTS FFI : erreur d'initialisation : $e");
      return false;
    }
  }

  /// Sélectionne la voix par nom (ex. `'fr'`, `'fr+f3'`, `'fr-nolist'`).
  static bool setVoice(String name) {
    if (!_initialized) return false;
    final ptr = name.toNativeUtf8();
    try {
      final ok = _ngSetVoiceByName!(ptr) == _kEnsOk;
      if (ok) _currentVoice = name;
      return ok;
    } catch (e) {
      debugPrint('TTS FFI : setVoice erreur : $e');
      return false;
    } finally {
      malloc.free(ptr);
    }
  }

  /// Définit le débit de parole en mots par minute (80–450, défaut 175).
  static bool setRate(int wpm) {
    if (!_initialized) return false;
    try {
      return _ngSetParameter!(_kParamRate, wpm.clamp(80, 450), 0) == _kEnsOk;
    } catch (_) {
      return false;
    }
  }

  /// Définit le volume / amplitude (0–200, défaut 100).
  static bool setVolume(int amplitude) {
    if (!_initialized) return false;
    try {
      return _ngSetParameter!(_kParamVolume, amplitude.clamp(0, 200), 0) ==
          _kEnsOk;
    } catch (_) {
      return false;
    }
  }

  /// Définit la hauteur de la voix (0–100, défaut 50).
  static bool setPitch(int pitch) {
    if (!_initialized) return false;
    try {
      return _ngSetParameter!(_kParamPitch, pitch.clamp(0, 100), 0) == _kEnsOk;
    } catch (_) {
      return false;
    }
  }

  /// Lance la synthèse et la lecture du [text] (UTF-8 brut).
  ///
  /// Retourne `true` si la requête de synthèse a été acceptée.
  /// La lecture se fait de manière asynchrone dans le thread interne d'eSpeak NG.
  static bool synth(String text) {
    if (!_initialized) return false;
    if (text.trim().isEmpty) return false;

    final textPtr = text.toNativeUtf8();
    try {
      // Taille du buffer UTF-8 incluant le terminateur null
      final bufferSize = textPtr.length + 1;
      final status = _ngSynthesize!(
        textPtr.cast<Void>(),
        bufferSize,
        0, // position : depuis le début
        _kPosCharacter, // type de position : en caractères
        0, // end_position : jusqu'à la fin
        _kFlagCharsUtf8, // drapeaux : texte UTF-8
        Pointer<Void>.fromAddress(0), // unique_identifier : non utilisé
        Pointer<Void>.fromAddress(0), // user_data : non utilisé
      );
      return status == _kEnsOk;
    } catch (e) {
      debugPrint('TTS FFI : synth erreur : $e');
      return false;
    } finally {
      malloc.free(textPtr);
    }
  }

  /// Lance la synthèse d'un texte SSML (ex. `<speak><phoneme alphabet="ipa" ph="...">mot</phoneme></speak>`).
  ///
  /// Permet de forcer la prononciation via phonèmes IPA — utile pour les
  /// homographes ou pour lire la colonne [phono_ipa] du Lexique 4.
  /// Retourne `true` si la requête de synthèse a été acceptée.
  static bool synthSsml(String ssmlText) {
    if (!_initialized) return false;
    if (ssmlText.trim().isEmpty) return false;

    final textPtr = ssmlText.toNativeUtf8();
    try {
      final bufferSize = textPtr.length + 1;
      final status = _ngSynthesize!(
        textPtr.cast<Void>(),
        bufferSize,
        0,
        _kPosCharacter,
        0,
        _kFlagCharsUtf8 | _kFlagSsml, // UTF-8 + SSML
        Pointer<Void>.fromAddress(0),
        Pointer<Void>.fromAddress(0),
      );
      return status == _kEnsOk;
    } catch (e) {
      debugPrint('TTS FFI : synthSsml erreur : $e');
      return false;
    } finally {
      malloc.free(textPtr);
    }
  }

  /// Prononce un mot via ses phonèmes IPA (colonne [phono_ipa] du Lexique 4).
  ///
  /// Construit automatiquement le SSML : `<speak><phoneme alphabet="ipa" ph="...">mot</phoneme></speak>`
  /// Si [phonoIpa] est null/vide, retombe sur la synthèse normale du mot.
  /// Retourne `true` si la requête a été acceptée.
  static bool synthPhonetic({required String word, String? phonoIpa}) {
    if (!_initialized) return false;
    // Nettoyer les slashes éventuels ex. /bɔ̃ʒuʁ/ → bɔ̃ʒuʁ
    final ipa = phonoIpa?.replaceAll('/', '').replaceAll('\\', '').trim();
    if (ipa == null || ipa.isEmpty) return synth(word);
    // Échapper les caractères XML dans le mot affiché
    final wordEscaped = word
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    final ssml =
        '<speak><phoneme alphabet="ipa" ph="$ipa">$wordEscaped</phoneme></speak>';
    return synthSsml(ssml);
  }

  /// Annule la synthèse et la lecture en cours.
  ///
  /// Re-sélectionne automatiquement la voix courante car `espeak_ng_Cancel()`
  /// appelle `close_MBR()` en interne, effaçant l'état MBROLA.
  /// Sans ce re-sélection, les synthèses suivantes utilisent la voix formant.
  static bool cancel() {
    if (!_initialized) return false;
    try {
      _ngCancel!();
      // Re-initialiser MBROLA : espeak_ng_Cancel → close_MBR → perd init_MBR.
      // SetVoiceByName rappelle init_MBR et restaure la base diphone.
      final voice = _currentVoice;
      if (voice != null) {
        final ptr = voice.toNativeUtf8();
        try {
          _ngSetVoiceByName!(ptr);
        } finally {
          malloc.free(ptr);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Réinitialise MBROLA après une synthèse complète, sans appeler cancel().
  ///
  /// `espeak_ng_Cancel()` détruit l'état MBROLA via `close_MBR()`. Cette
  /// méthode remet la voix en place via `setVoiceByName` (qui appelle
  /// `init_MBR`) sans la phase destructrice, ce qui prépare la prochaine
  /// synthèse sans perdre l'initialisation MBROLA.
  static bool resetMbrola() {
    if (!_initialized) return false;
    final voice = _currentVoice;
    if (voice == null) return false;
    final ptr = voice.toNativeUtf8();
    try {
      final ok = _ngSetVoiceByName!(ptr) == _kEnsOk;
      debugPrint('TTS FFI resetMbrola($voice) : $ok');
      return ok;
    } catch (e) {
      debugPrint('TTS FFI resetMbrola erreur : $e');
      return false;
    } finally {
      malloc.free(ptr);
    }
  }

  /// Retourne `true` si eSpeak NG est en train de synthétiser ou de lire.
  static bool isPlaying() {
    if (!_initialized) return false;
    try {
      return _espeakIsPlaying!() != 0;
    } catch (_) {
      return false;
    }
  }

  /// Attend la fin de la lecture en cours (appel bloquant).
  ///
  /// À utiliser uniquement depuis un isolate ou en dehors du thread UI.
  static void synchronize() {
    if (!_initialized) return;
    try {
      _ngSynchronize!();
    } catch (_) {}
  }

  /// Libère toutes les ressources du moteur eSpeak NG.
  static void terminate() {
    if (!_initialized) return;
    try {
      _ngTerminate!();
    } catch (_) {}
    _initialized = false;
    _lib = null;
    _detectedDataPath = null;
    _ngInitializePath = null;
    _ngInitialize = null;
    _ngInitializeOutput = null;
    _ngSetVoiceByName = null;
    _ngSetParameter = null;
    _ngSynthesize = null;
    _ngCancel = null;
    _ngSynchronize = null;
    _ngTerminate = null;
    _espeakIsPlaying = null;
  }

  // ── Résolution interne ──────────────────────────────────────────────────────

  /// Chemins candidats selon la plateforme.
  ///
  /// La valeur `dataPath` est `null` quand le chemin système par défaut
  /// (compilé dans la bibliothèque) doit être utilisé.
  static List<({String libPath, String? dataPath})> _candidates() {
    if (kIsWeb) return const [];

    // Répertoire de l'exécutable — priorité 1 (DLL bundlée avec l'app)
    final exeDir = File(Platform.resolvedExecutable).parent.path;

    if (Platform.isWindows) {
      final bundledDll = '$exeDir\\libespeak-ng.dll';
      final bundledData = '$exeDir\\espeak-ng-data';
      return [
        // DLL bundlée à côté de l'exécutable (build Flutter avec CMake)
        // espeak_ng_InitializePath attend le RÉPERTOIRE PARENT de espeak-ng-data
        // (il ajoute lui-même /espeak-ng-data au chemin fourni).
        if (File(bundledDll).existsSync())
          (
            libPath: bundledDll,
            dataPath: Directory(bundledData).existsSync() ? exeDir : null,
          ),
        // Résolution via le PATH système (install standard)
        (libPath: 'libespeak-ng.dll', dataPath: null),
        (libPath: 'espeak-ng.dll', dataPath: null),
        // Chemin absolu — installeur officiel eSpeak NG
        (
          libPath: r'C:\Program Files\eSpeak NG\libespeak-ng.dll',
          dataPath: r'C:\Program Files\eSpeak NG',
        ),
        (
          libPath: r'C:\Program Files (x86)\eSpeak NG\libespeak-ng.dll',
          dataPath: r'C:\Program Files (x86)\eSpeak NG',
        ),
      ];
    }

    if (Platform.isLinux) {
      final bundledSo = '$exeDir/lib/libespeak-ng.so.1';
      final bundledData = '$exeDir/lib/espeak-ng-data';
      return [
        if (File(bundledSo).existsSync())
          (
            libPath: bundledSo,
            dataPath: Directory(bundledData).existsSync() ? bundledData : null,
          ),
        (libPath: 'libespeak-ng.so.1', dataPath: null),
        (libPath: 'libespeak-ng.so', dataPath: null),
        (
          libPath: '/usr/lib/x86_64-linux-gnu/libespeak-ng.so.1',
          dataPath: null
        ),
        (
          libPath: '/usr/lib/aarch64-linux-gnu/libespeak-ng.so.1',
          dataPath: null
        ),
        (libPath: '/usr/local/lib/libespeak-ng.so.1', dataPath: null),
        (libPath: '/usr/lib/libespeak-ng.so.1', dataPath: null),
      ];
    }

    if (Platform.isMacOS) {
      return [
        (libPath: 'libespeak-ng.dylib', dataPath: null),
        (libPath: '/opt/homebrew/lib/libespeak-ng.dylib', dataPath: null),
        (libPath: '/usr/local/lib/libespeak-ng.dylib', dataPath: null),
      ];
    }

    return const [];
  }

  /// Résout tous les symboles depuis la bibliothèque chargée.
  ///
  /// Retourne `true` si tous les symboles requis sont présents.
  static bool _resolveSymbols(DynamicLibrary lib) {
    try {
      _ngInitializePath = lib.lookupFunction<_InitPathC, _InitPathDart>(
        'espeak_ng_InitializePath',
      );
      _ngInitialize = lib.lookupFunction<_InitializeC, _InitializeDart>(
        'espeak_ng_Initialize',
      );
      _ngInitializeOutput = lib.lookupFunction<_InitOutputC, _InitOutputDart>(
        'espeak_ng_InitializeOutput',
      );
      _ngSetVoiceByName = lib.lookupFunction<_SetVoiceC, _SetVoiceDart>(
        'espeak_ng_SetVoiceByName',
      );
      _ngSetParameter = lib.lookupFunction<_SetParamC, _SetParamDart>(
        'espeak_ng_SetParameter',
      );
      _ngSynthesize =
          lib.lookupFunction<_SynthC, _SynthDart>('espeak_ng_Synthesize');
      _ngCancel = lib.lookupFunction<_CancelC, _CancelDart>('espeak_ng_Cancel');
      _ngSynchronize = lib.lookupFunction<_SynchronizeC, _SynchronizeDart>(
        'espeak_ng_Synchronize',
      );
      _ngTerminate = lib.lookupFunction<_TerminateC, _TerminateDart>(
        'espeak_ng_Terminate',
      );
      _espeakIsPlaying =
          lib.lookupFunction<_IsPlayingC, _IsPlayingDart>('espeak_IsPlaying');
      return true;
    } catch (e) {
      debugPrint('TTS FFI : résolution des symboles échouée : $e');
      return false;
    }
  }
}
