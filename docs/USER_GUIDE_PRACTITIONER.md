# Guide Praticien — Orphotonie

## Premiers pas

### Créer un profil praticien

1. Au lancement, l'écran de sélection des profils s'affiche
2. Appuyez sur **« Nouveau praticien »**
3. Renseignez votre prénom (obligatoire) et nom (optionnel)
4. Choisissez un avatar (photo ou image par défaut)
5. Définissez un **code PIN à 4 chiffres** pour sécuriser l'accès
6. Choisissez une question secrète (en cas d'oubli du PIN)
7. Validez — votre profil est créé

### Créer un profil enfant

1. Depuis l'espace praticien, accédez à la liste des profils
2. Appuyez sur **« Nouveau profil enfant »**
3. Renseignez le prénom de l'enfant
4. Choisissez un avatar
5. Validez — le profil est prêt

---

## Gérer les dictionnaires

### Créer un dictionnaire

1. Depuis l'écran principal praticien, appuyez sur **« + Nouveau dictionnaire »**
2. Donnez un nom (ex : « Animaux », « Sons [ch] », « Vocabulaire CE1 »)
3. Ajoutez une description (optionnel)
4. Choisissez une couleur et une icône
5. Validez

### Ajouter des mots

**Depuis la recherche Lexique 4 :**

1. Ouvrez un dictionnaire puis appuyez sur **« Rechercher »**
2. Tapez le début d'un mot dans la barre de recherche
3. Les résultats s'affichent avec les informations linguistiques :
   - Phonétique IPA, catégorie grammaticale
   - Nombre de syllabes, fréquence d'usage
4. Appuyez sur un mot pour l'ajouter au dictionnaire
5. Personnalisez la définition si besoin

**Manuellement :**

1. Depuis la liste des mots, appuyez sur **« + Ajouter un mot »**
2. Tapez le mot, sa définition
3. Ajoutez une image (photo ou fichier) et/ou un enregistrement audio
4. Réglez la difficulté (1 = facile, 2 = moyen, 3 = difficile)

### Partager un dictionnaire

1. Ouvrez le dictionnaire, appuyez sur **« Partager »**
2. Choisissez le mode :
   - **QR Code** : pour les petits dictionnaires (≤ 30 mots). L'autre praticien
     scanne le QR depuis l'écran d'import
   - **Fichier .orpho** : pour les dictionnaires avec images/audio.
     Le fichier est partagé via le système de partage du téléphone
3. Le destinataire importe depuis l'écran **« Importer »**

### Importer un dictionnaire

1. Depuis le menu, ouvrez **« Importer »**
2. Trois options :
   - **Scanner un QR Code** : pointez la caméra vers le QR
   - **Ouvrir un fichier .orpho** : sélectionnez le fichier reçu
   - **Coller un code** : collez un code `ORPH-...` partagé par texte
3. Un aperçu du dictionnaire s'affiche (nom, nombre de mots)
4. Confirmez l'import

---

## Lancer une session de jeu

1. Sélectionnez le profil de l'enfant
2. Choisissez un dictionnaire
3. Sélectionnez une activité parmi les **9 jeux** :
   - **Anagramme** — réordonner les lettres mélangées
   - **Pendu** — deviner lettre par lettre
   - **Mot Lacunaire** — compléter les lettres manquantes
   - **Mots Cachés** — trouver les mots dans une grille
   - **Mots Croisés** — remplir la grille à partir de définitions
   - **Flashcard** — retourner des cartes mot/définition
   - **QCM Définition** — choisir la bonne définition parmi 4
   - **Syllabes** — remettre les syllabes dans le bon ordre
   - **Memory** — retrouver les paires mot ↔ définition
4. Ajustez les paramètres de difficulté si disponibles
5. L’enfant joue en autonomie

Le système de **répétition espacée** (Leitner) sélectionne automatiquement
les mots à réviser en priorité.

---

## Mode Découverte

Le mode Découverte permet à l’enfant d’explorer des mots nouveaux classés
par niveau scolaire (Dubois-Buyse), sans dictionnaire préalable.

1. Activer/désactiver depuis la fiche du profil enfant (**« Mode Découverte »**)
2. L’enfant choisit un cycle scolaire (CP, CM, Collège, Lycée, Surprise) et un nombre de mots
3. Chaque mot est présenté avec sa définition ; l’enfant juge « Je connais » / « Je découvre »
4. Un parcours de jeux est proposé pour les mots découverts
5. En fin de session, option de sauvegarder la liste comme nouveau dictionnaire

---

## Consulter la progression

### Statistiques quotidiennes

- **Mots vus** : nombre de mots présentés dans la journée
- **Mots réussis** : nombre de réussites
- **Temps de jeu** : durée totale des sessions

### Historique des sessions

- Liste des sessions passées avec :
  - Date et durée
  - Type d'activité
  - Score obtenu (0–100)

### Niveau de maîtrise

Chaque mot a un **niveau de maîtrise** (0–4) basé sur les boîtes Leitner :

- 0 : Jamais vu
- 1 : En apprentissage
- 2 : En cours d'acquisition
- 3 : Bien connu
- 4 : Maîtrisé

### Export PDF

Le praticien peut exporter un rapport PDF de progression contenant :

- Résumé général (mots maîtrisés, en cours, à revoir)
- Graphique d'évolution sur 30 jours
- Détail par mot

---

## Paramètres

### Thème

- **Mode** : Clair, Sombre ou Système (suit le réglage de l'appareil)
- **Thème enfant** : 4 thèmes visuels pour l'interface enfant
  - Espace (bleu nuit + doré)
  - Forêt (vert + ambre)
  - Océan (bleu cyan, par défaut)
  - Fantaisie (violet + rose)

### Synthèse vocale (TTS)

- Activer/désactiver la lecture vocale
- Régler la vitesse (0.5 = lent, 1.0 = normal). Défaut : 0.8
- Régler le volume

### Retour sonore

- Sons de feedback (succès, erreur, clic)
- Activer/désactiver

### Durée de session

- Limiter le temps de jeu en minutes (0 = illimité)
- Alerte douce quand le temps est écoulé

### Options d'accessibilité

- **Police dyslexie** (OpenDyslexic) : active une police adaptée pour les profils dyslexiques
- **Contraste élevé** : renforce le contraste des couleurs
- **Mode daltonisme** : deuteranopie, protanopie, tritanopie
- **Réduire les animations** : désactive les animations de transition
- **Taille des cibles** : normale, grande, très grande
- **Retour haptique** : vibration sur les actions
- **Espacement du texte** : letter-spacing et word-spacing accrus
- **Sous-titres audio** : affiche le texte lu par le TTS

---

## Accessibilité

L'application respecte le niveau **WCAG AA** :

- Contraste de couleur ≥ 4.5:1 sur tous les thèmes
- Taille de texte minimale 16sp (corps), 14sp (légendes)
- Cibles tactiles ≥ 44dp (praticien) / 48dp (enfant)
- Compatible lecteur d'écran (Semantics sur tous les éléments interactifs)
- Navigation clavier complète (Tab, Entrée, Espace)
