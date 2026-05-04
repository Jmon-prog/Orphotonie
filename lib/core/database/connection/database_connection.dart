// ============================================================
// Fichier : lib/core/database/connection/database_connection.dart
// Description : Hub d'export conditionnel — native vs web.
//               Sélectionne l'implémentation de connexion SQLite
//               selon la plateforme de compilation.
// ============================================================

export 'database_connection_native.dart'
    if (dart.library.js_interop) 'database_connection_web.dart';
