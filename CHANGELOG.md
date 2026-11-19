# Changelog

## v2.33.6

- Correction d'une erreur à l'ouverture de « Gestion des stuffs et des catégories » introduite en 2.33.5 (surveillance du déplacement des colonnes).

## v2.33.5

- Fenêtre « Gestion des stuffs et des catégories » : la dernière colonne de chaque liste prend toute la largeur restante (plus de zone vide ni de bande bleue à droite), y compris après avoir agrandi une colonne ou la fenêtre. Les listes sont dessinées sans traces quand on déplace le bord d'une colonne.

## v2.33.4

- « Refaire la capture » d'un stuff : le menu ferme les fenêtres et les affichages (coordonnées, touches, chrono, overlay), te téléporte à la position du stuff, prend la capture au centre du jeu puis rouvre tout comme avant. Il n'y a plus de compte à rebours pour viser : l'angle du stuff est appliqué par la téléportation.

## v2.33.3

- Journal d'erreurs (`data\menu_errors.log`) plus précis : il note maintenant la fonction concernée et l'endroit de l'appel en plus du message et de la ligne. Le rapport de diagnostic (« Aide ») reprend ces détails.

## v2.33.2

- Nettoyage du code : suppression de variables et fonctions devenues inutiles (anciens contrôles du menu, liserés et textes remplacés par le dessin lissé, réglage et variable de bip du chrono, aide texte du bas du menu, arrêt de GDI+). Aucun changement de comportement.
- `config.example.ini` : retrait de `TimerBeep`. README : mention de la mémorisation des positions de fenêtres.

## v2.33.1

- Sons du menu : activés par défaut, volume à 25 %. Si tu avais déjà réglé les sons dans les réglages, ton choix est conservé.

## v2.33.0

- Petits sons très doux dans le menu en jeu : un pour défiler, un pour avancer / valider, un pour reculer. Générés par le menu (aucun fichier), désactivés par défaut. Case « Petits sons dans le menu » et volume dans Réglages > Menu.

## v2.32.1

- Score du quiz : 100 % jusqu'à 0,3° d'écart, puis dégressif jusqu'à 0 % à l'écart réglé.
- Zone d'aide beaucoup plus fluide : lecture de la visée 25 fois par seconde, mouvement estimé entre deux lectures, cercle déplacé ~60 fois par seconde sans être redessiné et lissé.
- Aide du quiz : la capture est aussi cherchée par position si elle est enregistrée sous un autre nom de map, et le bandeau indique « pas de capture pour ce stuff » quand il n'y en a pas.

## v2.32.0

- **Zone d'aide du quiz** : une touche (Insert par défaut) affiche un cercle à l'écran qui contient le repère sans le centrer dessus. Le menu lit ton pitch et ton yaw en continu ; le cercle suit ta souris. Trois niveaux (de plus en plus petit), puis la zone disparaît. Hors écran, un trait indique la direction.
- **Pourcentage de réussite** : au lancer (clic gauche relâché), ta visée est comparée à celle du stuff. Le bandeau affiche le pourcentage, l'écart en degrés et ta moyenne sur la partie.
- Onglet Quiz : zone d'aide (activer, taille, ajustement du champ), score (activer, écart pour 0 %) et la nouvelle touche Zone.

## v2.31.5

- Les fenêtres du menu (réglages, quiz, gestion, packs, partage...) se rouvrent à l'endroit où tu les as laissées. La position est mémorisée par fenêtre dans `config.ini` (section `WinPos`) ; elle est recadrée si l'écran a changé.

## v2.31.4

- Coordonnées plus fluides : elles se mettent à jour toutes les 120 ms au lieu de 300 ms (minimum réglable : 60 ms). L'ancienne valeur par défaut de `config.ini` est remplacée automatiquement, une seule fois. Si tu avais choisi une autre valeur, elle est conservée.

## v2.31.3

- Chrono : la position par défaut est maintenant à droite des coordonnées (avant : au-dessus), centrée sur leur hauteur.

## v2.31.2

- Quiz : la liste des stuffs était illisible (grisée sur fond blanc) en mode « Aléatoire ». Elle reste lisible en permanence ; cocher un stuff ou un bouton de sélection passe tout seul en mode « Choisir les stuffs ».

## v2.31.1

- Coordonnées : elles continuent de se mettre à jour quand le menu en jeu (F1) est ouvert.

## v2.31.0

- **Quiz refait** : « Quiz : choisir les stuffs et lancer » ouvre une page de départ. Tu choisis soit tous les stuffs de la map au hasard, soit les stuffs à travailler (cases à cocher, par catégorie). La sélection est mémorisée par map.
- Option « Pas de répétition » (par défaut) : chaque stuff une seule fois avant de recommencer, sans retomber sur le même deux fois de suite.
- Quatre touches pendant le quiz, actives dans CS2 : **suivant**, **précédent** (retour au stuff d'avant), **aide** (info du chat + capture du stuff comme repère) et **réponse**. Le menu principal propose aussi ces actions et « Quiz : arrêter ».
- Au premier quiz, une page te laisse choisir tes touches (clavier ou boutons de souris).
- Nouvel onglet **Quiz** dans « Réglages du menu » : touches, pas de répétition, capture dans l'aide.
- Le bandeau du quiz affiche le numéro du stuff, et l'info du chat quand tu demandes l'aide.

## v2.30.0

- Touches à l'écran et chrono : nouvelle case « Masquer quand CS2 n'est pas au premier plan (alt-tab) » (onglets Touches et Chrono). Par défaut, ils restent affichés en permanence.
- Affichage plus léger : les polices et formats de texte sont gardés en mémoire au lieu d'être recréés à chaque dessin, et GDI+ n'est plus arrêté puis relancé quand on coupe les touches.
- Mise à jour : seuls les fichiers qui ont changé sont réécrits (le téléchargement de l'archive reste complet).
- Packs : une mise à jour d'un pack déjà importé passe par la même sauvegarde complète du profil que tout import (déjà le cas).

## v2.29.12

- God mode : « activer » envoie `sv_regeneration_force_on 1; buddha 1` et « désactiver » envoie `sv_regeneration_force_on 0; buddha 0`. Les lignes précédentes sont remplacées automatiquement.

## v2.29.11

- Correction : le menu ne démarrait plus (accolade en trop dans le code du God mode de la 2.29.10).

## v2.29.10

- God mode : `god` n'existe plus dans CS2. Les entrées utilisent maintenant `buddha` : « activer » (`buddha 1; buddha_ignore_bots 1`, tu ne meurs plus mais les bots peuvent mourir) et « désactiver » (`buddha 0`). Les lignes de la 2.29.8 sont remplacées automatiquement.

## v2.29.9

- « Changer de map » : une fois la nouvelle map chargée, le menu exécute le cfg d'entraînement puis redémarre le round, comme au lancement automatique (plus besoin de le faire à la main).

## v2.29.8

- God mode : l'ancienne commande `god` seule est une bascule qui se désynchronise (bloqué en god, ou impossible à activer). Deux entrées fiables la remplacent : « God mode - activer » (`god 1; buddha 1`) et « God mode - désactiver » (`god 0; buddha 0`). L'ancienne ligne est remplacée automatiquement une fois dans les utilitaires de chaque profil.

## v2.29.7

- Touches à l'écran : le liseré du menu (couleur et épaisseur des réglages) entoure aussi l'overlay. Position par défaut : à droite, au milieu de l'écran.

## v2.29.6

- Chronomètre de grenade : il reste affiché en permanence (« Chrono : -- » en attente), même en alt-tab, comme les coordonnées. Le résultat s'affiche le temps réglé puis le panneau revient à l'attente. Pour le retirer : décocher l'option dans Réglages > Chrono.

## v2.29.5

- Touches à l'écran : l'overlay reste affiché en permanence, même en alt-tab, comme les coordonnées.

## v2.29.4

- Menu en jeu : rappel des touches du bas réorganisé (favori, cadenas et nouveau stuff chacun sur sa ligne) et phrase « Sauvegarde, réglages... » supprimée.

## v2.29.3

- Réglages > Chrono : la case « Bip » (inutile depuis la suppression des sons) ne chevauche plus les boutons « Tester ».

## v2.29.2

- Menu en jeu : le rappel des touches en jaune (doublon du bas) est supprimé. La hauteur du menu s'adapte au contenu : plus de grand vide en bas, les infos et messages n'occupent de la place que quand il y en a.

## v2.29.1

- Correction : le menu ne démarrait plus (erreur « This Class cannot be used as an output variable » ligne 215). Un nom de classe entrait en conflit avec une variable.

## v2.29.0

- Nouveau design lissé pour tout l'affichage en jeu : menu, coordonnées, chronomètre, quiz et capture du stuff. Même style que les touches à l'écran : fond arrondi, lignes en cases arrondies, ligne choisie mise en valeur avec un repère, liseré et textes sans effet d'escalier.
- Les réglages (thème, police, taille, opacité, coins, liseré) s'appliquent toujours.

## v2.28.9

- Map automatique : après l'exec du cfg d'entraînement, le round est redémarré (`mp_restartgame 1`) pour que l'argent, les bots et les réglages soient bien pris en compte au départ. Le troisième passage de la 2.28.8 est retiré.

## v2.28.8

- Map automatique : le cfg d'entraînement attend 5 s après la détection de la map (au lieu de 3 s), puis est renvoyé 6 s et 16 s plus tard, au cas où le mode de jeu remette ses réglages après le chargement.

## v2.28.7

- Touches à l'écran : dessin lissé (GDI+). Les bords arrondis, les cases et les textes n'ont plus d'effet d'escalier, et la transparence est calculée pixel par pixel (coins du fond parfaitement arrondis).

## v2.28.6

- Touches à l'écran : les cases sont maintenant dessinées comme des images (rectangles arrondis) avec la couleur exacte du fond dans les coins. Plus de coins bleus, et les cases réagissent dès la première pression.

## v2.28.5

- Touches à l'écran : l'arrondi des cases est appliqué directement à chaque case (il ne marchait pas bien avant).

## v2.28.4

- Touches à l'écran : les cases ont maintenant des coins arrondis.

## v2.28.3

- **Touches à l'écran** : correction pour les claviers AZERTY. CS2 note ses touches par position (W, A...) : l'overlay suit maintenant la position des touches et affiche les lettres de ton clavier (Z, Q, S, D). Avant, il surveillait les mauvaises touches.
- Les réglages de l'overlay quittent le menu en jeu et passent dans un nouvel onglet **Touches** des réglages du menu. Les onglets sont un peu plus larges.

## v2.28.2

- Map automatique : le deuxième essai ne se produit plus qu'après 60 s et seulement si aucune map n'est chargée (il pouvait relancer la map pendant son chargement et annuler le cfg d'entraînement). Le cfg est exécuté une fois la map prête, puis une seconde fois quelques secondes plus tard avec `bot_quota 0` et `bot_kick` pour retirer les bots.
- Les étapes sont notées dans `data\auto_debug.txt` (et dans le rapport « Signaler un problème ») pour comprendre ce qui se passe.

## v2.28.1

- **Touches à l'écran** : l'overlay lit maintenant les touches enregistrées dans CS2 (déplacement, marche, accroupi, saut, tir). Si ta marche est sur MOUSE4, la case affiche « SOURIS 4 » et s'allume avec ce bouton. Case « Utiliser les touches de CS2 » et bouton « Relire les touches » dans le réglage (`KeysFromGame=0` pour revenir aux touches par défaut).

## v2.28.0

- **Touches à l'écran** : petit overlay qui affiche en direct les touches pressées (Maj, Ctrl, Espace, **Z Q S D** au clavier AZERTY, clics de la souris), par-dessus CS2 et seulement quand le jeu est au premier plan. Menu principal > « Touches à l'écran » : activer, taille, opacité, position (coin inférieur droit ou libre avec la souris). Désactivé par défaut (`KeysOn=1` pour l'activer).

## v2.27.0

- **Packs : aperçu avant import** : la liste affiche le nombre de stuffs, les maps et la date de mise à jour de chaque pack, et sa description quand tu le sélectionnes.
- **Packs : versions** : un pack republié passe à la version suivante. La liste indique « Nouveau », « Mis à jour » ou « Importé » selon ce que tu as déjà importé.
- **Packs : point ●** sur le bouton « Packs de stuffs » du launcher quand un pack est nouveau ou mis à jour depuis ta dernière visite.
- **Sauvegarde avant import** : avant chaque import de stuffs (fichier, code ou pack), une sauvegarde complète du profil de destination est faite (« Avant un import de profil » dans « Restaurer une sauvegarde », les 5 dernières sont gardées).

## v2.26.6

- Version de test de la mise à jour automatique (aucun changement).

## v2.26.5

- Launcher : bouton « Vérifier les mises à jour » (propose l'installation si une version plus récente existe, sinon confirme que tu es à jour).

## v2.26.4

- Après un redémarrage du menu (mise à jour, retour à la version précédente, changement de touche), le launcher se rouvre tout seul. Le jeu n'est pas relancé.

## v2.26.3

- Plus aucun son : le bip d'anticipation du chronomètre est retiré (la case de l'onglet Chrono disparaît).

## v2.26.2

- Plus de bip à l'explosion de la grenade. Seul le bip d'anticipation (0,5 s avant, quand le temps de vol du stuff est connu) reste ; `TimerBeep=0` le coupe aussi.

## v2.26.1

- Correction : avec la map automatique, le cfg d'entraînement (bots, argent, cheats...) n'était pas exécuté tant que tu n'ouvrais pas le menu. Il s'exécute maintenant tout seul dès que la map est chargée (`AutoExec=0` pour l'éviter).

## v2.26.0

- **Map d'entraînement automatique** : après « Lancer CS2 », le menu charge tout seul une map (la dernière jouée, ou de_dust2 la première fois). Le choix se fait dans le launcher (« Map au lancement » : dernière map, une map précise ou aucune). `AutoMap` et `AutoMapDelay` dans `config.ini`.
- **Launcher** : indique si le menu est à jour (clic pour installer une nouvelle version), bouton « Sauvegarder maintenant » (copie manuelle de tes stuffs, favoris et temps de vol), « Packs de stuffs », « Guide de démarrage » et « Signaler un problème ».
- **Guide de démarrage** : s'affiche à la première utilisation (3 étapes : lancer CS2, ouvrir le menu, récupérer des stuffs). Le bouton du launcher le rouvre.
- **Packs de stuffs** : packs publiés par ProToxEU sur GitHub, importables en un clic (tu choisis quoi garder). Seul le propriétaire du dépôt peut en publier.
- **Signaler un problème** : crée un rapport (version, état de l'installation, réglages, dernières erreurs) sans chemin ni nom personnel, à copier ou enregistrer.
- **Vérification** : contrôle aussi la présence de Steam, affiche le nombre de points à corriger et confirme « Installation validée » la première fois.
- **Retour à la version précédente** : si le menu rencontre deux erreurs après une mise à jour, il propose de revenir à la version d'avant. Aussi disponible dans « Profils et partage > Sauvegardes ». `rollback.bat` fait la même chose si le menu ne démarre plus.
- Sauvegardes manuelles listées dans « Restaurer une sauvegarde ».

## v2.25.5

- La vérification de l'installation s'ouvre de nouveau toute seule, 1,5 s après « Lancer CS2 » (comme avant), mais à côté du launcher et non plus par-dessus. La fenêtre Nouveautés ne s'ouvre pas toute seule (point ● sur le bouton du launcher).

## v2.25.4

- Plus de fenêtre « Vérification de l'installation » ni « Nouveautés » qui s'ouvre toute seule au démarrage : elles s'ouvrent avec leurs boutons du launcher. Un point ● sur « Nouveautés » signale une nouvelle version.

## v2.25.3

- Correction : fermer les réglages (ou une autre fenêtre) quand CS2 n'est pas lancé provoquait l'erreur « Target window not found ». Désormais sans effet si le jeu est fermé.

## v2.25.2

- **Installateur** : il cherche ton ancienne installation et te propose de reprendre tes stuffs, favoris, temps de vol, profils et réglages dans le nouveau dossier. L'ancien dossier n'est jamais modifié ni supprimé. Un dossier qui contient déjà des stuffs n'est jamais écrasé.

## v2.25.1

- `build_exe.bat` retiré : le raccourci créé par l'installateur suffit (même icône, mises à jour automatiques).

## v2.25.0

- **Installateur** : `install.bat` copie le menu dans le dossier de ton choix (refuse `C:\Program Files`), installe AutoHotkey v2 si besoin et crée un raccourci « Menu Stuf » avec icône sur le bureau et dans le menu Démarrer. `uninstall.bat` retire les raccourcis.
- **Launcher** : fenêtre d'accueil avec « Lancer CS2 », « Nouveautés », « Vérification », « Réglages », « Ouvrir le dossier » et un voyant d'état de CS2. Fermer la fenêtre laisse le menu actif ; l'icône près de l'horloge la rouvre. `Launcher=0` rétablit l'ancien démarrage.
- **Icône** : nouvelle icône du menu (raccourci, barre des tâches, icône près de l'horloge).
- Le menu ne lance plus CS2 tout seul au démarrage tant que le launcher est actif : clique sur « Lancer CS2 ».

## v2.24.2

- Sauvegarde et modification d'un stuff : le champ des tags prend toute la largeur, les boutons « Ajouter », « Retirer » et « → Info » sont dessous.

## v2.24.1

- Correction du thème sombre : les listes déroulantes modifiables (par exemple « Catégorie ») avaient un fond blanc avec un texte clair, donc illisible. Fond et texte sont maintenant sombres. Si une liste reste blanche, choisis le thème « Clair » dans l'onglet Fenêtres des réglages (ou `WinTheme=light` dans `config.ini`).

## v2.24.0

- **Dernier lancer en stuff** : nouvelle entrée « Enregistrer le dernier lancer comme stuff ». Position, angle, type de grenade et temps de vol du dernier lancer au clic sont déjà remplis dans la fenêtre de sauvegarde (chronomètre actif requis).
- **Tester la mesure** : bouton dans l'onglet Chrono des réglages, qui affiche le temps lu et d'où part le chrono.
- **Aperçu du style** : l'onglet Fenêtres ouvre un aperçu en direct à chaque changement.
- **Boutons alignés** : bouton principal à droite, secondaires à gauche, dans toutes les fenêtres.
- **Sauvegarder la position** : zone « Détails : position » repliable, nom déjà pris signalé en rouge sous le champ (aussi dans « Modifier le stuff »).
- **Fenêtre de gestion** : taille et position mémorisées.
- **Nouveautés** : titres de version en gras et en couleur d'accent.

## v2.23.0

- **Fenêtres plus modernes** : thème sombre par défaut sur toutes les fenêtres du menu (barre de titre, listes, champs, boutons), onglets plats avec une couleur d'accent à la place des onglets Windows.
- **Nouvel onglet « Fenêtres »** dans les réglages : thème (sombre, clair, comme le menu en jeu), couleur d'accent, police et taille du texte. Appliqué à la prochaine ouverture d'une fenêtre.
- En cas de souci d'affichage : `WinTheme=light` dans `config.ini` remet un style clair.

## v2.22.1

- Correction : la fenêtre « Gérer les stuffs et les catégories » ne s'ouvrait plus (erreur « Gui.Edit has no method named SetCue »). Si tu es sur la 2.22.0, mets à jour : l'ancienne version peut quand même télécharger la mise à jour.

## v2.22.0

- **Réglages** : six onglets (Menu, Couleurs, Captures, Coords, Chrono, Aide), fenêtre plus courte. Bouton « Placer avec la souris » pour chaque position, « Réinitialiser » limité à l'onglet affiché. « Vérifier l'installation », le diagnostic et le nettoyage sont dans l'onglet Aide.
- **Gestion des stuffs** : recherche, colonne du temps de vol, clic droit, fenêtre redimensionnable.
- **Profils et partage** : trois onglets (Profils, Partager des stuffs, Sauvegardes) et compteur de stuffs cochés.
- **Restaurer une sauvegarde** : descriptions en clair (type et date).
- **Menu principal** : blocs séparés, « voir la réponse » du quiz affiché seulement pendant un quiz, entrée « Fermer » retirée (Échap suffit).
- **Sauvegarde et modification d'un stuff** : boutons de tags « Ajouter » / « Retirer » et « Nouvelle » (catégorie) plus clairs, temps de vol juste sous le nom, titre harmonisé.
- **Vérification de l'installation** : boutons pour copier `cs2_practice.cfg` et ouvrir le dossier cfg.
- **Changer de map** : la map détectée en dernier est présélectionnée.

## v2.21.0

- **Changer de map** : nouvelle entrée « Changer de map » dans le menu principal. Liste de tes maps et des maps de compétition, ou nom saisi à la main ; le menu envoie `map <nom>` au jeu et l'exec du cfg d'entraînement se relance tout seul sur la nouvelle map.

## v2.20.0

- **Bip du chrono** : un court bip retentit 0,5 s avant l'explosion prévue quand le temps de vol du stuff est connu, sinon à l'explosion. Réglable dans l'onglet Chronomètre (`TimerBeep`). Le compteur en direct démarre aussi avec la touche de relance.
- **Sauvegarde avant mise à jour** : maps, temps de vol, favoris et cadenas de chaque profil sont copiés dans `data\backup\auto\avant-maj-...` avant chaque mise à jour (5 gardées) et se restaurent avec « Restaurer une sauvegarde… ».
- **Voyant de connexion** : en bas de « Réglages du menu », un voyant vert ou rouge indique si CS2 est connecté, mis à jour en direct.
- **Profil complet en un fichier** : « Exporter le profil… » et « Importer un profil… » dans « Profils et partage » (stuffs, temps, favoris, cadenas, captures et réglages dans un `.zip`), pour changer de PC. Les commandes interdites sont ignorées à l'import.

## v2.19.1

- Chrono : correction du temps faux avec la touche de relance (`K`). Chaque grenade en vol a maintenant son propre départ : spammer `K` ou avoir plusieurs grenades en l'air n'additionne plus les temps, et la répétition automatique de la touche maintenue est ignorée.
- Nouveau réglage `TimerDebug=1` (dans `config.ini`) : écrit les événements du chrono dans `data\timer_debug.txt` (et dans le diagnostic) pour comprendre un temps incorrect.

## v2.19.0

- Nouveau : une fenêtre « Nouveautés » s'ouvre au démarrage après chaque mise à jour et liste les modifications des versions que tu n'avais pas encore vues.
- Tu peux la désactiver (case dans la fenêtre, ou `ShowChangelog=0`) et la rouvrir avec l'entrée « Nouveautés » du menu principal.

## v2.18.5

- Chrono : la touche de relance (`RethrowKey`, `k` par défaut) fait partir le chrono, car le jeu n'écrit pas toujours de ligne au lancer d'une relance. Le départ retenu est le plus récent entre cette touche, la ligne `sv_throw_...` du journal et le dernier clic relâché.
- Chrono : les noms de grenade sont reconnus plus largement (une flash n'est plus affichée « Grenade »).
- Quiz : le nom et la catégorie du stuff s'affichent dans un bandeau en haut de l'écran, jusqu'à « Quiz : voir la réponse » ou un nouveau quiz (l'infobulle de 7 secondes disparaissait trop vite).

## v2.18.4

- Correction : le script ne démarrait plus (« This Func cannot be used as an output variable : TmLiveStart ») à cause d'une variable du chrono en direct qui portait le même nom qu'une fonction. Si tu es sur une version 2.18.0 à 2.18.3, remplace `stuff_menu.ahk` à la main : l'ancien fichier ne peut pas lancer la mise à jour.

## v2.18.3

- **Noms uniques** : un nom de stuff ne peut exister qu'une fois par map (toutes catégories, « communs » compris) et un nom de catégorie qu'une fois, sans tenir compte des majuscules. Contrôle à la création, à la modification, au renommage, au déplacement et à l'import (un stuff importé qui porte le nom d'un stuff d'une autre catégorie est renommé « Nom (2) » ou ignoré selon le choix).
- Correction : l'aperçu de l'import ne repérait jamais les doublons (statut toujours « Nouveau »).

## v2.18.2

- Le temps de vol reste facultatif : case « Proposer de mesurer le temps de vol après la création d'un stuff » (onglet Chronomètre, clé `FlightAsk`), et bouton « Supprimer » pour retirer le temps d'un stuff dans « Modifier le stuff ».
- Import : case « Importer les temps de vol » dans la fenêtre d'import (cochée par défaut).

## v2.18.1

- Les temps de vol sont inclus dans les exports de stuffs (lignes `@TIME` du fichier ou du code) et repris à l'import, dans le profil de destination. Les anciennes versions ignorent ces lignes.

## v2.18.0

- **Temps de vol par stuff** : après la création d'un stuff de grenade, le menu propose de mesurer son temps de vol (téléportation au repère, lancer, mesure). Le joueur valide le temps (Oui / refaire / abandonner). Le bouton « Mesurer le temps de vol... » de la fenêtre « Modifier le stuff » le fait aussi pour les stuffs existants. Le temps s'affiche dans le menu (`Temps de vol : 2,9 s`) et est gardé dans `data\times.txt`.
- **Chrono en direct** : pour une relance (`sv_rethrow_last_grenade`), le compteur tourne jusqu'à l'explosion.
- **Quiz** : entrées « Quiz : stuff au hasard » (téléportation sans visée ni info du chat) et « Quiz : voir la réponse » dans le menu principal.
- **Diagnostic** : bouton « Copier le diagnostic » en bas des réglages.
- **console.log** : vidé au lancement du menu s'il dépasse `LogMaxMB` (10 Mo), quand CS2 est fermé.
- **Nettoyage** : bouton « Nettoyer les captures et temps orphelins » (onglet Captures).
- Menu principal : les entrées sont désormais gérées par identifiant (plus de numéros).

## v2.17.0

- **Chronomètre de grenade** : affiche le temps entre le lâcher (clic gauche relâché, ou relance `sv_throw_...`) et l'explosion lue dans `console.log` (`threw smokegrenade [...]`), pour la smoke, la flash, la HE, le molotov, l'incendiaire et le leurre.
- Nouvel onglet **Chronomètre** dans les réglages : activer, placement (par défaut juste au-dessus des coordonnées, ou libre), durée d'affichage, bouton de test. Même style que les coordonnées (police, couleurs, liseré, coins, opacité).
- Le menu active le journal du serveur (`log on`, `mp_logdetail 3`) quand le chronomètre est activé.
- Nouvelles clés `TimerOn`, `TimerAuto`, `TimerX`, `TimerY`, `TimerDur` dans `config.ini`.

## v2.16.0

- **Connexion directe obligatoire** : le menu n'utilise plus de touches ni de fichier `stuff_run.cfg` pour parler à CS2. Fini le sélecteur de touches, le bouton « Touches du script », `ExecKey`, `HudKey` et `ConsoleKey`.
- Le menu doit être lancé **avant** CS2 : il démarre le jeu avec `-condebug -netconport 2121 -insecure` (par `steam.exe -applaunch 730`). Si CS2 est déjà ouvert sans la connexion directe, il propose de le fermer et de le relancer. Une fenêtre d'information s'affiche au premier lancement (avertissement VAC).
- Nettoyage automatique des anciennes liaisons (`exec stuff_run`, `exec hud_pos`) dans `cs2_practice.cfg` et suppression de `stuff_run.cfg` / `hud_pos.cfg`.
- Les coordonnées en temps réel et l'exec automatique passent par la connexion directe.
- « Vérifier l'installation » : la connexion directe est maintenant un point obligatoire.
- README réécrit : seule l'option de lancement `-condebug` est à ajouter par le joueur, installation et dépannage mis à jour.
- Clé `LaunchCs2` supprimée.

## v2.15.4

- Lancement de CS2 : utilise `steam.exe -applaunch 730` avec les options (le lien `steam://rungameid` ne transmettait pas `-netconport` chez certains joueurs). Le lien reste en secours si Steam est introuvable.
- Après le lancement, le menu attend l'ouverture du port et prévient au bout de 2 minutes si le jeu n'a pas reçu les options.
- « Vérifier l'installation » réessaie la connexion sans attendre le délai de 5 secondes.

## v2.15.3

- Connexion directe : envoi immédiat des commandes (TCP_NODELAY). Corrige les petits retards ponctuels (téléportation, give du kit complet) causés par l'attente d'accusé de réception de TCP quand plusieurs commandes partent à la suite.

## v2.15.2

- Retour du lancement de CS2 par le menu (contenu de l'ancienne v2.15.0) : si le jeu est fermé au démarrage du script, le menu propose de le lancer avec `-condebug -netconport 2121 -insecure` par Steam, sans modifier les options de lancement du joueur.
- Clés `LaunchCs2` (0 jamais, 1 demander, 2 automatique) et `LaunchArgs` dans `config.ini`.

## v2.15.1

- Retour au contenu de la v2.14.2 : le lancement de CS2 par le menu (v2.15.0) est retiré. Numéro plus élevé pour que la mise à jour s'installe.

## v2.14.2

- Fenêtre de sauvegarde : la liste **Catégorie** est maintenant une liste de **recherche** (taper filtre les catégories existantes). Elle ne crée plus jamais de catégorie : un nom inconnu est refusé, les catégories se créent avec le bouton **+**. Sans catégorie choisie, la catégorie portant le nom du type est utilisée si elle existe déjà, sinon un message demande d'en choisir une.
- Le type choisi ne change plus quand on sélectionne une catégorie sans préfixe de type.
- `F4` : ouvre aussi la fenêtre de sauvegarde depuis le menu principal et la liste des utilitaires (il ne faisait rien). Si la fenêtre est déjà ouverte, elle repasse devant. Un indicateur « fenêtre ouverte » resté bloqué est remis à zéro, ce qui pouvait empêcher la fenêtre de s'ouvrir de nouveau.

## v2.14.1

- Bouton **+** de la catégorie : la catégorie est créée avec exactement le nom tapé, sans préfixe de type, et le type choisi ne change plus.
- Tags : nouveau bouton **→ Info** qui recopie le nom des tags dans le message d'info du chat (fenêtres de sauvegarde et de modification).
- Fenêtre de sauvegarde : « Donner la grenade du type choisi (give) » est décoché par défaut et placé sous la capture (il passait sur l'image). Même correction pour les boutons de la fenêtre de modification.

## v2.14.0

- Fenêtre de sauvegarde et de modification d'un stuff : liste **Tags** entre le nom et l'info du chat. On choisit un tag existant ou on en tape un nouveau, puis **+** l'ajoute au stuff (**-** le retire). Les tags créés sont gardés dans `data\tags.txt`.
- Les tags s'affichent sous l'info dans le menu, sont pris en compte par la recherche rapide, et sont exportés et importés avec les stuffs. Ils sont enregistrés comme 5e champ de la ligne (`Catégorie | Nom | commandes | info | tags`) ; les stuffs existants restent valables.
- Fenêtre de sauvegarde : bouton **+** à côté de la liste Catégorie pour créer une nouvelle catégorie dans la map choisie.

## v2.13.1

- La connexion directe exige l'option de lancement `-insecure` en plus de `-netconport 2121` (sans elle, CS2 n'ouvre pas le port). README, `config.example.ini` et la vérification de l'installation l'indiquent, avec l'avertissement : `-insecure` désactive VAC, à retirer pour jouer en ligne.

## v2.13.0

- Connexion directe à CS2 : avec l'option de lancement `-netconport 2121`, le script envoie les commandes à la console du jeu par un port local, sans fichier `stuff_run.cfg`, sans appui de touche et sans `exec cs2_practice`. Les stuffs, utilitaires, coordonnées et la vérification l'utilisent automatiquement. Si la connexion échoue, le script revient aux 2 touches comme avant.
- Nouvelle clé `NetconPort` dans `config.ini` (2121 par défaut, 0 pour désactiver).
- La vérification de l'installation indique si la connexion directe est active.
- La fenêtre de choix des touches ne s'ouvre pas si la connexion directe fonctionne au lancement.

## v2.12.1

- Nettoyage du code : suppression de fonctions et de variables qui n'étaient plus utilisées (anciens raccourcis de suppression et d'ajout, aides inutilisées). Aucun changement de fonctionnement.
- Une touche invalide dans `config.ini` (`MenuKey`, `FavKey`, `LockKey`, `AddKey`) n'empêche plus le script de démarrer : un message l'indique.
- `cs2_practice.cfg` : les liaisons des 2 touches du script sont remises à jour à chaque lancement si le fichier a été recopié, et ne sont réécrites que si nécessaire.
- README : sections réorganisées (touches du script, « Où sont mes stuffs ? », structure du dépôt, dépannage) et rappels périmés corrigés.

## v2.12.0

- Choix des touches du script : au premier lancement de cette version, une fenêtre propose 2 touches (lancer les stuffs, coordonnées) parmi une liste. Le script lit ta configuration CS2 (touches enregistrées et fichiers cfg) et signale celles qui sont déjà utilisées ; les touches libres sont proposées en premier. Évite qu'une touche déjà utilisée (arme, Discord, logiciel de clavier) déclenche autre chose en jeu.
- Nouveau bouton « Touches du script » dans les réglages (F10) pour les changer plus tard ; clés `ExecKey` et `HudKey` dans `config.ini`.
- `cs2_practice.cfg` (dossier cfg de CS2) est réécrit automatiquement avec les touches choisies. Si CS2 tourne, il est relancé tout de suite avec l'ancienne touche ; sinon tape `exec cs2_practice` une fois dans la console.

## v2.11.1

- Retour au contenu de la v2.10.1 : le choix des touches du script (v2.11.0) est retiré. Pour les utilisateurs de la v2.11.0, cette version remet les touches par défaut (`*` et `/` du pavé numérique).

## v2.10.1

- Coordonnées en temps réel : elles ont leur propre fichier (`hud_pos.cfg`) et leur propre touche (`kp_slash`) et ne réécrivent plus `stuff_run.cfg` en boucle. Pause de 2 secondes après chaque commande du menu. Corrige un stuff (avec `give`) rejoué en boucle quand les coordonnées étaient actives. La liaison de la touche se fait toute seule à l'activation, sans refaire `exec cs2_practice`.

## v2.10.0

- La catégorie « Utilitaires » (bots, God mode, noclip, kit d'armes…) passe dans le menu principal et n'apparaît plus dans la liste des catégories de chaque map. Elle reste modifiable dans la fenêtre de gestion (« Communs »).

## v2.9.2

- `F4` (menu des stuffs ouvert) : créer un nouveau stuff, avec la catégorie courante pré-remplie.

## v2.9.1

- Raccourci F4 (ajouter) supprimé : les stuffs s'ajoutent avec « Sauvegarder la position actuelle » du menu principal, les catégories dans la fenêtre de gestion.

## v2.9.0

- Une seule touche en jeu : `F1` ouvre un **menu principal** (Stuffs, Relancer le dernier stuff, Sauvegarder la position, Gestion, Profils et partage, Réglages, Relancer l'exec, Vérifier l'installation). Les raccourcis F6 à F11 sont supprimés.
- Dans le menu des stuffs : `F2` favoris, `F3` cadenas, `F4` ajouter, `Ctrl+Z` annuler. Le raccourci de suppression est retiré (la suppression se fait dans la fenêtre de gestion).
- Nouvelle clé `MenuKey` (défaut F1). Les touches sont migrées une seule fois dans config.ini.

## v2.8.3

- Correction : les captures importées depuis un fichier .stuffpack provoquaient « Can't create control » dans la fenêtre de modification (format d'image illisible). Elles sont maintenant enregistrées en BMP 24 bits, et les captures déjà importées sont réparées automatiquement à l'affichage.

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
