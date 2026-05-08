// ============================================================
// Fichier : lib/features/help/presentation/aide_screen.dart
// Description : Hub d'aide — accès au glossaire, aux guides
//               pédagogiques et à l'onboarding.
//               100 % hors-ligne, responsive, accessible.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_bar.dart';
import '../../auth/notifiers/auth_notifier.dart';
import 'glossary_screen.dart';
import 'onboarding_screen.dart';
import 'pedagogical_guide_screen.dart';

/// Écran d'aide principal — liste des ressources disponibles.
class AideScreen extends ConsumerWidget {
  const AideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final profileId = switch (auth) {
      PractitionerAuth(profile: final p) => p.id,
      ChildSelected(profile: final p) => p.id,
      _ => 0,
    };
    final isPractitioner = auth is PractitionerAuth;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Aide',
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Ressources',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Grille de cartes
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.4 : 1.2,
                      children: [
                        _HelpCard(
                          icon: Icons.menu_book_outlined,
                          color: colorScheme.primary,
                          title: 'Glossaire',
                          subtitle: 'Termes linguistiques expliqués',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GlossaryScreen(),
                            ),
                          ),
                        ),
                        _HelpCard(
                          icon: Icons.school_outlined,
                          color: Colors.teal,
                          title: 'Guides pédagogiques',
                          subtitle: 'Conseils par profil de difficulté',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PedagogicalGuideScreen(),
                            ),
                          ),
                        ),
                        _HelpCard(
                          icon: Icons.play_circle_outline,
                          color: Colors.orange,
                          title: 'Revoir le tutoriel',
                          subtitle: 'Présentation de l\'application',
                          onTap: profileId > 0
                              ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => OnboardingScreen(
                                        isPractitioner: isPractitioner,
                                        profileId: profileId,
                                        onComplete: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ),
                                  )
                              : null,
                        ),
                        _HelpCard(
                          icon: Icons.info_outline,
                          color: colorScheme.secondary,
                          title: 'À propos',
                          subtitle: 'Version 0.1.0 · Orphotonie',
                          onTap: () => _showAboutDialog(context),
                        ),
                        if (isPractitioner)
                          _HelpCard(
                            icon: Icons.settings_outlined,
                            color: colorScheme.tertiary,
                            title: 'Paramètres',
                            subtitle: 'Thèmes et accessibilité',
                            onTap: () => context.go(AppRoutes.parametres),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Section FAQ
                    Text(
                      'Questions fréquentes',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _FaqSection(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Orphotonie',
      applicationVersion: '0.1.0',
      applicationIcon: const Icon(Icons.record_voice_over, size: 48),
      applicationLegalese: '© 2025 Orphotonie\n100 % hors-ligne',
      children: const [
        SizedBox(height: 12),
        Text(
          'Application d\'orthophonie multiplateforme.\n'
          'Dictionnaires personnalisés, jeux lexicaux et suivi de progression.',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Carte d'aide
// ---------------------------------------------------------------------------

class _HelpCard extends StatelessWidget {
  const _HelpCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return Semantics(
      button: true,
      label: title,
      hint: subtitle,
      child: Card(
        elevation: isEnabled ? 2 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: isEnabled
                      ? color
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isEnabled
                            ? null
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
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

// ---------------------------------------------------------------------------
// Section FAQ
// ---------------------------------------------------------------------------

class _FaqSection extends StatelessWidget {
  const _FaqSection();

  static const List<({String question, String answer})> _faqs = [
    (
      question: 'Comment créer un dictionnaire ?',
      answer:
          'Allez dans "Mes dictionnaires" → bouton + en bas à droite. Donnez un nom, puis ajoutez des mots via le bouton flottant dans la liste des mots.',
    ),
    (
      question: 'Comment lancer un jeu pour un enfant ?',
      answer:
          'Sélectionnez un profil enfant, puis choisissez un dictionnaire et le jeu souhaité (Anagramme, Pendu, Mot lacunaire…).',
    ),
    (
      question: 'Qu\'est-ce que le niveau Dubois-Buyse ?',
      answer:
          'C\'est une échelle (1–43) indiquant à quelle année scolaire un mot est généralement acquis. Niveau 1 = CP, niveau 8 = CM2.',
    ),
    (
      question: 'L\'application fonctionne-t-elle sans internet ?',
      answer:
          'Oui, entièrement. Toutes les données (lexique, définitions, parties, progression) sont stockées localement.',
    ),
    (
      question: 'Comment voir la progression d\'un enfant ?',
      answer:
          'Dans l\'espace praticien, allez dans "Progression" (icône graphique). Sélectionnez l\'enfant pour voir son tableau de bord détaillé.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _faqs.map((faq) => _FaqTile(faq: faq)).toList(),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});
  final ({String question, String answer}) faq;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          Icons.help_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          faq.question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(faq.answer),
          ),
        ],
      ),
    );
  }
}
