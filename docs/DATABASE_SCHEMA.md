# Schéma de base de données — Orphotonie

## Vue d'ensemble

L'application utilise **3 bases SQLite** :

| Base | Accès | Contenu | Localisation |
|------|-------|---------|--------------|
| `app.db` | Lecture/écriture | Données utilisateur, progression, paramètres | `{documents}/orphotonie/db/app.db` |
| `lexique4.db` | Lecture seule | **4 973 lemmes** du lexique français (version allégée pré-filtrée, 0,71 Mo) | Copié depuis `assets/data/` |
| `definitions.db` | Lecture seule | 3 725 définitions + niveaux Dubois-Buyse | Copié depuis `assets/data/` |

---

## app.db — Données utilisateur

### Diagramme ERD

```
┌─────────────┐       ┌──────────────────┐       ┌──────────────┐
│  Profiles    │       │  Dictionaries    │       │    Words     │
├─────────────┤       ├──────────────────┤       ├──────────────┤
│ PK id       │──┐    │ PK id            │──┐    │ PK id        │
│ prenom      │  │    │ FK profileId ────│──┘    │ FK dictId ───│──┘
│ nom?        │  │    │ nom              │       │ mot          │
│ avatarPath? │  │    │ description?     │       │ definition?  │
│ type        │  │    │ couleur          │       │ defCroises?  │
│ parentId?   │  │    │ icon             │       │ defFleches?  │
│ allowDiscov.│  │    │ active           │       │ imagePath?   │
│ pinHash?    │  │    │ createdAt        │       │ audioPath?   │
│ createdAt   │  │    └──────────────────┘       │ tags         │
└─────────────┘  │         │                       │ difficulty   │
                 │         ┌──────────────────┐ │ createdAt    │
                 │         │DictionaryAssign. │ └──────────────┘
                 │         ├──────────────────┤        │
                 │    ┌───┤ PK id            │ ┌────▼─────┐
                 │    │───│ FK dictionaryId  │ │WordMastery│
                 │    │   │ FK childId       │ ├───────────┤
                 │    │   │ assignedAt       │ │ PK id    │
                 │    │   └──────────────────┘ │FK profId │
                 │    │  UNIQUE(dicId,childId)│FK wordId │
                 │    │                       │ ...(voir) │
                 │    │                       └───────────┘
                 │    └──────────────────┘       │ tags         │
                 │                               │ difficulty   │
                 │    ┌──────────────────┐       │ createdAt    │
                 │    │  AppSettings     │       └──────────────┘
                 │    ├──────────────────┤              │
                 ├───▶│ PK id            │              │
                 │    │ FK profileId (U) │       ┌──────┴───────┐
                 │    │ themeName        │       │              │
                 │    │ childThemeName   │  ┌────▼─────┐  ┌────▼──────────┐
                 │    │ fontSize         │  │WordMastery│  │ WordAttempts  │
                 │    │ ttsEnabled       │  ├──────────┤  ├───────────────┤
                 │    │ ttsRate          │  │ PK id    │  │ PK id         │
                 │    │ ttsVolume        │  │FK profId │  │ FK sessionId  │
                 │    │ soundEnabled     │  │FK wordId │  │ FK wordId     │
                 │    │ sessionDurLimit  │  │ nbSeen   │  │ success       │
                 │    │ onboardingDone   │  │ nbSuccess│  │ firstTry      │
                 │    └──────────────────┘  │nbFirstTry│  │ hintUsed      │
                 │                          │consecOk  │  │ durationMs    │
                 │    ┌──────────────────┐  │leitnerBox│  │ errorLetters  │
                 │    │  Sessions        │  │nextReview│  └───────────────┘
                 │    ├──────────────────┤  │ lastSeen │         ▲
                 ├───▶│ PK id            │  │masteryLvl│         │
                 │    │ FK profileId     │  └──────────┘         │
                 │    │ FK dictionaryId  │       ▲               │
                 │    │ activityType     │       │               │
                 │    │ startedAt        │  UNIQUE(profId,wordId)│
                 │    │ endedAt?         │                       │
                 │    │ score            │───────────────────────┘
                 │    └──────────────────┘
                 │
                 │    ┌──────────────────┐
                 │    │  DailyStats      │
                 │    ├──────────────────┤
                 └───▶│ PK id            │
                      │ FK profileId     │
                      │ date             │
                      │ wordsSeen        │
                      │ wordsSuccess     │
                      │ minutesPlayed    │
                      └──────────────────┘
                      UNIQUE(profileId, date)
```

### Tables détaillées

#### Profiles

| Colonne | Type | Contrainte | Description |
|---------|------|------------|-------------|
| `id` | INTEGER | PK, auto-increment | Identifiant unique |
| `prenom` | TEXT | NOT NULL, 1–100 chars | Prénom de l'utilisateur |
| `nom` | TEXT | nullable, 1–100 chars | Nom (optionnel) |
| `avatar_path` | TEXT | nullable | Chemin vers l'avatar local |
| `type` | TEXT | default `'enfant'` | `'praticien'` ou `'enfant'` |
| `parent_id` | INTEGER | nullable, FK → profiles.id | Id du praticien parent (null si praticien) |
| `allow_discovery_mode` | INTEGER (bool) | default 1 | Mode Découverte accessible à l’enfant |
| `pin_hash` | TEXT | nullable | Hash SHA-256 du PIN praticien |
| `created_at` | INTEGER (epoch) | default CURRENT_TIMESTAMP | Date de création |

#### Dictionaries

| Colonne | Type | Contrainte | Description |
|---------|------|------------|-------------|
| `id` | INTEGER | PK, auto-increment | Identifiant unique |
| `profile_id` | INTEGER | FK → profiles.id | Profil propriétaire |
| `nom` | TEXT | NOT NULL, 1–100 chars | Nom du dictionnaire |
| `description` | TEXT | nullable | Description libre |
| `couleur` | TEXT | default `'#6A5AE0'` | Code couleur hexadécimal |
| `icon` | TEXT | default `'book'` | Nom de l'icône Material |
| `active` | INTEGER (bool) | default 1 | 0 = archivé |
| `created_at` | INTEGER (epoch) | default CURRENT_TIMESTAMP | Date de création |

#### DictionaryAssignments

Table de liaison entre un dictionnaire (propriété du praticien) et les enfants
qui y ont accès. Un dictionnaire peut être assigné à plusieurs enfants.

| Colonne | Type | Contrainte | Description |
|---------|------|------------|-------------|
| `id` | INTEGER | PK, auto-increment | Identifiant unique |
| `dictionary_id` | INTEGER | FK → dictionaries.id | Dictionnaire assigné |
| `child_id` | INTEGER | FK → profiles.id | Enfant bénéficiaire |
| `assigned_at` | INTEGER (epoch) | default CURRENT_TIMESTAMP | Date d'assignation |

**Contrainte unique** : `(dictionary_id, child_id)`

#### Words

| Colonne | Type | Contrainte | Description |
|---------|------|------------|-------------|
| `id` | INTEGER | PK, auto-increment | Identifiant unique |
| `dictionary_id` | INTEGER | FK → dictionaries.id | Dictionnaire parent |
| `mot` | TEXT | NOT NULL | Le mot |
| `definition` | TEXT | nullable | Définition personnalisée |
| `def_croises` | TEXT | nullable | Définition pour mots croisés |
| `def_fleches` | TEXT | nullable | Définition pour mots fléchés |
| `image_path` | TEXT | nullable | Chemin image locale |
| `audio_path` | TEXT | nullable | Chemin audio local |
| `tags` | TEXT | default `'[]'` | Tags JSON |
| `difficulty` | INTEGER | default 1 | Difficulté (1–3) |
| `created_at` | INTEGER (epoch) | default CURRENT_TIMESTAMP | Date de création |

#### WordMastery

| Colonne | Type | Contrainte | Description |
|---------|------|------------|-------------|
| `id` | INTEGER | PK, auto-increment | Identifiant unique |
| `profile_id` | INTEGER | FK → profiles.id | Profil de l'apprenant |
| `word_id` | INTEGER | FK → words.id | Mot concerné |
| `nb_seen` | INTEGER | default 0 | Nombre total de présentations |
| `nb_success` | INTEGER | default 0 | Nombre de réussites |
| `nb_first_try` | INTEGER | default 0 | Réussites du premier coup |
| `consecutive_ok` | INTEGER | default 0 | Réussites consécutives actuelles |
| `leitner_box` | INTEGER | default 1 | Boîte Leitner (1–5) |
| `next_review` | INTEGER (epoch) | nullable | Prochaine révision planifiée |
| `last_seen` | INTEGER (epoch) | nullable | Dernière présentation |
| `mastery_level` | INTEGER | default 0 | Niveau de maîtrise (0–4) |

**Contrainte unique** : `(profile_id, word_id)`

#### Sessions

| Colonne | Type | Contrainte | Description |
|---------|------|------------|-------------|
| `id` | INTEGER | PK, auto-increment | Identifiant unique |
| `profile_id` | INTEGER | FK → profiles.id | Profil joueur |
| `dictionary_id` | INTEGER | FK → dictionaries.id | Dictionnaire utilisé |
| `activity_type` | TEXT | NOT NULL | Type d'activité |
| `started_at` | INTEGER (epoch) | default CURRENT_TIMESTAMP | Début de session |
| `ended_at` | INTEGER (epoch) | nullable | Fin de session |
| `score` | INTEGER | default 0 | Score (0–100) |

**Types d'activité** : `memoire`, `puzzle`, `reconnaissance`, `dictee`, `associations`

#### WordAttempts

| Colonne | Type | Contrainte | Description |
|---------|------|------------|-------------|
| `id` | INTEGER | PK, auto-increment | Identifiant unique |
| `session_id` | INTEGER | FK → sessions.id | Session parent |
| `word_id` | INTEGER | FK → words.id | Mot tenté |
| `success` | INTEGER (bool) | default 0 | Réussi ou non |
| `first_try` | INTEGER (bool) | default 0 | Réussi du premier coup |
| `hint_used` | INTEGER (bool) | default 0 | Indice utilisé |
| `duration_ms` | INTEGER | default 0 | Durée en ms |
| `error_letters` | TEXT | default `'[]'` | Lettres erronées (JSON) |

#### DailyStats

| Colonne | Type | Contrainte | Description |
|---------|------|------------|-------------|
| `id` | INTEGER | PK, auto-increment | Identifiant unique |
| `profile_id` | INTEGER | FK → profiles.id | Profil concerné |
| `date` | INTEGER (epoch) | NOT NULL | Jour (tronqué à minuit) |
| `words_seen` | INTEGER | default 0 | Mots vus ce jour |
| `words_success` | INTEGER | default 0 | Mots réussis ce jour |
| `minutes_played` | INTEGER | default 0 | Minutes jouées ce jour |

**Contrainte unique** : `(profile_id, date)`

#### AppSettings

| Colonne | Type | Contrainte | Description |
|---------|------|------------|-------------|
| `id` | INTEGER | PK, auto-increment | Identifiant unique |
| `profile_id` | INTEGER | FK → profiles.id, UNIQUE | Un réglage par profil |
| `theme_name` | TEXT | default `'systeme'` | `'clair'`, `'sombre'` ou `'systeme'` |
| `child_theme_name` | TEXT | default `'ocean'` | `'espace'`, `'foret'`, `'ocean'` ou `'fantasy'` |
| `font_size` | REAL | default 1.0 | Facteur de taille (0.8–2.0) |
| `tts_enabled` | INTEGER (bool) | default 1 | Synthèse vocale active |
| `tts_rate` | REAL | default 0.8 | Vitesse TTS (0.5–1.0) |
| `tts_volume` | REAL | default 1.0 | Volume TTS (0.0–1.0) |
| `sound_enabled` | INTEGER (bool) | default 1 | Retour sonore actif |
| `session_duration_limit_min` | INTEGER | default 0 | Limite session (0 = illimité) |
| `onboarding_done` | INTEGER (bool) | default 0 | Onboarding terminé |
| `dyslexic_font` | INTEGER (bool) | default 0 | Police OpenDyslexic activée |
| `high_contrast` | INTEGER (bool) | default 0 | Mode contraste élevé |
| `color_blind_mode` | TEXT | default `'none'` | `'none'`, `'deuteranopia'`, `'protanopia'`, `'tritanopia'` |
| `reduce_animations` | INTEGER (bool) | default 0 | Réduire les animations |
| `large_targets` | TEXT | default `'normal'` | `'normal'`, `'large'`, `'xlarge'` |
| `haptic_feedback` | INTEGER (bool) | default 1 | Retour haptique activé |
| `text_spacing` | INTEGER (bool) | default 0 | Espacement texte dyslexie |
| `show_captions` | INTEGER (bool) | default 0 | Sous-titres audio affichés |

### Historique des migrations

| Version | Modification |
|---------|-------------|
| 1 → 2 | Ajout `onboarding_done` dans AppSettings |
| 2 → 3 | Ajout `tts_rate`, `tts_volume` dans AppSettings |
| 3 → 4 | Ajout `child_theme_name` dans AppSettings |
| 4 → 5 | Ajout `parent_id` dans Profiles |
| 5 → 6 | Création table `DictionaryAssignments` ; migration des dictionnaires enfant vers praticien |
| 6 → 7 | Ajout colonnes accessibilité dans AppSettings (`dyslexic_font`, `high_contrast`, `color_blind_mode`, `reduce_animations`, `large_targets`, `haptic_feedback`, `text_spacing`, `show_captions`) |
| 7 → 8 | Ajout `allow_discovery_mode` dans Profiles |

### Migration Drift : Ajout du champ parentId (liaison enfant/praticien)

**Étape 1 : Ajout du champ dans la table Drift**

Dans `profiles_table.dart` :

```dart
IntColumn get parentId => integer().nullable()();
```

**Étape 2 : Génération du code Drift**

Dans le terminal :

```
flutter pub run build_runner build --delete-conflicting-outputs
```

**Étape 3 : Migration de la base existante**

Si tu es en développement, tu peux simplement supprimer le fichier `app.db` pour repartir sur une base propre.

Sinon, ajoute une migration dans ta classe `AppDatabase` :

```dart
@DriftDatabase(...)
class AppDatabase extends _$AppDatabase {
     ...
     @override
     MigrationStrategy get migration => MigrationStrategy(
          onUpgrade: (m, from, to) async {
               if (from == X && to == X+1) {
                    await m.addColumn(profiles, profiles.parentId);
               }
               // autres migrations...
          },
     );
}
```

Remplace `X` par la version précédente de ta base.

**Étape 4 : Mise à jour du code métier**

- Lors de la création d’un enfant, renseigne le champ `parentId` avec l’id du praticien.
- Pour récupérer les enfants d’un praticien :

     ```dart
     (select(profiles)..where((p) => p.parentId.equals(praticienId))).get();
     ```

- Pour afficher tous les dictionnaires liés :
  - Récupère la liste des ids enfants
  - Modifie la requête des dictionnaires pour inclure `profileId == praticienId` **ou** `profileId` dans la liste des enfants

**Étape 5 : Vérification**

- Teste la création d’un enfant et l’affichage des dictionnaires pour le praticien.

---

## lexique4.db — Lexique français (lecture seule)

**189 863 entrées** — Base de données linguistique Lexique 4 (New et al., 2026).

| Colonne | Type | Description |
|---------|------|-------------|
| `mot` | TEXT | Forme orthographique |
| `phono` | TEXT | Transcription phonologique (SAMPA) |
| `phono_ipa` | TEXT | Transcription IPA |
| `cgram` | TEXT | Catégorie grammaticale (NOM, VER, ADJ…) |
| `cgram_ortho` | TEXT | Catégorie grammaticale (forme longue) |
| `nbsyll` | INTEGER | Nombre de syllabes |
| `nblettres` | INTEGER | Nombre de lettres |
| `nbphons` | INTEGER | Nombre de phonèmes |
| `syllphono` | TEXT | Découpage syllabique phonologique |
| `cvortho` | TEXT | Structure consonne/voyelle |
| `freqortho` | REAL | Fréquence orthographique |
| `cdortho` | REAL | Coefficient de dispersion |
| `preval` | REAL | Prévalence lexicale |
| `freqlemme` | REAL | Fréquence du lemme |
| `freqmot` | REAL | Fréquence du mot |
| `lemme` | TEXT | Forme lemmatisée |
| `islem` | INTEGER | 1 = forme lemme, 0 = forme fléchie |
| `genre` | TEXT | Genre (m, f) |
| `nombre` | TEXT | Nombre (s, p) |
| `morphodecomp` | TEXT | Décomposition morphologique |
| `nbhomoph` | INTEGER | Nombre d'homophones |

> ⚠️ **Note** : la version embarquée `lexique4.db` est pré-filtrée (uniquement `islem = 1`).
> Aucune requête supplémentaire sur ce champ n’est nécessaire dans l’application.

---

## definitions.db — Définitions (lecture seule)

**3 725 entrées** — Définitions + échelle Dubois-Buyse (niveaux 1–43).

| Colonne | Type | Description |
|---------|------|-------------|
| `mot` | TEXT | Mot défini |
| `definition` | TEXT | Définition générale |
| `def_croises` | TEXT | Définition courte (mots croisés) |
| `def_fleches` | TEXT | Définition indice (mots fléchés) |
| `niveau_dubois` | INTEGER | Niveau Dubois-Buyse (1–43) |

L'échelle Dubois-Buyse ordonne les mots par difficulté d'acquisition :

- Niveaux 1–10 : mots acquis en CP/CE1
- Niveaux 11–20 : CE2/CM1
- Niveaux 21–30 : CM2/6ème
- Niveaux 31–43 : collège et au-delà
