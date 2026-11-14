# CS2 Stuff Menu

Menu en overlay, navigable au clavier, pour s'entraîner aux lineups (smokes, flashs, molotovs, spawns…) en **entraînement local** sur Counter-Strike 2.

Le script [AutoHotkey v2](https://www.autohotkey.com/) affiche le menu par-dessus le jeu et envoie les commandes à CS2 par une **connexion directe** à sa console (option de lancement `-netconport`), sans aucune touche appuyée à ta place. Tes repères sont de simples fichiers texte, un par map.

> Projet de la communauté, sans lien avec Valve. À utiliser **uniquement en local**. Le menu lance CS2 avec `-insecure`, qui **désactive VAC** : dans cette session, pas de matchmaking, de Premier ni de FACEIT. Pour jouer en ligne, ferme le jeu et lance-le normalement depuis Steam, sans passer par le menu.

## Fonctionnalités

- Menu à 3 niveaux : **Map > Catégorie > Stuff**, ouvert directement sur la map détectée
- **Recherche rapide** (nom, catégorie, info et tags), **favoris**, **récents**, **tags**, relance du dernier stuff
- Infos du stuff affichées dans l'overlay et dans le **chat** au lancement
- **Sauvegarde d'un repère depuis le jeu** (position et angle capturés automatiquement)
- **Ajout / suppression** de stuffs et de catégories depuis le menu
- Utilitaires : bots (placer, accroupi, immobile…), God mode, noclip, kit d'armes
- **Apparence réglable** : thèmes, police, taille, position, opacité, couleur de fond, liseré et coins arrondis
- **Captures d'écran** des stuffs, **coordonnées en temps réel**, **profils** et **partage** de stuffs (export / import avec aperçu)

## Prérequis

- Windows, [Steam](https://store.steampowered.com/) et [AutoHotkey v2](https://www.autohotkey.com/)
- Counter-Strike 2
- L'option de lancement Steam **`-condebug`** (obligatoire : le menu lit `console.log` pour détecter la map et ta position). Aucune autre option de lancement n'est à ajouter : `-netconport` et `-insecure` sont ajoutées par le menu lui-même.

## Installation

1. Installe [AutoHotkey v2](https://www.autohotkey.com/).
2. Télécharge ce dépôt (bouton vert **Code > Download ZIP**) et extrais-le où tu veux, ou clone-le.
3. Dans Steam, clic droit sur Counter-Strike 2 > **Propriétés** > **Options de lancement**, et ajoute **`-condebug`** (une seule fois). Garde tes autres options si tu en as.
4. **Ferme CS2**, puis double-clique sur `stuff_menu.ahk`. Au premier lancement, **tout se configure tout seul** :
   - `config.ini` est créé à partir de `config.example.ini` ;
   - le dossier cfg de CS2 est trouvé automatiquement (Steam et ses bibliothèques). S'il n'est pas trouvé, une fenêtre te demande de le choisir : `...\Counter-Strike Global Offensive\game\csgo\cfg` ;
   - `cs2_practice.cfg` est copié dans ce dossier cfg (un fichier existant n'est jamais écrasé) ;
   - une fenêtre t'explique que le menu va lancer CS2 avec `-netconport 2121 -insecure`, puis il **démarre le jeu lui-même** (par Steam, sans modifier tes options de lancement).
5. Attends que CS2 soit chargé et lance une **map d'entraînement locale**. Une petite infobulle « Connexion directe à CS2 active » confirme que tout est prêt.
6. Appuie sur `F1` en jeu pour ouvrir le menu. Une fenêtre de vérification contrôle l'installation et se ferme toute seule si tout est bon.

**Règle à retenir : lance toujours le script (`stuff_menu.ahk`) avant CS2.** C'est lui qui démarre le jeu avec la connexion directe, le seul moyen d'envoyer les commandes. Si CS2 est déjà ouvert quand tu lances le script, il te propose de le fermer et de le relancer avec les bonnes options.

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
| `F4` | Créer un nouveau stuff (fenêtre de sauvegarde, catégorie courante pré-remplie dans le menu des stuffs). Fonctionne aussi depuis le menu principal |
| `Ctrl+Z` | Annuler la dernière suppression de stuff |

La suppression de stuffs et de catégories se fait depuis la fenêtre de gestion. Les touches du menu se changent dans `config.ini` (`MenuKey`, `FavKey`, `LockKey`, `AddKey`).

## Connexion directe à CS2

Le menu envoie toutes ses commandes (téléportation, give, bots, god mode, coordonnées…) par un port TCP local que CS2 ouvre avec les options `-netconport 2121 -insecure`. Aucun fichier `cfg` n'est écrit, aucune touche n'est appuyée à ta place : pas de collision avec tes touches, Discord ou un logiciel de clavier.

- **Le menu lance CS2 pour toi** (`steam.exe -applaunch 730 -condebug -netconport 2121 -insecure`). Tes options de lancement enregistrées dans Steam ne sont pas modifiées.
- **Sans cette connexion, le menu ne peut pas envoyer de commandes.** S'il n'arrive pas à se connecter, une infobulle te le dit. Ferme CS2 et relance le menu.
- **`-insecure` désactive VAC** : une copie de CS2 lancée ainsi ne peut pas rejoindre de serveur protégé (matchmaking, Premier, FACEIT…). Pour jouer en ligne, ferme le jeu et relance-le normalement depuis Steam.
- Le port est ouvert sur le réseau local : garde le pare-feu Windows actif et n'utilise le menu que sur un réseau de confiance.
- Le port se règle avec `NetconPort` dans `config.ini` (2121 par défaut) ; les options données au jeu avec `LaunchArgs` (`{port}` est remplacé par `NetconPort`). Si le port est déjà pris par un autre programme, change `NetconPort`.
- Si le lancement par le menu ne fonctionne pas chez toi, ajoute `-netconport 2121 -insecure` dans les options de lancement de CS2 sur Steam, à côté de `-condebug`. Le menu se connecte alors au jeu lancé de cette façon.

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
- Les coordonnées sont demandées par la connexion directe, sans aucune touche : elles ne gênent ni la console ni le chat. Le script fait une pause de 2 secondes après chaque stuff lancé.
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

L'exec est envoyé à CS2 par la connexion directe : tu n'as rien à taper dans la console.

## Captures d'écran des stuffs

Quand tu sauvegardes un stuff (entrée « Sauvegarder la position actuelle » du menu, ou `F4` dans le menu des stuffs), le script prend une petite capture de 100 x 100 px au centre du jeu (autour du réticule) et la propose dans la fenêtre. Si la case est cochée, elle est liée au stuff. Dans le menu, la capture du stuff sélectionné s'affiche dans le coin supérieur droit de l'écran (placement réglable). Pour la refaire : `F11`, modifier le stuff, bouton « Refaire la capture (en jeu) » (place-toi au point du stuff : les fenêtres se masquent et la capture se fait 3 secondes plus tard). Les captures sont dans `data\shots\`. Elles peuvent être jointes à un export vers un fichier `.stuffpack` (case « Inclure les captures » dans F1) : l'import les restaure. Le code copié ne les contient pas (trop lourd).

Tout se règle dans « Réglages du menu », onglet « Captures » : activer, zone capturée, taille affichée, placement (coin supérieur droit par défaut, ou libre avec position X/Y), arrondi des coins (3 px par défaut). Le liseré de la capture reprend celui du menu et se dessine par-dessus l'image. Équivalents dans `config.ini` : `Shot`, `ShotSize`, `ShotZoom`, `ShotPos`, `ShotCorner`, `ShotX`, `ShotY`. Le jeu doit être en fenêtré ou en plein écran fenêtré.

## Ajouter des stuffs

**Depuis le jeu** : place-toi au bon endroit, vise, ouvre le menu (`F1`) et choisis « Sauvegarder la position actuelle », puis remplis la map, le type, la catégorie, le nom et le message du chat.

Dans la fenêtre, la liste **Catégorie** propose toutes les catégories déjà créées pour la map (y compris celles créées dans la fenêtre de gestion). Tape quelques lettres pour **chercher** une catégorie : la liste se filtre. Taper un nom qui n'existe pas ne crée rien, et l'enregistrement est refusé tant qu'aucune catégorie existante n'est choisie. Pour en créer une, utilise le bouton **+** à côté de la liste : la catégorie est créée dans la map choisie avec exactement le nom que tu tapes (le type n'est pas ajouté devant) et elle est sélectionnée.

**Tags** : la liste **Tags** (entre le nom et l'info du chat) propose les tags déjà créés. Choisis-en un ou tape-en un nouveau, puis clique sur **+** pour l'ajouter au stuff (un tag nouveau est créé et gardé dans `data\tags.txt`). Le bouton **-** retire le tag tapé, ou le dernier ajouté si la liste est vide. Le bouton **→ Info** recopie le nom des tags dans le message d'info du chat. Un stuff peut avoir plusieurs tags. Ils s'affichent sous le message d'info dans le menu, se retrouvent dans la recherche rapide (tape `#facile` ou `facile`), et se modifient dans la fenêtre « Modifier le stuff ». Ils sont inclus dans l'export et l'import.

**À la main** : édite `maps/de_<map>.txt`, une ligne par stuff :

```
Catégorie | Nom affiché | commande(s) console | info affichée dans le chat (optionnel) | tags séparés par des virgules (optionnel)
```

Exemple :

```
Smoke - Site A | Smoke CT depuis T spawn | setpos -456 -2288 -163; setang -39 57; give weapon_smokegrenade | Jump throw - clic gauche
```

- Les tags sont le 5e champ (`... | info | facile, site-a`). Sans info, laisse le 4e champ vide : `... | commandes |  | facile`.
- Une catégorie est le premier champ des lignes. Une catégorie vide se déclare avec `@cat | Nom`.
- Évite le caractère `;` dans l'info du chat (il est remplacé par une virgule).
- Les lignes commençant par `#` sont ignorées. Voir `maps_default/_exemple.txt`.
- `maps/_commun.txt` s'affiche dans toutes les maps.

## Où sont mes stuffs ?

Le dépôt ne contient aucun stuff : il fournit des maps vides dans `maps_default\`. Au premier lancement, le script les copie dans `maps\`, ton dossier personnel. Le dossier `maps\` (comme `data\` et `profiles\`) est exclu de git : tes stuffs ne sont jamais envoyés sur GitHub, même avec `git add .`, et une mise à jour du script ne les écrase pas.

## Structure

```
stuff_menu.ahk        script principal
cs2_practice.cfg      réglages d'entraînement (copié dans le cfg de CS2 au premier lancement)
config.example.ini    modèle de configuration (copié en config.ini)
maps_default/         modèles de maps vides (copiés dans maps/ au premier lancement)
maps/                 tes stuffs : un fichier .txt par map + _commun.txt (non versionné)
data/                 favoris, récents, captures, copies de sécurité (non versionné)
profiles/             autres profils de stuffs (non versionné)
update.bat            mise à jour sans lancer le script
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

- **Sauvegarde automatique** : une fois par jour, au lancement du script, tes maps (de chaque profil) sont copiées dans `data\backup\auto\AAAA-MM-JJ\`. Les 14 dernières sont conservées (`BackupKeep` dans `config.ini`, `AutoBackup=0` pour désactiver). Pour restaurer : entrée « Profils et partage de stuffs » du menu, puis bouton « Restaurer une sauvegarde… ». Ton état actuel est sauvegardé juste avant dans un dossier `avant-restauration-...`.
- **Annuler une suppression** : `Ctrl+Z` dans le menu, ou le bouton « Annuler la suppression » (et `Ctrl+Z`) dans la fenêtre de gestion. Le dernier stuff supprimé est remis dans sa catégorie ; les 50 derniers sont mémorisés dans `data\deleted.txt`. Le favori et le cadenas du stuff ne sont pas restaurés. La suppression d'une catégorie ne détruit pas ses stuffs (ils vont dans « Non classés »), donc elle n'a pas besoin d'être annulée.

## Vérification de l'installation

Au lancement, le script vérifie ce qui peut l'être sans CS2 : dossier cfg, `cs2_practice.cfg`, tes maps, droits d'écriture, présence de `console.log`. Une petite fenêtre affiche le résultat avec ✔, ⚠ ou ✘ et la solution de chaque problème.

Dès que CS2 est lancé et au premier plan dans une map locale, le script teste la connexion directe, l'envoi d'une commande (via `console.log`), les cheats et la détection de la map. S'il n'y a aucun problème, la fenêtre se ferme toute seule.

- Pour relancer la vérification : bouton « Vérifier l'installation » dans les réglages du menu (visible sous tous les onglets).
- Pour la désactiver : `AutoCheck=0` dans `config.ini`.
- Le test d'envoi passe par la connexion directe. Si elle échoue, la ligne « Connexion directe à CS2 impossible » indique quoi faire.

## Mise à jour

- **Automatique** : au lancement, le script regarde s'il existe une version plus récente sur GitHub. Si oui, il te propose de l'installer ; accepte et il redémarre tout seul. Pour désactiver la vérification : `AutoUpdate=0` dans `config.ini`.
- **Sans le script** : ferme le script, puis double-clique sur `update.bat`. Il télécharge la dernière version et remplace les fichiers du programme.
- **Avec Git** : `git pull` dans le dossier.

Dans tous les cas, `maps\`, `data\`, `profiles\` et `config.ini` ne sont jamais modifiés : tes stuffs, favoris, profils et réglages restent en place. L'ancien script est copié dans `data\backup\stuff_menu.ahk.bak`. Si `cs2_practice.cfg` change (voir le CHANGELOG), supprime l'ancienne copie du dossier cfg de CS2 : le script en recopie une neuve au lancement. Les anciennes liaisons de touches (`stuff_run`, `hud_pos`) laissées par les versions précédentes sont retirées automatiquement.

## Dépannage

- **Le menu n'apparaît pas** : vérifie que le script tourne et que CS2 est en mode fenêtré (plein écran fenêtré). Tu peux aussi placer le menu sur un autre écran dans les réglages du menu (réglages de position).
- **La map n'est pas détectée** : vérifie que `-condebug` est dans les options de lancement de CS2 sur Steam, ou règle `AutoDetectMap=0` dans `config.ini`.
- **Une infobulle dit « Pas de connexion à CS2 »** : CS2 n'a pas été lancé par le menu (ou sans `-netconport`). Ferme le jeu puis relance le menu : il redémarre CS2 avec les bonnes options. Contrôle avec « Vérifier l'installation » dans les réglages. En ligne de commande : `netstat -ano | findstr 2121` doit afficher `LISTENING` quand le jeu tourne.
- **CS2 ne se lance pas depuis le menu** : vérifie que Steam est installé et connecté. En dernier recours, ajoute `-condebug -netconport 2121 -insecure` dans les options de lancement de CS2 sur Steam et lance le jeu toi-même.
- **TP, give, God mode ou bot ne marchent plus** : ces commandes exigent `sv_cheats 1`. Le script l'envoie avant chaque commande ; si ça ne marche toujours pas, vérifie que tu es bien dans une partie locale (pas en matchmaking). Test rapide : tape `setpos 0 0 0` dans la console.
- **Rien ne se passe au choix d'un stuff** : vérifie que tu es dans une partie locale et que la connexion directe est active (« Vérifier l'installation »).
- **Des armes changent toutes seules** : d'anciennes versions du menu liaient des touches du pavé numérique (`*`, `/`). Le menu les retire de `cs2_practice.cfg` au lancement ; relance CS2 depuis le menu pour repartir proprement. Si le problème persiste, vérifie qu'aucun logiciel (Discord, clavier, souris) ne répète une touche.
- **L'exec automatique ne se déclenche pas** : vérifie `-condebug` (détection de map) et la connexion directe, ou utilise l'entrée « Relancer l'exec » du menu.
- **Suppression par erreur** : récupère le fichier dans `data/backup/`.

## Contribuer

Les lineups des maps sont dans `maps/` : les pull requests avec de nouveaux repères sont les bienvenues (une ligne par stuff, nom clair, info de lancer dans le 4e champ).

## Licence

[MIT](LICENSE)
