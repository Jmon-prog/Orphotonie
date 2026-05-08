// ============================================================
// Fichier : lib/core/widgets/app_bar.dart
// Description : AppBar praticien avec barre d'accent colorée en bas.
//               Identité visuelle chaleur + couleur présente sans
//               alourdir le chrome (fond surface, accent primary).
//               Implémente PreferredSizeWidget.
// ============================================================

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// AppBar standard de l'application praticien.
///
/// Affiche une barre horizontale colorée (3 dp) sous l'AppBar
/// pour apporter la couleur principale sans un fond entièrement coloré.
///
/// Utilisation :
/// ```dart
/// Scaffold(
///   appBar: ThemedAppBar(title: 'Mes dictionnaires'),
///   body: ...,
/// )
/// ```
class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ThemedAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.accentHeight = 3.0,
  });

  /// Titre principal affiché dans l'AppBar.
  final String title;

  /// Sous-titre optionnel (ex : nom du praticien, nom du dictionnaire).
  final String? subtitle;

  /// Actions affichées à droite de l'AppBar (icônes, menus).
  final List<Widget>? actions;

  /// Widget remplaçant le bouton retour automatique (ex : icône personnalisée).
  final Widget? leading;

  /// Si `false`, le bouton retour automatique est supprimé.
  final bool automaticallyImplyLeading;

  /// Widget additionnel sous l'AppBar (ex : TabBar).
  /// Si fourni, la barre d'accent est affichée après.
  final PreferredSizeWidget? bottom;

  /// Hauteur de la barre d'accent colorée (défaut : 3 dp).
  final double accentHeight;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight + accentHeight);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          title: subtitle != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.75),
                          ),
                    ),
                  ],
                )
              : Text(title),
          actions: actions,
          leading: leading,
          automaticallyImplyLeading: automaticallyImplyLeading,
          bottom: bottom,
        ),
        // Barre d'accent colorée
        Container(
          height: accentHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary,
                AppColors.secondary,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Variante avec un TabBar intégré — pour les écrans à onglets.
///
/// ```dart
/// Scaffold(
///   appBar: TabbedThemedAppBar(
///     title: 'Statistiques',
///     tabs: [Tab(text: 'Semaine'), Tab(text: 'Mois')],
///     controller: _tabController,
///   ),
///   body: ...,
/// )
/// ```
class TabbedThemedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const TabbedThemedAppBar({
    super.key,
    required this.title,
    required this.tabs,
    required this.controller,
    this.actions,
  });

  /// Titre principal de l'écran.
  final String title;

  /// Onglets affichés dans le [TabBar] (un [Tab] par onglet).
  final List<Widget> tabs;

  /// Contrôleur liant le [TabBar] au [TabBarView] de l'écran.
  final TabController controller;

  /// Actions affichées à droite de l'AppBar.
  final List<Widget>? actions;

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight + 3);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ThemedAppBar(
      title: title,
      actions: actions,
      bottom: TabBar(
        controller: controller,
        tabs: tabs,
        indicatorColor: colorScheme.primary,
        indicatorWeight: 3,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        dividerColor: Colors.transparent,
      ),
    );
  }
}
