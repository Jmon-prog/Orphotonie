// ============================================================
// Fichier : lib/features/stats/praticien_stats_screen.dart
//
// Écran de suivi de la progression des patients.
// Liste tous les profils enfants et permet d'accéder au tableau de bord
// de chaque enfant (ProgressDashboardScreen).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../core/widgets/shimmer_list.dart';
import 'presentation/progress_dashboard_screen.dart';

/// Écran de suivi de progression — liste des enfants.
class PraticienStatsScreen extends ConsumerWidget {
  const PraticienStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(profilesDaoProvider);

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Progression des enfants',
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
        ],
      ),
      body: StreamBuilder<List<Profile>>(
        stream: dao.watchProfilesByType('enfant'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerListView();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final children = snapshot.data ?? [];
          if (children.isEmpty) {
            return const EmptyState(
              icon: Icons.child_care_outlined,
              title: 'Aucun enfant',
              description: 'Créez un profil enfant pour suivre sa progression.',
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: children.length,
                  itemBuilder: (context, i) => _ChildCard(child: children[i]),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: children.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _ChildCard(child: children[i]),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carte enfant
// ---------------------------------------------------------------------------

/// Carte affichant le prénom d'un enfant et un bouton vers son tableau de bord.
class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child});

  final Profile child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Voir la progression de ${child.prenom}',
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProgressDashboardScreen(
                profileId: child.id,
                childName: child.prenom,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ProfileAvatar(
                  profileId: child.id,
                  prenom: child.prenom,
                  avatarPath: child.avatarPath,
                  radius: 26,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        child.prenom,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (child.nom?.isNotEmpty == true)
                        Text(
                          child.nom!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
