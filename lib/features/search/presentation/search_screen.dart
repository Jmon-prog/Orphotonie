// ============================================================
// Fichier : lib/features/search/presentation/search_screen.dart
// Description : Écran principal du moteur de recherche Lexique 4.
//               Barre de recherche + debounce 300ms + panneau filtres +
//               ListView.builder / GridView + barre de sélection flottante.
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/lexique4_database.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../features/dictionaries/services/definitions_service.dart';
import '../search_providers.dart';
import 'widgets/filter_panel.dart';
import 'widgets/quick_searches.dart';
import 'widgets/result_grid_item.dart';
import 'widgets/result_list_item.dart';
import 'widgets/selection_bar.dart';
import 'widgets/word_detail_card.dart';
import '../data/search_filters_model.dart';

/// Écran de recherche dans lexique4.db.
/// [dictionaryId] et [dictionaryName] : dictionnaire cible pour l'ajout en lot.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.dictionaryId,
    this.dictionaryName,
    this.initialFilters,
  });

  final int? dictionaryId;
  final String? dictionaryName;

  /// Filtres pré-remplis (ex : depuis un guide pédagogique).
  final SearchFilters? initialFilters;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    // Appliquer les filtres initiaux si fournis (ex : guide pédagogique)
    if (widget.initialFilters != null) {
      Future.microtask(() {
        ref
            .read(searchNotifierProvider.notifier)
            .updateFilters(widget.initialFilters!);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Debounce de la saisie
  // ---------------------------------------------------------------------------

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchNotifierProvider.notifier).setTextQuery(value);
    });
  }

  // ---------------------------------------------------------------------------
  // Pagination au scroll
  // ---------------------------------------------------------------------------

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(searchNotifierProvider.notifier).loadNextPage();
    }
  }

  // ---------------------------------------------------------------------------
  // Ajout d'un mot au dictionnaire courant
  // ---------------------------------------------------------------------------

  Future<void> _addWord(LexiqueEntry entry) async {
    if (widget.dictionaryId == null) {
      _showNoTargetSnack();
      return;
    }
    try {
      final dao = ref.read(wordsDaoProvider);
      // Vérification doublon : mot déjà présent dans ce dictionnaire ?
      final existing = await dao.getWordByMot(widget.dictionaryId!, entry.mot);
      if (existing != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('« ${entry.mot} » est déjà dans le dictionnaire.'),
            ),
          );
        }
        return;
      }
      // Récupère la définition depuis definitions.db (si disponible)
      final defEntry =
          await ref.read(definitionsServiceProvider).findDefinition(entry.mot);
      await dao.insertWord(
        WordsCompanion(
          dictionaryId: Value(widget.dictionaryId!),
          mot: Value(entry.mot),
          definition: Value(defEntry?.defComplete),
          defCroises: Value(defEntry?.defCroises),
          defFleches: Value(defEntry?.defFleches),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ "${entry.mot}" ajouté au dictionnaire.'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _addBatch(List<String> mots) async {
    if (widget.dictionaryId == null) {
      _showNoTargetSnack();
      return;
    }
    try {
      final dao = ref.read(wordsDaoProvider);
      int added = 0;
      int skipped = 0;
      for (final mot in mots) {
        // Vérification doublon avant chaque insertion
        final existing = await dao.getWordByMot(widget.dictionaryId!, mot);
        if (existing != null) {
          skipped++;
          continue;
        }
        // Récupère la définition depuis definitions.db (si disponible)
        final defEntry =
            await ref.read(definitionsServiceProvider).findDefinition(mot);
        await dao.insertWord(
          WordsCompanion(
            dictionaryId: Value(widget.dictionaryId!),
            mot: Value(mot),
            definition: Value(defEntry?.defComplete),
            defCroises: Value(defEntry?.defCroises),
            defFleches: Value(defEntry?.defFleches),
          ),
        );
        added++;
      }
      if (mounted) {
        final msg = skipped > 0
            ? '$added mot${added > 1 ? 's' : ''} ajouté${added > 1 ? 's' : ''}, $skipped déjà présent${skipped > 1 ? 's' : ''}.'
            : '$added mot${added > 1 ? 's' : ''} ajouté${added > 1 ? 's' : ''}.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  void _showNoTargetSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ouvrez la recherche depuis un dictionnaire pour ajouter des mots.',
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(state, notifier),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panneau filtres latéral (desktop)
                if (state.filterPanelOpen)
                  const SizedBox(
                    width: 320,
                    child: FilterPanel(),
                  ),
                Expanded(child: _buildMain(context, state, notifier, isWide)),
              ],
            );
          }
          return _buildMain(context, state, notifier, isWide);
        },
      ),
      // Barre flottante de sélection
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SelectionBar(
        dictionaryId: widget.dictionaryId,
        dictionaryName: widget.dictionaryName,
        onAddToDictionary: _addBatch,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    SearchState state,
    SearchNotifier notifier,
  ) {
    return ThemedAppBar(
      title: widget.dictionaryName != null
          ? 'Recherche → ${widget.dictionaryName}'
          : 'Recherche dictionnaire',
      actions: [
        // Compteur de mots sélectionnés
        if (state.selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Badge(
              label: Text('${state.selected.length}'),
              child: const Icon(Icons.menu_book_outlined),
            ),
          ),
      ],
    );
  }

  Widget _buildMain(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
    bool isWide,
  ) {
    return Column(
      children: [
        // ── Barre de recherche ───────────────────────────────────────────
        _SearchBar(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          onClear: () {
            _searchCtrl.clear();
            notifier.setTextQuery('');
          },
          filterActive: state.filterPanelOpen,
          onFilterToggle: notifier.toggleFilterPanel,
          sort: state.filters.sort,
          onSortChanged: (s) =>
              notifier.updateFilters(state.filters.copyWith(sort: s)),
          gridView: state.filters.gridView,
          onViewToggle: notifier.toggleGridView,
        ),

        // ── Panneau filtres (mobile/tablette) ────────────────────────────
        if (state.filterPanelOpen && !isWide) const FilterPanel(),

        // ── Chips filtres actifs ─────────────────────────────────────────
        if (state.filters.hasActiveFilters)
          _ActiveFiltersBar(
            chips: state.filters.activeChips,
            onClearAll: notifier.resetFilters,
          ),

        // ── Raccourcis praticiens ────────────────────────────────────────
        const QuickSearchesBar(),
        const SizedBox(height: 4),

        // ── Barre de statut ──────────────────────────────────────────────
        _StatusBar(state: state, onSelectAll: notifier.toggleSelectAll),

        // ── Résultats ────────────────────────────────────────────────────
        Expanded(child: _buildResults(context, state, notifier)),
      ],
    );
  }

  Widget _buildResults(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
  ) {
    if (state.isLoading && state.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(state.error!),
            TextButton(
              onPressed: () => notifier.resetFilters(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return _EmptySearch(hasQuery: state.filters.hasActiveFilters);
    }

    if (state.filters.gridView) {
      return _buildGrid(context, state, notifier);
    }
    return _buildList(context, state, notifier);
  }

  Widget _buildList(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
  ) {
    // Mots déjà présents dans le dictionnaire cible (stream réactif)
    final alreadyAdded = widget.dictionaryId != null
        ? ref
                .watch(wordsInDictionaryProvider(widget.dictionaryId!))
                .valueOrNull ??
            const <String>{}
        : const <String>{};

    return ListView.builder(
      controller: _scrollCtrl,
      itemExtent: 60,
      itemCount: state.results.length + (state.isLoading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= state.results.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final entry = state.results[i];
        final selected = state.selected.contains(entry.mot);
        return ResultListItem(
          key: ValueKey(entry.mot),
          entry: entry,
          isSelected: selected,
          isAlreadyAdded: alreadyAdded.contains(entry.mot),
          onTap: () => showWordDetail(
            context,
            entry: entry,
            dictionaryId: widget.dictionaryId,
            onAdd: (e) => _addWord(e),
          ),
          onLongPress: () => notifier.toggleSelection(entry.mot),
          onAdd: () => _addWord(entry),
          onToggleSelect: () => notifier.toggleSelection(entry.mot),
        );
      },
    );
  }

  Widget _buildGrid(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
  ) {
    final alreadyAdded = widget.dictionaryId != null
        ? ref
                .watch(wordsInDictionaryProvider(widget.dictionaryId!))
                .valueOrNull ??
            const <String>{}
        : const <String>{};

    return LayoutBuilder(
      builder: (_, constraints) {
        final cols = (constraints.maxWidth / 110).floor().clamp(2, 8);
        return GridView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: 1.3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: state.results.length,
          itemBuilder: (_, i) {
            final entry = state.results[i];
            final selected = state.selected.contains(entry.mot);
            return ResultGridItem(
              key: ValueKey(entry.mot),
              entry: entry,
              isSelected: selected,
              isAlreadyAdded: alreadyAdded.contains(entry.mot),
              onTap: () => notifier.toggleSelection(entry.mot),
              onLongPress: () => showWordDetail(
                context,
                entry: entry,
                dictionaryId: widget.dictionaryId,
                onAdd: (e) => _addWord(e),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets internes
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.filterActive,
    required this.onFilterToggle,
    required this.sort,
    required this.onSortChanged,
    required this.gridView,
    required this.onViewToggle,
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final VoidCallback onClear;
  final bool filterActive;
  final VoidCallback onFilterToggle;
  final SearchSort sort;
  final void Function(SearchSort) onSortChanged;
  final bool gridView;
  final VoidCallback onViewToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Column(
        children: [
          // Barre de saisie
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Tapez un mot ou un fragment…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClear,
                      tooltip: 'Vider',
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: onChanged,
          ),
          const SizedBox(height: 4),
          // Contrôles
          Row(
            children: [
              // Filtres avancés
              Semantics(
                label: 'Filtres avancés',
                button: true,
                child: FilterChip(
                  label: const Text('Filtres'),
                  avatar: const Icon(Icons.tune, size: 16),
                  selected: filterActive,
                  onSelected: (_) => onFilterToggle(),
                ),
              ),
              const Spacer(),
              // Tri
              _SortMenu(sort: sort, onChanged: onSortChanged),
              const SizedBox(width: 8),
              // Bascule liste/grille
              IconButton(
                icon: Icon(gridView ? Icons.view_list : Icons.grid_view),
                onPressed: onViewToggle,
                tooltip: gridView ? 'Vue liste' : 'Vue grille',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.sort, required this.onChanged});
  final SearchSort sort;
  final void Function(SearchSort) onChanged;

  static const _labels = {
    SearchSort.alphabetique: 'Alphabétique',
    SearchSort.prevalence: 'Prévalence',
    SearchSort.frequence: 'Fréquence',
    SearchSort.syllabes: 'Syllabes',
    SearchSort.familiarite: 'Familiarité',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SearchSort>(
      initialValue: sort,
      onSelected: onChanged,
      child: Chip(
        avatar: const Icon(Icons.sort, size: 16),
        label: Text(_labels[sort] ?? 'Tri'),
      ),
      itemBuilder: (_) => SearchSort.values
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Text(_labels[s] ?? s.name),
            ),
          )
          .toList(),
    );
  }
}

class _ActiveFiltersBar extends ConsumerWidget {
  const _ActiveFiltersBar({required this.chips, required this.onClearAll});
  final List<FilterChipData> chips;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          ...chips.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InputChip(
                label: Text(c.label, style: const TextStyle(fontSize: 12)),
                onDeleted: () {
                  final newFilters = c.onRemove();
                  ref
                      .read(searchNotifierProvider.notifier)
                      .updateFilters(newFilters);
                },
                deleteIcon: const Icon(Icons.close, size: 14),
              ),
            ),
          ),
          TextButton(
            onPressed: onClearAll,
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.state, required this.onSelectAll});
  final SearchState state;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final total = state.totalCount;
    final shown = state.results.length;
    final label = total > shown
        ? '$shown / $total résultats (affinez vos critères)'
        : '$total résultat${total > 1 ? 's' : ''}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          if (state.results.isNotEmpty)
            TextButton(
              onPressed: onSelectAll,
              child: Text(
                state.selected.length == state.results.length
                    ? 'Tout désélectionner'
                    : 'Tout sélectionner',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            hasQuery
                ? 'Aucun mot ne correspond aux filtres.'
                : 'Commencez à taper pour rechercher.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
