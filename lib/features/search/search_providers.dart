// ============================================================
// Fichier : lib/features/search/search_providers.dart
// Description : Providers Riverpod pour le moteur de recherche J05.
//               SearchStateNotifier gère filtres + sélection.
//               Le debounce est géré dans le widget (Timer).
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import '../../core/database/lexique4_database.dart';
import '../dictionaries/services/definitions_service.dart';
import 'data/lexique4_repository.dart';
import 'data/search_filters_model.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Provider du repository de recherche — dépend du singleton Lexique4Database.
final lexique4RepositoryProvider =
    FutureProvider<Lexique4Repository>((ref) async {
  final db = await ref.watch(lexique4Provider.future);
  return Lexique4Repository(db);
});

// ---------------------------------------------------------------------------
// État de recherche
// ---------------------------------------------------------------------------

/// État global de l'écran de recherche.
class SearchState {
  const SearchState({
    this.filters = const SearchFilters(),
    this.results = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.error,
    this.selected = const {},
    this.filterPanelOpen = false,
  });

  final SearchFilters filters;

  /// Résultats de la page courante.
  final List<LexiqueEntry> results;

  /// Nombre total de résultats (toutes pages).
  final int totalCount;

  final bool isLoading;
  final String? error;

  /// Mots sélectionnés pour l'ajout en lot (Set de `mot`).
  final Set<String> selected;

  /// Panneau filtres ouvert ?
  final bool filterPanelOpen;

  bool get hasSelection => selected.isNotEmpty;

  SearchState copyWith({
    SearchFilters? filters,
    List<LexiqueEntry>? results,
    int? totalCount,
    bool? isLoading,
    String? error,
    Set<String>? selected,
    bool? filterPanelOpen,
  }) {
    return SearchState(
      filters: filters ?? this.filters,
      results: results ?? this.results,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selected: selected ?? this.selected,
      filterPanelOpen: filterPanelOpen ?? this.filterPanelOpen,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Notifier principal de l'écran de recherche.
/// Le widget appelle [updateFilters] ou [setTextQuery] après le debounce.
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._repoFuture, this._definitionsService)
      : super(const SearchState());

  final Future<Lexique4Repository> _repoFuture;
  final DefinitionsService _definitionsService;

  /// Cache des mots de definitions.db (chargé une seule fois).
  Set<String>? _cachedDefWords;

  /// Charge et met en cache les mots de definitions.db.
  Future<Set<String>> _getDefinitionWords() async {
    _cachedDefWords ??= await _definitionsService.getAllWords();
    return _cachedDefWords!;
  }

  // ---------------------------------------------------------------------------
  // Filtres
  // ---------------------------------------------------------------------------

  /// Met à jour les filtres et relance la recherche.
  Future<void> updateFilters(SearchFilters filters) async {
    state = state.copyWith(
      filters: filters.copyWith(page: 0),
      isLoading: true,
      error: null,
    );
    await _runSearch();
  }

  /// Met à jour uniquement le texte de recherche (après debounce dans le widget).
  Future<void> setTextQuery(String query) async {
    final newFilters = state.filters.copyWith(textQuery: query, page: 0);
    state = state.copyWith(filters: newFilters, isLoading: true, error: null);
    await _runSearch();
  }

  /// Active ou désactive un raccourci prédéfini (multi-sélection).
  Future<void> applyQuickSearch(QuickSearch qs) async {
    final current = List<String>.from(state.filters.rawWheres);
    if (current.contains(qs.whereClause)) {
      current.remove(qs.whereClause);
    } else {
      current.add(qs.whereClause);
    }
    final newFilters = state.filters.copyWith(rawWheres: current, page: 0);
    state = state.copyWith(filters: newFilters, isLoading: true, error: null);
    await _runSearch();
  }

  /// Réinitialise tous les filtres.
  Future<void> resetFilters() async {
    final reset = state.filters.reset();
    state = state.copyWith(
      filters: reset,
      results: [],
      totalCount: 0,
      isLoading: false,
      error: null,
    );
  }

  /// Ouvre/ferme le panneau filtres avancés.
  void toggleFilterPanel() {
    state = state.copyWith(filterPanelOpen: !state.filterPanelOpen);
  }

  /// Bascule vue liste / grille.
  void toggleGridView() {
    final newFilters =
        state.filters.copyWith(gridView: !state.filters.gridView);
    state = state.copyWith(filters: newFilters);
  }

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  /// Charge la page suivante si disponible.
  Future<void> loadNextPage() async {
    final current = state.filters;
    final hasMore = (current.page + 1) * current.pageSize < state.totalCount;
    if (!hasMore || state.isLoading) return;

    final newFilters = current.copyWith(page: current.page + 1);
    state = state.copyWith(filters: newFilters, isLoading: true);
    try {
      final repo = await _repoFuture;
      final defWords = await _getDefinitionWords();
      final result = await repo.search(
        newFilters,
        restrictToWords: defWords.isNotEmpty ? defWords : null,
      );
      state = state.copyWith(
        results: [...state.results, ...result.entries],
        totalCount: result.totalCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de pagination : $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Sélection
  // ---------------------------------------------------------------------------

  /// Bascule la sélection d'un mot.
  void toggleSelection(String mot) {
    final sel = Set<String>.from(state.selected);
    if (sel.contains(mot)) {
      sel.remove(mot);
    } else {
      sel.add(mot);
    }
    state = state.copyWith(selected: sel);
  }

  /// Sélectionne/désélectionne tous les résultats visibles.
  void toggleSelectAll() {
    if (state.selected.length == state.results.length) {
      state = state.copyWith(selected: {});
    } else {
      final all = state.results.map((e) => e.mot).toSet();
      state = state.copyWith(selected: all);
    }
  }

  /// Vide la sélection.
  void clearSelection() {
    state = state.copyWith(selected: {});
  }

  // ---------------------------------------------------------------------------
  // Requête interne
  // ---------------------------------------------------------------------------

  Future<void> _runSearch() async {
    try {
      final repo = await _repoFuture;
      final defWords = await _getDefinitionWords();
      final result = await repo.search(
        state.filters,
        restrictToWords: defWords.isNotEmpty ? defWords : null,
      );
      state = state.copyWith(
        results: result.entries,
        totalCount: result.totalCount,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de recherche : $e',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Provider principal
// ---------------------------------------------------------------------------

/// Provider de l'état de recherche.
/// Le widget [SearchScreen] le lit et écrit via [ref.read(...notifier)].
final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repoFuture = ref.watch(lexique4Provider.future).then(
        (db) => Lexique4Repository(db),
      );
  final defService = ref.watch(definitionsServiceProvider);
  return SearchNotifier(repoFuture, defService);
});

// ---------------------------------------------------------------------------
// Provider famille de mots (pour word_detail_card)
// ---------------------------------------------------------------------------

/// Retourne la famille de mots pour un fragment de morphodecomp donné.
final wordFamilyProvider =
    FutureProvider.family<List<LexiqueEntry>, String>((ref, morphoRoot) async {
  final repo = await ref.watch(lexique4RepositoryProvider.future);
  return repo.getWordFamily(morphoRoot: morphoRoot);
});

/// Retourne les voisins orthographiques d'un mot.
final orthographicNeighborsProvider =
    FutureProvider.family<List<LexiqueEntry>, String>((ref, mot) async {
  final repo = await ref.watch(lexique4RepositoryProvider.future);
  return repo.getOrthographicNeighbors(mot: mot);
});

// ---------------------------------------------------------------------------
// Provider définitions (pour word_detail_card)
// ---------------------------------------------------------------------------

/// Retourne la définition d'un mot depuis definitions.db, ou null.
final definitionProvider =
    FutureProvider.family<DefinitionEntry?, String>((ref, mot) async {
  final svc = ref.watch(definitionsServiceProvider);
  return svc.findDefinition(mot);
});

// ---------------------------------------------------------------------------
// Provider phonèmes des mots de definitions.db
// ---------------------------------------------------------------------------

/// Codes SAMPA distincts présents dans les transcriptions phono des mots
/// de definitions.db (jointure avec lexique4.db, islem = 1).
/// Calculé une seule fois et mis en cache par Riverpod.
final definitionPhonemesProvider = FutureProvider<Set<String>>((ref) async {
  final defDb = await ref.watch(definitionsProvider.future);
  final lexDb = await ref.watch(lexique4Provider.future);

  // 1. Tous les mots de definitions.db
  final defWords = await defDb.getAllWords();

  // 2. Valeurs phono SAMPA pour ces mots dans lexique4.db (par lots de 900)
  final phonoValues = await lexDb.getPhonoForWords(defWords);

  // 3. Extraction des phonèmes individuels (chaque caractère SAMPA = 1 phonème)
  final distinct = <String>{};
  for (final phono in phonoValues) {
    for (final ch in phono.split('')) {
      distinct.add(ch);
    }
  }
  return distinct;
});
