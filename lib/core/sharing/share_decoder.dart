// ============================================================
// Fichier : lib/core/sharing/share_decoder.dart
// Description : Décodeur de dictionnaires partagés.
//               Importe depuis un fichier .orpho (ZIP) ou un code ORPH-.
//               Aucun accès réseau — tout est local.
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'share_encoder.dart';

/// Résultat du décodage d'un dictionnaire partagé.
class SharedDictionaryData {
  SharedDictionaryData({
    required this.nom,
    required this.couleur,
    required this.words,
    this.exportDate,
  });

  /// Nom du dictionnaire importé.
  final String nom;

  /// Couleur hexadécimale du dictionnaire (#RRGGBB).
  final String couleur;

  /// Date d'export d'origine (YYYY-MM-DD).
  final String? exportDate;

  /// Liste des mots importés.
  final List<SharedWordData> words;
}

/// Données d'un mot importé.
class SharedWordData {
  SharedWordData({
    required this.mot,
    this.definition,
    this.localImagePath,
    this.localAudioPath,
  });

  /// Le mot orthographié.
  final String mot;

  /// Définition (si incluse dans l'export).
  final String? definition;

  /// Chemin local de l'image après extraction (null si pas de média).
  final String? localImagePath;

  /// Chemin local de l'audio après extraction (null si pas de média).
  final String? localAudioPath;
}

/// Service de décodage de dictionnaires partagés.
class ShareDecoder {
  /// Importe un dictionnaire depuis un fichier `.orpho` (archive ZIP).
  ///
  /// [file] : fichier .orpho à importer.
  /// [mediaOutputDir] : répertoire où extraire les médias.
  ///   Si null, les médias ne sont pas extraits.
  Future<SharedDictionaryData> importFromFile(
    File file, {
    String? mediaOutputDir,
  }) async {
    if (!await file.exists()) {
      throw Exception('Le fichier n\'existe pas : ${file.path}');
    }

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Recherche du fichier dictionary.json
    final jsonFile = archive.findFile('dictionary.json');
    if (jsonFile == null) {
      throw const FormatException(
        'Fichier .orpho invalide : dictionary.json manquant.',
      );
    }

    final jsonString = utf8.decode(jsonFile.content as List<int>);
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    // Validation de la version
    final version = jsonData['version'] as int?;
    if (version == null || version > kShareFormatVersion) {
      throw FormatException(
        'Version du format non supportée : $version '
        '(max: $kShareFormatVersion).',
      );
    }

    final dictData = jsonData['dictionary'] as Map<String, dynamic>;
    final wordsJson = jsonData['words'] as List<dynamic>;
    final exportDate = jsonData['export_date'] as String?;

    // Extraction des médias si répertoire fourni
    final words = <SharedWordData>[];
    for (final wordJson in wordsJson) {
      final wordMap = wordJson as Map<String, dynamic>;
      String? localImagePath;
      String? localAudioPath;

      if (mediaOutputDir != null) {
        // Image
        final imagePath = wordMap['image_path'] as String?;
        if (imagePath != null) {
          final mediaFile = archive.findFile(imagePath);
          if (mediaFile != null) {
            final outputPath = p.join(mediaOutputDir, p.basename(imagePath));
            final outFile = File(outputPath);
            await outFile.parent.create(recursive: true);
            await outFile.writeAsBytes(mediaFile.content as List<int>);
            localImagePath = outputPath;
          }
        }
        // Audio
        final audioPath = wordMap['audio_path'] as String?;
        if (audioPath != null) {
          final mediaFile = archive.findFile(audioPath);
          if (mediaFile != null) {
            final outputPath = p.join(mediaOutputDir, p.basename(audioPath));
            final outFile = File(outputPath);
            await outFile.parent.create(recursive: true);
            await outFile.writeAsBytes(mediaFile.content as List<int>);
            localAudioPath = outputPath;
          }
        }
      }

      words.add(
        SharedWordData(
          mot: wordMap['mot'] as String,
          definition: wordMap['definition'] as String?,
          localImagePath: localImagePath,
          localAudioPath: localAudioPath,
        ),
      );
    }

    return SharedDictionaryData(
      nom: dictData['nom'] as String,
      couleur: dictData['couleur'] as String? ?? '#6A5AE0',
      exportDate: exportDate,
      words: words,
    );
  }

  /// Importe un dictionnaire depuis un code ORPH- (QR Code ou texte copié).
  ///
  /// [code] : code commençant par "ORPH-".
  SharedDictionaryData importFromCode(String code) {
    final trimmed = code.trim();
    if (!trimmed.startsWith(kOrphPrefix)) {
      throw const FormatException(
        'Code invalide : doit commencer par "ORPH-".',
      );
    }

    final base64String = trimmed.substring(kOrphPrefix.length);

    List<int> gzipped;
    try {
      gzipped = base64Decode(base64String);
    } catch (_) {
      throw const FormatException('Code ORPH- invalide : base64 corrompu.');
    }

    String jsonString;
    try {
      jsonString = utf8.decode(GZipDecoder().decodeBytes(gzipped));
    } catch (_) {
      throw const FormatException(
        'Code ORPH- invalide : données compressées corrompues.',
      );
    }

    Map<String, dynamic> jsonData;
    try {
      jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Code ORPH- invalide : JSON malformé.');
    }

    // Validation version
    final version = jsonData['v'] as int?;
    if (version == null || version > kShareFormatVersion) {
      throw FormatException(
        'Version du code non supportée : $version.',
      );
    }

    final name = jsonData['n'] as String? ?? 'Dictionnaire importé';
    final rawWords = jsonData['w'] as List<dynamic>? ?? [];

    // Supporte le format minimal (liste de strings) et le format étendu
    // (liste d'objets {m: mot, d: définition}) généré par generateUrlCode().
    final words = rawWords.map((e) {
      if (e is String) return SharedWordData(mot: e);
      final map = e as Map<String, dynamic>;
      return SharedWordData(
        mot: map['m'] as String? ?? map['mot'] as String? ?? '',
        definition: map['d'] as String? ?? map['definition'] as String?,
      );
    }).toList();

    return SharedDictionaryData(
      nom: name,
      couleur: '#6A5AE0', // Couleur par défaut (non incluse dans le QR)
      words: words,
    );
  }

  /// Extrait le code ORPH- d'une URL `orphotonie://import?d=ORPH-...`.
  ///
  /// Retourne le code ORPH- si l'URL est valide, `null` sinon.
  String? extractCodeFromUrl(String url) {
    try {
      final trimmed = url.trim();
      final uri = Uri.parse(trimmed);
      if (uri.scheme == kOrphScheme && uri.host == kOrphImportHost) {
        final d = uri.queryParameters[kOrphDataParam];
        if (d != null && d.startsWith(kOrphPrefix)) return d;
      }
    } catch (_) {}
    return null;
  }

  /// Normalise une saisie utilisateur : URL ou code brut.
  ///
  /// Accepte :
  /// - `orphotonie://import?d=ORPH-...`  → extrait le code
  /// - `ORPH-...`                        → retourne tel quel
  /// - Tout autre texte                  → retourne tel quel (erreur différée)
  String normalizeInput(String input) {
    final fromUrl = extractCodeFromUrl(input);
    return fromUrl ?? input.trim();
  }

  /// Vérifie si une chaîne est un code ORPH- valide.
  bool isValidOrphCode(String code) {
    try {
      importFromCode(code);
      return true;
    } catch (_) {
      return false;
    }
  }
}
