// ============================================================
// Fichier : lib/features/home/praticien_accueil_screen.dart
//
// Écran d'accueil de l'espace praticien.
// Tableau de bord — accès rapide aux fonctions principales
// et compteurs de profils/sessions.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/notifiers/auth_notifier.dart';
//import '../../core/database/app_database.dart' show Profile;
import '../../core/database/database_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/profile_avatar.dart';

// ---------------------------------------------------------------------------
// Provider — compteur de profils enfants
// ---------------------------------------------------------------------------

final _childCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(profilesDaoProvider)
      .watchProfilesByType('enfant')
      .map((list) => list.length);
});

// ---------------------------------------------------------------------------
// Écran
// ---------------------------------------------------------------------------

/// Écran d'accueil du praticien — tableau de bord.
class PraticienAccueilScreen extends ConsumerWidget {
  const PraticienAccueilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childCountAsync = ref.watch(_childCountProvider);
    final childCount = childCountAsync.valueOrNull ?? 0;

    // Récupère le profil du praticien connecté pour les routes nécessitant un profileId
    final auth = ref.watch(authNotifierProvider);
    final praticienId = auth is PractitionerAuth ? auth.profile.id : 0;
    final praticienPrenom =
        auth is PractitionerAuth ? auth.profile.prenom : 'Gestionnaire';

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Accueil',
        actions: [
          Semantics(
            label: 'Paramètres',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Paramètres',
              onPressed: () => context.go(AppRoutes.parametres),
            ),
          ),
          Semantics(
            label: 'Se déconnecter',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Déconnexion',
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                context.go(AppRoutes.profiles);
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ----- En-tête -----
                    Row(
                      children: [
                        ProfileAvatar(
                          profileId: praticienId,
                          prenom: praticienPrenom,
                          radius: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Espace Gestionnaire',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Gestion des profils et des jeux',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ----- Compteur enfants -----
                    Card(
                      color: colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.child_care,
                              size: 36,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$childCount profil${childCount > 1 ? 's' : ''} enfant${childCount > 1 ? 's' : ''}',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    childCount == 0
                                        ? 'Créez un profil pour commencer'
                                        : 'Suivez leur progression depuis "Stats"',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ----- Accès rapide -----
                    Text(
                      'Accès rapide',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 5 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.3 : 1.15,
                      children: [
                        _QuickCard(
                          icon: Icons.menu_book,
                          color: colorScheme.primary,
                          label: 'Dictionnaires',
                          onTap: () =>
                              context.go(AppRoutes.praticienDictionnaires),
                        ),
                        _QuickCard(
                          icon: Icons.assignment_outlined,
                          color: Colors.teal,
                          label: 'Fiches',
                          onTap: () => context.go(AppRoutes.praticienJeux),
                        ),
                        _QuickCard(
                          icon: Icons.bar_chart,
                          color: Colors.orange,
                          label: 'Progression',
                          onTap: () => context.go(AppRoutes.praticienStats),
                        ),
                        _QuickCard(
                          icon: Icons.qr_code_scanner_rounded,
                          color: Colors.teal,
                          label: 'Importer',
                          onTap: () => context.push(
                            '${AppRoutes.importDic}?profileId=$praticienId',
                          ),
                        ),
                        _QuickCard(
                          icon: Icons.help_outline,
                          color: Colors.indigo,
                          label: 'Aide',
                          onTap: () => context.go(AppRoutes.aide),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ----- Rappel si aucun enfant -----
                    if (childCount == 0)
                      Card(
                        color: colorScheme.secondaryContainer,
                        child: ListTile(
                          leading: Icon(
                            Icons.person_add_outlined,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          title: Text(
                            'Aucun profil enfant',
                            style: TextStyle(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Ajoutez un enfant depuis l\'écran de sélection',
                            style: TextStyle(
                              color: colorScheme.onSecondaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carte d'accès rapide
// ---------------------------------------------------------------------------

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Card(
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 26, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
