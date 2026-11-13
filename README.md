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
- **Apparence réglable** : thèmes, police, taille, position, opacité, couleur de fond, liseré et coins arrondis
- **Captures d'écran** des stuffs, **coordonnées en temps réel**, **profils** et **partage** de stuffs (export / import avec aperçu)

## Prérequis

- Windows et [AutoHotkey v2](https://www.autohotkey.com/)
- Counter-Strike 2
- L'option de lancement Steam `-condebug` (détection de la map et capture de position)

## Installation

1. Installe [AutoHotkey v2](https://www.autohotkey.com/).
2. Télécharge ce dépôt (bouton vert **Code > Download ZIP**) et extrais-le où tu veux, ou clone-le.
3. Dans Steam, clic droit sur Counter-Strike 2 > **Propriétés** > **Options de lancement**, et ajoute `-condebug`.
4. Double-clique sur `stuff_menu.ahk`. Au premier lancement, **tout se configure tout seul** :
   - `config.ini` est créé à partir de `config.example.ini` ;
   - le dossier cfg de CS2 est trouvé automatiquement (Steam et ses bibliothèques). S'il n'est pas trouvé, une fenêtre te demande de le choisir : `...\Counter-Strike Global Offensive\game\csgo\cfg` ;
   - `cs2_practice.cfg` est copié dans ce dossier cfg (un fichier existant n'est jamais écrasé).
5. Lance CS2 et une **map d'entraînement locale**, ouvre la console et tape `exec cs2_practice` **une seule fois** : cela crée la touche qui relie le jeu au menu. Ensuite, le script l'exécute tout seul (voir [Exec automatique](#exec-automatique)).
6. Appuie sur `F1` en jeu pour ouvrir le menu. Une fenêtre de vérification contrôle l'installation au lancement du script et se ferme toute seule si tout est bon.

Le menu est vide au départ : sauvegarde tes stuffs avec « Sauvegarder la position actuelle » (voir plus bas) ou importe ceux d'un ami avec « Profils et partage de stuffs ».

## Raccourcis

Une seule touche en jeu : **`F1`** ouvre le **menu principal**. Tout le reste s'y trouve (navigation aux flèches, `Entrée` pour choisir, `Échap` pour fermer) :

| Entrée du menu | Action |
| --- | --- |
| Stuffs (maps et catégories) | Le menu des stuffs : Map > Catégorie > Stuff, ouvert sur la map détectée |
| Utilitaires | Bots (placer, accroupi, immobile…), God mode, noclip, kit d'armes, kill smokes… (catégorie `Utilitaires` de `maps\_commun.txt`) |
| Relancer le dernier stuff | Relance le dernier stuff utilisé |
| Sauvegarder la position actuelle | Enregistre ta position comme nouveau stuff |
| Gérer les stuffs et les catégories | Fenêtre de gestion (déplacer, renommer, supprimer, modifier) |
| Profils et partage de stuffs | Profils, export et import |
| Réglages du menu | Thème, police, liseré, captures, coordonnées |
| Relancer l'exec de cs2_practice | Relance le cfg d'entraînement |
| Vérifier l'installation | Contrôle de l'installation |

Dans le menu des stuffs :

| Touche | Action |
| --- | --- |
| `Haut` / `Bas` | Naviguer |
| `Droite` / `Entrée` | Valider |
| `Gauche` / `Retour arrière` | Retour (de la liste des maps, retour au menu principal) |
| `Échap` | Fermer |
| `Tab` | Recherche rapide |
| `F2` | Ajouter / retirer des favoris |
| `F3` | Cadenas : verrouiller / déverrouiller la catégorie ou le stuff sélectionné |
| `F4` | Créer un nouveau stuff (fenêtre de sauvegarde, catégorie courante pré-remplie) |
| `Ctrl+Z` | Annuler la dernière suppression de stuff |

La suppression de stuffs et de catégories se fait depuis la fenêtre de gestion. Les touches se changent dans `config.ini` (`MenuKey`, `FavKey`, `LockKey`, `AddKey`). Le script utilise aussi la touche `kp_multiply` (pavé numérique `*`) pour déclencher le cfg, ainsi que `K`, `N`, `L`, `P` dans `cs2_practice.cfg`.

## Gestion des stuffs et des catégories

L'entrée « Gérer les stuffs et les catégories » du menu ouvre une fenêtre de gestion, au centre de l'écran :

- **Catégories** (à gauche) : créer, renommer, supprimer, verrouiller.
- **Stuffs** (à droite) : renommer, modifier le message du chat, supprimer, verrouiller.
- **Modifier un stuff en entier** : double-clic sur un stuff (ou « Modifier… ») pour changer le type, la catégorie, le nom, le message du chat, les **coordonnées** (setpos / setang) et les autres commandes. Le bouton « Recapturer ma position actuelle » reprend ta position en jeu.
- **Déplacer vers** : choisis une catégorie existante (ou tape un nouveau nom) et clique sur « Déplacer ». Tu peux sélectionner plusieurs stuffs avec `Ctrl` ou `Maj`.
- La liste « Map » permet de choisir la map, ou « Communs (toutes les maps) » pour gérer `maps/_commun.txt`.

**Supprimer une catégorie ne supprime pas ses stuffs** : ils sont déplacés dans la catégorie « Non classés », que tu peux ensuite vider en les déplaçant où tu veux. Les éléments verrouillés (cadenas) ne peuvent être ni supprimés, ni renommés, ni déplacés.

## Coordonnées en temps réel

L'affichage s'active dans « Réglages du menu », onglet **Coordonnées** (pas de raccourci clavier). Une fois activé et enregistré, il reste actif à chaque lancement du script, jusqu'à ce que tu le désactives. Il se place par défaut dans le **coin inférieur gauche** de l'écran, ou où tu veux (position X / Y dans le même onglet). Il affiche la map, ta position (X, Y, Z) et ton angle de vue (pitch, yaw), mises à jour plusieurs fois par seconde. Le texte suit l'apparence réglée avec `F10`.

Le script demande `getpos` au jeu à intervalle régulier et lit la réponse dans `console.log` (option `-condebug`). Il ne lit pas la mémoire du jeu.

- La fréquence se règle avec `HudInterval` (en ms, 300 par défaut) . `HudAtStart` (0 ou 1) est géré par la case des réglages.
- Pendant que l'affichage est actif, le script envoie une touche (`kp_slash`, le `/` du pavé numérique) à chaque mise à jour, avec son propre fichier `hud_pos.cfg` : il n'utilise pas la touche ni le fichier des stuffs et fait une pause de 2 secondes après chaque stuff lancé. **Désactive-le quand même avant d'ouvrir la console ou le chat**, sinon le caractère `/` s'y écrit.
- Il se met en pause quand le menu ou une fenêtre du script est ouverte, et quand CS2 n'est pas la fenêtre active.

## Profils et partage

L'entrée « Profils et partage de stuffs » du menu ouvre la fenêtre **Profils et partage**.

- **Profils** : chaque joueur peut avoir plusieurs profils (par exemple « Principal », « Stuffs de Léo », « Equipe »). Le profil Principal utilise les dossiers `maps\` et `data\` ; les autres sont dans `profiles\<nom>\`. « Activer » recharge le script avec le profil choisi. Chaque profil a ses propres stuffs, favoris, récents et cadenas.
- **Exporter** : coche les stuffs à partager (un seul, plusieurs ou tout), puis « Exporter vers un fichier… » (fichier `.stuffpack`) ou « Copier le code » (texte à coller dans Discord, de préférence dans un bloc de code ; pour beaucoup de stuffs, envoie plutôt le fichier).
- **Importer** : « Importer un fichier… » ou « Importer depuis le presse-papiers ». Une fenêtre liste les stuffs reçus avec leur statut (Nouveau, Doublon, Identique). Tu coches ceux à garder, tu choisis le profil de destination (existant, ou un nom nouveau pour en créer un) et ce qu'il faut faire des doublons : ignorer, garder les deux (le nouveau est renommé) ou remplacer le tien.
- **Rien n'est cassé** : l'import n'ajoute que ce que tu coches, ne supprime jamais de stuff, et copie les fichiers touchés dans `data\backup\` du profil de destination avant d'écrire.
- **Hauteur** : le pack contient le réglage `TpZOffset` de l'exportateur ; à l'import, les coordonnées sont ajustées pour que la hauteur reste correcte avec ton propre réglage.
- **Sécurité** : les stuffs contenant des commandes `quit`, `exec`, `bind`, `unbind`, `unbindall`, `alias`, `connect`, `disconnect`, `rcon`… sont refusés à l'import. Les cadenas et les favoris ne sont pas exportés.

## Cadenas

Un cadenas apparaît à la fin des catégories et des stuffs verrouillés. Un élément verrouillé ne peut pas être supprimé depuis le menu : appuie sur `F3` pour le verrouiller ou le déverrouiller.

- Un **cadenas de catégorie** protège la catégorie ; il porte sur le nom de la catégorie, donc sur toutes les maps qui l'utilisent.
- Une catégorie qui contient un stuff verrouillé ne peut pas être supprimée non plus.
- `Utilitaires` est verrouillée par défaut au premier lancement. Les verrous sont gardés dans `data/locks.txt`.
- Si le cadenas s'affiche comme un carré, remplace la valeur de `LOCK_ICON` en haut de `stuff_menu.ahk` par `"[L]"`.
- Le cadenas ne protège que dans le menu : un fichier `maps/*.txt` édité à la main n'est pas verrouillé.

## Exec automatique

Les réglages d'entraînement (`cs2_practice.cfg` : argent, munitions infinies, `sv_cheats`, touches K / N / L / P…) se remettent à zéro à chaque chargement de map. Le script les relance pour toi :

- à l'ouverture du menu des stuffs (entrée « Stuffs »), **une fois par map détectée** (la détection demande `-condebug`) ;
- à la demande avec l'entrée « Relancer l'exec » du menu, par exemple après un redémarrage de la même map.

Chaque commande du menu envoie aussi `sv_cheats 1` d'abord, donc les stuffs, le God mode et les bots marchent même si l'exec n'a pas tourné.

Réglages dans `config.ini` :

| Clé | Rôle |
| --- | --- |
| `AutoExec` | `1` = exec automatique, `0` = désactivé |
| `PracticeCfg` | Nom du cfg à exécuter (par défaut `cs2_practice`) |
| `ConsoleKey` | Optionnel : touche de la console (ex. `{sc029}`, la touche à gauche du 1) |

Avec `ConsoleKey` vide, l'exec passe par la touche liée au menu, créée par ton premier `exec cs2_practice` manuel. Avec `ConsoleKey` renseignée, le script ouvre la console, tape la commande et la referme lui-même, sans exec manuel. Utilise-la seulement si la touche est la bonne : sinon les lettres tapées arrivent dans le jeu.

## Captures d'écran des stuffs

Quand tu sauvegardes un stuff (entrée « Sauvegarder la position actuelle » du menu, ou `F4` dans le menu des stuffs), le script prend une petite capture de 100 x 100 px au centre du jeu (autour du réticule) et la propose dans la fenêtre. Si la case est cochée, elle est liée au stuff. Dans le menu, la capture du stuff sélectionné s'affiche dans le coin supérieur droit de l'écran (placement réglable). Pour la refaire : `F11`, modifier le stuff, bouton « Refaire la capture (en jeu) » (place-toi au point du stuff : les fenêtres se masquent et la capture se fait 3 secondes plus tard). Les captures sont dans `data\shots\`. Elles peuvent être jointes à un export vers un fichier `.stuffpack` (case « Inclure les captures » dans F1) : l'import les restaure. Le code copié ne les contient pas (trop lourd).

Tout se règle dans « Réglages du menu », onglet « Captures » : activer, zone capturée, taille affichée, placement (coin supérieur droit par défaut, ou libre avec position X/Y), arrondi des coins (3 px par défaut). Le liseré de la capture reprend celui du menu et se dessine par-dessus l'image. Équivalents dans `config.ini` : `Shot`, `ShotSize`, `ShotZoom`, `ShotPos`, `ShotCorner`, `ShotX`, `ShotY`. Le jeu doit être en fenêtré ou en plein écran fenêtré.

## Ajouter des stuffs

**Depuis le jeu** : place-toi au bon endroit, vise, ouvre le menu (`F1`) et choisis « Sauvegarder la position actuelle », puis remplis la map, le type, la catégorie, le nom et le message du chat.

Dans la fenêtre, la liste **Catégorie** propose toutes les catégories déjà créées pour la map (y compris celles créées dans la fenêtre de gestion). Choisis-en une, ou tape un nouveau nom : sans catégorie existante du même nom, il est rangé sous « Type - Nom » (par exemple `Smoke - Site A`).

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

## Thèmes et police

« Réglages du menu » ouvre les réglages. La liste **Thème** applique en un clic une palette complète (fond, titre, nom de map, textes) :

| Thème | Ambiance |
| --- | --- |
| Graphite et Or | anthracite, accents or doux |
| Encre et Glace | bleu nuit, titre bleu glacier |
| Forêt et Sauge | vert très sombre, titre sauge |
| Bordeaux et Crème | bordeaux presque noir, titre rose ancien |
| Ardoise et Lavande | ardoise bleutée, titre lavande |
| Papier et Encre | fond crème clair, titre bleu acier |

La ligne sélectionnée du menu est mise en valeur par une barre de fond, dont la couleur est choisie par le thème (ou calculée à partir du fond en mode « Personnalisé »).

Le menu a des coins arrondis et un fin liseré dont la couleur suit le thème. Dans les réglages, tu peux régler l'épaisseur et la couleur du liseré (liste ou code hexadécimal) ainsi que l'arrondi des coins. Réglage dans `config.ini`, section `[Overlay]` : `Corner=14` (rayon des coins, `0` = coins carrés) et `Border=2` (épaisseur du liseré, `0` = aucun).

Si tu modifies ensuite le fond (préréglage ou curseurs), le menu repasse en « Personnalisé » avec des couleurs de texte automatiques. La liste **Police** ne propose que les polices installées sur ton PC (Segoe UI, Bahnschrift, Cascadia, Consolas, Calibri, Georgia…). Le thème est enregistré dans `config.ini` (`Theme=`).

## Sauvegardes et annulation

- **Sauvegarde automatique** : une fois par jour, au lancement du script, tes maps (de chaque profil) sont copiées dans `data\backup\auto\AAAA-MM-JJ\`. Les 14 dernières sont conservées (`BackupKeep` dans `config.ini`, `AutoBackup=0` pour désactiver). Pour restaurer : `F1` > « Restaurer une sauvegarde… ». Ton état actuel est sauvegardé juste avant dans un dossier `avant-restauration-...`.
- **Annuler une suppression** : `Ctrl+Z` dans le menu, ou le bouton « Annuler la suppression » (et `Ctrl+Z`) dans la fenêtre de gestion. Le dernier stuff supprimé est remis dans sa catégorie ; les 50 derniers sont mémorisés dans `data\deleted.txt`. Le favori et le cadenas du stuff ne sont pas restaurés. La suppression d'une catégorie ne détruit pas ses stuffs (ils vont dans « Non classés »), donc elle n'a pas besoin d'être annulée.

## Vérification de l'installation

Au lancement, le script vérifie ce qui peut l'être sans CS2 : dossier cfg, `cs2_practice.cfg`, tes maps, droits d'écriture, présence de `console.log`. Une petite fenêtre affiche le résultat avec ✔, ⚠ ou ✘ et la solution de chaque problème.

Lance ensuite CS2 et une map locale : dès que le jeu est au premier plan, le script teste l'envoi d'une commande (via `console.log`), les cheats et la détection de la map. S'il n'y a aucun problème, la fenêtre se ferme toute seule.

- Pour relancer la vérification : bouton « Vérifier l'installation » dans les réglages du menu (visible sous tous les onglets).
- Pour la désactiver : `AutoCheck=0` dans `config.ini`.
- Le test d'envoi appuie sur la touche `*` du pavé numérique dans le jeu : ne laisse pas la console ni le chat ouverts pendant la vérification.

## Mise à jour

- **Automatique** : au lancement, le script regarde s'il existe une version plus récente sur GitHub. Si oui, il te propose de l'installer ; accepte et il redémarre tout seul. Pour désactiver la vérification : `AutoUpdate=0` dans `config.ini`.
- **Sans le script** : ferme le script, puis double-clique sur `update.bat`. Il télécharge la dernière version et remplace les fichiers du programme.
- **Avec Git** : `git pull` dans le dossier.

Dans tous les cas, `maps\`, `data\`, `profiles\` et `config.ini` ne sont jamais modifiés : tes stuffs, favoris, profils et réglages restent en place. L'ancien script est copié dans `data\backup\stuff_menu.ahk.bak`. Si `cs2_practice.cfg` change (voir le CHANGELOG), recopie-le dans le dossier cfg de CS2.

## Dépannage

- **Le menu n'apparaît pas** : vérifie que le script tourne et que CS2 est en mode fenêtré (plein écran fenêtré). Tu peux aussi placer le menu sur un autre écran dans les réglages du menu (réglages de position).
- **La map n'est pas détectée** : vérifie `-condebug`, ou règle `AutoDetectMap=0` dans `config.ini`.
- **TP, give, God mode ou bot ne marchent plus** : ces commandes exigent `sv_cheats 1`. Le script l'envoie avant chaque commande ; si ça ne marche toujours pas, vérifie que tu es bien dans une partie locale (pas en matchmaking). Test rapide : tape `setpos 0 0 0` dans la console.
- **Rien ne se passe au choix d'un stuff** : vérifie `CfgPath` et que tu as lancé `exec cs2_practice` au moins une fois à la main (il relie la touche `kp_multiply` au fichier généré).
- **L'exec automatique ne se déclenche pas** : vérifie `-condebug` (détection de map) ou utilise l'entrée « Relancer l'exec » du menu.
- **Suppression par erreur** : récupère le fichier dans `data/backup/`.

## Contribuer

Les lineups des maps sont dans `maps/` : les pull requests avec de nouveaux repères sont les bienvenues (une ligne par stuff, nom clair, info de lancer dans le 4e champ).

## Licence

[MIT](LICENSE)

## Où sont mes stuffs ?

Le dépôt ne contient aucun stuff : il fournit des maps vides dans `maps_default\`. Au premier lancement, le script les copie dans `maps\`, ton dossier personnel. Le dossier `maps\` (comme `data\` et `profiles\`) est exclu de git : tes stuffs ne sont jamais envoyés sur GitHub, même avec `git add .`, et une mise à jour du script ne les écrase pas.
