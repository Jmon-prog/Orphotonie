// ============================================================
// Fichier : lib/core/sharing/share_encoder.dart
// Description : Encodeur de dictionnaires pour le partage hors ligne.
//               Génère des fichiers .orpho (ZIP) ou des codes ORPH- (QR).
//               Aucun accès réseau — tout est local.
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

/// Limite de mots pour le partage QR Code.
const kQrMaxWords = 30;

/// Limite de caractères pour le code ORPH- (compatibilité QR).
const kQrMaxChars = 2000;

/// Préfixe des codes texte courts (dictionnaire).
const kOrphPrefix = 'ORPH-';

/// Préfixe des codes stats.
const kOrphStatPrefix = 'ORPH-STAT-';

/// Version du format de partage.
const kShareFormatVersion = 1;

/// Schéma URI interne de l'application (deep link).
const kOrphScheme = 'orphotonie';

/// Hôte import dictionnaire.
const kOrphImportHost = 'import';

/// Hôte rapport de stats.
const kOrphStatsHost = 'stats';

/// Paramètre data dans les URLs de partage.
const kOrphDataParam = 'd';

/// Service d'encodage de dictionnaires pour le partage.
///
/// Deux formats :
/// - `.orpho` : archive ZIP contenant dictionary.json + médias optionnels.
/// - Code ORPH- : JSON minimal compressé GZip + Base64 (≤ 30 mots).
class ShareEncoder {
  /// Vérifie si un dictionnaire peut être partagé par QR Code.
  bool canUseQrCode(int wordCount) => wordCount <= kQrMaxWords;

  /// Exporte un dictionnaire en fichier `.orpho` (archive ZIP).
  ///
  /// [name] : nom du dictionnaire.
  /// [couleur] : couleur hexadécimale (#RRGGBB).
  /// [words] : liste des mots avec définitions et chemins médias.
  /// [outputDir] : répertoire de sortie pour le fichier .orpho.
  /// [includeDefinitions] : inclure les définitions dans l'export.
  /// [includeMedia] : inclure les images/audios dans l'archive.
  Future<File> exportToFile({
    required String name,
    required String couleur,
    required List<Map<String, dynamic>> words,
    required String outputDir,
    bool includeDefinitions = true,
    bool includeMedia = false,
  }) async {
    final archive = Archive();

    // Prépare la liste des mots pour le JSON
    final jsonWords = <Map<String, dynamic>>[];
    for (final word in words) {
      final entry = <String, dynamic>{
        'mot': word['mot'],
      };
      if (includeDefinitions && word['definition'] != null) {
        entry['definition'] = word['definition'];
      }

      // Gestion des médias
      if (includeMedia) {
        final imagePath = word['imagePath'] as String?;
        if (imagePath != null && imagePath.isNotEmpty) {
          final imageFile = File(imagePath);
          if (await imageFile.exists()) {
            final fileName = p.basename(imagePath);
            final mediaPath = 'media/$fileName';
            final bytes = await imageFile.readAsBytes();
            archive.addFile(ArchiveFile(mediaPath, bytes.length, bytes));
            entry['image_path'] = mediaPath;
          }
        }
        final audioPath = word['audioPath'] as String?;
        if (audioPath != null && audioPath.isNotEmpty) {
          final audioFile = File(audioPath);
          if (await audioFile.exists()) {
            final fileName = p.basename(audioPath);
            final mediaPath = 'media/$fileName';
            final bytes = await audioFile.readAsBytes();
            archive.addFile(ArchiveFile(mediaPath, bytes.length, bytes));
            entry['audio_path'] = mediaPath;
          }
        }
      }

      jsonWords.add(entry);
    }

    // Construit le JSON principal
    final jsonData = {
      'version': kShareFormatVersion,
      'export_date': DateTime.now().toIso8601String().substring(0, 10),
      'dictionary': {
        'nom': name,
        'couleur': couleur,
      },
      'words': jsonWords,
    };

    final jsonBytes =
        utf8.encode(const JsonEncoder.withIndent('  ').convert(jsonData));
    archive
        .addFile(ArchiveFile('dictionary.json', jsonBytes.length, jsonBytes));

    // Encode l'archive ZIP
    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception('Erreur lors de la création de l\'archive ZIP.');
    }

    // Écrit le fichier .orpho
    final safeFileName = name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    final outputFile = File(p.join(outputDir, '$safeFileName.orpho'));
    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsBytes(zipData);

    return outputFile;
  }

  /// Génère un code ORPH- court pour partage par QR Code ou texte.
  ///
  /// Limité à [kQrMaxWords] mots et [kQrMaxChars] caractères.
  /// Retourne `null` si le code dépasse la limite de caractères.
  ///
  /// [name] : nom du dictionnaire.
  /// [wordList] : liste des mots (chaînes uniquement).
  String? generateQrCode({
    required String name,
    required List<String> wordList,
  }) {
    if (wordList.length > kQrMaxWords) return null;

    // JSON minimal
    final jsonData = {
      'v': kShareFormatVersion,
      'n': name,
      'w': wordList,
    };

    final jsonString = jsonEncode(jsonData);
    final gzipped = GZipEncoder().encode(utf8.encode(jsonString))!;
    final base64String = base64Encode(gzipped);
    final code = '$kOrphPrefix$base64String';

    if (code.length > kQrMaxChars) return null;

    return code;
  }

  /// Calcule la taille estimée du code ORPH- sans le générer complètement.
  int estimateQrCodeLength({
    required String name,
    required List<String> wordList,
  }) {
    final code = generateQrCode(name: name, wordList: wordList);
    return code?.length ?? -1;
  }

  // ---------------------------------------------------------------------------
  // URL de partage (deep link orphotonie://)
  // ---------------------------------------------------------------------------

  /// Génère une URL de partage `orphotonie://import?d=ORPH-...`.
  ///
  /// Fonctionne quel que soit la taille du dictionnaire (pas de limite QR).
  /// L'URL peut être copiée dans un SMS, un e-mail ou une messagerie.
  /// Sur mobile, elle ouvre directement l'écran d'import de l'application.
  ///
  /// [orphCode] : code ORPH- généré par [generateQrCode] ou depuis un
  ///   export complet (non limité).
  String generateShareUrl(String orphCode) {
    return Uri(
      scheme: kOrphScheme,
      host: kOrphImportHost,
      queryParameters: {kOrphDataParam: orphCode},
    ).toString();
  }

  /// Génère un code ORPH- complet (sans limite de longueur) pour usage URL.
  ///
  /// Contrairement à [generateQrCode], ne limite pas à [kQrMaxWords].
  /// Retourne le code ORPH- et l'URL correspondante.
  ({String code, String url}) generateUrlCode({
    required String name,
    required List<String> wordList,
    bool includeDefinitions = false,
    List<Map<String, dynamic>>? wordsWithDefs,
  }) {
    final Map<String, dynamic> jsonData;

    if (includeDefinitions && wordsWithDefs != null) {
      // Format étendu avec définitions
      jsonData = {
        'v': kShareFormatVersion,
        'n': name,
        'w': wordsWithDefs
            .map(
              (w) => {
                'm': w['mot'],
                if (w['definition'] != null &&
                    (w['definition'] as String).isNotEmpty)
                  'd': w['definition'],
              },
            )
            .toList(),
      };
    } else {
      // Format minimal (mots seulement)
      jsonData = {
        'v': kShareFormatVersion,
        'n': name,
        'w': wordList,
      };
    }

    final jsonString = jsonEncode(jsonData);
    final gzipped = GZipEncoder().encode(utf8.encode(jsonString))!;
    final base64String = base64Encode(gzipped);
    final code = '$kOrphPrefix$base64String';
    final url = generateShareUrl(code);

    return (code: code, url: url);
  }
}
