// ============================================================
// Fichier : lib/features/auth/screens/profile_selection_screen.dart
// Description : Écran de sélection de profil (enfants + accès praticien).
//               Responsive : 2 col mobile, 3 col tablette, 4 col desktop.
//               Semantics sur chaque avatar pour l'accessibilité.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/shimmer_list.dart';
import '../notifiers/auth_notifier.dart';
import '../services/pin_service.dart';

class ProfileSelectionScreen extends ConsumerWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesStream =
        ref.watch(profilesDaoProvider).watchProfilesByType('enfant');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Icône + titre
            Semantics(
              label: 'Orphotonie',
              image: true,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/images/launcher_icon.png',
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Orphotonie',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Qui joue aujourd\'hui ?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 32),

            // Grille de profils enfants
            Expanded(
              child: StreamBuilder<List<Profile>>(
                stream: profilesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ShimmerGridView(itemCount: 4);
                  }
                  final profiles = snapshot.data ?? [];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive : colonnes selon largeur
                      final crossAxisCount = switch (constraints.maxWidth) {
                        > 900 => 4,
                        > 600 => 3,
                        _ => 2,
                      };

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: profiles.length + 1, // +1 pour "Ajouter"
                        itemBuilder: (context, index) {
                          if (index == profiles.length) {
                            return _AddProfileCard(
                              onTap: () => context.go(AppRoutes.newChild),
                            );
                          }
                          return _ProfileCard(
                            profile: profiles[index],
                            onTap: () {
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .selectChild(profiles[index]);
                              context.go(AppRoutes.childHome);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Bouton accès praticien
            Padding(
              padding: const EdgeInsets.all(24),
              child: Semantics(
                label: 'Accès espace gestionnaire',
                child: OutlinedButton.icon(
                  onPressed: () => _showPractitionerSelection(context, ref),
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: const Text('Espace Gestionnaire'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Accède à l'espace Gestionnaire — PIN si configuré, sinon accès direct.
  Future<void> _showPractitionerSelection(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final dao = ref.read(profilesDaoProvider);
    final practitioners = await dao.watchProfilesByType('praticien').first;

    if (!context.mounted) return;

    if (practitioners.isEmpty) {
      context.go(AppRoutes.newPractitioner);
      return;
    }

    final profile = practitioners.first;
    final hasPin = await ref.read(pinServiceProvider).hasPin();
    if (!context.mounted) return;

    if (hasPin) {
      // PIN configuré → écran de saisie
      ref.read(authNotifierProvider.notifier).requestPinFor(profile);
      context.go(AppRoutes.pin);
    } else {
      // Aucun PIN → accès direct
      ref.read(authNotifierProvider.notifier).directLoginGestionnaire(profile);
      context.go(AppRoutes.praticienAccueil);
    }
  }
}

// ---------------------------------------------------------------------------
// Widgets internes
// ---------------------------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onTap});
  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Profil de ${profile.prenom}',
      button: true,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar emoji (si défini) ou initiale du prénom
              ProfileAvatar(
                profileId: profile.id,
                prenom: profile.prenom,
                avatarPath: profile.avatarPath,
                radius: 36,
                useHero:
                    false, // Pas de Hero ici : l'écran enfant n'a pas de destinataire correspondant
              ),
              const SizedBox(height: 12),
              Text(
                profile.prenom,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddProfileCard extends StatelessWidget {
  const _AddProfileCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ajouter un profil enfant',
      button: true,
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              const SizedBox(height: 12),
              Text(
                'Ajouter',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
