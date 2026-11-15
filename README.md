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
- **Chronomètre de grenade** : temps entre le lâcher et l'explosion, en direct pour les relances, et **temps de vol mémorisé par stuff**
- **Quiz** : un stuff au hasard, sans la visée ni les infos du chat
- **Captures d'écran** des stuffs, **coordonnées en temps réel**, **profils** et **partage** de stuffs (export / import avec aperçu)

## Prérequis

- Windows, [Steam](https://store.steampowered.com/) et [AutoHotkey v2](https://www.autohotkey.com/) (installé automatiquement par `install.bat` s'il manque)
- Counter-Strike 2
- L'option de lancement Steam **`-condebug`** (obligatoire : le menu lit `console.log` pour détecter la map et ta position). Aucune autre option de lancement n'est à ajouter : `-netconport` et `-insecure` sont ajoutées par le menu lui-même.

## Installation

### Avec l'installateur (recommandé)

1. Télécharge ce dépôt (bouton vert **Code > Download ZIP**) et extrais-le n'importe où (Bureau, Téléchargements...).
2. Double-clique sur **`install.bat`**. Une fenêtre te demande le dossier d'installation (par exemple `D:\Jeux`, avec tes autres jeux) : un sous-dossier **Menu Stuf** y est créé.
   - **N'installe pas dans `C:\Program Files`** (ni `C:\Windows`) : le menu y enregistre tes stuffs et Windows l'en empêche. L'installateur refuse ces dossiers.
   - Si AutoHotkey v2 manque, l'installateur l'installe avec `winget` ; sinon il ouvre la page de téléchargement et tu relances `install.bat` ensuite.
   - Il crée un raccourci **Menu Stuf** (avec son icône) sur le **Bureau** et dans le **menu Démarrer**.
3. Dans Steam, clic droit sur Counter-Strike 2 > **Propriétés** > **Options de lancement**, et ajoute **`-condebug`** (une seule fois). Garde tes autres options si tu en as.
4. **Ferme CS2**, puis ouvre le raccourci **Menu Stuf**. Le **launcher** s'ouvre : clique sur **Lancer CS2**. Au premier lancement, **tout se configure tout seul** :
   - `config.ini` est créé à partir de `config.example.ini` ;
   - le dossier cfg de CS2 est trouvé automatiquement (Steam et ses bibliothèques). S'il n'est pas trouvé, une fenêtre te demande de le choisir : `...\Counter-Strike Global Offensive\game\csgo\cfg` ;
   - `cs2_practice.cfg` est copié dans ce dossier cfg (un fichier existant n'est jamais écrasé) ;
   - une fenêtre t'explique que le menu va lancer CS2 avec `-netconport 2121 -insecure`, puis il **démarre le jeu lui-même** (par Steam, sans modifier tes options de lancement).
5. Attends que CS2 soit chargé et lance une **map d'entraînement locale**. Le voyant du launcher passe au vert (« CS2 lancé et connecté au menu »).
6. Appuie sur `F1` en jeu pour ouvrir le menu.

**Tu utilisais déjà le menu ?** Ferme-le avant de lancer `install.bat`. L'installateur cherche ton ancienne installation (dossier du menu en cours d'exécution, Bureau, Documents, Téléchargements, disques) et te propose de **reprendre tes stuffs, favoris, temps de vol, profils et réglages** dans le nouveau dossier. Rien n'est supprimé ni modifié dans l'ancien dossier : supprime-le toi-même quand tout fonctionne. Si tu installes dans le même dossier que l'ancien, tes fichiers restent en place. Si l'installateur ne trouve rien, copie à la main `maps`, `data`, `profiles` et `config.ini` de l'ancien dossier vers le nouveau.

Pour désinstaller : ferme le menu, puis `uninstall.bat` (supprime les raccourcis ; ton dossier, avec tes stuffs, est conservé).

### À la main

1. Installe [AutoHotkey v2](https://www.autohotkey.com/).
2. Télécharge ce dépôt, extrais-le où tu veux (hors `C:\Program Files`), ou clone-le.
3. Ajoute **`-condebug`** dans les options de lancement de CS2 (Steam).
4. **Ferme CS2**, puis double-clique sur `stuff_menu.ahk` : le launcher s'ouvre, clique sur **Lancer CS2**.

**Règle à retenir : lance toujours le menu avant CS2.** C'est lui qui démarre le jeu avec la connexion directe, le seul moyen d'envoyer les commandes. Si CS2 est déjà ouvert quand tu cliques sur « Lancer », le menu te propose de le fermer et de le relancer avec les bonnes options.

Le menu est vide au départ : sauvegarde tes stuffs avec « Sauvegarder la position actuelle » (voir plus bas) ou importe ceux d'un ami avec « Profils et partage de stuffs ».

## Launcher

Au démarrage du menu, une fenêtre d'accueil propose : **Lancer CS2**, **Map au lancement**, **Nouveautés**, **Vérification** (de l'installation), **Réglages**, **Ouvrir le dossier**, **Sauvegarder maintenant**, **Packs de stuffs**, **Guide de démarrage**, **Signaler un problème** et **Quitter le menu**. Sous le titre, une ligne indique si le menu est à jour (clic pour installer une nouvelle version). Après « Lancer CS2 », la vérification de l'installation s'ouvre toute seule à côté du launcher (`AutoCheck=0` pour la désactiver) ; les nouveautés ne s'ouvrent pas toutes seules. Un voyant indique l'état de CS2 (non lancé, lancé et connecté, lancé sans connexion directe). Fermer la fenêtre laisse le menu actif : l'icône près de l'horloge la rouvre (clic). `Launcher=0` dans `config.ini` supprime la fenêtre et rétablit l'ancien comportement : le menu lance CS2 tout seul au démarrage.

## Raccourcis

Une seule touche en jeu : **`F1`** ouvre le **menu principal**. Tout le reste s'y trouve (navigation aux flèches, `Entrée` pour choisir, `Échap` pour fermer) :

| Entrée du menu | Action |
| --- | --- |
| Stuffs (maps et catégories) | Le menu des stuffs : Map > Catégorie > Stuff, ouvert sur la map détectée |
| Utilitaires | Bots (placer, accroupi, immobile…), God mode, noclip, kit d'armes, kill smokes… (catégorie `Utilitaires` de `maps\_commun.txt`) |
| Relancer le dernier stuff | Relance le dernier stuff utilisé |
| Quiz : stuff au hasard | Te téléporte au départ d'un stuff au hasard de la map, **sans la visée ni le message du chat** (voir [Quiz](#quiz)) |
| Quiz : voir la réponse | Relance le stuff du quiz en entier (visée et info du chat) |
| Sauvegarder la position actuelle | Enregistre ta position comme nouveau stuff |
| Gérer les stuffs et les catégories | Fenêtre de gestion (déplacer, renommer, supprimer, modifier) |
| Profils et partage de stuffs | Profils, export et import |
| Nouveautés | Historique des dernières versions (le CHANGELOG) |
| Réglages du menu | Sept onglets : Menu, Couleurs, Captures, Coords, Chrono, Fenêtres, Aide |
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

## Ergonomie des fenêtres

- **Style des fenêtres** : onglet **Fenêtres** des réglages. Thème sombre (par défaut), clair ou « comme le menu en jeu », couleur d'accent (onglets), police et taille du texte (90 à 120 %). Les changements s'appliquent à la prochaine ouverture d'une fenêtre. Équivalents dans `config.ini` : `WinTheme` (`dark`, `light`, `menu`), `WinAccent`, `WinFont`, `WinScale`. Les petites boîtes de message de Windows (confirmations, sélecteurs de fichier) gardent le style de Windows. Si les fenêtres sont illisibles chez toi, mets `WinTheme=light`.
- **Réglages** : sept onglets (Menu, Couleurs, Captures, Coords, Chrono, Fenêtres, Aide). Chaque position (menu, capture, coordonnées, chrono) a un bouton **Placer avec la souris** : tu cliques à l'endroit voulu à l'écran. « Réinitialiser » ne remet à zéro que l'onglet affiché.
- **Gestion des stuffs** : champ de recherche (nom ou info), colonne du temps de vol, clic droit sur un stuff (modifier, renommer, info, cadenas, supprimer), fenêtre redimensionnable. Clique sur un titre de colonne pour trier.
- **Profils et partage** : trois onglets (Profils, Partager des stuffs, Sauvegardes) et un compteur de stuffs cochés.
- **Restaurer une sauvegarde** : les sauvegardes sont décrites en clair (« Avant la mise à jour 2.22.0, le 15/11/2026 à 09 h 18 »).
- **Menu principal** : trois blocs séparés par des tirets, « Quiz : voir la réponse » n'apparaît que pendant un quiz.
- **Vérification de l'installation** : boutons pour copier `cs2_practice.cfg` dans le cfg de CS2 et ouvrir ce dossier.

- **Boutons** : le bouton principal est toujours à droite (Enregistrer, Importer, Restaurer, Changer de map), les boutons secondaires à gauche.
- **Sauvegarder la position** : la position est dans une zone « Détails : position » repliable (ouverte automatiquement si la position n'a pas pu être lue) ; un message rouge sous le champ Nom signale tout de suite un nom déjà pris (aussi dans « Modifier le stuff »).
- **Aperçu du style** : dans l'onglet Fenêtres des réglages, chaque changement ouvre une petite fenêtre d'aperçu à côté.
- **Fenêtre de gestion** : elle se rouvre à la taille et à la place où tu l'as laissée.
- **Nouveautés** : titres de version en gras et en couleur d'accent.

## Dernier lancer en stuff

Entrée « Enregistrer le dernier lancer comme stuff » du menu principal : le menu retient, à chaque grenade lancée au clic, ta position et ton angle (envoyés au moment du lancer) ainsi que le temps mesuré par le chronomètre. L'entrée ouvre la fenêtre de sauvegarde déjà remplie : position, type de grenade, « give » coché et temps de vol enregistré avec le stuff, sans nouvelle mesure. Il suffit de choisir la catégorie et le nom. Le chronomètre doit être actif. Les relances avec la touche K ne changent pas le lancer mémorisé (elles relancent la même trajectoire) mais mettent à jour son temps. Pas de capture d'écran dans ce cas.

## Changer de map

L'entrée « Changer de map » du menu principal ouvre une liste (tes maps, plus les maps de compétition). Double-clic ou « Changer de map » : le menu envoie `map <nom>` au jeu. Tu peux aussi taper un nom à la main (ex. `cs_office`). Le cfg d'entraînement se relance tout seul sur la nouvelle map si l'exec automatique est activé.

## Gestion des stuffs et des catégories

L'entrée « Gérer les stuffs et les catégories » du menu ouvre une fenêtre de gestion, au centre de l'écran :

- **Catégories** (à gauche) : créer, renommer, supprimer, verrouiller.
- **Stuffs** (à droite) : renommer, modifier le message du chat, supprimer, verrouiller.
- **Modifier un stuff en entier** : double-clic sur un stuff (ou « Modifier… ») pour changer le type, la catégorie, le nom, le message du chat, les **coordonnées** (setpos / setang) et les autres commandes. Le bouton « Recapturer ma position actuelle » reprend ta position en jeu.
- **Déplacer vers** : choisis une catégorie existante (ou tape un nouveau nom) et clique sur « Déplacer ». Tu peux sélectionner plusieurs stuffs avec `Ctrl` ou `Maj`.
- La liste « Map » permet de choisir la map, ou « Communs (toutes les maps) » pour gérer `maps/_commun.txt`.

**Supprimer une catégorie ne supprime pas ses stuffs** : ils sont déplacés dans la catégorie « Non classés », que tu peux ensuite vider en les déplaçant où tu veux. Les éléments verrouillés (cadenas) ne peuvent être ni supprimés, ni renommés, ni déplacés.

## Coordonnées en temps réel

L'affichage s'active dans « Réglages du menu », onglet **Coords** (pas de raccourci clavier). Une fois activé et enregistré, il reste actif à chaque lancement du script, jusqu'à ce que tu le désactives. Il se place par défaut dans le **coin inférieur gauche** de l'écran, ou où tu veux (position X / Y dans le même onglet). Il affiche la map, ta position (X, Y, Z) et ton angle de vue (pitch, yaw), mises à jour plusieurs fois par seconde. Le texte suit l'apparence réglée dans « Réglages du menu ».

Le script demande `getpos` au jeu à intervalle régulier et lit la réponse dans `console.log` (option `-condebug`). Il ne lit pas la mémoire du jeu.

- La fréquence se règle avec `HudInterval` (en ms, 300 par défaut) . `HudAtStart` (0 ou 1) est géré par la case des réglages.
- Les coordonnées sont demandées par la connexion directe, sans aucune touche : elles ne gênent ni la console ni le chat. Le script fait une pause de 2 secondes après chaque stuff lancé.
- Il se met en pause quand le menu ou une fenêtre du script est ouverte, et quand CS2 n'est pas la fenêtre active.

## Chronomètre de grenade

Après chaque grenade (smoke, flash, HE, molotov, incendiaire, leurre), le menu affiche le temps écoulé entre le moment où tu la **lâches** et celui où elle **explose**, par exemple `Smoke : 2,9 s`. Le résultat reste à l'écran le nombre de secondes choisi, puis disparaît.

- **Départ du chrono** : le relâchement du clic gauche, ou l'appui sur la touche de relance `sv_rethrow_last_grenade` (touche `K` du cfg d'entraînement ; si tu l'as changée, mets la même dans `RethrowKey` de `config.ini`). Chaque grenade en vol garde son propre départ, la ligne `sv_throw_...` du journal le confirme. En cas de temps incorrect, mets `TimerDebug=1` dans `config.ini` : les événements sont notés dans `data\timer_debug.txt` (et ajoutés au diagnostic).
- **Fin du chrono** : la ligne `threw smokegrenade [x y z]` que le jeu écrit dans `console.log` quand la grenade explose. Le menu active tout seul le journal du serveur (`log on` et `mp_logdetail 3`) ; la mesure demande donc `-condebug`, comme le reste du menu.
- **Précision** : de l'ordre d'un dixième de seconde (le menu lit le fichier toutes les 50 ms).
- **Limite** : le menu ne sait pas quelle arme tu tiens. Si tu tires avec une arme pendant que la grenade vole, le temps affiché peut être faux.
- **Réglages** : « Réglages du menu », onglet **Chrono** : activer, placement (par défaut **juste au-dessus des coordonnées**, ou libre avec position X / Y), durée d'affichage, et bouton « Tester l'affichage ». La police, les couleurs, le liseré, les coins arrondis et l'opacité suivent ceux du menu et des coordonnées. Équivalents dans `config.ini` : `TimerOn`, `TimerAuto`, `TimerX`, `TimerY`, `TimerDur`.
- **Tester la mesure** : bouton dans l'onglet Chrono des réglages. Pendant 60 s, chaque grenade lancée dans CS2 est mesurée et le résultat s'affiche dans les réglages avec l'origine du départ (clic, touche de relance, journal), même si le chronomètre est désactivé.
- **Bip d'arrivée** : si le temps de vol du stuff lancé par le menu est connu, un court bip retentit 0,5 s avant l'explosion prévue ; sinon il retentit à l'explosion. Case dans l'onglet Chronomètre, `TimerBeep=0` pour le couper.

- **Chrono en direct** : quand le jeu écrit la ligne de lancer (`sv_throw_...`) au moment où la grenade part, le type est connu tout de suite : le compteur tourne à l'écran jusqu'à l'explosion, puis s'arrête sur le temps final. Avec la touche de relance, le compteur démarre aussi tout de suite, avec le type de la dernière grenade vue.

Le journal du serveur crée aussi des fichiers dans `game\csgo\logs\`. Pour ne pas l'activer, désactive le chronomètre.

### Temps de vol d'un stuff

Le temps de vol d'un stuff (du lâcher à l'explosion) peut être mémorisé et affiché dans le menu, sous l'info du stuff : `Temps de vol : 2,9 s`.

- **Rien n'est obligatoire** : le temps de vol est facultatif pour chaque stuff. Tu peux répondre « Non » à la proposition, ne jamais mesurer un stuff, ou désactiver la proposition dans « Réglages du menu », onglet **Chrono** (case « Proposer de mesurer le temps de vol après la création d'un stuff », ou `FlightAsk=0` dans `config.ini`).
- **À la création** : après l'enregistrement d'un stuff de grenade (fenêtre « Sauvegarder la position actuelle » ou `F4`), le menu propose de mesurer son temps de vol. Si tu acceptes, tu es téléporté au repère (avec la grenade), tu la lances, et le menu mesure le temps. **Tu valides le résultat** : « Oui » l'enregistre, « Non » te laisse refaire le lancer (si tu as raté), « Annuler » abandonne. `Échap` annule l'attente, et au bout de 30 secondes sans explosion, le menu propose de réessayer.
- **Pour un stuff existant** : fenêtre « Modifier le stuff » (double-clic dans la fenêtre de gestion), ligne « Temps de vol », bouton **Mesurer...** (ou **Supprimer** pour retirer le temps), puis « Enregistrer ». Cela marche aussi pour les stuffs créés avant cette version.
- Le temps est enregistré dans `data\times.txt`, lié à la position et à la visée du stuff : il suit le stuff quand tu le renommes ou le déplaces. Si tu changes la position ou la visée, l'ancien temps est supprimé (il n'est plus valable). Il est **inclus dans les exports** (fichier ou code) et repris à l'import, sauf si tu décoches **Importer les temps de vol** dans la fenêtre d'import : le temps est lié au stuff importé, sans écraser un temps que tu as déjà mesuré (sauf si tu choisis « Remplacer le mien »).
- La mesure marche même si l'affichage du chronomètre est désactivé dans les réglages.

## Quiz

Entrée « Quiz : stuff au hasard » du menu principal : le menu choisit un stuff au hasard parmi ceux de la map détectée (hors catégorie Utilitaires) et te téléporte au point de départ avec la grenade, mais **sans régler la visée et sans envoyer le message du chat**. Un **bandeau en haut de l'écran** affiche le nom du stuff et sa catégorie (il reste affiché tant que tu n'as pas demandé la réponse) ; à toi de retrouver le lineup. « Quiz : voir la réponse » relance ensuite le stuff en entier (visée et info du chat) et retire le bandeau.

## Profils et partage

L'entrée « Profils et partage de stuffs » du menu ouvre la fenêtre **Profils et partage**.

- **Profils** : chaque joueur peut avoir plusieurs profils (par exemple « Principal », « Stuffs de Léo », « Equipe »). Le profil Principal utilise les dossiers `maps\` et `data\` ; les autres sont dans `profiles\<nom>\`. « Activer » recharge le script avec le profil choisi. Chaque profil a ses propres stuffs, favoris, récents et cadenas.
- **Exporter** : coche les stuffs à partager (un seul, plusieurs ou tout), puis « Exporter vers un fichier… » (fichier `.stuffpack`) ou « Copier le code » (texte à coller dans Discord, de préférence dans un bloc de code ; pour beaucoup de stuffs, envoie plutôt le fichier).
- **Importer** : « Importer un fichier… » ou « Importer depuis le presse-papiers ». Une fenêtre liste les stuffs reçus avec leur statut (Nouveau, Doublon, Identique). Tu coches ceux à garder, tu choisis le profil de destination (existant, ou un nom nouveau pour en créer un) et ce qu'il faut faire des doublons : ignorer, garder les deux (le nouveau est renommé) ou remplacer le tien.
- **Profil complet en un fichier** : « Exporter le profil… » crée un `.zip` avec les maps, les temps de vol, les favoris, les cadenas, les captures et les réglages (apparence, touches, coordonnées, chronomètre ; jamais les chemins de ce PC). « Importer un profil… » le recrée sur un autre PC (nom au choix ; un profil existant est sauvegardé avant d'être remplacé, les commandes interdites sont ignorées, l'application des réglages est facultative).
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

Quand tu sauvegardes un stuff (entrée « Sauvegarder la position actuelle » du menu, ou `F4` dans le menu des stuffs), le script prend une petite capture de 100 x 100 px au centre du jeu (autour du réticule) et la propose dans la fenêtre. Si la case est cochée, elle est liée au stuff. Dans le menu, la capture du stuff sélectionné s'affiche dans le coin supérieur droit de l'écran (placement réglable). Pour la refaire : « Gérer les stuffs et les catégories » du menu, double-clic sur le stuff, bouton « Refaire la capture (en jeu) » (place-toi au point du stuff : les fenêtres se masquent et la capture se fait 3 secondes plus tard). Les captures sont dans `data\shots\`. Elles peuvent être jointes à un export vers un fichier `.stuffpack` (case « Inclure les captures » dans « Profils et partage de stuffs ») : l'import les restaure. Le code copié ne les contient pas (trop lourd).

Les captures qui ne correspondent plus à aucun stuff (stuff supprimé ou déplacé) peuvent être supprimées (onglet Aide des réglages) avec le bouton **Nettoyer les captures et temps orphelins** de l'onglet « Captures » (il nettoie aussi les temps de vol orphelins du profil actif).

Tout se règle dans « Réglages du menu », onglet « Captures » : activer, zone capturée, taille affichée, placement (coin supérieur droit par défaut, ou libre avec position X/Y), arrondi des coins (3 px par défaut). Le liseré de la capture reprend celui du menu et se dessine par-dessus l'image. Équivalents dans `config.ini` : `Shot`, `ShotSize`, `ShotZoom`, `ShotPos`, `ShotCorner`, `ShotX`, `ShotY`. Le jeu doit être en fenêtré ou en plein écran fenêtré.

## Ajouter des stuffs

**Noms uniques** : dans une map, deux stuffs ne peuvent pas porter le même nom, même dans des catégories différentes (les majuscules ne comptent pas). Deux catégories non plus. Le menu refuse l'enregistrement, le renommage ou le déplacement qui créerait un doublon, et utilise la catégorie existante si tu en tapes une qui existe déjà à la casse près.

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
data/                 favoris, récents, captures, temps de vol (times.txt), copies de sécurité (non versionné)
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

## Map d'entraînement automatique

Après « Lancer CS2 », le menu charge tout seul une map d'entraînement une fois le jeu prêt (`AutoMapDelay`, 8 s par défaut). Le choix se fait dans le launcher, « Map au lancement » : *Dernière map jouée* (de_dust2 la première fois), une map précise, ou *Aucune*. Dans `config.ini` : `AutoMap=last`, `none` ou un nom de map (ex. `de_mirage`). Cela ne concerne que le jeu lancé par le menu.

## Guide de démarrage

À la première utilisation, une fenêtre explique les 3 étapes (lancer CS2, ouvrir le menu avec la touche, récupérer des stuffs) et permet de changer la touche du menu. Le bouton « Guide de démarrage » du launcher la rouvre.

## Packs de stuffs

Le bouton « Packs de stuffs » (launcher, ou « Profils et partage > Partager des stuffs ») liste les packs publiés dans le dossier `packs\` du dépôt GitHub. Un clic télécharge le pack et ouvre la fenêtre d'import habituelle (tu choisis quoi garder et où le ranger). Les joueurs ne peuvent que les importer.

Pour publier un pack (propriétaire du dépôt) : mets `PackAdmin=1` dans ton `config.ini`, exporte tes stuffs en `.stuffpack`, puis dans la fenêtre des packs clique sur « Publier un pack (administrateur)... » : le fichier est copié dans `packs\` de ton dossier Git et `packs\index.txt` est mis à jour (`PackRepoDir` = ton dossier Git, demandé la première fois). Termine avec `git add .`, `git commit`, `git push`. Format de `index.txt` : une ligne par pack, `fichier.stuffpack | Titre | Description`.

## Signaler un problème

Le bouton « Signaler un problème » du launcher (ou « Créer un rapport » dans la vérification) affiche un rapport : version, Windows, état de l'installation, réglages, dernières erreurs du menu et extraits utiles de `console.log`. Les chemins et le nom d'utilisateur Windows sont masqués. Tu peux le copier ou l'enregistrer dans `data\rapport_...txt`.

## Retour à la version précédente

Chaque mise à jour garde l'ancien script dans `data\backup\stuff_menu.ahk.bak`. Si le menu rencontre deux erreurs dans les minutes qui suivent une mise à jour, il propose de revenir à la version précédente (tes stuffs ne sont pas touchés, la version abandonnée n'est plus proposée automatiquement). Le même retour est dans « Profils et partage > Sauvegardes ». Si le menu ne démarre plus du tout, double-clique sur `rollback.bat`. Les erreurs sont notées dans `data\menu_errors.log`.

## Sauvegardes et annulation

- **Sauvegarde manuelle** : bouton « Sauvegarder maintenant » du launcher (les 10 dernières sont gardées, listées dans « Restaurer une sauvegarde »).
- **Sauvegarde automatique** : une fois par jour, au lancement du script, tes maps (de chaque profil) sont copiées dans `data\backup\auto\AAAA-MM-JJ\`. Les 14 dernières sont conservées (`BackupKeep` dans `config.ini`, `AutoBackup=0` pour désactiver). Pour restaurer : entrée « Profils et partage de stuffs » du menu, puis bouton « Restaurer une sauvegarde… ». Ton état actuel est sauvegardé juste avant dans un dossier `avant-restauration-...`.
- **Annuler une suppression** : `Ctrl+Z` dans le menu, ou le bouton « Annuler la suppression » (et `Ctrl+Z`) dans la fenêtre de gestion. Le dernier stuff supprimé est remis dans sa catégorie ; les 50 derniers sont mémorisés dans `data\deleted.txt`. Le favori et le cadenas du stuff ne sont pas restaurés. La suppression d'une catégorie ne détruit pas ses stuffs (ils vont dans « Non classés »), donc elle n'a pas besoin d'être annulée.

## Vérification de l'installation

Sous les onglets de « Réglages du menu », un voyant indique en direct si CS2 est connecté au menu (vert) ou non (rouge).

Au lancement, le script vérifie ce qui peut l'être sans CS2 : dossier cfg, `cs2_practice.cfg`, tes maps, droits d'écriture, présence de `console.log`. Une petite fenêtre affiche le résultat avec ✔, ⚠ ou ✘ et la solution de chaque problème.

Dès que CS2 est lancé et au premier plan dans une map locale, le script teste la connexion directe, l'envoi d'une commande (via `console.log`), les cheats et la détection de la map. S'il n'y a aucun problème, la fenêtre se ferme toute seule.

- Pour relancer la vérification : bouton « Vérifier l'installation » dans les réglages du menu (onglet « Aide »).
- Pour demander de l'aide : bouton **Copier le diagnostic** juste en dessous. Il copie dans le presse-papiers la version, l'état de la connexion directe, les chemins et les dernières lignes utiles de `console.log` (identifiants Steam masqués). Colle-le dans ton message.
- Pour la désactiver : `AutoCheck=0` dans `config.ini`.
- Le test d'envoi passe par la connexion directe. Si elle échoue, la ligne « Connexion directe à CS2 impossible » indique quoi faire.

## Mise à jour

Après une mise à jour, un point ● apparaît sur le bouton **Nouveautés** du launcher (rien ne s'ouvre tout seul). Le bouton, ou l'entrée « Nouveautés » du menu en jeu, affiche les modifications des dernières versions (lues dans `CHANGELOG.md`). `ShowChangelog=0` dans `config.ini` supprime le point. Si tu désactives le launcher (`Launcher=0`), la fenêtre Nouveautés s'ouvre de nouveau toute seule après chaque mise à jour.

- **Automatique** : au lancement, le script regarde s'il existe une version plus récente sur GitHub. Si oui, il te propose de l'installer ; accepte et il redémarre tout seul. Pour désactiver la vérification : `AutoUpdate=0` dans `config.ini`.
- **Sans le script** : ferme le script, puis double-clique sur `update.bat`. Il télécharge la dernière version et remplace les fichiers du programme.
- **Avec Git** : `git pull` dans le dossier.

Dans tous les cas, `maps\`, `data\`, `profiles\` et `config.ini` ne sont jamais modifiés : tes stuffs, favoris, profils et réglages restent en place. L'ancien script est copié dans `data\backup\stuff_menu.ahk.bak`, et tes maps, temps, favoris et cadenas sont copiés avant chaque mise à jour dans `data\backup\auto\avant-maj-...` (les 5 dernières sont gardées ; « Restaurer une sauvegarde… » les remet en place). Si `cs2_practice.cfg` change (voir le CHANGELOG), supprime l'ancienne copie du dossier cfg de CS2 : le script en recopie une neuve au lancement. Les anciennes liaisons de touches (`stuff_run`, `hud_pos`) laissées par les versions précédentes sont retirées automatiquement.

## Dépannage

- **Le menu n'apparaît pas** : vérifie que le script tourne et que CS2 est en mode fenêtré (plein écran fenêtré). Tu peux aussi placer le menu sur un autre écran dans les réglages du menu (réglages de position).
- **console.log devient énorme** : au lancement du script, si le jeu est fermé et que le fichier dépasse `LogMaxMB` (10 Mo par défaut, `0` pour désactiver), il est vidé. Le jeu le recrée.
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
