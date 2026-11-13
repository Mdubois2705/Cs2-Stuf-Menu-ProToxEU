# Changelog

## v2.8.2

- cs2_practice.cfg est copié automatiquement dans le dossier cfg de CS2 au lancement s'il n'y est pas encore (un fichier existant n'est jamais écrasé).

## v2.8.1

- Premier lancement : le dossier cfg de CS2 est détecté automatiquement (Steam et ses bibliothèques). S'il n'est pas trouvé, une fenêtre permet de le choisir, et le chemin est enregistré dans config.ini. Plus d'erreur « Chemin CfgPath invalide » sur un autre PC.

## v2.8.0

- Raccourci Ctrl+P (refaire la capture dans le menu) supprimé. Un bouton « Refaire la capture (en jeu) » est ajouté dans la fenêtre de modification d'un stuff (F11) : il masque les fenêtres, laisse 3 secondes pour viser, puis capture le centre du jeu.

## v2.7.7

- Capture : option « À côté du menu » retirée (coin supérieur droit ou libre).
- Capture : coins arrondis de 3 px par défaut (réglable), et liseré dessiné par-dessus l'image au lieu d'en dessous.

## v2.7.6

- Capture d'écran : position de base dans le coin supérieur droit de l'écran. Placements possibles : coin supérieur droit, à côté du menu, ou libre (X / Y).

## v2.7.5

- Coordonnées : placement réglable dans F10, onglet « Coordonnées » (coin inférieur gauche par défaut, ou position libre X / Y).

## v2.7.4

- Coordonnées en temps réel : coins arrondis et liseré liés aux réglages du menu (épaisseur, couleur, arrondi).
- La fenêtre de vérification de l'installation se ferme directement quand tout est bon.

## v2.7.3

- Le bouton « Vérifier l'installation » passe de F1 aux réglages F10 (visible sous tous les onglets).

## v2.7.2

- La vérification de l'installation ne se relance plus après un changement de profil ou une mise à jour : elle n'a lieu qu'au lancement du script.
- Vérification : la map est lue dans la même réponse du jeu que le test d'envoi, avec plusieurs essais avant d'afficher un avertissement.

## v2.7.1

- Les coordonnées en temps réel n'ont plus de raccourci clavier : elles s'activent dans F10, onglet « Coordonnées ». Le choix est enregistré et appliqué à chaque lancement du script.

## v2.7.0

- Export de fichier .stuffpack avec les captures d'écran (case « Inclure les captures », JPEG en base64). L'import les restaure avec les stuffs et montre un aperçu de l'image.
- Le code copié n'inclut pas les captures (trop lourd) : un message prévient dans les deux cas.

## v2.6.1

- Réglages (F10) : nouvel onglet « Captures » (activer, zone capturée, taille affichée, placement automatique ou libre avec position X/Y, aperçu en direct). Le liseré de la capture suit celui du menu.

## v2.6.0

- Captures d'écran des stuffs : 100 x 100 px au centre du jeu, prises à l'ouverture de la fenêtre de sauvegarde (F9 / F4), jointes au stuff si coché.
- Le menu affiche la capture du stuff sélectionné à côté de lui. Ctrl+P (menu ouvert) refait la capture.
- La fenêtre de modification (F11) montre la capture et permet de la supprimer. Elle suit le stuff s'il est renommé ou déplacé.
- Réglages `config.ini` : Shot, ShotKey, ShotSize, ShotZoom.

## v2.5.1

- Import : aperçu détaillé avant d'importer (commandes, info, comparaison avec ton stuff existant) et résumé (nouveaux, doublons, identiques, refusés, cochés).

## v2.5.0

- Réglages (F10) : épaisseur, couleur (liste ou code hexadécimal) du liseré du menu et arrondi des coins.

## v2.4.5

- Retrait des cadres colorés autour du nom de la map et de la ligne sélectionnée (retour au rendu 2.4.2).

## v2.4.4

- Correction des cadres : texte de la ligne sélectionnée visible, cadre du nom de la map complet.

## v2.4.3

- Cadre arrondi coloré autour du nom de la map et de la ligne sélectionnée, de la couleur du nom de la map du thème.

## v2.4.2

- Coins arrondis du menu et de la ligne sélectionnée, liseré coloré qui suit le thème (`Corner` et `Border` dans `config.ini`).

## v2.4.1

- La ligne sélectionnée du menu est mise en valeur par une barre de fond (couleur propre à chaque thème).

## v2.4.0

- Six thèmes de couleurs (Graphite et Or, Encre et Glace, Forêt et Sauge, Bordeaux et Crème, Ardoise et Lavande, Papier et Encre) dans les réglages F10.
- Liste de polices élargie, limitée aux polices installées.

## v2.3.0

- Sauvegarde automatique quotidienne des maps (14 jours) et restauration depuis F1.
- Annulation de la suppression d'un stuff : Ctrl+Z dans le menu, bouton dans la gestion (F11).

## v2.2.1

- Vérification de l'installation au lancement, puis test d'envoi de commandes une fois CS2 lancé (option `AutoCheck`).

## v2.2.0

- Les maps vides sont fournies dans maps_default\ ; maps\ (tes stuffs) est exclu de git.
- Profils et partage : plusieurs profils, export (fichier .stuffpack ou code) et import sans écraser (touche F1).
- Correction de la hauteur de téléportation (TpZOffset).
- Modification complète d'un stuff depuis la gestion : type, catégorie, nom, coordonnées, commandes, info (double-clic).
- Coordonnées en temps réel dans le coin inférieur gauche (touche Insert).
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
