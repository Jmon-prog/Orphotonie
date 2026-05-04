# Intégration Lexique 4 — Orphotonie

## Présentation

**Lexique 4** (New, Pallier, Brysbaert & Ferrand, 2026) est une base de données
lexicales du français, librement disponible pour la recherche et l'éducation.
Elle contient **189 863 formes orthographiques** avec des informations
phonologiques, morphologiques et fréquentielles.

Site officiel : [www.lexique.org](http://www.lexique.org)

---

## Colonnes retenues

| Colonne | Type | Pourquoi |
|---------|------|----------|
| `mot` | TEXT | Forme orthographique — base de tout exercice |
| `phono` | TEXT | Transcription SAMPA — prononciation machine |
| `phono_ipa` | TEXT | Transcription IPA — affichage pour le praticien |
| `cgram` | TEXT | Catégorie grammaticale courte (NOM, VER, ADJ…) — filtrage par type de mot |
| `cgram_ortho` | TEXT | Catégorie longue — affichage lisible |
| `nbsyll` | INTEGER | Nombre de syllabes — difficulté progressive, exercice ciblé |
| `nblettres` | INTEGER | Nombre de lettres — taille de grille, sélection de mots |
| `nbphons` | INTEGER | Nombre de phonèmes — analyse phonologique |
| `syllphono` | TEXT | Découpage syllabique — exercice de segmentation |
| `cvortho` | TEXT | Structure CV — analyse orthographique |
| `freqortho` | REAL | Fréquence orthographique — prioriser les mots courants |
| `cdortho` | REAL | Dispersion — stabilité de la fréquence |
| `preval` | REAL | Prévalence lexicale — % de locuteurs connaissant le mot |
| `freqlemme` | REAL | Fréquence du lemme — tri par fréquence |
| `freqmot` | REAL | Fréquence du mot fléchi |
| `lemme` | TEXT | Forme lemmatisée — regroupement de formes |
| `islem` | INTEGER | 1 = forme lemme — **filtre obligatoire** |
| `genre` | TEXT | Genre (m/f) — accord grammatical |
| `nombre` | TEXT | Nombre (s/p) — accord grammatical |
| `morphodecomp` | TEXT | Décomposition morphologique — exercice de morphologie |
| `nbhomoph` | INTEGER | Nombre d'homophones — travail sur les homophones |

---

## Filtre obligatoire : `islem = 1`

La base contient des formes fléchies (« mangeons », « mangé », « mangerais »…)
en plus des lemmes (« manger »). Pour éviter les doublons et garder une
entrée par mot, **toutes les requêtes filtrent `WHERE islem = 1`**.

Cela réduit l'espace de recherche à environ 55 000 lemmes uniques.

---

## Requêtes SQL utiles

### Recherche par préfixe

```sql
SELECT * FROM lexique
WHERE islem = 1
  AND mot LIKE 'cha%'
ORDER BY freqlemme DESC
LIMIT 50;
```

Résultat : chat, chance, chambre, changer, champ, chapeau…

### Mots par nombre de syllabes

```sql
SELECT * FROM lexique
WHERE islem = 1
  AND nbsyll = 2
ORDER BY RANDOM()
LIMIT 20;
```

Utile pour les exercices ciblés sur les mots bisyllabiques.

### Mots par catégorie grammaticale

```sql
SELECT * FROM lexique
WHERE islem = 1
  AND cgram = 'NOM'
  AND freqlemme > 10
ORDER BY freqlemme DESC
LIMIT 50;
```

Retourne les noms les plus fréquents.

### Homophones

```sql
SELECT * FROM lexique
WHERE islem = 1
  AND nbhomoph > 1
ORDER BY freqlemme DESC
LIMIT 30;
```

Trouve les mots ayant des homophones (ver/verre/vert/vers…).

### Mots par longueur (pour les grilles)

```sql
SELECT * FROM lexique
WHERE islem = 1
  AND nblettres BETWEEN 4 AND 8
  AND freqlemme > 5
ORDER BY RANDOM()
LIMIT 10;
```

Sélection de mots adaptés aux grilles de mots croisés et mots cachés.

### Recherche avec décomposition morphologique

```sql
SELECT mot, morphodecomp FROM lexique
WHERE islem = 1
  AND morphodecomp LIKE '%+%'
ORDER BY freqlemme DESC
LIMIT 20;
```

Trouve les mots composés (porte-monnaie, arc-en-ciel…).

---

## Utilisation dans l'application

### Écran de recherche

Le praticien utilise l'écran de recherche pour trouver des mots à ajouter
au dictionnaire de l'enfant. La recherche est par préfixe, insensible à la
casse, triée par fréquence décroissante.

Chaque résultat affiche :

- Le mot et sa phonétique IPA
- La catégorie grammaticale
- Le nombre de syllabes et de lettres
- La fréquence (barre visuelle)

### Sélection SRS

Le service `WordsDao.selectWordsForSession()` sélectionne les mots
pour une session de jeu en croisant les données du dictionnaire
utilisateur avec les données de maîtrise (boîtes Leitner).

### Filtrage par difficulté

Le praticien peut ajuster la difficulté en ciblant :

- Un nombre de syllabes précis (`nbsyll`)
- Une longueur de mot (`nblettres`)
- Une fréquence minimale (`freqlemme`)
- Une catégorie grammaticale (`cgram`)

---

## Référence

> New, B., Pallier, C., Brysbaert, M., & Ferrand, L. (2026).
> *Lexique 4 : une nouvelle base de données lexicales du français*.
> Disponible sur [www.lexique.org](http://www.lexique.org).
