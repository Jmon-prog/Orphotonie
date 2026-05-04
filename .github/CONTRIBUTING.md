# Contribuer à Orphotonie

Merci de l'intérêt que vous portez au projet ! Voici les règles pour contribuer.

## Prérequis

- Flutter SDK ≥ 3.5.3 / Dart SDK ≥ 3.5.3
- Un éditeur avec le plugin Dart/Flutter (VS Code ou Android Studio)

## Démarrage rapide

```bash
git clone https://github.com/<votre-org>/orphotonie.git
cd orphotonie/orphotonie
flutter pub get
flutter run
```

## Règles de contribution

### Langue

- Commentaires de code : **français**
- Commits et PR : **français**
- Issues : français ou anglais acceptés

### Architecture

- **Feature-first** : tout nouveau code va dans `lib/features/<fonctionnalite>/`
- **100 % hors ligne** : aucune requête réseau (pas de `http`, `firebase`, `supabase`)
- **Drift uniquement** pour les données persistantes (pas de `SharedPreferences`)

### Qualité

Avant de soumettre une PR :

```bash
cd orphotonie
flutter analyze --fatal-infos   # doit afficher "No issues found"
flutter test                    # tous les tests doivent passer
dart fix --apply                # corriger les suggestions automatiques
```

### Conventions de code

- En-tête sur chaque nouveau fichier Dart :

  ```dart
  // ============================================================
  // Fichier : lib/features/.../mon_fichier.dart
  // Description : Description en français.
  // ============================================================
  ```

- `try/catch` obligatoire sur toute opération base de données
- `Semantics()` sur chaque élément interactif (accessibilité)
- Widgets responsives avec `LayoutBuilder`

### Commits

Format : `type(scope): message en français`

Types : `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

Exemples :

```text
feat(jeux): ajouter le mode difficile au jeu Pendu
fix(db): corriger la suppression des mots avec contrainte FK
docs(readme): mettre à jour les instructions d'installation
```

## Soumettre une Pull Request

1. Créer une branche depuis `develop` : `git checkout -b feat/ma-fonctionnalite`
2. Faire les modifications et commits
3. Vérifier `flutter analyze` et `flutter test`
4. Pousser et ouvrir une PR vers `develop` (pas `main`)
5. Décrire les changements et les tests effectués

## Signaler un bug

Utilisez le [template de rapport de bug](.github/ISSUE_TEMPLATE/bug_report.md).

## Licence

En contribuant, vous acceptez que votre code soit distribué sous licence [MIT](LICENSE).
