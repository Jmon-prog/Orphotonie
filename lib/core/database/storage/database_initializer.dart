// ============================================================
// Fichier : lib/core/database/storage/database_initializer.dart
// Description : Initialisation du stockage local au 1er lancement.
//               Copie lexique4.db et definitions.db depuis les assets
//               Flutter vers le répertoire documents (native uniquement).
//               Sur web : les bases sont chargées directement depuis
//               les assets via WASM — aucune copie nécessaire.
//               Ne recopie jamais si les fichiers existent déjà.
// ============================================================

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Gère la copie initiale des bases de données embarquées.
/// À appeler une seule fois dans main() avant runApp().
class DatabaseInitializer {
  DatabaseInitializer._();

  /// Noms des bases de données embarquées dans assets/data/.
  static const _assetDbs = [
    'lexique4.db', // 0,71 Mo — Lexique 4 allégé (read-only)
    'definitions.db', // 1,27 Mo — Dubois-Buyse (read-only)
  ];

  /// Initialise le répertoire DB et copie les bases si nécessaire.
  /// Sur web : sans effet (les bases sont chargées via WASM directement).
  /// Lance une [Exception] lisible en cas d'échec, jamais un crash silencieux.
  static Future<void> init() async {
    // Web : les bases read-only sont chargées depuis les assets en mémoire WASM
    if (kIsWeb) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(docsDir.path, 'orphotonie', 'db'));

    // Crée le répertoire si absent (premier lancement)
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }

    for (final dbName in _assetDbs) {
      final dest = File(p.join(dbDir.path, dbName));

      // Ne recopie jamais si le fichier existe déjà
      if (dest.existsSync()) continue;

      try {
        final data = await rootBundle.load('assets/data/$dbName');
        final bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await dest.writeAsBytes(bytes, flush: true);
      } catch (e, st) {
        throw Exception(
          'Impossible d\'initialiser la base $dbName.\n'
          'Détail : $e\n$st',
        );
      }
    }
  }

  /// Retourne le chemin absolu d'une base dans le répertoire documents.
  static Future<String> dbPath(String dbName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, 'orphotonie', 'db', dbName);
  }

  /// Supprime les bases copiées (utile pour les tests ou réinitialisation).
  /// ⚠️ Ne supprime jamais app.db pour éviter la perte de données.
  static Future<void> resetReadOnlyDbs() async {
    final docsDir = await getApplicationDocumentsDirectory();
    for (final dbName in _assetDbs) {
      final file = File(p.join(docsDir.path, 'orphotonie', 'db', dbName));
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
}
