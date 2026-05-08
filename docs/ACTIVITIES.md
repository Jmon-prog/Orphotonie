# Activités de jeu — Orphotonie

## Vue d'ensemble

Orphotonie propose **9 jeux** et un **mode Découverte** pour travailler la
conscience phonologique, l'orthographe et le vocabulaire. Chaque jeu s'appuie
sur les mots du dictionnaire personnalisé de l'enfant.

| # | Jeu | Compétence ciblée |
|---|-----|-------------------|
| 1 | Anagramme | Ordre des lettres |
| 2 | Pendu | Reconnaissance de lettres |
| 3 | Mot Lacunaire | Orthographe ciblée |
| 4 | Mots Cachés | Reconnaissance visuelle |
| 5 | Mots Croisés | Définitions + orthographe |
| 6 | Flashcard Leitner | Mémorisation mot/définition |
| 7 | QCM Définition | Compréhension lexicale |
| 8 | Roue des Syllabes | Segmentation syllabique |
| 9 | Memory | Association mot ↔ définition |

---

## 1. Anagramme

**Objectif** : reconstituer un mot dont les lettres ont été mélangées.

### Algorithme

1. Le mot est sélectionné depuis le dictionnaire (priorité SRS Leitner)
2. Les lettres sont mélangées par **shuffle de Fisher-Yates**
3. Si le résultat est identique au mot original → re-shuffle (max 20 tentatives)
4. L'enfant réordonne les lettres par glisser-déposer

### Système d'indices

- **Indice progressif** : révèle la prochaine lettre non découverte (dans l'ordre)
- Chaque indice réduit le score potentiel

### Barème

| Condition | Score |
|-----------|-------|
| Aucun indice, aucune erreur | 100 pts |
| ≤ 1 indice | 60 pts |
| ≤ 2 indices | 30 pts |
| Plus de 2 indices | 10 pts |

### Exemple pas à pas

```
Mot : PAPILLON
1. Mélange → POLALIPN
2. L'enfant déplace P en position 1 → P_OLALIPN
3. Indice demandé → A est révélé en position 2 → PA_OLIPN
4. L'enfant continue jusqu'à PAPILLON ✓
5. Score : 60 pts (1 indice utilisé)
```

---

## 2. Pendu

**Objectif** : deviner un mot lettre par lettre avant d'épuiser les erreurs.

### Niveaux de difficulté

| Niveau | Erreurs max | Particularité |
|--------|------------|---------------|
| Facile | 8 | Catégorie grammaticale affichée |
| Normal | 6 | Aucun indice initial |
| Difficile | 5 | Aucun indice, animation rapide |

### Algorithme

1. Le mot est affiché sous forme de tirets `_ _ _ _ _ _`
2. L'enfant sélectionne une lettre sur le clavier virtuel
3. **Lettre correcte** → toutes les occurrences sont révélées, lettre marquée verte
4. **Lettre incorrecte** → compteur d'erreurs +1, lettre marquée rouge, mascotte avance
5. **Victoire** : toutes les lettres révélées avant max erreurs
6. **Défaite** : erreurs = max, le mot complet est affiché

### Mascotte

- Progression linéaire de 0.0 à 1.0 (= erreurs / max)
- 8 états visuels successifs (ajout progressif des membres)

### Indices

- **Révéler la première lettre** : -20 pts
- **Révéler une lettre aléatoire** : -15 pts
- Chaque indice : -10 pts supplémentaires (minimum 0)

### Barème

| Condition | Score |
|-----------|-------|
| Aucune erreur, aucun indice | 100 pts |
| ≤ 2 erreurs | 80 pts |
| ≤ 4 erreurs | 60 pts |
| > 4 erreurs | 40 pts |
| Défaite | 10 pts |

### Exemple pas à pas

```
Mot : GIRAFE (difficulté normale, 6 erreurs max)
Affichage : _ _ _ _ _ _
1. Lettre E → _ _ _ _ _ E (correct ✓)
2. Lettre A → _ _ _ A _ E (correct ✓)
3. Lettre S → erreur 1/6 (S marqué rouge)
4. Lettre I → _ I _ A _ E (correct ✓)
5. Lettre R → _ I R A _ E (correct ✓)
6. Lettre G → G I R A _ E (correct ✓)
7. Lettre F → G I R A F E (victoire !)
Score : 80 pts (1 erreur)
```

---

## 3. Mot Lacunaire (Fill-in-the-Blank)

**Objectif** : compléter un mot dont certaines lettres sont masquées.

### 3 modes de jeu

| Mode | Interface | Description |
|------|-----------|-------------|
| `freeInput` | Champ de saisie libre | L'enfant tape les lettres manquantes |
| `multipleChoice` | 4 boutons de choix | L'enfant sélectionne la bonne proposition |
| `letterPool` | Glisser-déposer | L'enfant place les lettres depuis un pool |

### Algorithme de génération des lacunes

1. Calculer le nombre de lacunes selon la longueur du mot :
   - ≤ 4 lettres → 1 lacune
   - 5–7 lettres → 2 lacunes
   - ≥ 8 lettres → 3 lacunes
2. Maximum 50 % des lettres masquées
3. La première lettre n'est **jamais** masquée
4. Priorité de sélection :
   - Lettres « difficiles » (accents, H, Y, X, K, W, Q)
   - Voyelles
   - Consonnes courantes

### Distracteurs (mode multipleChoice)

Substitution phonétique pour les faux choix :

- `é` ↔ `è` ↔ `ê`, `c` ↔ `s` ↔ `ç`, `an` ↔ `en`, etc.
- Garantit que les distracteurs sont plausibles

### Exemple pas à pas

```
Mot : ÉLÉPHANT (8 lettres → 3 lacunes)
Lettres sélectionnées : É (accent), PH (difficile), AN (voyelle)

Mode freeInput :
  Affichage : _LÉ_H_ NT
  L'enfant tape : É, P, A → ÉLÉPHANT ✓

Mode multipleChoice :
  Lacune 1 : _LÉPHANT → choix : [É, È, E, A] → É ✓
  Lacune 2 : ÉLÉ_HANT → choix : [P, B, F, V] → P ✓
  Lacune 3 : ÉLÉPH_NT → choix : [A, E, O, I] → A ✓
```

---

## 4. Mots Cachés (Word Search)

**Objectif** : trouver des mots cachés dans une grille de lettres.

### Tailles de grille

| Niveau | Grille | Directions |
|--------|--------|------------|
| Facile | 8 × 8 | → (droite) et ↓ (bas) uniquement |
| Normal | 10 × 10 | + ↘ (diagonale) |
| Difficile | 12 × 12 | 8 directions (incluant inversées) |

### Algorithme de placement

1. Trier les mots par longueur décroissante (les plus longs d'abord)
2. Pour chaque mot :
   - Normaliser (majuscules, supprimer accents)
   - Choisir une direction aléatoire parmi celles autorisées
   - Choisir une position aléatoire
   - Vérifier que le mot tient dans la grille
   - Vérifier les conflits (chevauchement permis si même lettre)
   - Placer le mot (max 100 tentatives par mot)
3. Remplir les cases vides avec des lettres aléatoires pondérées par la fréquence française

### Fréquences de remplissage (français)

```
E: 14.7%  A: 7.6%  I: 7.5%  S: 7.9%  N: 7.1%
R: 6.6%   T: 7.2%  O: 5.4%  L: 5.5%  U: 6.3%
D: 3.7%   C: 3.3%  M: 3.0%  P: 3.0%  ...
```

### Validation de la sélection

1. L'enfant glisse le doigt sur la grille
2. Le système vérifie que la sélection est en ligne droite
3. Compare les lettres sélectionnées avec chaque mot non trouvé
4. Vérifie aussi le sens inverse (pour le niveau difficile)

### Exemple pas à pas

```
Mots : [CHAT, CHIEN, RAT]
Grille 8×8 (facile, droite + bas) :

  C H I E N T A R
  R A T S U L P E
  M B D F G H J K
  C Q W E R T Y U
  H Z X C V B N M
  A O P A S D F G
  T H J K L Z X C
  V B N M Q W E R

1. L'enfant glisse de (0,0) à (4,0) → CHIEN ✓ (surligné)
2. L'enfant glisse de (0,0) à (0,6) → CHAT ✓ (vertical, surligné)
3. L'enfant glisse de (0,1) à (2,1) → RAT ✓ (surligné)
Victoire ! Tous les mots trouvés.
```

---

## 5. Mots Croisés (Crossword)

**Objectif** : remplir une grille de mots croisés à partir de définitions.

### Algorithme de génération

1. **Grille de travail** : 30 × 30 (plus grande que le résultat final)
2. **Placement du premier mot** : horizontal, centré
3. **Placement itératif** :
   - Pour chaque mot restant, chercher des intersections avec les mots déjà placés
   - Intersection = une lettre commune entre le nouveau mot et un mot existant
   - Le nouveau mot est placé **perpendiculairement** au mot existant
   - Score de chaque candidat = nombre d'intersections + compacité
   - Choisir le meilleur candidat
4. **Règle d'isolation** : une case vide obligatoire avant et après chaque mot (dans sa direction)
5. **Recadrage** : la grille est réduite au rectangle minimal contenant tous les mots
6. **Numérotation** : attribution automatique des numéros (horizontal/vertical)

### Contraintes

- Longueur minimale d'un mot : 2 lettres
- Grille finale : maximum 15 × 15
- Un mot non plaçable est simplement ignoré

### Structure de données

```
CrosswordGrid {
  grid: List<List<String?>>     // null = case noire
  placements: [CrosswordPlacement]
  horizontalClues: {num: clue}
  verticalClues: {num: clue}
}

CrosswordPlacement {
  word: String
  clue: String
  row: int
  col: int
  isHorizontal: bool
  number: int
}
```

### Exemple pas à pas

```
Mots :
  CHAT (déf: "Animal félin domestique")
  CHIEN (déf: "Meilleur ami de l'homme")
  RAT (déf: "Petit rongeur")

Étape 1 : CHAT horizontal au centre
    C H A T

Étape 2 : CHIEN vertical, intersection sur C
    C H I E N
    H
    A
    T

Étape 3 : RAT horizontal, intersection sur A (de CHAT)
    C H I E N
    H
    A
    T

  → RAT intersecte le A de CHAT (position [2]):
    C H I E N
    H
  R A T
    T

Grille finale 4×5 :
    1     2
    C  H  I  E  N     ← 1 horizontal : CHIEN (clue)
    H                  ← 1 vertical : CHAT (clue)
  3 R  A  T           ← 3 horizontal : RAT (clue)
    T

Indices horizontaux : 1. "Meilleur ami de l'homme", 3. "Petit rongeur"
Indices verticaux : 1. "Animal félin domestique"
```

---

## Sélection des mots (SRS Leitner)

Tous les jeux utilisent le système de répétition espacée pour choisir les mots :

1. **Révisions en retard** (nextReview < maintenant) — priorité maximale
2. **Boîte 1** (mots jamais vus ou échoués) — haute priorité
3. **Aléatoire** dans le dictionnaire — pour compléter

Intervalles de révision par boîte :

- Boîte 1 : immédiat
- Boîte 2 : 1 jour
- Boîte 3 : 3 jours
- Boîte 4 : 7 jours
- Boîte 5 : 14 jours (maîtrisé)

Après chaque tentative, le `LeitnerService` met à jour la boîte :

- **Réussite** : boîte +1 (max 5), prochaine révision planifiée
- **Échec** : retour en boîte 1, révision immédiate

---

## 6. Flashcard Leitner

**Objectif** : mémoriser les mots et leurs définitions par retournement de cartes.

### Fonctionnement

1. La carte recto affiche le **mot**
2. L'enfant tape la carte pour révéler le verso (**définition**)
3. L'enfant juge : **« Je savais »** / **« Je ne savais pas »**
4. Le `LeitnerService` met à jour la boîte du mot selon le jugement
5. Animations de flip (400 ms, easeInOut)

### Barème

| Condition | Score |
|-----------|-------|
| Réponse correcte sans hésitation | 100 pts |
| Réponse correcte | 70 pts |
| Réponse incorrecte | 0 pts |

---

## 7. QCM Définition

**Objectif** : choisir la bonne définition parmi 4 propositions.

### Fonctionnement

1. Un mot est affiché
2. 4 définitions sont proposées (1 correcte + 3 distracteurs issus du même dictionnaire)
3. Feedback couleur immédiat (vert = correct, rouge = incorrect)
4. Passage automatique au mot suivant après le feedback

### Barème

| Condition | Score |
|-----------|-------|
| Bonne réponse au premier essai | 100 pts |
| Mauvaise réponse | 0 pts |

---

## 8. Roue des Syllabes

**Objectif** : reconstituer un mot en remettant ses syllabes dans le bon ordre.

### Fonctionnement

1. Les syllabes du mot sont affichées mélangées dans une rangée de boutons
2. L'enfant tape les syllabes dans le bon ordre pour reconstituer le mot
3. Feedback visuel vert/rouge après chaque syllabe
4. Score affiché en fin de mot

### Algorithme de découpe

- Utilise le champ `syllphono` de Lexique 4 pour les mots issus du dictionnaire praticien
- Découpe simple (voyelle = noyau) pour les autres

### Barème

| Condition | Score |
|-----------|-------|
| Aucune erreur | 100 pts |
| 1 erreur | 60 pts |
| 2 erreurs | 30 pts |
| > 2 erreurs | 10 pts |

---

## 9. Memory (Jeu des paires)

**Objectif** : retrouver les paires mot ↔ définition sur un plateau de cartes.

### Fonctionnement

1. Les cartes sont placées face cachée sur le plateau
2. L'enfant retourne 2 cartes à la fois
3. Si la carte mot correspond à la carte définition → paire trouvée, cartes retirées
4. Sinon → les cartes sont re-cachées
5. Le jeu se termine quand toutes les paires sont trouvées

### Plateau

- Entre 4 et 10 mots sélectionnés selon la difficulté
- Cartes mot (fond coloré) + cartes définition (fond neutre)
- Animation de retournement 3D (300 ms)

### Barème

| Condition | Score |
|-----------|-------|
| 0 erreur | 100 pts |
| ≤ nb_mots erreurs | 70 pts |
| > nb_mots erreurs | 40 pts |

---

## 10. Mode Découverte

**Objectif** : explorer des mots nouveaux par niveau scolaire, sans dictionnaire préalable.

### Fonctionnement

1. **Configuration** : l'enfant choisit un cycle (CP→Terminale) et un nombre de mots (5/10/15)
2. **Présentation** : chaque mot est présenté sur une carte avec sa définition (flip)
   - L'enfant juge : « Je connais » / « Je découvre »
3. **Parcours** : selon les jugements, des activités sont proposées (jeux avec les mots « découverts »)
4. **Fin** : option de sauvegarder les mots comme nouveau dictionnaire

### Cycles disponibles

| Cycle | Niveaux Dubois-Buyse | Emoji |
|-------|----------------------|-------|
| Cycle 2 (CP→CE2) | 1–11 | 🐣 |
| Cycle 3 (CM1→6ème) | 11–20 | 🌱 |
| Collège (5ème→3ème) | 20–32 | 🚀 |
| Lycée (2nde→Terminale) | 32–43 | 🎓 |
| Surprise ! | 1–43 (aléatoire) | 🎲 |

### Accès

Disponible uniquement si `allowDiscoveryMode = true` sur le profil enfant
(activé par défaut, désactivable par le praticien).
