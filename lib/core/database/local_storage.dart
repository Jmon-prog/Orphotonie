// ============================================================
// Fichier : lib/core/database/local_storage.dart
// Description : Initialisation du stockage local au 1er lancement.
//               Copie les bases SQLite embarquées (assets) vers le
//               répertoire documents de l'appareil. 100% hors ligne.
// ============================================================

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Gère la copie initiale des bases de données depuis les assets vers le disque.
class LocalStorage {
  LocalStorage._();

  // Noms des fichiers DB embarqués dans assets/data/
  static const _dbFiles = ['lexique4.db', 'definitions.db'];

  /// À appeler une seule fois dans main() avant runApp().
  static Future<void> init() async {
    // Web : les bases read-only sont chargées depuis les assets en mémoire WASM
    if (kIsWeb) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(docsDir.path, 'orphotonie', 'db'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }

    for (final dbName in _dbFiles) {
      final dest = File(p.join(dbDir.path, dbName));
      if (!dest.existsSync()) {
        // Copie depuis les assets (1er lancement uniquement)
        try {
          final data = await rootBundle.load('assets/data/$dbName');
          final bytes = data.buffer.asUint8List();
          await dest.writeAsBytes(bytes, flush: true);
        } catch (e) {
          // En cas d'erreur, on remonte une exception lisible
          throw Exception(
            'Impossible d\'initialiser la base $dbName : $e',
          );
        }
      }
    }
  }

  /// Retourne le chemin absolu d'une base de données sur le disque local.
  static Future<String> dbPath(String dbName) async {
    final docsDir = await getApplicationDocumentsDirectory();
    return p.join(docsDir.path, 'orphotonie', 'db', dbName);
  }
}
