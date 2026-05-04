// ============================================================
// Fichier : test/unit/audio_feedback_service_test.dart
// Description : Tests unitaires du service de sons de feedback.
//               Vérifie l'API, le flag enabled, et la robustesse
//               quand les assets ne sont pas disponibles (test env).
// ============================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orphotonie/core/audio/audio_feedback_service.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class FakeSource extends Fake implements Source {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeSource());
  });

  group('AudioFeedbackService', () {
    late MockAudioPlayer mockPlayer;
    late AudioFeedbackService service;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      // Stubs par défaut
      when(() => mockPlayer.stop()).thenAnswer((_) async {});
      when(() => mockPlayer.play(any())).thenAnswer((_) async {});
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});
      service = AudioFeedbackService(player: mockPlayer);
    });

    tearDown(() async {
      await service.dispose();
    });

    test('enabled est true par défaut', () {
      expect(service.enabled, isTrue);
    });

    test('enabled peut être désactivé', () {
      service.enabled = false;
      expect(service.enabled, isFalse);
    });

    test('playSuccess() appelle play quand activé', () async {
      await service.playSuccess();
      verify(() => mockPlayer.stop()).called(1);
      verify(() => mockPlayer.play(any())).called(1);
    });

    test('playSuccess() ne joue pas quand désactivé', () async {
      service.enabled = false;
      await service.playSuccess();
      verifyNever(() => mockPlayer.play(any()));
    });

    test('playError() ne joue pas quand désactivé', () async {
      service.enabled = false;
      await service.playError();
      verifyNever(() => mockPlayer.play(any()));
    });

    test('playEncouragement() ne joue pas quand désactivé', () async {
      service.enabled = false;
      await service.playEncouragement();
      verifyNever(() => mockPlayer.play(any()));
    });

    test('playLevelComplete() ne joue pas quand désactivé', () async {
      service.enabled = false;
      await service.playLevelComplete();
      verifyNever(() => mockPlayer.play(any()));
    });

    test('playTick() ne joue pas quand désactivé', () async {
      service.enabled = false;
      await service.playTick();
      verifyNever(() => mockPlayer.play(any()));
    });

    test('dispose() libère le player', () async {
      await service.dispose();
      verify(() => mockPlayer.dispose()).called(1);
    });

    test('toggler enabled on/off fonctionne', () {
      service.enabled = false;
      expect(service.enabled, isFalse);
      service.enabled = true;
      expect(service.enabled, isTrue);
    });
  });
}
