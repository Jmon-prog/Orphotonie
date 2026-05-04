// ============================================================
// Fichier : lib/core/database/connection/database_connection_web.dart
// Description : Connexion SQLite web via WASM.
//               Remplace dart:io + drift/native.dart pour Flutter web.
//               - Bases read-only : chargées depuis assets en mémoire (InMemoryFileSystem).
//               - app.db : persistance via IndexedDB (IndexedDbFileSystem).
//               Ne jamais importer directement — passer par database_connection.dart.
// ============================================================

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqlite3/wasm.dart';
import 'package:typed_data/typed_buffers.dart';

/// Singleton sqlite3 WASM (chargé une seule fois depuis sqlite3.wasm).
WasmSqlite3? _sqlite3;

Future<WasmSqlite3> _getSqlite3() async {
  _sqlite3 ??= await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  return _sqlite3!;
}

/// Ouvre une base SQLite read-only depuis les assets Flutter (web).
///
/// Le fichier SQLite est chargé en mémoire via [InMemoryFileSystem].
/// Pas de persistance : rechargé depuis les assets à chaque démarrage.
/// Adapté aux petites bases (lexique4.db ≈ 0,71 Mo, definitions.db ≈ 1,27 Mo).
Future<DatabaseConnection> openReadOnlyDb(String filename) async {
  final sqlite3 = await _getSqlite3();

  // Charger les bytes du fichier SQLite depuis les assets Flutter
  final data = await rootBundle.load('assets/data/$filename');
  final bytes = data.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );

  // Créer un VFS en mémoire avec un nom unique pour éviter les conflits
  final vfsName = 'memvfs-${filename.replaceAll('.', '-')}';
  final memFs = InMemoryFileSystem(name: vfsName);

  // Écrire les bytes dans le VFS
  final buffer = Uint8Buffer()..addAll(bytes);
  memFs.fileData['/$filename'] = buffer;

  // Enregistrer le VFS auprès de l'instance sqlite3 WASM
  sqlite3.registerVirtualFileSystem(memFs, makeDefault: false);

  // Ouvrir la base depuis le VFS en mémoire (lecture/écriture pour que
  // Drift puisse gérer user_version — les écritures restent en mémoire)
  final rawDb = sqlite3.open('/$filename', vfs: vfsName);
  return DatabaseConnection(WasmDatabase.opened(rawDb));
}

/// Ouvre app.db avec persistance IndexedDB (web).
///
/// Les données utilisateur survivent aux rechargements de page grâce à
/// [IndexedDbFileSystem]. Fonctionne sans web worker dédié.
LazyDatabase openAppDb() {
  return LazyDatabase(() async {
    final sqlite3 = await _getSqlite3();

    // IndexedDB comme VFS persistant — enregistré comme VFS par défaut
    final fileSystem = await IndexedDbFileSystem.open(
      dbName: 'orphotonie',
    );
    sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);

    return WasmDatabase(
      sqlite3: sqlite3,
      path: '/app.db',
      fileSystem: fileSystem,
    );
  });
}
