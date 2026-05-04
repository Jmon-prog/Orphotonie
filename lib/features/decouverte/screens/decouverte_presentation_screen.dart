// ============================================================
// Fichier : lib/features/decouverte/screens/decouverte_presentation_screen.dart
// Description : Présentation mot par mot d'une session Découverte.
//               L'enfant juge chaque mot : "Je connais" ou "Je découvre".
//               Animation de flip entre le mot et sa définition.
//               Responsive. 100 % hors ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../decouverte_providers.dart';
import '../decouverte_session.dart';

class DecouvertePresentationScreen extends ConsumerWidget {
  const DecouvertePresentationScreen({
    super.key,
    required this.profileId,
  });

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(decouverteProvider);

    // Garde-fou : rediriger si la session n'est pas prête
    if (session.config == null || session.words.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.childHome);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Tous les mots ont été jugés → aller au parcours
    if (session.presentationComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(
          '${AppRoutes.decouverceParcours}?profileId=$profileId',
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentWord = session.words[session.currentWordIndex];
    final total = session.words.length;
    final current = session.currentWordIndex + 1;
    final progress = current / total;

    return Scaffold(
      appBar: AppBar(
        title: Text('Découverte · $current/$total'),
        leading: BackButton(
          onPressed: () {
            if (session.currentWordIndex > 0) {
              ref.read(decouverteProvider.notifier).previousWord();
            } else {
              context.go(AppRoutes.decouverteConfig);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    // ── Carte de mot ──────────────────────────────────────────
                    Expanded(
                      child: _WordCard(word: currentWord),
                    ),
                    const SizedBox(height: 24),

                    // ── Boutons de jugement ───────────────────────────────────
                    Row(
                      children: [
                        // Je connais
                        Expanded(
                          child: Semantics(
                            label: 'Je connais ce mot',
                            button: true,
                            child: OutlinedButton.icon(
                              onPressed: () => ref
                                  .read(decouverteProvider.notifier)
                                  .judgeCurrentWord(
                                    WordExplorationStatus.known,
                                  ),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 20,
                              ),
                              label: const Text('Je connais !'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2,
                                ),
                                foregroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Je découvre
                        Expanded(
                          child: Semantics(
                            label: 'Je veux apprendre ce mot',
                            button: true,
                            child: FilledButton.icon(
                              onPressed: () => ref
                                  .read(decouverteProvider.notifier)
                                  .judgeCurrentWord(
                                    WordExplorationStatus.toLearn,
                                  ),
                              icon: const Icon(Icons.school_rounded, size: 20),
                              label: const Text('Je découvre !'),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Compteur de mots "à apprendre"
                    Text(
                      '${session.wordsToLearn.length} mot(s) à découvrir',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(140),
                          ),
                    ),
                    const SizedBox(height: 8),
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
// Carte de mot avec flip (mot → définition)
// ---------------------------------------------------------------------------

class _WordCard extends StatefulWidget {
  const _WordCard({required this.word});

  final DecouverteWordState word;

  @override
  State<_WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<_WordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showDefinition = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_WordCard old) {
    super.didUpdateWidget(old);
    // Nouveau mot → réinitialiser le flip
    if (old.word.entry.mot != widget.word.entry.mot) {
      _controller.reset();
      _showDefinition = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showDefinition) {
      _controller.reverse().then((_) {
        if (mounted) setState(() => _showDefinition = false);
      });
    } else {
      setState(() => _showDefinition = true);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.word.entry;
    final definition = entry.defFleches ?? entry.defCroises ?? entry.definition;

    return Semantics(
      label: _showDefinition
          ? 'Définition : ${definition ?? "Pas de définition disponible"}'
          : 'Mot : ${entry.mot}. Appuie pour voir la définition.',
      button: true,
      child: GestureDetector(
        onTap: _flip,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Flip via perspective transform
            final angle = _animation.value * 3.14159;
            final showBack = _animation.value > 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: showBack
                      ? theme.colorScheme.secondaryContainer
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withAlpha(40),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: showBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: _DefinitionSide(
                          mot: entry.mot,
                          definition: definition,
                        ),
                      )
                    : _WordSide(mot: entry.mot, niveau: entry.niveauDubois),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WordSide extends StatelessWidget {
  const _WordSide({required this.mot, this.niveau});

  final String mot;
  final int? niveau;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.text_fields_rounded,
            size: 40,
            color: theme.colorScheme.onPrimaryContainer.withAlpha(120),
          ),
          const SizedBox(height: 20),
          Text(
            mot,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onPrimaryContainer,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 16,
                color: theme.colorScheme.onPrimaryContainer.withAlpha(100),
              ),
              const SizedBox(width: 6),
              Text(
                'Appuie pour voir la définition',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withAlpha(130),
                ),
              ),
            ],
          ),
          if (niveau != null) ...[
            const SizedBox(height: 16),
            Chip(
              label: Text('Niveau $niveau'),
              labelStyle: theme.textTheme.labelSmall,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ],
        ],
      ),
    );
  }
}

class _DefinitionSide extends StatelessWidget {
  const _DefinitionSide({required this.mot, this.definition});

  final String mot;
  final String? definition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            mot,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSecondaryContainer.withAlpha(180),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: theme.colorScheme.onSecondaryContainer.withAlpha(60)),
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                definition ?? 'Pas de définition disponible.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Appuie pour retourner la carte',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}
