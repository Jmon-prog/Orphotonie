// ============================================================
// Fichier : lib/core/layout/adaptive_scaffold.dart
//
// Scaffold adaptatif principal de l'application Orphotonie.
// Bascule automatiquement entre :
//   - NavigationBar en bas (compact < 600 dp)
//   - NavigationRail latéral icônes seules (medium 600–839 dp)
//   - Drawer permanent latéral avec libellés (expanded+ ≥ 840 dp)
//
// Intégré via StatefulShellRoute de go_router pour conserver
// l'état des branches de navigation.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../../features/auth/notifiers/auth_notifier.dart';
import 'breakpoints.dart';
import 'adaptive_navigation.dart';

/// Scaffold principal adaptatif de l'espace praticien.
///
/// Doit être utilisé avec [StatefulShellRoute.indexedStack] de go_router :
/// ```dart
/// StatefulShellRoute.indexedStack(
///   builder: (ctx, state, shell) => OrphoAdaptiveScaffold(navigationShell: shell),
///   branches: [...],
/// )
/// ```
class OrphoAdaptiveScaffold extends ConsumerWidget {
  const OrphoAdaptiveScaffold({
    required this.navigationShell,
    super.key,
  });

  /// Shell de navigation fourni par go_router (StatefulShellRoute).
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Retour à l'emplacement initial de la branche si déjà sélectionnée
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = Breakpoints.of(context);
    final isLandscapePhone = Breakpoints.isLandscapePhone(context);

    // Téléphone en paysage → Rail (comme medium)
    if (screenSize == ScreenSize.compact && !isLandscapePhone) {
      return _CompactScaffold(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        body: navigationShell,
        ref: ref,
      );
    }

    if (Breakpoints.useRail(context)) {
      return _MediumScaffold(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        body: navigationShell,
        isLandscapePhone: isLandscapePhone,
        ref: ref,
      );
    }

    // expanded, large, extraLarge → Drawer permanent
    return _ExpandedScaffold(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: _onDestinationSelected,
      body: navigationShell,
      ref: ref,
    );
  }
}

// ---------------------------------------------------------------------------
// Compact — NavigationBar en bas
// ---------------------------------------------------------------------------

class _CompactScaffold extends StatelessWidget {
  const _CompactScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    required this.ref,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: buildNavigationBarDestinations(kPraticienDestinations),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Medium — NavigationRail latéral (icônes seules)
// ---------------------------------------------------------------------------

class _MediumScaffold extends StatelessWidget {
  const _MediumScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    required this.isLandscapePhone,
    required this.ref,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final bool isLandscapePhone;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations:
                buildNavigationRailDestinations(kPraticienDestinations),
            // Icônes seules en medium (labels masqués)
            labelType: NavigationRailLabelType.none,
            // En paysage sur téléphone, compacter le rail
            minWidth: isLandscapePhone ? 52 : 72,
            leading: isLandscapePhone
                ? null
                : const SizedBox(height: 8), // espace au-dessus des icônes
            trailing: Semantics(
              label: 'Paramètres',
              child: IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Paramètres',
                onPressed: () => context.go(AppRoutes.parametres),
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expanded / Large / ExtraLarge — Drawer permanent latéral (200–280 dp)
// ---------------------------------------------------------------------------

class _ExpandedScaffold extends StatelessWidget {
  const _ExpandedScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    required this.ref,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Row(
        children: [
          // ── Drawer permanent ──
          SizedBox(
            width: 240,
            child: Material(
              color: colorScheme.surface,
              elevation: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête du drawer
                  _DrawerHeader(colorScheme: colorScheme, textTheme: textTheme),

                  // Destinations principales
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: kPraticienDestinations.length,
                      itemBuilder: (context, i) {
                        final dest = kPraticienDestinations[i];
                        final selected = i == selectedIndex;
                        return Semantics(
                          label: dest.semanticLabel,
                          selected: selected,
                          child: ListTile(
                            selected: selected,
                            selectedTileColor: colorScheme.secondaryContainer,
                            leading: Icon(
                              selected ? dest.selectedIcon : dest.icon,
                              color: selected
                                  ? colorScheme.onSecondaryContainer
                                  : null,
                            ),
                            title: Text(
                              dest.label,
                              style: textTheme.labelLarge?.copyWith(
                                color: selected
                                    ? colorScheme.onSecondaryContainer
                                    : null,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            onTap: () => onDestinationSelected(i),
                          ),
                        );
                      },
                    ),
                  ),

                  // Section basse : profil actif + déconnexion
                  _DrawerFooter(ref: ref),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),

          // ── Corps principal ──
          Expanded(child: body),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Composants internes du drawer permanent
// ---------------------------------------------------------------------------

/// En-tête du drawer — logo + nom de l'application.
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Icon(
            Icons.record_voice_over,
            size: 32,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Orphotonie',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pied de page du drawer — profil praticien connecté + déconnexion.
class _DrawerFooter extends ConsumerWidget {
  const _DrawerFooter({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final profile = switch (auth) {
      PractitionerAuth(profile: final p) => p,
      _ => null,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        // Lien Paramètres
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Semantics(
            label: 'Paramètres',
            child: ListTile(
              leading: const Icon(Icons.settings_outlined, size: 20),
              title: const Text('Paramètres'),
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              onTap: () => context.go(AppRoutes.parametres),
            ),
          ),
        ),
        if (profile != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    profile.prenom.isNotEmpty
                        ? profile.prenom[0].toUpperCase()
                        : '?',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    profile.prenom,
                    style: textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Semantics(
                  label: 'Se déconnecter',
                  child: IconButton(
                    icon: const Icon(Icons.logout, size: 20),
                    tooltip: 'Déconnexion',
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).logout();
                      context.go(AppRoutes.profiles);
                    },
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
