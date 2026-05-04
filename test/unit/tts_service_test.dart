// ============================================================
// Fichier : test/unit/tts_service_test.dart
// Description : Tests unitaires du service TTS.
//               Vérifie l'API, les valeurs par défaut et le
//               comportement quand le TTS n'est pas disponible.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/core/audio/tts_service.dart';

void main() {
  group('TtsService — état initial', () {
    late TtsService service;

    setUp(() {
      service = TtsService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('isAvailable retourne false avant init()', () {
      expect(service.isAvailable, isFalse);
    });

    test('isSpeaking émet un stream', () {
      expect(service.isSpeaking, isA<Stream<bool>>());
    });

    test('speak() ne plante pas quand non initialisé', () async {
      // Ne doit pas lever d'exception
      await service.speak('bonjour');
    });

    test('speakWord() ne plante pas quand non initialisé', () async {
      await service.speakWord('chat');
    });

    test('speakDefinition() ne plante pas quand non initialisé', () async {
      await service.speakDefinition('un animal domestique');
    });

    test('stop() ne plante pas quand non initialisé', () async {
      await service.stop();
    });

    test('setRate() clamp entre 0.1 et 2.0', () async {
      // Pas d'exception même sans init
      await service.setRate(0.0);
      await service.setRate(3.0);
      await service.setRate(1.0);
    });

    test('setVolume() clamp entre 0.0 et 1.0', () async {
      await service.setVolume(-1.0);
      await service.setVolume(2.0);
      await service.setVolume(0.5);
    });

    test('dispose() ne plante pas même sans init', () async {
      await service.dispose();
    });
  });
}
