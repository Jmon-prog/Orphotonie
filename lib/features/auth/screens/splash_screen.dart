// ============================================================
// Fichier : lib/features/auth/screens/splash_screen.dart
// Description : Écran de démarrage animé — logo, nom de l'app et
//               indicateur de chargement. Redirige vers la sélection
//               de profil ou la création du premier praticien.
//               Animations : entrée logo (scale + fade), titre
//               (slide + fade), tagline (fade), dots rebondissants.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/database/storage/database_initializer.dart';
import '../../../core/router/app_router.dart';

// Couleurs du dégradé (indépendantes du thème — splash avant chargement du thème)
const _kColorTop = Color(0xFF7B6EE8);
const _kColorBottom = Color(0xFF4A3AB0);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // -- Animations d'entrée (logo + titre + tagline) --
  late final AnimationController _entryCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;

  // -- Points de chargement (boucle infinie) --
  late final AnimationController _dotsCtrl;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.38, 0.75, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.38, 0.75, curve: Curves.easeOut),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _entryCtrl.forward();
    _init();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      await DatabaseInitializer.init();
      if (!mounted) return;

      final dao = ref.read(profilesDaoProvider);
      final profiles = await dao.watchAllProfiles().first;
      if (!mounted) return;

      // Durée minimale pour laisser l'animation d'entrée se terminer
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      if (profiles.isEmpty) {
        context.go(AppRoutes.newPractitioner);
      } else {
        context.go(AppRoutes.profiles);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur d'initialisation : $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kColorTop, _kColorBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Zone centrale : logo + titre + tagline ────────────────
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo avec ombre portée
                      FadeTransition(
                        opacity: _logoOpacity,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 32,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/images/launcher_icon.png',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Titre de l'application
                      FadeTransition(
                        opacity: _titleOpacity,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: const Text(
                            'Orphotonie',
                            style: TextStyle(
                              fontFamily: 'Baloo2',
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Tagline
                      FadeTransition(
                        opacity: _taglineOpacity,
                        child: const Text(
                          'Orthophonie adaptée',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Points de chargement rebondissants ────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 52),
                child: _BouncingDots(controller: _dotsCtrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Indicateur de chargement : 3 points rebondissants décalés
// ---------------------------------------------------------------------------

class _BouncingDots extends StatelessWidget {
  const _BouncingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final start = i * 0.2;
        final end = (start + 0.5).clamp(0.0, 1.0);
        final bounce = Tween<double>(begin: 0.0, end: -12.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: Curves.easeInOut),
          ),
        );
        return AnimatedBuilder(
          animation: bounce,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, bounce.value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
