// ============================================================
// Fichier : lib/core/database/connection/database_connection_native.dart
// Description : Connexion SQLite native (Android, iOS, Desktop).
//               Utilise dart:io + drift/native.dart + sqlite3_flutter_libs.
//               Ne jamais importer directement — passer par database_connection.dart.
// ============================================================

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Ouvre une base SQLite read-only depuis le répertoire documents (natif).
/// Le fichier doit avoir été copié par [DatabaseInitializer.init()].
Future<DatabaseConnection> openReadOnlyDb(String filename) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final file = File(p.join(docsDir.path, 'orphotonie', 'db', filename));
  if (!file.existsSync()) {
    throw StateError(
      '$filename introuvable — DatabaseInitializer.init() doit être appelé '
      'avant tout accès à cette base de données.',
    );
  }
  final executor = NativeDatabase(file, logStatements: false);
  return DatabaseConnection(executor);
}

/// Ouvre app.db depuis le répertoire documents (natif).
/// Utilise un thread d'arrière-plan pour éviter les blocages UI.
LazyDatabase openAppDb() {
  return LazyDatabase(() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(docsDir.path, 'orphotonie', 'db'));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    final file = File(p.join(dbDir.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
