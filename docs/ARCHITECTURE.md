# Architecture — Orphotonie

## Vue d'ensemble

Orphotonie est une application Flutter multiplateforme d'orthophonie, **100 % hors ligne**.
Elle cible Android, Windows, macOS, iOS et Linux.

```
┌──────────────────────────────────────────────────────────┐
│                     Flutter UI                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐  │
│  │  Écrans  │  │ Widgets  │  │  Thèmes  │  │ A11y    │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘  │
│       │              │             │              │       │
│  ┌────▼──────────────▼─────────────▼──────────────▼────┐ │
│  │              Riverpod (Providers)                   │ │
│  │  appThemeProvider · authNotifier · srsProviders     │ │
│  └────┬────────────────────────────────────────────────┘ │
│       │                                                  │
│  ┌────▼──────────────────────────────────────────────┐   │
│  │          Services / Logique métier                │   │
│  │  LeitnerService · ShareEncoder · AudioFeedback    │   │
│  └────┬──────────────────────────────────────────────┘   │
│       │                                                  │
│  ┌────▼──────────────────────────────────────────────┐   │
│  │             DAOs (Drift)                          │   │
│  │  ProfilesDao · DictionariesDao · WordsDao         │   │
│  │  DictionaryAssignmentsDao · StatsDao              │   │
│  └────┬──────────────────────────────────────────────┘   │
│       │                                                  │
│  ┌────▼──────────────────────────────────────────────┐   │
│  │         Bases SQLite (NativeDatabase)             │   │
│  │  app.db (R/W)  lexique4.db (RO)  definitions.db  │   │
│  └───────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

---

## Organisation des sources

```
lib/
├── main.dart                  # Point d'entrée
├── core/
│   ├── accessibility/         # Helpers Semantics + Focus
│   ├── audio/                 # TTS, retour sonore
│   ├── database/
│   │   ├── dao/               # 5 DAOs Drift
│   │   ├── tables/            # 9 tables Drift
│   │   ├── storage/           # Initialisation et copie DB
│   │   ├── app_database.dart
│   │   ├── lexique4_database.dart
│   │   ├── definitions_database.dart
│   │   ├── database_providers.dart
│   │   └── local_storage.dart
│   ├── router/                # GoRouter + auth redirect
│   ├── sharing/               # Export/import .orpho + QR
│   ├── theme/                 # Material 3 + 4 thèmes enfant
│   └── utils/                 # Constantes applicatives
└── features/
    ├── auth/                  # Profils, PIN, onboarding
    ├── decouverte/            # Mode Découverte (exploration libre)
    ├── dictionaries/          # CRUD dictionnaires
    ├── games/
    │   ├── anagram/           # Jeu Anagramme
    │   ├── crossword/         # Jeu Mots Croisés
    │   ├── definition_qcm/    # Jeu QCM Définition
    │   ├── fill_blank/        # Jeu Mot Lacunaire
    │   ├── flashcard/         # Jeu Flashcard Leitner
    │   ├── hangman/           # Jeu Pendu
    │   ├── memory/            # Jeu Memory (paires mot↔définition)
    │   ├── syllables/         # Jeu Roue des Syllabes
    │   └── word_search/       # Jeu Mots Cachés
    ├── help/                  # Aide contextuelle
    ├── search/                # Recherche Lexique 4
    ├── session/               # Sessions de jeu
    ├── sharing/               # Écrans partage/import
    ├── srs/                   # Répétition espacée Leitner
    └── stats/                 # Statistiques + PDF
```

---

## Architecture feature-first

Chaque feature suit la structure :

```
feature/
├── data/            # Modèles de données locaux
├── presentation/    # Widgets, écrans
├── services/        # Logique métier
└── providers.dart   # Providers Riverpod
```

Les features ne dépendent **jamais** les unes des autres directement.
Les dépendances partagées passent par `core/`.

---

## Flux de données

```
UI (ConsumerWidget)
  │  ref.watch(provider)
  ▼
Provider (Riverpod)
  │  appDatabaseProvider / lexique4Provider / ...
  ▼
DAO (Drift @DriftAccessor)
  │  Requêtes typées, Streams réactifs
  ▼
Drift (code généré .g.dart)
  │  SQL compilé + sérialisation
  ▼
SQLite (NativeDatabase via sqlite3_flutter_libs)
  │  Fichiers locaux dans documents/orphotonie/db/
  ▼
Stockage local (path_provider)
```

**Réactivité** : Les DAOs exposent des `Stream<List<T>>` via `watch()`.
Riverpod propage automatiquement les changements vers l'UI.

---

## Décisions techniques

| Choix | Justification |
|-------|---------------|
| **Drift** plutôt que sqflite | Requêtes typées, migrations versionnées, code généré, Streams réactifs, support desktop natif |
| **Riverpod** plutôt que Bloc | Plus léger, compile-time safe, dispose automatique, adapté aux providers DB singleton |
| **GoRouter** | Routing déclaratif, deep links, redirect auth, support web |
| **100 % offline** | Public cible (enfants, écoles) sans connexion fiable. Aucune requête réseau dans l'app |
| **3 bases séparées** | `lexique4.db` et `definitions.db` sont en lecture seule, embarquées dans les assets. `app.db` contient les données utilisateur modifiables |
| **google_fonts local** | Polices Nunito + Baloo2 embarquées dans `assets/fonts/`, pas de téléchargement réseau |
| **Architecture feature-first** | Isolation des domaines, navigation claire, testabilité indépendante |

---

## Gestion d'état

| Couche | Outil | Exemple |
|--------|-------|---------|
| Thème global | `StateNotifier` + Riverpod | `AppThemeNotifier` persiste dans `app_settings` |
| Authentification | `StateNotifier` | `AuthNotifier` : profil sélectionné, PIN vérifié |
| Données DB | `Provider` / `FutureProvider` | `appDatabaseProvider`, `lexique4Provider` |
| Jeux | `StateNotifier` par feature | `AnagramNotifier`, `HangmanNotifier`, etc. |
| Streams réactifs | DAOs Drift | `watchWordsForDictionary()`, `watchRecentStats()` |

---

## Sécurité

- PIN praticien : hash SHA-256 stocké dans `flutter_secure_storage`
- Aucune donnée ne quitte l'appareil (pas de réseau)
- `PRAGMA foreign_keys = ON` sur chaque ouverture de `app.db`
- Partage via `.orpho` : l'utilisateur contrôle explicitement l'export

---

## Tests

```
test/
├── unit/              # Tests unitaires (logique, encodage, DB)
└── widget/            # Tests widget (accessibilité, UI)
```

Couverture : logique des 9 jeux, mode Découverte, encodeur/décodeur partage,
DAOs, services SRS, contraste WCAG AA, sémantique d'accessibilité.
