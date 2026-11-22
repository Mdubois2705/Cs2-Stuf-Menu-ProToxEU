# CS2 Stuff Menu

Menu en overlay, navigable au clavier, pour s'entraîner aux lineups (smokes, flashs, molotovs, spawns…) en **entraînement local** sur Counter-Strike 2.

Le script [AutoHotkey v2](https://www.autohotkey.com/) affiche le menu par-dessus le jeu et envoie les commandes à CS2 par une **connexion directe** à sa console (option de lancement `-netconport`), sans aucune touche appuyée à ta place. Tes repères sont de simples fichiers texte, un par map.

> Projet de la communauté, sans lien avec Valve. À utiliser **uniquement en local**. Le menu lance CS2 avec `-insecure`, qui **désactive VAC** : dans cette session, pas de matchmaking, de Premier ni de FACEIT. Pour jouer en ligne, ferme le jeu et lance-le normalement depuis Steam, sans passer par le menu.

## Sommaire

- [Fonctionnalités](#fonctionnalités)
- [Installation](#installation) : [installateur](#avec-linstallateur-recommandé), [à la main](#à-la-main), [prérequis](#prérequis)
- [Utilisation](#utilisation) : [launcher](#launcher), [raccourcis](#raccourcis), [connexion directe](#connexion-directe-à-cs2), [map automatique](#map-dentraînement-automatique), [changer de map](#changer-de-map), [exec automatique](#exec-automatique)
- [Stuffs](#stuffs) : [ajouter](#ajouter-des-stuffs), [gérer](#gérer-les-stuffs-et-les-catégories), [dernier lancer](#dernier-lancer-en-stuff), [cadenas](#cadenas), [captures](#captures-décran-des-stuffs), [quiz](#quiz)
- [Chronomètre de grenade](#chronomètre-de-grenade) et [temps de vol](#temps-de-vol-dun-stuff)
- [Partage](#partage) : [profils](#profils-et-partage), [packs de stuffs](#packs-de-stuffs)
- [Réglages](#réglages) : [coordonnées](#coordonnées-en-temps-réel), [touches à l'écran](#touches-à-lécran), [fenêtres](#style-des-fenêtres), [thèmes du menu](#thèmes-et-police)
- [Maintenance](#maintenance) : [sauvegardes](#sauvegardes-et-annulation), [vérification](#vérification-de-linstallation), [mise à jour](#mise-à-jour), [retour arrière](#retour-à-la-version-précédente), [rapport](#signaler-un-problème), [dépannage](#dépannage)
- [Structure du dossier](#structure-du-dossier)

## Fonctionnalités

- Menu à 3 niveaux : **Map > Catégorie > Stuff**, ouvert directement sur la map détectée
- **Launcher** : lancer CS2, map d'entraînement chargée toute seule, état de la mise à jour, sauvegarde en un clic
- **Recherche rapide** (nom, catégorie, info et tags), **favoris**, **récents**, **tags**, relance du dernier stuff
- Infos du stuff affichées dans l'overlay et dans le **chat** au lancement
- **Sauvegarde d'un repère depuis le jeu** (position et angle capturés automatiquement), ou du dernier lancer
- **Ajout / suppression** de stuffs et de catégories depuis le menu
- Utilitaires : bots (placer, accroupi, immobile…), God mode (vie qui se régénère), noclip, kit d'armes
- **Chronomètre de grenade** : temps entre le lâcher et l'explosion, en direct pour les relances, et **temps de vol mémorisé par stuff**
- **Quiz** : entraîne-toi à retrouver les lineups, avec les stuffs de ton choix ou au hasard sans répétition
- **Captures d'écran** des stuffs, **coordonnées en temps réel**
- **Profils**, **partage** (fichier ou code) et **packs de stuffs** publiés sur GitHub
- **Apparence réglable** (menu en jeu et fenêtres) : thèmes, police, taille, couleurs
- **Sauvegardes**, annulation, **retour à la version précédente** et rapport de problème

## Installation

### Prérequis

- Windows, [Steam](https://store.steampowered.com/) et [AutoHotkey v2](https://www.autohotkey.com/) (installé automatiquement par `install.bat` s'il manque)
- Counter-Strike 2
- L'option de lancement Steam **`-condebug`** (le menu lit `console.log` pour détecter la map et ta position). Aucune autre option n'est à ajouter : `-netconport` et `-insecure` sont ajoutées par le menu.

### Avec l'installateur (recommandé)

1. Télécharge ce dépôt (bouton vert **Code > Download ZIP**) et extrais-le n'importe où.
2. Double-clique sur **`install.bat`**. Une fenêtre te demande le dossier d'installation (par exemple `D:\Jeux`) : un sous-dossier **Menu Stuf** y est créé.
   - **N'installe pas dans `C:\Program Files`** (ni `C:\Windows`) : le menu y enregistre tes stuffs et Windows l'en empêche. L'installateur refuse ces dossiers.
   - Si AutoHotkey v2 manque, l'installateur l'installe avec `winget` ; sinon il ouvre la page de téléchargement et tu relances `install.bat` ensuite.
   - Il crée un raccourci **Menu Stuf** (avec son icône) sur le **Bureau** et dans le **menu Démarrer**.
3. Dans Steam, clic droit sur Counter-Strike 2 > **Propriétés** > **Options de lancement** : ajoute **`-condebug`** (une seule fois, garde tes autres options).
4. **Ferme CS2**, puis ouvre le raccourci **Menu Stuf**. Le **launcher** s'ouvre (et le [guide de démarrage](#guide-de-démarrage) la première fois) : clique sur **Lancer CS2**. Au premier lancement, tout se configure tout seul :
   - `config.ini` est créé à partir de `config.example.ini` ;
   - le dossier cfg de CS2 est trouvé automatiquement (Steam et ses bibliothèques) ; sinon une fenêtre te demande de le choisir : `...\Counter-Strike Global Offensive\game\csgo\cfg` ;
   - `cs2_practice.cfg` est copié dans ce dossier cfg (un fichier existant n'est jamais écrasé) ;
   - le menu démarre CS2 lui-même (par Steam, sans modifier tes options de lancement) puis charge une map d'entraînement.
5. Une fois dans la map, le voyant du launcher passe au vert (« CS2 lancé et connecté au menu »). Appuie sur `F1` en jeu pour ouvrir le menu.

**Tu utilisais déjà le menu ?** Ferme-le avant de lancer `install.bat`. L'installateur cherche ton ancienne installation (dossier en cours d'exécution, Bureau, Documents, Téléchargements, disques) et te propose de **reprendre tes stuffs, favoris, temps de vol, profils et réglages**. Rien n'est supprimé ni modifié dans l'ancien dossier : supprime-le toi-même quand tout fonctionne. Si l'installateur ne trouve rien, copie à la main `maps`, `data`, `profiles` et `config.ini` de l'ancien dossier vers le nouveau.

Pour désinstaller : ferme le menu, puis `uninstall.bat` (supprime les raccourcis ; ton dossier, avec tes stuffs, est conservé).

### À la main

1. Installe [AutoHotkey v2](https://www.autohotkey.com/).
2. Télécharge ce dépôt, extrais-le où tu veux (hors `C:\Program Files`), ou clone-le.
3. Ajoute **`-condebug`** dans les options de lancement de CS2 (Steam).
4. **Ferme CS2**, puis double-clique sur `stuff_menu.ahk` : le launcher s'ouvre, clique sur **Lancer CS2**.

**Règle à retenir : lance toujours le menu avant CS2.** C'est lui qui démarre le jeu avec la connexion directe, le seul moyen d'envoyer les commandes. Si CS2 est déjà ouvert quand tu cliques sur « Lancer », le menu te propose de le fermer et de le relancer avec les bonnes options.

Le menu est vide au départ : sauvegarde tes stuffs avec « Sauvegarder la position actuelle », ou importe-en avec les [packs](#packs-de-stuffs) ou le [partage](#profils-et-partage).

### Guide de démarrage

À la première utilisation, une fenêtre explique les 3 étapes (lancer CS2, ouvrir le menu avec la touche, récupérer des stuffs) et permet de changer la touche du menu. Le bouton « Guide de démarrage » du launcher la rouvre.

## Utilisation

### Launcher

Au démarrage, une fenêtre d'accueil propose :

| Élément | Rôle |
| --- | --- |
| Ligne de version | « Menu à jour » ou « Version X disponible » (clic pour installer) |
| Vérifier les mises à jour | Cherche une nouvelle version et propose de l'installer |
| Voyant | État de CS2 : non lancé, lancé et connecté, lancé sans connexion directe |
| **Lancer CS2** | Démarre le jeu avec la connexion directe (ou le relance si besoin) |
| **Map au lancement** | Map chargée automatiquement après le lancement (voir [map automatique](#map-dentraînement-automatique)) |
| Nouveautés | Historique des versions (point ● quand il y a du nouveau) |
| Vérification | Contrôle de l'installation (s'ouvre aussi toute seule à côté du launcher après « Lancer CS2 » ; `AutoCheck=0` pour l'éviter) |
| Réglages, Ouvrir le dossier | Réglages du menu, dossier d'installation |
| Sauvegarder maintenant | Copie manuelle de tes stuffs, favoris et temps de vol |
| Packs de stuffs | Packs publiés sur GitHub (voir [packs](#packs-de-stuffs)) ; point ● quand il y en a de nouveaux |
| Guide de démarrage | Les 3 étapes pour débuter |
| Signaler un problème | Rapport à envoyer (voir [rapport](#signaler-un-problème)) |

Fermer la fenêtre laisse le menu actif : l'icône près de l'horloge la rouvre (clic). `Launcher=0` dans `config.ini` supprime la fenêtre et rétablit l'ancien comportement : le menu lance CS2 tout seul au démarrage.

### Raccourcis

Une seule touche en jeu : **`F1`** ouvre le **menu principal**. Tout le reste s'y trouve (navigation aux flèches, `Entrée` pour choisir, `Échap` pour fermer) :

| Entrée du menu | Action |
| --- | --- |
| Stuffs | Menu des stuffs : Map > Catégorie > Stuff, ouvert sur la map détectée |
| Utilitaires | Bots, God mode, noclip, kit d'armes, kill smokes… (catégorie `Utilitaires` de `maps\_commun.txt`) |
| Relancer le dernier stuff | Relance le dernier stuff utilisé |
| Quiz : choisir les stuffs et lancer | Ouvre la page de départ du quiz (voir [Quiz](#quiz)) |
| Quiz : suivant, d'avant, aide, réponse, arrêter | Disponibles pendant un quiz, aussi avec les touches du quiz |
| Sauvegarder la position actuelle | Enregistre ta position comme nouveau stuff |
| Enregistrer le dernier lancer comme stuff | Voir [Dernier lancer](#dernier-lancer-en-stuff) |
| Changer de map | Liste de maps (voir [changer de map](#changer-de-map)) |
| Gérer les stuffs et les catégories | Fenêtre de gestion |
| Profils et partage de stuffs | Profils, export, import, sauvegardes |
| Nouveautés | Historique des dernières versions |
| Réglages du menu | Dix onglets : Menu, Couleurs, Captures, Coords, Chrono, Fenêtres, Touches, Quiz, Binds, Aide |
| Relancer l'exec de cs2_practice | Relance le cfg d'entraînement |
| Vérifier l'installation | Contrôle de l'installation |

Le menu principal a trois blocs séparés par des tirets ; les entrées « Quiz : suivant… arrêter » n'apparaissent que pendant un quiz.

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
| `F4` | Créer un nouveau stuff (catégorie courante pré-remplie). Fonctionne aussi depuis le menu principal |
| `Ctrl+Z` | Annuler la dernière suppression de stuff |

Les touches se changent dans `config.ini` (`MenuKey`, `FavKey`, `LockKey`, `AddKey`) ou, pour la touche du menu, dans le guide de démarrage.

### Connexion directe à CS2

Le menu envoie toutes ses commandes (téléportation, give, bots, god mode, coordonnées…) par un port TCP local que CS2 ouvre avec les options `-netconport 2121 -insecure`. Aucun fichier `cfg` n'est écrit, aucune touche n'est appuyée à ta place : pas de collision avec tes touches, Discord ou un logiciel de clavier.

- **Le menu lance CS2 pour toi** (`steam.exe -applaunch 730 -condebug -netconport 2121 -insecure`). Tes options de lancement enregistrées dans Steam ne sont pas modifiées.
- **Sans cette connexion, le menu ne peut pas envoyer de commandes.** Si elle échoue, une infobulle te le dit : ferme CS2 et relance le menu.
- **`-insecure` désactive VAC** : une copie de CS2 lancée ainsi ne peut pas rejoindre de serveur protégé.
- Le port est ouvert sur le réseau local : garde le pare-feu Windows actif et n'utilise le menu que sur un réseau de confiance.
- Réglages : `NetconPort` (2121 par défaut ; change-le si le port est pris) et `LaunchArgs` (`{port}` est remplacé par `NetconPort`).
- Si le lancement par le menu ne fonctionne pas chez toi, ajoute `-netconport 2121 -insecure` dans les options de lancement de CS2 sur Steam, à côté de `-condebug`.

### Map d'entraînement automatique

Après « Lancer CS2 », le menu charge tout seul une map d'entraînement une fois le jeu prêt (`AutoMapDelay`, 8 s par défaut), puis exécute le [cfg d'entraînement](#exec-automatique). Le choix se fait dans le launcher, « Map au lancement » : *Dernière map jouée* (de_dust2 la première fois), une map précise, ou *Aucune*. Dans `config.ini` : `AutoMap=last`, `none` ou un nom de map (ex. `de_mirage`). Cela ne concerne que le jeu lancé par le menu.

### Changer de map

L'entrée « Changer de map » du menu principal ouvre une liste (tes maps, plus les maps de compétition). Double-clic ou « Changer de map » : le menu envoie `map <nom>` au jeu. Tu peux aussi taper un nom à la main (ex. `cs_office`). Le cfg d'entraînement se relance sur la nouvelle map si l'exec automatique est activé.

### Exec automatique

Les réglages d'entraînement (`cs2_practice.cfg` : argent, munitions infinies, `sv_cheats`, bots…) se remettent à zéro à chaque chargement de map. Le menu les relance pour toi :

- juste après la map chargée automatiquement par le launcher ;
- à l'ouverture du menu des stuffs, **une fois par map détectée** (la détection demande `-condebug`) ;
- à la demande avec l'entrée « Relancer l'exec » du menu, par exemple après un redémarrage de la même map.

Chaque commande du menu envoie aussi `sv_cheats 1` d'abord, donc les stuffs, le God mode et les bots marchent même si l'exec n'a pas tourné.

| Clé de `config.ini` | Rôle |
| --- | --- |
| `AutoExec` | `1` = exec automatique, `0` = désactivé |
| `PracticeCfg` | Nom du cfg à exécuter (par défaut `cs2_practice`) |

## Stuffs

### Ajouter des stuffs

**Noms** : plusieurs stuffs peuvent porter le même nom (même dans la même catégorie). Les favoris, le cadenas et les récents se basent sur le nom : deux stuffs de même nom partagent donc ces réglages. Deux catégories ne peuvent pas porter le même nom (les majuscules ne comptent pas) : le menu refuse la création ou le renommage qui créerait un doublon de catégorie.

**Depuis le jeu** : place-toi au bon endroit, vise, ouvre le menu (`F1`) et choisis « Sauvegarder la position actuelle », puis remplis la map, le type, la catégorie, le nom et le message du chat. La position est dans une zone « Détails : position » repliable (ouverte si elle n'a pas pu être lue).

- **Catégorie** : la liste propose les catégories de la map ; tape quelques lettres pour la filtrer. Pour en créer une, utilise le bouton **Nouvelle** : elle est créée avec exactement le nom tapé.
- **Tags** : la liste est officielle et identique pour tout le monde (fichier `tags_officiels.txt`, mis à jour avec le menu). Personne ne peut en créer ni en supprimer de la liste : seul l'auteur modifie ce fichier. Choisis un tag dans la liste, tape si tu veux une **touche** dans la case à côté (elle se colle devant le tag : `LEFT CLICK JUMPTHROW` + `Z` donne `Z LEFT CLICK JUMPTHROW`, `STEP LEFT CLICK THROW` + `2` donne `2 STEP LEFT CLICK THROW`), puis clique sur **Ajouter**. **Retirer** enlève un tag du stuff, **→ Info** recopie les tags dans le message du chat. Les tags s'affichent sous l'info, se cherchent dans la recherche rapide (`#facile` ou `facile`), se modifient dans « Modifier le stuff » et sont inclus dans l'export. Les anciens tags libres créés avant la liste officielle sont retirés des stuffs une seule fois, au premier lancement de cette version (une copie des maps est faite avant, dans `data\backup\avant_tags_<profil>`).

**À la main** : édite `maps/de_<map>.txt`, une ligne par stuff :

```
Catégorie | Nom affiché | commande(s) console | info affichée dans le chat (optionnel) | tags séparés par des virgules (optionnel)
```

Exemple :

```
Smoke - Site A | Smoke CT depuis T spawn | setpos -456 -2288 -163; setang -39 57; give weapon_smokegrenade | Jump throw - clic gauche
```

- Sans info, laisse le 4e champ vide : `... | commandes |  | facile`.
- Une catégorie vide se déclare avec `@cat | Nom`.
- Évite le caractère `;` dans l'info du chat (il est remplacé par une virgule).
- Les lignes commençant par `#` sont ignorées. Voir `maps_default/_exemple.txt`.
- `maps/_commun.txt` s'affiche dans toutes les maps.

### Gérer les stuffs et les catégories

L'entrée « Gérer les stuffs et les catégories » ouvre une fenêtre redimensionnable (elle se rouvre à la taille et à la place où tu l'as laissée) :

- **Catégories** (à gauche) : créer, renommer, supprimer, verrouiller, ranger dans l'ordre voulu avec les boutons ▲ et ▼ (l'ordre est aussi celui du menu en jeu).
- **Séparateur** : le bouton « Séparateur » ajoute une ligne de séparation (texte au choix, ou `-` pour une simple ligne) dans la liste des catégories du menu. Elle est sautée quand on défile, on ne peut pas y entrer ni y ranger de stuff. Elle arrive en bas : place-la avec ▲ et ▼ (supprime-la ou renomme-la comme une catégorie).
- **Stuffs** (à droite) : recherche par nom ou info, colonne du temps de vol, tri par clic sur un titre de colonne, boutons ▲ et ▼ pour ranger les stuffs dans la catégorie (recherche vidée), clic droit (modifier, renommer, info, cadenas, supprimer).
- **Modifier un stuff** : double-clic (ou « Modifier… ») pour changer le type, la catégorie, le nom, le message, les **coordonnées** et les autres commandes. « Recapturer ma position actuelle » reprend ta position en jeu.
- **Déplacer vers** : choisis une catégorie (ou tape un nouveau nom) puis « Déplacer ». Sélection multiple avec `Ctrl` ou `Maj`.
- La liste « Map » permet de choisir la map, ou « Communs (toutes les maps) » pour gérer `maps/_commun.txt`.

**Supprimer une catégorie ne supprime pas ses stuffs** : ils vont dans « Non classés ». Les éléments verrouillés ne peuvent être ni supprimés, ni renommés, ni déplacés.

### Dernier lancer en stuff

L'entrée « Enregistrer le dernier lancer comme stuff » reprend, pour la dernière grenade lancée au clic, ta position, ton angle et le temps mesuré par le chronomètre. La fenêtre de sauvegarde s'ouvre déjà remplie (position, type de grenade, temps de vol ; la case « give » reste décochée, à toi de la cocher) : il suffit de choisir la catégorie et le nom. Le chronomètre doit être actif. Les relances avec la touche de relance (K par défaut) relancent la même trajectoire et mettent à jour son temps. La capture ne se prend pas toute seule dans ce cas (tu n'es plus à la position du lancer) : clique sur « Faire la capture (en jeu) » dans la fenêtre, tu es téléporté au stuff et la capture se fait.

### Cadenas

Un cadenas apparaît à la fin des catégories et des stuffs verrouillés. Un élément verrouillé ne peut pas être supprimé depuis le menu : `F3` le verrouille ou le déverrouille.

- Un **cadenas de catégorie** porte sur le nom de la catégorie, donc sur toutes les maps qui l'utilisent. Une catégorie qui contient un stuff verrouillé ne peut pas être supprimée.
- `Utilitaires` est verrouillée par défaut au premier lancement. Les verrous sont dans `data/locks.txt`.
- Si le cadenas s'affiche comme un carré, remplace `LOCK_ICON` en haut de `stuff_menu.ahk` par `"[L]"`.
- Un fichier `maps/*.txt` édité à la main n'est pas verrouillé.

### Captures d'écran des stuffs

Quand tu sauvegardes un stuff, le menu prend une petite capture (100 x 100 px par défaut) au centre du jeu, autour du réticule, et la propose dans la fenêtre. Dans le menu, la capture du stuff sélectionné s'affiche dans le coin supérieur droit. Pour la refaire : « Gérer les stuffs », double-clic sur le stuff, « Refaire la capture (en jeu) » (les fenêtres se ferment, tu es téléporté au stuff, la capture se fait 2 secondes plus tard, puis tout se rouvre). **Repère 2 (facultatif)** : pour un stuff qui demande un premier repère, un déplacement sans toucher à la souris, puis un second repère, ouvre « Modifier un stuff » > « Capturer le repère 2 (en jeu) » : tu es téléporté au stuff, tu as 12 secondes pour te placer sur le 2e repère, puis la capture se fait. Elle s'affiche à droite de la première (1 et 2) ; sans repère 2, rien ne change. Chaque capture est liée à la position **et** à l'angle du stuff. Les captures sont dans `data\shots\` (le repère 2 finit par `_r2`). Elles peuvent être jointes à un export vers un fichier `.stuffpack` (pas au code copié, trop lourd).

Le bouton **Nettoyer les captures et temps orphelins** (onglet Captures des réglages) supprime les captures et temps de vol qui ne correspondent plus à aucun stuff. Réglages : onglet Captures (zone, taille, placement, arrondi). Équivalents dans `config.ini` : `Shot`, `ShotSize`, `ShotZoom`, `ShotPos`, `ShotCorner`, `ShotX`, `ShotY`. Le jeu doit être en fenêtré ou en plein écran fenêtré.

### Quiz

« Quiz : choisir les stuffs et lancer » ouvre la page de départ du quiz pour la map détectée (hors Utilitaires) :

- **Aléatoire parmi tous les stuffs** de la map, ou **choix des stuffs à travailler** (cases à cocher, par catégorie ou tout d'un coup). Ta sélection est mémorisée par map.
- **Pas de répétition** (activé par défaut) : chaque stuff passe une seule fois avant de recommencer, et le premier d'un nouveau tour n'est jamais celui que tu viens de voir.

Tu es téléporté au départ du stuff avec la grenade, **sans la visée ni le message du chat**. Un bandeau en haut de l'écran donne le numéro, le nom et la catégorie. Pendant le quiz, quatre touches (actives seulement dans CS2) :

| Action | Effet |
|---|---|
| Suivant | stuff suivant (si tu es revenu en arrière, il rejoue d'abord les stuffs déjà vus) |
| Précédent | retour au stuff d'avant |
| Aide | affiche l'info du chat et le repère (la capture du stuff) |
| Zone d'aide | affiche un cercle à l'écran qui contient le repère sans être centré dessus ; chaque appui le rétrécit (3 niveaux), le 4e le retire |
| Réponse | relance le stuff en entier, avec la visée et le message du chat |

Au **premier quiz**, une page te laisse choisir ces touches (clavier ou boutons de souris ; défauts : Page suivante, Page précédente, Début, Insert, Fin). Tu les changes ensuite dans « Réglages du menu » > onglet **Quiz**, avec « Pas de répétition » et l'affichage de la capture dans l'aide. Les touches du quiz laissent aussi leur effet au jeu : choisis-en que tu n'utilises pas en jeu. **Zone d'aide** : le menu lit ton pitch et ton yaw en continu et compare ta visée à celle du stuff. Le cercle bouge avec ta souris ; le repère est dedans, mais jamais au centre, et le décalage change à chaque stuff. S'il est hors de l'écran, un trait indique la direction. La position est approximative : « Ajustement du champ » (onglet Quiz) la calibre si le cercle semble trop large ou trop serré par rapport à ton écran.

**Pourcentage de réussite** : quand tu relâches le clic gauche (lancer), le menu compare ta visée à celle du stuff et affiche par exemple « Visée : 87 % (écart 0,7°) », avec ta moyenne sur la partie. 100 % jusqu'à 0,3° d'écart, puis ça baisse jusqu'à 0 % pour un écart supérieur à la valeur « Écart pour 0 % » (5° par défaut). La lecture a un léger retard : si tu bouges encore la souris juste après le lancer, le score peut être un peu faussé. Pas de score après « Réponse », puisque la visée est alors réglée par le menu.

« Quiz : arrêter » (menu principal) termine le quiz. Équivalents dans `config.ini` : `QuizKeyNext`, `QuizKeyPrev`, `QuizKeyHint`, `QuizKeyZone`, `QuizKeyAns`, `QuizNoRepeat`, `QuizHintShot`, `QuizMode`, `QuizZoneOn`, `QuizZoneSize`, `QuizFovPct`, `QuizScoreOn`, `QuizTol`.

## Chronomètre de grenade

Après chaque grenade (smoke, flash, HE, molotov, incendiaire, leurre), le menu affiche le temps entre le moment où tu la **lâches** et celui où elle **explose**, par exemple `Smoke : 2,9 s`. Le panneau reste affiché en permanence, même en alt-tab (« Chrono : -- » en attente) ; le résultat s'affiche le temps choisi, puis le panneau revient à l'attente.

- **Départ** : le relâchement du clic gauche, ou la touche de relance `sv_rethrow_last_grenade` (`K` par défaut ; elle se change dans Réglages > Binds). Chaque grenade en vol garde son propre départ.
- **Fin** : la ligne `threw smokegrenade [x y z]` écrite dans `console.log` à l'explosion. Le menu active tout seul le journal du serveur (`log on`, `mp_logdetail 3`), ce qui crée aussi des fichiers dans `game\csgo\logs\` ; pour l'éviter, désactive le chronomètre.
- **Chrono en direct** : le compteur tourne à l'écran dès le lâcher (type connu par la ligne `sv_throw_...`), puis s'arrête sur le temps final. Avec la touche de relance, il démarre avec le type de la dernière grenade vue.
- **Précision** : environ un dixième de seconde (lecture du fichier toutes les 50 ms).
- **Limite** : le menu ne sait pas quelle arme tu tiens ; un tir pendant que la grenade vole peut fausser le temps.
- **Réglages** (onglet Chrono) : activer (le panneau reste alors affiché en permanence), placement (par défaut à droite des coordonnées, ou libre), durée d'affichage du résultat, « Tester l'affichage ». L'apparence suit celle du menu. Équivalents : `TimerOn`, `TimerHideOut` (1 = masquer hors de CS2), `TimerAuto`, `TimerX`, `TimerY`, `TimerDur`.
- **Tester la mesure** : pendant 60 s, chaque grenade lancée est mesurée et le résultat s'affiche dans les réglages avec l'origine du départ, même si le chronomètre est désactivé.
- **Temps incorrect ?** Mets `TimerDebug=1` : les événements sont notés dans `data\timer_debug.txt`.

### Temps de vol d'un stuff

Le temps de vol d'un stuff peut être mémorisé et affiché dans le menu, sous l'info : `Temps de vol : 2,9 s`. C'est facultatif : tu peux répondre « Non », ne jamais mesurer, ou désactiver la proposition (`FlightAsk=0`, ou la case de l'onglet Chrono).

- **À la création** : après l'enregistrement d'un stuff de grenade, le menu propose de mesurer son temps. Si tu acceptes, tu es téléporté au repère avec la grenade, tu la lances et le menu mesure. **Tu valides** : « Oui » enregistre, « Non » te laisse refaire le lancer, « Annuler » abandonne. Au bout de 30 s sans explosion, le menu propose de réessayer.
- **Pour un stuff existant** : « Modifier le stuff », ligne « Temps de vol », **Mesurer...** ou **Supprimer**.
- Le temps est dans `data\times.txt`, lié à la position et à la visée du stuff : il suit le stuff quand tu le renommes ou le déplaces, et disparaît si tu changes la position ou la visée. Il est inclus dans les exports (sauf si tu décoches « Importer les temps de vol » à l'import ; un temps déjà mesuré n'est écrasé que si tu choisis « Remplacer le mien »).

## Partage

### Profils et partage

« Profils et partage de stuffs » ouvre une fenêtre à trois onglets : Profils, Partager des stuffs, Sauvegardes.

- **Profils** : plusieurs jeux complets de stuffs (par exemple « Principal », « Stuffs de Léo », « Equipe »). Le profil Principal utilise `maps\` et `data\` ; les autres sont dans `profiles\<nom>\`. « Activer » recharge le menu avec le profil choisi. Chaque profil a ses stuffs, favoris, récents et cadenas.
- **Cocher une map** : choisis la map dans la liste « Map » puis « Cocher uniquement les stuffs de cette map » : tous ses stuffs sont cochés (le reste décoché), il ne reste qu'à exporter.
- **Un pack par map** : le bouton « Un pack par map… » crée d'un coup un fichier `.stuffpack` par map (ex. `de_ancient.stuffpack`) dans un dossier au choix, pour les stuffs cochés ou, si rien n'est coché, pour tous (utile pour publier des packs).
- **Exporter** : coche les stuffs à partager, puis « Exporter vers un fichier… » (`.stuffpack`) ou « Copier le code » (texte à coller dans Discord, de préférence dans un bloc de code ; pour beaucoup de stuffs, envoie plutôt le fichier).
- **Importer** : « Importer un fichier… » ou « Importer depuis le presse-papiers ». Une fenêtre liste les stuffs reçus avec leur statut (Nouveau, Doublon, Identique). Tu coches ceux à garder, tu choisis le profil de destination et ce qu'il faut faire des doublons : ignorer, garder les deux (le nouveau est renommé) ou remplacer le tien.
- **Profil complet** : « Exporter le profil… » crée un `.zip` (maps, temps de vol, favoris, cadenas, captures, réglages sans les chemins de ce PC). « Importer un profil… » le recrée sur un autre PC ; un profil existant est sauvegardé avant d'être remplacé.
- **Sécurité** : l'import n'ajoute que ce que tu coches et ne supprime rien. Avant chaque import, le profil de destination est sauvegardé en entier (« Avant un import de profil » dans « Restaurer une sauvegarde », 5 gardées) et les fichiers touchés sont copiés dans `data\backup\`. Les stuffs contenant `quit`, `exec`, `bind`, `unbind`, `unbindall`, `alias`, `connect`, `disconnect`, `rcon`… sont refusés. Cadenas et favoris ne sont pas exportés.
- **Hauteur** : le pack contient le réglage `TpZOffset` de l'exportateur ; à l'import, les coordonnées sont ajustées pour que la hauteur reste correcte avec ton réglage.

### Packs de stuffs

Le bouton « Packs de stuffs » (launcher, ou « Profils et partage > Partager des stuffs ») liste les packs publiés dans le dossier `packs\` du dépôt GitHub. La liste affiche, pour chaque pack, son état (**Nouveau**, **Mis à jour** ou **Importé**), le nombre de stuffs, les maps et la date ; sa description apparaît quand tu le sélectionnes. Un point ● sur le bouton du launcher signale un pack nouveau ou mis à jour depuis ta dernière visite. Un clic sur « Importer ce pack » le télécharge et ouvre la fenêtre d'import habituelle (tu choisis quoi garder et où le ranger). Les joueurs ne peuvent que les importer.

**Publier un pack (propriétaire du dépôt)** :

1. Mets `PackAdmin=1` dans ton `config.ini`.
2. Exporte tes stuffs en `.stuffpack` (onglet Partager des stuffs).
3. Dans la fenêtre des packs, clique sur « Publier un pack (administrateur)... », choisis le fichier, un titre et une description. La première fois, choisis ton dossier Git (`PackRepoDir`). Le fichier est copié dans `packs\` et `packs\index.txt` est mis à jour (le dossier est créé si besoin).
4. `git add .`, `git commit -m "..."`, `git push`.

Format de `packs\index.txt` : une ligne par pack, `fichier.stuffpack | Titre | Description | version | date | nombre de stuffs | maps`. Le menu remplit tout seul les 4 derniers champs à la publication. Pour corriger un pack, republie un fichier du même nom : sa version augmente et tes amis le voient comme « Mis à jour ». Pour le retirer, supprime sa ligne et le fichier. Le dépôt doit être public.

## Réglages

« Réglages du menu » (dix onglets : Menu, Couleurs, Captures, Coords, Chrono, Fenêtres, Touches, Quiz, Binds, Aide) :

- Un voyant indique en direct si CS2 est connecté au menu (vert) ou non (rouge).
- Chaque position (menu, capture, coordonnées, chrono) a un bouton **Placer avec la souris** : tu cliques à l'endroit voulu à l'écran.
- « Réinitialiser » ne remet à zéro que l'onglet affiché.
- Les fenêtres du menu (réglages, quiz, gestion, packs, partage...) se rouvrent là où tu les as laissées ; la position est mémorisée dans `config.ini`, section `[WinPos]` (supprime la ligne d'une fenêtre pour la recentrer).

### Coordonnées en temps réel

Activées dans l'onglet **Coords** (pas de raccourci clavier) ; l'affichage reste actif à chaque lancement jusqu'à ce que tu le désactives. Par défaut dans le **coin inférieur gauche**, ou à la position X / Y de ton choix. Il affiche la map, ta position (X, Y, Z) et ton angle (pitch, yaw), mis à jour plusieurs fois par seconde, avec l'apparence du menu.

Le menu demande `getpos` au jeu par la connexion directe et lit la réponse dans `console.log` ; il ne lit pas la mémoire du jeu. La fréquence se règle avec `HudInterval` (120 ms par défaut, minimum 60 ms). L'affichage reste actualisé quand le menu en jeu est ouvert ; il se met en pause quand une fenêtre (réglages, gestion...) est ouverte, ou quand CS2 n'est pas la fenêtre active.

### Touches à l'écran

« Réglages du menu » > onglet **Touches** : un petit overlay affiche en direct les touches pressées (Maj, Ctrl, Espace, **Z Q S D** et les clics de la souris), affiché en permanence, même en alt-tab (comme les coordonnées). Les touches s'allument à la couleur d'accent des fenêtres. Réglages : activer, taille, opacité, position (à droite au milieu de l'écran par défaut, ou libre avec « Placer avec la souris »). Il suit les couleurs, la police, les coins et le liseré du menu. Équivalents dans `config.ini` : `KeysOn` (désactivé par défaut), `KeysHideOut` (1 = masquer hors de CS2), `KeysSize`, `KeysOpacity`, `KeysAuto`, `KeysX`, `KeysY`. Il lit seulement l'état des touches de Windows (rien n'est lu dans le jeu). L'overlay **reprend tes touches de CS2** (fichier `cs2_user_keys_0_slot0.vcfg` de ton dossier Steam `userdata`) : déplacement, marche, accroupi, saut et tir. Par exemple, avec la marche sur MOUSE4, la case de gauche affiche « SOURIS 4 » et s'allume quand tu appuies sur ce bouton. Si tu changes tes touches dans CS2, clique sur « Relire les touches ». Décoche « Utiliser les touches de CS2 » (`KeysFromGame=0`) pour garder les touches par défaut (Maj, Ctrl, Espace, ZQSD). CS2 note les touches par leur position sur le clavier : le menu suit cette position, donc avec un clavier AZERTY les cases affichent Z, Q, S, D (et W, A, S, D avec un QWERTY). Les changements de l'onglet s'appliquent tout de suite.

### Touches d'entraînement (Binds)

Onglet **Binds** : le menu lie pour toi quatre actions à des touches de CS2. Par défaut : `K` relancer la dernière grenade (`sv_rethrow_last_grenade`), `N` noclip, `L` effacer les smokes, `P` kit d'armes et de grenades. Clique sur une action, puis appuie sur la touche voulue (lettre, chiffre, F1 à F12, Espace, Tab ou bouton de souris) ; « Aucune » retire la touche, « Touches par défaut » remet les quatre. Deux actions ne peuvent pas avoir la même touche. Le changement est envoyé tout de suite à CS2 s'il est connecté, puis à chaque exec du cfg d'entraînement ; l'ancienne touche est déliée. La touche de relance sert aussi au chronomètre (il démarre quand tu l'appuies). Les touches sont repérées par leur position, comme dans CS2 : avec un clavier AZERTY, la touche affichée est celle qui est écrite sur ton clavier. Équivalents dans `config.ini` : `RethrowKey`, `BindNoclip`, `BindKill`, `BindGive` (noms de touches CS2 : `k`, `f5`, `space`, `mouse4`… ; vide = aucune).

### Style des fenêtres

Onglet **Fenêtres** : thème sombre (par défaut), clair ou « comme le menu en jeu », couleur d'accent, police et taille du texte (90 à 120 %). Chaque changement ouvre une fenêtre d'aperçu et s'applique à la prochaine ouverture d'une fenêtre. Équivalents dans `config.ini` : `WinTheme` (`dark`, `light`, `menu`), `WinAccent`, `WinFont`, `WinScale`. Les boîtes de message de Windows gardent le style de Windows. Si les fenêtres sont illisibles chez toi, mets `WinTheme=light`.

### Sons du menu

Réglages > onglet **Menu** : « Petits sons dans le menu » joue une note très douce quand tu défiles, quand tu avances ou valides, et quand tu recules. Les sons sont générés par le menu (aucun fichier), activés par défaut à 25 % de volume. Équivalents dans `config.ini` : `MenuSound`, `MenuSoundVol` (10 à 100).

### Thèmes et police

La liste **Thème** (onglet Menu) applique en un clic une palette complète (fond, titre, nom de map, textes) :

| Thème | Ambiance |
| --- | --- |
| Graphite et Or | anthracite, accents or doux |
| Encre et Glace | bleu nuit, titre bleu glacier |
| Forêt et Sauge | vert très sombre, titre sauge |
| Bordeaux et Crème | bordeaux presque noir, titre rose ancien |
| Ardoise et Lavande | ardoise bleutée, titre lavande |
| Papier et Encre | fond crème clair, titre bleu acier |

Si tu modifies ensuite le fond, le menu repasse en « Personnalisé » avec des couleurs de texte automatiques. Le menu a des coins arrondis et un liseré dont tu règles l'épaisseur et la couleur (liste ou code hexadécimal) ; dans `config.ini`, section `[Overlay]` : `Corner=14` (`0` = coins carrés) et `Border=2` (`0` = aucun). La liste **Police** ne propose que les polices installées sur ton PC. Le thème est enregistré dans `Theme=`.

## Maintenance

### Sauvegardes et annulation

- **Manuelle** : bouton « Sauvegarder maintenant » du launcher (les 10 dernières sont gardées).
- **Automatique** : une fois par jour au lancement, tes maps (de chaque profil) sont copiées dans `data\backup\auto\AAAA-MM-JJ\`. Les 14 dernières sont conservées (`BackupKeep`, `AutoBackup=0` pour désactiver). Une copie est aussi faite avant chaque mise à jour (les 5 dernières sont gardées).
- **Restaurer** : « Profils et partage de stuffs » > Sauvegardes > « Restaurer une sauvegarde… ». Les sauvegardes sont décrites en clair (« Avant la mise à jour 2.22.0, le 15/11/2026 à 09 h 18 »). Ton état actuel est sauvegardé juste avant (« Avant une restauration »).
- **Annuler une suppression** : `Ctrl+Z` dans le menu ou dans la fenêtre de gestion. Les 50 derniers stuffs supprimés sont mémorisés dans `data\deleted.txt` (favori et cadenas non restaurés).

### Vérification de l'installation

Après « Lancer CS2 », ou avec le bouton « Vérification » du launcher, une fenêtre contrôle ce qui peut l'être sans CS2 : Steam, dossier cfg, `cs2_practice.cfg`, tes maps, droits d'écriture, `console.log`. Chaque ligne est notée ✔, ⚠ ou ✘ avec la solution.

Dès que CS2 est au premier plan dans une map locale, le menu teste la connexion directe, l'envoi d'une commande (via `console.log`), les cheats et la détection de la map. S'il n'y a aucun problème, la fenêtre se ferme toute seule (et confirme « Installation validée » la première fois).

- Relancer la vérification : « Relancer la vérification », ou « Vérifier l'installation » dans les réglages (onglet Aide).
- Demander de l'aide : « Créer un rapport... » ou [Signaler un problème](#signaler-un-problème).
- Désactiver : `AutoCheck=0` dans `config.ini`.

### Mise à jour

- **Automatique** : au lancement, le menu regarde s'il existe une version plus récente sur GitHub (le launcher l'indique aussi). Accepte et il redémarre tout seul. `AutoUpdate=0` désactive la vérification.
- **Sans le script** : ferme-le, puis double-clique sur `update.bat`.
- **Avec Git** : `git pull` dans le dossier.

`maps\`, `data\`, `profiles\` et `config.ini` ne sont jamais modifiés. L'ancien script est copié dans `data\backup\stuff_menu.ahk.bak`. Si `cs2_practice.cfg` change (voir le CHANGELOG), supprime l'ancienne copie du dossier cfg de CS2 : le menu en recopie une neuve au lancement.

Après une mise à jour, un point ● apparaît sur « Nouveautés » (rien ne s'ouvre tout seul). `ShowChangelog=0` le supprime ; avec `Launcher=0`, la fenêtre Nouveautés s'ouvre toute seule après chaque mise à jour.

### Retour à la version précédente

Si le menu rencontre deux erreurs dans les minutes qui suivent une mise à jour, il propose de revenir à la version précédente (tes stuffs ne sont pas touchés, la version abandonnée n'est plus proposée automatiquement). Le même retour est dans « Profils et partage > Sauvegardes ». Si le menu ne démarre plus du tout, double-clique sur `rollback.bat`. Les erreurs sont notées dans `data\menu_errors.log`.

### Signaler un problème

Le bouton « Signaler un problème » du launcher (ou « Créer un rapport » dans la vérification) affiche un rapport : version, Windows, état de l'installation, réglages, dernières erreurs et extraits utiles de `console.log`. Les chemins et le nom d'utilisateur Windows sont masqués. Copie-le ou enregistre-le dans `data\rapport_...txt` pour l'envoyer.

### Dépannage

- **Le menu n'apparaît pas** : vérifie que le script tourne et que CS2 est en mode fenêtré (plein écran fenêtré). Tu peux placer le menu sur un autre écran dans les réglages.
- **Les bots sont encore là / le cfg ne se lance pas** : vérifie `AutoExec=1` et que `cs2_practice.cfg` est dans le dossier cfg (Vérification), ou utilise « Relancer l'exec » du menu.
- **La map n'est pas détectée** : vérifie `-condebug` dans les options de lancement de CS2, ou règle `AutoDetectMap=0`.
- **« Pas de connexion à CS2 »** : CS2 n'a pas été lancé par le menu (ou sans `-netconport`). Ferme le jeu et relance-le avec « Lancer CS2 ». En ligne de commande : `netstat -ano | findstr 2121` doit afficher `LISTENING` quand le jeu tourne.
- **CS2 ne se lance pas depuis le menu** : vérifie que Steam est installé et connecté. En dernier recours, ajoute `-condebug -netconport 2121 -insecure` dans les options de lancement de Steam et lance le jeu toi-même.
- **God mode : ma vie descend puis remonte** : c'est normal, le God mode active la régénération de vie (`sv_regeneration_force_on`) sans `buddha`, pour éviter la croix rouge à l'écran. Un très gros dégât d'un coup peut quand même te tuer.
- **TP, give, God mode ou bot ne marchent plus** : ces commandes exigent `sv_cheats 1` (envoyé avant chaque commande). Vérifie que tu es dans une partie locale. Test : tape `setpos 0 0 0` dans la console.
- **Rien ne se passe au choix d'un stuff** : même vérification (partie locale, connexion directe active).
- **Des armes changent toutes seules** : d'anciennes versions liaient des touches du pavé numérique ; le menu les retire de `cs2_practice.cfg` au lancement. Relance CS2 depuis le menu et vérifie qu'aucun logiciel (Discord, clavier, souris) ne répète une touche.
- **console.log devient énorme** : au lancement, si le jeu est fermé et que le fichier dépasse `LogMaxMB` (10 Mo, `0` pour désactiver), il est vidé.
- **Suppression par erreur** : `Ctrl+Z`, ou récupère le fichier dans `data/backup/`.

## Structure du dossier

```
stuff_menu.ahk        script principal
menu_stuf.ico         icône du menu et des raccourcis
install.bat / .ps1    installateur (dossier au choix, raccourcis, reprise de l'ancienne installation)
uninstall.bat / .ps1  retire les raccourcis (tes stuffs sont conservés)
update.bat / .ps1     mise à jour sans lancer le script
rollback.bat          retour à la version précédente du script
tags_officiels.txt   liste officielle des tags (identique pour tout le monde, mise à jour avec le menu)
cs2_practice.cfg      réglages d'entraînement (copié dans le cfg de CS2 au premier lancement)
config.example.ini    modèle de configuration (copié en config.ini)
maps_default/         modèles de maps vides (copiés dans maps/ au premier lancement)
packs/                packs de stuffs publiés (index.txt), lus par le menu depuis GitHub
maps/                 tes stuffs : un fichier .txt par map + _commun.txt (non versionné)
data/                 favoris, récents, captures, temps de vol, sauvegardes, journaux (non versionné)
profiles/             autres profils de stuffs (non versionné)
config.ini            tes réglages (non versionné)
```

Le dépôt ne contient aucun stuff personnel : `maps\`, `data\`, `profiles\` et `config.ini` sont exclus de git, donc jamais envoyés sur GitHub, même avec `git add .`, et une mise à jour ne les écrase pas.

## Contribuer

Pour partager des lineups, propose un pack (`.stuffpack`) au propriétaire du dépôt : il le publie dans `packs\`. Les pull requests sur le script sont les bienvenues.

## Licence

[MIT](LICENSE)
