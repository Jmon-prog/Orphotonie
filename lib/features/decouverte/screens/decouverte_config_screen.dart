// ============================================================
// Fichier : lib/features/decouverte/screens/decouverte_config_screen.dart
// Description : Écran de configuration d'une session Découverte.
//               L'enfant choisit une plage de niveaux Dubois-Buyse
//               et le nombre de mots (5 / 10 / 15).
//               Responsive. 100 % hors ligne.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../decouverte_providers.dart';
import '../decouverte_session.dart';

class DecouverteConfigScreen extends ConsumerStatefulWidget {
  const DecouverteConfigScreen({
    super.key,
    required this.profileId,
  });

  final int profileId;

  @override
  ConsumerState<DecouverteConfigScreen> createState() =>
      _DecouverteConfigScreenState();
}

class _DecouverteConfigScreenState
    extends ConsumerState<DecouverteConfigScreen> {
  RangeValues _levelRange = const RangeValues(1, 11);
  int _wordCount = 10;
  // Index du cycle sélectionné (0-4), 4 = Surprise
  int _selectedCycleIndex = 0;

  static const _wordCountOptions = [5, 10, 15];

  // Cycles scolaires : (label, sous-label, emoji, levelMin, levelMax, couleur ARGB)
  static const _cycles = [
    _CycleOption('Cycle 2', 'CP · CE1 · CE2', '🐣', 1, 11, 0xFF5A7AE0),
    _CycleOption('Cycle 3', 'CM1 · CM2 · 6ème', '🌱', 11, 20, 0xFF5AE0C0),
    _CycleOption('Collège', '5ème · 4ème · 3ème', '🚀', 20, 32, 0xFFB05AE0),
    _CycleOption('Lycée', '2nde · 1ère · Terminale', '🎓', 32, 43, 0xFFE05A5A),
    _CycleOption(
      'Surprise !',
      'Tous niveaux mélangés',
      '🎲',
      1,
      43,
      0xFFE0A05A,
    ),
  ];

  void _selectCycle(int index) {
    final c = _cycles[index];
    setState(() {
      _selectedCycleIndex = index;
      _levelRange = RangeValues(c.levelMin.toDouble(), c.levelMax.toDouble());
    });
  }

  Future<void> _start() async {
    final config = DecouverteConfig(
      levelMin: _levelRange.start.round(),
      levelMax: _levelRange.end.round(),
      wordCount: _wordCount,
    );

    await ref.read(decouverteProvider.notifier).startSession(config);

    final error = ref.read(decouverteProvider).error;
    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    if (!mounted) return;
    context.go(
      '${AppRoutes.decouvertePresentation}?profileId=${widget.profileId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(
      decouverteProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Découverte'),
        leading: BackButton(
          onPressed: () => context.go(AppRoutes.childHome),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 64 : 20,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── En-tête ──────────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(80),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.explore_rounded,
                            size: 40,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Découvre de nouveaux mots !',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Choisis ton niveau et le nombre de mots '
                                  'à explorer.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withAlpha(160),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Sélection du niveau ──────────────────────────────────
                    Text(
                      'Niveau scolaire',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    // Ligne 1 : 4 cycles (2 × 2)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.6,
                      children: List.generate(4, (i) {
                        final c = _cycles[i];
                        final selected = _selectedCycleIndex == i;
                        final color = Color(c.color);
                        return Semantics(
                          label: '${c.label}, ${c.subLabel}',
                          button: true,
                          selected: selected,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withAlpha(200)
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? color
                                    : theme.colorScheme.outline.withAlpha(80),
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _selectCycle(i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      c.emoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            c.label,
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: selected
                                                  ? Colors.white
                                                  : theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            c.subLabel,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: selected
                                                  ? Colors.white.withAlpha(200)
                                                  : theme.colorScheme.onSurface
                                                      .withAlpha(130),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    // Ligne 2 : Surprise (pleine largeur)
                    Builder(
                      builder: (context) {
                        const i = 4;
                        final c = _cycles[i];
                        final selected = _selectedCycleIndex == i;
                        final color = Color(c.color);
                        return Semantics(
                          label: '${c.label}, ${c.subLabel}',
                          button: true,
                          selected: selected,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withAlpha(200)
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? color
                                    : theme.colorScheme.outline.withAlpha(80),
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _selectCycle(i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      c.emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.label,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: selected
                                                ? Colors.white
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          c.subLabel,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: selected
                                                ? Colors.white.withAlpha(200)
                                                : theme.colorScheme.onSurface
                                                    .withAlpha(130),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // ── Nombre de mots ────────────────────────────────────────
                    Text(
                      'Nombre de mots',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _wordCountOptions.map((count) {
                        final selected = count == _wordCount;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Semantics(
                              label: '$count mots',
                              button: true,
                              selected: selected,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : theme
                                          .colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline
                                            .withAlpha(100),
                                    width: 2,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () =>
                                      setState(() => _wordCount = count),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '$count',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: selected
                                                ? theme.colorScheme.onPrimary
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          'mots',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: selected
                                                ? theme.colorScheme.onPrimary
                                                    .withAlpha(200)
                                                : theme.colorScheme.onSurface
                                                    .withAlpha(150),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),

                    // ── Bouton démarrer ───────────────────────────────────────
                    Semantics(
                      label: 'Démarrer la session Découverte',
                      button: true,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : _start,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          isLoading ? 'Chargement…' : 'C\'est parti !',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lien retour
                    TextButton(
                      onPressed: () => context.go(AppRoutes.childHome),
                      child: const Text('Retour à mes listes'),
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
// Modèle interne pour les cycles scolaires
// ---------------------------------------------------------------------------

class _CycleOption {
  const _CycleOption(
    this.label,
    this.subLabel,
    this.emoji,
    this.levelMin,
    this.levelMax,
    this.color,
  );

  final String label;
  final String subLabel;
  final String emoji;
  final int levelMin;
  final int levelMax;
  final int color; // valeur ARGB
}
