// ============================================================
// Fichier : lib/features/dictionaries/screens/word_list_screen.dart
// Description : Écran praticien de gestion des mots d'un dictionnaire.
//               Vue orientée workflow avec recherche, filtres métier,
//               synthèse pédagogique, sélection multiple et panneau détail.
// ============================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/definitions_database.dart';
import '../../../core/database/lexique4_database.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/notifiers/auth_notifier.dart';
import '../services/media_service.dart';
import '../../search/presentation/widgets/word_detail_card.dart';
import 'add_edit_word_screen.dart';

enum _WordSortOrder { alphabetical, difficulty, recent }

enum _WordViewMode { compact, pedagogic }

enum _DifficultyFilter { all, easy, medium, hard }

enum _CompletenessFilter { all, complete, incomplete }

enum _MediaFilter { all, withImage, withAudio, withBoth, withoutMedia }

/// Liste des mots d'un dictionnaire orientée usage orthophoniste.
class WordListScreen extends ConsumerStatefulWidget {
  const WordListScreen({
    super.key,
    required this.dictionaryId,
    required this.dictionaryName,
  });

  final int dictionaryId;
  final String dictionaryName;

  @override
  ConsumerState<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends ConsumerState<WordListScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';
  final Set<int> _selected = <int>{};
  bool _selectionMode = false;
  bool _showFiltersOnNarrow = false;
  int? _focusedWordId;
  _WordSortOrder _sortOrder = _WordSortOrder.alphabetical;
  _WordViewMode _viewMode = _WordViewMode.compact;
  _DifficultyFilter _difficultyFilter = _DifficultyFilter.all;
  _CompletenessFilter _completenessFilter = _CompletenessFilter.all;
  _MediaFilter _mediaFilter = _MediaFilter.all;
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final nextQuery = _searchCtrl.text.trim().toLowerCase();
      if (nextQuery != _query) {
        final hadFocus = _searchFocusNode.hasFocus;
        setState(() => _query = nextQuery);
        if (hadFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_searchFocusNode.hasFocus) {
              _searchFocusNode.requestFocus();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearSearchQuery() {
    setState(() {
      _searchCtrl.clear();
      _query = '';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
      _selectionMode = _selected.isNotEmpty;
    });
  }

  void _clearSelection() {
    setState(() {
      _selected.clear();
      _selectionMode = false;
    });
  }

  void _setFocusedWord(Word? word) {
    setState(() {
      _focusedWordId = word?.id;
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selected.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Retirer $count mot${count > 1 ? 's' : ''} de la liste ?'),
        content: const Text(
          'Les mots sélectionnés seront supprimés de ce dictionnaire ainsi que la progression associée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final dao = ref.read(wordsDaoProvider);
      for (final id in List<int>.of(_selected)) {
        await dao.deleteWord(id);
      }
      _clearSelection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$count mot${count > 1 ? 's retirés de la liste' : ' retiré de la liste'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openAdd() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditWordScreen(dictionaryId: widget.dictionaryId),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _openEdit(Word word) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditWordScreen(
          dictionaryId: widget.dictionaryId,
          word: word,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _deleteWord(Word word) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retirer ce mot de la liste ?'),
        content: Text(
          '« ${word.mot} » sera supprimé de ce dictionnaire et sa progression associée sera retirée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(wordsDaoProvider).deleteWord(word.id);
      if (_focusedWordId == word.id) {
        _setFocusedWord(null);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('« ${word.mot} » retiré de la liste.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _selectAllVisible(List<Word> words) {
    setState(() {
      if (_selected.length == words.length) {
        _clearSelection();
      } else {
        _selected
          ..clear()
          ..addAll(words.map((word) => word.id));
        _selectionMode = true;
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _searchCtrl.clear();
      _query = '';
      _difficultyFilter = _DifficultyFilter.all;
      _completenessFilter = _CompletenessFilter.all;
      _mediaFilter = _MediaFilter.all;
      _selectedTag = null;
    });
  }

  List<Word> _applyFilters(List<Word> words) {
    var filtered = List<Word>.of(words);

    if (_query.isNotEmpty) {
      filtered = filtered.where((word) {
        final tags = _tagsForWord(word).join(' ').toLowerCase();
        final definition = (word.definition ?? '').toLowerCase();
        return word.mot.toLowerCase().contains(_query) ||
            definition.contains(_query) ||
            tags.contains(_query);
      }).toList();
    }

    filtered = filtered.where((word) {
      switch (_difficultyFilter) {
        case _DifficultyFilter.all:
          return true;
        case _DifficultyFilter.easy:
          return word.difficulty == 1;
        case _DifficultyFilter.medium:
          return word.difficulty == 2;
        case _DifficultyFilter.hard:
          return word.difficulty >= 3;
      }
    }).toList();

    filtered = filtered.where((word) {
      switch (_completenessFilter) {
        case _CompletenessFilter.all:
          return true;
        case _CompletenessFilter.complete:
          return _isComplete(word);
        case _CompletenessFilter.incomplete:
          return !_isComplete(word);
      }
    }).toList();

    filtered = filtered.where((word) {
      switch (_mediaFilter) {
        case _MediaFilter.all:
          return true;
        case _MediaFilter.withImage:
          return word.imagePath != null;
        case _MediaFilter.withAudio:
          return word.audioPath != null;
        case _MediaFilter.withBoth:
          return word.imagePath != null && word.audioPath != null;
        case _MediaFilter.withoutMedia:
          return word.imagePath == null && word.audioPath == null;
      }
    }).toList();

    if (_selectedTag != null) {
      filtered = filtered
          .where((word) => _tagsForWord(word).contains(_selectedTag))
          .toList();
    }

    filtered.sort(_buildSorter());
    return filtered;
  }

  int Function(Word, Word) _buildSorter() {
    switch (_sortOrder) {
      case _WordSortOrder.alphabetical:
        return (a, b) => a.mot.compareTo(b.mot);
      case _WordSortOrder.difficulty:
        return (a, b) {
          final result = a.difficulty.compareTo(b.difficulty);
          return result != 0 ? result : a.mot.compareTo(b.mot);
        };
      case _WordSortOrder.recent:
        return (a, b) => b.createdAt.compareTo(a.createdAt);
    }
  }

  List<String> _tagsForWord(Word word) {
    if (word.tags.isEmpty || word.tags == '[]') {
      return const <String>[];
    }
    try {
      final decoded = jsonDecode(word.tags);
      if (decoded is List) {
        return decoded
            .whereType<String>()
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }
    } catch (_) {
      return word.tags
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((tag) => tag.replaceAll('"', '').trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  bool _isComplete(Word word) {
    return (word.definition?.trim().isNotEmpty ?? false) &&
        word.imagePath != null &&
        word.audioPath != null;
  }

  _WordStats _computeStats(List<Word> words) {
    final tags = <String>{};
    var completeCount = 0;
    var imageCount = 0;
    var audioCount = 0;
    var definitionsCount = 0;
    for (final word in words) {
      tags.addAll(_tagsForWord(word));
      if (_isComplete(word)) completeCount++;
      if (word.imagePath != null) imageCount++;
      if (word.audioPath != null) audioCount++;
      if (word.definition?.trim().isNotEmpty ?? false) definitionsCount++;
    }
    return _WordStats(
      total: words.length,
      completeCount: completeCount,
      imageCount: imageCount,
      audioCount: audioCount,
      definitionsCount: definitionsCount,
      tagCount: tags.length,
      easyCount: words.where((word) => word.difficulty == 1).length,
      mediumCount: words.where((word) => word.difficulty == 2).length,
      hardCount: words.where((word) => word.difficulty >= 3).length,
    );
  }

  List<String> _availableTags(List<Word> words) {
    final tags = <String>{};
    for (final word in words) {
      tags.addAll(_tagsForWord(word));
    }
    final list = tags.toList()..sort();
    return list;
  }

  List<_FilterChipData> _activeFilters() {
    final chips = <_FilterChipData>[];
    if (_query.isNotEmpty) {
      chips.add(
        _FilterChipData(
          label: 'Recherche : ${_searchCtrl.text.trim()}',
          onDeleted: () {
            setState(
              () {
                _searchCtrl.clear();
                _query = '';
              },
            );
          },
        ),
      );
    }
    if (_difficultyFilter != _DifficultyFilter.all) {
      chips.add(
        _FilterChipData(
          label: 'Difficulté : ${_difficultyLabel(_difficultyFilter)}',
          onDeleted: () => setState(
            () => _difficultyFilter = _DifficultyFilter.all,
          ),
        ),
      );
    }
    if (_completenessFilter != _CompletenessFilter.all) {
      chips.add(
        _FilterChipData(
          label: 'Complétude : ${_completenessLabel(_completenessFilter)}',
          onDeleted: () => setState(
            () => _completenessFilter = _CompletenessFilter.all,
          ),
        ),
      );
    }
    if (_mediaFilter != _MediaFilter.all) {
      chips.add(
        _FilterChipData(
          label: 'Médias : ${_mediaLabel(_mediaFilter)}',
          onDeleted: () => setState(
            () => _mediaFilter = _MediaFilter.all,
          ),
        ),
      );
    }
    if (_selectedTag != null) {
      chips.add(
        _FilterChipData(
          label: 'Tag : $_selectedTag',
          onDeleted: () => setState(
            () => _selectedTag = null,
          ),
        ),
      );
    }
    return chips;
  }

  String _difficultyLabel(_DifficultyFilter filter) {
    switch (filter) {
      case _DifficultyFilter.all:
        return 'Toutes';
      case _DifficultyFilter.easy:
        return 'Facile';
      case _DifficultyFilter.medium:
        return 'Intermédiaire';
      case _DifficultyFilter.hard:
        return 'Difficile';
    }
  }

  String _completenessLabel(_CompletenessFilter filter) {
    switch (filter) {
      case _CompletenessFilter.all:
        return 'Tous';
      case _CompletenessFilter.complete:
        return 'Complets';
      case _CompletenessFilter.incomplete:
        return 'À compléter';
    }
  }

  String _mediaLabel(_MediaFilter filter) {
    switch (filter) {
      case _MediaFilter.all:
        return 'Tous';
      case _MediaFilter.withImage:
        return 'Avec image';
      case _MediaFilter.withAudio:
        return 'Avec audio';
      case _MediaFilter.withBoth:
        return 'Image + audio';
      case _MediaFilter.withoutMedia:
        return 'Sans média';
    }
  }

  String _sortLabel(_WordSortOrder order) {
    switch (order) {
      case _WordSortOrder.alphabetical:
        return 'Alphabétique';
      case _WordSortOrder.difficulty:
        return 'Difficulté';
      case _WordSortOrder.recent:
        return 'Plus récents';
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordsStream = ref
        .watch(wordsDaoProvider)
        .watchWordsForDictionary(widget.dictionaryId);

    return Scaffold(
      appBar: _selectionMode ? _selectionAppBar() : _defaultAppBar(),
      body: StreamBuilder<List<Word>>(
        stream: wordsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final allWords = snapshot.data ?? <Word>[];
          final filteredWords = _applyFilters(allWords);
          final stats = _computeStats(allWords);
          final tags = _availableTags(allWords);
          final activeFilters = _activeFilters();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1200;
              final isTablet = constraints.maxWidth >= 800;
              final showFilterPanel = isDesktop || _showFiltersOnNarrow;

              final listContent = _WordListPane(
                dictionaryName: widget.dictionaryName,
                totalWords: allWords.length,
                visibleWords: filteredWords,
                selectedIds: _selected,
                selectionMode: _selectionMode,
                viewMode: _viewMode,
                activeFilters: activeFilters,
                sortLabel: _sortLabel(_sortOrder),
                searchController: _searchCtrl,
                searchFocusNode: _searchFocusNode,
                onClearSearch: _clearSearchQuery,
                onClearAllFilters: _clearFilters,
                onToggleSelection: _toggleSelect,
                onOpenEdit: _openEdit,
                onOpenPreview: (word) {
                  _showWordPreviewSheet(word);
                },
                onDelete: _deleteWord,
                onAddWord: _openAdd,
                onSearchLexique: _openLexiqueSearch,
                onSelectAllVisible: () => _selectAllVisible(filteredWords),
                onToggleFilterPanel: isDesktop
                    ? null
                    : () => setState(
                          () => _showFiltersOnNarrow = !_showFiltersOnNarrow,
                        ),
                onToggleViewMode: () => setState(() {
                  _viewMode = _viewMode == _WordViewMode.compact
                      ? _WordViewMode.pedagogic
                      : _WordViewMode.compact;
                }),
                onSortChanged: (value) => setState(() => _sortOrder = value),
                showFilterToggle: !isDesktop,
                isFilterPanelOpen: _showFiltersOnNarrow,
              );

              final filterPanel = _FilterPanel(
                difficultyFilter: _difficultyFilter,
                completenessFilter: _completenessFilter,
                mediaFilter: _mediaFilter,
                selectedTag: _selectedTag,
                tags: tags,
                onDifficultyChanged: (value) =>
                    setState(() => _difficultyFilter = value),
                onCompletenessChanged: (value) =>
                    setState(() => _completenessFilter = value),
                onMediaChanged: (value) => setState(() => _mediaFilter = value),
                onTagChanged: (value) => setState(() => _selectedTag = value),
                onClearAll: _clearFilters,
              );

              final summary = _SummaryPanel(stats: stats);

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                        child: Column(
                          children: [
                            summary,
                            const SizedBox(height: 16),
                            filterPanel,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: listContent,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: summary,
                  ),
                  if (showFilterPanel)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: filterPanel,
                    ),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(16, 12, 16, isTablet ? 16 : 12),
                      child: listContent,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: _selectionMode
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'word_add_manual',
                  onPressed: _openAdd,
                  tooltip: 'Ajouter un mot',
                  child: const Icon(Icons.edit_outlined),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'word_search_lexique',
                  onPressed: _openLexiqueSearch,
                  icon: const Icon(Icons.manage_search),
                  label: const Text('Recherche dictionnaire'),
                ),
              ],
            ),
    );
  }

  /// Ouvre la fiche détaillée d'un mot en dialog (desktop) ou bottom sheet
  /// (mobile/tablette) en utilisant le même widget que la recherche lexique.
  Future<void> _showWordPreviewSheet(Word word) async {
    // Recherche de l'entrée Lexique 4 pour afficher les données linguistiques
    LexiqueEntry? lexEntry;
    try {
      final db = await ref.read(lexique4Provider.future);
      lexEntry = await db.getByMot(word.mot);
    } catch (_) {}
    // Repli minimal si le mot n'est pas dans lexique4.db
    final entry = lexEntry ?? LexiqueEntry(mot: word.mot, islem: 1);
    if (!mounted) return;
    showWordDetail(
      context,
      entry: entry,
      word: word,
      tags: _tagsForWord(word),
      onEdit: () {
        Navigator.of(context).pop();
        _openEdit(word);
      },
      onDelete: () {
        Navigator.of(context).pop();
        _deleteWord(word);
      },
    );
  }

  void _openLexiqueSearch() {
    context.push(
      '${AppRoutes.recherche}?dicId=${widget.dictionaryId}&dicName=${Uri.encodeComponent(widget.dictionaryName)}',
    );
  }

  /// Navigue vers l'écran complet de génération de fiches d'exercices.
  void _openExerciseSheet() {
    context.push(
      '/praticien/dictionnaires/${widget.dictionaryId}/fiches'
      '?nom=${Uri.encodeComponent(widget.dictionaryName)}',
    );
  }

  AppBar _defaultAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.dictionaryName),
          Text(
            'Gestion de la liste de mots',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        Semantics(
          label: 'Imprimer ou exporter les exercices en PDF',
          child: IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Imprimer / exporter les exercices',
            onPressed: _openExerciseSheet,
          ),
        ),
        Semantics(
          label: 'Partager ce dictionnaire',
          child: IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Partager',
            onPressed: () => context.push(
              '${AppRoutes.share}?dicId=${widget.dictionaryId}',
            ),
          ),
        ),
      ],
    );
  }

  AppBar _selectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Fermer la sélection',
        onPressed: _clearSelection,
      ),
      title: Text(
        '${_selected.length} mot${_selected.length > 1 ? 's sélectionnés' : ' sélectionné'}',
      ),
      actions: [
        TextButton(
          onPressed: _deleteSelected,
          child: const Text('Retirer'),
        ),
      ],
    );
  }
}

class _WordListPane extends StatelessWidget {
  const _WordListPane({
    required this.dictionaryName,
    required this.totalWords,
    required this.visibleWords,
    required this.selectedIds,
    required this.selectionMode,
    required this.viewMode,
    required this.activeFilters,
    required this.sortLabel,
    required this.searchController,
    required this.searchFocusNode,
    required this.onClearSearch,
    required this.onClearAllFilters,
    required this.onToggleSelection,
    required this.onOpenEdit,
    required this.onOpenPreview,
    required this.onDelete,
    required this.onAddWord,
    required this.onSearchLexique,
    required this.onSelectAllVisible,
    required this.onToggleFilterPanel,
    required this.onToggleViewMode,
    required this.onSortChanged,
    required this.showFilterToggle,
    required this.isFilterPanelOpen,
  });

  final String dictionaryName;
  final int totalWords;
  final List<Word> visibleWords;
  final Set<int> selectedIds;
  final bool selectionMode;
  final _WordViewMode viewMode;
  final List<_FilterChipData> activeFilters;
  final String sortLabel;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onClearSearch;
  final VoidCallback onClearAllFilters;
  final ValueChanged<int> onToggleSelection;
  final ValueChanged<Word> onOpenEdit;
  final ValueChanged<Word> onOpenPreview;
  final ValueChanged<Word> onDelete;
  final VoidCallback onAddWord;
  final VoidCallback onSearchLexique;
  final VoidCallback onSelectAllVisible;
  final VoidCallback? onToggleFilterPanel;
  final VoidCallback onToggleViewMode;
  final ValueChanged<_WordSortOrder> onSortChanged;
  final bool showFilterToggle;
  final bool isFilterPanelOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre tronqué + boutons sur la même ligne (sans débordement)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        dictionaryName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: onAddWord,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Préparez la séance, filtrez et gardez la liste lisible.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Barre de recherche principale
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Mot, tag ou définition…',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: onClearSearch,
                                  icon: const Icon(Icons.close),
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (showFilterToggle) ...[
                      const SizedBox(width: 8),
                      Semantics(
                        label: isFilterPanelOpen
                            ? 'Masquer les filtres'
                            : 'Afficher les filtres',
                        button: true,
                        child: OutlinedButton.icon(
                          onPressed: onToggleFilterPanel,
                          icon: Icon(
                            isFilterPanelOpen
                                ? Icons.tune
                                : Icons.tune_outlined,
                          ),
                          label: const Text('Filtres'),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Tri et mode d'affichage — scrollable horizontalement
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      PopupMenuButton<_WordSortOrder>(
                        tooltip: 'Trier la liste',
                        initialValue: _WordSortOrder.alphabetical,
                        onSelected: onSortChanged,
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _WordSortOrder.alphabetical,
                            child: Text('Alphabétique'),
                          ),
                          PopupMenuItem(
                            value: _WordSortOrder.difficulty,
                            child: Text('Par difficulté'),
                          ),
                          PopupMenuItem(
                            value: _WordSortOrder.recent,
                            child: Text('Plus récents'),
                          ),
                        ],
                        child: InputChip(
                          label: Text('Tri : $sortLabel'),
                          avatar: const Icon(Icons.swap_vert, size: 18),
                          onPressed: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(
                          viewMode == _WordViewMode.compact
                              ? 'Vue compacte'
                              : 'Vue pédagogique',
                        ),
                        selected: true,
                        onSelected: (_) => onToggleViewMode(),
                      ),
                    ],
                  ),
                ),
                if (activeFilters.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...activeFilters.map(
                        (chip) => InputChip(
                          label: Text(chip.label),
                          onDeleted: chip.onDeleted,
                        ),
                      ),
                      TextButton(
                        onPressed: onClearAllFilters,
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Text(
                  '${visibleWords.length} mot${visibleWords.length > 1 ? 's visibles' : ' visible'} sur $totalWords',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                if (selectionMode)
                  TextButton(
                    onPressed: onSelectAllVisible,
                    child: Text(
                      selectedIds.length == visibleWords.length
                          ? 'Tout décocher'
                          : 'Tout sélectionner',
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: visibleWords.isEmpty
                ? _EmptyWords(
                    hasQuery: activeFilters.isNotEmpty ||
                        searchController.text.isNotEmpty,
                    dictionaryId: 0,
                    dictionaryName: dictionaryName,
                    onAddWord: onAddWord,
                    onSearchLexique: onSearchLexique,
                    onClearFilters: onClearAllFilters,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: visibleWords.length,
                    itemBuilder: (context, index) {
                      final word = visibleWords[index];
                      return _WordTile(
                        word: word,
                        tags: _safeTags(word),
                        selected: selectedIds.contains(word.id),
                        selectionMode: selectionMode,
                        viewMode: viewMode,
                        onTap: () => selectionMode
                            ? onToggleSelection(word.id)
                            : onOpenPreview(word),
                        onLongPress: () => onToggleSelection(word.id),
                        onEdit: () => onOpenEdit(word),
                        onDelete: () => onDelete(word),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<String> _safeTags(Word word) {
    try {
      final decoded = jsonDecode(word.tags);
      if (decoded is List) {
        return decoded.whereType<String>().take(3).toList();
      }
    } catch (_) {
      return word.tags
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .map((tag) => tag.replaceAll('"', '').trim())
          .where((tag) => tag.isNotEmpty)
          .take(3)
          .toList();
    }
    return const <String>[];
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.difficultyFilter,
    required this.completenessFilter,
    required this.mediaFilter,
    required this.selectedTag,
    required this.tags,
    required this.onDifficultyChanged,
    required this.onCompletenessChanged,
    required this.onMediaChanged,
    required this.onTagChanged,
    required this.onClearAll,
  });

  final _DifficultyFilter difficultyFilter;
  final _CompletenessFilter completenessFilter;
  final _MediaFilter mediaFilter;
  final String? selectedTag;
  final List<String> tags;
  final ValueChanged<_DifficultyFilter> onDifficultyChanged;
  final ValueChanged<_CompletenessFilter> onCompletenessChanged;
  final ValueChanged<_MediaFilter> onMediaChanged;
  final ValueChanged<String?> onTagChanged;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Filtres métier',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClearAll,
                  child: const Text('Tout effacer'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PanelSection<_DifficultyFilter>(
              title: 'Difficulté',
              value: difficultyFilter,
              options: const {
                _DifficultyFilter.all: 'Toutes',
                _DifficultyFilter.easy: 'Facile',
                _DifficultyFilter.medium: 'Intermédiaire',
                _DifficultyFilter.hard: 'Difficile',
              },
              onChanged: onDifficultyChanged,
            ),
            const SizedBox(height: 16),
            _PanelSection<_CompletenessFilter>(
              title: 'Complétude',
              value: completenessFilter,
              options: const {
                _CompletenessFilter.all: 'Tous',
                _CompletenessFilter.complete: 'Complets',
                _CompletenessFilter.incomplete: 'À compléter',
              },
              onChanged: onCompletenessChanged,
            ),
            const SizedBox(height: 16),
            _PanelSection<_MediaFilter>(
              title: 'Médias',
              value: mediaFilter,
              options: const {
                _MediaFilter.all: 'Tous',
                _MediaFilter.withImage: 'Avec image',
                _MediaFilter.withAudio: 'Avec audio',
                _MediaFilter.withBoth: 'Image + audio',
                _MediaFilter.withoutMedia: 'Sans média',
              },
              onChanged: onMediaChanged,
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Tags thérapeutiques',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tous'),
                    selected: selectedTag == null,
                    onSelected: (_) => onTagChanged(null),
                  ),
                  ...tags.map(
                    (tag) => ChoiceChip(
                      label: Text(tag),
                      selected: selectedTag == tag,
                      onSelected: (_) => onTagChanged(tag),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PanelSection<T> extends StatelessWidget {
  const _PanelSection({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries
              .map(
                (entry) => ChoiceChip(
                  label: Text(entry.value),
                  selected: value == entry.key,
                  onSelected: (_) => onChanged(entry.key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.stats});

  final _WordStats stats;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilotage pédagogique',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Repérez rapidement les mots déjà exploitables et ceux à compléter avant la séance.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                  label: 'Mots',
                  value: '${stats.total}',
                  icon: Icons.list_alt,
                ),
                _StatCard(
                  label: 'Complets',
                  value: '${stats.completeCount}',
                  icon: Icons.task_alt,
                ),
                _StatCard(
                  label: 'Avec image',
                  value: '${stats.imageCount}',
                  icon: Icons.image_outlined,
                ),
                _StatCard(
                  label: 'Avec audio',
                  value: '${stats.audioCount}',
                  icon: Icons.mic_none,
                ),
                _StatCard(
                  label: 'Définitions',
                  value: '${stats.definitionsCount}',
                  icon: Icons.subject,
                ),
                _StatCard(
                  label: 'Tags',
                  value: '${stats.tagCount}',
                  icon: Icons.sell_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LevelChip(
                  label: 'Facile',
                  count: stats.easyCount,
                  color: const Color(0xFF2E7D32),
                ),
                _LevelChip(
                  label: 'Intermédiaire',
                  count: stats.mediumCount,
                  color: const Color(0xFFF9A825),
                ),
                _LevelChip(
                  label: 'Difficile',
                  count: stats.hardCount,
                  color: const Color(0xFFC62828),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(110),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(height: 10),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Opacité renforcée en thème sombre pour maintenir la lisibilité
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 45 : 24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(isDark ? 160 : 90)),
      ),
      child: Text('$label : $count'),
    );
  }
}

class _WordTile extends ConsumerWidget {
  const _WordTile({
    required this.word,
    required this.tags,
    required this.selected,
    required this.selectionMode,
    required this.viewMode,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  final Word word;
  final List<String> tags;
  final bool selected;
  final bool selectionMode;
  final _WordViewMode viewMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _isComplete =>
      (word.definition?.trim().isNotEmpty ?? false) &&
      word.imagePath != null &&
      word.audioPath != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Mot ${word.mot}',
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withAlpha(26)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withAlpha(120)
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                selectionMode
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Icon(
                          selected ? Icons.check_circle : Icons.circle_outlined,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                      )
                    : _WordThumbnail(imagePath: word.imagePath),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              word.mot.toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          _CompletenessBadge(isComplete: _isComplete),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (viewMode == _WordViewMode.pedagogic &&
                          (word.definition?.trim().isNotEmpty ?? false))
                        Text(
                          word.definition!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        )
                      else
                        Text(
                          _pedagogicHint(word),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _metaChip(
                            theme,
                            Icons.stars_rounded,
                            'Niveau ${word.difficulty}',
                          ),
                          if (tags.isNotEmpty)
                            ...tags.map(
                              (tag) => _metaChip(
                                theme,
                                Icons.sell_outlined,
                                tag,
                              ),
                            ),
                          _metaChip(
                            theme,
                            word.imagePath != null
                                ? Icons.image_outlined
                                : Icons.hide_image_outlined,
                            word.imagePath != null ? 'Image' : 'Sans image',
                          ),
                          _metaChip(
                            theme,
                            word.audioPath != null ? Icons.mic : Icons.mic_off,
                            word.audioPath != null ? 'Audio' : 'Sans audio',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!selectionMode) ...[
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Semantics(
                        label: 'Prononcer ${word.mot}',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.volume_up_outlined),
                          tooltip: 'Prononcer le mot',
                          color: theme.colorScheme.primary,
                          onPressed: () async {
                            final tts = ref.read(ttsServiceProvider);
                            // Récupérer phonoIpa depuis lexique4.db pour la
                            // prononciation MBROLA via eSpeak NG
                            final lexDb =
                                await ref.read(lexique4Provider.future);
                            final entry = await lexDb.getByMot(word.mot);
                            await tts.speakPhonetic(
                              word: word.mot,
                              phonoIpa: entry?.phonoIpa,
                            );
                          },
                        ),
                      ),
                      Semantics(
                        label: 'Modifier ${word.mot}',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Modifier ce mot',
                          onPressed: onEdit,
                        ),
                      ),
                      Semantics(
                        label: 'Retirer ${word.mot} de la liste',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Retirer ce mot',
                          color: theme.colorScheme.error,
                          onPressed: onDelete,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _pedagogicHint(Word word) {
    if (word.definition?.trim().isNotEmpty ?? false) {
      return 'Définition disponible';
    }
    if (word.audioPath != null || word.imagePath != null) {
      return 'Support partiel à compléter';
    }
    return 'Aucun support ajouté pour le moment';
  }

  Widget _metaChip(ThemeData theme, IconData icon, String label) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(110),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CompletenessBadge extends StatelessWidget {
  const _CompletenessBadge({required this.isComplete});

  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    // Couleurs adaptées au thème clair/sombre pour un contraste suffisant
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isComplete
        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
        : (isDark ? const Color(0xFFFFB74D) : const Color(0xFFEF6C00));
    final label = isComplete ? 'Prêt' : 'À compléter';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 45 : 24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(isDark ? 160 : 90)),
      ),
      child: Text(label),
    );
  }
}

class _WordThumbnail extends ConsumerWidget {
  const _WordThumbnail({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imagePath == null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.image_outlined, color: Colors.grey),
      );
    }
    return FutureBuilder<String>(
      future: ref.read(mediaServiceProvider).absoluteImagePath(imagePath!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(snapshot.data!),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Données asynchrones enrichies pour le panneau détail
// ---------------------------------------------------------------------------

class _WordPanelData {
  const _WordPanelData({this.lexiqueEntry, this.defEntry, this.mastery});

  /// Données linguistiques (phonétique IPA, catégorie, syllabes…) — lexique4.db
  final LexiqueEntry? lexiqueEntry;

  /// Définition de référence + niveau Dubois-Buyse (1–43) — definitions.db
  final DefinitionEntry? defEntry;

  /// Progression Leitner du praticien connecté — app.db
  final WordMasteryData? mastery;
}

// ---------------------------------------------------------------------------
// Panneau détail d'un mot — refonte UI/UX praticien
// ---------------------------------------------------------------------------

/// Panneau latéral (desktop) ou bottom-sheet (mobile/tablette) affichant
/// l'ensemble des informations cliniques et pédagogiques d'un mot.
class _WordDetailPanel extends ConsumerStatefulWidget {
  const _WordDetailPanel({
    required this.word,
    required this.tagsBuilder,
    required this.onEdit,
    required this.onDelete,
  });

  final Word? word;
  final List<String> Function(Word word) tagsBuilder;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  ConsumerState<_WordDetailPanel> createState() => _WordDetailPanelState();
}

class _WordDetailPanelState extends ConsumerState<_WordDetailPanel> {
  Future<_WordPanelData>? _dataFuture;

  @override
  void initState() {
    super.initState();
    if (widget.word != null) _dataFuture = _loadAsync(widget.word!);
  }

  @override
  void didUpdateWidget(covariant _WordDetailPanel old) {
    super.didUpdateWidget(old);
    if (widget.word?.id != old.word?.id) {
      setState(() {
        _dataFuture = widget.word != null ? _loadAsync(widget.word!) : null;
      });
    }
  }

  Future<_WordPanelData> _loadAsync(Word w) async {
    try {
      final profileId = switch (ref.read(authNotifierProvider)) {
        PractitionerAuth(profile: final p) => p.id,
        _ => null,
      };
      // Chargement parallèle des deux bases en lecture seule
      final results = await Future.wait([
        ref.read(lexique4Provider.future).then((db) => db.getByMot(w.mot)),
        ref
            .read(definitionsProvider.future)
            .then((db) => db.getDefinition(w.mot)),
      ]);
      final lexEntry = results[0] as LexiqueEntry?;
      final defEntry = results[1] as DefinitionEntry?;
      final mastery = profileId != null
          ? await ref.read(wordsDaoProvider).getMastery(w.id, profileId)
          : null;
      return _WordPanelData(
        lexiqueEntry: lexEntry,
        defEntry: defEntry,
        mastery: mastery,
      );
    } catch (_) {
      return const _WordPanelData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ── État vide ──────────────────────────────────────────────────────────
    if (widget.word == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.touch_app_outlined,
                color: theme.colorScheme.onSurface.withAlpha(90),
              ),
              const SizedBox(height: 12),
              Text(
                'Sélectionnez un mot pour voir sa fiche détaillée.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(140),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final w = widget.word!;
    final tags = widget.tagsBuilder(w);
    final hasDefinition = w.definition?.trim().isNotEmpty ?? false;
    final hasCroises = w.defCroises?.trim().isNotEmpty ?? false;
    final hasFleches = w.defFleches?.trim().isNotEmpty ?? false;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image plein-largeur ───────────────────────────────────────
            _DetailImageHeader(imagePath: w.imagePath),

            // ── Corps scrollable ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: FutureBuilder<_WordPanelData>(
                future: _dataFuture,
                builder: (context, snap) {
                  final data = snap.data;
                  final entry = data?.lexiqueEntry;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Titre + phonétique IPA + TTS + badge ───────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w.mot.toUpperCase(),
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (entry?.phonoIpa != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '/${entry!.phonoIpa}/',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          _CompletenessBadge(
                            isComplete: hasDefinition &&
                                w.imagePath != null &&
                                w.audioPath != null,
                          ),
                          Semantics(
                            label: 'Prononcer ${w.mot}',
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.volume_up_outlined),
                              color: theme.colorScheme.primary,
                              tooltip: 'Prononcer',
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(ttsServiceProvider)
                                      .speakPhonetic(
                                        word: w.mot,
                                        phonoIpa: entry?.phonoIpa,
                                      );
                                } catch (_) {}
                              },
                            ),
                          ),
                        ],
                      ),

                      // ── Métadonnées linguistiques (Lexique 4) ──────
                      if (entry != null) ...[
                        const SizedBox(height: 8),
                        _LinguisticChips(
                          entry: entry,
                          theme: theme,
                          isDark: isDark,
                        ),
                      ],

                      // Niveau Dubois-Buyse (definitions.db)
                      if (data?.defEntry?.niveauDubois != null) ...[
                        const SizedBox(height: 10),
                        _DuboisBuyseLevel(
                          niveau: data!.defEntry!.niveauDubois!,
                          theme: theme,
                          isDark: isDark,
                        ),
                      ],

                      const SizedBox(height: 12),
                      _DifficultyStars(difficulty: w.difficulty, theme: theme),

                      // ── Progression Leitner / SRS ─────────────────
                      const SizedBox(height: 16),
                      if (data?.mastery != null)
                        _LeitnerSection(
                          mastery: data!.mastery!,
                          theme: theme,
                          isDark: isDark,
                        )
                      else
                        _DetailSectionTitle(
                          title: 'Progression',
                          child: Text(
                            snap.connectionState == ConnectionState.done
                                ? 'Pas encore présenté en séance.'
                                : '…',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),

                      // ── Qualité du support ────────────────────────
                      const SizedBox(height: 16),
                      _DetailSectionTitle(
                        title: 'Support',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _supportBadge(
                              theme,
                              isDark,
                              active: hasDefinition,
                              label: 'Définition',
                              icon: Icons.subject,
                            ),
                            _supportBadge(
                              theme,
                              isDark,
                              active: w.imagePath != null,
                              label: 'Image',
                              icon: Icons.image_outlined,
                            ),
                            _supportBadge(
                              theme,
                              isDark,
                              active: w.audioPath != null,
                              label: 'Audio',
                              icon: Icons.mic_none,
                              onPlay: w.audioPath != null
                                  ? () async {
                                      try {
                                        await ref
                                            .read(mediaServiceProvider)
                                            .playAudio(w.audioPath!);
                                      } catch (_) {}
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      // ── Définition complète ───────────────────────
                      const SizedBox(height: 16),
                      _DetailSectionTitle(
                        title: 'Définition',
                        child: hasDefinition
                            ? Text(
                                w.definition!,
                                style: theme.textTheme.bodyMedium,
                              )
                            : data?.defEntry?.definition != null
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data!.defEntry!.definition!,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Source : bibliotheque de reference',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withAlpha(100),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Aucune définition renseignée.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withAlpha(100),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                      ),

                      // ── Définitions courtes (croisés + fléchés) ───
                      if (hasCroises || hasFleches) ...[
                        const SizedBox(height: 10),
                        if (hasCroises)
                          _ShortDefRow(
                            icon: Icons.grid_on,
                            label: 'Croisés',
                            text: w.defCroises!,
                            theme: theme,
                          ),
                        if (hasCroises && hasFleches) const SizedBox(height: 6),
                        if (hasFleches)
                          _ShortDefRow(
                            icon: Icons.arrow_forward,
                            label: 'Fléchés',
                            text: w.defFleches!,
                            theme: theme,
                          ),
                      ] else if (data?.defEntry != null &&
                          (data!.defEntry?.defCroises != null ||
                              data.defEntry?.defFleches != null)) ...[
                        // Fallback depuis definitions.db si non saisis manuellement
                        const SizedBox(height: 10),
                        if (data.defEntry?.defCroises != null)
                          _ShortDefRow(
                            icon: Icons.grid_on,
                            label: 'Croisés',
                            text: data.defEntry!.defCroises!,
                            theme: theme,
                          ),
                        if (data.defEntry?.defCroises != null &&
                            data.defEntry?.defFleches != null)
                          const SizedBox(height: 6),
                        if (data.defEntry?.defFleches != null)
                          _ShortDefRow(
                            icon: Icons.arrow_forward,
                            label: 'Fléchés',
                            text: data.defEntry!.defFleches!,
                            theme: theme,
                          ),
                      ],

                      // ── Étiquettes thérapeutiques ─────────────────
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _DetailSectionTitle(
                          title: 'Étiquettes',
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tags
                                .map(
                                  (t) => Chip(
                                    label: Text(t),
                                    avatar: const Icon(
                                      Icons.sell_outlined,
                                      size: 13,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],

                      // ── Date d'ajout ──────────────────────────────
                      const SizedBox(height: 12),
                      Text(
                        'Ajouté le ${_fmtDate(w.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(100),
                        ),
                      ),

                      // ── Boutons d'action ──────────────────────────
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: widget.onEdit,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Modifier'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side:
                                    BorderSide(color: theme.colorScheme.error),
                              ),
                              onPressed: widget.onDelete,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Retirer'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportBadge(
    ThemeData theme,
    bool isDark, {
    required bool active,
    required String label,
    required IconData icon,
    VoidCallback? onPlay,
  }) {
    final color = active
        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
        : (isDark ? const Color(0xFFFFB74D) : const Color(0xFFEF6C00));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 45 : 22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(isDark ? 150 : 90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? icon : Icons.warning_amber_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
          if (onPlay != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onPlay,
              child: Icon(
                Icons.play_circle_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ---------------------------------------------------------------------------
// Sous-widgets du panneau détail
// ---------------------------------------------------------------------------

/// Image plein-largeur en haut du panneau.
class _DetailImageHeader extends ConsumerWidget {
  const _DetailImageHeader({this.imagePath});
  final String? imagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    final onSurface = Theme.of(context).colorScheme.onSurface.withAlpha(60);
    if (imagePath == null) {
      return Container(
        height: 120,
        color: bg,
        child: Center(
          child: Icon(Icons.image_outlined, size: 44, color: onSurface),
        ),
      );
    }
    return FutureBuilder<String>(
      future: ref.read(mediaServiceProvider).absoluteImagePath(imagePath!),
      builder: (_, snap) {
        if (!snap.hasData) return Container(height: 120, color: bg);
        return Image.file(
          File(snap.data!),
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

/// Titre de section uppercase + couleur primaire.
class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle({
    required this.title,
    required this.child,
  });
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

/// Chips de métadonnées linguistiques issues de Lexique 4.
class _LinguisticChips extends StatelessWidget {
  const _LinguisticChips({
    required this.entry,
    required this.theme,
    required this.isDark,
  });
  final LexiqueEntry entry;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      if (entry.cgramOrtho?.isNotEmpty ?? false)
        (Icons.category_outlined, entry.cgramOrtho!),
      if (entry.nbsyll != null)
        (Icons.music_note_outlined, '${entry.nbsyll} syll.'),
      if (entry.nbphons != null)
        (Icons.record_voice_over_outlined, '${entry.nbphons} phon.'),
      if (entry.cvortho?.isNotEmpty ?? false)
        (Icons.text_fields, entry.cvortho!),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color:
                theme.colorScheme.primaryContainer.withAlpha(isDark ? 80 : 50),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: theme.colorScheme.primary.withAlpha(40)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.$1, size: 13, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                item.$2,
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Badge affichant le niveau Dubois-Buyse (1–43) issu de definitions.db.
/// Indique l'année scolaire de référence du mot selon la liste Dubois-Buyse.
class _DuboisBuyseLevel extends StatelessWidget {
  const _DuboisBuyseLevel({
    required this.niveau,
    required this.theme,
    required this.isDark,
  });
  final int niveau;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Niveau 1–5 : CP→CE2, 6–10 : CM, 11–17 : collège, 18+ : lycée/adulte
    final Color color;
    final String label;
    if (niveau <= 5) {
      color = isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
      label = 'Niveau $niveau — Primaire (CP–CE2)';
    } else if (niveau <= 10) {
      color = isDark ? const Color(0xFF4FC3F7) : const Color(0xFF0277BD);
      label = 'Niveau $niveau — Primaire (CM)';
    } else if (niveau <= 17) {
      color = isDark ? const Color(0xFFFFD54F) : const Color(0xFFF9A825);
      label = 'Niveau $niveau — Collège';
    } else {
      color = isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828);
      label = 'Niveau $niveau — Lycée / Adulte';
    }
    return Semantics(
      label: 'Niveau Dubois-Buyse : $label',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Étoiles de difficulté 1-3.
class _DifficultyStars extends StatelessWidget {
  const _DifficultyStars({required this.difficulty, required this.theme});
  final int difficulty;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    const labels = {1: 'Facile', 2: 'Intermédiaire', 3: 'Difficile'};
    const colors = {
      1: Color(0xFF2E7D32),
      2: Color(0xFFF9A825),
      3: Color(0xFFC62828),
    };
    final color = colors[difficulty] ?? theme.colorScheme.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 3; i++)
          Icon(
            i <= difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 20,
            color: color,
          ),
        const SizedBox(width: 6),
        Text(
          labels[difficulty] ?? 'N/D',
          style: theme.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}

/// Barre de progression Leitner (1-5 boîtes) + statistiques SRS.
class _LeitnerSection extends StatelessWidget {
  const _LeitnerSection({
    required this.mastery,
    required this.theme,
    required this.isDark,
  });
  final WordMasteryData mastery;
  final ThemeData theme;
  final bool isDark;

  static const _boxColors = [
    Color(0xFFC62828),
    Color(0xFFEF6C00),
    Color(0xFFF9A825),
    Color(0xFF388E3C),
    Color(0xFF1B5E20),
  ];

  @override
  Widget build(BuildContext context) {
    final box = mastery.leitnerBox.clamp(1, 5);
    final seen = mastery.nbSeen;
    final success = mastery.nbSuccess;
    final pct = seen > 0 ? (success / seen * 100).round() : 0;

    return _DetailSectionTitle(
      title: 'Progression Leitner',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de 5 boîtes colorées
          Row(
            children: List.generate(5, (i) {
              final filled = i < box;
              final c = _boxColors[i];
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 10,
                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: filled ? c : c.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: c.withAlpha(isDark ? 120 : 70)),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Boîte $box / 5',
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                'Maîtrise ${mastery.masteryLevel} / 4',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _stat(
                Icons.remove_red_eye_outlined,
                '$seen présenté${seen > 1 ? 's' : ''}',
              ),
              _stat(
                Icons.check_circle_outline,
                '$success réussite${success > 1 ? 's' : ''}'
                ' ($pct%)',
              ),
              if (mastery.consecutiveOk > 0)
                _stat(
                    Icons.local_fire_department_outlined,
                    '${mastery.consecutiveOk}× consécutif'
                    '${mastery.consecutiveOk > 1 ? 's' : ''}'),
              if (mastery.nextReview != null)
                _stat(
                    Icons.event_available_outlined,
                    'Révision : '
                    '${_fmtDate(mastery.nextReview!)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurface.withAlpha(140),
          ),
          const SizedBox(width: 4),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      );

  static String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// Ligne de définition courte (mots croisés ou mots fléchés).
class _ShortDefRow extends StatelessWidget {
  const _ShortDefRow({
    required this.icon,
    required this.label,
    required this.text,
    required this.theme,
  });
  final IconData icon;
  final String label;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall,
              children: [
                TextSpan(
                  text: '$label : ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyWords extends StatelessWidget {
  const _EmptyWords({
    required this.hasQuery,
    required this.dictionaryId,
    required this.dictionaryName,
    required this.onAddWord,
    required this.onSearchLexique,
    required this.onClearFilters,
  });

  final bool hasQuery;
  final int dictionaryId;
  final String dictionaryName;
  final VoidCallback onAddWord;
  final VoidCallback onSearchLexique;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off : Icons.menu_book_outlined,
              size: 60,
              color: Theme.of(context).colorScheme.primary.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery
                  ? 'Aucun mot ne correspond aux critères actuels'
                  : 'Cette liste est encore vide',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Retirez un filtre ou élargissez la recherche pour retrouver des mots exploitables.'
                  : 'Ajoutez quelques mots manuellement ou ouvrez Lexique 4 pour construire rapidement une première sélection.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (hasQuery)
              FilledButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Réinitialiser les filtres'),
              )
            else ...[
              FilledButton.icon(
                onPressed: onSearchLexique,
                icon: const Icon(Icons.manage_search),
                label: const Text('Recherche dictionnaire'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onAddWord,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Ajouter manuellement'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChipData {
  const _FilterChipData({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;
}

class _WordStats {
  const _WordStats({
    required this.total,
    required this.completeCount,
    required this.imageCount,
    required this.audioCount,
    required this.definitionsCount,
    required this.tagCount,
    required this.easyCount,
    required this.mediumCount,
    required this.hardCount,
  });

  final int total;
  final int completeCount;
  final int imageCount;
  final int audioCount;
  final int definitionsCount;
  final int tagCount;
  final int easyCount;
  final int mediumCount;
  final int hardCount;
}
