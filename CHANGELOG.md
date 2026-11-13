# Changelog

## v2.2.0

- Les maps vides sont fournies dans maps_default\ ; maps\ (tes stuffs) est exclu de git.
- Profils et partage : plusieurs profils, export (fichier .stuffpack ou code) et import sans écraser (touche F1).
- Correction de la hauteur de téléportation (TpZOffset).
- Modification complète d'un stuff depuis la gestion : type, catégorie, nom, coordonnées, commandes, info (double-clic).
- Coordonnées en temps réel dans le coin inférieur gauche (touche Insert).
- Vérification de l'installation au lancement, puis test d'envoi de commandes une fois CS2 lancé (option `AutoCheck`).
- Mise à jour automatique au lancement (option `AutoUpdate`) et `update.bat` pour mettre à jour en double-clic.

## v2.1.0

- Exec automatique du cfg d'entraînement à l'ouverture du menu (une fois par map détectée), et `F6` pour le relancer.
- `sv_cheats 1` envoyé avant chaque commande du menu.
- Titre du menu configurable (`Title` dans `config.ini`).
- Option `ConsoleKey` pour que le script tape l'exec dans la console.
- Fenêtre de sauvegarde : la liste des catégories propose toutes les catégories existantes de la map.
- Fenêtre de gestion (F11) : déplacer des stuffs entre catégories, renommer, modifier l'info, supprimer, verrouiller.
- Supprimer une catégorie ne supprime plus ses stuffs : ils sont déplacés dans « Non classés ».
- Cadenas (F5) sur les catégories et les stuffs : un élément verrouillé ne peut pas être supprimé depuis le menu. « Utilitaires » est verrouillée par défaut.

## v2.0.0

- Menu navigable en overlay (Map > Catégorie > Stuff) avec un fichier `.txt` par map.
- Détection automatique de la map en cours (via `console.log`, option `-condebug`).
- Recherche rapide (Tab), favoris (F2), récents, relance du dernier stuff (F8).
- Info du stuff affichée dans l'overlay et dans le chat au lancement.
- Sauvegarde d'un repère depuis le jeu (F9) : map, type, catégorie, nom, info chat.
- Ajout et suppression de stuffs et de catégories depuis le menu (F4 / F3), avec copie de sécurité.
- Rappel des raccourcis adapté à l'écran affiché.
- Réglages d'apparence (F10) : police, taille, position, opacité, couleur de fond.
- Utilitaires communs : bots (placer, accroupir, immobiliser…), God mode, noclip, kit d'armes.
