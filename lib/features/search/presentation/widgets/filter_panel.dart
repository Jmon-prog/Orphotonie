// ============================================================
// Fichier : lib/features/search/presentation/widgets/filter_panel.dart
// Description : Panneau de filtres avancés rétractable.
//               Sections repliables ordonnées par pertinence clinique :
//               Phonologie → Syllabes → Orthographe → Grammaire →
//               Fréquence → Morphologie.
//               Sur desktop : latéral. Mobile/tablette : sous la barre.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/audio_providers.dart';
import '../../../../core/audio/tts_service.dart';
import '../../data/search_filters_model.dart';
import '../../search_providers.dart';
// ---------------------------------------------------------------------------
// Référentiel des phonèmes
// ---------------------------------------------------------------------------

/// Entrée du référentiel phonémique (notation Lexique4 / SAMPA-FR).
typedef _PhonemeEntry = ({
  String code,
  String ipa,
  String description,
  String example,
  bool isVowel,
});

/// Table complète des phonèmes du français utilisés dans Lexique4.
const List<_PhonemeEntry> _kPhonemes = [
  // ── Consonnes occlusives ─────────────────────────────────────────────────
  (
    code: 'p',
    ipa: 'p',
    description: 'Plosive bilabiale sourde',
    example: 'papa',
    isVowel: false
  ),
  (
    code: 'b',
    ipa: 'b',
    description: 'Plosive bilabiale voisée',
    example: 'bébé',
    isVowel: false
  ),
  (
    code: 't',
    ipa: 't',
    description: 'Plosive dentale sourde',
    example: 'tête',
    isVowel: false
  ),
  (
    code: 'd',
    ipa: 'd',
    description: 'Plosive dentale voisée',
    example: 'dodo',
    isVowel: false
  ),
  (
    code: 'k',
    ipa: 'k',
    description: 'Plosive vélaire sourde',
    example: 'café',
    isVowel: false
  ),
  (
    code: 'g',
    ipa: 'g',
    description: 'Plosive vélaire voisée',
    example: 'gâteau',
    isVowel: false
  ),
  // ── Consonnes fricatives ──────────────────────────────────────────────────
  (
    code: 'f',
    ipa: 'f',
    description: 'Fricative labiodentale sourde',
    example: 'feu',
    isVowel: false
  ),
  (
    code: 'v',
    ipa: 'v',
    description: 'Fricative labiodentale voisée',
    example: 'vache',
    isVowel: false
  ),
  (
    code: 's',
    ipa: 's',
    description: 'Fricative alvéolaire sourde',
    example: 'sac',
    isVowel: false
  ),
  (
    code: 'z',
    ipa: 'z',
    description: 'Fricative alvéolaire voisée',
    example: 'zèbre',
    isVowel: false
  ),
  (
    code: 'S',
    ipa: 'ʃ',
    description: 'Fricative palatale sourde (ch)',
    example: 'chat',
    isVowel: false
  ),
  (
    code: 'Z',
    ipa: 'ʒ',
    description: 'Fricative palatale voisée (j)',
    example: 'jeu',
    isVowel: false
  ),
  // ── Consonnes nasales ────────────────────────────────────────────────────
  (
    code: 'm',
    ipa: 'm',
    description: 'Nasale bilabiale',
    example: 'maman',
    isVowel: false
  ),
  (
    code: 'n',
    ipa: 'n',
    description: 'Nasale alvéolaire',
    example: 'nuit',
    isVowel: false
  ),
  (
    code: 'J',
    ipa: 'ɲ',
    description: 'Nasale palatale (gn)',
    example: 'agneau',
    isVowel: false
  ),
  (
    code: 'N',
    ipa: 'ŋ',
    description: 'Nasale vélaire (ng)',
    example: 'parking',
    isVowel: false
  ),
  // ── Consonnes liquides & semi-consonnes ──────────────────────────────────
  (
    code: 'l',
    ipa: 'l',
    description: 'Latérale alvéolaire',
    example: 'lune',
    isVowel: false
  ),
  (
    code: 'R',
    ipa: 'ʁ',
    description: 'Fricative uvulaire voisée (r)',
    example: 'rose',
    isVowel: false
  ),
  (
    code: 'j',
    ipa: 'j',
    description: 'Semi-consonne palatale (y)',
    example: 'yeux',
    isVowel: false
  ),
  (
    code: 'w',
    ipa: 'w',
    description: 'Semi-consonne labiovélaire',
    example: 'oui',
    isVowel: false
  ),
  (
    code: 'H',
    ipa: 'ɥ',
    description: 'Semi-consonne palatalisée',
    example: 'nuit',
    isVowel: false
  ),
  // ── Voyelles orales ───────────────────────────────────────────────────────
  (
    code: 'a',
    ipa: 'a',
    description: 'Ouverte antérieure',
    example: 'patte',
    isVowel: true
  ),
  (
    code: 'A',
    ipa: 'ɑ',
    description: 'Ouverte postérieure (â)',
    example: 'pâte',
    isVowel: true
  ),
  (
    code: 'e',
    ipa: 'e',
    description: 'Mi-fermée antérieure',
    example: 'été',
    isVowel: true
  ),
  (
    code: 'E',
    ipa: 'ɛ',
    description: 'Mi-ouverte antérieure (è/ê)',
    example: 'fête',
    isVowel: true
  ),
  (
    code: 'i',
    ipa: 'i',
    description: 'Fermée antérieure',
    example: 'vie',
    isVowel: true
  ),
  (
    code: 'o',
    ipa: 'o',
    description: 'Mi-fermée postérieure',
    example: 'beau',
    isVowel: true
  ),
  (
    code: 'O',
    ipa: 'ɔ',
    description: 'Mi-ouverte postérieure (o)',
    example: 'botte',
    isVowel: true
  ),
  (
    code: 'u',
    ipa: 'u',
    description: 'Fermée postérieure (ou)',
    example: 'roue',
    isVowel: true
  ),
  (
    code: 'y',
    ipa: 'y',
    description: 'Fermée antérieure arrondie (u)',
    example: 'lune',
    isVowel: true
  ),
  (
    code: '2',
    ipa: 'ø',
    description: 'Mi-fermée arrondie (eu fermé)',
    example: 'feu',
    isVowel: true
  ),
  (
    code: '9',
    ipa: 'œ',
    description: 'Mi-ouverte arrondie (eu ouvert)',
    example: 'fleur',
    isVowel: true
  ),
  (
    code: '@',
    ipa: 'ə',
    description: 'Centrale réduite (e muet)',
    example: 'le',
    isVowel: true
  ),
  // ── Voyelles nasales ──────────────────────────────────────────────────────
  (
    code: '5',
    ipa: 'ɛ̃',
    description: 'Nasale antérieure (in / ain)',
    example: 'pain',
    isVowel: true
  ),
  (
    code: '1',
    ipa: 'œ̃',
    description: 'Nasale arrondie (un)',
    example: 'brun',
    isVowel: true
  ),
  (
    code: '§',
    ipa: 'ɔ̃',
    description: 'Nasale postérieure (on)',
    example: 'bon',
    isVowel: true
  ),
  (
    code: '~',
    ipa: 'ɑ̃',
    description: 'Nasale postérieure ouverte (an)',
    example: 'dans',
    isVowel: true
  ),
];

/// Panneau filtres avancés. Affiché uniquement si [SearchState.filterPanelOpen].
class FilterPanel extends ConsumerStatefulWidget {
  const FilterPanel({super.key});

  @override
  ConsumerState<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends ConsumerState<FilterPanel> {
  final _startsWithCtrl = TextEditingController();
  final _endsWithCtrl = TextEditingController();
  final _containsCtrl = TextEditingController();
  final _cvPatternCtrl = TextEditingController();
  final _morphoCtrl = TextEditingController();

  @override
  void dispose() {
    _startsWithCtrl.dispose();
    _endsWithCtrl.dispose();
    _containsCtrl.dispose();
    _cvPatternCtrl.dispose();
    _morphoCtrl.dispose();
    super.dispose();
  }

  void _applyFilters(SearchFilters f) {
    ref.read(searchNotifierProvider.notifier).updateFilters(f);
  }

  void _resetAll() {
    _startsWithCtrl.clear();
    _endsWithCtrl.clear();
    _containsCtrl.clear();
    _cvPatternCtrl.clear();
    _morphoCtrl.clear();
    ref.read(searchNotifierProvider.notifier).resetFilters();
  }

  /// Nombre total de sections ayant au moins un filtre actif.
  int _countActiveSections(SearchFilters f) {
    int count = 0;
    if (f.targetPhonemes.isNotEmpty ||
        f.minPhonemes != null ||
        f.minHomophones != null) {
      count++;
    }
    if (f.nbsyllList.isNotEmpty || f.minNbsyll != null || f.maxNbsyll != null) {
      count++;
    }
    if (f.startsWith?.isNotEmpty == true ||
        f.endsWith?.isNotEmpty == true ||
        f.contains?.isNotEmpty == true ||
        f.cvPattern?.isNotEmpty == true ||
        f.exactLength != null ||
        f.minLength != null) {
      count++;
    }
    if (f.cgramList.isNotEmpty || f.genre != null || f.nombre != null) {
      count++;
    }
    if (f.minPreval != null || f.minFreqortho != null) {
      count++;
    }
    if (f.hasMorphodecomp == true || f.morphoContains?.isNotEmpty == true) {
      count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchNotifierProvider).filters;
    final colorScheme = Theme.of(context).colorScheme;
    final activeSections = _countActiveSections(filters);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // â”€â”€ En-tête â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _FilterPanelHeader(
            activeCount: activeSections,
            hasActive: filters.hasActiveFilters,
            onReset: _resetAll,
            onClose: () =>
                ref.read(searchNotifierProvider.notifier).toggleFilterPanel(),
          ),
          const Divider(height: 1),

          // â”€â”€ Sections â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Ordre clinique : phonologie en premier pour orthophonie
                  _PhonologySection(
                    filters: filters,
                    onApply: _applyFilters,
                  ),
                  _SyllablesSection(filters: filters, onApply: _applyFilters),
                  _OrthographySection(
                    filters: filters,
                    onApply: _applyFilters,
                    startsWithCtrl: _startsWithCtrl,
                    endsWithCtrl: _endsWithCtrl,
                    containsCtrl: _containsCtrl,
                    cvPatternCtrl: _cvPatternCtrl,
                  ),
                  _GrammarSection(filters: filters, onApply: _applyFilters),
                  _FrequencySection(filters: filters, onApply: _applyFilters),
                  _MorphologySection(
                    filters: filters,
                    onApply: _applyFilters,
                    morphoCtrl: _morphoCtrl,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// En-tête du panneau
// ---------------------------------------------------------------------------

class _FilterPanelHeader extends StatelessWidget {
  const _FilterPanelHeader({
    required this.activeCount,
    required this.hasActive,
    required this.onReset,
    required this.onClose,
  });
  final int activeCount;
  final bool hasActive;
  final VoidCallback onReset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
      child: Row(
        children: [
          Icon(
            Icons.tune,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Filtres avancés',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (activeCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$activeCount',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (hasActive)
            TextButton(
              onPressed: onReset,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Tout effacer'),
            ),
          Semantics(
            label: 'Fermer les filtres',
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onClose,
              tooltip: 'Fermer',
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tuile de section repliable
// ---------------------------------------------------------------------------

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.title,
    required this.hasActive,
    required this.children,
    this.initiallyExpanded = false,
    this.titleActions = const <Widget>[],
  });
  final IconData icon;
  final String title;
  final bool hasActive;
  final List<Widget> children;
  final bool initiallyExpanded;

  /// Widgets insérés à droite du titre (avant le chevron ExpansionTile).
  final List<Widget> titleActions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      // Supprime le bord de séparation intérieur par défaut d'ExpansionTile
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: hasActive
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: hasActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: hasActive ? FontWeight.w600 : FontWeight.normal,
                    color:
                        hasActive ? colorScheme.primary : colorScheme.onSurface,
                  ),
            ),
            if (hasActive) ...[
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            if (titleActions.isNotEmpty) ...[
              const Spacer(),
              ...titleActions,
            ],
          ],
        ),
        children: children,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sections individuelles
// ---------------------------------------------------------------------------

class _PhonologySection extends ConsumerWidget {
  const _PhonologySection({
    required this.filters,
    required this.onApply,
  });
  final SearchFilters filters;
  final void Function(SearchFilters) onApply;

  /// Ouvre le guide des phonèmes.
  void _showHelp(BuildContext context, WidgetRef ref) {
    final tts = ref.read(ttsServiceProvider);
    showDialog<void>(
      context: context,
      builder: (_) => _PhonemeHelpDialog(
        tts: tts,
        onSelect: (code) {
          final current = List<String>.from(filters.targetPhonemes);
          if (current.contains(code)) {
            current.remove(code);
          } else {
            current.add(code);
          }
          onApply(filters.copyWith(targetPhonemes: current));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = filters.targetPhonemes;
    final hasActive = active.isNotEmpty ||
        filters.minPhonemes != null ||
        filters.minHomophones != null;

    // Phonèmes présents dans les mots de definitions.db (async).
    // Filtre _kPhonemes pour ne conserver que ceux réellement attestés.
    final phonemesAsync = ref.watch(definitionPhonemesProvider);
    final chips = phonemesAsync.when(
      data: (codes) => _kPhonemes.where((e) => codes.contains(e.code)).toList(),
      loading: () => const <_PhonemeEntry>[],
      error: (_, __) => const <_PhonemeEntry>[],
    );

    return _SectionTile(
      icon: Icons.record_voice_over,
      title: 'Phonologie',
      hasActive: hasActive,
      initiallyExpanded: true,
      titleActions: [
        Semantics(
          label: 'Guide des phonèmes',
          child: IconButton(
            icon: const Icon(Icons.help_outline, size: 18),
            onPressed: () => _showHelp(context, ref),
            tooltip: 'Guide des phonèmes',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Raccourcis phonèmes — multi-sélection dynamique
              Text(
                'Phonèmes cibles (multi-sélection)',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 6),
              phonemesAsync.isLoading
                  ? const SizedBox(
                      height: 24,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Chargement des phonèmes…'),
                        ],
                      ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: chips.map((entry) {
                        final isActive = active.contains(entry.code);
                        return Tooltip(
                          message:
                              '[${entry.ipa}] ${entry.description} · ex : ${entry.example}',
                          child: FilterChip(
                            label: Text(
                              entry.code,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: isActive,
                            visualDensity: VisualDensity.compact,
                            onSelected: (v) {
                              final current = List<String>.from(active);
                              if (v) {
                                current.add(entry.code);
                              } else {
                                current.remove(entry.code);
                              }
                              onApply(
                                filters.copyWith(targetPhonemes: current),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 8),
              // Homophones
              SwitchListTile(
                title: const Text('Avec homophones'),
                value: (filters.minHomophones ?? 0) >= 1,
                onChanged: (v) => onApply(
                  filters.copyWith(minHomophones: v ? 1 : null),
                ),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SyllablesSection extends StatelessWidget {
  const _SyllablesSection({required this.filters, required this.onApply});
  final SearchFilters filters;
  final void Function(SearchFilters) onApply;

  @override
  Widget build(BuildContext context) {
    final hasActive = filters.nbsyllList.isNotEmpty ||
        filters.minNbsyll != null ||
        filters.maxNbsyll != null;

    return _SectionTile(
      icon: Icons.grain,
      title: 'Syllabes',
      hasActive: hasActive,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre de syllabes',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [1, 2, 3, 4, 5, 6].map((n) {
                  final selected = filters.nbsyllList.contains(n);
                  return FilterChip(
                    label: Text('${n}s'),
                    selected: selected,
                    tooltip: '$n syllabe${n > 1 ? 's' : ''}',
                    onSelected: (v) {
                      final list = List<int>.from(filters.nbsyllList);
                      if (v) {
                        list.add(n);
                      } else {
                        list.remove(n);
                      }
                      onApply(filters.copyWith(nbsyllList: list));
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrthographySection extends StatelessWidget {
  const _OrthographySection({
    required this.filters,
    required this.onApply,
    required this.startsWithCtrl,
    required this.endsWithCtrl,
    required this.containsCtrl,
    required this.cvPatternCtrl,
  });
  final SearchFilters filters;
  final void Function(SearchFilters) onApply;
  final TextEditingController startsWithCtrl;
  final TextEditingController endsWithCtrl;
  final TextEditingController containsCtrl;
  final TextEditingController cvPatternCtrl;

  @override
  Widget build(BuildContext context) {
    final hasActive = filters.startsWith?.isNotEmpty == true ||
        filters.endsWith?.isNotEmpty == true ||
        filters.contains?.isNotEmpty == true ||
        filters.cvPattern?.isNotEmpty == true ||
        filters.exactLength != null ||
        filters.minLength != null;

    return _SectionTile(
      icon: Icons.spellcheck,
      title: 'Orthographe',
      hasActive: hasActive,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              _FilterTextField(
                controller: startsWithCtrl,
                label: 'Commence par',
                placeholder: 'ex: ch',
                onChanged: (v) => onApply(filters.copyWith(startsWith: v)),
              ),
              _FilterTextField(
                controller: endsWithCtrl,
                label: 'Finit par',
                placeholder: 'ex: tion',
                onChanged: (v) => onApply(filters.copyWith(endsWith: v)),
              ),
              _FilterTextField(
                controller: containsCtrl,
                label: 'Contient',
                placeholder: 'ex: eau',
                onChanged: (v) => onApply(filters.copyWith(contains: v)),
              ),
              _FilterTextField(
                controller: cvPatternCtrl,
                label: 'Motif C/V',
                placeholder: 'ex: CVCV',
                onChanged: (v) =>
                    onApply(filters.copyWith(cvPattern: v.toUpperCase())),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GrammarSection extends StatelessWidget {
  const _GrammarSection({required this.filters, required this.onApply});
  final SearchFilters filters;
  final void Function(SearchFilters) onApply;

  static const _options = [
    'NOM',
    'VER',
    'ADJ',
    'ADV',
    'AUX',
    'PRE',
    'CON',
    'PRO',
    'ONO',
  ];
  static const _genres = [('Masculin', 'm'), ('Féminin', 'f')];
  static const _nombres = [('Singulier', 's'), ('Pluriel', 'p')];

  @override
  Widget build(BuildContext context) {
    final hasActive = filters.cgramList.isNotEmpty ||
        filters.genre != null ||
        filters.nombre != null;

    return _SectionTile(
      icon: Icons.text_fields,
      title: 'Grammaire',
      hasActive: hasActive,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Catégories grammaticales
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _options.map((cat) {
                  final selected = filters.cgramList.contains(cat);
                  return FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (v) {
                      final list = List<String>.from(filters.cgramList);
                      if (v) {
                        list.add(cat);
                      } else {
                        list.remove(cat);
                      }
                      onApply(filters.copyWith(cgramList: list));
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // Genre
              Row(
                children: [
                  Text(
                    'Genre :',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  ..._genres.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(g.$1),
                        selected: filters.genre == g.$2,
                        onSelected: (v) => onApply(
                          filters.copyWith(genre: v ? g.$2 : null),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Nombre
              Row(
                children: [
                  Text(
                    'Nombre :',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  ..._nombres.map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(n.$1),
                        selected: filters.nombre == n.$2,
                        onSelected: (v) => onApply(
                          filters.copyWith(nombre: v ? n.$2 : null),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrequencySection extends StatelessWidget {
  const _FrequencySection({required this.filters, required this.onApply});
  final SearchFilters filters;
  final void Function(SearchFilters) onApply;

  @override
  Widget build(BuildContext context) {
    final hasActive = filters.minPreval != null || filters.minFreqortho != null;
    final prevalVal = filters.minPreval ?? 0;

    return _SectionTile(
      icon: Icons.bar_chart,
      title: 'Fréquence & Prévalence',
      hasActive: hasActive,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prévalence minimale : ${prevalVal.toInt()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Slider(
                value: prevalVal,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${prevalVal.toInt()}%',
                onChanged: (v) => onApply(
                  filters.copyWith(minPreval: v > 0 ? v : null),
                ),
              ),
              // Boutons rapides
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Très connu (>90%)'),
                    onPressed: () => onApply(filters.copyWith(minPreval: 90)),
                  ),
                  ActionChip(
                    label: const Text('Connu (>70%)'),
                    onPressed: () => onApply(filters.copyWith(minPreval: 70)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MorphologySection extends StatelessWidget {
  const _MorphologySection({
    required this.filters,
    required this.onApply,
    required this.morphoCtrl,
  });
  final SearchFilters filters;
  final void Function(SearchFilters) onApply;
  final TextEditingController morphoCtrl;

  @override
  Widget build(BuildContext context) {
    final hasActive = filters.hasMorphodecomp == true ||
        filters.morphoContains?.isNotEmpty == true;

    return _SectionTile(
      icon: Icons.extension,
      title: 'Morphologie',
      hasActive: hasActive,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Décomposition disponible'),
                value: filters.hasMorphodecomp == true,
                onChanged: (v) => onApply(
                  filters.copyWith(hasMorphodecomp: v ? true : null),
                ),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              _FilterTextField(
                controller: morphoCtrl,
                label: 'Contient racine',
                placeholder: 'ex: compos, port',
                onChanged: (v) => onApply(filters.copyWith(morphoContains: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Widget utilitaire
// ---------------------------------------------------------------------------

class _FilterTextField extends StatelessWidget {
  const _FilterTextField({
    required this.controller,
    required this.label,
    required this.placeholder,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog : guide des phonèmes
// ---------------------------------------------------------------------------

/// Pop-up référentiel des phonèmes du français.
/// Permet d'écouter le mot exemple et de sélectionner un phonème comme filtre.
class _PhonemeHelpDialog extends StatelessWidget {
  const _PhonemeHelpDialog({
    required this.tts,
    required this.onSelect,
  });

  final TtsService tts;

  /// Appelé quand l'utilisateur choisit un phonème ; ferme le dialog.
  final void Function(String code) onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final consonants = _kPhonemes.where((p) => !p.isVowel).toList();
    final vowels = _kPhonemes.where((p) => p.isVowel).toList();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.record_voice_over, color: colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          const Expanded(child: Text('Guide des phonèmes')),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      content: SizedBox(
        width: 520,
        height: 540,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Notation Lexique4 (SAMPA-FR). Tapez une ligne pour sélectionner le phonème comme filtre.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      context,
                      colorScheme,
                      textTheme,
                      'CONSONNES',
                      consonants,
                    ),
                    _buildSection(
                      context,
                      colorScheme,
                      textTheme,
                      'VOYELLES',
                      vowels,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    String sectionTitle,
    List<_PhonemeEntry> phonemes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
          child: Text(
            sectionTitle,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...phonemes.map((p) => _buildRow(context, colorScheme, textTheme, p)),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    _PhonemeEntry p,
  ) {
    return InkWell(
      onTap: () {
        onSelect(p.code);
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: [
            // Code Lexique4 dans un badge
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                p.code,
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // IPA + description + exemple
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: '[${p.ipa}]  ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: p.description,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'ex : ${p.example}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Bouton écouter le mot exemple
            Semantics(
              label: 'Écouter « ${p.example} »',
              button: true,
              child: IconButton(
                icon: Icon(
                  Icons.volume_up_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                onPressed: () async {
                  try {
                    await tts.speak(p.example);
                  } catch (_) {}
                },
                tooltip: 'Écouter « ${p.example} »',
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
