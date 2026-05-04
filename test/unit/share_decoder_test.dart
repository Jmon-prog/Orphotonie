// ============================================================
// Fichier : test/unit/share_decoder_test.dart
// Description : Tests unitaires du service de décodage de dictionnaires.
//               Vérifie l'import depuis .orpho (ZIP) et code ORPH-.
//               Aucun accès réseau.
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orphotonie/core/sharing/share_decoder.dart';
import 'package:orphotonie/core/sharing/share_encoder.dart';

void main() {
  late ShareDecoder decoder;
  late ShareEncoder encoder;
  late Directory tempDir;

  setUp(() async {
    decoder = ShareDecoder();
    encoder = ShareEncoder();
    tempDir = await Directory.systemTemp.createTemp('share_decoder_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Crée un fichier .orpho de test avec le JSON fourni.
  Future<File> createOrphoFile(Map<String, dynamic> jsonData) async {
    final archive = Archive();
    final jsonBytes = utf8.encode(jsonEncode(jsonData));
    archive
        .addFile(ArchiveFile('dictionary.json', jsonBytes.length, jsonBytes));
    final zipData = ZipEncoder().encode(archive)!;
    final file = File('${tempDir.path}/test.orpho');
    await file.writeAsBytes(zipData);
    return file;
  }

  // -------------------------------------------------------------------------
  // importFromFile
  // -------------------------------------------------------------------------
  group('importFromFile', () {
    test('importe un fichier .orpho valide', () async {
      final jsonData = {
        'version': 1,
        'export_date': '2026-04-19',
        'dictionary': {'nom': 'Animaux', 'couleur': '#2196F3'},
        'words': [
          {'mot': 'chat', 'definition': 'Animal domestique'},
          {'mot': 'chien', 'definition': 'Fidèle compagnon'},
        ],
      };
      final file = await createOrphoFile(jsonData);

      final result = await decoder.importFromFile(file);

      expect(result.nom, equals('Animaux'));
      expect(result.couleur, equals('#2196F3'));
      expect(result.exportDate, equals('2026-04-19'));
      expect(result.words, hasLength(2));
      expect(result.words[0].mot, equals('chat'));
      expect(result.words[0].definition, equals('Animal domestique'));
      expect(result.words[1].mot, equals('chien'));
    });

    test('utilise la couleur par défaut si absente', () async {
      final jsonData = {
        'version': 1,
        'dictionary': {'nom': 'Test'},
        'words': [
          {'mot': 'alpha'},
        ],
      };
      final file = await createOrphoFile(jsonData);

      final result = await decoder.importFromFile(file);

      expect(result.couleur, equals('#6A5AE0'));
    });

    test('extrait les médias dans le répertoire de sortie', () async {
      // Crée un .orpho avec un fichier média
      final archive = Archive();
      final jsonData = {
        'version': 1,
        'dictionary': {'nom': 'Média', 'couleur': '#4CAF50'},
        'words': [
          {'mot': 'chat', 'image_path': 'media/chat.jpg'},
        ],
      };
      final jsonBytes = utf8.encode(jsonEncode(jsonData));
      archive
          .addFile(ArchiveFile('dictionary.json', jsonBytes.length, jsonBytes));

      final fakeImageBytes = [0xFF, 0xD8, 0xFF, 0xE0]; // En-tête JPEG
      archive.addFile(
        ArchiveFile('media/chat.jpg', fakeImageBytes.length, fakeImageBytes),
      );

      final zipData = ZipEncoder().encode(archive)!;
      final file = File('${tempDir.path}/media_test.orpho');
      await file.writeAsBytes(zipData);

      final mediaDir = '${tempDir.path}/extracted_media';
      final result = await decoder.importFromFile(
        file,
        mediaOutputDir: mediaDir,
      );

      expect(result.words[0].localImagePath, isNotNull);
      expect(await File(result.words[0].localImagePath!).exists(), isTrue);
    });

    test('lève une exception si le fichier n\'existe pas', () async {
      final fakeFile = File('${tempDir.path}/inexistant.orpho');
      expect(
        () => decoder.importFromFile(fakeFile),
        throwsException,
      );
    });

    test('lève une FormatException si dictionary.json manque', () async {
      // Crée un ZIP sans dictionary.json
      final archive = Archive();
      final fakeBytes = utf8.encode('dummy');
      archive.addFile(ArchiveFile('autre.txt', fakeBytes.length, fakeBytes));
      final zipData = ZipEncoder().encode(archive)!;
      final file = File('${tempDir.path}/invalid.orpho');
      await file.writeAsBytes(zipData);

      expect(
        () => decoder.importFromFile(file),
        throwsA(isA<FormatException>()),
      );
    });

    test('lève une FormatException si version trop élevée', () async {
      final jsonData = {
        'version': 999,
        'dictionary': {'nom': 'Futur'},
        'words': [],
      };
      final file = await createOrphoFile(jsonData);

      expect(
        () => decoder.importFromFile(file),
        throwsA(isA<FormatException>()),
      );
    });
  });

  // -------------------------------------------------------------------------
  // importFromCode
  // -------------------------------------------------------------------------
  group('importFromCode', () {
    test('décode un code ORPH- généré par le encoder', () {
      final code = encoder.generateQrCode(
        name: 'Animaux',
        wordList: ['chat', 'chien', 'vache'],
      )!;

      final result = decoder.importFromCode(code);

      expect(result.nom, equals('Animaux'));
      expect(result.words, hasLength(3));
      expect(result.words[0].mot, equals('chat'));
      expect(result.words[1].mot, equals('chien'));
      expect(result.words[2].mot, equals('vache'));
    });

    test('couleur par défaut pour import QR', () {
      final code = encoder.generateQrCode(
        name: 'Test',
        wordList: ['alpha'],
      )!;

      final result = decoder.importFromCode(code);
      expect(result.couleur, equals('#6A5AE0'));
    });

    test('lève une FormatException si pas de préfixe ORPH-', () {
      expect(
        () => decoder.importFromCode('INVALID-abcdef'),
        throwsA(isA<FormatException>()),
      );
    });

    test('lève une FormatException si base64 invalide', () {
      expect(
        () => decoder.importFromCode('ORPH-!!!invalidbase64!!!'),
        throwsA(isA<FormatException>()),
      );
    });

    test('lève une FormatException si données corrompues', () {
      // Base64 valide mais pas du GZip
      final fakeBase64 = base64Encode([1, 2, 3, 4, 5]);
      expect(
        () => decoder.importFromCode('ORPH-$fakeBase64'),
        throwsA(isA<FormatException>()),
      );
    });

    test('gère un dictionnaire avec une liste vide', () {
      final code = encoder.generateQrCode(name: 'Vide', wordList: [])!;
      final result = decoder.importFromCode(code);

      expect(result.nom, equals('Vide'));
      expect(result.words, isEmpty);
    });

    test('gère des espaces autour du code', () {
      final code = encoder.generateQrCode(
        name: 'Test',
        wordList: ['mot'],
      )!;

      // Ajoute des espaces
      final result = decoder.importFromCode('  $code  ');
      expect(result.nom, equals('Test'));
    });
  });

  // -------------------------------------------------------------------------
  // isValidOrphCode
  // -------------------------------------------------------------------------
  group('isValidOrphCode', () {
    test('retourne true pour un code valide', () {
      final code = encoder.generateQrCode(
        name: 'Test',
        wordList: ['chat'],
      )!;
      expect(decoder.isValidOrphCode(code), isTrue);
    });

    test('retourne false pour un code invalide', () {
      expect(decoder.isValidOrphCode('INVALID'), isFalse);
      expect(decoder.isValidOrphCode('ORPH-corrupted'), isFalse);
      expect(decoder.isValidOrphCode(''), isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Aller-retour complet (encoder → decoder)
  // -------------------------------------------------------------------------
  group('aller-retour', () {
    test('export .orpho puis import retourne les mêmes données', () async {
      final words = [
        {'mot': 'papillon', 'definition': 'Insecte aux ailes colorées'},
        {'mot': 'abeille', 'definition': 'Produit du miel'},
        {'mot': 'fourmi', 'definition': null},
      ];

      // Export
      final file = await encoder.exportToFile(
        name: 'Insectes',
        couleur: '#FF9800',
        words: words,
        outputDir: tempDir.path,
      );

      // Import
      final result = await decoder.importFromFile(file);

      expect(result.nom, equals('Insectes'));
      expect(result.couleur, equals('#FF9800'));
      expect(result.words, hasLength(3));
      expect(result.words[0].mot, equals('papillon'));
      expect(result.words[0].definition, equals('Insecte aux ailes colorées'));
      expect(result.words[2].mot, equals('fourmi'));
      expect(result.words[2].definition, isNull);
    });

    test('code ORPH- aller-retour préserve les mots', () {
      final mots = ['chat', 'chien', 'poisson', 'hamster'];
      final code = encoder.generateQrCode(
        name: 'Animaux domestiques',
        wordList: mots,
      )!;

      final result = decoder.importFromCode(code);

      expect(result.nom, equals('Animaux domestiques'));
      expect(
        result.words.map((w) => w.mot).toList(),
        equals(mots),
      );
    });
  });
}
