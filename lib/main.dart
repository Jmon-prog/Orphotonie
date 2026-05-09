// ============================================================
// Fichier : lib/main.dart
// Description : Point d'entrée de l'application Orphotonie.
//               Initialise le stockage local, la base app.db et
//               démarre le routeur. 100% hors ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/audio/audio_providers.dart';
import 'core/database/storage/database_initializer.dart';
import 'core/layout/window_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Copie les DB embarquées vers documents au 1er lancement (hors ligne)
  await DatabaseInitializer.init();

  // Configure la fenêtre desktop (taille minimale 800×600, titre)
  await WindowConfig.init();

  runApp(
    // ProviderScope requis par Riverpod
    const ProviderScope(
      child: OrphothonieApp(),
    ),
  );
}

/// Widget racine de l'application Orphotonie.
class OrphothonieApp extends ConsumerWidget {
  const OrphothonieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(appThemeProvider);
    final light = ref.watch(lightThemeProvider);
    final dark = ref.watch(darkThemeProvider);

    // Déclenche l'initialisation du moteur TTS local (eSpeak NG) au démarrage.
    // Sans ce watch, tts.init() n'est jamais appelé et _available reste false.
    ref.watch(ttsInitProvider);

    return MaterialApp.router(
      title: 'Orphotonie',
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: themeState.themeMode,
      routerConfig: router,
    );
  }
}
