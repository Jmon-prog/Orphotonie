// ============================================================
// Fichier : lib/features/auth/screens/create_practitioner_screen.dart
// Description : Création de l'espace Gestionnaire (profil unique, sans nom).
//               Aucun PIN requis à la création — configurable depuis Paramètres.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_bar.dart';

class CreatePractitionerScreen extends ConsumerStatefulWidget {
  const CreatePractitionerScreen({super.key});

  @override
  ConsumerState<CreatePractitionerScreen> createState() =>
      _CreatePractitionerScreenState();
}

class _CreatePractitionerScreenState
    extends ConsumerState<CreatePractitionerScreen> {
  bool _isLoading = false;

  Future<void> _create() async {
    setState(() => _isLoading = true);
    try {
      final dao = ref.read(profilesDaoProvider);
      await dao.insertProfile(
        const ProfilesCompanion(
          prenom: Value('Gestionnaire'),
          type: Value('praticien'),
        ),
      );
      if (!mounted) return;
      context.go(AppRoutes.profiles);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la création : $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Espace Gestionnaire',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.manage_accounts_outlined,
                  size: 72,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Créer l\'espace Gestionnaire',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Cet espace permet de gérer les profils enfants, '
                  'les dictionnaires et les jeux.\n\n'
                  'Un code PIN optionnel peut être activé depuis les '
                  'Paramètres pour protéger l\'accès.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Semantics(
                  label: 'Créer l\'espace Gestionnaire',
                  button: true,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _create,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: const Text('Créer l\'espace'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
