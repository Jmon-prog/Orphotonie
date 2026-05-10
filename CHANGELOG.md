# Changelog

Toutes les modifications notables de ce projet sont documentées ici.
Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/).

## [0.2.1] - 2026-05-10

### Corrigé

- **Filtres phonémiques** : remplacement de `LIKE` (insensible à la casse) par `GLOB` (sensible à la casse) pour les filtres sur la colonne `phono` (SAMPA). Évite que le son `[S]` (ch) corresponde aux mots contenant `[s]`, et vice versa pour tous les couples SAMPA (`Z`/`z`, `J`/`j`, `N`/`n`, `R`/`r`, `A`/`a`, `E`/`e`, etc.)
- **Homophones** : correction du seuil `nbhomoph >= 1` → `>= 2`. Dans Lexique4, `nbhomoph` compte le mot lui-même ; `nbhomoph = 1` signifie "aucun homophone" et non "au moins un". Le filtre retournait incorrectement 4 591 mots (dont 1 293 sans aucun homophone) ; il en retourne maintenant 3 298 pertinents
- **Filtre morphodecomp** : `IS NOT NULL` couvrait 99,4 % de la base (inefficace). Remplacé par une détection réelle de la décomposition morphologique : présence d'un préfixe (`_`) ou d'un suffixe (`.`), soit 66 % des mots. Label mis à jour : "Avec préfixe ou suffixe"

### Modifié

- **Raccourcis rapides** (`kQuickSearches`) : révision complète des 4 filtres génériques
  - "Mots très connus" (`preval > 90`, trop restrictif) → **"Mots fréquents"** (`preval >= 75`)
  - "Morphologie riche" (99 % de la base, inutile) → **"Monosyllabes"** (`nbsyll = 1`)
  - "Mots ambigu POS" (jargon technique) → **"Groupes consonantiques"** (`cvortho GLOB '*CC*'`)
  - "Homophones" supprimé des raccourcis rapides (disponible dans les filtres avancés)
- Reformatage automatique `dart format` sur les fichiers de thème

## [0.2.0] - 2026-05-08

### Ajouté

- Nouveaux widgets partagés : `AppSpacing`, `AppRadius`, `ThemedAppBar`, `EmptyState`, `ShimmerListView`, `ShimmerGridView`, `AnimatedCounter`, `ScoreBadge`, `ProfileAvatar`, `ProfileAvatarWithBadge`
- Barre d'accent dégradée (primary → secondary) sous chaque AppBar via `ThemedAppBar`
- États vides illustrés (`EmptyState`) sur toutes les listes
- Squelettes de chargement shimmer remplaçant les indicateurs de progression circulaires
- Compteur animé `AnimatedCounter` pour les scores de jeux

### Modifié

- Refonte complète du thème Material 3 (`app_theme.dart`) : hiérarchie de boutons, tokens d'espacement, cartes, dialogues, navigation
- `AppColors` : palette douce accessible (WCAG AA) — constantes centralisées
- Mise à jour vers schéma Drift v9 avec colonne `archivedAt` sur les profils
- `ThemedAppBar` câblé sur l'ensemble des écrans praticien (24+)
- `ProfileAvatar` avec Hero animation câblé dans la sélection de profil et les fiches
- `ShimmerGridView` remplace le `CircularProgressIndicator` dans la sélection de profil enfant
- `EmptyState` câblé dans les listes de dictionnaires, mots, statistiques et résultats de recherche
- Documentation Dart (`///`) complète sur tous les nouveaux widgets et classes publiques

### Corrigé

- Remplacement de `Color.withValues()` (non disponible dans la version Flutter utilisée) par `withOpacity()` dans tous les fichiers
- Paramètre `subtitle` manquant dans `ThemedAppBar` ajouté (rendu en `Column`)
- 13 erreurs de compilation initiales résolues (Drift codegen, API PinService, imports inutilisés)

## [0.1.0] - 2026-04-20

### Ajouté

- Gestion de profils (praticien avec PIN, enfant)
- Onboarding praticien et parent
- Création et gestion de dictionnaires personnalisés
- Ajout de mots avec définition, image et audio
- Moteur de recherche Lexique 4 (189 863 mots français)
- 5 jeux éducatifs :
  - Anagramme (mélange de lettres)
  - Pendu (devinette lettre par lettre)
  - Mot Lacunaire (lettres manquantes, 3 modes)
  - Mots Cachés (grille, 3 niveaux de difficulté)
  - Mots Croisés (grille générée automatiquement)
- Système de répétition espacée Leitner (5 boîtes)
- Statistiques quotidiennes et historique des sessions
- Export PDF de progression
- Synthèse vocale (TTS) avec vitesse et volume réglables
- Retour sonore (succès, erreur, clic)
- Partage de dictionnaires par QR Code et fichier .orpho
- Import de dictionnaires (scan QR, fichier, code texte)
- 4 thèmes visuels enfant (Espace, Forêt, Océan, Fantaisie)
- Mode clair / sombre / système
- Accessibilité WCAG AA (contraste, taille de texte, Semantics)
- Navigation clavier et focus traversal (desktop)
- 100 % hors ligne — aucune requête réseau
- Support multiplateforme : Android, Windows, macOS, Linux, iOS
