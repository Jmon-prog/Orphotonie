// ============================================================
// Fichier : lib/features/help/presentation/onboarding_screen.dart
// Description : Écran d'onboarding avec PageView + indicateurs,
//               bouton Passer, sauvegarde dans AppSettings.
//               100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/help_content.dart';
import 'widgets/onboarding_page.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/app_database.dart';
import 'package:drift/drift.dart' hide Column;

/// Écran d'onboarding — praticien ou parent.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.isPractitioner,
    required this.profileId,
    required this.onComplete,
  });

  /// true = 5 pages praticien, false = 3 pages parent.
  final bool isPractitioner;

  /// Profil courant.
  final int profileId;

  /// Callback appelé quand l'onboarding est terminé ou passé.
  final VoidCallback onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingPageData> get _pages =>
      widget.isPractitioner ? kPractitionerOnboarding : kParentOnboarding;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = _pages;
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Pages
                PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      OnboardingPage(data: pages[index]),
                ),

                // Bouton « Passer » en haut à droite
                Positioned(
                  top: 8,
                  right: 16,
                  child: Semantics(
                    button: true,
                    label: 'Passer l\'introduction',
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Passer'),
                    ),
                  ),
                ),

                // Bas : indicateurs + bouton suivant
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Indicateurs de page
                        Row(
                          children: List.generate(
                            pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              width: index == _currentPage ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: index == _currentPage
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary
                                        .withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        // Bouton suivant / terminer
                        Semantics(
                          button: true,
                          label: isLastPage ? 'Commencer' : 'Page suivante',
                          child: FilledButton(
                            onPressed:
                                isLastPage ? _completeOnboarding : _nextPage,
                            child: Text(
                              isLastPage ? 'Commencer' : 'Suivant',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Marque l'onboarding comme terminé et appelle le callback.
  Future<void> _completeOnboarding() async {
    try {
      final db = ref.read(appDatabaseProvider);
      // Upsert : mettre onboarding_done = true
      await db.into(db.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              profileId: widget.profileId,
              onboardingDone: const Value(true),
            ),
          );
    } catch (e) {
      // En cas d'erreur DB, on continue quand même
      debugPrint('Erreur sauvegarde onboarding : $e');
    }
    widget.onComplete();
  }
}
