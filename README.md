# CS2 Stuff Menu

Menu en overlay, navigable au clavier, pour s'entraîner aux lineups (smokes, flashs, molotovs, spawns…) en **entraînement local** sur Counter-Strike 2.

Le script [AutoHotkey v2](https://www.autohotkey.com/) affiche le menu par-dessus le jeu et envoie les commandes à CS2 via un petit fichier `cfg`. Tes repères sont de simples fichiers texte, un par map.

> Projet de la communauté, sans lien avec Valve. À utiliser **uniquement en local** : ferme le script avant de jouer en matchmaking, sur FACEIT ou sur un serveur avec anti-cheat.

## Fonctionnalités

- Menu à 3 niveaux : **Map > Catégorie > Stuff**, ouvert directement sur la map détectée
- **Recherche rapide**, **favoris**, **récents**, relance du dernier stuff
- Infos du stuff affichées dans l'overlay et dans le **chat** au lancement
- **Sauvegarde d'un repère depuis le jeu** (position et angle capturés automatiquement)
- **Ajout / suppression** de stuffs et de catégories depuis le menu
- Utilitaires : bots (placer, accroupi, immobile…), God mode, noclip, kit d'armes
- **Apparence réglable** : police, taille, position, opacité, couleur de fond

## Prérequis

- Windows et [AutoHotkey v2](https://www.autohotkey.com/)
- Counter-Strike 2
- L'option de lancement Steam `-condebug` (détection de la map et capture de position)

## Installation

1. Clone ou télécharge ce dépôt.
2. Copie `cs2_practice.cfg` dans le dossier cfg de CS2 :
   `...\Counter-Strike Global Offensive\game\csgo\cfg\`
3. Dans Steam, ajoute `-condebug` aux options de lancement de CS2.
4. Lance `stuff_menu.ahk` une première fois : il crée `config.ini` à partir de `config.example.ini`.
5. Ouvre `config.ini` et vérifie `CfgPath` (chemin du fichier `stuff_run.cfg` dans le dossier cfg de CS2). Relance le script.
6. Lance un entraînement local et tape `exec cs2_practice` dans la console **une seule fois** : cela crée la touche qui relie le jeu au menu. Ensuite, le script l'exécute tout seul (voir [Exec automatique](#exec-automatique)).

## Raccourcis

| Touche | Action |
| --- | --- |
| `F7` | Ouvrir / fermer le menu |
| `F8` | Relancer le dernier stuff |
| `F9` | Sauvegarder la position actuelle comme nouveau stuff |
| `F10` | Réglages du menu (police, taille, position, opacité, fond) |
| `F6` | Relancer l'exec du cfg d'entraînement |
| `F11` | Gestion des stuffs et des catégories |
| `F1` | Profils et partage de stuffs (export / import) |
| `Insert` | Afficher / masquer les coordonnées en temps réel |

Dans le menu :

| Touche | Action |
| --- | --- |
| `Haut` / `Bas` | Naviguer |
| `Droite` / `Entrée` | Valider |
| `Gauche` / `Retour arrière` | Retour |
| `Échap` | Fermer |
| `Tab` | Recherche rapide |
| `F2` | Ajouter / retirer des favoris |
| `F4` | Ajouter une catégorie, ou un stuff dans la catégorie courante |
| `F3` | Supprimer (2 appuis pour confirmer). Supprimer une catégorie **garde ses stuffs** : ils vont dans « Non classés » |
| `F5` | Cadenas : verrouiller / déverrouiller la catégorie ou le stuff sélectionné |

Toutes les touches se changent dans `config.ini`. Le script utilise aussi la touche `kp_multiply` (pavé numérique `*`) pour déclencher le cfg, ainsi que `K`, `N`, `L`, `P` dans `cs2_practice.cfg`.

## Gestion des stuffs et des catégories

`F11` ouvre une fenêtre de gestion, au centre de l'écran :

- **Catégories** (à gauche) : créer, renommer, supprimer, verrouiller.
- **Stuffs** (à droite) : renommer, modifier le message du chat, supprimer, verrouiller.
- **Modifier un stuff en entier** : double-clic sur un stuff (ou « Modifier… ») pour changer le type, la catégorie, le nom, le message du chat, les **coordonnées** (setpos / setang) et les autres commandes. Le bouton « Recapturer ma position actuelle » reprend ta position en jeu.
- **Déplacer vers** : choisis une catégorie existante (ou tape un nouveau nom) et clique sur « Déplacer ». Tu peux sélectionner plusieurs stuffs avec `Ctrl` ou `Maj`.
- La liste « Map » permet de choisir la map, ou « Communs (toutes les maps) » pour gérer `maps/_commun.txt`.

**Supprimer une catégorie ne supprime pas ses stuffs** : ils sont déplacés dans la catégorie « Non classés », que tu peux ensuite vider en les déplaçant où tu veux. Les éléments verrouillés (cadenas) ne peuvent être ni supprimés, ni renommés, ni déplacés.

## Coordonnées en temps réel

`Insert` affiche, dans le **coin inférieur gauche** de l'écran, la map, ta position (X, Y, Z) et ton angle de vue (pitch, yaw), mises à jour plusieurs fois par seconde. Le texte suit l'apparence réglée avec `F10`.

Le script demande `getpos` au jeu à intervalle régulier et lit la réponse dans `console.log` (option `-condebug`). Il ne lit pas la mémoire du jeu.

- La fréquence se règle avec `HudInterval` (en ms, 300 par défaut) ; `HudAtStart=1` l'affiche dès le lancement du script.
- Pendant que l'affichage est actif, le script envoie une touche (`kp_multiply`) à chaque mise à jour : **désactive-le avant d'ouvrir la console ou le chat**, sinon le caractère `*` s'y écrit.
- Il se met en pause quand le menu ou une fenêtre du script est ouverte, et quand CS2 n'est pas la fenêtre active.

## Profils et partage

`F1` ouvre la fenêtre **Profils et partage**.

- **Profils** : chaque joueur peut avoir plusieurs profils (par exemple « Principal », « Stuffs de Léo », « Equipe »). Le profil Principal utilise les dossiers `maps\` et `data\` ; les autres sont dans `profiles\<nom>\`. « Activer » recharge le script avec le profil choisi. Chaque profil a ses propres stuffs, favoris, récents et cadenas.
- **Exporter** : coche les stuffs à partager (un seul, plusieurs ou tout), puis « Exporter vers un fichier… » (fichier `.stuffpack`) ou « Copier le code » (texte à coller dans Discord, de préférence dans un bloc de code ; pour beaucoup de stuffs, envoie plutôt le fichier).
- **Importer** : « Importer un fichier… » ou « Importer depuis le presse-papiers ». Une fenêtre liste les stuffs reçus avec leur statut (Nouveau, Doublon, Identique). Tu coches ceux à garder, tu choisis le profil de destination (existant, ou un nom nouveau pour en créer un) et ce qu'il faut faire des doublons : ignorer, garder les deux (le nouveau est renommé) ou remplacer le tien.
- **Rien n'est cassé** : l'import n'ajoute que ce que tu coches, ne supprime jamais de stuff, et copie les fichiers touchés dans `data\backup\` du profil de destination avant d'écrire.
- **Hauteur** : le pack contient le réglage `TpZOffset` de l'exportateur ; à l'import, les coordonnées sont ajustées pour que la hauteur reste correcte avec ton propre réglage.
- **Sécurité** : les stuffs contenant des commandes `quit`, `exec`, `bind`, `unbind`, `unbindall`, `alias`, `connect`, `disconnect`, `rcon`… sont refusés à l'import. Les cadenas et les favoris ne sont pas exportés.

## Cadenas

Un cadenas apparaît à la fin des catégories et des stuffs verrouillés. Un élément verrouillé ne peut pas être supprimé depuis le menu : appuie sur `F5` pour le verrouiller ou le déverrouiller.

- Un **cadenas de catégorie** protège la catégorie ; il porte sur le nom de la catégorie, donc sur toutes les maps qui l'utilisent.
- Une catégorie qui contient un stuff verrouillé ne peut pas être supprimée non plus.
- `Utilitaires` est verrouillée par défaut au premier lancement. Les verrous sont gardés dans `data/locks.txt`.
- Si le cadenas s'affiche comme un carré, remplace la valeur de `LOCK_ICON` en haut de `stuff_menu.ahk` par `"[L]"`.
- Le cadenas ne protège que dans le menu : un fichier `maps/*.txt` édité à la main n'est pas verrouillé.

## Exec automatique

Les réglages d'entraînement (`cs2_practice.cfg` : argent, munitions infinies, `sv_cheats`, touches K / N / L / P…) se remettent à zéro à chaque chargement de map. Le script les relance pour toi :

- à l'ouverture du menu (`F7`), **une fois par map détectée** (la détection demande `-condebug`) ;
- à la demande avec `F6`, par exemple après un redémarrage de la même map.

Chaque commande du menu envoie aussi `sv_cheats 1` d'abord, donc les stuffs, le God mode et les bots marchent même si l'exec n'a pas tourné.

Réglages dans `config.ini` :

| Clé | Rôle |
| --- | --- |
| `AutoExec` | `1` = exec automatique, `0` = désactivé |
| `PracticeCfg` | Nom du cfg à exécuter (par défaut `cs2_practice`) |
| `ExecKey` | Touche pour relancer l'exec (par défaut `F6`) |
| `ConsoleKey` | Optionnel : touche de la console (ex. `{sc029}`, la touche à gauche du 1) |

Avec `ConsoleKey` vide, l'exec passe par la touche liée au menu, créée par ton premier `exec cs2_practice` manuel. Avec `ConsoleKey` renseignée, le script ouvre la console, tape la commande et la referme lui-même, sans exec manuel. Utilise-la seulement si la touche est la bonne : sinon les lettres tapées arrivent dans le jeu.

## Ajouter des stuffs

**Depuis le jeu (F9)** : place-toi au bon endroit, vise, appuie sur `F9`, puis remplis la map, le type, la catégorie, le nom et le message du chat.

Dans la fenêtre, la liste **Catégorie** propose toutes les catégories déjà créées pour la map (y compris celles créées avec `F4`). Choisis-en une, ou tape un nouveau nom : sans catégorie existante du même nom, il est rangé sous « Type - Nom » (par exemple `Smoke - Site A`).

**À la main** : édite `maps/de_<map>.txt`, une ligne par stuff :

```
Catégorie | Nom affiché | commande(s) console | info affichée dans le chat (optionnel)
```

Exemple :

```
Smoke - Site A | Smoke CT depuis T spawn | setpos -456 -2288 -163; setang -39 57; give weapon_smokegrenade | Jump throw - clic gauche
```

- Une catégorie est le premier champ des lignes. Une catégorie vide se déclare avec `@cat | Nom`.
- Évite le caractère `;` dans l'info du chat (il est remplacé par une virgule).
- Les lignes commençant par `#` sont ignorées. Voir `maps/_exemple.txt`.
- `maps/_commun.txt` s'affiche dans toutes les maps.

## Structure

```
stuff_menu.ahk        script principal
cs2_practice.cfg      réglages d'entraînement (à copier dans le cfg de CS2)
config.example.ini    modèle de configuration (copié en config.ini)
maps/                 un fichier .txt par map + _commun.txt
data/                 favoris, récents, copies de sécurité (non versionné)
```

## Vérification de l'installation

Au lancement, le script vérifie ce qui peut l'être sans CS2 : dossier cfg, `cs2_practice.cfg`, tes maps, droits d'écriture, présence de `console.log`. Une petite fenêtre affiche le résultat avec ✔, ⚠ ou ✘ et la solution de chaque problème.

Lance ensuite CS2 et une map locale : dès que le jeu est au premier plan, le script teste l'envoi d'une commande (via `console.log`), les cheats et la détection de la map. S'il n'y a aucun problème, la fenêtre se ferme toute seule.

- Pour relancer la vérification : bouton « Vérifier l'installation » dans la fenêtre `F1`.
- Pour la désactiver : `AutoCheck=0` dans `config.ini`.
- Le test d'envoi appuie sur la touche `*` du pavé numérique dans le jeu : ne laisse pas la console ni le chat ouverts pendant la vérification.

## Mise à jour

- **Automatique** : au lancement, le script regarde s'il existe une version plus récente sur GitHub. Si oui, il te propose de l'installer ; accepte et il redémarre tout seul. Pour désactiver la vérification : `AutoUpdate=0` dans `config.ini`.
- **Sans le script** : ferme le script, puis double-clique sur `update.bat`. Il télécharge la dernière version et remplace les fichiers du programme.
- **Avec Git** : `git pull` dans le dossier.

Dans tous les cas, `maps\`, `data\`, `profiles\` et `config.ini` ne sont jamais modifiés : tes stuffs, favoris, profils et réglages restent en place. L'ancien script est copié dans `data\backup\stuff_menu.ahk.bak`. Si `cs2_practice.cfg` change (voir le CHANGELOG), recopie-le dans le dossier cfg de CS2.

## Dépannage

- **Le menu n'apparaît pas** : vérifie que le script tourne et que CS2 est en mode fenêtré (plein écran fenêtré). Tu peux aussi placer le menu sur un autre écran avec `F10` (réglages de position).
- **La map n'est pas détectée** : vérifie `-condebug`, ou règle `AutoDetectMap=0` dans `config.ini`.
- **TP, give, God mode ou bot ne marchent plus** : ces commandes exigent `sv_cheats 1`. Le script l'envoie avant chaque commande ; si ça ne marche toujours pas, vérifie que tu es bien dans une partie locale (pas en matchmaking). Test rapide : tape `setpos 0 0 0` dans la console.
- **Rien ne se passe au choix d'un stuff** : vérifie `CfgPath` et que tu as lancé `exec cs2_practice` au moins une fois à la main (il relie la touche `kp_multiply` au fichier généré).
- **L'exec automatique ne se déclenche pas** : vérifie `-condebug` (détection de map) ou appuie sur `F6`.
- **Suppression par erreur** : récupère le fichier dans `data/backup/`.

## Contribuer

Les lineups des maps sont dans `maps/` : les pull requests avec de nouveaux repères sont les bienvenues (une ligne par stuff, nom clair, info de lancer dans le 4e champ).

## Licence

[MIT](LICENSE)

## Où sont mes stuffs ?

Le dépôt ne contient aucun stuff : il fournit des maps vides dans `maps_default\`. Au premier lancement, le script les copie dans `maps\`, ton dossier personnel. Le dossier `maps\` (comme `data\` et `profiles\`) est exclu de git : tes stuffs ne sont jamais envoyés sur GitHub, même avec `git add .`, et une mise à jour du script ne les écrase pas.
