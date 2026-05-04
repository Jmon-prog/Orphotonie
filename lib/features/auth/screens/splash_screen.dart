// ============================================================
// Fichier : lib/features/auth/screens/splash_screen.dart
// Description : Écran de démarrage — initialise les bases de données
//               puis redirige selon la présence de profils.
//               Affiché < 2 s, aucun contenu utilisateur.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/storage/database_initializer.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/router/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // Copie les bases depuis les assets si premier lancement
      await DatabaseInitializer.init();

      if (!mounted) return;

      // Vérifie si des profils existent déjà
      final dao = ref.read(profilesDaoProvider);
      final profiles = await dao.watchAllProfiles().first;

      if (!mounted) return;

      if (profiles.isEmpty) {
        // Premier lancement → création du premier praticien
        context.go(AppRoutes.newPractitioner);
      } else {
        // Des profils existent → sélection
        context.go(AppRoutes.profiles);
      }
    } catch (e) {
      if (!mounted) return;
      // Affiche une erreur lisible à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'initialisation : $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / icône de l'application
            const Text(
              '🦜',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              'Orphotonie',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
