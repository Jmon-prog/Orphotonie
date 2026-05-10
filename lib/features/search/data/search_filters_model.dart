// ============================================================
// Fichier : lib/features/search/data/search_filters_model.dart
// Description : Modèle immuable des filtres combinables pour la
//               recherche dans lexique4.db. Chaque champ nul
//               signifie « filtre non actif ».
// ============================================================

/// Sentinelle pour distinguer « non fourni » de « explicitement null » dans copyWith.
const _absent = Object();

// ---------------------------------------------------------------------------
// Tri des résultats
// ---------------------------------------------------------------------------

/// Ordre de tri des résultats de recherche.
enum SearchSort {
  /// Ordre alphabétique (mot ASC)
  alphabetique,

  /// Fréquence orale décroissante (freqortho DESC)
  frequence,

  /// Nombre de syllabes croissant puis alphabétique
  syllabes,

  /// Familiarité décroissante (cdortho DESC)
  familiarite,

  /// Prévalence décroissante (preval DESC)
  prevalence,
}

// ---------------------------------------------------------------------------
// Raccourcis praticiens
// ---------------------------------------------------------------------------

/// Un raccourci de recherche prédéfini.
class QuickSearch {
  const QuickSearch(this.label, this.whereClause);

  /// Libellé affiché sur le bouton.
  final String label;

  /// Fragment SQL WHERE (sans le mot-clé WHERE, sans islem=1).
  final String whereClause;
}

/// 8 raccourcis couvrant les besoins courants en orthophonie.
const List<QuickSearch> kQuickSearches = [
  QuickSearch('Son [s]', "phono GLOB '*s*'"),
  QuickSearch('Son [S] (ch)', "phono GLOB '*S*'"),
  QuickSearch('Son [f]', "phono GLOB '*f*'"),
  QuickSearch('Son [R]', "phono GLOB '*R*'"),
  QuickSearch('CVCV bisyllabes', "cvortho = 'CVCV' AND nbsyll = 2"),
  QuickSearch('Mots fréquents', 'preval >= 75'),
  QuickSearch('Monosyllabes', 'nbsyll = 1'),
  QuickSearch('Groupes consonantiques', "cvortho GLOB '*CC*'"),
];

// ---------------------------------------------------------------------------
// Modèle de filtres
// ---------------------------------------------------------------------------

/// Filtres combinables pour la recherche dans lexique4.
/// Tous les champs sont nullable — null = filtre inactif.
/// La méthode [buildSql] génère le SQL correspondant.
class SearchFilters {
  const SearchFilters({
    this.textQuery,
    this.startsWith,
    this.endsWith,
    this.contains,
    this.exactLength,
    this.minLength,
    this.maxLength,
    this.cvPattern,
    this.targetPhonemes = const [],
    this.startPhoneme,
    this.endPhoneme,
    this.minPhonemes,
    this.maxPhonemes,
    this.syllPhono,
    this.minHomophones,
    this.minFreqortho,
    this.maxFreqortho,
    this.minCdortho,
    this.maxCdortho,
    this.minPreval,
    this.maxPreval,
    this.cgramList = const [],
    this.genre,
    this.nombre,
    this.nbsyllList = const [],
    this.minNbsyll,
    this.maxNbsyll,
    this.hasMorphodecomp,
    this.morphoContains,
    this.rawWheres = const [],
    this.sort = SearchSort.prevalence,
    this.gridView = false,
    this.pageSize = 200,
    this.page = 0,
  });

  // ── Orthographiques ──────────────────────────────────────────────────────
  /// Texte libre (mot LIKE '%query%')
  final String? textQuery;

  /// Mot commence par cette chaîne
  final String? startsWith;

  /// Mot finit par cette chaîne
  final String? endsWith;

  /// Mot contient cette chaîne (différent de textQuery : ne préfixe pas)
  final String? contains;

  /// Longueur exacte en lettres
  final int? exactLength;

  /// Longueur minimale en lettres
  final int? minLength;

  /// Longueur maximale en lettres
  final int? maxLength;

  /// Motif C/V orthographique (ex: 'CVCV')
  final String? cvPattern;

  // ── Phonologiques ─────────────────────────────────────────────────────────
  /// Phonèmes cibles quelque part dans le mot (AND : le mot doit contenir TOUS les phonèmes sélectionnés)
  final List<String> targetPhonemes;

  /// Phonème en position initiale
  final String? startPhoneme;

  /// Phonème en position finale
  final String? endPhoneme;

  /// Nombre minimal de phonèmes
  final int? minPhonemes;

  /// Nombre maximal de phonèmes
  final int? maxPhonemes;

  /// Structure syllabique phonologique (syllphono LIKE)
  final String? syllPhono;

  /// Nombre minimal d'homophones
  final int? minHomophones;

  // ── Fréquence / Prévalence ────────────────────────────────────────────────
  final double? minFreqortho;
  final double? maxFreqortho;
  final double? minCdortho;
  final double? maxCdortho;
  final double? minPreval;
  final double? maxPreval;

  // ── Grammaticaux ──────────────────────────────────────────────────────────
  /// Liste de catégories grammaticales (NOM, VER, ADJ…)
  final List<String> cgramList;

  /// Genre : 'm' ou 'f'
  final String? genre;

  /// Nombre : 's' ou 'p'
  final String? nombre;

  // ── Syllabes ──────────────────────────────────────────────────────────────
  /// Valeurs exactes de nbsyll sélectionnées (boutons rapides)
  final List<int> nbsyllList;

  /// Plage de syllabes min
  final int? minNbsyll;

  /// Plage de syllabes max
  final int? maxNbsyll;

  // ── Morphologie ───────────────────────────────────────────────────────────
  /// true = morphodecomp IS NOT NULL, false = IS NULL
  final bool? hasMorphodecomp;

  /// Fragment de morphodecomp (ex: 'compos')
  final String? morphoContains;

  // ── Raccourcis bruts (multi-sélection) ───────────────────────────────────
  /// Clauses WHERE brutes issues des QuickSearch actifs — combinées par AND
  final List<String> rawWheres;

  // ── Interface ─────────────────────────────────────────────────────────────
  final SearchSort sort;
  final bool gridView;
  final int pageSize;
  final int page;

  // ---------------------------------------------------------------------------
  // Sérialisation SQL
  // ---------------------------------------------------------------------------

  /// Retourne `(sql, args)` — clause WHERE complète + clause ORDER BY + LIMIT/OFFSET.
  /// La DB est pré-filtrée — pas besoin de `islem = 1`.
  /// Si [restrictToWords] est fourni, ajoute un filtre IN (...) sur les mots.
  ({String sql, List<Object?> args}) buildSql({Set<String>? restrictToWords}) {
    final where = <String>[];
    final args = <Object?>[];

    // Restriction aux mots de definitions.db
    if (restrictToWords != null && restrictToWords.isNotEmpty) {
      final escaped =
          restrictToWords.map((w) => "'${w.replaceAll("'", "''")}'").join(', ');
      where.add('LOWER(mot) IN ($escaped)');
    }

    // Texte libre
    if (textQuery != null && textQuery!.isNotEmpty) {
      where.add('LOWER(mot) LIKE LOWER(?)');
      args.add('%${textQuery!.toLowerCase()}%');
    }

    // Orthographiques
    if (startsWith != null && startsWith!.isNotEmpty) {
      where.add('LOWER(mot) LIKE LOWER(?)');
      args.add('${startsWith!.toLowerCase()}%');
    }
    if (endsWith != null && endsWith!.isNotEmpty) {
      where.add('LOWER(mot) LIKE LOWER(?)');
      args.add('%${endsWith!.toLowerCase()}');
    }
    if (contains != null && contains!.isNotEmpty) {
      where.add('LOWER(mot) LIKE LOWER(?)');
      args.add('%${contains!.toLowerCase()}%');
    }
    if (exactLength != null) {
      where.add('nblettres = ?');
      args.add(exactLength!);
    } else {
      if (minLength != null) {
        where.add('nblettres >= ?');
        args.add(minLength!);
      }
      if (maxLength != null) {
        where.add('nblettres <= ?');
        args.add(maxLength!);
      }
    }
    if (cvPattern != null && cvPattern!.isNotEmpty) {
      where.add('cvortho = ?');
      args.add(cvPattern!.toUpperCase());
    }

    // Phonèmes cibles — AND : le mot doit contenir TOUS les phonèmes sélectionnés
    // GLOB est utilisé (et non LIKE) car GLOB est sensible à la casse dans SQLite,
    // ce qui est indispensable pour distinguer s/S, z/Z, n/N, j/J, etc. (SAMPA)
    for (final ph in targetPhonemes) {
      where.add('phono GLOB ?');
      args.add('*$ph*');
    }
    if (startPhoneme != null && startPhoneme!.isNotEmpty) {
      where.add('phono GLOB ?');
      args.add('${startPhoneme!}*');
    }
    if (endPhoneme != null && endPhoneme!.isNotEmpty) {
      where.add('phono GLOB ?');
      args.add('*${endPhoneme!}');
    }
    if (minPhonemes != null) {
      where.add('nbphons >= ?');
      args.add(minPhonemes!);
    }
    if (maxPhonemes != null) {
      where.add('nbphons <= ?');
      args.add(maxPhonemes!);
    }
    if (syllPhono != null && syllPhono!.isNotEmpty) {
      where.add('syllphono LIKE ?');
      args.add('%${syllPhono!}%');
    }
    if (minHomophones != null) {
      where.add('nbhomoph >= ?');
      args.add(minHomophones!);
    }

    // Fréquence / prévalence
    if (minFreqortho != null) {
      where.add('freqortho >= ?');
      args.add(minFreqortho!);
    }
    if (maxFreqortho != null) {
      where.add('freqortho <= ?');
      args.add(maxFreqortho!);
    }
    if (minCdortho != null) {
      where.add('cdortho >= ?');
      args.add(minCdortho!);
    }
    if (maxCdortho != null) {
      where.add('cdortho <= ?');
      args.add(maxCdortho!);
    }
    if (minPreval != null) {
      where.add('preval >= ?');
      args.add(minPreval!);
    }
    if (maxPreval != null) {
      where.add('preval <= ?');
      args.add(maxPreval!);
    }

    // Grammaticaux
    if (cgramList.isNotEmpty) {
      final placeholders = cgramList.map((_) => '?').join(', ');
      where.add('cgram IN ($placeholders)');
      args.addAll(cgramList);
    }
    if (genre != null) {
      where.add('genre = ?');
      args.add(genre!);
    }
    if (nombre != null) {
      where.add('nombre = ?');
      args.add(nombre!);
    }

    // Syllabes
    if (nbsyllList.isNotEmpty) {
      final placeholders = nbsyllList.map((_) => '?').join(', ');
      where.add('nbsyll IN ($placeholders)');
      args.addAll(nbsyllList);
    } else {
      if (minNbsyll != null) {
        where.add('nbsyll >= ?');
        args.add(minNbsyll!);
      }
      if (maxNbsyll != null) {
        where.add('nbsyll <= ?');
        args.add(maxNbsyll!);
      }
    }

    // Morphologie
    // morphodecomp IS NOT NULL couvre 99,4 % de la base (inutile comme filtre).
    // On distingue les mots vraiment décomposés (préfixe _ ou suffixe .)
    // des mots simples (/racine sans affixe).
    if (hasMorphodecomp == true) {
      where.add(
        "(morphodecomp LIKE '\\_%' ESCAPE '\\' OR morphodecomp LIKE '%.%')",
      );
    } else if (hasMorphodecomp == false) {
      where.add(
        "(morphodecomp NOT LIKE '\\_%' ESCAPE '\\' AND morphodecomp NOT LIKE '%.%')",
      );
    }
    if (morphoContains != null && morphoContains!.isNotEmpty) {
      where.add('morphodecomp LIKE ?');
      args.add('%${morphoContains!}%');
    }

    // Raccourcis rapides (multi-sélection, combinés par AND)
    for (final rw in rawWheres) {
      if (rw.isNotEmpty) where.add('($rw)');
    }

    // Construction finale
    final whereClause = where.isEmpty ? '1' : where.join(' AND ');
    final orderBy = _orderByClause();
    final offset = page * pageSize;

    final sql = '''
SELECT mot, phono, phono_ipa, cgram, cgram_ortho,
       nbsyll, nblettres, nbphons, syllphono, cvortho,
       freqortho, cdortho, preval, freqlemme, freqmot,
       lemme, islem, genre, nombre, morphodecomp, nbhomoph
FROM lexique4
WHERE $whereClause
$orderBy
LIMIT ? OFFSET ?
''';
    args
      ..add(pageSize)
      ..add(offset);

    return (sql: sql, args: args);
  }

  /// SQL pour compter le total de résultats (sans LIMIT).
  ({String sql, List<Object?> args}) buildCountSql({
    Set<String>? restrictToWords,
  }) {
    final base = buildSql(restrictToWords: restrictToWords);
    // Retire les 2 derniers args (LIMIT/OFFSET)
    final countArgs = base.args.sublist(0, base.args.length - 2);
    // Remplace le SELECT par COUNT(*) et supprime ORDER BY + LIMIT/OFFSET
    String countSql = base.sql.replaceFirst(
      RegExp(r'SELECT .+?FROM', dotAll: true),
      'SELECT COUNT(*) as cnt FROM',
    );
    // Supprime ORDER BY et tout ce qui suit (LIMIT/OFFSET inclus)
    countSql = countSql.replaceFirst(
      RegExp(r'\s*ORDER BY .+$', dotAll: true),
      '\n',
    );
    return (sql: countSql, args: countArgs);
  }

  String _orderByClause() => switch (sort) {
        SearchSort.alphabetique => 'ORDER BY mot ASC',
        SearchSort.frequence => 'ORDER BY freqortho DESC NULLS LAST',
        SearchSort.syllabes => 'ORDER BY nbsyll ASC, mot ASC',
        SearchSort.familiarite => 'ORDER BY cdortho DESC NULLS LAST',
        SearchSort.prevalence => 'ORDER BY preval DESC NULLS LAST',
      };

  // ---------------------------------------------------------------------------
  // copyWith — utilise _Absent pour permettre de remettre un champ à null
  // ---------------------------------------------------------------------------

  SearchFilters copyWith({
    Object? textQuery = _absent,
    Object? startsWith = _absent,
    Object? endsWith = _absent,
    Object? contains = _absent,
    Object? exactLength = _absent,
    Object? minLength = _absent,
    Object? maxLength = _absent,
    Object? cvPattern = _absent,
    List<String>? targetPhonemes,
    Object? startPhoneme = _absent,
    Object? endPhoneme = _absent,
    Object? minPhonemes = _absent,
    Object? maxPhonemes = _absent,
    Object? syllPhono = _absent,
    Object? minHomophones = _absent,
    Object? minFreqortho = _absent,
    Object? maxFreqortho = _absent,
    Object? minCdortho = _absent,
    Object? maxCdortho = _absent,
    Object? minPreval = _absent,
    Object? maxPreval = _absent,
    List<String>? cgramList,
    Object? genre = _absent,
    Object? nombre = _absent,
    List<int>? nbsyllList,
    Object? minNbsyll = _absent,
    Object? maxNbsyll = _absent,
    Object? hasMorphodecomp = _absent,
    Object? morphoContains = _absent,
    List<String>? rawWheres,
    SearchSort? sort,
    bool? gridView,
    int? pageSize,
    int? page,
  }) {
    return SearchFilters(
      textQuery: textQuery == _absent ? this.textQuery : textQuery as String?,
      startsWith:
          startsWith == _absent ? this.startsWith : startsWith as String?,
      endsWith: endsWith == _absent ? this.endsWith : endsWith as String?,
      contains: contains == _absent ? this.contains : contains as String?,
      exactLength:
          exactLength == _absent ? this.exactLength : exactLength as int?,
      minLength: minLength == _absent ? this.minLength : minLength as int?,
      maxLength: maxLength == _absent ? this.maxLength : maxLength as int?,
      cvPattern: cvPattern == _absent ? this.cvPattern : cvPattern as String?,
      targetPhonemes: targetPhonemes ?? this.targetPhonemes,
      startPhoneme:
          startPhoneme == _absent ? this.startPhoneme : startPhoneme as String?,
      endPhoneme:
          endPhoneme == _absent ? this.endPhoneme : endPhoneme as String?,
      minPhonemes:
          minPhonemes == _absent ? this.minPhonemes : minPhonemes as int?,
      maxPhonemes:
          maxPhonemes == _absent ? this.maxPhonemes : maxPhonemes as int?,
      syllPhono: syllPhono == _absent ? this.syllPhono : syllPhono as String?,
      minHomophones:
          minHomophones == _absent ? this.minHomophones : minHomophones as int?,
      minFreqortho:
          minFreqortho == _absent ? this.minFreqortho : minFreqortho as double?,
      maxFreqortho:
          maxFreqortho == _absent ? this.maxFreqortho : maxFreqortho as double?,
      minCdortho:
          minCdortho == _absent ? this.minCdortho : minCdortho as double?,
      maxCdortho:
          maxCdortho == _absent ? this.maxCdortho : maxCdortho as double?,
      minPreval: minPreval == _absent ? this.minPreval : minPreval as double?,
      maxPreval: maxPreval == _absent ? this.maxPreval : maxPreval as double?,
      cgramList: cgramList ?? this.cgramList,
      genre: genre == _absent ? this.genre : genre as String?,
      nombre: nombre == _absent ? this.nombre : nombre as String?,
      nbsyllList: nbsyllList ?? this.nbsyllList,
      minNbsyll: minNbsyll == _absent ? this.minNbsyll : minNbsyll as int?,
      maxNbsyll: maxNbsyll == _absent ? this.maxNbsyll : maxNbsyll as int?,
      hasMorphodecomp: hasMorphodecomp == _absent
          ? this.hasMorphodecomp
          : hasMorphodecomp as bool?,
      morphoContains: morphoContains == _absent
          ? this.morphoContains
          : morphoContains as String?,
      rawWheres: rawWheres ?? this.rawWheres,
      sort: sort ?? this.sort,
      gridView: gridView ?? this.gridView,
      pageSize: pageSize ?? this.pageSize,
      page: page ?? this.page,
    );
  }

  /// Réinitialise tous les filtres (garde sort/gridView).
  SearchFilters reset() => SearchFilters(sort: sort, gridView: gridView);

  /// Vrai si au moins un filtre (hors tri/vue/pagination) est actif.
  bool get hasActiveFilters =>
      textQuery?.isNotEmpty == true ||
      startsWith?.isNotEmpty == true ||
      endsWith?.isNotEmpty == true ||
      contains?.isNotEmpty == true ||
      exactLength != null ||
      minLength != null ||
      maxLength != null ||
      cvPattern?.isNotEmpty == true ||
      targetPhonemes.isNotEmpty ||
      startPhoneme?.isNotEmpty == true ||
      endPhoneme?.isNotEmpty == true ||
      minPhonemes != null ||
      maxPhonemes != null ||
      syllPhono?.isNotEmpty == true ||
      minHomophones != null ||
      minFreqortho != null ||
      maxFreqortho != null ||
      minCdortho != null ||
      maxCdortho != null ||
      minPreval != null ||
      maxPreval != null ||
      cgramList.isNotEmpty ||
      genre != null ||
      nombre != null ||
      nbsyllList.isNotEmpty ||
      minNbsyll != null ||
      maxNbsyll != null ||
      hasMorphodecomp != null ||
      morphoContains?.isNotEmpty == true ||
      rawWheres.isNotEmpty;

  /// Génère les chips résumant les filtres actifs.
  List<FilterChipData> get activeChips {
    final chips = <FilterChipData>[];
    if (textQuery?.isNotEmpty == true) {
      chips.add(
        FilterChipData('Texte: "$textQuery"', () => copyWith(textQuery: '')),
      );
    }
    if (startsWith?.isNotEmpty == true) {
      chips.add(
        FilterChipData(
          'Commence par "$startsWith"',
          () => copyWith(startsWith: ''),
        ),
      );
    }
    if (endsWith?.isNotEmpty == true) {
      chips.add(
        FilterChipData(
          'Finit par "$endsWith"',
          () => copyWith(endsWith: ''),
        ),
      );
    }
    if (contains?.isNotEmpty == true) {
      chips.add(
        FilterChipData('Contient "$contains"', () => copyWith(contains: '')),
      );
    }
    if (exactLength != null) {
      chips.add(FilterChipData('$exactLength lettres', () => copyWith()));
    }
    if (cvPattern?.isNotEmpty == true) {
      chips.add(
        FilterChipData('C/V: $cvPattern', () => copyWith(cvPattern: '')),
      );
    }
    for (final ph in targetPhonemes) {
      chips.add(
        FilterChipData(
          'Son [$ph]',
          () => copyWith(
            targetPhonemes: targetPhonemes.where((p) => p != ph).toList(),
          ),
        ),
      );
    }
    if (cgramList.isNotEmpty) {
      chips.add(
        FilterChipData(cgramList.join(', '), () => copyWith(cgramList: [])),
      );
    }
    if (nbsyllList.isNotEmpty) {
      final s = nbsyllList.map((n) => '${n}s').join(', ');
      chips.add(FilterChipData(s, () => copyWith(nbsyllList: [])));
    }
    if (minPreval != null) {
      chips.add(
        FilterChipData(
          'Preval ≥${minPreval!.toInt()}%',
          () => copyWith(minPreval: null),
        ),
      );
    }
    if (hasMorphodecomp == true) {
      chips.add(
        FilterChipData('Morphologie', () => copyWith(hasMorphodecomp: null)),
      );
    }
    if (minHomophones != null) {
      chips.add(
        FilterChipData(
          'Homophones ≥$minHomophones',
          () => copyWith(minHomophones: null),
        ),
      );
    }
    for (final rw in rawWheres) {
      final label = kQuickSearches
          .firstWhere(
            (qs) => qs.whereClause == rw,
            orElse: () => QuickSearch('Raccourci', rw),
          )
          .label;
      chips.add(
        FilterChipData(
          label,
          () => copyWith(
            rawWheres: rawWheres.where((w) => w != rw).toList(),
          ),
        ),
      );
    }
    return chips;
  }
}

/// Données d'un chip filtre actif.
class FilterChipData {
  const FilterChipData(this.label, this.onRemove);
  final String label;

  /// Retourne les filtres après suppression de ce filtre.
  final SearchFilters Function() onRemove;
}
