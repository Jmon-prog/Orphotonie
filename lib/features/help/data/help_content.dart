// ============================================================
// Fichier : lib/features/help/data/help_content.dart
// Description : Contenu statique de l'aide — glossaire, tooltips,
//               guides pédagogiques. 100 % hors-ligne.
// ============================================================

import 'package:flutter/material.dart';
import '../../search/data/search_filters_model.dart';

// =====================================================================
// Glossaire (9 termes + bonus)
// =====================================================================

/// Entrée de glossaire.
class GlossaryEntry {
  const GlossaryEntry({
    required this.key,
    required this.term,
    required this.shortExplanation,
    required this.detailedExplanation,
    this.example,
  });

  /// Clé unique (ex : 'preval', 'cdortho').
  final String key;

  /// Terme affiché (ex : 'Prévalence').
  final String term;

  /// Explication courte (2 phrases max, pour le tooltip).
  final String shortExplanation;

  /// Explication détaillée (pour l'écran glossaire).
  final String detailedExplanation;

  /// Exemple concret (optionnel).
  final String? example;
}

/// Les 10 entrées du glossaire.
const List<GlossaryEntry> kGlossaryEntries = [
  GlossaryEntry(
    key: 'frequence',
    term: 'Fréquence',
    shortExplanation: 'Combien de fois un mot apparaît dans les textes. '
        'Plus la valeur est élevée, plus le mot est courant.',
    detailedExplanation:
        'La fréquence lexicale mesure le nombre d\'occurrences d\'un mot '
        'dans un corpus de textes écrits. Elle est exprimée en occurrences par '
        'million de mots. Un mot fréquent (>100/million) est rencontré '
        'quotidiennement, tandis qu\'un mot rare (<1/million) est spécialisé.',
    example: '« le » ≈ 36 000/million · « chrysanthème » ≈ 0.5/million',
  ),
  GlossaryEntry(
    key: 'cdortho',
    term: 'Diversité (cdortho)',
    shortExplanation: 'Dans combien de textes différents ce mot apparaît. '
        'Plus c\'est élevé, plus le mot est « universel ».',
    detailedExplanation:
        'L\'indice de diversité (cdortho) mesure le nombre de sources textuelles '
        'dans lesquelles un mot est attesté. Contrairement à la fréquence brute, '
        'il résiste aux biais : un mot technique répété 100 fois dans un seul '
        'article aura une fréquence élevée mais une diversité basse.',
    example: '« maison » : diversité élevée · « catalyseur » : diversité basse',
  ),
  GlossaryEntry(
    key: 'preval',
    term: 'Prévalence',
    shortExplanation: 'Combien de Français connaissent ce mot. '
        '90 % = presque tout le monde.',
    detailedExplanation:
        'La prévalence indique le pourcentage de locuteurs francophones qui '
        'connaissent un mot donné. C\'est une mesure de « familiarité collective ». '
        'Un mot à 95 % de prévalence est connu de quasi tous les adultes ; '
        'un mot à 40 % est réservé à un vocabulaire spécialisé.',
    example: '« chat » : 99 % · « trépan » : 35 %',
  ),
  GlossaryEntry(
    key: 'phonologie',
    term: 'Phonologie / IPA',
    shortExplanation:
        'La transcription des sons du mot en alphabet phonétique. '
        'Utile pour cibler les sons à travailler.',
    detailedExplanation:
        'La phonologie étudie les sons du langage. L\'IPA (International Phonetic '
        'Alphabet) est un système universel de transcription. Chaque symbole '
        'représente un son unique : /ʃ/ = « ch », /ʒ/ = « j », /ɛ̃/ = « in ». '
        'La colonne phono utilise le format SAMPA (ASCII), phono_ipa l\'IPA Unicode.',
    example: '« chat » : /ʃa/ (IPA) = /Sa/ (SAMPA)',
  ),
  GlossaryEntry(
    key: 'cvortho',
    term: 'Structure C/V',
    shortExplanation: 'Le squelette consonnes-voyelles du mot. '
        'CVCV = consonne-voyelle-consonne-voyelle.',
    detailedExplanation:
        'La structure C/V représente le patron consonnes (C) et voyelles (V) '
        'd\'un mot. Par exemple « papa » = CVCV, « strophe » = CCCVC. '
        'C\'est un outil clinique pour cibler la complexité articulatoire. '
        'Les structures CVCV sont les plus simples, les clusters (CCV, CCC) '
        'sont plus difficiles.',
    example: '« chat » = CV · « triste » = CCVCC',
  ),
  GlossaryEntry(
    key: 'morphologie',
    term: 'Morphologie',
    shortExplanation:
        'La décomposition du mot en parties (préfixe, racine, suffixe). '
        'Ex : « refaire » = re + faire.',
    detailedExplanation:
        'La morphologie étudie la formation des mots. La colonne morphodecomp '
        'décompose un mot en morphèmes : préfixes, racines et suffixes. '
        'Un mot « simple » n\'a qu\'un morphème (« chat »), un mot « complexe » '
        'en a plusieurs (« in-dé-compos-able » = 4 morphèmes). '
        'Travailler la conscience morphologique améliore l\'orthographe.',
    example: '« parapluie » = para + pluie · « injustice » = in + justice',
  ),
  GlossaryEntry(
    key: 'lemme',
    term: 'Lemme',
    shortExplanation:
        'La forme de base d\'un mot (infinitif du verbe, masculin singulier). '
        '« mangeons » → lemme = « manger ».',
    detailedExplanation:
        'Le lemme est la forme canonique d\'un mot, celle qu\'on trouve dans '
        'le dictionnaire. Pour les verbes, c\'est l\'infinitif ; pour les noms '
        'et adjectifs, le masculin singulier. La colonne islem indique si '
        'l\'entrée est elle-même le lemme (islem = 1) ou une forme fléchie.',
    example:
        '« chevaux » → lemme = « cheval » · « allions » → lemme = « aller »',
  ),
  GlossaryEntry(
    key: 'cgram',
    term: 'Ambiguïté grammaticale',
    shortExplanation: 'Quand un mot peut être plusieurs catégories. '
        '« livre » = nom OU verbe.',
    detailedExplanation:
        'L\'ambiguïté grammaticale (POS) survient quand un même mot peut '
        'appartenir à plusieurs catégories grammaticales. La colonne cgram_ortho '
        'liste toutes les catégories possibles séparées par des virgules. '
        'Les mots ambigus sont intéressants en rééducation car ils demandent '
        'une analyse du contexte pour choisir la bonne interprétation.',
    example: '« livre » = NOM,VER · « la » = ART,PRO,NOM',
  ),
  GlossaryEntry(
    key: 'dubois',
    term: 'Niveau Dubois-Buyse',
    shortExplanation:
        'Échelle de 1 à 43 indiquant quand un enfant devrait savoir '
        'orthographier ce mot. 1 = CP, 43 = fin lycée.',
    detailedExplanation:
        'L\'échelle Dubois-Buyse est un classement historique des mots français '
        'par difficulté orthographique. Elle associe à chaque mot un « échelon » '
        '(1 à 43) correspondant au niveau scolaire auquel 75 % des élèves '
        'l\'orthographient correctement. Les échelons 1-7 correspondent au CP, '
        '8-15 au CE, 16-23 au CM, au-delà au collège/lycée.',
    example: '« papa » = échelon 1 · « abîme » = échelon 29',
  ),
  GlossaryEntry(
    key: 'zrt_flp',
    term: 'zRT_FLP',
    shortExplanation:
        'Score standardisé du temps de réaction en décision lexicale. '
        'Plus c\'est négatif, plus le mot est reconnu vite.',
    detailedExplanation:
        'Le zRT_FLP (z-score du temps de réaction du French Lexicon Project) '
        'est un score standardisé mesurant la vitesse à laquelle un mot est '
        'reconnu comme existant. Un z-score négatif signifie reconnaissance '
        'plus rapide que la moyenne, un z-score positif plus lent. '
        'C\'est un indicateur de la facilité d\'accès lexical.',
    example: '« maison » : z = -0.8 (rapide) · « abscisse » : z = +1.2 (lent)',
  ),
];

/// Recherche une entrée de glossaire par sa clé.
GlossaryEntry? findGlossaryEntry(String key) {
  for (final entry in kGlossaryEntries) {
    if (entry.key == key) return entry;
  }
  return null;
}

// =====================================================================
// Onboarding — contenu des écrans
// =====================================================================

/// Page d'onboarding.
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;

  /// Icône Material (IconData constant pour le tree-shaking).
  final IconData icon;
}

/// Écrans d'onboarding praticien (5 pages).
const List<OnboardingPageData> kPractitionerOnboarding = [
  OnboardingPageData(
    title: 'Bienvenue dans Orphotonie',
    description: 'Votre assistant d\'orthophonie 100 % hors ligne. '
        'Toutes vos données restent sur votre appareil.',
    icon: IconData(
      0xe87d,
      fontFamily: 'MaterialIcons',
    ), // Icons.waving_hand
  ),
  OnboardingPageData(
    title: 'Recherche avancée',
    description: 'Explorez 189 863 mots avec des filtres phonologiques, '
        'morphologiques et fréquentiels. '
        'Idéal pour préparer vos séances.',
    icon: IconData(0xe8b6, fontFamily: 'MaterialIcons'), // Icons.search
  ),
  OnboardingPageData(
    title: 'Dictionnaires personnalisés',
    description: 'Créez des listes de mots ciblés pour chaque patient. '
        'Ajoutez des images et des enregistrements audio.',
    icon: IconData(0xe865, fontFamily: 'MaterialIcons'), // Icons.menu_book
  ),
  OnboardingPageData(
    title: '5 jeux de rééducation',
    description:
        'Anagrammes, pendu, mots lacunaires, mots cachés, mots croisés. '
        'Chaque jeu s\'adapte au niveau de l\'enfant via le SRS.',
    icon: IconData(
      0xea65,
      fontFamily: 'MaterialIcons',
    ), // Icons.sports_esports
  ),
  OnboardingPageData(
    title: 'Suivi de progression',
    description: 'Tableaux de bord, taux de réussite par activité, '
        'mots en difficulté. Exportez en PDF pour les parents.',
    icon: IconData(
      0xe6df,
      fontFamily: 'MaterialIcons',
    ), // Icons.trending_up
  ),
];

/// Écrans d'onboarding parent (3 pages).
const List<OnboardingPageData> kParentOnboarding = [
  OnboardingPageData(
    title: 'Bienvenue !',
    description: 'Orphotonie aide votre enfant à enrichir son vocabulaire '
        'grâce à des jeux amusants. Tout fonctionne sans Internet.',
    icon: IconData(
      0xe87d,
      fontFamily: 'MaterialIcons',
    ), // Icons.waving_hand
  ),
  OnboardingPageData(
    title: 'Des jeux pour apprendre',
    description: 'Anagrammes, pendu, mots cachés… Les mots sont choisis '
        'par l\'orthophoniste et adaptés au niveau de votre enfant.',
    icon: IconData(
      0xea65,
      fontFamily: 'MaterialIcons',
    ), // Icons.sports_esports
  ),
  OnboardingPageData(
    title: 'Un suivi simple',
    description: 'Suivez les progrès de votre enfant jour après jour. '
        'Les mots difficiles sont automatiquement retravaillés.',
    icon: IconData(
      0xe6df,
      fontFamily: 'MaterialIcons',
    ), // Icons.trending_up
  ),
];

// =====================================================================
// Guides pédagogiques
// =====================================================================

/// Guide pédagogique avec filtres pré-remplis.
class PedagogicalGuide {
  const PedagogicalGuide({
    required this.title,
    required this.description,
    required this.tips,
    required this.suggestedFilters,
  });

  final String title;
  final String description;
  final List<String> tips;

  /// Filtres pré-remplis à appliquer dans SearchScreen.
  final SearchFilters suggestedFilters;
}

/// 5 guides pédagogiques.
const List<PedagogicalGuide> kPedagogicalGuides = [
  PedagogicalGuide(
    title: 'Retard de langage',
    description: 'Sélection de mots fréquents, courts et très connus '
        'pour consolider le vocabulaire de base.',
    tips: [
      'Privilégier les mots de 1-2 syllabes (CVCV) pour commencer.',
      'Cibler les mots à forte prévalence (> 90 %) pour maximiser l\'utilité.',
      'Travailler les noms concrets avant les mots abstraits.',
      'Utiliser les images pour renforcer l\'association mot-sens.',
    ],
    suggestedFilters: SearchFilters(
      maxNbsyll: 2,
      minPreval: 90,
      cgramList: ['NOM'],
      sort: SearchSort.prevalence,
    ),
  ),
  PedagogicalGuide(
    title: 'Dyslexie',
    description: 'Mots à structure syllabique régulière (CVCV) '
        'pour travailler le décodage.',
    tips: [
      'Commencer par des structures CVCV simples avant les clusters.',
      'Travailler la correspondance graphème-phonème avec des paires minimales.',
      'Éviter les mots avec des lettres muettes au début.',
      'Augmenter progressivement la longueur des mots.',
      'Utiliser le mode phonétique pour visualiser la structure sonore.',
    ],
    suggestedFilters: SearchFilters(
      cvPattern: 'CVCV',
      minPreval: 70,
      sort: SearchSort.frequence,
    ),
  ),
  PedagogicalGuide(
    title: 'Conscience morphologique',
    description:
        'Mots décomposables en morphèmes (préfixes, suffixes, racines) '
        'pour développer la compréhension de la formation des mots.',
    tips: [
      'Commencer par des mots avec des préfixes transparents (re-, dé-, in-).',
      'Travailler les familles de mots (lire → relire → illisible).',
      'Explorer les suffixes dérivationnels (-tion, -ment, -able).',
      'Jouer avec la décomposition : « parapluie » = para + pluie.',
    ],
    suggestedFilters: SearchFilters(
      hasMorphodecomp: true,
      minPreval: 60,
      sort: SearchSort.prevalence,
    ),
  ),
  PedagogicalGuide(
    title: 'Enrichissement lexical',
    description: 'Mots de fréquence moyenne — ni trop faciles ni trop rares — '
        'pour étendre le vocabulaire actif.',
    tips: [
      'Cibler les mots de prévalence 50-80 % : connus mais pas encore maîtrisés.',
      'Varier les catégories grammaticales (noms, verbes, adjectifs).',
      'Associer chaque mot nouveau à un contexte concret (phrase, image).',
      'Utiliser le SRS pour garantir la mémorisation à long terme.',
      'Grouper les mots par champ sémantique (animaux, alimentation…).',
    ],
    suggestedFilters: SearchFilters(
      minPreval: 50,
      maxPreval: 80,
      sort: SearchSort.prevalence,
    ),
  ),
  PedagogicalGuide(
    title: 'Vocabulaire scolaire',
    description: 'Mots du programme scolaire classés par niveau Dubois-Buyse.',
    tips: [
      'Utiliser l\'échelle Dubois-Buyse pour ajuster le niveau.',
      'Travailler les mots du niveau actuel + 1 pour une progression douce.',
      'Intégrer les mots dans des phrases contextualisées.',
    ],
    suggestedFilters: SearchFilters(
      minPreval: 70,
      sort: SearchSort.frequence,
    ),
  ),
];

// =====================================================================
// Textes pour SuggestionsPanel
// =====================================================================

/// Génère une explication en langage naturel des filtres actifs.
String explainFilters(SearchFilters filters) {
  final parts = <String>[];

  if (filters.textQuery != null && filters.textQuery!.isNotEmpty) {
    parts.add('contenant « ${filters.textQuery} »');
  }
  if (filters.targetPhonemes.isNotEmpty) {
    parts.add('avec les sons [${filters.targetPhonemes.join(', ')}]');
  }
  if (filters.cvPattern != null && filters.cvPattern!.isNotEmpty) {
    parts.add('de structure ${filters.cvPattern}');
  }
  if (filters.cgramList.isNotEmpty) {
    parts.add('catégorie ${filters.cgramList.join(", ")}');
  }
  if (filters.nbsyllList.isNotEmpty) {
    parts.add('${filters.nbsyllList.join(" ou ")} syllabe(s)');
  }
  if (filters.minPreval != null) {
    parts.add('connus par ≥ ${filters.minPreval!.toInt()} % des Français');
  }
  if (filters.maxPreval != null) {
    parts.add('connus par ≤ ${filters.maxPreval!.toInt()} % des Français');
  }
  if (filters.hasMorphodecomp == true) {
    parts.add('décomposables en morphèmes');
  }
  if (filters.minHomophones != null) {
    parts.add('ayant ≥ ${filters.minHomophones} homophone(s)');
  }

  if (parts.isEmpty) return 'Tous les mots du lexique sont affichés.';

  return 'Mots sélectionnés : ${parts.join(", ")}.';
}
