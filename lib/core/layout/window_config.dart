// ============================================================
// Fichier : lib/core/layout/window_config.dart
//
// Configuration de la fenêtre desktop (Windows / macOS / Linux).
// Définit la taille minimale et le titre de la fenêtre via le
// package window_manager.
//
// Appelé dans main() avant runApp() sur les plateformes desktop.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Configure la fenêtre native sur les plateformes desktop.
///
/// - Taille minimale : 800×600 dp
/// - Titre : 'Orphotonie'
///
/// Doit être appelé avant [runApp] :
/// ```dart
/// await WindowConfig.init();
/// runApp(const OrphothonieApp());
/// ```
abstract final class WindowConfig {
  /// Initialise la configuration de la fenêtre desktop.
  /// Sans effet sur Android, iOS et web.
  static Future<void> init() async {
    // Web : pas de gestion de fenêtre native
    if (kIsWeb) return;
    // Uniquement sur les plateformes desktop
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return;
    }

    await windowManager.ensureInitialized();

    const options = WindowOptions(
      minimumSize: Size(800, 600),
      title: 'Orphotonie',
      center: true,
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
