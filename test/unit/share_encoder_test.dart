// ============================================================
// Fichier : test/unit/share_encoder_test.dart
// Description : Tests unitaires du service d'encodage de dictionnaires.
//               Vérifie l'export .orpho (ZIP) et la génération ORPH- (QR).
//               Aucun accès réseau.
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/core/sharing/share_encoder.dart';

void main() {
  late ShareEncoder encoder;
  late Directory tempDir;

  setUp(() async {
    encoder = ShareEncoder();
    tempDir = await Directory.systemTemp.createTemp('share_encoder_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  // -------------------------------------------------------------------------
  // canUseQrCode
  // -------------------------------------------------------------------------
  group('canUseQrCode', () {
    test('retourne true pour ≤ 30 mots', () {
      expect(encoder.canUseQrCode(0), isTrue);
      expect(encoder.canUseQrCode(15), isTrue);
      expect(encoder.canUseQrCode(30), isTrue);
    });

    test('retourne false pour > 30 mots', () {
      expect(encoder.canUseQrCode(31), isFalse);
      expect(encoder.canUseQrCode(100), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // exportToFile
  // -------------------------------------------------------------------------
  group('exportToFile', () {
    test('crée un fichier .orpho valide', () async {
      final words = [
        {'mot': 'chat', 'definition': 'Animal domestique'},
        {'mot': 'chien', 'definition': 'Fidèle compagnon'},
      ];

      final file = await encoder.exportToFile(
        name: 'Animaux',
        couleur: '#2196F3',
        words: words,
        outputDir: tempDir.path,
      );

      expect(await file.exists(), isTrue);
      expect(file.path, endsWith('.orpho'));
    });

    test('fichier .orpho est un ZIP lisible', () async {
      final words = [
        {'mot': 'chat', 'definition': 'Animal domestique'},
      ];

      final file = await encoder.exportToFile(
        name: 'Test ZIP',
        couleur: '#4CAF50',
        words: words,
        outputDir: tempDir.path,
      );

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Doit contenir dictionary.json
      final jsonFile = archive.findFile('dictionary.json');
      expect(jsonFile, isNotNull);
    });

    test('dictionary.json contient les bonnes métadonnées', () async {
      final words = [
        {'mot': 'papillon', 'definition': 'Insecte volant'},
        {'mot': 'abeille', 'definition': null},
      ];

      final file = await encoder.exportToFile(
        name: 'Insectes',
        couleur: '#FF9800',
        words: words,
        outputDir: tempDir.path,
      );

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final jsonFile = archive.findFile('dictionary.json')!;
      final jsonStr = utf8.decode(jsonFile.content as List<int>);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(data['version'], equals(kShareFormatVersion));
      expect(data['export_date'], isNotEmpty);
      expect(data['dictionary']['nom'], equals('Insectes'));
      expect(data['dictionary']['couleur'], equals('#FF9800'));

      final wordsList = data['words'] as List;
      expect(wordsList, hasLength(2));
      expect(wordsList[0]['mot'], equals('papillon'));
      expect(wordsList[0]['definition'], equals('Insecte volant'));
      expect(wordsList[1]['mot'], equals('abeille'));
    });

    test('exclut les définitions quand includeDefinitions = false', () async {
      final words = [
        {'mot': 'chat', 'definition': 'Animal domestique'},
      ];

      final file = await encoder.exportToFile(
        name: 'Sans déf',
        couleur: '#2196F3',
        words: words,
        outputDir: tempDir.path,
        includeDefinitions: false,
      );

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final jsonFile = archive.findFile('dictionary.json')!;
      final jsonStr = utf8.decode(jsonFile.content as List<int>);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final wordsList = data['words'] as List;

      expect(wordsList[0].containsKey('definition'), isFalse);
    });

    test('inclut les médias quand includeMedia = true', () async {
      // Crée un fichier image factice
      final fakeImage = File('${tempDir.path}/test_image.jpg');
      await fakeImage.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]); // En-tête JPEG

      final words = [
        {
          'mot': 'chat',
          'definition': 'Animal',
          'imagePath': fakeImage.path,
        },
      ];

      final file = await encoder.exportToFile(
        name: 'Avec images',
        couleur: '#2196F3',
        words: words,
        outputDir: tempDir.path,
        includeMedia: true,
      );

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Doit contenir le fichier média
      final mediaFile = archive.findFile('media/test_image.jpg');
      expect(mediaFile, isNotNull);

      // Le JSON doit référencer le média
      final jsonFile = archive.findFile('dictionary.json')!;
      final jsonStr = utf8.decode(jsonFile.content as List<int>);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final wordsList = data['words'] as List;
      expect(wordsList[0]['image_path'], equals('media/test_image.jpg'));
    });

    test('nom de fichier sécurisé (caractères spéciaux)', () async {
      final file = await encoder.exportToFile(
        name: 'Sons [f] & [v]!',
        couleur: '#2196F3',
        words: [
          {'mot': 'feu'},
        ],
        outputDir: tempDir.path,
      );

      // Le nom ne doit pas contenir de caractères spéciaux
      final fileName = file.uri.pathSegments.last;
      expect(fileName, isNot(contains('[')));
      expect(fileName, isNot(contains('&')));
      expect(fileName, endsWith('.orpho'));
    });
  });

  // -------------------------------------------------------------------------
  // generateQrCode
  // -------------------------------------------------------------------------
  group('generateQrCode', () {
    test('génère un code ORPH- valide', () {
      final code = encoder.generateQrCode(
        name: 'Animaux',
        wordList: ['chat', 'chien', 'vache'],
      );

      expect(code, isNotNull);
      expect(code, startsWith(kOrphPrefix));
    });

    test('code contient les données correctes après décodage', () {
      final code = encoder.generateQrCode(
        name: 'Test',
        wordList: ['alpha', 'beta', 'gamma'],
      )!;

      // Décode manuellement
      final base64Str = code.substring(kOrphPrefix.length);
      final gzipped = base64Decode(base64Str);
      final jsonStr = utf8.decode(GZipCodec().decode(gzipped));
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      expect(data['v'], equals(kShareFormatVersion));
      expect(data['n'], equals('Test'));
      expect(data['w'], equals(['alpha', 'beta', 'gamma']));
    });

    test('retourne null pour > 30 mots', () {
      final mots = List.generate(31, (i) => 'mot_$i');
      final code = encoder.generateQrCode(name: 'Trop', wordList: mots);
      expect(code, isNull);
    });

    test('code ≤ 2000 caractères pour 30 mots courts', () {
      final mots = List.generate(30, (i) => 'mot$i');
      final code = encoder.generateQrCode(name: 'Test', wordList: mots);

      expect(code, isNotNull);
      expect(code!.length, lessThanOrEqualTo(kQrMaxChars));
    });

    test('génère un code pour une liste vide', () {
      final code = encoder.generateQrCode(name: 'Vide', wordList: []);
      expect(code, isNotNull);
      expect(code, startsWith(kOrphPrefix));
    });
  });

  // -------------------------------------------------------------------------
  // estimateQrCodeLength
  // -------------------------------------------------------------------------
  group('estimateQrCodeLength', () {
    test('retourne la longueur du code', () {
      final length = encoder.estimateQrCodeLength(
        name: 'Test',
        wordList: ['chat', 'chien'],
      );
      expect(length, greaterThan(0));
    });

    test('retourne -1 pour un dictionnaire trop grand', () {
      final mots = List.generate(31, (i) => 'mot_$i');
      final length = encoder.estimateQrCodeLength(
        name: 'Trop',
        wordList: mots,
      );
      expect(length, equals(-1));
    });
  });
}
