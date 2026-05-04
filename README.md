# Orphotonie

Application Flutter d'orthophonie, **100 % hors ligne**.

5 jeux éducatifs pour aider les enfants à mémoriser des mots,
pilotés par un système de répétition espacée (Leitner).

## Fonctionnalités

- Profils praticien (PIN) et enfant
- Dictionnaires personnalisés avec images et audio
- Recherche dans Lexique 4 (189 863 mots français)
- 5 jeux : Anagramme, Pendu, Mot Lacunaire, Mots Cachés, Mots Croisés
- Répétition espacée automatique (5 boîtes Leitner)
- Statistiques et export PDF
- Partage de dictionnaires (QR Code + fichier .orpho)
- 4 thèmes visuels enfant, mode clair/sombre
- Accessibilité WCAG AA
- Synthèse vocale et retour sonore

## Plateformes

Android · Windows · Web (PWA)

## Prérequis

- Flutter SDK ≥ 3.5.3
- Dart SDK ≥ 3.5.3

## Lancement

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Tests

```bash
flutter test
```

## Build release

```bash
flutter build windows --release
flutter build apk --release
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Schéma de base de données](docs/DATABASE_SCHEMA.md)
- [Activités de jeu](docs/ACTIVITIES.md)
- [Intégration Lexique 4](docs/LEXIQUE4_INTEGRATION.md)
- [Guide praticien](docs/USER_GUIDE_PRACTITIONER.md)
- [Guide parent](docs/USER_GUIDE_PARENT.md)

## Licence

Distribué sous licence [MIT](LICENSE).

## Développement assisté par IA

Voir [AI_DISCLOSURE.md](AI_DISCLOSURE.md) pour les informations sur le développement assisté par GitHub Copilot.
