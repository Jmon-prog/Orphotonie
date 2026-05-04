// ============================================================
// Fichier : lib/core/layout/adaptive_navigation.dart
//
// Définition des destinations de navigation de l'application.
// Utilisé par OrphoAdaptiveScaffold pour construire le
// NavigationBar (compact), NavigationRail (medium) et le
// Drawer permanent (expanded+).
// ============================================================

import 'package:flutter/material.dart';

/// Représente une destination de navigation principale.
class AppNavDestination {
  const AppNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.tooltip,
    required this.semanticLabel,
  });

  /// Libellé affiché sous l'icône.
  final String label;

  /// Icône en état non sélectionné.
  final IconData icon;

  /// Icône en état sélectionné (filled).
  final IconData selectedIcon;

  /// Tooltip affiché au survol (desktop).
  final String tooltip;

  /// Label pour l'accessibilité (Semantics).
  final String semanticLabel;
}

/// Les 4 destinations de navigation principales de l'espace praticien.
const kPraticienDestinations = <AppNavDestination>[
  AppNavDestination(
    label: 'Accueil',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    tooltip: 'Accueil',
    semanticLabel: 'Aller à l\'accueil',
  ),
  AppNavDestination(
    label: 'Dictionnaires',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    tooltip: 'Mes dictionnaires',
    semanticLabel: 'Aller aux dictionnaires',
  ),
  AppNavDestination(
    label: 'Fiches',
    icon: Icons.assignment_outlined,
    selectedIcon: Icons.assignment,
    tooltip: 'Fiches d\'exercices',
    semanticLabel: 'Aller aux fiches d\'exercices',
  ),
  AppNavDestination(
    label: 'Progression',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    tooltip: 'Suivi de progression',
    semanticLabel: 'Voir la progression',
  ),
];

/// Construit les [NavigationDestination] pour un [NavigationBar] (compact).
List<NavigationDestination> buildNavigationBarDestinations(
  List<AppNavDestination> destinations,
) {
  return destinations
      .map(
        (d) => NavigationDestination(
          icon: Semantics(
            label: d.semanticLabel,
            child: Icon(d.icon),
          ),
          selectedIcon: Icon(d.selectedIcon),
          label: d.label,
          tooltip: d.tooltip,
        ),
      )
      .toList();
}

/// Construit les [NavigationRailDestination] pour un [NavigationRail] (medium).
List<NavigationRailDestination> buildNavigationRailDestinations(
  List<AppNavDestination> destinations,
) {
  return destinations
      .map(
        (d) => NavigationRailDestination(
          icon: Tooltip(
            message: d.tooltip,
            child: Semantics(
              label: d.semanticLabel,
              child: Icon(d.icon),
            ),
          ),
          selectedIcon: Tooltip(
            message: d.tooltip,
            child: Icon(d.selectedIcon),
          ),
          label: Text(d.label),
        ),
      )
      .toList();
}
