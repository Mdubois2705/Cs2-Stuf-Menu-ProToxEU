#Requires AutoHotkey v2.0
#SingleInstance Force

; =====================================================================
;  CS2 STUFF MENU - overlay navigable pour s'entraîner en local
;  Config : config.ini   |   Stuffs : dossier maps\ (un .txt par map)
;  Données perso (favoris, récents) : dossier data\
; =====================================================================

APP_VERSION := "2.26.6"   ; à garder identique au fichier VERSION du dépôt
UPDATE_REPO := "Mdubois2705/Cs2-Stuf-Menu-ProToxEU"

; ---------- Configuration ----------
IniFile := A_ScriptDir "\config.ini"
if (!FileExist(IniFile) && FileExist(A_ScriptDir "\config.example.ini"))
    FileCopy(A_ScriptDir "\config.example.ini", IniFile)
DEFAULT_PROFILE := "Principal"   ; profil par défaut : dossiers maps\ et data\
curProfile := IniRead(IniFile, "State", "Profile", DEFAULT_PROFILE)
if (curProfile != DEFAULT_PROFILE && !DirExist(A_ScriptDir "\profiles\" curProfile))
    curProfile := DEFAULT_PROFILE
MapsDir := ProfMaps(curProfile)
DataDir := ProfData(curProfile)
FavFile := DataDir "\favorites.txt"
LockFile := DataDir "\locks.txt"
TimesFile := DataDir "\times.txt"   ; temps de vol des stuffs
RecentFile := DataDir "\recents.txt"

CfgPath := IniRead(IniFile, "Settings", "CfgPath", "")
; Migration unique des touches (v2.9) : une seule touche globale (MenuKey), le reste est dans le menu
if (IniRead(IniFile, "State", "KeysV", "") != "2") {
    IniWrite("F1", IniFile, "Settings", "MenuKey")
    IniWrite("F2", IniFile, "Settings", "FavKey")
    IniWrite("F3", IniFile, "Settings", "LockKey")
    IniWrite("2", IniFile, "State", "KeysV")
}
MenuKey := IniRead(IniFile, "Settings", "MenuKey", "F1")
FavKey := IniRead(IniFile, "Settings", "FavKey", "F2")
LockKey := IniRead(IniFile, "Settings", "LockKey", "F3")
AddKey := IniRead(IniFile, "Settings", "AddKey", "F4")
CloseAfterRun := (IniRead(IniFile, "Settings", "CloseAfterRun", "1") = "1")
AutoDetect := (IniRead(IniFile, "Settings", "AutoDetectMap", "1") = "1")
ConsoleLog := IniRead(IniFile, "Settings", "ConsoleLog", "")
LastMap := IniRead(IniFile, "State", "LastMap", "")
TpZOffset := Number(IniRead(IniFile, "Settings", "TpZOffset", "-64"))
AutoBackupOn := (IniRead(IniFile, "Settings", "AutoBackup", "1") = "1")
BackupKeep := Max(0, ToInt(IniRead(IniFile, "Settings", "BackupKeep", "14"), 14))
AutoCheck := (IniRead(IniFile, "Settings", "AutoCheck", "1") = "1")
AutoUpdate := (IniRead(IniFile, "Settings", "AutoUpdate", "1") = "1")
HudInterval := Max(100, ToInt(IniRead(IniFile, "Settings", "HudInterval", "300"), 300))
HudAtStart := (IniRead(IniFile, "Settings", "HudAtStart", "0") = "1")
HudAuto := (IniRead(IniFile, "Settings", "HudAuto", "1") = "1")      ; 1 = coin inférieur gauche, 0 = position libre
HudX := ToInt(IniRead(IniFile, "Settings", "HudX", "12"), 12)
HudY := ToInt(IniRead(IniFile, "Settings", "HudY", "900"), 900)
; Chronomètre de grenade (temps entre le lâcher et l'explosion)
TimerOn := (IniRead(IniFile, "Settings", "TimerOn", "1") = "1")
TimerAuto := (IniRead(IniFile, "Settings", "TimerAuto", "1") = "1")   ; 1 = au-dessus des coordonnées, 0 = position libre
TimerX := ToInt(IniRead(IniFile, "Settings", "TimerX", "12"), 12)
TimerY := ToInt(IniRead(IniFile, "Settings", "TimerY", "820"), 820)
TimerDur := Max(2, Min(20, ToInt(IniRead(IniFile, "Settings", "TimerDur", "6"), 6)))   ; secondes d'affichage du résultat
ShowChangelogOn := (IniRead(IniFile, "Settings", "ShowChangelog", "1") = "1")   ; fenêtre « Nouveautés » après chaque mise à jour
LauncherOn := (IniRead(IniFile, "Settings", "Launcher", "1") = "1")   ; fenêtre d'accueil au démarrage
AutoMap := Trim(IniRead(IniFile, "Settings", "AutoMap", "last"))   ; map chargée toute seule après le lancement de CS2 : last, none ou un nom de map
AutoMapDelay := Max(3, Min(60, ToInt(IniRead(IniFile, "Settings", "AutoMapDelay", "8"), 8)))   ; secondes d'attente après la connexion au jeu
PackAdmin := (IniRead(IniFile, "Settings", "PackAdmin", "0") = "1")   ; réservé à l'auteur : publier des packs dans son dépôt
PackRepoDir := Trim(IniRead(IniFile, "Settings", "PackRepoDir", ""))
WinThemeSel := IniRead(IniFile, "Settings", "WinTheme", "dark")   ; dark, light ou menu
if !RegExMatch(WinThemeSel, "^(dark|light|menu)$")
    WinThemeSel := "dark"
WinAccent := StrUpper(IniRead(IniFile, "Settings", "WinAccent", "5B9BFF"))
if !RegExMatch(WinAccent, "^[0-9A-F]{6}$")
    WinAccent := "5B9BFF"
WinFontName := IniRead(IniFile, "Settings", "WinFont", "Segoe UI")
WinScale := Max(90, Min(120, ToInt(IniRead(IniFile, "Settings", "WinScale", "100"), 100)))
TimerBeep := (IniRead(IniFile, "Settings", "TimerBeep", "1") = "1")   ; bip avant l'arrivée de la grenade
RethrowKey := Trim(IniRead(IniFile, "Settings", "RethrowKey", "k"))   ; touche liée à sv_rethrow_last_grenade (chrono : départ de la relance)
FlightAsk := (IniRead(IniFile, "Settings", "FlightAsk", "1") = "1")   ; proposer de mesurer le temps de vol après la création d'un stuff
LogMaxMB := Max(0, ToInt(IniRead(IniFile, "Settings", "LogMaxMB", "10"), 10))   ; taille de console.log au-delà de laquelle il est vidé au lancement (0 = jamais)
ShotOn := (IniRead(IniFile, "Settings", "Shot", "1") = "1")                         ; captures d'écran des stuffs
ShotSize := Max(40, Min(300, ToInt(IniRead(IniFile, "Settings", "ShotSize", "100"), 100)))   ; zone capturée (px)
ShotZoom := Max(60, Min(500, ToInt(IniRead(IniFile, "Settings", "ShotZoom", "160"), 160)))   ; taille d'affichage (px)
ShotPlace := Max(1, Min(2, ToInt(IniRead(IniFile, "Settings", "ShotPos", "1"), 1)))   ; 1 = coin supérieur droit, 2 = position libre
ShotCorner := Max(0, Min(30, ToInt(IniRead(IniFile, "Settings", "ShotCorner", "3"), 3)))   ; arrondi des coins de la capture (px)
ShotX := ToInt(IniRead(IniFile, "Settings", "ShotX", "520"), 520)
ShotY := ToInt(IniRead(IniFile, "Settings", "ShotY", "100"), 100)
PracticeCfg := IniRead(IniFile, "Settings", "PracticeCfg", "cs2_practice")
AutoExec := (IniRead(IniFile, "Settings", "AutoExec", "1") = "1")
; Connexion directe à la console de CS2 (option de lancement -netconport) : seul moyen d'envoyer des commandes au jeu
NetconPort := Max(1, Min(65535, ToInt(IniRead(IniFile, "Settings", "NetconPort", "2121"), 2121)))
LaunchArgs := Trim(IniRead(IniFile, "Settings", "LaunchArgs", "-condebug -netconport {port} -insecure"))
netSock := -1          ; socket ouvert vers CS2 (-1 = aucun)
netWsa := false        ; Winsock initialisé
netFailTick := 0       ; moment de la dernière connexion ratée (pas de nouvel essai avant quelques secondes)
execMap := ""       ; map pour laquelle le cfg d'entraînement a déjà été exécuté

; Apparence du menu (modifiable avec la touche de réglages)
ovFont := IniRead(IniFile, "Overlay", "Font", "")
ovScale := Max(60, Min(200, ToInt(IniRead(IniFile, "Overlay", "Scale", "100"), 100)))
ovX := ToInt(IniRead(IniFile, "Overlay", "X", "30"), 30)
ovY := ToInt(IniRead(IniFile, "Overlay", "Y", "100"), 100)
ovOpacity := Max(80, Min(255, ToInt(IniRead(IniFile, "Overlay", "Opacity", "225"), 225)))
ovBg := IniRead(IniFile, "Overlay", "Bg", "14181D")
ovTheme := IniRead(IniFile, "Overlay", "Theme", "")
ovCorner := Max(0, Min(30, ToInt(IniRead(IniFile, "Overlay", "Corner", "14"), 14)))   ; rayon des coins arrondis (0 = carré)
ovBorder := Max(0, Min(6, ToInt(IniRead(IniFile, "Overlay", "Border", "2"), 2)))      ; épaisseur du liseré (0 = aucun)
ovBorderCol := StrUpper(Trim(IniRead(IniFile, "Overlay", "BorderColor", ""), "# `t"))   ; couleur du liseré (vide = auto selon le thème)
if !RegExMatch(ovBorderCol, "^[0-9A-F]{6}$")
    ovBorderCol := ""
ovTitle := Trim(RegExReplace(IniRead(IniFile, "Overlay", "Title", "Menu Stuf V.{version} ProToxEU"), "[`r`n`t]+", " "))
if (ovTitle = "Menu Stuf V.2 ProToxEU")   ; ancien titre par défaut : suit maintenant la version
    ovTitle := "Menu Stuf V.{version} ProToxEU"
ovTitle := StrReplace(ovTitle, "{version}", APP_VERSION)
if !RegExMatch(ovBg, "^[0-9A-Fa-f]{6}$")
    ovBg := "14181D"

SplitPath(CfgPath, , &cfgDir)
if (CfgPath = "" || !DirExist(cfgDir)) {
    ; Chemin absent ou invalide (ex. config copiée d'un autre PC) : détection automatique de CS2 via Steam
    badPath := CfgPath
    found := FindCs2Cfg()
    if (found = "") {
        badTxt := (badPath != "") ? " (chemin du config.ini : " badPath ")" : ""
        MsgBox("Le dossier cfg de CS2 n'a pas été trouvé automatiquement" badTxt ".`n`nChoisis le dossier cfg de CS2 à la fenêtre suivante.`nIl se trouve en général ici :`n...\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg", "Menu Stuf - installation", 0x40040)
        picked := DirSelect("*C:\Program Files (x86)\Steam\steamapps\common", 0, "Choisis le dossier cfg de CS2 (game\csgo\cfg)")
        picked := RTrim(picked, "\")
        if (picked != "") {
            found := Cs2CfgIn(picked)
            if (found = "" && DirExist(picked))
                found := picked
        }
    }
    if (found = "") {
        MsgBox("Aucun dossier cfg valide : le menu ne peut pas démarrer.`n`nRelance le script et choisis le dossier cfg de CS2, ou renseigne CfgPath dans config.ini.", "Menu Stuf - installation", 0x40010)
        ExitApp
    }
    CfgPath := found "\stuff_run.cfg"
    IniWrite(CfgPath, IniFile, "Settings", "CfgPath")
    SplitPath(CfgPath, , &cfgDir)
}
; Copie automatique de cs2_practice.cfg dans le dossier cfg de CS2 (sans jamais écraser un fichier existant)
practiceSrc := A_ScriptDir "\" PracticeCfg ".cfg"
practiceDst := cfgDir "\" PracticeCfg ".cfg"
if (FileExist(practiceSrc) && !FileExist(practiceDst)) {
    try FileCopy(practiceSrc, practiceDst)
}
if (ConsoleLog = "") {
    SplitPath(cfgDir, , &csgoDir)
    ConsoleLog := csgoDir "\console.log"
}
DirCreate(DataDir)
DirCreate(MapsDir)
; Premier lancement : copie les maps vides de maps_default\ (sans jamais écraser tes fichiers)
if (curProfile = DEFAULT_PROFILE && DirExist(A_ScriptDir "\maps_default")) {
    Loop Files A_ScriptDir "\maps_default\*.txt" {
        if !FileExist(MapsDir "\" A_LoopFileName)
            FileCopy(A_LoopFileFullPath, MapsDir "\" A_LoopFileName)
    }
}

; ---------- Constantes ----------
FAV_CAT := "[Favoris]"
REC_CAT := "[Récents]"
LOCK_ICON := "🔒"   ; si le cadenas s'affiche comme un carré, remplace par "[L]"
DEFAULT_LOCKED_CATS := ["Utilitaires"]   ; verrouillées au premier lancement
; Thèmes de couleurs : [id, nom affiché, fond, texte, titre, nom de map, texte secondaire, ligne sélectionnée]
THEMES := [
    ["graphite", "Graphite et Or", "16181D", "E8E4DA", "D4B483", "D4B483", "8B8F98", "23262D"],
    ["encre", "Encre et Glace", "0F1822", "E3ECF2", "7DB7D1", "E9C98F", "7F93A3", "1B2A38"],
    ["foret", "Forêt et Sauge", "101A17", "E3EBE4", "A3C9A8", "E2CF9C", "80978A", "1C2B25"],
    ["bordeaux", "Bordeaux et Crème", "1B1316", "EFE3D8", "D98B95", "ECD9B0", "9A8587", "2A1D22"],
    ["ardoise", "Ardoise et Lavande", "171A27", "E7E8F3", "AEB1EE", "F2BD9E", "8B8FAB", "252A40"],
    ["papier", "Papier et Encre", "F4F1EA", "22262E", "3B5B7A", "9A6330", "6D7480", "E6E1D5"]
]
UTIL_CAT := "Utilitaires"                ; catégorie commune, affichée dans le menu principal
utilMode := false                        ; true = liste des utilitaires ouverte depuis le menu principal
FALLBACK_CAT := "Non classés"            ; où vont les stuffs d'une catégorie supprimée
NO_TYPE := "(aucun)"
Types := ["Smoke", "Molotov", "Flash", "HE", "Position", "Autre", NO_TYPE]
GiveMap := Map("Smoke", "weapon_smokegrenade", "Molotov", "weapon_molotov", "Flash", "weapon_flashbang", "HE", "weapon_hegrenade")
NUM := "[-+\d.eE]+"

; ---------- État ----------
menuOpen := false
dlgOpen := false
dlgHwnd := 0        ; fenêtre de sauvegarde ouverte (retrouve un indicateur resté bloqué)
level := 0          ; 0 = maps, 1 = catégories, 2 = stuffs, 3 = recherche, 4 = menu principal
mainIdx := 1
prevLevel := 1
mapIdx := 1
catIdx := 1
itemIdx := 1
resIdx := 1
query := ""
results := []
mapNames := []
mapFiles := []
loadedMap := ""
cats := []
items := Map()      ; catégorie -> tableau de stuffs [nom, commande, info, catégorie, clé, fichier source]
setOpen := false    ; fenêtre de réglages ouverte
mgrOpen := false    ; fenêtre de gestion ouverte
hudOn := false      ; affichage des coordonnées en temps réel
hudGui := ""
hudTxt := ""
hudLast := ""
hudPos := 0         ; position de lecture dans console.log
cmdBusy := 0        ; > 0 pendant l'envoi d'une commande au jeu
lastCmdTick := 0    ; moment du dernier envoi de commande (pause des coordonnées après un stuff)
chkGui := ""        ; fenêtre de vérification de l'installation
chkHead := ""
chkTxt := ""
chkP1 := []
chkP2 := []
chkAttempts := 0
chkTicks := 0
chkBusy := false
g := ""
gb := ""            ; fenêtre derrière le menu qui forme le liseré coloré
hudB := ""          ; liseré des coordonnées
tmGui := ""         ; fenêtre du chronomètre de grenade
tmB := ""           ; liseré du chronomètre
tmText := ""        ; dernier texte affiché
tmVisible := false
tmRunning := false  ; lecture de console.log active
tmPos := 0          ; position de lecture dans console.log
tmClicks := []      ; moments où le clic gauche a été relâché
tmStarts := []      ; file des départs de grenades en vol : [instant, confirmé par le journal]
tmLastK := 0
launcherHwnd := 0   ; fenêtre du launcher (pour placer la vérification à côté)
newsUnseen := false  ; nouvelle version : un point apparaît sur « Nouveautés » du launcher
tmLastThrow := ""   ; dernier lancer : Map(kind, pos, secs)
tmPosWait := 0
tmLineWasK := false
tmTesting := false  ; test de la mesure (réglages)
tmTestCb := ""
tmExpect := ""      ; temps de vol attendu (stuff lancé par le menu)
tmBeeped := false
tmLastLabel := ""   ; type de la dernière grenade vue (pour le chrono en direct des relances)
TimerDebug := (IniRead(IniFile, "Settings", "TimerDebug", "0") = "1")
TmDbgFile := DataDir "\timer_debug.txt"
tmSentSock := 0     ; connexion pour laquelle « log on » a été envoyé
tmMeasuring := false ; mesure du temps de vol d'un stuff en cours
tmMeasured := 0     ; dernier temps mesuré pendant une mesure (secondes)
tmLive := false     ; chrono en direct affiché
tmLiveLabel := ""
tmLiveT0 := 0
tmCtl := ""         ; texte du chronomètre
times := Map()      ; temps de vol : clé de position -> secondes
quizCur := ""       ; stuff du quiz en cours
qzGui := ""         ; bandeau du quiz
clGui := ""         ; fenêtre des nouveautés
qzB := ""
shotOk := Map()     ; captures vérifiées lisibles
gs := ""            ; fenêtre qui affiche la capture du stuff sélectionné
gsPic := ""
gsTxt := ""
titleCtl := ""
listRows := []     ; 13 lignes du menu (texte normal)
listRowsS := []    ; 13 lignes du menu (ligne sélectionnée, fond mis en valeur)
infoCtl := ""
hintCtl := ""
statusCtl := ""
favs := Map()
locks := Map()      ; verrous : "cat|Nom" ou "it|clé du stuff"
recents := []

; ---------- Fenêtre overlay (ne prend pas le focus du jeu) ----------
BuildOverlay()

; ---------- Recherche : capture du texte tapé ----------
ih := InputHook()
ih.OnChar := OnSearchChar

DirCreate(DataDir)
LoadFavs()
LoadLocks()
LoadRecents()
LoadTimes()

; =====================================================================
;  Fichiers : maps, favoris, récents
; =====================================================================
LoadMaps() {
    global mapNames, mapFiles
    mapNames := []
    mapFiles := []
    Loop Files MapsDir "\*.txt" {
        if (SubStr(A_LoopFileName, 1, 1) = "_")
            continue
        mapNames.Push(RegExReplace(A_LoopFileName, "\.txt$"))
        mapFiles.Push(A_LoopFileFullPath)
    }
}

ParseFile(path, mapName) {
    if !FileExist(path)
        return
    for line in StrSplit(FileRead(path, "UTF-8"), "`n", "`r") {
        line := Trim(line)
        if (line = "" || SubStr(line, 1, 1) = "#" || SubStr(line, 1, 2) = "//")
            continue
        p := StrSplit(line, "|", " `t", 4)
        if (p[1] = "@cat") {          ; catégorie vide déclarée : @cat | Nom
            if (p.Length >= 2 && p[2] != "") {
                c := p[2]
                if !items.Has(c) {
                    items[c] := []
                    cats.Push(c)
                }
            }
            continue
        }
        if (p.Length < 3)
            continue
        c := p[1]
        if !items.Has(c) {
            items[c] := []
            cats.Push(c)
        }
        info := ""
        tags := ""
        if (p.Length >= 4) {
            sp := SplitInfo(p[4])
            info := sp[1]
            tags := sp[2]
        }
        items[c].Push([p[2], p[3], info, c, mapName "|" c "|" p[2], path, tags])
    }
}

LoadMapStuff(idx) {
    global cats, items, loadedMap
    cats := []
    items := Map()
    loadedMap := mapNames[idx]
    ParseFile(mapFiles[idx], loadedMap)
    ParseFile(MapsDir "\_commun.txt", loadedMap)
    ; « Utilitaires » vit dans le menu principal, pas dans la liste de chaque map
    if items.Has(UTIL_CAT) {
        items.Delete(UTIL_CAT)
        i := cats.Length
        while (i >= 1) {
            if (cats[i] = UTIL_CAT)
                cats.RemoveAt(i)
            i -= 1
        }
    }
    BuildVirtual()
}

; Ouvre la liste des utilitaires (bots, god mode, noclip...) depuis le menu principal
OpenUtil() {
    global cats, items, level, itemIdx, catIdx, utilMode, loadedMap
    cats := []
    items := Map()
    ParseFile(MapsDir "\_commun.txt", "_commun")
    if (!items.Has(UTIL_CAT) || items[UTIL_CAT].Length = 0) {
        SetStatus("Aucun utilitaire trouvé (catégorie Utilitaires de maps\_commun.txt)")
        return
    }
    list := items[UTIL_CAT]
    cats := [UTIL_CAT]
    items := Map(UTIL_CAT, list)
    loadedMap := ""
    catIdx := 1
    itemIdx := 1
    utilMode := true
    level := 2
    Render()
}

; =====================================================================
;  Temps de vol des stuffs (data\times.txt)
; =====================================================================
; Clé = position et angle du stuff (stable si on renomme ou déplace le stuff)
TimeKey(cmd) {
    pat := "i)setpos\s+(" NUM ")\s+(" NUM ")\s+(" NUM ")(?:\s*;\s*setang\s+(" NUM ")\s+(" NUM "))?"
    if !RegExMatch(cmd, pat, &m)
        return ""
    k := ""
    try {
        k := Format("{:.2f}", Number(m[1])) "_" Format("{:.2f}", Number(m[2])) "_" Format("{:.2f}", Number(m[3]))
        if (m[4] != "" && m[5] != "")
            k .= "_" Format("{:.2f}", Number(m[4])) "_" Format("{:.2f}", Number(m[5]))
    }
    return k
}

LoadTimes() {
    global times
    times := Map()
    if !FileExist(TimesFile)
        return
    for line in StrSplit(FileRead(TimesFile, "UTF-8"), "`n", "`r") {
        p := StrSplit(line, "`t")
        if (p.Length >= 2 && p[1] != "" && IsNumber(p[2]))
            times[p[1]] := p[2]
    }
}

SaveTimes() {
    txt := ""
    for k, v in times
        txt .= k "`t" v "`n"
    try {
        DirCreate(DataDir)
        try FileDelete(TimesFile)
        FileAppend(txt, TimesFile, "UTF-8-RAW")
    }
}

; Temps de vol (secondes, en texte) d'un stuff d'après sa commande, "" s'il n'est pas mesuré
FlightTime(cmd) {
    k := TimeKey(cmd)
    return (k != "" && times.Has(k)) ? times[k] : ""
}

FlightText(secs) {
    return StrReplace(Format("{:.1f}", Number(secs)), ".", ",") " s"
}

SetFlightTime(cmd, secs) {
    k := TimeKey(cmd)
    if (k = "")
        return
    times[k] := Format("{:.2f}", Number(secs))
    SaveTimes()
}

DelFlightTime(key) {
    if (key != "" && times.Has(key)) {
        times.Delete(key)
        SaveTimes()
    }
}

; Téléporte le joueur au repère, attend qu'il lance la grenade et renvoie le temps mesuré (secondes),
; ou 0 si annulé. Le joueur valide le temps (il peut refaire le lancer s'il a raté).
MeasureFlight(cmd, typ := "") {
    global tmMeasuring, tmMeasured, netFailTick
    if !ProcessExist("cs2.exe") {
        MsgBox("CS2 n'est pas lancé.", "Temps de vol", 0x40030)
        return 0
    }
    netFailTick := 0
    if !NetOpen() {
        MsgBox("Pas de connexion à CS2 : ferme le jeu et relance le menu.", "Temps de vol", 0x40030)
        return 0
    }
    send := cmd
    if (typ != "" && !RegExMatch(cmd, "i)give\s+weapon_")) {
        gv := GiveMap.Get(typ, "")
        if (gv != "")
            send .= "; give " gv
    }
    Loop {
        tmMeasuring := true
        tmMeasured := 0
        TmApply()
        try WinActivate("ahk_exe cs2.exe")
        WinWaitActive("ahk_exe cs2.exe", , 3)
        Sleep(200)
        RunCmd(send)
        ToolTip("Chrono : lance la grenade maintenant (Échap pour annuler)")
        t0 := A_TickCount
        res := 0
        canceled := false
        while (A_TickCount - t0 < 30000) {
            Sleep(50)
            if (tmMeasured > 0) {
                res := tmMeasured
                break
            }
            if GetKeyState("Escape", "P") {
                canceled := true
                break
            }
        }
        ToolTip()
        tmMeasuring := false
        TmApply()
        if canceled
            return 0
        if (res = 0) {
            if (MsgBox("Aucune explosion détectée en 30 secondes.`n`nRéessayer ?", "Temps de vol", 0x40024) = "Yes")
                continue
            return 0
        }
        ans := MsgBox("Temps mesuré : " FlightText(res) "`n`nOui : enregistrer ce temps`nNon : refaire le lancer`nAnnuler : abandonner", "Temps de vol", 0x40023)
        if (ans = "Yes")
            return res
        if (ans = "Cancel")
            return 0
    }
}

; Propose de mesurer le temps de vol d'un stuff qui vient d'être créé
OfferFlight(cmd, typ) {
    if !FlightAsk
        return
    if !(GiveMap.Has(typ) || RegExMatch(cmd, "i)give\s+weapon_(smokegrenade|flashbang|hegrenade|molotov|incgrenade|decoy)"))
        return
    if (MsgBox("Mesurer le temps de vol de ce stuff ?`n`nOui : tu es téléporté au repère, tu lances la grenade et le menu mesure le temps jusqu'à l'explosion. Tu valides ensuite le résultat.`nNon : tu pourras le faire plus tard (Modifier le stuff).", "Temps de vol", 0x40024) != "Yes")
        return
    secs := MeasureFlight(cmd, typ)
    if (secs > 0) {
        SetFlightTime(cmd, secs)
        ToolTip("Temps de vol enregistré : " FlightText(secs))
        SetTimer(() => ToolTip(), -2500)
    }
}

; Ajoute les catégories [Favoris] et [Récents] en tête (si non vides)
BuildVirtual() {
    global cats, items
    i := cats.Length
    while (i >= 1) {
        if (cats[i] = FAV_CAT || cats[i] = REC_CAT) {
            items.Delete(cats[i])
            cats.RemoveAt(i)
        }
        i -= 1
    }
    favItems := []
    for c in cats {
        for it in items[c] {
            if favs.Has(it[5])
                favItems.Push(it)
        }
    }
    recItems := []
    for r in recents {
        if (InStr(r[5], loadedMap "|") = 1)
            recItems.Push(r)
    }
    if (recItems.Length > 0) {
        items[REC_CAT] := recItems
        cats.InsertAt(1, REC_CAT)
    }
    if (favItems.Length > 0) {
        items[FAV_CAT] := favItems
        cats.InsertAt(1, FAV_CAT)
    }
}

LoadFavs() {
    global favs
    favs := Map()
    if !FileExist(FavFile)
        return
    for line in StrSplit(FileRead(FavFile, "UTF-8"), "`n", "`r") {
        line := Trim(line)
        if (line != "")
            favs[line] := 1
    }
}

SaveFavs() {
    txt := ""
    for k in favs
        txt .= k "`n"
    try FileDelete(FavFile)
    FileAppend(txt, FavFile, "UTF-8-RAW")
}

LoadRecents() {
    global recents
    recents := []
    if !FileExist(RecentFile)
        return
    for line in StrSplit(FileRead(RecentFile, "UTF-8"), "`n", "`r") {
        if (line = "")
            continue
        a := StrSplit(line, "`t")
        if (a.Length >= 5)
            recents.Push([a[2], a[3], a[4], a[5], a[1]])
    }
}

SaveRecents() {
    txt := ""
    for r in recents
        txt .= r[5] "`t" r[1] "`t" r[2] "`t" r[3] "`t" r[4] "`n"
    try FileDelete(RecentFile)
    FileAppend(txt, RecentFile, "UTF-8-RAW")
}

AddRecent(it) {
    for i, r in recents {
        if (r[5] = it[5]) {
            recents.RemoveAt(i)
            break
        }
    }
    recents.InsertAt(1, it)
    while (recents.Length > 15)
        recents.Pop()
    SaveRecents()
}

; =====================================================================
;  Connexion directe à la console de CS2 (option de lancement -netconport)
; =====================================================================
; CS2 ouvre un port TCP local qui accepte des commandes de console en texte. Le script s'y connecte
; (127.0.0.1 uniquement) et y envoie les commandes : pas de fichier cfg, pas de touche.
; Sans connexion, aucune commande ne part (NetWarn prévient l'utilisateur).
NetOpen() {
    global netSock, netWsa, netFailTick
    if (NetconPort <= 0)
        return false
    if (netSock != -1)
        return true
    if (netFailTick != 0 && A_TickCount - netFailTick < 5000)
        return false
    if !netWsa {
        wsa := Buffer(408, 0)
        if (DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", wsa, "Int") != 0) {
            netFailTick := A_TickCount
            return false
        }
        netWsa := true
    }
    sk := DllCall("ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr")   ; AF_INET, SOCK_STREAM, TCP
    if (sk = -1) {
        netFailTick := A_TickCount
        return false
    }
    sa := Buffer(16, 0)
    NumPut("UShort", 2, sa, 0)
    NumPut("UShort", ((NetconPort & 0xFF) << 8) | (NetconPort >> 8), sa, 2)   ; port en ordre réseau
    NumPut("UChar", 127, sa, 4)
    NumPut("UChar", 1, sa, 7)                                                  ; 127.0.0.1
    if (DllCall("ws2_32\connect", "Ptr", sk, "Ptr", sa, "Int", 16, "Int") != 0) {
        DllCall("ws2_32\closesocket", "Ptr", sk)
        netFailTick := A_TickCount
        return false
    }
    nd := Buffer(4, 0)
    NumPut("Int", 1, nd)
    DllCall("ws2_32\setsockopt", "Ptr", sk, "Int", 6, "Int", 1, "Ptr", nd, "Int", 4)   ; TCP_NODELAY : envoi immédiat, sans attendre l'accusé de réception (évite 40 à 200 ms de retard)
    nb := Buffer(4, 0)
    NumPut("UInt", 1, nb)
    DllCall("ws2_32\ioctlsocket", "Ptr", sk, "UInt", 0x8004667E, "Ptr", nb)   ; mode non bloquant
    netSock := sk
    netFailTick := 0
    SetTimer(NetDrain, 1000)
    return true
}

NetClose() {
    global netSock
    if (netSock != -1)
        DllCall("ws2_32\closesocket", "Ptr", netSock)
    netSock := -1
}

; Le jeu répond sur la même connexion : on jette ce qu'il envoie pour ne jamais saturer le tampon
NetDrain() {
    if (netSock = -1)
        return
    buf := Buffer(4096)
    Loop 64 {
        n := DllCall("ws2_32\recv", "Ptr", netSock, "Ptr", buf, "Int", 4096, "Int", 0, "Int")
        if (n > 0)
            continue
        if (n = 0)
            NetClose()   ; fermée par le jeu
        break
    }
}

NetSendRaw(txt) {
    n := StrPut(txt, "UTF-8") - 1
    buf := Buffer(n + 1, 0)
    StrPut(txt, buf, "UTF-8")
    return (DllCall("ws2_32\send", "Ptr", netSock, "Ptr", buf, "Int", n, "Int", 0, "Int") = n)
}

; Envoie une commande à CS2 par la connexion directe. false = pas de connexion
NetSend(cmd) {
    if !NetOpen()
        return false
    NetDrain()
    if (netSock = -1 && !NetOpen())
        return false
    if NetSendRaw(cmd "`n")
        return true
    NetClose()   ; connexion morte (jeu relancé) : un seul nouvel essai
    if !NetOpen()
        return false
    if NetSendRaw(cmd "`n")
        return true
    NetClose()
    return false
}

OnExit((*) => NetClose())
OnError(ScriptError)

; Lance CS2 par Steam avec les options nécessaires à la connexion directe, sans toucher aux options enregistrées dans Steam.
; Méthode fiable : steam.exe -applaunch 730 <options> (le lien steam://rungameid ignore souvent les options).
launchWatch := 0
autoMapDone := true   ; false après un lancement de CS2 par le menu : la map automatique reste à charger
updRemote := ""       ; dernière version trouvée sur GitHub
updTick := 0
; Lance CS2 avec la connexion directe (ou propose de le relancer s'il est déjà ouvert sans elle)
LaunchFlow() {
    if !ProcessExist("cs2.exe") {
        if (IniRead(IniFile, "State", "LaunchInfo", "") != "1") {
            MsgBox("Le menu va lancer CS2 avec les options " StrReplace(LaunchArgs, "{port}", NetconPort) ".`n`n-netconport permet au menu d'envoyer les commandes directement au jeu.`n-insecure désactive VAC pour cette session : pas de matchmaking, Premier ni FACEIT. Pour jouer en ligne, ferme le jeu et lance-le normalement depuis Steam, sans le menu.`n`nTes options de lancement Steam ne sont pas modifiées.", "Menu Stuf - lancement de CS2", 0x40040)
            IniWrite("1", IniFile, "State", "LaunchInfo")
        }
        if !LaunchGame()
            MsgBox("Steam n'a pas pu être lancé : démarre CS2 toi-même avec les options " StrReplace(LaunchArgs, "{port}", NetconPort) " dans les options de lancement de Steam.", "Menu Stuf", 0x40030)
    } else if !NetOpen() {
        if (MsgBox("CS2 est déjà lancé sans la connexion directe : le menu ne peut pas lui envoyer de commandes.`n`nFermer CS2 et le relancer avec les bonnes options ?", "Menu Stuf - CS2 déjà ouvert", 0x40024) = "Yes") {
            try WinClose("ahk_exe cs2.exe")
            ProcessWaitClose("cs2.exe", 10)
            if ProcessExist("cs2.exe") {
                try ProcessClose("cs2.exe")
                ProcessWaitClose("cs2.exe", 5)
            }
            Sleep(1500)
            LaunchGame()
        }
    }
}

; Icône près de l'horloge : ouvre le launcher
TraySetup() {
    ico := A_ScriptDir "\menu_stuf.ico"
    if FileExist(ico) {
        try TraySetIcon(ico)
    }
    A_IconTip := "Menu Stuf V." APP_VERSION
    try {
        A_TrayMenu.Insert("1&", "Ouvrir le launcher", (*) => OpenLauncher())
        A_TrayMenu.Default := "Ouvrir le launcher"
        A_TrayMenu.ClickCount := 1
    }
}

; Fenêtre d'accueil : lancer le jeu, map automatique, mise à jour, sauvegarde, packs, nouveautés, vérification, réglages
OpenLauncher() {
    global launcherHwnd, updRemote, updTick
    static lg := ""
    static st := ""
    static upT := ""
    if IsObject(lg) {
        try {
            lg.Show()
            LauncherTick()
            if (A_TickCount - updTick > 600000)
                SetTimer(UpCheck, -300)
            return
        }
    }
    p := WinPal()
    lg := WinNew("Menu Stuf", "")
    launcherHwnd := lg.Hwnd
    lg.MarginX := 24
    lg.MarginY := 20
    lg.SetFont("s" Round(WinSz() * 2) " bold c" p["accent"], WinFontName)
    lg.Add("Text", "x24 y18 w372", "MENU STUF")
    lg.SetFont("s" Max(8, WinSz() - 1) " norm c" p["dim"], WinFontName)
    lg.Add("Text", "x26 y+0 w372", "V." APP_VERSION " ProToxEU - lineups et entraînement CS2")
    upT := lg.Add("Text", "x26 y+2 w372 +0x100", "Mise à jour : vérification...")
    lg.Add("Text", "x24 y+12 w372 h2 Background" p["accent"])
    lg.SetFont("s" WinSz() " bold c" p["txt"], WinFontName)
    st := lg.Add("Text", "x24 y+14 w372", "")
    lg.SetFont("s" WinSz() " norm c" p["txt"], WinFontName)
    btnGo := lg.Add("Button", "x24 y+16 w372 h46 Default", "Lancer CS2")
    lg.SetFont("s" WinSz() " norm c" p["dim"], WinFontName)
    lg.Add("Text", "x24 y+16 w150", "Map au lancement :")
    lg.SetFont("s" WinSz() " norm c" p["txt"], WinFontName)
    names := MapChoices()
    amKey := StrLower(AutoMap)
    if (amKey != "last" && amKey != "none" && amKey != "") {
        has := false
        for x in names {
            if (x = AutoMap)
                has := true
        }
        if (!has && RegExMatch(AutoMap, "^\w+$"))
            names.Push(AutoMap)
    }
    mapItems := ["Dernière map jouée"]
    for x in names
        mapItems.Push(x)
    mapItems.Push("Aucune (menu principal)")
    ddMap := lg.Add("DropDownList", "x+6 yp-4 w212", mapItems)
    sel := 1
    if (amKey = "none") {
        sel := mapItems.Length
    } else if (amKey != "last" && amKey != "") {
        for k, x in mapItems {
            if (x = AutoMap)
                sel := k
        }
    }
    ddMap.Choose(sel)
    btnNews := lg.Add("Button", "x24 y+16 w180 h36", newsUnseen ? "Nouveautés  ●" : "Nouveautés")
    btnChk := lg.Add("Button", "x+12 yp w180 h36", "Vérification")
    btnSet := lg.Add("Button", "x24 y+10 w180 h36", "Réglages")
    btnDir := lg.Add("Button", "x+12 yp w180 h36", "Ouvrir le dossier")
    btnSave := lg.Add("Button", "x24 y+10 w180 h36", "Sauvegarder maintenant")
    btnPack := lg.Add("Button", "x+12 yp w180 h36", "Packs de stuffs")
    btnGuide := lg.Add("Button", "x24 y+10 w180 h36", "Guide de démarrage")
    btnRep := lg.Add("Button", "x+12 yp w180 h36", "Signaler un problème")
    lg.SetFont("s" Max(8, WinSz() - 1) " norm c" p["dim"], WinFontName)
    lg.Add("Text", "x24 y+16 w372 r2", "Fermer cette fenêtre laisse le menu actif (icône près de l'horloge). Dans CS2, appuie sur " MenuKey " pour ouvrir le menu.")
    lg.SetFont("s" WinSz() " norm c" p["txt"], WinFontName)
    btnQuit := lg.Add("Button", "x24 y+12 w140", "Quitter le menu")
    btnUpd := lg.Add("Button", "x+12 yp w220", "Vérifier les mises à jour")
    GoClick(*) {
        LaunchFlow()
        if AutoCheck
            SetTimer(StartCheck, -1500)   ; la vérification s'ouvre à côté du launcher
        LauncherTick()
    }
    MapChange(*) {
        global AutoMap
        i := ddMap.Value
        if (i = 1) {
            v := "last"
        } else if (i = mapItems.Length) {
            v := "none"
        } else {
            v := mapItems[i]
        }
        AutoMap := v
        IniWrite(v, IniFile, "Settings", "AutoMap")
    }
    NewsClick(*) {
        global newsUnseen
        newsUnseen := false
        btnNews.Text := "Nouveautés"
        ShowNews("", 5)
    }
    ChkClick(*) {
        SetTimer(StartCheck, -50)
    }
    SetClick(*) {
        ShowSettings()
    }
    DirClick(*) {
        Run('explorer "' A_ScriptDir '"')
    }
    SaveClick(*) {
        ManualBackup()
    }
    PackClick(*) {
        ShowPacks(lg.Hwnd)
    }
    GuideClick(*) {
        ShowWelcome()
    }
    RepClick(*) {
        ShowReport()
    }
    QuitClick(*) {
        ExitApp()
    }
    Hide(*) {
        SetTimer(LauncherTick, 0)
        lg.Hide()
        TrayTip("Le menu reste actif. Clique sur l'icône près de l'horloge pour rouvrir le launcher.", "Menu Stuf")
    }
    UpCheck() {
        global updRemote, updTick
        if !IsObject(lg)
            return
        updTick := A_TickCount
        updRemote := RemoteVersion()
        UpShow()
    }
    UpShow() {
        pp := WinPal()
        if (updRemote = "") {
            upT.SetFont("c" pp["dim"])
            upT.Text := "Mise à jour : impossible de vérifier (clique pour réessayer)"
        } else if (VerCompare(updRemote, APP_VERSION) > 0) {
            upT.SetFont("c" pp["accent"])
            upT.Text := "● Version " updRemote " disponible - clique ici pour l'installer"
        } else {
            upT.SetFont("c" pp["ok"])
            upT.Text := "● Menu à jour"
        }
    }
    UpClick(*) {
        if (updRemote != "" && VerCompare(updRemote, APP_VERSION) > 0) {
            if (MsgBox("Installer la version " updRemote " (tu as la " APP_VERSION ") ?`nTes stuffs, favoris, profils et réglages ne sont pas touchés.", "Mise à jour du menu", 0x40024) = "Yes")
                InstallUpdate()
        } else {
            upT.Text := "Mise à jour : vérification..."
            SetTimer(UpCheck, -100)
        }
    }
    UpdBtn(*) {
        upT.SetFont("c" WinPal()["dim"])
        upT.Text := "Mise à jour : vérification..."
        UpCheck()
        if (updRemote = "") {
            MsgBox("Impossible de joindre GitHub. Vérifie ta connexion Internet puis réessaie.", "Mise à jour du menu", 0x40030)
        } else if (VerCompare(updRemote, APP_VERSION) > 0) {
            UpClick()
        } else {
            MsgBox("Tu as déjà la dernière version (" APP_VERSION ").", "Mise à jour du menu", 0x40040)
        }
    }
    LauncherTick() {
        if !IsObject(lg)
            return
        if !ProcessExist("cs2.exe") {
            st.SetFont("c" WinPal()["dim"])
            st.Text := "● CS2 n'est pas lancé"
            btnGo.Text := "Lancer CS2"
        } else if NetOpen() {
            st.SetFont("c" WinPal()["ok"])
            st.Text := "● CS2 lancé et connecté au menu"
            btnGo.Text := "CS2 est prêt"
        } else {
            st.SetFont("c" WinPal()["bad"])
            st.Text := "● CS2 lancé sans connexion directe"
            btnGo.Text := "Relancer CS2 avec le menu"
        }
    }
    btnGo.OnEvent("Click", GoClick)
    ddMap.OnEvent("Change", MapChange)
    btnNews.OnEvent("Click", NewsClick)
    btnChk.OnEvent("Click", ChkClick)
    btnSet.OnEvent("Click", SetClick)
    btnDir.OnEvent("Click", DirClick)
    btnSave.OnEvent("Click", SaveClick)
    btnPack.OnEvent("Click", PackClick)
    btnGuide.OnEvent("Click", GuideClick)
    btnRep.OnEvent("Click", RepClick)
    upT.OnEvent("Click", UpClick)
    btnQuit.OnEvent("Click", QuitClick)
    btnUpd.OnEvent("Click", UpdBtn)
    lg.OnEvent("Close", Hide)
    ico := A_ScriptDir "\menu_stuf.ico"
    if FileExist(ico) {
        try {
            hIc := LoadPicture(ico, "w32 h32", &imgType)
            SendMessage(0x80, 1, hIc, lg)
            hIs := LoadPicture(ico, "w16 h16", &imgType)
            SendMessage(0x80, 0, hIs, lg)
        }
    }
    LauncherTick()
    SetTimer(LauncherTick, 1500)
    WinStyle(lg)
    lg.Show("AutoSize Center")
    if (updRemote != "" && A_TickCount - updTick < 600000)
        UpShow()
    else
        SetTimer(UpCheck, -600)
    if (IniRead(IniFile, "State", "WelcomeDone", "0") != "1")
        SetTimer(ShowWelcome, -900)
}

LaunchGame() {
    global launchWatch, autoMapDone
    args := StrReplace(LaunchArgs, "{port}", NetconPort)
    steamExe := ""
    try steamExe := RegRead("HKEY_CURRENT_USER\Software\Valve\Steam", "SteamExe")
    steamExe := StrReplace(steamExe, "/", "\")
    ok := false
    if (steamExe != "" && FileExist(steamExe)) {
        try {
            Run('"' steamExe '" -applaunch 730 ' args)
            ok := true
        }
    }
    if !ok {
        try {
            Run("steam://rungameid/730//" StrReplace(args, " ", "%20"))
            ok := true
        }
    }
    if ok {
        launchWatch := A_TickCount
        autoMapDone := false
        SetTimer(LaunchCheck, 3000)
    }
    return ok
}

; Après le lancement : attend que le port s'ouvre ; au bout de 2 minutes, prévient si le jeu n'a pas reçu les options
LaunchCheck() {
    global launchWatch, netFailTick, autoMapDone
    if (A_TickCount - launchWatch > 120000) {
        SetTimer(LaunchCheck, 0)
        if ProcessExist("cs2.exe") && !NetOpen()
            MsgBox("CS2 est lancé mais n'a pas reçu l'option -netconport " NetconPort ".`n`nAjoute-la dans les options de lancement de CS2 sur Steam (clic droit sur le jeu > Propriétés) :`n" StrReplace(LaunchArgs, "{port}", NetconPort) "`n`nFerme puis relance le jeu. Sans cette option, le menu ne peut pas envoyer de commandes.", "Menu Stuf", 0x40040)
        return
    }
    if !ProcessExist("cs2.exe")
        return
    netFailTick := 0
    if NetOpen() {
        SetTimer(LaunchCheck, 0)
        ToolTip("Connexion directe à CS2 active")
        SetTimer(() => ToolTip(), -2500)
        if (!autoMapDone) {
            autoMapDone := true
            if (AutoMapName() != "")
                SetTimer(AutoMapGo.Bind(1), -AutoMapDelay * 1000)
        }
    }
}

; Nom de la map à charger après le lancement ("" = aucune)
AutoMapName() {
    m := StrLower(AutoMap)
    if (m = "" || m = "none")
        return ""
    if (m = "last") {
        if (LastMap != "" && RegExMatch(LastMap, "^\w+$"))
            return LastMap
        return "de_dust2"
    }
    return RegExMatch(AutoMap, "^\w+$") ? AutoMap : ""
}

; Charge la map d'entraînement une fois le jeu prêt (un seul nouvel essai si le jeu n'était pas encore à l'écran d'accueil)
AutoMapGo(tryNo := 1, *) {
    if !ProcessExist("cs2.exe")
        return
    nm := AutoMapName()
    if (nm = "")
        return
    if (tryNo > 1 && InStr(RunAndReadLog("status", "main lump"), "main lump"))
        return
    if NetSend("map " nm) {
        ToolTip("Chargement de la map " nm "...")
        SetTimer(() => ToolTip(), -3500)
        if AutoExec
            SetTimer(AutoPracticeWait.Bind(0), -4000)   ; le cfg d'entraînement (bots, argent, etc.) s'exécute dès que la map est chargée
    }
    if (tryNo < 2)
        SetTimer(AutoMapGo.Bind(2), -20000)
}

; Attend la fin du chargement de la map (jusqu'à 90 s) puis exécute le cfg d'entraînement une fois
AutoPracticeWait(n := 0, *) {
    global execMap
    if !ProcessExist("cs2.exe")
        return
    txt := RunAndReadLog("status", "main lump")
    if RegExMatch(txt, "main lump") {
        Sleep(2500)   ; laisse les joueurs et les bots apparaître avant l'exec
        LoadMaps()
        mp := MapFromStatus(txt)
        execMap := (mp != "") ? mp : "?"
        RunPractice()
        ToolTip(PracticeCfg " exécuté")
        SetTimer(() => ToolTip(), -2000)
        return
    }
    if (n < 40)
        SetTimer(AutoPracticeWait.Bind(n + 1), -2000)
}

; Liste des maps proposées (tes fichiers de map + les maps officielles)
MapChoices() {
    LoadMaps()
    names := []
    for n in mapNames {
        if RegExMatch(n, "^\w+$") && SubStr(n, 1, 1) != "_"
            names.Push(n)
    }
    for n in ["de_ancient", "de_anubis", "de_dust2", "de_inferno", "de_mirage", "de_nuke", "de_overpass", "de_train", "de_vertigo"] {
        has := false
        for x in names {
            if (x = n)
                has := true
        }
        if !has
            names.Push(n)
    }
    return names
}

; =====================================================================
;  Dialogue avec le jeu (cfg + console.log)
; =====================================================================
WriteAndExec(cmd) {
    global cmdBusy
    cmdBusy += 1
    try {
        WriteAndExecRaw(cmd)
    } finally {
        cmdBusy -= 1
    }
}

WriteAndExecRaw(cmd) {
    global lastCmdTick
    lastCmdTick := A_TickCount
    cmd := "sv_cheats 1; " cmd   ; setpos, give, god, bot_place... exigent sv_cheats 1
    if !NetSend(cmd)
        NetWarn()
}

; Prévient (sans spammer) que le jeu n'est pas joignable
NetWarn() {
    static last := 0
    if (A_TickCount - last < 8000)
        return
    last := A_TickCount
    ToolTip("Pas de connexion à CS2 : ferme le jeu et relance le menu (il lance CS2 lui-même)")
    SetTimer(() => ToolTip(), -3500)
}

; Exécute une commande puis renvoie ce qui a été écrit dans console.log
; (nécessite l'option de lancement -condebug)
RunAndReadLog(cmd, pattern := "") {
    global cmdBusy
    cmdBusy += 1
    try {
        return RunAndReadLogRaw(cmd, pattern)
    } finally {
        cmdBusy -= 1
    }
}

RunAndReadLogRaw(cmd, pattern := "") {
    if !FileExist(ConsoleLog) || !NetOpen()
        return ""
    size := FileGetSize(ConsoleLog)
    WriteAndExec(cmd)
    last := ""
    Loop 12 {
        Sleep(120)
        newSize := FileGetSize(ConsoleLog)
        if (newSize < size)
            size := 0
        if (newSize > size) {
            txt := ReadFrom(ConsoleLog, size)
            last := txt
            if (pattern = "" || RegExMatch(txt, pattern))
                return txt
        }
    }
    return last
}

ReadFrom(path, pos) {
    txt := ""
    try {
        f := FileOpen(path, "r", "UTF-8")
        f.Seek(pos)
        txt := f.Read()
        f.Close()
    }
    return txt
}

; Corrige la hauteur des setpos : getpos donne la hauteur des yeux, setpos attend celle des pieds
AdjustZ(cmd) {
    return ShiftZ(cmd, TpZOffset)
}

RunCmd(cmd, info := "") {
    cmd := AdjustZ(cmd)
    if (info != "") {
        info := StrReplace(info, ";", ",")   ; un ; couperait la commande say
        cmd .= "; say " info
    }
    WriteAndExec(cmd)
}

; Retrouve la map en cours via la commande "status"
DetectMap() {
    return MapFromStatus(RunAndReadLog("status", "main lump"))
}

; Nom de la map (parmi tes fichiers) d'après la réponse de la commande status
MapFromStatus(txt) {
    if (txt = "")
        return ""
    if RegExMatch(txt, "\[\d+:\s*([A-Za-z0-9_\-/]+)\s*\|\s*main lump", &m) {
        SplitPath(m[1], &fname)
        for n in mapNames {
            if (StrLower(n) = StrLower(fname))
                return n
        }
    }
    for n in mapNames {
        if InStr(txt, n)
            return n
    }
    return ""
}

NormalizePos(txt) {
    pat := "i)setpos\s+(" NUM ")\s+(" NUM ")\s+(" NUM ")\s*;\s*setang\s+(" NUM ")\s+(" NUM ")"
    if RegExMatch(txt, pat, &m)
        return "setpos " m[1] " " m[2] " " m[3] "; setang " m[4] " " m[5]
    return ""
}

CapturePos() {
    txt := RunAndReadLog("getpos", "setpos\s+" NUM)
    return NormalizePos(txt)
}

; =====================================================================
;  Captures d'écran des stuffs (zone au centre de l'écran du jeu)
; =====================================================================
ShotDir(prof := "") {
    return ((prof = "") ? DataDir : ProfData(prof)) "\shots"
}

; Fichier image d'un stuff : lié à la map et à la position (donc stable si on renomme ou déplace le stuff)
ShotPath(mapName, cmd, prof := "") {
    if !RegExMatch(cmd, "i)setpos\s+(" NUM ")\s+(" NUM ")\s+(" NUM ")", &m)
        return ""
    return ShotDir(prof) "\" mapName "_" ShotCoordKey(cmd) ".bmp"
}

; Partie « coordonnées » du nom de fichier d'une capture ("" si le stuff n'a pas de position)
ShotCoordKey(cmd) {
    if !RegExMatch(cmd, "i)setpos\s+(" NUM ")\s+(" NUM ")\s+(" NUM ")", &m)
        return ""
    k := m[1] "_" m[2] "_" m[3]
    return StrReplace(StrReplace(k, "-", "m"), ".", "p")
}

; Capture ShotSize x ShotSize px au centre de la fenêtre CS2 (sinon de l'écran) et l'enregistre en .bmp
CaptureShot(dest) {
    sz := ShotSize
    cx := A_ScreenWidth // 2
    cy := A_ScreenHeight // 2
    if WinExist("ahk_exe cs2.exe") {
        try {
            WinGetClientPos(&wx, &wy, &ww, &wh, "ahk_exe cs2.exe")
            if (ww > 200 && wh > 200) {
                cx := wx + ww // 2
                cy := wy + wh // 2
            }
        }
    }
    sx := cx - sz // 2
    sy := cy - sz // 2
    stride := ((sz * 3 + 3) // 4) * 4
    imgSize := stride * sz
    bi := Buffer(40, 0)
    NumPut("UInt", 40, bi, 0)
    NumPut("Int", sz, bi, 4)
    NumPut("Int", sz, bi, 8)
    NumPut("UShort", 1, bi, 12)
    NumPut("UShort", 24, bi, 14)
    NumPut("UInt", imgSize, bi, 20)
    hdcScr := DllCall("GetDC", "Ptr", 0, "Ptr")
    hdcMem := DllCall("CreateCompatibleDC", "Ptr", hdcScr, "Ptr")
    bits := 0
    hbm := DllCall("CreateDIBSection", "Ptr", hdcScr, "Ptr", bi, "UInt", 0, "Ptr*", &bits, "Ptr", 0, "UInt", 0, "Ptr")
    ok := false
    if (hbm && bits) {
        oldObj := DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hbm, "Ptr")
        DllCall("BitBlt", "Ptr", hdcMem, "Int", 0, "Int", 0, "Int", sz, "Int", sz, "Ptr", hdcScr, "Int", sx, "Int", sy, "UInt", 0x40CC0020)
        try {
            DirCreate(ShotDir())
            hdr := Buffer(54, 0)
            NumPut("UShort", 0x4D42, hdr, 0)
            NumPut("UInt", 54 + imgSize, hdr, 2)
            NumPut("UInt", 54, hdr, 10)
            Loop 40
                NumPut("UChar", NumGet(bi, A_Index - 1, "UChar"), hdr, 14 + A_Index - 1)
            f := FileOpen(dest, "w")
            f.RawWrite(hdr, 54)
            f.RawWrite(bits, imgSize)
            f.Close()
            ok := true
        }
        DllCall("SelectObject", "Ptr", hdcMem, "Ptr", oldObj)
        DllCall("DeleteObject", "Ptr", hbm)
    }
    DllCall("DeleteDC", "Ptr", hdcMem)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdcScr)
    return ok
}

HideShot() {
    if IsObject(gs)
        gs.Hide()
}

; Affiche (ou cache) la capture du stuff sélectionné. preview = true : aperçu depuis les réglages
UpdateShot(preview := false) {
    global gs, gsPic, gsTxt
    if (!ShotOn || (!menuOpen && !preview)) {
        HideShot()
        return
    }
    path := ""
    if preview {
        Loop Files, ShotDir() "\*.bmp" {
            if (SubStr(A_LoopFileName, 1, 1) != "_") {
                path := A_LoopFileFullPath
                break
            }
        }
    } else {
        cur := CurrentItem()
        if IsObject(cur)
            path := ShotPath(StrSplit(cur[5], "|")[1], cur[2])
        if !ShotValid(path) {
            HideShot()
            return
        }
    }
    if (preview && path != "" && !ShotValid(path))
        path := ""
    bw := ovBorder
    if !IsObject(gs) {
        gs := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
        gs.BackColor := SelColor()
        gsPic := gs.Add("Picture", "x0 y0 w" ShotZoom " h" ShotZoom, "")
        gsTxt := gs.Add("Text", "x0 y0 w" ShotZoom " h" ShotZoom " Center 0x200 Background" SelColor() " cA0A6AE", "Aperçu de la capture")
        if (bw > 0) {
            ; liseré dessiné PAR-DESSUS l'image (créé après elle)
            bc := BorderColor()
            gs.Add("Text", "x0 y0 w" ShotZoom " h" bw " Background" bc, "")
            gs.Add("Text", "x0 y" (ShotZoom - bw) " w" ShotZoom " h" bw " Background" bc, "")
            gs.Add("Text", "x0 y0 w" bw " h" ShotZoom " Background" bc, "")
            gs.Add("Text", "x" (ShotZoom - bw) " y0 w" bw " h" ShotZoom " Background" bc, "")
        }
    }
    if (path != "") {
        try {
            gsPic.Value := "*w" ShotZoom " *h" ShotZoom " " path
            gsPic.Visible := true
            gsTxt.Visible := false
        } catch {
            gsPic.Visible := false
            gsTxt.Visible := true
        }
    } else {
        gsPic.Visible := false
        gsTxt.Visible := true
    }
    tw := ShotZoom
    vl := SysGet(76)
    vt := SysGet(77)
    vw := SysGet(78)
    vh := SysGet(79)
    if (ShotPlace = 1) {
        MonitorGet(MonitorGetPrimary(), &ml, &mt, &mr, &mb)
        px := mr - tw - 12
        py := mt + 12
    } else {
        px := Max(vl, Min(ShotX, vl + vw - tw))
        py := Max(vt, Min(ShotY, vt + vh - tw))
    }
    gs.Show("NA x" px " y" py " w" tw " h" tw)
    if (ShotCorner > 0) {
        rd := 2 * Min(ShotCorner, ShotZoom // 2)
        WinSetRegion("0-0 W" tw " H" tw " R" rd "-" rd, gs)
    } else {
        WinSetRegion("", gs)
    }
    WinSetTransparent(Max(ovOpacity, 200), gs)
}

; =====================================================================
;  Affichage
; =====================================================================
Count() {
    if (level = 4)
        return MainLabels().Length
    if (level = 0)
        return mapNames.Length
    if (level = 1)
        return cats.Length
    if (level = 2)
        return items[cats[catIdx]].Length
    return results.Length
}

CurrentItem() {
    if (level = 2 && Count() > 0)
        return items[cats[catIdx]][itemIdx]
    if (level = 3 && results.Length > 0)
        return results[resIdx]
    return ""
}

DispName(it, withCat) {
    str := it[1]
    if favs.Has(it[5])
        str := "* " str
    if withCat
        str .= "  [" it[4] "]"
    if locks.Has("it|" it[5])
        str .= "  " LOCK_ICON
    return str
}

; Entrées du menu principal (ouvert par la touche MenuKey)
MainItems() {
    out := [["stuffs", "Stuffs (maps et catégories)"]
        , ["util", "Utilitaires (bots, god mode, noclip...)"]
        , ["last", "Relancer le dernier stuff"]
        , ["changemap", "Changer de map"]
        , ["quiz", "Quiz : stuff au hasard (sans les infos)"]]
    if IsObject(quizCur)
        out.Push(["quizans", "Quiz : voir la réponse"])
    out.Push(["sep", "- - - - - - - - - - - -"]
        , ["savelast", "Enregistrer le dernier lancer comme stuff"]
        , ["save", "Sauvegarder la position actuelle"]
        , ["manage", "Gérer les stuffs et les catégories"]
        , ["share", "Profils et partage de stuffs"]
        , ["sep", "- - - - - - - - - - - -"]
        , ["settings", "Réglages du menu"]
        , ["news", "Nouveautés (historique des versions)"]
        , ["exec", "Relancer l'exec de " PracticeCfg]
        , ["check", "Vérifier l'installation"])
    return out
}

MainLabels() {
    out := []
    for it in MainItems()
        out.Push(it[2])
    return out
}

MainSelect() {
    global level
    id := MainItems()[mainIdx][1]
    if (id = "sep")
        return
    if (id = "stuffs") {
        OpenStuffs()
        return
    }
    if (id = "util") {
        OpenUtil()
        return
    }
    CloseMenu()
    if (id = "close")
        return
    Sleep(60)
    if (id = "last")
        RepeatLast()
    else if (id = "changemap")
        ShowMapChange()
    else if (id = "savelast")
        SaveLastThrow()
    else if (id = "quiz")
        QuizStart()
    else if (id = "quizans")
        QuizReveal()
    else if (id = "save")
        ShowSaveDialog()
    else if (id = "manage")
        ShowManager()
    else if (id = "share")
        ShowShare()
    else if (id = "news")
        ShowNews("", 5)
    else if (id = "settings")
        ShowSettings()
    else if (id = "exec")
        ForceExec()
    else if (id = "check")
        SetTimer(StartCheck, -50)
}

; =====================================================================
;  Nouveautés : fenêtre qui affiche le CHANGELOG des versions récentes
; =====================================================================
; Renvoie [[version, texte], ...] (les plus récentes d'abord) d'après CHANGELOG.md
ReadChangelog() {
    f := A_ScriptDir "\CHANGELOG.md"
    out := []
    if !FileExist(f)
        return out
    ver := ""
    body := ""
    for ln in StrSplit(FileRead(f, "UTF-8"), "`n", "`r") {
        if RegExMatch(ln, "^##\s+v?(\d+(?:\.\d+)*)", &m) {
            if (ver != "")
                out.Push([ver, Trim(body, "`n")])
            ver := m[1]
            body := ""
            continue
        }
        if (ver != "")
            body .= ln "`n"
    }
    if (ver != "")
        out.Push([ver, Trim(body, "`n")])
    return out
}

; Texte lisible : sans mise en forme Markdown
CleanLogText(txt) {
    txt := StrReplace(txt, Chr(96), "")
    txt := StrReplace(txt, "**", "")
    txt := RegExReplace(txt, "m)^\s*-\s+", "• ")
    return StrReplace(txt, "`n", "`r`n")
}

; Affiche les versions plus récentes que sinceVer (toutes si vide), jusqu'à maxN versions, sans dépasser la version actuelle
; =====================================================================
;  Style des fenêtres (thème, couleur d'accent, police) - réglable dans l'onglet « Fenêtres »
; =====================================================================
Shade(hex, d) {
    r := Max(0, Min(255, Integer("0x" SubStr(hex, 1, 2)) + d))
    g := Max(0, Min(255, Integer("0x" SubStr(hex, 3, 2)) + d))
    b := Max(0, Min(255, Integer("0x" SubStr(hex, 5, 2)) + d))
    return Format("{:02X}{:02X}{:02X}", r, g, b)
}

; Palette courante : fond, champs, texte, texte discret, accent, ok, erreur, sombre ou non
WinPal() {
    dark := (WinThemeSel = "dark")
    bg := ""
    if (WinThemeSel = "menu") {
        bg := ovBg
        dark := (Lum(ovBg) < 140)
    } else if dark {
        bg := "1B1F26"
    } else {
        bg := "F3F4F6"
    }
    p := Map()
    p["dark"] := dark
    p["bg"] := bg
    p["edit"] := dark ? Shade(bg, 16) : (WinThemeSel = "menu" ? Shade(bg, 14) : "FFFFFF")
    p["txt"] := dark ? "E6E9EE" : "1B1F26"
    p["dim"] := dark ? "8A8F98" : "6B7280"
    p["accent"] := WinAccent
    p["ok"] := dark ? "4FD17A" : "1B6E1B"
    p["bad"] := dark ? "FF6B6B" : "C0392B"
    return p
}

WinSz() {
    return Round(10 * WinScale / 100)
}

; Nouvelle fenêtre aux couleurs et à la police choisies
WinNew(title, opts := "+AlwaysOnTop") {
    p := WinPal()
    g := Gui(opts, title)
    g.BackColor := p["bg"]
    g.SetFont("s" WinSz() " c" p["txt"], WinFontName)
    return g
}

BgrOf(hex) {
    r := Integer("0x" SubStr(hex, 1, 2))
    g := Integer("0x" SubStr(hex, 3, 2))
    b := Integer("0x" SubStr(hex, 5, 2))
    return (b << 16) | (g << 8) | r
}

; À appeler avant g.Show() : barre de titre et contrôles Windows en mode sombre quand le thème l'est
WinStyle(g) {
    p := WinPal()
    if !p["dark"]
        return
    try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", g.Hwnd, "Int", 20, "Int*", 1, "Int", 4)
    for hw, c in g {
        t := c.Type
        try {
            if (t = "Edit") {
                c.Opt("+Background" p["edit"])
                DllCall("uxtheme\SetWindowTheme", "Ptr", c.Hwnd, "Str", "DarkMode_CFD", "Ptr", 0)
            } else if (t = "ComboBox" || t = "DDL") {
                try c.Opt("+Background" p["edit"])   ; zone de saisie / liste en sombre
                DllCall("uxtheme\SetWindowTheme", "Ptr", c.Hwnd, "Str", "DarkMode_CFD", "Ptr", 0)
                ; le champ de saisie interne d'une liste modifiable (ComboBox) a son propre fond
                if (t = "ComboBox") {
                    cbi := Buffer(A_PtrSize = 8 ? 64 : 52, 0)
                    NumPut("UInt", cbi.Size, cbi, 0)
                    if DllCall("user32\GetComboBoxInfo", "Ptr", c.Hwnd, "Ptr", cbi) {
                        hEd := NumGet(cbi, A_PtrSize = 8 ? 48 : 44, "Ptr")
                        if hEd
                            DllCall("uxtheme\SetWindowTheme", "Ptr", hEd, "Str", "DarkMode_CFD", "Ptr", 0)
                    }
                }
            } else if (t = "ListView") {
                DllCall("uxtheme\SetWindowTheme", "Ptr", c.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
                SendMessage(0x1001, 0, BgrOf(p["edit"]), c)   ; fond
                SendMessage(0x1026, 0, BgrOf(p["edit"]), c)   ; fond du texte
                SendMessage(0x1024, 0, BgrOf(p["txt"]), c)    ; texte
            } else if (t = "ListBox") {
                c.Opt("+Background" p["edit"])
                DllCall("uxtheme\SetWindowTheme", "Ptr", c.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
            } else if (t = "CheckBox" || t = "Radio") {
                c.Opt("-Theme")
            } else if (t = "Button" || t = "Slider") {
                DllCall("uxtheme\SetWindowTheme", "Ptr", c.Hwnd, "Str", "DarkMode_Explorer", "Ptr", 0)
            }
        }
    }
}

; Onglets sans le contrôle Tab de Windows (qui ne se colore pas) : même interface (UseTab, Move, Value)
; names = noms des onglets ; x, y, w = position et largeur de la barre d'onglets
WinTabs(g, names, x, y, w) {
    p := WinPal()
    st := Map("cur", 1, "start", Map(), "groups", [], "hdr", [])
    n := names.Length
    cw := w // n
    CountCtrls() {
        k := 0
        for hw, c in g
            k += 1
        return k
    }
    TabPick(i, *) {
        st["cur"] := i
        for k, grp in st["groups"] {
            for c in grp
                c.Visible := (k = i)
        }
        for k, h in st["hdr"] {
            h.SetFont((k = i) ? "bold c" p["accent"] : "norm c" p["txt"])
            h.Redraw()
        }
        st["ul"].Move(x + (i - 1) * cw + 6, y + 30, cw - 12)
    }
    for i, nm in names {
        h := g.Add("Text", "x" (x + (i - 1) * cw) " y" y " w" cw " h28 Center +0x200 +0x100", nm)
        h.SetFont("s" Max(8, WinSz() - 1))
        h.OnEvent("Click", TabPick.Bind(i))
        st["hdr"].Push(h)
    }
    g.Add("Text", "x" x " y" (y + 31) " w" w " h1 Background" p["dim"])
    st["ul"] := g.Add("Text", "x" (x + 6) " y" (y + 30) " w" (cw - 12) " h3 Background" p["accent"])
    Use(this, i) {
        if (i >= 1) {
            st["start"][i] := CountCtrls()
            return
        }
        all := []
        for hw, c in g
            all.Push(c)
        st["groups"] := []
        k := 1
        while (k <= n) {
            a := st["start"].Has(k) ? st["start"][k] : all.Length
            b := st["start"].Has(k + 1) ? st["start"][k + 1] : all.Length
            grp := []
            Loop (b - a)
                grp.Push(all[a + A_Index])
            st["groups"].Push(grp)
            k += 1
        }
        TabPick(1)
    }
    GetV(this) {
        return st["cur"]
    }
    NoMove(this, *) {
    }
    t := Object()
    t.DefineProp("UseTab", {Call: Use})
    t.DefineProp("Move", {Call: NoMove})
    t.DefineProp("Value", {Get: GetV})
    return t
}

; Ouvre la fenêtre de sauvegarde avec la position, le type et le temps du dernier lancer mesuré par le chrono
SaveLastThrow() {
    if !(TimerOn || tmMeasuring) {
        MsgBox("Active d'abord le chronomètre (Réglages, onglet Chrono) : c'est lui qui mémorise tes lancers.", "Dernier lancer", 0x40040)
        return
    }
    if (!IsObject(tmLastThrow) || tmLastThrow["pos"] = "") {
        MsgBox("Aucun lancer mémorisé.`n`nLance une grenade au clic (pas avec la touche de relance), puis rouvre cette entrée.", "Dernier lancer", 0x40040)
        return
    }
    k := tmLastThrow["kind"]
    typ := (k = "Smoke") ? "Smoke" : (k = "Flash") ? "Flash" : (k = "HE") ? "HE" : (k = "Molotov" || k = "Incendiaire") ? "Molotov" : "Autre"
    ShowSaveDialog("", "", Map("pos", tmLastThrow["pos"], "type", typ, "secs", tmLastThrow["secs"]))
}

; Changement de map : envoie « map <nom> » au jeu (le cfg d'entraînement se relance tout seul à la détection de la nouvelle map)
ShowMapChange() {
    static open := ""
    if IsObject(open) {
        try open.Show()
        return
    }
    LoadMaps()
    names := []
    for n in mapNames {
        if RegExMatch(n, "^\w+$") && SubStr(n, 1, 1) != "_"
            names.Push(n)
    }
    for n in ["de_ancient", "de_anubis", "de_dust2", "de_inferno", "de_mirage", "de_nuke", "de_overpass", "de_train", "de_vertigo"] {
        has := false
        for x in names {
            if (x = n)
                has := true
        }
        if !has
            names.Push(n)
    }
    d := WinNew("Changer de map")
    open := d
    d.Add("Text", "x12 y12 w300", "Choisis la map à charger (sélection = map détectée en dernier) :")
    lb := d.Add("ListBox", "x12 y+8 w300 r12", names)
    cur := 1
    for k, n in names {
        if (n = LastMap)
            cur := k
    }
    lb.Choose(cur)
    d.Add("Text", "x12 y+10 w300", "Ou tape un nom de map (ex. de_mirage, cs_office) :")
    ed := d.Add("Edit", "x12 y+4 w300")
    btnNo := d.Add("Button", "x12 y+12 w112", "Fermer")
    btnGo := d.Add("Button", "x132 yp w180 Default", "Changer de map")
    Go(*) {
        nm := Trim(ed.Value)
        if (nm = "")
            nm := lb.Text
        if !RegExMatch(nm, "^\w+$") {
            MsgBox("Nom de map invalide.", "Changer de map", 0x40030)
            return
        }
        if !NetSend("map " nm)
            NetWarn()
        Shut()
    }
    Shut(*) {
        open := ""
        try d.Destroy()
        try WinActivate("ahk_exe cs2.exe")
    }
    lb.OnEvent("DoubleClick", Go)
    btnGo.OnEvent("Click", Go)
    btnNo.OnEvent("Click", Shut)
    d.OnEvent("Close", Shut)
    d.OnEvent("Escape", Shut)
    WinStyle(d)
    d.Show("AutoSize Center")
}

; Zone de texte des nouveautés : RichEdit (titres en gras, couleur d'accent) ou simple champ si indisponible
NewsBox(g, txt) {
    try {
        p := WinPal()
        DllCall("LoadLibrary", "Str", "Msftedit.dll")
        rc := g.Add("Custom", "ClassRICHEDIT50W x12 y+8 w620 h380 +0x200000 +0x800 +0x4 +0x40 +Border")
        rc.Text := txt
        SendMessage(0x443, 0, BgrOf(p["edit"]), rc)   ; fond
        cf := Buffer(92, 0)
        NumPut("UInt", 92, cf, 0)
        NumPut("UInt", 0x40000000, cf, 4)              ; CFM_COLOR
        NumPut("UInt", BgrOf(p["txt"]), cf, 20)
        SendMessage(0x444, 4, cf, rc)                  ; texte par défaut (tout)
        pos := 0
        for ln in StrSplit(txt, "`n", "`r") {
            ln := RTrim(ln, "`r")
            if (SubStr(ln, 1, 8) = "VERSION ") {
                cr := Buffer(8, 0)
                NumPut("Int", pos, cr, 0)
                NumPut("Int", pos + StrLen(ln), cr, 4)
                SendMessage(0x437, 0, cr, rc)          ; sélection de la ligne
                cf2 := Buffer(92, 0)
                NumPut("UInt", 92, cf2, 0)
                NumPut("UInt", 0x40000001, cf2, 4)     ; CFM_COLOR | CFM_BOLD
                NumPut("UInt", 1, cf2, 8)              ; CFE_BOLD
                NumPut("UInt", BgrOf(p["accent"]), cf2, 20)
                SendMessage(0x444, 1, cf2, rc)         ; applique à la sélection
            }
            pos += StrLen(ln) + 1
        }
        cr0 := Buffer(8, 0)
        SendMessage(0x437, 0, cr0, rc)                 ; curseur au début
        return rc
    }
    return g.Add("Edit", "x12 y+8 w620 r20 ReadOnly +VScroll", txt)
}

ShowNews(sinceVer := "", maxN := 5) {
    global clGui
    txt := ""
    n := 0
    for e in ReadChangelog() {
        if (VerCompare(e[1], APP_VERSION) > 0)
            continue
        if (sinceVer != "" && VerCompare(e[1], sinceVer) <= 0)
            continue
        n += 1
        if (n > maxN)
            break
        txt .= "VERSION " e[1] "`r`n" CleanLogText(e[2]) "`r`n`r`n"
    }
    if (txt = "") {
        MsgBox("Aucune nouveauté à afficher (CHANGELOG.md introuvable ou vide).", "Menu Stuf", 0x40040)
        return false
    }
    if IsObject(clGui)
        try clGui.Destroy()
    clGui := WinNew("Nouveautés - Menu Stuf V." APP_VERSION, "+AlwaysOnTop")
    clGui.Add("Text", "x12 y12 w620", "Voici ce qui a changé dans le menu :")
    ed := NewsBox(clGui, RTrim(txt, "`r`n"))
    chk := clGui.Add("CheckBox", "x12 y+10 w620" (ShowChangelogOn ? "" : " Checked"), "Ne plus afficher cette fenêtre après les mises à jour (réglage ShowChangelog)")
    btn := clGui.Add("Button", "x12 y+10 w160 Default", "Fermer")
    NewsToggle(*) {
        global ShowChangelogOn
        ShowChangelogOn := !chk.Value
        IniWrite(ShowChangelogOn ? 1 : 0, IniFile, "Settings", "ShowChangelog")
    }
    NewsClose(*) {
        global clGui
        try clGui.Destroy()
        clGui := ""
    }
    chk.OnEvent("Click", NewsToggle)
    btn.OnEvent("Click", NewsClose)
    clGui.OnEvent("Close", NewsClose)
    clGui.OnEvent("Escape", NewsClose)
    WinStyle(clGui)
    clGui.Show("AutoSize Center")
    btn.Focus()
    return true
}

; =====================================================================
;  Quiz : un stuff au hasard de la map, sans l'angle ni les infos du chat
; =====================================================================
; Tu es téléporté au point de départ (avec la grenade) mais la visée n'est pas réglée et le message
; du chat n'est pas envoyé : à toi de retrouver le lineup. « Quiz : voir la réponse » relance le stuff complet.
QuizStart() {
    global quizCur, LastMap
    LoadMaps()
    target := LastMap
    if (AutoDetect && FileExist(ConsoleLog) && NetOpen()) {
        det := DetectMap()
        if (det != "")
            target := det
    }
    path := ""
    for i, n in mapNames {
        if (n = target)
            path := mapFiles[i]
    }
    if (path = "") {
        ToolTip("Quiz : map introuvable (ouvre d'abord les stuffs de ta map)")
        SetTimer(() => ToolTip(), -2500)
        return
    }
    pool := []
    for e in ReadEntries(path)[2] {
        if (e[1] != UTIL_CAT && RegExMatch(e[3], "i)setpos"))
            pool.Push(e)
    }
    if (pool.Length = 0) {
        ToolTip("Quiz : aucun stuff avec position dans " target)
        SetTimer(() => ToolTip(), -2500)
        return
    }
    pick := pool[Random(1, pool.Length)]
    tries := 0
    while (pool.Length > 1 && IsObject(quizCur) && quizCur[1] = pick[1] && quizCur[2] = pick[2] && tries < 8) {
        pick := pool[Random(1, pool.Length)]
        tries += 1
    }
    quizCur := pick
    qcmd := RegExReplace(pick[3], "i)\s*;?\s*setang\s+" NUM "\s+" NUM "(?:\s+" NUM ")?", "")
    qcmd := Trim(RegExReplace(qcmd, "\s*;(\s*;)+", ";"), " `t;")
    RunCmd(qcmd)
    QzShow("QUIZ : " pick[2], "(" pick[1] ")")
}

; Bandeau du quiz (haut de l'écran) : reste affiché jusqu'à « voir la réponse » ou un nouveau quiz
QzShow(l1, l2) {
    global qzGui, qzB
    QzHide()
    if (ovBorder > 0) {
        qzB := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
        qzB.BackColor := BorderColor()
    }
    dark := (Lum(ovBg) < 140)
    cTxt := dark ? "FFFFFF" : "111111"
    thh := ThemeById(ovTheme)
    if IsObject(thh)
        cTxt := thh[4]
    fnt := (ovFont = "") ? "Consolas" : ovFont
    qzGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
    qzGui.BackColor := ovBg
    qzGui.MarginX := 14 + ovCorner // 3
    qzGui.MarginY := 8 + ovCorner // 4
    qzGui.SetFont("s" FS(15) " bold c" cTxt, fnt)
    qzGui.Add("Text", "Center", l1 "`n" l2)
    qzGui.Show("NA AutoSize x0 y0")
    qzGui.GetPos(, , &w, &h)
    MonitorGet(MonitorGetPrimary(), &ml, &mt, &mr, &mb)
    qzGui.Move(ml + (mr - ml - w) // 2, mt + 12 + ovBorder)
    qzGui.GetPos(&px, &py, &pw, &ph)
    dia := 2 * Min(ovCorner, ph // 2)
    if (ovCorner > 0)
        WinSetRegion("0-0 W" pw " H" ph " R" dia "-" dia, qzGui)
    WinSetTransparent(ovOpacity, qzGui)
    if IsObject(qzB) {
        b := ovBorder
        bw := pw + 2 * b
        bh := ph + 2 * b
        qzB.Show("NA x" (px - b) " y" (py - b) " w" bw " h" bh)
        if (ovCorner > 0) {
            bd := dia + 2 * b
            WinSetRegion("0-0 W" bw " H" bh " R" bd "-" bd, qzB)
        }
        WinSetTransparent(ovOpacity, qzB)
        DllCall("SetWindowPos", "Ptr", qzGui.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
    }
}

QzHide() {
    global qzGui, qzB
    if IsObject(qzGui)
        try qzGui.Destroy()
    if IsObject(qzB)
        try qzB.Destroy()
    qzGui := ""
    qzB := ""
}

QuizReveal() {
    if !IsObject(quizCur) {
        ToolTip("Aucun quiz en cours")
        SetTimer(() => ToolTip(), -1800)
        return
    }
    QzHide()
    RunCmd(quizCur[3], SplitInfo(quizCur[4])[1])
    ToolTip("Réponse : " quizCur[2])
    SetTimer(() => ToolTip(), -2500)
}

Render() {
    names := []
    sel := 1
    title := ""
    if (level = 4) {
        names := MainLabels()
        sel := mainIdx
        title := "MENU"
    } else if (level = 0) {
        names := mapNames
        sel := mapIdx
        title := "MAPS"
    } else if (level = 1) {
        for c in cats
            names.Push(locks.Has("cat|" c) ? c "  " LOCK_ICON : c)
        sel := catIdx
        title := loadedMap
    } else if (level = 2) {
        c := cats[catIdx]
        virt := (c = FAV_CAT || c = REC_CAT)
        for it in items[c]
            names.Push(DispName(it, virt))
        sel := itemIdx
        title := utilMode ? "UTILITAIRES" : loadedMap " > " c
    } else {
        for it in results
            names.Push(DispName(it, true))
        sel := resIdx
        title := "Recherche : " query "_"
    }
    n := names.Length
    if (n = 0) {
        SetList([(level = 2) ? "(vide - " AddKey " pour créer un stuff)" : "(vide)"], 0)
    } else {
        start := Max(1, Min(sel - 6, n - 12))
        vis := []
        Loop Min(13, n) {
            i := start + A_Index - 1
            vis.Push((i = sel ? "> " : "   ") names[i])
        }
        SetList(vis, sel - start + 1)
    }
    titleCtl.Text := title
    cur := CurrentItem()
    infoTxt := ""
    if IsObject(cur) {
        if (cur[3] != "")
            infoTxt := "Info : " cur[3]
        if (cur.Length >= 7 && cur[7] != "") {
            nl := (infoTxt != "") ? "`n" : ""
            infoTxt .= nl "Tags : " TagsDisp(cur[7])
        }
        ft := FlightTime(cur[2])
        if (ft != "")
            infoTxt .= ((infoTxt != "") ? "`n" : "") "Temps de vol : " FlightText(ft)
    }
    infoCtl.Text := infoTxt
    hintCtl.Text := HintText() "`nCtrl+Z : annuler la dernière suppression de stuff"
    ShowOverlay()
    UpdateShot()
}

HintText() {
    if (level = 4)
        return "Haut/Bas : naviguer   Entrée : choisir   Échap : fermer"
    if (level = 0)
        return "Droite/Entrée : choisir la map"
    if (level = 1)
        return "Droite : ouvrir la catégorie   Tab : recherche   " LockKey " : cadenas   " AddKey " : nouveau stuff"
    if (level = 2)
        return "Entrée : lancer le stuff   Tab : recherche   " FavKey " : favori   " LockKey " : cadenas   " AddKey " : nouveau stuff"
    return "Tape pour filtrer   Entrée : lancer   Échap : retour`n" FavKey " : favori   " LockKey " : cadenas   " AddKey " : nouveau stuff"
}

SetStatus(msg) {
    statusCtl.Text := msg
    SetTimer(ClearStatus, -3000)
}

ClearStatus() {
    statusCtl.Text := ""
}

; =====================================================================
;  Navigation
; =====================================================================
; Touche d'ouverture : affiche le menu principal
Toggle() {
    global menuOpen, level, mainIdx, utilMode
    if menuOpen {
        CloseMenu()
        return
    }
    utilMode := false
    level := 4
    mainIdx := 1
    menuOpen := true
    Render()
}

; Entrée « Stuffs » : détecte la map (et lance l'exec si besoin) puis ouvre le menu des stuffs
OpenStuffs() {
    global menuOpen, level, mapIdx, catIdx, itemIdx, LastMap, utilMode
    utilMode := false
    LoadMaps()   ; relit le dossier maps\ à chaque ouverture
    if (mapNames.Length = 0) {
        MsgBox("Aucun fichier .txt dans " MapsDir)
        return
    }
    msg := ""
    target := LastMap
    detMap := ""
    if AutoDetect {
        if !FileExist(ConsoleLog) {
            msg := "Détection impossible : console.log absent (option -condebug ?)"
        } else {
            det := DetectMap()
            if (det != "") {
                target := det
                detMap := det
                msg := "Map détectée : " det
            } else {
                msg := "Map non détectée, dernière map utilisée"
            }
        }
    }
    if (AutoExec && EnsurePractice(detMap))
        msg := (msg != "") ? msg "`n" PracticeCfg " exécuté" : PracticeCfg " exécuté"
    mapIdx := 1
    level := 0
    for i, name in mapNames {
        if (name = target) {
            mapIdx := i
            LoadMapStuff(i)
            LastMap := name
            level := 1
            catIdx := 1
            break
        }
    }
    menuOpen := true
    Render()
    if (msg != "")
        SetStatus(msg)
}

CloseMenu() {
    global menuOpen
    menuOpen := false
    if ih.InProgress
        ih.Stop()
    g.Hide()
    if IsObject(gb)
        gb.Hide()
    HideShot()
}

Move(d) {
    global mapIdx, catIdx, itemIdx, resIdx, mainIdx
    n := Count()
    if (n = 0)
        return
    if (level = 4) {
        items4 := MainItems()
        Loop n {
            mainIdx := Mod(mainIdx - 1 + d + n, n) + 1
            if (items4[mainIdx][1] != "sep")
                break
        }
    } else if (level = 0) {
        mapIdx := Mod(mapIdx - 1 + d + n, n) + 1
    } else if (level = 1) {
        catIdx := Mod(catIdx - 1 + d + n, n) + 1
    } else if (level = 2) {
        itemIdx := Mod(itemIdx - 1 + d + n, n) + 1
    } else {
        resIdx := Mod(resIdx - 1 + d + n, n) + 1
    }
    Render()
}

Select() {
    global level, catIdx, itemIdx, LastMap
    if (level = 4) {
        MainSelect()
        return
    }
    if (Count() = 0)
        return
    if (level = 0) {
        LoadMapStuff(mapIdx)
        LastMap := mapNames[mapIdx]
        IniWrite(LastMap, IniFile, "State", "LastMap")
        level := 1
        catIdx := 1
    } else if (level = 1) {
        level := 2
        itemIdx := 1
    } else {
        it := CurrentItem()
        RunCmd(it[2], it[3])
        AddRecent(it)
        if CloseAfterRun
            CloseMenu()
        return
    }
    Render()
}

Back() {
    global level, utilMode
    if (level = 3) {
        ExitSearch()
        return
    }
    if (level = 4) {
        CloseMenu()
        return
    }
    if (level = 2 && utilMode) {
        utilMode := false
        level := 4
        Render()
        return
    }
    if (level = 0) {
        level := 4
        Render()
        return
    }
    level -= 1
    Render()
}

EscKey() {
    if (level = 3) {
        ExitSearch()
        return
    }
    CloseMenu()
}

; ---------- Recherche rapide ----------
StartSearch() {
    global level, prevLevel, query, resIdx
    if (level != 1 && level != 2) {
        SetStatus("Choisis d'abord une map")
        return
    }
    prevLevel := level
    query := ""
    resIdx := 1
    level := 3
    UpdateResults()
    ih.Start()
    Render()
}

ExitSearch() {
    global level
    if ih.InProgress
        ih.Stop()
    level := prevLevel
    Render()
}

TabKey() {
    if (level = 3)
        ExitSearch()
    else
        StartSearch()
}

BackspaceKey() {
    global query, resIdx
    if (level != 3) {
        Back()
        return
    }
    if (query = "") {
        ExitSearch()
        return
    }
    query := SubStr(query, 1, -1)
    resIdx := 1
    UpdateResults()
    Render()
}

OnSearchChar(hook, char) {
    global query, resIdx
    if (level != 3 || Ord(char) < 32)
        return
    query .= char
    resIdx := 1
    UpdateResults()
    Render()
}

UpdateResults() {
    global results
    results := []
    words := StrSplit(Trim(query), " ")
    for c in cats {
        if (c = FAV_CAT || c = REC_CAT)
            continue
        for it in items[c] {
            tg := (it.Length >= 7) ? TagsDisp(it[7]) : ""
            hay := it[4] " " it[1] " " it[3] " " tg
            ok := true
            for w in words {
                if (w != "" && !InStr(hay, w))
                    ok := false
            }
            if ok
                results.Push(it)
        }
    }
}

; ---------- Favoris ----------
ToggleFav() {
    if (level = 4 || utilMode)
        return
    it := CurrentItem()
    if !IsObject(it)
        return
    key := it[5]
    if favs.Has(key) {
        favs.Delete(key)
        SetStatus("Retiré des favoris")
    } else {
        favs[key] := 1
        SetStatus("Ajouté aux favoris")
    }
    SaveFavs()
    RebuildKeepPos()
    Render()
}

RebuildKeepPos() {
    global catIdx, itemIdx, level
    curName := ""
    if ((level = 1 || level = 2) && catIdx <= cats.Length)
        curName := cats[catIdx]
    BuildVirtual()
    if (curName != "") {
        found := 0
        for i, c in cats {
            if (c = curName) {
                found := i
                break
            }
        }
        if (found > 0) {
            catIdx := found
        } else {
            level := 1
            catIdx := Max(1, Min(catIdx, cats.Length))
        }
    }
    if (level = 2)
        itemIdx := Max(1, Min(itemIdx, Count()))
}

; ---------- Dernier stuff ----------
RepeatLast() {
    if (recents.Length = 0) {
        ToolTip("Aucun stuff récent")
        SetTimer(() => ToolTip(), -1500)
        return
    }
    it := recents[1]
    RunCmd(it[2], it[3])
    ToolTip("Relancé : " it[1])
    SetTimer(() => ToolTip(), -1500)
}

; =====================================================================
;  Sauvegarde d'un repère (fenêtre au centre de l'écran)
; =====================================================================
CleanField(s) {
    s := StrReplace(s, "|", "/")
    s := RegExReplace(s, "[`r`n`t]+", " ")
    return Trim(s)
}

CleanInfo(s) {
    return StrReplace(CleanField(s), ";", ",")
}

; Les tags sont rangés dans le même champ que l'info : "info | tag1, tag2" (info vide : "| tag1, tag2")
SplitInfo(raw) {
    pos := InStr(raw, "|")
    if !pos
        return [Trim(raw), ""]
    return [Trim(SubStr(raw, 1, pos - 1)), Trim(SubStr(raw, pos + 1))]
}

JoinInfo(info, tags) {
    if (tags = "")
        return info
    return info " | " tags
}

; Nom de tag valide : pas de virgule, de point-virgule, de # ni de |
CleanTag(s) {
    s := RegExReplace(CleanField(s), "[,;#]", "")
    return Trim(s)
}

TagList(tags) {
    out := []
    for t in StrSplit(tags, ",") {
        t := CleanTag(t)
        if (t != "")
            out.Push(t)
    }
    return out
}

TagsToStr(arr) {
    out := ""
    for t in arr {
        sep := (out != "") ? ", " : ""
        out .= sep t
    }
    return out
}

; "#facile  #site-a" pour l'affichage
TagsDisp(tags) {
    out := ""
    for t in TagList(tags) {
        sep := (out != "") ? "  " : ""
        out .= sep "#" t
    }
    return out
}

; Info suivie des tags, pour les listes
InfoDisp(raw) {
    sp := SplitInfo(raw)
    tg := TagsDisp(sp[2])
    if (tg = "")
        return sp[1]
    return (sp[1] != "") ? sp[1] "  " tg : tg
}

; Tags connus : ceux créés (data\tags.txt) et ceux déjà utilisés dans les maps du profil
AllTags() {
    seen := Map()
    out := []
    AddTag(t) {
        t := CleanTag(t)
        if (t != "" && !seen.Has(StrLower(t))) {
            seen[StrLower(t)] := 1
            out.Push(t)
        }
    }
    f := DataDir "\tags.txt"
    if FileExist(f) {
        try {
            for ln in StrSplit(FileRead(f, "UTF-8"), "`n", "`r")
                AddTag(ln)
        }
    }
    Loop Files MapsDir "\*.txt" {
        try {
            for e in ReadEntries(A_LoopFileFullPath)[2] {
                for t in TagList(SplitInfo(e[4])[2])
                    AddTag(t)
            }
        }
    }
    ; tri alphabétique simple
    i := 2
    while (i <= out.Length) {
        v := out[i]
        j := i - 1
        while (j >= 1 && StrCompare(out[j], v) > 0) {
            out[j + 1] := out[j]
            j -= 1
        }
        out[j + 1] := v
        i += 1
    }
    return out
}

; Ajoute le tag à la liste des tags connus (data\tags.txt) s'il n'y est pas déjà
SaveTag(t) {
    t := CleanTag(t)
    if (t = "")
        return
    f := DataDir "\tags.txt"
    try {
        if FileExist(f) {
            for ln in StrSplit(FileRead(f, "UTF-8"), "`n", "`r") {
                if (StrLower(CleanTag(ln)) = StrLower(t))
                    return
            }
        }
        AppendLine(f, t)
    }
}

AllCategories(path) {
    out := []
    seen := Map()
    if !FileExist(path)
        return out
    for line in StrSplit(FileRead(path, "UTF-8"), "`n", "`r") {
        line := Trim(line)
        if (line = "" || SubStr(line, 1, 1) = "#" || SubStr(line, 1, 2) = "//")
            continue
        p := StrSplit(line, "|", " `t", 4)
        c := ""
        if (p[1] = "@cat") {
            if (p.Length >= 2)
                c := p[2]
        } else if (p.Length >= 3) {
            c := p[1]
        }
        if (c != "" && !seen.Has(c)) {
            seen[c] := 1
            out.Push(c)
        }
    }
    return out
}

AppendLine(path, line) {
    txt := FileExist(path) ? FileRead(path, "UTF-8") : ""
    prefix := (txt != "" && SubStr(txt, -1) != "`n") ? "`n" : ""
    FileAppend(prefix line "`n", path, "UTF-8-RAW")
}

; Noms uniques : un nom de stuff ne peut exister qu'une fois par map (toutes catégories, « communs » compris)
; et un nom de catégorie qu'une fois par map, sans tenir compte des majuscules.
; Renvoie la catégorie du stuff qui porte déjà ce nom, "" sinon. exCat / exName : le stuff en cours de modification (ignoré).
StuffNameTaken(path, name, exCat := "", exName := "") {
    nl := StrLower(Trim(name))
    files := [path]
    common := MapsDir "\_commun.txt"
    if (StrLower(path) != StrLower(common))
        files.Push(common)
    for f in files {
        for e in ReadEntries(f)[2] {
            if (StrLower(Trim(e[2])) != nl)
                continue
            if (f = path && exCat != "" && e[1] = exCat && e[2] = exName)
                continue
            return e[1]
        }
    }
    return ""
}

; Renvoie le nom (tel qu'il est écrit) de la catégorie existante qui porte déjà ce nom, "" sinon. exCat : catégorie en cours de renommage (ignorée)
CatNameTaken(path, name, exCat := "") {
    nl := StrLower(Trim(name))
    files := [path]
    common := MapsDir "\_commun.txt"
    if (StrLower(path) != StrLower(common))
        files.Push(common)
    for f in files {
        for c in ReadEntries(f)[1] {
            if (StrLower(Trim(c)) != nl)
                continue
            if (f = path && exCat != "" && StrLower(c) = StrLower(exCat))
                continue
            return c
        }
    }
    return ""
}

ShowSaveDialog(presetCat := "", presetMap := "", preset := "") {
    global dlgOpen, dlgHwnd
    if dlgOpen {
        ; déjà ouverte : on la remet devant. Si elle n'existe plus, l'indicateur était resté bloqué : on le remet à zéro
        if (dlgHwnd != 0 && WinExist("ahk_id " dlgHwnd)) {
            WinActivate("ahk_id " dlgHwnd)
            return
        }
        dlgOpen := false
    }
    if menuOpen {
        CloseMenu()
        Sleep(120)
    }
    LoadMaps()
    if (mapNames.Length = 0) {
        MsgBox("Aucun fichier .txt dans " MapsDir)
        return
    }

    ; Capture d'écran (centre du jeu) avant d'afficher la fenêtre
    tmpShot := ShotDir() "\_pending.bmp"
    shotPending := false
    chkShot := ""
    if (ShotOn && !IsObject(preset) && WinActive("ahk_exe cs2.exe")) {
        Sleep(100)
        shotPending := CaptureShot(tmpShot)
    }

    ; Position + map actuelles (via console.log)
    posCaptured := ""
    detected := ""
    if IsObject(preset) {
        posCaptured := preset["pos"]
        if (AutoDetect && presetMap = "" && FileExist(ConsoleLog))
            detected := DetectMap()
    } else if FileExist(ConsoleLog) {
        posCaptured := CapturePos()
        if (AutoDetect && presetMap = "")
            detected := DetectMap()
    }
    target := (presetMap != "") ? presetMap : ((detected != "") ? detected : LastMap)
    mapSel := 1
    for i, name in mapNames {
        if (name = target)
            mapSel := i
    }

    dlgOpen := true
    d := WinNew("Sauvegarder la position actuelle")
    dlgHwnd := d.Hwnd
    d.Add("Text", "xm w95", "Map")
    ddMap := d.Add("DropDownList", "x110 yp-3 w340 Choose" mapSel, mapNames)
    d.Add("Text", "xm y+14 w95", "Type")
    ddType := d.Add("DropDownList", "x110 yp-3 w340 Choose1", Types)
    d.Add("Text", "xm y+14 w95", "Catégorie")
    cbCat := d.Add("ComboBox", "x110 yp-3 w256", [])
    btnCatAdd := d.Add("Button", "x+6 yp w78", "Nouvelle")
    d.Add("Text", "xm y+14 w95", "Nom")
    edName := d.Add("Edit", "x110 yp-3 w340")
    d.SetFont("s9 c" WinPal()["bad"])
    txNameErr := d.Add("Text", "x110 y+2 w340 h16", "")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    d.Add("Text", "xm y+8 w95", "Tags")
    cbTag := d.Add("ComboBox", "x110 yp-3 w340", [])
    btnTagAdd := d.Add("Button", "x110 y+6 w104", "Ajouter")
    btnTagDel := d.Add("Button", "x+6 yp w104", "Retirer")
    btnTagInfo := d.Add("Button", "x+6 yp w116", "→ Info")
    d.SetFont("s9 c8A8F96")
    txTags := d.Add("Text", "x110 y+4 w340 r2", "")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    d.Add("Text", "xm y+10 w95", "Info chat")
    edInfo := d.Add("Edit", "x110 yp-3 w340 r3")
    giveY := "y+14"
    if shotPending {
        d.Add("Text", "xm y+14 w95", "Capture")
        picShot := d.Add("Picture", "x110 yp-3 w" ShotSize " h" ShotSize, tmpShot)
        chkDy := ShotSize // 2 - 10
        chkShot := d.Add("CheckBox", "x+14 yp+" chkDy " Checked", "Joindre cette capture au stuff")
        picShot.GetPos(, &picY, , &picH)
        giveTop := picY + picH + 16
        giveY := "y" giveTop   ; sous l'image, jamais dessus
    }
    chkGive := d.Add("CheckBox", "xm " giveY, "Donner la grenade du type choisi (give)")
    chkFav := d.Add("CheckBox", "xm y+6", "Ajouter aux favoris")
    btnCancel := d.Add("Button", "xm y+14 w170", "Annuler")
    btnSave := d.Add("Button", "x280 yp w170 Default", "Enregistrer")
    btnDet := d.Add("Button", "xm y+16 w200", (posCaptured = "") ? "Détails : position ▴" : "Détails : position ▾")
    lblPos := d.Add("Text", "xm y+10 w95", "Position")
    edPos := d.Add("Edit", "x110 yp-3 w340 r2", posCaptured)
    d.SetFont("s9 c" WinPal()["bad"])
    txPosWarn := d.Add("Text", "xm y+6 w450 r2", (posCaptured = "") ? "Position non capturée : lance le jeu avec -condebug, ou colle ici la sortie de getpos." : "")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    detOpen := Map("v", (posCaptured = ""))
    ShowDet(on, show := true) {
        detOpen["v"] := on
        lblPos.Visible := on
        edPos.Visible := on
        txPosWarn.Visible := on
        btnDet.Text := on ? "Détails : position ▴" : "Détails : position ▾"
        if show
            d.Show("AutoSize")
    }
    DetClick(*) {
        ShowDet(!detOpen["v"])
    }
    NameCheck(*) {
        ncN := CleanField(edName.Value)
        ncD := (ncN = "") ? "" : StuffNameTaken(mapFiles[ddMap.Value], ncN)
        txNameErr.Text := (ncD != "") ? "Ce nom est déjà pris (catégorie « " ncD " »)." : ""
    }

    FillCats(*) {
        fcTxt := cbCat.Text
        cbCat.Delete()
        fcLst := AllCategories(mapFiles[ddMap.Value])
        if (fcLst.Length > 0)
            cbCat.Add(fcLst)
        cbCat.Text := fcTxt
    }

    ; Tags du stuff en cours de création
    tagSel := []
    ShowTags() {
        txTags.Text := (tagSel.Length = 0) ? "Aucun tag : choisis ou tape un tag, puis clique sur Ajouter" : "Tags : " TagsDisp(TagsToStr(tagSel))
    }
    FillTags() {
        ftTxt := cbTag.Text
        cbTag.Delete()
        ftLst := AllTags()
        if (ftLst.Length > 0)
            cbTag.Add(ftLst)
        cbTag.Text := ftTxt
    }
    TagAddClick(*) {
        taT := CleanTag(cbTag.Text)
        if (taT = "")
            return
        taHave := false
        for taX in tagSel {
            if (StrLower(taX) = StrLower(taT))
                taHave := true
        }
        if !taHave {
            tagSel.Push(taT)
            SaveTag(taT)
        }
        FillTags()
        cbTag.Text := ""
        ShowTags()
    }
    TagDelClick(*) {
        tdT := CleanTag(cbTag.Text)
        tdI := 0
        if (tdT != "") {
            for tdK, tdX in tagSel {
                if (StrLower(tdX) = StrLower(tdT))
                    tdI := tdK
            }
        } else if (tagSel.Length > 0) {
            tdI := tagSel.Length
        }
        if (tdI > 0)
            tagSel.RemoveAt(tdI)
        cbTag.Text := ""
        ShowTags()
    }

    ; Quand une catégorie existante est choisie, le type suit (ou "(aucun)" s'il n'y en a pas)
    CatSync(*) {
        ccTxt := Trim(cbCat.Text)
        for ccC in AllCategories(mapFiles[ddMap.Value]) {
            if (ccC = ccTxt) {
                ccType := NO_TYPE
                for ccT in Types {
                    if (ccT != NO_TYPE && (InStr(ccC, ccT " - ") = 1 || ccC = ccT))
                        ccType := ccT
                }
                if (ccType != NO_TYPE)
                    ddType.Choose(ccType)
                return
            }
        }
    }

    ; Taper dans la liste filtre les catégories existantes (recherche) : rien n'est créé
    catBusy := Map("v", false)
    CatFilter() {
        if catBusy["v"]
            return
        catBusy["v"] := true
        try {
            cfTxt := cbCat.Text
            cfExact := false
            cfAll := AllCategories(mapFiles[ddMap.Value])
            cfLst := []
            for cfC in cfAll {
                if (StrLower(cfC) = StrLower(cfTxt))
                    cfExact := true
                if (cfTxt = "" || InStr(cfC, cfTxt))
                    cfLst.Push(cfC)
            }
            ; catégorie reconnue ou champ vide : toute la liste ; sinon seulement celles qui contiennent le texte tapé
            cfShow := (cfExact || cfTxt = "") ? cfAll : cfLst
            cbCat.Delete()
            if (cfShow.Length > 0)
                cbCat.Add(cfShow)
            cbCat.Text := cfTxt
            cfN := StrLen(cfTxt)
            SendMessage(0x142, 0, (cfN << 16) | cfN, cbCat)   ; curseur à la fin du texte tapé
            if (!cfExact && cfTxt != "" && cfLst.Length > 0)
                SendMessage(0x14F, 1, 0, cbCat)               ; ouvre la liste filtrée
        }
        catBusy["v"] := false
        CatSync()
    }

    CatChange(*) {
        if catBusy["v"]
            return
        SetTimer(CatFilter, -200)
    }

    ; Recopie le nom des tags dans le message d'info du chat (le tag reste aussi enregistré comme tag)
    TagInfoClick(*) {
        tiTxt := TagsToStr(tagSel)
        if (tiTxt = "") {
            MsgBox("Ajoute d'abord un tag avec le bouton Ajouter.", "Tags", 0x40030)
            return
        }
        tiCur := Trim(edInfo.Value)
        if (tiCur = "")
            edInfo.Value := tiTxt
        else if !InStr(tiCur, tiTxt)
            edInfo.Value := tiCur " - " tiTxt
    }

    ; « Nouvelle » : crée une catégorie vide (nom tel quel, sans préfixe de type) dans la map choisie et la sélectionne
    CatAddClick(*) {
        caName := CleanField(AskText("Nouvelle catégorie", "Nom de la nouvelle catégorie :", "", "ahk_id " d.Hwnd))
        if (caName = "")
            return
        caC1 := SubStr(caName, 1, 1)
        if (caC1 = "[" || caC1 = "@") {
            MsgBox("Le nom ne peut pas commencer par [ ou @.", "Nouvelle catégorie", 0x40030)
            return
        }
        caFull := caName
        caFile := mapFiles[ddMap.Value]
        caHave := false
        for caC in AllCategories(caFile) {
            if (StrLower(caC) = StrLower(caFull)) {
                caFull := caC
                caHave := true
            }
        }
        if !caHave
            EnsureCatDeclared(caFile, caFull)
        FillCats()
        cbCat.Text := caFull
    }

    CloseDlg(*) {
        global dlgOpen
        dlgOpen := false
        d.Destroy()
        try FileDelete(tmpShot)
        try WinActivate("ahk_exe cs2.exe")
    }

    SaveClick(*) {
        nm := CleanField(edName.Value)
        if (nm = "") {
            MsgBox("Donne un nom au stuff.", "Sauvegarde", 0x40030)
            return
        }
        pnorm := NormalizePos(edPos.Value)
        if (pnorm = "") {
            MsgBox("Position invalide. Format attendu :`nsetpos x y z; setang pitch yaw", "Sauvegarde", 0x40030)
            return
        }
        typ := ddType.Text
        sub := CleanField(cbCat.Text)
        catFull := ""
        for scC in AllCategories(mapFiles[ddMap.Value]) {
            if (sub != "" && StrLower(scC) = StrLower(sub)) {
                catFull := scC
                break
            }
            ; aucune catégorie choisie : on prend celle qui porte le nom du type si elle existe déjà
            if (sub = "" && typ != NO_TYPE && StrLower(scC) = StrLower(typ))
                catFull := scC
        }
        if (catFull = "") {
            if (sub = "")
                MsgBox("Choisis une catégorie dans la liste, ou crée-la avec le bouton Nouvelle.", "Sauvegarde", 0x40030)
            else
                MsgBox("La catégorie « " sub " » n'existe pas.`n`nChoisis une catégorie dans la liste (tu peux taper pour la chercher), ou crée-la avec le bouton Nouvelle.", "Sauvegarde", 0x40030)
            return
        }
        dupCat := StuffNameTaken(mapFiles[ddMap.Value], nm)
        if (dupCat != "") {
            MsgBox("Un stuff nommé « " nm " » existe déjà dans cette map (catégorie « " dupCat " »).`n`nChoisis un autre nom.", "Sauvegarde", 0x40030)
            return
        }
        cmdFull := pnorm
        if chkGive.Value {
            gv := GiveMap.Get(typ, "")
            if (gv != "")
                cmdFull .= "; give " gv
        }
        inf := JoinInfo(CleanInfo(edInfo.Value), TagsToStr(tagSel))
        line := catFull " | " nm " | " cmdFull
        if (inf != "")
            line .= " | " inf
        mapName := mapNames[ddMap.Value]
        AppendLine(mapFiles[ddMap.Value], line)
        if chkFav.Value {
            favs[mapName "|" catFull "|" nm] := 1
            SaveFavs()
        }
        if (IsObject(chkShot) && chkShot.Value) {
            shotDest := ShotPath(mapName, cmdFull)
            if (shotDest != "")
                try FileCopy(tmpShot, shotDest, 1)
        }
        CloseDlg()
        ToolTip("Stuff enregistré dans " mapName)
        SetTimer(() => ToolTip(), -2500)
        if (IsObject(preset) && preset["secs"] != "") {
            SetFlightTime(cmdFull, preset["secs"])
            ToolTip("Stuff enregistré dans " mapName " (temps de vol : " FlightText(preset["secs"]) ")")
            SetTimer(() => ToolTip(), -3000)
        } else {
            OfferFlight(cmdFull, typ)
        }
    }

    FillCats()
    if (presetCat != "") {
        pcType := NO_TYPE
        for pcT in Types {
            if (pcT != NO_TYPE && (InStr(presetCat, pcT " - ") = 1 || presetCat = pcT))
                pcType := pcT
        }
        ddType.Choose(pcType)
        FillCats()
        cbCat.Text := presetCat
    }
    FillTags()
    ShowTags()
    if IsObject(preset) {
        pt := preset["type"]
        for ptT in Types {
            if (ptT = pt) {
                ddType.Choose(ptT)
                chkGive.Value := (GiveMap.Get(ptT, "") != "") ? 1 : 0
            }
        }
    }
    ShowDet(detOpen["v"], false)
    btnDet.OnEvent("Click", DetClick)
    edName.OnEvent("Change", NameCheck)
    ddMap.OnEvent("Change", (*) => (FillCats(), NameCheck()))
    cbCat.OnEvent("Change", CatChange)
    btnCatAdd.OnEvent("Click", CatAddClick)
    btnTagAdd.OnEvent("Click", TagAddClick)
    btnTagDel.OnEvent("Click", TagDelClick)
    btnTagInfo.OnEvent("Click", TagInfoClick)
    btnSave.OnEvent("Click", SaveClick)
    btnCancel.OnEvent("Click", CloseDlg)
    d.OnEvent("Close", CloseDlg)
    d.OnEvent("Escape", CloseDlg)
    WinStyle(d)
    d.Show("AutoSize Center")
    edName.Focus()
}

; =====================================================================
;  Gestion depuis le menu : ajouter / supprimer stuffs et catégories
; =====================================================================
ReadLines(path) {
    lines := StrSplit(FileRead(path, "UTF-8"), "`n", "`r")
    if (lines.Length > 0 && lines[lines.Length] = "")
        lines.Pop()
    return lines
}

; Réécriture sûre : copie de secours dans data\backup, puis fichier temporaire
RewriteFile(path, lines) {
    SplitPath(path, &fn)
    DirCreate(DataDir "\backup")
    FileCopy(path, DataDir "\backup\" fn ".bak", 1)
    tmp := path ".tmp"
    try FileDelete(tmp)
    out := ""
    for l in lines
        out .= l "`n"
    FileAppend(out, tmp, "UTF-8-RAW")
    FileMove(tmp, path, 1)
}

IsDataLine(t) {
    return !(t = "" || SubStr(t, 1, 1) = "#" || SubStr(t, 1, 2) = "//")
}

DeleteLineFrom(path, cat, name) {
    if !FileExist(path)
        return false
    keep := []
    removed := false
    for line in ReadLines(path) {
        t := Trim(line)
        if (!removed && IsDataLine(t)) {
            p := StrSplit(t, "|", " `t", 4)
            if (p.Length >= 3 && p[1] = cat && p[2] = name) {
                removed := true
                gone := p
                continue
            }
        }
        keep.Push(line)
    }
    if removed {
        RewriteFile(path, keep)
        LogDeleted(path, gone)
    }
    return removed
}

PurgeKey(key) {
    if locks.Has("it|" key) {
        locks.Delete("it|" key)
        SaveLocks()
    }
    if favs.Has(key) {
        favs.Delete(key)
        SaveFavs()
    }
    i := recents.Length
    while (i >= 1) {
        if (recents[i][5] = key)
            recents.RemoveAt(i)
        i -= 1
    }
    SaveRecents()
}

; Recharge la map courante en gardant la sélection
ReloadKeep() {
    global catIdx, itemIdx, resIdx, level, mapIdx
    curName := ((level = 1 || level = 2) && catIdx >= 1 && catIdx <= cats.Length) ? cats[catIdx] : ""
    LoadMaps()
    for i, n in mapNames {
        if (n = loadedMap) {
            mapIdx := i
            LoadMapStuff(i)
            break
        }
    }
    if (curName != "") {
        found := 0
        for i, c in cats {
            if (c = curName) {
                found := i
                break
            }
        }
        if (found > 0) {
            catIdx := found
        } else {
            if (level = 2)
                level := 1
            catIdx := Max(1, Min(catIdx, cats.Length))
        }
    } else {
        catIdx := Max(1, Min(catIdx, cats.Length))
    }
    if (level = 2)
        itemIdx := Max(1, Min(itemIdx, Count()))
    if (level = 3) {
        UpdateResults()
        resIdx := Max(1, Min(resIdx, results.Length))
    }
}

; Petite fenêtre de saisie (reste au-dessus du jeu)
AskText(title, prompt, defVal := "", back := "ahk_exe cs2.exe") {
    res := Map("v", "")
    d := WinNew(title, "+AlwaysOnTop")
    d.Add("Text", "w340", prompt)
    ed := d.Add("Edit", "w340", defVal)
    btnNo := d.Add("Button", "w165", "Annuler")
    btnOk := d.Add("Button", "x+10 yp w165 Default", "OK")
    Done(ok, *) {
        if ok
            res["v"] := ed.Value
        d.Destroy()
    }
    btnOk.OnEvent("Click", Done.Bind(true))
    btnNo.OnEvent("Click", Done.Bind(false))
    d.OnEvent("Close", Done.Bind(false))
    d.OnEvent("Escape", Done.Bind(false))
    WinStyle(d)
    d.Show("AutoSize Center")
    ed.Focus()
    hwnd := d.Hwnd
    WinWaitClose("ahk_id " hwnd)
    WinActivate(back)
    return res["v"]
}

; Touche AddKey : ouvre la fenêtre de création d'un nouveau stuff (catégorie courante pré-remplie)
NewStuffPress() {
    preset := ""
    pmap := ""
    if (level >= 1 && level <= 3 && !utilMode && loadedMap != "") {
        pmap := loadedMap
        cur := CurrentItem()
        if (level = 1 && cats.Length > 0 && cats[catIdx] != FAV_CAT && cats[catIdx] != REC_CAT)
            preset := cats[catIdx]
        else if (level = 2 && cats[catIdx] != FAV_CAT && cats[catIdx] != REC_CAT)
            preset := cats[catIdx]
        else if IsObject(cur)
            preset := cur[4]
    }
    ShowSaveDialog(preset, pmap)
}

; =====================================================================
;  Apparence de l'overlay (police, taille, couleurs, position)
; =====================================================================
; Dossier cfg de CS2 à partir d'un dossier choisi (Steam, jeu, csgo, cfg...) ou ""
Cs2CfgIn(base) {
    base := RTrim(base, "\")
    for sub in ["", "\game\csgo\cfg", "\csgo\cfg", "\cfg", "\Counter-Strike Global Offensive\game\csgo\cfg", "\common\Counter-Strike Global Offensive\game\csgo\cfg", "\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"] {
        c := base sub
        if DirExist(c) {
            SplitPath(c, &nm)
            if (StrLower(nm) = "cfg")
                return c
        }
    }
    return ""
}

; Cherche le dossier cfg de CS2 dans les bibliothèques Steam de l'ordinateur
FindCs2Cfg() {
    libs := []
    steams := []
    for key in ["HKEY_CURRENT_USER\Software\Valve\Steam|SteamPath", "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam|InstallPath", "HKEY_LOCAL_MACHINE\SOFTWARE\Valve\Steam|InstallPath"] {
        kp := StrSplit(key, "|")
        try {
            sp := RegRead(kp[1], kp[2])
            if (sp != "")
                steams.Push(RTrim(StrReplace(sp, "/", "\"), "\"))
        }
    }
    steams.Push("C:\Program Files (x86)\Steam")
    steams.Push("C:\Program Files\Steam")
    for st in steams {
        libs.Push(st)
        vdf := st "\steamapps\libraryfolders.vdf"
        if FileExist(vdf) {
            try {
                for ln in StrSplit(FileRead(vdf, "UTF-8"), "`n", "`r") {
                    if RegExMatch(ln, 'i)"path"\s+"([^"]+)"', &pm)
                        libs.Push(RTrim(StrReplace(pm[1], "\\", "\"), "\"))
                }
            }
        }
    }
    for lib in libs {
        c := lib "\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
        if DirExist(c)
            return c
    }
    return ""
}

; Retire les restes du mode « touches » des anciennes versions : liaisons dans cs2_practice.cfg et fichiers stuff_run.cfg / hud_pos.cfg
CleanLegacy() {
    try {
        f := cfgDir "\" PracticeCfg ".cfg"
        if FileExist(f) {
            txt := FileRead(f, "UTF-8")
            out := ""
            changed := false
            for ln in StrSplit(txt, "`n", "`r") {
                if RegExMatch(ln, 'i)^\s*bind\s+"[^"]+"\s+"exec\s+(stuff_run|hud_pos)"') {
                    changed := true
                    continue
                }
                if RegExMatch(ln, "i)^//\s*(-+ Liaison avec le menu|Liaison avec le menu|Ne pas modifier : cette touche|Coordonnées en temps réel \(le script)") {
                    changed := true
                    continue
                }
                out .= ln "`n"
            }
            if changed
                FileOpen(f, "w", "UTF-8-RAW").Write(RTrim(out, "`n") "`n")
        }
    }
    for n in ["stuff_run.cfg", "hud_pos.cfg"] {
        if FileExist(cfgDir "\" n)
            try FileDelete(cfgDir "\" n)
    }
}

; =====================================================================
;  Diagnostic (copié dans le presse-papiers) et nettoyage des fichiers orphelins
; =====================================================================
CopyDiagnostic() {
    global netFailTick
    L := []
    L.Push("Menu Stuf v" APP_VERSION)
    L.Push("Windows " A_OSVersion (A_Is64bitOS ? " 64 bits" : " 32 bits") " - AutoHotkey " A_AhkVersion)
    L.Push("CS2 lancé : " (ProcessExist("cs2.exe") ? "oui" : "non"))
    steamExe := ""
    try steamExe := RegRead("HKEY_CURRENT_USER\Software\Valve\Steam", "SteamExe")
    L.Push("Steam : " (steamExe != "" ? steamExe : "introuvable"))
    L.Push("Dossier cfg : " cfgDir " (" (DirExist(cfgDir) ? "existe" : "introuvable") ")")
    L.Push("cs2_practice.cfg dans le cfg : " (FileExist(cfgDir "\" PracticeCfg ".cfg") ? "oui" : "non"))
    sz := FileExist(ConsoleLog) ? FileGetSize(ConsoleLog) : -1
    L.Push("console.log : " ConsoleLog " (" (sz >= 0 ? Round(sz / 1024) " Ko" : "absent") ")")
    netFailTick := 0
    L.Push("Connexion directe (port " NetconPort ") : " (NetOpen() ? "active" : "inactive"))
    L.Push("Options de lancement du menu : " StrReplace(LaunchArgs, "{port}", NetconPort))
    LoadMaps()
    L.Push("Profil : " curProfile " - maps : " mapNames.Length)
    L.Push("Touches : menu " MenuKey ", favori " FavKey ", cadenas " LockKey ", nouveau " AddKey)
    L.Push("Coordonnées : " (hudOn ? "actives" : "inactives") " - chronomètre : " (TimerOn ? "actif" : "inactif") " - exec auto : " (AutoExec ? "oui" : "non"))
    if (TimerDebug && FileExist(TmDbgFile)) {
        L.Push("")
        L.Push("Journal du chronomètre (TimerDebug) :")
        dl := StrSplit(Trim(FileRead(TmDbgFile, "UTF-8"), "`r`n"), "`n", "`r")
        Loop Min(30, dl.Length)
            L.Push(dl[dl.Length - Min(30, dl.Length) + A_Index])
    }
    L.Push("")
    L.Push("Dernières lignes utiles de console.log (positions masquées, identifiants Steam masqués) :")
    if (sz > 0) {
        tail := ReadFrom(ConsoleLog, Max(0, sz - 65536))
        keep := []
        for ln in StrSplit(tail, "`n", "`r") {
            if (Trim(ln) = "" || RegExMatch(ln, "i)^\s*(\d\d/\d\d\s+\d\d:\d\d:\d\d\s+)?setpos\s"))
                continue
            keep.Push(ln)
        }
        i := Max(1, keep.Length - 29)
        while (i <= keep.Length) {
            ln := RegExReplace(keep[i], "\[U:\d:\d+\]", "[U:x:xxxx]")
            ln := RegExReplace(ln, "STEAM_\d:\d:\d+", "STEAM_x:x:xxxx")
            L.Push(SubStr(ln, 1, 300))
            i += 1
        }
    } else {
        L.Push("(aucune)")
    }
    txt := ""
    for ln in L
        txt .= ln "`n"
    A_Clipboard := txt
    MsgBox("Le diagnostic est copié dans le presse-papiers.`n`nColle-le (Ctrl+V) dans un message pour le partager.", "Menu Stuf - diagnostic", 0x40040)
}

; Supprime les captures et les temps de vol qui ne correspondent plus à aucun stuff du profil actif
CleanOrphans() {
    validShots := Map()
    validTimes := Map()
    Loop Files MapsDir "\*.txt" {
        for line in ReadLines(A_LoopFileFullPath) {
            t := Trim(line)
            if !IsDataLine(t)
                continue
            p := StrSplit(t, "|", " `t", 4)
            if (p[1] = "@cat" || p.Length < 3)
                continue
            k := ShotCoordKey(p[3])
            if (k != "")
                validShots[k] := 1
            tk := TimeKey(p[3])
            if (tk != "")
                validTimes[tk] := 1
        }
    }
    orphShots := []
    bytes := 0
    Loop Files ShotDir() "\*.bmp" {
        if (SubStr(A_LoopFileName, 1, 1) = "_")
            continue
        if RegExMatch(A_LoopFileName, "i)_([mp\d]+_[mp\d]+_[mp\d]+)\.bmp$", &m) {
            if !validShots.Has(m[1]) {
                orphShots.Push(A_LoopFileFullPath)
                bytes += A_LoopFileSize
            }
        }
    }
    orphTimes := []
    for k, v in times {
        if !validTimes.Has(k)
            orphTimes.Push(k)
    }
    if (orphShots.Length = 0 && orphTimes.Length = 0) {
        MsgBox("Rien à nettoyer : toutes les captures et tous les temps de vol sont liés à un stuff.", "Menu Stuf - nettoyage", 0x40040)
        return
    }
    msg := orphShots.Length " capture(s) orpheline(s) (" Round(bytes / 1024) " Ko) et " orphTimes.Length " temps de vol orphelin(s) dans le profil « " curProfile " ».`n`nLes supprimer ?"
    if (MsgBox(msg, "Menu Stuf - nettoyage", 0x40024) != "Yes")
        return
    for f in orphShots
        try FileDelete(f)
    for k in orphTimes
        times.Delete(k)
    if (orphTimes.Length > 0)
        SaveTimes()
    MsgBox("Nettoyage terminé.", "Menu Stuf - nettoyage", 0x40040)
}

ToInt(v, def) {
    try
        return Integer(v)
    return def
}

Lum(hex) {
    r := Integer("0x" SubStr(hex, 1, 2))
    gr := Integer("0x" SubStr(hex, 3, 2))
    b := Integer("0x" SubStr(hex, 5, 2))
    return 0.299 * r + 0.587 * gr + 0.114 * b
}

FS(n) {
    return Max(6, Round(n * ovScale / 100))
}

; Couleur du liseré : mélange du fond et de la couleur du titre (thème), sinon fond éclairci ou assombri
BorderColor() {
    if (ovBorderCol != "")
        return ovBorderCol
    th := ThemeById(ovTheme)
    if IsObject(th)
        return MixHex(th[3], th[5], 55)
    return (Lum(ovBg) < 140) ? MixHex(ovBg, "FFFFFF", 30) : MixHex(ovBg, "000000", 28)
}

; Couleur de la ligne sélectionnée : celle du thème, sinon le fond éclairci (ou assombri)
SelColor() {
    th := ThemeById(ovTheme)
    if IsObject(th)
        return th[8]
    return (Lum(ovBg) < 140) ? MixHex(ovBg, "FFFFFF", 12) : MixHex(ovBg, "000000", 8)
}

MixHex(a, b, pct) {
    r := Round(Integer("0x" SubStr(a, 1, 2)) + (Integer("0x" SubStr(b, 1, 2)) - Integer("0x" SubStr(a, 1, 2))) * pct / 100)
    gg := Round(Integer("0x" SubStr(a, 3, 2)) + (Integer("0x" SubStr(b, 3, 2)) - Integer("0x" SubStr(a, 3, 2))) * pct / 100)
    bb := Round(Integer("0x" SubStr(a, 5, 2)) + (Integer("0x" SubStr(b, 5, 2)) - Integer("0x" SubStr(a, 5, 2))) * pct / 100)
    return Format("{:02X}{:02X}{:02X}", r, gg, bb)
}

SetList(lines, selIdx) {
    Loop 13 {
        i := A_Index
        t := (i <= lines.Length) ? lines[i] : ""
        isSel := (i = selIdx)
        listRows[i].Text := t
        listRowsS[i].Text := t
        listRows[i].Visible := !isSel
        listRowsS[i].Visible := isSel
    }
}

ThemeById(id) {
    if (id = "")
        return ""
    for t in THEMES {
        if (t[1] = id)
            return t
    }
    return ""
}

; Ne garde que les polices réellement installées (lecture du registre Windows)
InstalledFonts(cands) {
    names := ""
    try {
        Loop Reg "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            names .= A_LoopRegName "|"
    }
    try {
        Loop Reg "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            names .= A_LoopRegName "|"
    }
    if (names = "")
        return cands
    out := []
    for f in cands {
        if (f = "Par défaut" || InStr(names, f))
            out.Push(f)
    }
    return out
}

BuildOverlay() {
    global g, gb, gs, titleCtl, infoCtl, hintCtl, statusCtl, ovBg, listRows, listRowsS
    if IsObject(g)
        g.Destroy()
    if IsObject(gb) {
        gb.Destroy()
        gb := ""
    }
    if IsObject(gs) {
        gs.Destroy()
        gs := ""
    }
    W := Round(460 * ovScale / 100)
    th := ThemeById(ovTheme)
    if IsObject(th)
        ovBg := th[3]
    dark := (Lum(ovBg) < 140)
    cTitle := dark ? "FFB000" : "8A4B00"
    cList := dark ? "FFFFFF" : "111111"
    cInfo := dark ? "FFD27A" : "6B4A00"
    cStatus := dark ? "7CFC00" : "1B6E1B"
    cHint := dark ? "FFFFFF" : "000000"
    cFoot := dark ? "B4BAC2" : "444444"
    cBrand := dark ? "7AD7FF" : "005A8C"
    if IsObject(th) {
        cBrand := th[5]
        cTitle := th[6]
        cList := th[4]
        cInfo := th[6]
        cStatus := th[5]
        cHint := th[4]
        cFoot := th[7]
    }
    fText := (ovFont = "") ? "Segoe UI" : ovFont
    fList := (ovFont = "") ? "Consolas" : ovFont
    g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    g.BackColor := ovBg
    if (ovTitle != "") {
        g.SetFont("s" FS(12) " bold c" cBrand, fText)
        g.Add("Text", "w" W " Center", ovTitle)
    }
    g.SetFont("s" FS(16) " bold c" cTitle, fText)
    titleCtl := g.Add("Text", "w" W, "")
    g.SetFont("s" FS(13) " norm c" cList, fList)
    listRows := []
    listRowsS := []
    selCol := SelColor()
    Loop 13 {
        rowOpt := (A_Index = 1) ? "" : " y+0"
        rn := g.Add("Text", "w" W " r1 0x4000" rowOpt, "")
        rn.GetPos(&rx, &ry, &rw, &rh)
        rs := g.Add("Text", "x" rx " y" ry " w" rw " h" rh " 0x4000 Background" selCol, "")
        rs.Visible := false
        if (ovCorner > 0) {
            rr := Min(Max(4, Round(ovCorner * 0.9)), rh)
            WinSetRegion("0-0 W" rw " H" rh " R" rr "-" rr, rs)
        }
        listRows.Push(rn)
        listRowsS.Push(rs)
    }
    g.SetFont("s" FS(10) " c" cInfo, fText)
    infoCtl := g.Add("Text", "w" W " r3", "")
    g.SetFont("s" FS(9) " c" cStatus, fText)
    statusCtl := g.Add("Text", "w" W " r2", "")
    g.SetFont("s" FS(10) " bold c" cHint, fText)
    hintCtl := g.Add("Text", "w" W " r3", "")
    g.SetFont("s" FS(9) " norm c" cFoot, fText)
    g.Add("Text", "w" W, "Haut/Bas : naviguer   Droite/Entrée : valider   Gauche : retour   Échap : fermer`n" MenuKey " : ouvrir / fermer le menu`n" FavKey " : favori   " LockKey " : cadenas   " AddKey " : nouveau stuff (menu des stuffs)`nCtrl+Z : annuler la dernière suppression de stuff`nSauvegarde, réglages, gestion, profils, exec : tout est dans le menu.")
    if (ovBorder > 0) {
        gb := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
        gb.BackColor := BorderColor()
    }
}

ShowOverlay() {
    vl := SysGet(76)
    vt := SysGet(77)
    vw := SysGet(78)
    vh := SysGet(79)
    x := Max(vl, Min(ovX, vl + vw - 100))
    y := Max(vt, Min(ovY, vt + vh - 60))
    g.Show("NA x" x " y" y " AutoSize")
    g.GetPos(&gx, &gy, &gw, &gh)
    dia := 2 * ovCorner
    if (ovCorner > 0)
        WinSetRegion("0-0 W" gw " H" gh " R" dia "-" dia, g)
    WinSetTransparent(ovOpacity, g)
    if IsObject(gb) {
        b := ovBorder
        bx := gx - b
        by := gy - b
        bw := gw + 2 * b
        bh := gh + 2 * b
        gb.Show("NA x" bx " y" by " w" bw " h" bh)
        if (ovCorner > 0) {
            bd := dia + 2 * b
            WinSetRegion("0-0 W" bw " H" bh " R" bd "-" bd, gb)
        }
        WinSetTransparent(ovOpacity, gb)
        DllCall("SetWindowPos", "Ptr", g.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
    }
}

ShowPreview() {
    titleCtl.Text := "APERÇU DU MENU"
    SetList(["> Exemple de stuff", "   Autre stuff", "   * Stuff favori", "   Smoke - Site A"], 1)
    infoCtl.Text := "Info : message affiché dans le chat"
    statusCtl.Text := ""
    hintCtl.Text := "Droite/Entrée : valider   Gauche : retour"
    ShowOverlay()
    UpdateShot(true)
}

ApplyStyle() {
    BuildOverlay()
    if hudOn {
        BuildHud()
        ShowHud()
    }
    if tmVisible
        TmShow(tmText)
    if menuOpen
        Render()
    else if setOpen
        ShowPreview()
}

ShowSettings() {
    global setOpen
    if setOpen
        return
    setOpen := true
    old := Map("Font", ovFont, "Scale", ovScale, "X", ovX, "Y", ovY, "Opacity", ovOpacity, "Bg", ovBg, "Theme", ovTheme, "Border", ovBorder, "Corner", ovCorner, "BorderCol", ovBorderCol, "ShotOn", ShotOn, "ShotSize", ShotSize, "ShotZoom", ShotZoom, "ShotPlace", ShotPlace, "ShotCorner", ShotCorner, "ShotX", ShotX, "ShotY", ShotY, "Hud", hudOn, "HudAuto", HudAuto, "HudX", HudX, "HudY", HudY, "Tm", TimerOn, "TmAuto", TimerAuto, "TmX", TimerX, "TmY", TimerY, "TmDur", TimerDur, "FlAsk", FlightAsk, "TmBeep", TimerBeep)
    vl := SysGet(76)
    vt := SysGet(77)
    vw := SysGet(78)
    vh := SysGet(79)
    xr := Max(1, vw - 100)
    yr := Max(1, vh - 60)
    fonts := InstalledFonts(["Par défaut", "Segoe UI", "Segoe UI Semibold", "Bahnschrift", "Cascadia Code", "Cascadia Mono", "Consolas", "Calibri", "Candara", "Corbel", "Trebuchet MS", "Verdana", "Tahoma", "Arial", "Georgia", "Franklin Gothic Medium", "Courier New", "Lucida Console"])
    if (ovFont != "") {
        known := false
        for f in fonts {
            if (f = ovFont)
                known := true
        }
        if !known
            fonts.Push(ovFont)
    }
    thNames := ["Personnalisé"]
    tSel := 1
    for k, t in THEMES {
        thNames.Push(t[2])
        if (t[1] = ovTheme)
            tSel := k + 1
    }
    pNames := ["Personnalisé", "Sombre (défaut)", "Noir", "Bleu nuit", "Gris", "Vert foncé", "Violet", "Clair"]
    pHex := ["", "14181D", "000000", "0B1530", "2B2F36", "0F2A1A", "241238", "E8E8E8"]
    fSel := 1
    for i, f in fonts {
        if (i > 1 && f = ovFont)
            fSel := i
    }
    pSel := 1
    for i, h in pHex {
        if (h != "" && h = StrUpper(ovBg))
            pSel := i
    }
    r0 := Integer("0x" SubStr(ovBg, 1, 2))
    g0 := Integer("0x" SubStr(ovBg, 3, 2))
    b0 := Integer("0x" SubStr(ovBg, 5, 2))
    bcNames := ["Auto (selon le thème)", "Or", "Blanc", "Bleu", "Cyan", "Vert", "Rouge", "Orange", "Rose", "Violet", "Gris", "Personnalisé"]
    bcHex := ["", "E3C48A", "F2F2F2", "5B9BFF", "4FD8E8", "4FD17A", "FF5C5C", "FF9F43", "FF7EB6", "B28DFF", "8A8F98", ""]
    bcSel := 1
    if (ovBorderCol != "") {
        bcSel := 12
        for i, h in bcHex {
            if (h != "" && h = ovBorderCol)
                bcSel := i
        }
    }
    x0 := Max(0, Min(ovX - vl, xr))
    y0 := Max(0, Min(ovY - vt, yr))

    d := WinNew("Réglages du menu", "+AlwaysOnTop")
    pv := Map("g", "")
    tabs := WinTabs(d, ["Menu", "Couleurs", "Captures", "Coords", "Chrono", "Fenêtres", "Aide"], 6, 8, 500)
    tabs.UseTab(1)
    y := 44
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Thème")
    ddTheme := d.Add("DropDownList", "x140 y" y " w260 Choose" tSel, thNames)
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Police")
    ddFont := d.Add("DropDownList", "x140 y" y " w260 Choose" fSel, fonts)
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Taille")
    slScale := d.Add("Slider", "x140 y" y " w260 Range60-200 ToolTip", ovScale)
    txScale := d.Add("Text", "x406 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Position X")
    slX := d.Add("Slider", "x140 y" y " w260 Range0-" xr " ToolTip", x0)
    txX := d.Add("Text", "x406 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Position Y")
    slY := d.Add("Slider", "x140 y" y " w260 Range0-" yr " ToolTip", y0)
    txY := d.Add("Text", "x406 y" ty " w70", "")
    y += 36
    btnPickM := d.Add("Button", "x140 y" y " w260", "Placer avec la souris")
    y += 44
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Opacité")
    slOp := d.Add("Slider", "x140 y" y " w260 Range80-255 ToolTip", ovOpacity)
    txOp := d.Add("Text", "x406 y" ty " w70", "")
    y += 46
    yEnd1 := y

    ; ----- Onglet Couleurs -----
    tabs.UseTab(2)
    y := 44
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Couleur de fond")
    ddPreset := d.Add("DropDownList", "x140 y" y " w260 Choose" pSel, pNames)
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Rouge")
    slR := d.Add("Slider", "x140 y" y " w260 Range0-255 ToolTip", r0)
    y += 34
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Vert")
    slG := d.Add("Slider", "x140 y" y " w260 Range0-255 ToolTip", g0)
    y += 34
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Bleu")
    slB := d.Add("Slider", "x140 y" y " w260 Range0-255 ToolTip", b0)
    txHex := d.Add("Text", "x406 y" ty " w70", "")
    y += 46
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Liseré épaisseur")
    slBw := d.Add("Slider", "x140 y" y " w260 Range0-6 ToolTip", ovBorder)
    txBw := d.Add("Text", "x406 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Coins arrondis")
    slCr := d.Add("Slider", "x140 y" y " w260 Range0-30 ToolTip", ovCorner)
    txCr := d.Add("Text", "x406 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Liseré couleur")
    ddBc := d.Add("DropDownList", "x140 y" y " w260 Choose" bcSel, bcNames)
    y += 36
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Code couleur")
    edBc := d.Add("Edit", "x140 y" y " w100 Limit7", (ovBorderCol != "") ? ovBorderCol : "")
    d.Add("Text", "x250 y" ty " w230", "ex : FF8800 (6 caractères)")
    y += 46
    yEnd2 := y

    ; ----- Onglet Captures -----
    tabs.UseTab(3)
    y := 44
    ty := y + 4
    shotChk := ShotOn ? " Checked" : ""
    chkShotOn := d.Add("CheckBox", "x22 y" y " w440" shotChk, "Activer les captures d'écran des stuffs")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Zone capturée")
    slShotSz := d.Add("Slider", "x140 y" y " w260 Range40-300 ToolTip", ShotSize)
    txShotSz := d.Add("Text", "x406 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Taille affichée")
    slShotZm := d.Add("Slider", "x140 y" y " w260 Range60-500 ToolTip", ShotZoom)
    txShotZm := d.Add("Text", "x406 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Coins arrondis")
    slShotCr := d.Add("Slider", "x140 y" y " w260 Range0-30 ToolTip", ShotCorner)
    txShotCr := d.Add("Text", "x406 y" ty " w70", "")
    y += 44
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Placement")
    shotSel := ShotPlace
    ddShotPos := d.Add("DropDownList", "x140 y" y " w260 Choose" shotSel, ["Coin supérieur droit (par défaut)", "Libre (où je veux sur l'écran)"])
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Position X")
    slShotX := d.Add("Slider", "x140 y" y " w260 Range0-" xr " ToolTip", Max(0, Min(ShotX - vl, xr)))
    txShotX := d.Add("Text", "x406 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Position Y")
    slShotY := d.Add("Slider", "x140 y" y " w260 Range0-" yr " ToolTip", Max(0, Min(ShotY - vt, yr)))
    txShotY := d.Add("Text", "x406 y" ty " w70", "")
    y += 36
    btnPickS := d.Add("Button", "x140 y" y " w260", "Placer avec la souris")
    y += 46
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "x22 y" y " w460 r4", "Le liseré de la capture (épaisseur et couleur) suit automatiquement celui du menu (onglet Menu) et se dessine par-dessus l'image. La zone capturée s'applique aux prochaines captures. Pour refaire la capture d'un stuff : « Gérer les stuffs et les catégories » du menu, double-clic sur le stuff, bouton « Refaire la capture ».")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    y += 80
    yEnd3 := y

    ; ----- Onglet Coordonnées -----
    tabs.UseTab(4)
    y := 44
    hudChk := hudOn ? " Checked" : ""
    chkHud := d.Add("CheckBox", "x22 y" y " w460" hudChk, "Afficher les coordonnées en temps réel")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Placement")
    hudSel := HudAuto ? 1 : 2
    ddHudPos := d.Add("DropDownList", "x140 y" y " w260 Choose" hudSel, ["Coin inférieur gauche (par défaut)", "Libre (où je veux sur l'écran)"])
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Position X")
    slHudX := d.Add("Slider", "x140 y" y " w260 Range0-" xr " ToolTip", Max(0, Min(HudX - vl, xr)))
    txHudX := d.Add("Text", "x406 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Position Y")
    slHudY := d.Add("Slider", "x140 y" y " w260 Range0-" yr " ToolTip", Max(0, Min(HudY - vt, yr)))
    txHudY := d.Add("Text", "x406 y" ty " w70", "")
    y += 36
    btnPickH := d.Add("Button", "x140 y" y " w260", "Placer avec la souris")
    y += 46
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "x22 y" y " w460 r8", "Affiche la map, ta position (X, Y, Z) et ton angle de vue dans le coin inférieur gauche de l'écran.`n`nSi tu l'actives puis cliques sur Enregistrer, il reste activé à chaque lancement du script, jusqu'à ce que tu le désactives ici.`n`nLes coordonnées sont demandées au jeu par la connexion directe, sans aucune touche : elles ne gênent ni les stuffs ni le chat.")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    y += 150
    yEnd4 := y

    ; ----- Onglet Chronomètre -----
    tabs.UseTab(5)
    y := 44
    chkTm := d.Add("CheckBox", "x22 y" y " w460" (TimerOn ? " Checked" : ""), "Afficher le chronomètre après chaque grenade")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Placement")
    ddTmPos := d.Add("DropDownList", "x140 y" y " w260 Choose" (TimerAuto ? 1 : 2), ["Au-dessus des coordonnées (par défaut)", "Libre (où je veux sur l'écran)"])
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Position X")
    slTmX := d.Add("Slider", "x140 y" y " w260 Range0-" xr " ToolTip", Max(0, Min(TimerX - vl, xr)))
    txTmX := d.Add("Text", "x406 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Position Y")
    slTmY := d.Add("Slider", "x140 y" y " w260 Range0-" yr " ToolTip", Max(0, Min(TimerY - vt, yr)))
    txTmY := d.Add("Text", "x406 y" ty " w70", "")
    y += 36
    btnPickT := d.Add("Button", "x140 y" y " w260", "Placer avec la souris")
    y += 44
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Affichage")
    slTmDur := d.Add("Slider", "x140 y" y " w260 Range2-20 ToolTip", TimerDur)
    txTmDur := d.Add("Text", "x406 y" ty " w70", "")
    y += 44
    chkFlAsk := d.Add("CheckBox", "x22 y" y " w460" (FlightAsk ? " Checked" : ""), "Proposer de mesurer le temps de vol après la création d'un stuff")
    y += 30
    chkBeep := d.Add("CheckBox", "x22 y" y " w460 Hidden" (TimerBeep ? " Checked" : ""), "Bip juste avant l'arrivée de la grenade (si le temps de vol est connu)")
    y += 6   ; la case du bip est masquée : le menu ne produit plus aucun son
    btnTmTest := d.Add("Button", "x22 y" y " w220", "Tester l'affichage")
    btnTmMeasure := d.Add("Button", "x250 y" y " w220", "Tester la mesure")
    y += 44
    txTmTest := d.Add("Text", "x22 y" y " w460 r2", "")
    y += 50
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "x22 y" y " w460 r9", "Mesure le temps entre le moment où tu lâches la grenade (clic gauche relâché, ou relance avec la touche de sv_rethrow_last_grenade) et son explosion, lue dans console.log. Le menu active tout seul le journal du serveur (log on, mp_logdetail 3).`n`nFonctionne pour la smoke, la flash, la HE, le molotov, l'incendiaire et le leurre. Le résultat reste affiché le nombre de secondes choisi ci-dessus. La police, les couleurs, le liseré, les coins et l'opacité suivent le menu. Si tu tires avec une arme pendant que la grenade vole, le temps affiché peut être faux.")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    y += 170
    yEnd5 := y

    ; ----- Onglet Fenêtres -----
    tabs.UseTab(6)
    y := 44
    ty := y + 4
    wtSel := (WinThemeSel = "light") ? 2 : (WinThemeSel = "menu") ? 3 : 1
    d.Add("Text", "x22 y" ty " w110", "Thème")
    ddWT := d.Add("DropDownList", "x140 y" y " w260 Choose" wtSel, ["Sombre", "Clair", "Comme le menu en jeu"])
    y += 40
    ty := y + 4
    waNames := ["Bleu", "Cyan", "Vert", "Or", "Orange", "Rose", "Violet"]
    waHex := ["5B9BFF", "4FD8E8", "4FD17A", "E3C48A", "FF9F43", "FF7EB6", "B28DFF"]
    waSel := 1
    for i, h in waHex {
        if (h = WinAccent)
            waSel := i
    }
    d.Add("Text", "x22 y" ty " w110", "Accent")
    ddWA := d.Add("DropDownList", "x140 y" y " w260 Choose" waSel, waNames)
    y += 40
    ty := y + 4
    wfSel := 1
    for i, f in fonts {
        if (i > 1 && f = WinFontName)
            wfSel := i
    }
    d.Add("Text", "x22 y" ty " w110", "Police")
    ddWF := d.Add("DropDownList", "x140 y" y " w260 Choose" wfSel, fonts)
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Taille du texte")
    slWS := d.Add("Slider", "x140 y" y " w260 Range90-120 ToolTip", WinScale)
    txWS := d.Add("Text", "x406 y" ty " w70", WinScale " %")
    slWS.OnEvent("Change", (*) => (txWS.Text := slWS.Value " %", PreviewStyle()))
    ddWT.OnEvent("Change", PreviewStyle)
    ddWA.OnEvent("Change", PreviewStyle)
    ddWF.OnEvent("Change", PreviewStyle)
    y += 50
    d.SetFont("s9 c" WinPal()["dim"])
    d.Add("Text", "x22 y" y " w460 r5", "Ces réglages concernent les fenêtres du menu (réglages, gestion, profils...). Ils s'appliquent à la prochaine ouverture d'une fenêtre, après « Enregistrer ». « Comme le menu en jeu » reprend le fond et le thème de l'overlay. Si les fenêtres sont illisibles, choisis « Clair », ou mets WinTheme=light dans config.ini.")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    y += 100
    yEnd6 := y

    ; ----- Onglet Aide -----
    tabs.UseTab(7)
    y := 44
    btnChkS := d.Add("Button", "x22 y" y " w440", "Vérifier l'installation")
    y += 44
    btnDiag := d.Add("Button", "x22 y" y " w440", "Copier le diagnostic (pour demander de l'aide)")
    y += 44
    btnClean := d.Add("Button", "x22 y" y " w440", "Nettoyer les captures et temps orphelins")
    y += 50
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "x22 y" y " w440 r6", "Vérifier l'installation : contrôle le dossier cfg, console.log et la connexion directe.`n`nCopier le diagnostic : met dans le presse-papiers un rapport sans données personnelles, à coller quand tu demandes de l'aide.`n`nNettoyer : supprime les captures et temps de vol qui ne correspondent plus à aucun stuff.")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    y += 120
    yEnd7 := y
    tabs.UseTab(0)
    tabH := Max(yEnd1, yEnd2, yEnd3, yEnd4, yEnd5, yEnd6, yEnd7) + 6
    tabs.Move(6, 6, 500, tabH)
    y := tabH + 18
    d.SetFont("s" WinSz() " bold")
    ledTx := d.Add("Text", "x14 y" y " w466", "")
    d.SetFont("s" WinSz() " norm")
    y += 28
    btnReset := d.Add("Button", "x12 y" y " w150", "Réinitialiser")
    btnCancel := d.Add("Button", "x+8 yp w150", "Annuler")
    btnSave := d.Add("Button", "x356 yp w150 Default", "Enregistrer")

    LedTick() {
        if !ProcessExist("cs2.exe") {
            ledTx.SetFont("c" WinPal()["bad"])
            ledTx.Text := "● CS2 n'est pas lancé"
        } else if NetOpen() {
            ledTx.SetFont("c" WinPal()["ok"])
            ledTx.Text := "● CS2 connecté (connexion directe active)"
        } else {
            ledTx.SetFont("c" WinPal()["bad"])
            ledTx.Text := "● CS2 lancé mais non connecté : relance-le avec le menu"
        }
    }
    LedTick()
    SetTimer(LedTick, 2000)

    Sync(*) {
        global ovFont, ovScale, ovX, ovY, ovOpacity, ovBg, ovBorder, ovCorner, ShotOn, ShotSize, ShotZoom, ShotPlace, ShotCorner, ShotX, ShotY, HudAuto, HudX, HudY, TimerOn, TimerAuto, TimerX, TimerY, TimerDur, FlightAsk, TimerBeep
        ovFont := (ddFont.Value = 1) ? "" : ddFont.Text
        ovScale := slScale.Value
        ovX := vl + slX.Value
        ovY := vt + slY.Value
        ovOpacity := slOp.Value
        ovBg := Format("{:02X}{:02X}{:02X}", slR.Value, slG.Value, slB.Value)
        txScale.Text := ovScale " %"
        txX.Text := ovX
        txY.Text := ovY
        txOp.Text := ovOpacity
        ovBorder := slBw.Value
        ovCorner := slCr.Value
        txBw.Text := ovBorder " px"
        txCr.Text := ovCorner
        txHex.Text := "#" ovBg
        ShotOn := chkShotOn.Value
        ShotSize := slShotSz.Value
        ShotZoom := slShotZm.Value
        ShotPlace := ddShotPos.Value
        ShotCorner := slShotCr.Value
        txShotCr.Text := ShotCorner " px"
        ShotX := vl + slShotX.Value
        ShotY := vt + slShotY.Value
        txShotSz.Text := ShotSize " px"
        txShotZm.Text := ShotZoom " px"
        txShotX.Text := ShotX
        txShotY.Text := ShotY
        slShotX.Enabled := (ShotPlace = 2)
        slShotY.Enabled := (ShotPlace = 2)
        HudAuto := (ddHudPos.Value = 1)
        HudX := vl + slHudX.Value
        HudY := vt + slHudY.Value
        txHudX.Text := HudX
        txHudY.Text := HudY
        slHudX.Enabled := !HudAuto
        slHudY.Enabled := !HudAuto
        TimerOn := chkTm.Value
        TimerAuto := (ddTmPos.Value = 1)
        TimerX := vl + slTmX.Value
        TimerY := vt + slTmY.Value
        TimerDur := slTmDur.Value
        FlightAsk := chkFlAsk.Value
        TimerBeep := chkBeep.Value
        txTmX.Text := TimerX
        txTmY.Text := TimerY
        txTmDur.Text := TimerDur " s"
        slTmX.Enabled := !TimerAuto
        slTmY.Enabled := !TimerAuto
        TmApply()
        HudSet(chkHud.Value)
        SetTimer(ApplyStyle, -40)
    }

    ThemeChange(*) {
        global ovTheme
        if (ddTheme.Value = 1) {
            ovTheme := ""
            Sync()
            return
        }
        th := THEMES[ddTheme.Value - 1]
        ovTheme := th[1]
        slR.Value := Integer("0x" SubStr(th[3], 1, 2))
        slG.Value := Integer("0x" SubStr(th[3], 3, 2))
        slB.Value := Integer("0x" SubStr(th[3], 5, 2))
        ddPreset.Choose(1)
        Sync()
    }

    BcChange(*) {
        global ovBorderCol
        if (ddBc.Value = 1) {
            ovBorderCol := ""
            edBc.Text := ""
        } else if (ddBc.Value < 12) {
            ovBorderCol := bcHex[ddBc.Value]
            edBc.Text := ovBorderCol
        }
        Sync()
    }

    BcEdit(*) {
        global ovBorderCol
        h := StrUpper(Trim(edBc.Text, "# `t"))
        if RegExMatch(h, "^[0-9A-F]{6}$") {
            ovBorderCol := h
            ddBc.Choose(12)
            for i, c in bcHex {
                if (c != "" && c = h)
                    ddBc.Choose(i)
            }
            Sync()
        }
    }

    PresetChange(*) {
        global ovTheme
        ovTheme := ""
        ddTheme.Choose(1)
        if (ddPreset.Value = 1)
            return
        h := pHex[ddPreset.Value]
        slR.Value := Integer("0x" SubStr(h, 1, 2))
        slG.Value := Integer("0x" SubStr(h, 3, 2))
        slB.Value := Integer("0x" SubStr(h, 5, 2))
        Sync()
    }

    RgbChange(*) {
        global ovTheme
        ovTheme := ""
        ddTheme.Choose(1)
        ddPreset.Choose(1)
        Sync()
    }

    ResetClick(*) {
        global ovTheme, ovBorderCol
        tv := tabs.Value
        if (tv = 1) {
            ovTheme := ""
            ddTheme.Choose(1)
            ddFont.Choose(1)
            slScale.Value := 100
            slX.Value := Max(0, Min(30 - vl, xr))
            slY.Value := Max(0, Min(100 - vt, yr))
            slOp.Value := 225
        } else if (tv = 2) {
            ovTheme := ""
            ddTheme.Choose(1)
            slR.Value := 20
            slG.Value := 24
            slB.Value := 29
            ddPreset.Choose(2)
            slBw.Value := 2
            slCr.Value := 14
            ddBc.Choose(1)
            edBc.Text := ""
            ovBorderCol := ""
        } else if (tv = 3) {
            chkShotOn.Value := 1
            slShotSz.Value := 100
            slShotZm.Value := 160
            slShotCr.Value := 3
            ddShotPos.Choose(1)
            slShotX.Value := Max(0, Min(520 - vl, xr))
            slShotY.Value := Max(0, Min(100 - vt, yr))
        } else if (tv = 4) {
            chkHud.Value := 0
            ddHudPos.Choose(1)
            slHudX.Value := Max(0, Min(12 - vl, xr))
            slHudY.Value := Max(0, Min(900 - vt, yr))
        } else if (tv = 5) {
            chkTm.Value := 1
            ddTmPos.Choose(1)
            slTmX.Value := Max(0, Min(12 - vl, xr))
            slTmY.Value := Max(0, Min(820 - vt, yr))
            slTmDur.Value := 6
            chkFlAsk.Value := 1
            chkBeep.Value := 1
        } else if (tv = 6) {
            ddWT.Choose(1)
            ddWA.Choose(1)
            ddWF.Choose(1)
            slWS.Value := 100
            txWS.Text := "100 %"
            return
        } else {
            return
        }
        Sync()
    }

    ; Aperçu du style choisi dans une petite fenêtre à côté (rien n'est enregistré avant « Enregistrer »)
    PreviewStyle(*) {
        global WinThemeSel, WinAccent, WinFontName, WinScale
        o1 := WinThemeSel
        o2 := WinAccent
        o3 := WinFontName
        o4 := WinScale
        try {
            WinThemeSel := (ddWT.Value = 2) ? "light" : (ddWT.Value = 3) ? "menu" : "dark"
            WinAccent := waHex[ddWA.Value]
            WinFontName := (ddWF.Value = 1) ? "Segoe UI" : ddWF.Text
            WinScale := slWS.Value
            try pv["g"].Destroy()
            g := WinNew("Aperçu du style")
            pv["g"] := g
            pp := WinPal()
            g.Add("Text", "x16 y14 w280 h24 +0x200", "Aperçu des fenêtres")
            g.Add("Text", "x16 y40 w280 h3 Background" pp["accent"])
            g.Add("Edit", "x16 y54 w280", "Un champ de saisie")
            g.Add("DropDownList", "x16 y+8 w280 Choose1", ["Une liste déroulante", "Autre choix"])
            g.Add("CheckBox", "x16 y+10 w280 Checked", "Une case à cocher")
            lvp := g.Add("ListView", "x16 y+10 w280 r3 -Multi", ["Nom", "Info"])
            lvp.Add("", "Smoke A", "depuis le T")
            lvp.Add("", "Flash B", "2,3 s")
            g.Add("Button", "x16 y+10 w130", "Annuler")
            g.Add("Button", "x166 yp w130 Default", "Enregistrer")
            WinStyle(g)
            d.GetPos(&sx, &sy)
            g.Show("NA AutoSize x" Max(0, sx - 340) " y" sy)
        }
        WinThemeSel := o1
        WinAccent := o2
        WinFontName := o3
        WinScale := o4
    }

    ; Test de la mesure : 60 s pendant lesquelles chaque grenade est mesurée et le résultat détaillé ici
    StopTest(*) {
        global tmTesting, tmTestCb
        if !tmTesting
            return
        tmTesting := false
        tmTestCb := ""
        SetTimer(StopTest, 0)
        TmApply()
        try txTmTest.Text := "Test terminé."
    }
    TestMeasure(*) {
        global tmTesting, tmTestCb
        tmTesting := true
        tmTestCb := (msg) => (txTmTest.Text := "Dernière mesure : " msg)
        TmApply()
        txTmTest.Text := "Test actif pendant 60 s : va dans CS2 et lance une grenade (clic ou touche de relance). Le résultat s'affiche ici et à l'écran."
        SetTimer(StopTest, -60000)
    }

    ; Place un élément à l'endroit où l'on clique à l'écran
    PickPos(slx, sly, ddPlace := "", *) {
        CoordMode("Mouse", "Screen")
        ToolTip("Clique à l'endroit voulu (Échap pour annuler)")
        while (!GetKeyState("LButton", "P") && !GetKeyState("Escape", "P"))
            Sleep(20)
        cancel := GetKeyState("Escape", "P")
        MouseGetPos(&mx, &my)
        KeyWait("LButton")
        KeyWait("Escape")
        ToolTip()
        if cancel
            return
        slx.Value := Max(0, Min(mx - vl, xr))
        sly.Value := Max(0, Min(my - vt, yr))
        if IsObject(ddPlace)
            ddPlace.Choose(2)
        Sync()
    }

    Finish(save, *) {
        global setOpen, ovFont, ovScale, ovX, ovY, ovOpacity, ovBg, ovTheme, ovBorder, ovCorner, ovBorderCol, ShotOn, ShotSize, ShotZoom, ShotPlace, ShotCorner, ShotX, ShotY, HudAuto, HudX, HudY, TimerOn, TimerAuto, TimerX, TimerY, TimerDur, FlightAsk, TimerBeep, WinThemeSel, WinAccent, WinFontName, WinScale
        if save {
            IniWrite(ovTheme, IniFile, "Overlay", "Theme")
            IniWrite(ovFont, IniFile, "Overlay", "Font")
            IniWrite(ovScale, IniFile, "Overlay", "Scale")
            IniWrite(ovX, IniFile, "Overlay", "X")
            IniWrite(ovY, IniFile, "Overlay", "Y")
            IniWrite(ovOpacity, IniFile, "Overlay", "Opacity")
            IniWrite(ovBg, IniFile, "Overlay", "Bg")
            IniWrite(ovBorder, IniFile, "Overlay", "Border")
            IniWrite(ovCorner, IniFile, "Overlay", "Corner")
            IniWrite(ovBorderCol, IniFile, "Overlay", "BorderColor")
            IniWrite(ShotOn ? 1 : 0, IniFile, "Settings", "Shot")
            IniWrite(ShotSize, IniFile, "Settings", "ShotSize")
            IniWrite(ShotZoom, IniFile, "Settings", "ShotZoom")
            IniWrite(ShotPlace, IniFile, "Settings", "ShotPos")
            IniWrite(ShotCorner, IniFile, "Settings", "ShotCorner")
            IniWrite(ShotX, IniFile, "Settings", "ShotX")
            IniWrite(ShotY, IniFile, "Settings", "ShotY")
            IniWrite(hudOn ? 1 : 0, IniFile, "Settings", "HudAtStart")
            IniWrite(HudAuto ? 1 : 0, IniFile, "Settings", "HudAuto")
            IniWrite(HudX, IniFile, "Settings", "HudX")
            IniWrite(HudY, IniFile, "Settings", "HudY")
            IniWrite(TimerOn ? 1 : 0, IniFile, "Settings", "TimerOn")
            IniWrite(TimerAuto ? 1 : 0, IniFile, "Settings", "TimerAuto")
            IniWrite(TimerX, IniFile, "Settings", "TimerX")
            IniWrite(TimerY, IniFile, "Settings", "TimerY")
            IniWrite(TimerDur, IniFile, "Settings", "TimerDur")
            IniWrite(FlightAsk ? 1 : 0, IniFile, "Settings", "FlightAsk")
            IniWrite(TimerBeep ? 1 : 0, IniFile, "Settings", "TimerBeep")
            WinThemeSel := (ddWT.Value = 2) ? "light" : (ddWT.Value = 3) ? "menu" : "dark"
            WinAccent := waHex[ddWA.Value]
            WinFontName := (ddWF.Value = 1) ? "Segoe UI" : ddWF.Text
            WinScale := slWS.Value
            IniWrite(WinThemeSel, IniFile, "Settings", "WinTheme")
            IniWrite(WinAccent, IniFile, "Settings", "WinAccent")
            IniWrite(WinFontName, IniFile, "Settings", "WinFont")
            IniWrite(WinScale, IniFile, "Settings", "WinScale")
        } else {
            ovFont := old["Font"]
            ovScale := old["Scale"]
            ovX := old["X"]
            ovY := old["Y"]
            ovOpacity := old["Opacity"]
            ovBg := old["Bg"]
            ovTheme := old["Theme"]
            ovBorder := old["Border"]
            ovCorner := old["Corner"]
            ovBorderCol := old["BorderCol"]
            ShotOn := old["ShotOn"]
            ShotSize := old["ShotSize"]
            ShotZoom := old["ShotZoom"]
            ShotPlace := old["ShotPlace"]
            ShotCorner := old["ShotCorner"]
            ShotX := old["ShotX"]
            ShotY := old["ShotY"]
            HudAuto := old["HudAuto"]
            HudX := old["HudX"]
            HudY := old["HudY"]
            TimerOn := old["Tm"]
            TimerAuto := old["TmAuto"]
            TimerX := old["TmX"]
            TimerY := old["TmY"]
            TimerDur := old["TmDur"]
            FlightAsk := old["FlAsk"]
            TimerBeep := old["TmBeep"]
            TmApply()
            HudSet(old["Hud"])
            if hudOn {
                BuildHud()
                ShowHud()
            }
        }
        setOpen := false
        StopTest()
        try pv["g"].Destroy()
        SetTimer(LedTick, 0)
        d.Destroy()
        BuildOverlay()
        if menuOpen
            Render()
        try WinActivate("ahk_exe cs2.exe")
    }

    ddTheme.OnEvent("Change", ThemeChange)
    ddFont.OnEvent("Change", Sync)
    slScale.OnEvent("Change", Sync)
    slX.OnEvent("Change", Sync)
    slY.OnEvent("Change", Sync)
    slOp.OnEvent("Change", Sync)
    ddPreset.OnEvent("Change", PresetChange)
    slR.OnEvent("Change", RgbChange)
    slG.OnEvent("Change", RgbChange)
    slB.OnEvent("Change", RgbChange)
    slBw.OnEvent("Change", Sync)
    chkShotOn.OnEvent("Click", Sync)
    chkHud.OnEvent("Click", Sync)
    ddHudPos.OnEvent("Change", Sync)
    slHudX.OnEvent("Change", Sync)
    slHudY.OnEvent("Change", Sync)
    chkTm.OnEvent("Click", Sync)
    chkFlAsk.OnEvent("Click", Sync)
    chkBeep.OnEvent("Click", Sync)
    ddTmPos.OnEvent("Change", Sync)
    slTmX.OnEvent("Change", Sync)
    slTmY.OnEvent("Change", Sync)
    slTmDur.OnEvent("Change", Sync)
    btnTmTest.OnEvent("Click", (*) => TmShow("Smoke : 2,9 s"))
    btnTmMeasure.OnEvent("Click", TestMeasure)
    btnPickM.OnEvent("Click", PickPos.Bind(slX, slY, ""))
    btnPickS.OnEvent("Click", PickPos.Bind(slShotX, slShotY, ddShotPos))
    btnPickH.OnEvent("Click", PickPos.Bind(slHudX, slHudY, ddHudPos))
    btnPickT.OnEvent("Click", PickPos.Bind(slTmX, slTmY, ddTmPos))
    slShotSz.OnEvent("Change", Sync)
    slShotZm.OnEvent("Change", Sync)
    slShotCr.OnEvent("Change", Sync)
    ddShotPos.OnEvent("Change", Sync)
    slShotX.OnEvent("Change", Sync)
    slShotY.OnEvent("Change", Sync)
    slCr.OnEvent("Change", Sync)
    ddBc.OnEvent("Change", BcChange)
    edBc.OnEvent("Change", BcEdit)
    btnSave.OnEvent("Click", Finish.Bind(true))
    btnReset.OnEvent("Click", ResetClick)
    btnChkS.OnEvent("Click", (*) => SetTimer(StartCheck, -50))
    btnDiag.OnEvent("Click", (*) => CopyDiagnostic())
    btnClean.OnEvent("Click", (*) => CleanOrphans())
    btnCancel.OnEvent("Click", Finish.Bind(false))
    d.OnEvent("Close", Finish.Bind(false))
    d.OnEvent("Escape", Finish.Bind(false))
    WinStyle(d)
    d.Show("AutoSize x" Max(0, A_ScreenWidth - 520) " y60")
    Sync()
}

; =====================================================================
;  Exec automatique du cfg d'entraînement
; =====================================================================
; Exécute cs2_practice dans le jeu (par la connexion directe).
RunPractice() {
    global tmSentSock
    WriteAndExec("exec " PracticeCfg)
    tmSentSock := 0   ; le journal du serveur est réactivé au prochain passage du chronomètre
    Sleep(400)
}

; Lance l'exec une fois par map détectée (renvoie true si exécuté)
EnsurePractice(mapKey) {
    global execMap
    if (mapKey = "")
        mapKey := "?"
    if (execMap = mapKey)
        return false
    execMap := mapKey
    RunPractice()
    return true
}

ForceExec() {
    RunPractice()
    ToolTip(PracticeCfg " exécuté")
    SetTimer(() => ToolTip(), -1500)
}

; =====================================================================
;  Cadenas : verrouiller des catégories et des stuffs contre la suppression
; =====================================================================
LoadLocks() {
    global locks
    locks := Map()
    if !FileExist(LockFile) {
        for c in DEFAULT_LOCKED_CATS
            locks["cat|" c] := 1
        SaveLocks()
        return
    }
    for line in StrSplit(FileRead(LockFile, "UTF-8"), "`n", "`r") {
        line := Trim(line)
        if (line != "")
            locks[line] := 1
    }
}

SaveLocks() {
    txt := ""
    for k in locks
        txt .= k "`n"
    try FileDelete(LockFile)
    FileAppend(txt, LockFile, "UTF-8-RAW")
}

LockPress() {
    if (level = 0 || level = 4 || utilMode)
        return
    key := ""
    label := ""
    if (level = 1) {
        if (cats.Length = 0)
            return
        c := cats[catIdx]
        if (c = FAV_CAT || c = REC_CAT) {
            SetStatus("Catégorie automatique : pas de cadenas")
            return
        }
        key := "cat|" c
        label := "Catégorie " c
    } else {
        cur := CurrentItem()
        if !IsObject(cur)
            return
        key := "it|" cur[5]
        label := cur[1]
    }
    if locks.Has(key) {
        locks.Delete(key)
        SetStatus("Déverrouillé : " label)
    } else {
        locks[key] := 1
        SetStatus(LOCK_ICON " Verrouillé : " label)
    }
    SaveLocks()
    Render()
}

; =====================================================================
;  Gestion des stuffs et des catégories (fenêtre de gestion)
; =====================================================================
BuildLine(cat, name, cmd, info) {
    ln := cat " | " name " | " cmd
    if (info != "")
        ln .= " | " info
    return ln
}

; Renvoie [liste des catégories, liste des stuffs [catégorie, nom, commande, info]]
ReadEntries(path) {
    catList := []
    seen := Map()
    ents := []
    if !FileExist(path)
        return [catList, ents]
    for line in ReadLines(path) {
        t := Trim(line)
        if !IsDataLine(t)
            continue
        p := StrSplit(t, "|", " `t", 4)
        if (p[1] = "@cat") {
            if (p.Length >= 2 && p[2] != "" && !seen.Has(p[2])) {
                seen[p[2]] := 1
                catList.Push(p[2])
            }
            continue
        }
        if (p.Length < 3)
            continue
        c := p[1]
        if !seen.Has(c) {
            seen[c] := 1
            catList.Push(c)
        }
        ents.Push([c, p[2], p[3], (p.Length >= 4) ? p[4] : ""])
    }
    return [catList, ents]
}

; Applique fn(p, line) à chaque ligne de donnée.
; fn renvoie la ligne (inchangée ou modifiée) ou false pour la supprimer.
TransformFile(path, fn) {
    if !FileExist(path)
        return 0
    out := []
    changed := 0
    for line in ReadLines(path) {
        t := Trim(line)
        if IsDataLine(t) {
            p := StrSplit(t, "|", " `t", 4)
            r := fn(p, line)
            if (Type(r) != "String") {
                changed += 1
                continue
            }
            if (r !== line)
                changed += 1
            out.Push(r)
        } else {
            out.Push(line)
        }
    }
    if (changed > 0)
        RewriteFile(path, out)
    return changed
}

EnsureCatDeclared(path, cat) {
    for c in AllCategories(path) {
        if (c = cat)
            return
    }
    AppendLine(path, "@cat | " cat)
}

MoveStuffsInFile(path, src, names, dest) {
    nameSet := Map()
    for nm in names
        nameSet[nm] := 1
    cnt := Map("n", 0)
    Fn(p, line) {
        if (p[1] != "@cat" && p.Length >= 3 && p[1] = src && nameSet.Has(p[2])) {
            cnt["n"] += 1
            return BuildLine(dest, p[2], p[3], (p.Length >= 4) ? p[4] : "")
        }
        return line
    }
    TransformFile(path, Fn)
    return cnt["n"]
}

RenameStuffInFile(path, cat, oldName, newName) {
    Fn(p, line) {
        if (p[1] != "@cat" && p.Length >= 3 && p[1] = cat && p[2] = oldName)
            return BuildLine(cat, newName, p[3], (p.Length >= 4) ? p[4] : "")
        return line
    }
    return TransformFile(path, Fn)
}

SetInfoInFile(path, cat, name, info) {
    Fn(p, line) {
        if (p[1] != "@cat" && p.Length >= 3 && p[1] = cat && p[2] = name) {
            old := (p.Length >= 4) ? p[4] : ""
            return BuildLine(cat, name, p[3], JoinInfo(info, SplitInfo(old)[2]))
        }
        return line
    }
    return TransformFile(path, Fn)
}

RenameCatInFile(path, oldCat, newCat) {
    Fn(p, line) {
        if (p[1] = "@cat")
            return (p.Length >= 2 && p[2] = oldCat) ? "@cat | " newCat : line
        if (p.Length >= 3 && p[1] = oldCat)
            return BuildLine(newCat, p[2], p[3], (p.Length >= 4) ? p[4] : "")
        return line
    }
    return TransformFile(path, Fn)
}

; Supprime une catégorie SANS supprimer ses stuffs : ils sont déplacés dans dest.
; Renvoie le nombre de stuffs déplacés.
DeleteCatKeepStuffs(path, src, dest) {
    cnt := Map("n", 0)
    Fn(p, line) {
        if (p[1] = "@cat")
            return (p.Length >= 2 && p[2] = src) ? false : line
        if (p.Length >= 3 && p[1] = src) {
            cnt["n"] += 1
            return BuildLine(dest, p[2], p[3], (p.Length >= 4) ? p[4] : "")
        }
        return line
    }
    TransformFile(path, Fn)
    return cnt["n"]
}

PurgeRecent(key) {
    i := recents.Length
    while (i >= 1) {
        if (recents[i][5] = key)
            recents.RemoveAt(i)
        i -= 1
    }
    SaveRecents()
}

; Un stuff change de clé (catégorie ou nom modifié) : favoris et verrou suivent
Rekey(oldKey, newKey) {
    if favs.Has(oldKey) {
        favs.Delete(oldKey)
        favs[newKey] := 1
        SaveFavs()
    }
    if locks.Has("it|" oldKey) {
        locks.Delete("it|" oldKey)
        locks["it|" newKey] := 1
        SaveLocks()
    }
    PurgeRecent(oldKey)
}

ShowManager() {
    global mgrOpen
    if mgrOpen
        return
    if menuOpen
        CloseMenu()
    LoadMaps()
    if (mapNames.Length = 0) {
        MsgBox("Aucun fichier .txt dans " MapsDir)
        return
    }
    mgrOpen := true
    labels := []
    for mn in mapNames
        labels.Push(mn)
    labels.Push("Communs (toutes les maps)")
    commonIdx := labels.Length
    selMap := 1
    pref := (loadedMap != "") ? loadedMap : LastMap
    for mi, mn2 in mapNames {
        if (mn2 = pref)
            selMap := mi
    }
    ui := Map("busy", false)

    d := WinNew("Gestion des stuffs et des catégories", "+AlwaysOnTop +Resize +MinSize780x540")
    d.Add("Text", "x12 y16 w50", "Map")
    ddMap := d.Add("DropDownList", "x64 y12 w320 Choose" selMap, labels)
    d.Add("Text", "x12 y54 w260", "Catégories")
    d.Add("Text", "x290 y54 w170", "Stuffs de la catégorie")
    edFind := d.Add("Edit", "x460 y50 w300")
    SendMessage(0x1501, 1, StrPtr("Rechercher un stuff..."), edFind)   ; texte grisé quand le champ est vide
    lvCat := d.Add("ListView", "x12 y78 w260 r14 -Multi", ["Catégorie", "Stuffs", "Cad."])
    lvSt := d.Add("ListView", "x290 y78 w470 r14", ["Nom", "Cad.", "Vol", "Info"])
    lvCat.ModifyCol(1, 140)
    lvCat.ModifyCol(2, 50)
    lvCat.ModifyCol(3, 45)
    lvSt.ModifyCol(1, 190)
    lvSt.ModifyCol(2, 45)
    lvSt.ModifyCol(3, 55)
    lvSt.ModifyCol(4, 150)
    lvCat.GetPos(&lx, &ly, &lw, &lh)
    row1 := ly + lh + 8
    row2 := row1 + 34
    row2t := row2 + 4
    note := row2 + 44
    status := note + 58
    bottom := status + 28
    btnCatNew := d.Add("Button", "x12 y" row1 " w126", "Nouvelle catégorie")
    btnCatRen := d.Add("Button", "x+8 yp w126", "Renommer")
    btnCatDel := d.Add("Button", "x12 y" row2 " w126", "Supprimer")
    btnCatLock := d.Add("Button", "x+8 yp w126", "Cadenas")
    btnStEdit := d.Add("Button", "x290 y" row1 " w86", "Modifier…")
    btnStRen := d.Add("Button", "x+8 yp w86", "Renommer")
    btnStInfo := d.Add("Button", "x+8 yp w86", "Info chat")
    btnStLock := d.Add("Button", "x+8 yp w86", "Cadenas")
    btnStDel := d.Add("Button", "x+8 yp w86", "Supprimer")
    txMoveLbl := d.Add("Text", "x290 y" row2t " w100", "Déplacer vers")
    cbDest := d.Add("ComboBox", "x395 y" row2 " w230", [])
    btnMove := d.Add("Button", "x+8 yp-1 w125 Default", "Déplacer")
    d.SetFont("s9 c8A8F96")
    txNote := d.Add("Text", "x12 y" note " w748 r3", "Double-clique sur un stuff (ou « Modifier… ») pour tout changer : type, catégorie, nom, coordonnées, commandes, info. Supprimer une catégorie garde ses stuffs : ils sont déplacés dans « " FALLBACK_CAT " ». Sélectionne plusieurs stuffs avec Ctrl ou Maj. Un élément verrouillé ne peut être ni supprimé, ni renommé, ni déplacé.")
    d.SetFont("s" WinSz() " c" WinPal()["ok"])
    stText := d.Add("Text", "x12 y" status " w748", "")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    btnClose := d.Add("Button", "x12 y" bottom " w120", "Fermer")
    btnUndo := d.Add("Button", "x+8 yp w260", "Annuler la suppression (Ctrl+Z)")

    MapPath() {
        if (ddMap.Value = commonIdx)
            return MapsDir "\_commun.txt"
        return mapFiles[ddMap.Value]
    }
    KeyMap() {
        if (ddMap.Value != commonIdx)
            return mapNames[ddMap.Value]
        return (loadedMap != "") ? loadedMap : mapNames[1]
    }
    Say(msg) {
        stText.Text := msg
    }
    SelCat() {
        r := lvCat.GetNext(0)
        return r ? lvCat.GetText(r, 1) : ""
    }
    SelStuff() {
        out := []
        r := 0
        while (r := lvSt.GetNext(r))
            out.Push(lvSt.GetText(r, 1))
        return out
    }
    StuffKey(cat, name) {
        return KeyMap() "|" cat "|" name
    }

    RefreshStuffs() {
        lvSt.Delete()
        cc := SelCat()
        if (cc = "")
            return
        q := Trim(edFind.Value)
        for ent in ReadEntries(MapPath())[2] {
            if (ent[1] != cc)
                continue
            if (q != "" && !InStr(ent[2], q) && !InStr(InfoDisp(ent[4]), q))
                continue
            ft := FlightTime(ent[3])
            lvSt.Add("", ent[2], locks.Has("it|" StuffKey(cc, ent[2])) ? LOCK_ICON : "", (ft != "") ? FlightText(ft) : "", InfoDisp(ent[4]))
        }
    }

    ; Clic droit sur un stuff : actions rapides
    StuffMenu(ctrl, item, isRight, x, y) {
        if (item = 0)
            return
        lvSt.Modify(item, "Select Focus")
        m := Menu()
        m.Add("Modifier...", EditStuff)
        m.Add("Renommer", RenStuff)
        m.Add("Info chat", InfoStuff)
        m.Add("Cadenas", LockStuff)
        m.Add()
        m.Add("Supprimer", DelStuff)
        m.Show()
    }

    ; Fenêtre redimensionnable : les listes grandissent, les boutons suivent
    ResizeMgr(g, minmax, w, h) {
        if (minmax = -1 || !ui.Has("h0"))
            return
        dh := h - ui["h0"]
        dw := w - ui["w0"]
        lvCat.Move(, , , ui["lh0"] + dh)
        lvSt.Move(, , ui["lw0"] + dw, ui["lh0"] + dh)
        for c, y0 in ui["ys"]
            c.Move(, y0 + dh)
        edFind.Move(, , Max(120, ui["fw0"] + dw))
    }

    RefreshCats(keep := "") {
        ui["busy"] := true
        if (keep = "")
            keep := SelCat()
        lvCat.Delete()
        ents := ReadEntries(MapPath())
        cnt := Map()
        for ent in ents[2]
            cnt[ent[1]] := cnt.Has(ent[1]) ? cnt[ent[1]] + 1 : 1
        cbDest.Delete()
        pick := 0
        for k, cn in ents[1] {
            lvCat.Add("", cn, cnt.Has(cn) ? cnt[cn] : 0, locks.Has("cat|" cn) ? LOCK_ICON : "")
            if (cn = keep)
                pick := k
        }
        if (ents[1].Length > 0)
            cbDest.Add(ents[1])
        if pick
            lvCat.Modify(pick, "Select Focus")
        ui["busy"] := false
        RefreshStuffs()
    }

    CatSelected(*) {
        if ui["busy"]
            return
        RefreshStuffs()
    }

    BadName(nm) {
        c1 := SubStr(nm, 1, 1)
        return (c1 = "[" || c1 = "@")
    }

    NewCat(*) {
        nm := CleanField(AskText("Nouvelle catégorie", "Nom de la nouvelle catégorie :", "", "ahk_id " d.Hwnd))
        if (nm = "")
            return
        if BadName(nm) {
            Say("Le nom ne peut pas commencer par [ ou @")
            return
        }
        exCn := CatNameTaken(MapPath(), nm)
        if (exCn != "") {
            Say("Cette catégorie existe déjà : " exCn)
            return
        }
        AppendLine(MapPath(), "@cat | " nm)
        RefreshCats(nm)
        Say("Catégorie ajoutée : " nm)
    }

    RenCat(*) {
        oc := SelCat()
        if (oc = "") {
            Say("Sélectionne une catégorie")
            return
        }
        if locks.Has("cat|" oc) {
            Say(LOCK_ICON " Catégorie verrouillée : déverrouille-la d'abord")
            return
        }
        nm := CleanField(AskText("Renommer la catégorie", "Nouveau nom de « " oc " » :", oc, "ahk_id " d.Hwnd))
        if (nm = "" || nm == oc)
            return
        if BadName(nm) {
            Say("Le nom ne peut pas commencer par [ ou @")
            return
        }
        exRn := CatNameTaken(MapPath(), nm, oc)
        if (exRn != "") {
            Say("Une catégorie « " exRn " » existe déjà")
            return
        }
        for ent in ReadEntries(MapPath())[2] {
            if (ent[1] = oc)
                Rekey(StuffKey(oc, ent[2]), StuffKey(nm, ent[2]))
        }
        RenameCatInFile(MapPath(), oc, nm)
        RefreshCats(nm)
        Say("Catégorie renommée : " oc " > " nm)
    }

    DelCat(*) {
        oc := SelCat()
        if (oc = "") {
            Say("Sélectionne une catégorie")
            return
        }
        if locks.Has("cat|" oc) {
            Say(LOCK_ICON " Catégorie verrouillée : déverrouille-la d'abord")
            return
        }
        ents := ReadEntries(MapPath())[2]
        total := 0
        for ent in ents {
            if (ent[1] = oc) {
                total += 1
                if locks.Has("it|" StuffKey(oc, ent[2])) {
                    Say(LOCK_ICON " Contient un stuff verrouillé : déverrouille-le d'abord")
                    return
                }
            }
        }
        if (oc = FALLBACK_CAT && total > 0) {
            Say("Déplace d'abord les stuffs de « " oc " » vers une autre catégorie")
            return
        }
        if (total > 0)
            question := "Supprimer la catégorie « " oc " » ?`nSes " total " stuff(s) seront déplacés dans « " FALLBACK_CAT " »."
        else
            question := "Supprimer la catégorie vide « " oc " » ?"
        if (MsgBox(question, "Gestion", 0x40024) != "Yes")
            return
        for ent in ents {
            if (ent[1] = oc)
                Rekey(StuffKey(oc, ent[2]), StuffKey(FALLBACK_CAT, ent[2]))
        }
        DeleteCatKeepStuffs(MapPath(), oc, FALLBACK_CAT)
        RefreshCats((total > 0) ? FALLBACK_CAT : "")
        if (total > 0)
            Say("Catégorie supprimée : " total " stuff(s) déplacé(s) dans « " FALLBACK_CAT " »")
        else
            Say("Catégorie supprimée")
    }

    LockCat(*) {
        oc := SelCat()
        if (oc = "") {
            Say("Sélectionne une catégorie")
            return
        }
        if locks.Has("cat|" oc) {
            locks.Delete("cat|" oc)
            Say("Déverrouillée : " oc)
        } else {
            locks["cat|" oc] := 1
            Say(LOCK_ICON " Verrouillée : " oc)
        }
        SaveLocks()
        RefreshCats(oc)
    }

    RenStuff(*) {
        sc := SelCat()
        names := SelStuff()
        if (names.Length != 1) {
            Say("Sélectionne un seul stuff à renommer")
            return
        }
        old := names[1]
        if locks.Has("it|" StuffKey(sc, old)) {
            Say(LOCK_ICON " Stuff verrouillé : déverrouille-le d'abord")
            return
        }
        nm := CleanField(AskText("Renommer le stuff", "Nouveau nom de « " old " » :", old, "ahk_id " d.Hwnd))
        if (nm = "" || nm == old)
            return
        exDn := StuffNameTaken(MapPath(), nm, sc, old)
        if (exDn != "") {
            Say("Un stuff « " nm " » existe déjà (catégorie « " exDn " »)")
            return
        }
        Rekey(StuffKey(sc, old), StuffKey(sc, nm))
        RenameStuffInFile(MapPath(), sc, old, nm)
        RefreshStuffs()
        Say("Stuff renommé : " nm)
    }

    InfoStuff(*) {
        sc := SelCat()
        names := SelStuff()
        if (names.Length != 1) {
            Say("Sélectionne un seul stuff")
            return
        }
        cur := ""
        for ent in ReadEntries(MapPath())[2] {
            if (ent[1] = sc && ent[2] = names[1])
                cur := SplitInfo(ent[4])[1]
        }
        inf := AskText("Info du chat", "Message affiché dans le chat pour « " names[1] " » :", cur, "ahk_id " d.Hwnd)
        if (inf == "" && cur == "")
            return
        SetInfoInFile(MapPath(), sc, names[1], CleanInfo(inf))
        RefreshStuffs()
        Say("Info mise à jour")
    }

    LockStuff(*) {
        sc := SelCat()
        names := SelStuff()
        if (names.Length = 0) {
            Say("Sélectionne un ou plusieurs stuffs")
            return
        }
        for nm in names {
            k := "it|" StuffKey(sc, nm)
            if locks.Has(k)
                locks.Delete(k)
            else
                locks[k] := 1
        }
        SaveLocks()
        RefreshStuffs()
        Say("Cadenas mis à jour")
    }

    DelStuff(*) {
        sc := SelCat()
        names := SelStuff()
        if (names.Length = 0) {
            Say("Sélectionne un ou plusieurs stuffs")
            return
        }
        for nm in names {
            if locks.Has("it|" StuffKey(sc, nm)) {
                Say(LOCK_ICON " « " nm " » est verrouillé : déverrouille-le d'abord")
                return
            }
        }
        if (MsgBox("Supprimer définitivement " names.Length " stuff(s) ?", "Gestion", 0x40024) != "Yes")
            return
        for nm in names {
            DeleteLineFrom(MapPath(), sc, nm)
            PurgeKey(StuffKey(sc, nm))
        }
        RefreshCats(sc)
        Say(names.Length " stuff(s) supprimé(s)")
    }

    MoveStuff(*) {
        sc := SelCat()
        names := SelStuff()
        if (names.Length = 0) {
            Say("Sélectionne un ou plusieurs stuffs")
            return
        }
        dest := CleanField(cbDest.Text)
        if (dest = "") {
            Say("Choisis ou tape la catégorie de destination")
            return
        }
        if BadName(dest) {
            Say("Le nom ne peut pas commencer par [ ou @")
            return
        }
        exDest := CatNameTaken(MapPath(), dest)
        if (exDest != "")
            dest := exDest   ; catégorie existante (même nom à la casse près)
        if (dest == sc) {
            Say("Ces stuffs sont déjà dans cette catégorie")
            return
        }
        for nm in names {
            for ent in ReadEntries(MapPath())[2] {
                if (ent[1] = dest && ent[2] = nm) {
                    Say("« " nm " » existe déjà dans « " dest " »")
                    return
                }
            }
        }
        for nm in names {
            if locks.Has("it|" StuffKey(sc, nm)) {
                Say(LOCK_ICON " « " nm " » est verrouillé : déverrouille-le d'abord")
                return
            }
        }
        for nm in names
            Rekey(StuffKey(sc, nm), StuffKey(dest, nm))
        moved := MoveStuffsInFile(MapPath(), sc, names, dest)
        EnsureCatDeclared(MapPath(), sc)
        RefreshCats(dest)
        Say(moved " stuff(s) déplacé(s) vers « " dest " »")
    }

    EditStuff(*) {
        sc := SelCat()
        names := SelStuff()
        if (names.Length != 1) {
            Say("Sélectionne un seul stuff à modifier")
            return
        }
        target := ""
        for ent in ReadEntries(MapPath())[2] {
            if (ent[1] = sc && ent[2] = names[1]) {
                target := ent
                break
            }
        }
        if !IsObject(target) {
            Say("Stuff introuvable")
            return
        }
        editedCat := EditStuffDialog(MapPath(), target, KeyMap(), d.Hwnd)
        if (editedCat != "") {
            RefreshCats(editedCat)
            Say("Stuff modifié")
        }
    }

    UndoStuff(*) {
        r := UndoLast()
        if !IsObject(r) {
            Say("Rien à annuler")
            return
        }
        RefreshCats()
        Say("Stuff restauré : « " r[1] " » (" r[2] ", catégorie « " r[3] " »)")
    }

    Finish(*) {
        global mgrOpen
        mgrOpen := false
        try {
            HotIfWinActive("ahk_id " d.Hwnd)
            Hotkey("^z", "Off")
            HotIf()
        }
        try {
            if (WinGetMinMax("ahk_id " d.Hwnd) = 0) {
                WinGetPos(&gx, &gy, &gw, &gh, "ahk_id " d.Hwnd)
                IniWrite(gx, IniFile, "State", "MgrX")
                IniWrite(gy, IniFile, "State", "MgrY")
                IniWrite(gw, IniFile, "State", "MgrW")
                IniWrite(gh, IniFile, "State", "MgrH")
            }
        }
        d.Destroy()
        try WinActivate("ahk_exe cs2.exe")
    }

    ddMap.OnEvent("Change", (*) => RefreshCats(""))
    edFind.OnEvent("Change", (*) => RefreshStuffs())
    lvSt.OnEvent("ContextMenu", StuffMenu)
    d.OnEvent("Size", ResizeMgr)
    lvCat.OnEvent("ItemSelect", CatSelected)
    btnCatNew.OnEvent("Click", NewCat)
    btnCatRen.OnEvent("Click", RenCat)
    btnCatDel.OnEvent("Click", DelCat)
    btnCatLock.OnEvent("Click", LockCat)
    btnUndo.OnEvent("Click", UndoStuff)
    HotIfWinActive("ahk_id " d.Hwnd)
    Hotkey("^z", UndoStuff)
    HotIf()
    btnStEdit.OnEvent("Click", EditStuff)
    lvSt.OnEvent("DoubleClick", EditStuff)
    btnStRen.OnEvent("Click", RenStuff)
    btnStInfo.OnEvent("Click", InfoStuff)
    btnStLock.OnEvent("Click", LockStuff)
    btnStDel.OnEvent("Click", DelStuff)
    btnMove.OnEvent("Click", MoveStuff)
    btnClose.OnEvent("Click", Finish)
    d.OnEvent("Close", Finish)
    d.OnEvent("Escape", Finish)
    RefreshCats("")
    WinStyle(d)
    d.Show("AutoSize Center")
    d.GetClientPos(, , &cw0, &ch0)
    lvSt.GetPos(, , &lw0, &lh0)
    edFind.GetPos(, , &fw0)
    ui["w0"] := cw0
    ui["h0"] := ch0
    ui["lw0"] := lw0
    ui["lh0"] := lh0
    ui["fw0"] := fw0
    ys := Map()
    for c in [btnCatNew, btnCatRen, btnCatDel, btnCatLock, btnStEdit, btnStRen, btnStInfo, btnStLock, btnStDel, cbDest, btnMove, stText, btnClose, btnUndo, txMoveLbl, txNote] {
        c.GetPos(, &cy)
        ys[c] := cy
    }
    ui["ys"] := ys
    ; retrouve la taille et la place de la dernière fois (si elles sont encore à l'écran)
    mw := ToInt(IniRead(IniFile, "State", "MgrW", "0"), 0)
    mh := ToInt(IniRead(IniFile, "State", "MgrH", "0"), 0)
    mx := ToInt(IniRead(IniFile, "State", "MgrX", "0"), 0)
    my := ToInt(IniRead(IniFile, "State", "MgrY", "0"), 0)
    if (mw >= 780 && mh >= 540) {
        vl := SysGet(76)
        vt := SysGet(77)
        vw := SysGet(78)
        vh := SysGet(79)
        mw := Min(mw, vw)
        mh := Min(mh, vh)
        mx := Max(vl, Min(mx, vl + vw - 200))
        my := Max(vt, Min(my, vt + vh - 100))
        try d.Move(mx, my, mw, mh)
    }
}

; =====================================================================
;  Modification complète d'un stuff (fenêtre ouverte depuis la gestion)
; =====================================================================
ReplaceStuffInFile(path, oldCat, oldName, newCat, newName, newCmd, newInfo) {
    done := Map("v", false)
    Fn(p, line) {
        if (!done["v"] && p[1] != "@cat" && p.Length >= 3 && p[1] = oldCat && p[2] = oldName) {
            done["v"] := true
            return BuildLine(newCat, newName, newCmd, newInfo)
        }
        return line
    }
    TransformFile(path, Fn)
    return done["v"]
}

; Renvoie la catégorie (nouvelle) du stuff si enregistré, "" si annulé
EditStuffDialog(path, ent, keyMap, ownerHwnd) {
    oldCat := ent[1]
    oldName := ent[2]
    oldKey := keyMap "|" oldCat "|" oldName
    cmd := ent[3]
    posTxt := ""
    others := cmd
    pat := "i)setpos\s+(" NUM ")\s+(" NUM ")\s+(" NUM ")\s*;\s*setang\s+(" NUM ")\s+(" NUM ")(?:\s+" NUM ")?"
    if RegExMatch(cmd, pat, &pm) {
        posTxt := "setpos " pm[1] " " pm[2] " " pm[3] "; setang " pm[4] " " pm[5]
        others := StrReplace(cmd, pm[0], "", , , 1)
        others := RegExReplace(others, "\s*;(\s*;)+", ";")
        others := Trim(others, " `t;")
    }
    res := Map("cat", "")
    typeSel := NO_TYPE
    for tp0 in Types {
        if (tp0 != NO_TYPE && (InStr(oldCat, tp0 " - ") = 1 || oldCat = tp0))
            typeSel := tp0
    }

    d := WinNew("Modifier le stuff", "+AlwaysOnTop")
    d.Add("Text", "xm w110", "Type")
    ddType := d.Add("DropDownList", "x130 yp-3 w380 Choose1", Types)
    d.Add("Text", "xm y+14 w110", "Catégorie")
    cbCat := d.Add("ComboBox", "x130 yp-3 w380", [])
    d.Add("Text", "xm y+14 w110", "Nom")
    edName := d.Add("Edit", "x130 yp-3 w380", oldName)
    d.SetFont("s9 c" WinPal()["bad"])
    txNameErr := d.Add("Text", "x130 y+2 w380 h16", "")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    fl := Map("v", "")
    flOld := FlightTime(cmd)
    d.Add("Text", "xm y+10 w110", "Temps de vol")
    txFlight := d.Add("Text", "x130 yp w120", (flOld != "") ? FlightText(flOld) : "non mesuré")
    btnFlight := d.Add("Button", "x+8 yp-5 w160", "Mesurer...")
    btnFlightDel := d.Add("Button", "x+8 yp w90", "Supprimer")
    btnFlightDel.Enabled := (flOld != "")
    d.Add("Text", "xm y+14 w110", "Tags")
    cbTag := d.Add("ComboBox", "x130 yp-3 w380", [])
    btnTagAdd := d.Add("Button", "x130 y+6 w120", "Ajouter")
    btnTagDel := d.Add("Button", "x+6 yp w120", "Retirer")
    btnTagInfo := d.Add("Button", "x+6 yp w128", "→ Info")
    d.SetFont("s9 c8A8F96")
    txTags := d.Add("Text", "x130 y+4 w380 r2", "")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    d.Add("Text", "xm y+10 w110", "Info chat")
    edInfo := d.Add("Edit", "x130 yp-3 w380 r3", SplitInfo(ent[4])[1])
    d.Add("Text", "xm y+14 w110", "Position")
    edPos := d.Add("Edit", "x130 yp-3 w380 r2", posTxt)
    btnRecap := d.Add("Button", "x130 y+6 w380", "Recapturer ma position actuelle (en jeu)")
    d.Add("Text", "xm y+14 w110", "Autres commandes")
    edOthers := d.Add("Edit", "x130 yp-3 w380 r2", others)
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "xm y+6 w500", "Exemples : give weapon_smokegrenade ou sv_rethrow_last_grenade. Sépare les commandes par un point-virgule.")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    shotFile := ShotPath(keyMap, cmd)
    curShot := shotFile
    shotRedone := false
    picSz := Min(ShotZoom, 160)
    hasShot := ShotValid(shotFile)
    d.Add("Text", "xm y+10 w110", "Capture")
    picShot := d.Add("Picture", "x130 yp-3 w" picSz " h" picSz, "")
    if hasShot {
        try {
            picShot.Value := "*w" picSz " *h" picSz " " shotFile
        } catch {
            hasShot := false
        }
    }
    btnShotNew := d.Add("Button", "x+12 yp w210", "Refaire la capture (en jeu)")
    btnShotDel := d.Add("Button", "xp y+6 w210", "Supprimer la capture")
    btnShotDel.Enabled := hasShot
    picShot.GetPos(, &pY0, , &pH0)
    btnShotDel.GetPos(, &bY0, , &bH0)
    saveTop := Max(pY0 + pH0, bY0 + bH0) + 16
    btnCancel := d.Add("Button", "xm y" saveTop " w180", "Annuler")
    btnSave := d.Add("Button", "x330 y" saveTop " w180 Default", "Enregistrer")

    for ec in AllCategories(path)
        cbCat.Add([ec])
    ddType.Choose(typeSel)
    cbCat.Text := oldCat

    ; Tags du stuff (déjà présents + ceux qu'on ajoute ici)
    tagSel := TagList(SplitInfo(ent[4])[2])
    ShowTags() {
        txTags.Text := (tagSel.Length = 0) ? "Aucun tag : choisis ou tape un tag, puis clique sur Ajouter" : "Tags : " TagsDisp(TagsToStr(tagSel))
    }
    FillTags() {
        ftTxt := cbTag.Text
        cbTag.Delete()
        ftLst := AllTags()
        if (ftLst.Length > 0)
            cbTag.Add(ftLst)
        cbTag.Text := ftTxt
    }
    TagAddClick(*) {
        taT := CleanTag(cbTag.Text)
        if (taT = "")
            return
        taHave := false
        for taX in tagSel {
            if (StrLower(taX) = StrLower(taT))
                taHave := true
        }
        if !taHave {
            tagSel.Push(taT)
            SaveTag(taT)
        }
        FillTags()
        cbTag.Text := ""
        ShowTags()
    }
    TagDelClick(*) {
        tdT := CleanTag(cbTag.Text)
        tdI := 0
        if (tdT != "") {
            for tdK, tdX in tagSel {
                if (StrLower(tdX) = StrLower(tdT))
                    tdI := tdK
            }
        } else if (tagSel.Length > 0) {
            tdI := tagSel.Length
        }
        if (tdI > 0)
            tagSel.RemoveAt(tdI)
        cbTag.Text := ""
        ShowTags()
    }
    ; Recopie le nom des tags dans le message d'info du chat (le tag reste aussi enregistré comme tag)
    TagInfoClick(*) {
        tiTxt := TagsToStr(tagSel)
        if (tiTxt = "") {
            MsgBox("Ajoute d'abord un tag avec le bouton Ajouter.", "Tags", 0x40030)
            return
        }
        tiCur := Trim(edInfo.Value)
        if (tiCur = "")
            edInfo.Value := tiTxt
        else if !InStr(tiCur, tiTxt)
            edInfo.Value := tiCur " - " tiTxt
    }
    FillTags()
    ShowTags()
    btnTagAdd.OnEvent("Click", TagAddClick)
    btnTagDel.OnEvent("Click", TagDelClick)
    btnTagInfo.OnEvent("Click", TagInfoClick)

    NameCheck(*) {
        ncN := CleanField(edName.Value)
        ncD := (ncN = "" || ncN = oldName) ? "" : StuffNameTaken(path, ncN, oldCat, oldName)
        txNameErr.Text := (ncD != "") ? "Ce nom est déjà pris (catégorie « " ncD " »)." : ""
    }
    edName.OnEvent("Change", NameCheck)

    CatSync(*) {
        tx2 := Trim(cbCat.Text)
        ty2 := NO_TYPE
        for tp2 in Types {
            if (tp2 != NO_TYPE && (InStr(tx2, tp2 " - ") = 1 || tx2 = tp2))
                ty2 := tp2
        }
        ddType.Choose(ty2)
    }

    CatChange(*) {
        SetTimer(CatSync, -30)
    }

    ; Changer le type réécrit le préfixe "Type - " de la catégorie
    TypeChange(*) {
        tx3 := Trim(cbCat.Text)
        base := tx3
        for tp3 in Types {
            if (tp3 = NO_TYPE)
                continue
            if (InStr(tx3, tp3 " - ") = 1) {
                base := SubStr(tx3, StrLen(tp3) + 4)
                break
            }
            if (tx3 = tp3) {
                base := ""
                break
            }
        }
        nt := ddType.Text
        if (nt = NO_TYPE)
            cbCat.Text := base
        else
            cbCat.Text := (base != "") ? nt " - " base : nt
    }

    Recap(*) {
        if !FileExist(ConsoleLog) {
            MsgBox("console.log introuvable : lance CS2 avec l'option -condebug.", "Modifier", 0x40030)
            return
        }
        try WinActivate("ahk_exe cs2.exe")
        WinWaitActive("ahk_exe cs2.exe", , 2)
        Sleep(250)
        np := CapturePos()
        WinActivate("ahk_id " d.Hwnd)
        if (np = "")
            MsgBox("Position non capturée. Vérifie que tu es en jeu et que -condebug est actif.", "Modifier", 0x40030)
        else
            edPos.Value := np
    }

    ; Mesure le temps de vol : téléporte au repère, le joueur lance la grenade et valide le résultat
    FlightClick(*) {
        flPos := Trim(edPos.Value)
        if (flPos != "")
            flPos := NormalizePos(flPos)
        if (flPos = "") {
            MsgBox("Renseigne d'abord une position valide (setpos x y z; setang pitch yaw).", "Temps de vol", 0x40030)
            return
        }
        flOth := Trim(CleanField(edOthers.Value), " `t;")
        flCmd := (flOth != "") ? flPos "; " flOth : flPos
        d.Hide()
        try WinHide("ahk_id " ownerHwnd)
        flSecs := MeasureFlight(flCmd, ddType.Text)
        try WinShow("ahk_id " ownerHwnd)
        d.Show()
        WinActivate("ahk_id " d.Hwnd)
        if (flSecs > 0) {
            fl["v"] := flSecs
            txFlight.Text := FlightText(flSecs) " (nouveau)"
            btnFlightDel.Enabled := true
        }
    }

    ; Retire le temps de vol du stuff (pris en compte à l'enregistrement)
    FlightDelClick(*) {
        fl["v"] := "DEL"
        txFlight.Text := "supprimé"
        btnFlightDel.Enabled := false
    }

    SaveClick(*) {
        nCat := CleanField(cbCat.Text)
        nName := CleanField(edName.Value)
        if (nCat = "" || nName = "") {
            MsgBox("La catégorie et le nom sont obligatoires.", "Modifier", 0x40030)
            return
        }
        c1 := SubStr(nCat, 1, 1)
        if (c1 = "[" || c1 = "@") {
            MsgBox("La catégorie ne peut pas commencer par [ ou @.", "Modifier", 0x40030)
            return
        }
        exCat := CatNameTaken(path, nCat)
        if (exCat != "")
            nCat := exCat   ; la catégorie existe déjà (même nom à la casse près) : on utilise celle qui existe
        exDup := (nName = oldName) ? "" : StuffNameTaken(path, nName, oldCat, oldName)   ; le nom n'a pas changé : pas de contrôle (anciens doublons éditables)
        if (exDup != "") {
            MsgBox("Un stuff nommé « " nName " » existe déjà dans cette map (catégorie « " exDup " »).`n`nChoisis un autre nom.", "Modifier", 0x40030)
            return
        }
        nPos := Trim(edPos.Value)
        if (nPos != "") {
            nPos := NormalizePos(nPos)
            if (nPos = "") {
                MsgBox("Position invalide. Format attendu :`nsetpos x y z; setang pitch yaw", "Modifier", 0x40030)
                return
            }
        }
        nOth := Trim(CleanField(edOthers.Value), " `t;")
        nCmd := nPos
        if (nOth != "")
            nCmd := (nCmd != "") ? nCmd "; " nOth : nOth
        if (nCmd = "") {
            MsgBox("Renseigne une position ou au moins une commande.", "Modifier", 0x40030)
            return
        }
        changedId := (nCat !== oldCat || nName !== oldName)
        if (changedId && locks.Has("it|" oldKey)) {
            MsgBox(LOCK_ICON " Stuff verrouillé : son nom et sa catégorie ne peuvent pas changer.", "Modifier", 0x40030)
            return
        }
        ReplaceStuffInFile(path, oldCat, oldName, nCat, nName, nCmd, JoinInfo(CleanInfo(edInfo.Value), TagsToStr(tagSel)))
        ; temps de vol : nouveau temps mesuré, ou temps retiré si la position ou l'angle ont changé
        oldTK := TimeKey(cmd)
        newTK := TimeKey(nCmd)
        if (fl["v"] = "DEL") {
            DelFlightTime(oldTK)
            DelFlightTime(newTK)
        } else if (fl["v"] != "") {
            SetFlightTime(nCmd, fl["v"])
        }
        if (oldTK != "" && oldTK != newTK)
            DelFlightTime(oldTK)
        newShot := ShotPath(keyMap, nCmd)
        if (!shotRedone && shotFile != "" && newShot != "" && newShot != shotFile && FileExist(shotFile))
            try FileMove(shotFile, newShot, 1)
        if changedId {
            Rekey(oldKey, keyMap "|" nCat "|" nName)
            if (nCat !== oldCat)
                EnsureCatDeclared(path, oldCat)
        }
        res["cat"] := nCat
        d.Destroy()
    }

    CancelClick(*) {
        d.Destroy()
    }

    ShotDelClick(*) {
        if (MsgBox("Supprimer la capture de ce stuff ?", "Modifier", 0x24) = "Yes") {
            try FileDelete(curShot)
            btnShotDel.Enabled := false
            picShot.Value := ""
        }
    }

    ; Refait la capture : masque les fenêtres, laisse 3 secondes pour viser, puis capture le centre du jeu
    ShotRedoClick(*) {
        sp := ShotPath(keyMap, edPos.Value)
        if (sp = "") {
            MsgBox("Renseigne d'abord une position valide (setpos x y z; setang pitch yaw).", "Modifier", 0x40030)
            return
        }
        if !ProcessExist("cs2.exe") {
            MsgBox("CS2 n'est pas lancé.", "Modifier", 0x40030)
            return
        }
        ans := MsgBox("Place-toi au point du stuff en jeu et vise le point à capturer.`n`nAprès OK, les fenêtres se masquent et la capture se fait 3 secondes plus tard, au centre du jeu.", "Refaire la capture", 0x41)
        if (ans != "OK")
            return
        d.Hide()
        try WinHide("ahk_id " ownerHwnd)
        try WinActivate("ahk_exe cs2.exe")
        WinWaitActive("ahk_exe cs2.exe", , 2)
        Loop 3 {
            left := 4 - A_Index
            ToolTip("Capture dans " left " s...")
            Sleep(1000)
        }
        ToolTip()
        Sleep(80)
        ok := CaptureShot(sp)
        try WinShow("ahk_id " ownerHwnd)
        d.Show()
        WinActivate("ahk_id " d.Hwnd)
        if ok {
            shotRedone := true
            curShot := sp
            shotOk[sp] := 1
            try picShot.Value := "*w" picSz " *h" picSz " " sp
            btnShotDel.Enabled := true
        } else {
            MsgBox("Capture impossible.", "Modifier", 0x40030)
        }
    }

    btnFlight.OnEvent("Click", FlightClick)
    btnFlightDel.OnEvent("Click", FlightDelClick)
    btnShotNew.OnEvent("Click", ShotRedoClick)
    btnShotDel.OnEvent("Click", ShotDelClick)
    cbCat.OnEvent("Change", CatChange)
    ddType.OnEvent("Change", TypeChange)
    btnRecap.OnEvent("Click", Recap)
    btnSave.OnEvent("Click", SaveClick)
    btnCancel.OnEvent("Click", CancelClick)
    d.OnEvent("Close", CancelClick)
    d.OnEvent("Escape", CancelClick)
    WinStyle(d)
    d.Show("AutoSize Center")
    hwnd := d.Hwnd
    WinWaitClose("ahk_id " hwnd)
    try WinActivate("ahk_id " ownerHwnd)
    return res["cat"]
}

; =====================================================================
;  Coordonnées en temps réel (coin inférieur gauche de l'écran)
; =====================================================================
; Le script demande "getpos" au jeu à intervalle régulier (via le cfg) et lit
; la réponse dans console.log. Aucune lecture de la mémoire du jeu.
BuildHud() {
    global hudGui, hudTxt, hudB
    if IsObject(hudGui)
        hudGui.Destroy()
    if IsObject(hudB) {
        hudB.Destroy()
        hudB := ""
    }
    if (ovBorder > 0) {
        hudB := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
        hudB.BackColor := BorderColor()
    }
    dark := (Lum(ovBg) < 140)
    cTxt := dark ? "FFFFFF" : "111111"
    thh := ThemeById(ovTheme)
    if IsObject(thh)
        cTxt := thh[4]
    fnt := (ovFont = "") ? "Consolas" : ovFont
    hudGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
    hudGui.BackColor := ovBg
    hudGui.MarginX := 10 + ovCorner // 3
    hudGui.MarginY := 6 + ovCorner // 4
    hudGui.SetFont("s" FS(11) " bold c" cTxt, fnt)
    hudTxt := hudGui.Add("Text", "w" Round(330 * ovScale / 100) " r3", hudLast)
}

ShowHud() {
    MonitorGet(MonitorGetPrimary(), &ml, &mt, &mr, &mb)
    hx := ml + 12
    hy := mt + 12
    hudGui.Show("NA AutoSize x" hx " y" hy)
    hudGui.GetPos(, , , &hh)
    hudGui.GetPos(&hx0, &hy0, &hw0, &hh0)
    if HudAuto {
        hudGui.Move(ml + 12 + ovBorder, mb - hh - 12 - ovBorder)
    } else {
        vl := SysGet(76)
        vt := SysGet(77)
        vw := SysGet(78)
        vh := SysGet(79)
        hudGui.Move(Max(vl, Min(HudX, vl + vw - hw0)), Max(vt, Min(HudY, vt + vh - hh)))
    }
    hudGui.GetPos(&px, &py, &pw, &ph)
    dia := 2 * Min(ovCorner, ph // 2)
    if (ovCorner > 0)
        WinSetRegion("0-0 W" pw " H" ph " R" dia "-" dia, hudGui)
    WinSetTransparent(ovOpacity, hudGui)
    if IsObject(hudB) {
        b := ovBorder
        bw := pw + 2 * b
        bh := ph + 2 * b
        hudB.Show("NA x" (px - b) " y" (py - b) " w" bw " h" bh)
        if (ovCorner > 0) {
            bd := dia + 2 * b
            WinSetRegion("0-0 W" bw " H" bh " R" bd "-" bd, hudB)
        }
        WinSetTransparent(ovOpacity, hudB)
        DllCall("SetWindowPos", "Ptr", hudGui.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
    }
}

HudSetText(p) {
    global hudLast
    try {
        mp := (execMap != "" && execMap != "?") ? execMap : LastMap
        hudLast := mp "`n"
            . "X " Format("{:.1f}", Number(p[1])) "   Y " Format("{:.1f}", Number(p[2])) "   Z " Format("{:.1f}", Number(p[3])) "`n"
            . "Pitch " Format("{:.1f}", Number(p[4])) "   Yaw " Format("{:.1f}", Number(p[5]))
        hudTxt.Text := hudLast
    }
}

; Dernière ligne "setpos ...; setang ..." trouvée dans un texte
LastPos(txt) {
    last := ""
    pos := 1
    pat := "i)setpos\s+(" NUM ")\s+(" NUM ")\s+(" NUM ")\s*;\s*setang\s+(" NUM ")\s+(" NUM ")"
    while (pos := RegExMatch(txt, pat, &m, pos)) {
        last := [m[1], m[2], m[3], m[4], m[5]]
        pos += StrLen(m[0])
    }
    return last
}

HudTick() {
    global hudPos
    Critical
    if (!hudOn || cmdBusy > 0)
        return
    if !WinActive("ahk_exe cs2.exe")
        return
    if !FileExist(ConsoleLog)
        return
    ; 1) lire ce que le jeu a écrit depuis le dernier passage
    sz := FileGetSize(ConsoleLog)
    if (sz < hudPos)
        hudPos := 0
    if (sz > hudPos) {
        txt := ReadFrom(ConsoleLog, hudPos)
        hudPos := sz
        lp := LastPos(txt)
        if IsObject(lp)
            HudSetText(lp)
    }
    ; 2) demander la position suivante (pas pendant un menu ou une fenêtre)
    if (menuOpen || dlgOpen || mgrOpen || setOpen)
        return
    ; pause de 2 s après chaque commande du menu (stuff, utilitaire...) pour ne jamais la gêner
    if (A_TickCount - lastCmdTick < 2000)
        return
    HudPing()
}

; Demande la position au jeu (getpos) : la réponse est lue dans console.log
HudPing() {
    NetSend("sv_cheats 1; getpos")
}

; Affiche (true) ou masque (false) les coordonnées
HudSet(on) {
    if (on && !hudOn)
        HudToggle()
    else if (!on && hudOn)
        HudToggle()
}

HudToggle() {
    global hudOn, hudPos, hudLast
    hudOn := !hudOn
    if hudOn {
        hudPos := FileExist(ConsoleLog) ? FileGetSize(ConsoleLog) : 0
        hudLast := FileExist(ConsoleLog) ? "En attente de la position..." : "console.log introuvable (-condebug ?)"
        BuildHud()
        ShowHud()
        SetTimer(HudTick, HudInterval)
    } else {
        SetTimer(HudTick, 0)
        hudGui.Hide()
        if IsObject(hudB)
            hudB.Hide()
    }
}

; =====================================================================
;  Chronomètre de grenade
; =====================================================================
; Mesure le temps entre le lâcher (clic gauche relâché, ou relance sv_throw_...) et l'explosion.
; L'explosion est lue dans console.log : le journal du serveur (log on, mp_logdetail 3) y écrit
; « threw smokegrenade [x y z] » quand la grenade a explosé.
TmClick() {
    global tmClicks
    if !(TimerOn || tmMeasuring || tmTesting)
        return
    tmClicks.Push(A_TickCount)
    TmDbg("clic relâché")
    if (tmClicks.Length > 30)
        tmClicks.RemoveAt(1)
}

; Active ou arrête la lecture du journal selon le réglage
TmApply() {
    global tmRunning, tmPos, tmSentSock, tmLive
    want := (TimerOn || tmMeasuring || tmTesting)
    if (want && !tmRunning) {
        tmRunning := true
        tmSentSock := 0
        tmPos := FileExist(ConsoleLog) ? FileGetSize(ConsoleLog) : 0
        SetTimer(TmTick, 50)
    } else if (!want && tmRunning) {
        tmRunning := false
        tmLive := false
        SetTimer(TmTick, 0)
        SetTimer(TmLiveTick, 0)
        TmHide()
    }
}

TmTick() {
    global tmPos, tmSentSock, tmStarts, tmLastThrow, tmPosWait, tmLineWasK
    if (!(TimerOn || tmMeasuring || tmTesting) || !FileExist(ConsoleLog))
        return
    sz := FileGetSize(ConsoleLog)
    if (sz < tmPos)
        tmPos := 0
    if !WinActive("ahk_exe cs2.exe") {
        tmPos := sz   ; hors du jeu : on ignore ce qui s'écrit, pour ne pas afficher de vieux résultats
        return
    }
    if (netSock != -1 && netSock != tmSentSock) {
        tmSentSock := netSock
        NetSend("log on; mp_logdetail 3")
    }
    if (sz <= tmPos)
        return
    txt := ReadFrom(ConsoleLog, tmPos)
    now := A_TickCount
    ; on ne consomme que les lignes complètes
    nl := InStr(txt, "`n", , -1)
    if (nl = 0) {
        if (StrLen(txt) > 4000)
            tmPos := sz
        return
    }
    tail := SubStr(txt, nl + 1)
    tmPos := sz - (StrPut(tail, "UTF-8") - 1)
    txt := SubStr(txt, 1, nl)
    pos := 1
    while (pos := RegExMatch(txt, "i)sv_throw_(\w+)|threw\s+(smokegrenade|flashbang|hegrenade|molotov|incgrenade|decoy)", &m, pos)) {
        pos += StrLen(m[0])
        if (m[2] = "") {
            st := TmThrowLine(now)
            if !tmLineWasK {
                tmLastThrow := Map("kind", TmName(m[1]), "pos", "", "secs", "")
                tmPosWait := now
                NetSend("sv_cheats 1; getpos")
            }
            TmDbg("ligne sv_throw_" m[1] " -> départ il y a " (now - st) " ms")
            if TimerOn
                TmLiveStart(TmName(m[1]), st)
        } else {
            TmDbg("ligne threw " m[2])
            TmFinish(m[2], now)
        }
    }
    if (tmPosWait != 0) {
        if (now - tmPosWait > 3000) {
            tmPosWait := 0
        } else if IsObject(tmLastThrow) {
            lp := ""
            q := 1
            while (q := RegExMatch(txt, "i)setpos\s+" NUM "\s+" NUM "\s+" NUM "\s*;\s*setang\s+" NUM "\s+" NUM, &pm, q)) {
                lp := NormalizePos(pm[0])
                q += StrLen(pm[0])
            }
            if (lp != "") {
                tmLastThrow["pos"] := lp
                tmPosWait := 0
            }
        }
    }
}

; Une ligne sv_throw_... apparaît : elle confirme la relance (touche K) en attente, sinon c'est un lancer normal
TmThrowLine(now) {
    global tmStarts, tmLineWasK
    tmLineWasK := false
    for e in tmStarts {
        if (!e[2] && now - e[1] < 1500) {
            e[2] := true
            tmLineWasK := true
            return e[1]
        }
    }
    st := now
    i := tmClicks.Length
    if (i >= 1 && now - tmClicks[i] < 1500) {
        st := tmClicks[i]
        tmClicks.RemoveAt(i)
    }
    tmStarts.Push([st, true, (st = now) ? "journal" : "clic"])
    return st
}

TmFinish(kind, now) {
    global tmStarts, tmLive, tmMeasured, tmLastLabel, tmBeeped
    ; on oublie les grenades trop anciennes (jamais explosées ou jamais vues)
    while (tmStarts.Length >= 1 && now - tmStarts[1][1] > 9000)
        tmStarts.RemoveAt(1)
    start := 0
    src := "clic (secours)"
    if (tmStarts.Length >= 1) {
        start := tmStarts[1][1]   ; la plus ancienne en vol explose en premier
        src := tmStarts[1][3]
        tmStarts.RemoveAt(1)
    } else {
        i := tmClicks.Length
        while (i >= 1) {
            if (now - tmClicks[i] < 9000) {
                start := tmClicks[i]
                tmClicks.RemoveAt(i)
                break
            }
            i -= 1
        }
    }
    if (start = 0) {
        TmDbg("explosion sans départ connu : ignorée")
        return
    }
    secs := (now - start) / 1000
    TmDbg("explosion " kind " -> " Round(secs, 2) " s")
    if (secs < 0.2)
        return
    if (IsObject(tmLastThrow) && tmLastThrow["kind"] = TmName(kind))
        tmLastThrow["secs"] := Round(secs, 2)
    tmLastLabel := TmName(kind)
    tmLive := false
    SetTimer(TmLiveTick, 0)
    if tmMeasuring
        tmMeasured := secs
    if (TimerOn || tmTesting)
        TmShow(TmName(kind) " : " StrReplace(Format("{:.1f}", secs), ".", ",") " s")
    if (tmTesting && IsObject(tmTestCb))
        tmTestCb.Call(TmName(kind) " : " StrReplace(Format("{:.2f}", secs), ".", ",") " s (départ : " src ")")
}

TmDbg(msg) {
    if !TimerDebug
        return
    try {
        if (FileExist(TmDbgFile) && FileGetSize(TmDbgFile) > 200000)
            FileDelete(TmDbgFile)
        FileAppend(A_Hour ":" A_Min ":" A_Sec "." A_MSec " " msg "`n", TmDbgFile, "UTF-8")
    }
}

; Nom affiché d'une grenade d'après son nom dans le journal (reconnaissance souple : « flash », « flashbang »...)
TmName(kind) {
    k := StrLower(kind)
    if InStr(k, "smoke")
        return "Smoke"
    if InStr(k, "flash")
        return "Flash"
    if InStr(k, "molotov")
        return "Molotov"
    if InStr(k, "inc")
        return "Incendiaire"
    if InStr(k, "decoy")
        return "Leurre"
    if (InStr(k, "he") = 1)
        return "HE"
    return "Grenade"
}

; Relance avec la touche de sv_rethrow_last_grenade : le chrono part tout de suite (la ligne du journal n'est pas toujours écrite)
TmRethrow() {
    global tmStarts, tmLastK
    if !(TimerOn || tmMeasuring || tmTesting)
        return
    if (!tmTesting && (menuOpen || dlgOpen || mgrOpen || setOpen))
        return
    now := A_TickCount
    if (now - tmLastK < 250)   ; répétition automatique de la touche maintenue
        return
    tmLastK := now
    tmStarts.Push([now, false, "touche relance"])
    if (tmStarts.Length > 20)
        tmStarts.RemoveAt(1)
    TmDbg("touche relance")
    if (TimerOn && tmLastLabel != "")
        TmLiveStart(tmLastLabel, now)
}

; Chrono en direct : démarre à la relance d'une grenade (type connu) et s'arrête à l'explosion
TmLiveStart(label, now) {
    global tmLive, tmLiveLabel, tmLiveT0, tmExpect, tmBeeped, tmLastLabel
    tmLive := true
    tmLiveLabel := label
    tmLastLabel := label
    tmLiveT0 := now
    tmBeeped := false
    tmExpect := ""
    if (recents.Length > 0) {
        ft := FlightTime(recents[1][2])
        if (ft != "")
            tmExpect := Number(ft)
    }
    TmShow(label " : 0,0 s", true)
    SetTimer(TmLiveTick, 100)
}

TmLiveTick() {
    global tmLive, tmBeeped
    if !tmLive {
        SetTimer(TmLiveTick, 0)
        return
    }
    el := A_TickCount - tmLiveT0
    if (el > ((tmExpect != "") ? tmExpect * 1000 + 3000 : 15000)) {
        tmLive := false
        SetTimer(TmLiveTick, 0)
        TmHide()
        return
    }
    try tmCtl.Text := tmLiveLabel " : " StrReplace(Format("{:.1f}", el / 1000), ".", ",") " s"
}

TmHide() {
    global tmVisible
    SetTimer(TmHide, 0)
    tmVisible := false
    try tmGui.Hide()
    try tmB.Hide()
}

; Affiche le texte avec le même style que les coordonnées (police, couleurs, liseré, coins, opacité)
TmShow(txt, hold := false) {
    global tmGui, tmB, tmText, tmVisible, tmCtl
    tmText := txt
    if IsObject(tmGui)
        try tmGui.Destroy()
    if IsObject(tmB) {
        try tmB.Destroy()
        tmB := ""
    }
    if (ovBorder > 0) {
        tmB := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
        tmB.BackColor := BorderColor()
    }
    dark := (Lum(ovBg) < 140)
    cTxt := dark ? "FFFFFF" : "111111"
    thh := ThemeById(ovTheme)
    if IsObject(thh)
        cTxt := thh[4]
    fnt := (ovFont = "") ? "Consolas" : ovFont
    tmGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
    tmGui.BackColor := ovBg
    tmGui.MarginX := 12 + ovCorner // 3
    tmGui.MarginY := 6 + ovCorner // 4
    tmGui.SetFont("s" FS(16) " bold c" cTxt, fnt)
    tmCtl := tmGui.Add("Text", "Center", "Incendiaire : 99,9 s")   ; largeur fixe pour tous les textes
    tmCtl.Text := txt
    tmGui.Show("NA AutoSize x0 y0")
    tmGui.GetPos(, , &w, &h)
    vl := SysGet(76)
    vt := SysGet(77)
    vw := SysGet(78)
    vh := SysGet(79)
    if TimerAuto {
        ; juste au-dessus des coordonnées
        MonitorGet(MonitorGetPrimary(), &ml, &mt, &mr, &mb)
        if (hudOn && IsObject(hudGui)) {
            hudGui.GetPos(&cx, &cy)
        } else if HudAuto {
            estH := Round(5.2 * FS(11)) + 2 * (6 + ovCorner // 4)
            cx := ml + 12 + ovBorder
            cy := mb - estH - 12 - ovBorder
        } else {
            cx := HudX
            cy := HudY
        }
        x := cx
        y := cy - 2 * ovBorder - 8 - h
    } else {
        x := TimerX
        y := TimerY
    }
    x := Max(vl, Min(x, vl + vw - w))
    y := Max(vt, Min(y, vt + vh - h))
    tmGui.Move(x, y)
    tmGui.GetPos(&px, &py, &pw, &ph)
    dia := 2 * Min(ovCorner, ph // 2)
    if (ovCorner > 0)
        WinSetRegion("0-0 W" pw " H" ph " R" dia "-" dia, tmGui)
    WinSetTransparent(ovOpacity, tmGui)
    if IsObject(tmB) {
        b := ovBorder
        bw := pw + 2 * b
        bh := ph + 2 * b
        tmB.Show("NA x" (px - b) " y" (py - b) " w" bw " h" bh)
        if (ovCorner > 0) {
            bd := dia + 2 * b
            WinSetRegion("0-0 W" bw " H" bh " R" bd "-" bd, tmB)
        }
        WinSetTransparent(ovOpacity, tmB)
        DllCall("SetWindowPos", "Ptr", tmGui.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
    }
    tmVisible := true
    if hold
        SetTimer(TmHide, 0)
    else
        SetTimer(TmHide, -TimerDur * 1000)
}

; =====================================================================
;  Profils et partage de stuffs (fichier .stuffpack ou code à coller)
; =====================================================================
; Un profil = un jeu complet de maps + favoris/cadenas. Le profil "Principal"
; utilise les dossiers maps\ et data\ ; les autres vivent dans profiles\<nom>\.
ProfDir(name) {
    return (name = DEFAULT_PROFILE) ? A_ScriptDir : A_ScriptDir "\profiles\" name
}

ProfMaps(name) {
    return ProfDir(name) "\maps"
}

ProfData(name) {
    return ProfDir(name) "\data"
}

ListProfiles() {
    arr := [DEFAULT_PROFILE]
    Loop Files A_ScriptDir "\profiles\*", "D" {
        if (A_LoopFileName != DEFAULT_PROFILE)
            arr.Push(A_LoopFileName)
    }
    return arr
}

CleanProfileName(s) {
    s := RegExReplace(s, "[\\/:*?`"<>|`r`n`t]+", "")
    return Trim(s, " .")
}

ProfileExists(name) {
    for pn in ListProfiles() {
        if (pn = name)
            return true
    }
    return false
}

; Crée un profil vide : mêmes maps (fichiers vides) et mêmes commandes communes que le profil actif
CreateProfile(name) {
    mdir := ProfMaps(name)
    DirCreate(mdir)
    DirCreate(ProfData(name))
    if (FileExist(MapsDir "\_commun.txt") && !FileExist(mdir "\_commun.txt"))
        FileCopy(MapsDir "\_commun.txt", mdir "\_commun.txt")
    Loop Files MapsDir "\*.txt" {
        if (SubStr(A_LoopFileName, 1, 1) = "_")
            continue
        if !FileExist(mdir "\" A_LoopFileName)
            FileAppend("# " RegExReplace(A_LoopFileName, "\.txt$") "`n", mdir "\" A_LoopFileName, "UTF-8-RAW")
    }
}

SwitchProfile(name) {
    IniWrite(name, IniFile, "State", "Profile")
    IniWrite(1, IniFile, "State", "SkipCheck")   ; pas de vérification de l'installation après ce rechargement
    Reload()
}

; Décale la hauteur (Z) de chaque setpos d'une commande
ShiftZ(cmd, delta) {
    if (delta = 0)
        return cmd
    pat := "i)(setpos\s+" NUM "\s+" NUM "\s+)(" NUM ")"
    pos := 1
    while (pos := RegExMatch(cmd, pat, &m, pos)) {
        rep := m[1] Round(Number(m[2]) + delta, 2)
        cmd := SubStr(cmd, 1, pos - 1) rep SubStr(cmd, pos + StrLen(m[0]))
        pos += StrLen(rep)
    }
    return cmd
}

; Commandes jamais importées : elles pourraient quitter le jeu, changer tes touches ou exécuter d'autres fichiers
BlockedCmd(cmd) {
    bad := "|quit|exit|disconnect|connect|exec|bind|unbind|unbindall|alias|rcon|rcon_password|host_writeconfig|writeid|writeip|"
    for part in StrSplit(cmd, ";") {
        w := StrSplit(Trim(part), [" ", "`t"])[1]
        w := StrLower(LTrim(w, "+-"))
        if (w != "" && InStr(bad, "|" w "|"))
            return w
    }
    return ""
}

; list = tableau de [map, catégorie, nom, commande, info]
; Convertit une image (GDI+) : fmt = "jpeg" ou "bmp"
ConvertImage(src, dest, fmt) {
    DllCall("LoadLibrary", "Str", "gdiplus")
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    token := 0
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", si, "Ptr", 0)
    img := 0
    ok := false
    if (DllCall("gdiplus\GdipLoadImageFromFile", "WStr", src, "Ptr*", &img) = 0 && img) {
        clsid := Buffer(16, 0)
        id := (fmt = "jpeg") ? "{557CF401-1A04-11D3-9A73-0000F81EF32E}" : "{557CF400-1A04-11D3-9A73-0000F81EF32E}"
        DllCall("ole32\CLSIDFromString", "WStr", id, "Ptr", clsid)
        ok := (DllCall("gdiplus\GdipSaveImageToFile", "Ptr", img, "WStr", dest, "Ptr", clsid, "Ptr", 0) = 0)
        DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
    }
    DllCall("gdiplus\GdiplusShutdown", "Ptr", token)
    return (ok && FileExist(dest))
}

; Charge une image (tout format lisible par GDI+) et renvoie un HBITMAP (ou 0)
LoadHBitmapGdip(path) {
    DllCall("LoadLibrary", "Str", "gdiplus")
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    token := 0
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", si, "Ptr", 0)
    img := 0
    hbm := 0
    if (DllCall("gdiplus\GdipCreateBitmapFromFile", "WStr", path, "Ptr*", &img) = 0 && img) {
        DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", img, "Ptr*", &hbm, "UInt", 0xFF000000)
        DllCall("gdiplus\GdipDisposeImage", "Ptr", img)
    }
    DllCall("gdiplus\GdiplusShutdown", "Ptr", token)
    return hbm
}

; Écrit un HBITMAP en .bmp 24 bits classique (lisible partout, y compris par les contrôles Picture)
SaveHBitmapBmp24(hbm, dest) {
    bm := Buffer(32, 0)
    DllCall("GetObject", "Ptr", hbm, "Int", 32, "Ptr", bm)
    w := NumGet(bm, 4, "Int")
    h := NumGet(bm, 8, "Int")
    if (w < 1 || h < 1)
        return false
    stride := ((w * 3 + 3) // 4) * 4
    imgSize := stride * h
    bi := Buffer(40, 0)
    NumPut("UInt", 40, bi, 0)
    NumPut("Int", w, bi, 4)
    NumPut("Int", h, bi, 8)
    NumPut("UShort", 1, bi, 12)
    NumPut("UShort", 24, bi, 14)
    NumPut("UInt", imgSize, bi, 20)
    hdcScr := DllCall("GetDC", "Ptr", 0, "Ptr")
    hdcSrc := DllCall("CreateCompatibleDC", "Ptr", hdcScr, "Ptr")
    hdcDst := DllCall("CreateCompatibleDC", "Ptr", hdcScr, "Ptr")
    bits := 0
    dib := DllCall("CreateDIBSection", "Ptr", hdcScr, "Ptr", bi, "UInt", 0, "Ptr*", &bits, "Ptr", 0, "UInt", 0, "Ptr")
    ok := false
    if (dib && bits) {
        old1 := DllCall("SelectObject", "Ptr", hdcSrc, "Ptr", hbm, "Ptr")
        old2 := DllCall("SelectObject", "Ptr", hdcDst, "Ptr", dib, "Ptr")
        DllCall("BitBlt", "Ptr", hdcDst, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", hdcSrc, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
        try {
            hdr := Buffer(54, 0)
            NumPut("UShort", 0x4D42, hdr, 0)
            NumPut("UInt", 54 + imgSize, hdr, 2)
            NumPut("UInt", 54, hdr, 10)
            Loop 40
                NumPut("UChar", NumGet(bi, A_Index - 1, "UChar"), hdr, 14 + A_Index - 1)
            f := FileOpen(dest, "w")
            f.RawWrite(hdr, 54)
            f.RawWrite(bits, imgSize)
            f.Close()
            ok := true
        }
        DllCall("SelectObject", "Ptr", hdcSrc, "Ptr", old1)
        DllCall("SelectObject", "Ptr", hdcDst, "Ptr", old2)
        DllCall("DeleteObject", "Ptr", dib)
    }
    DllCall("DeleteDC", "Ptr", hdcSrc)
    DllCall("DeleteDC", "Ptr", hdcDst)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdcScr)
    return ok
}

; Convertit n'importe quelle image en .bmp 24 bits
ImageToBmp24(src, dest) {
    hbm := LoadHBitmapGdip(src)
    if !hbm
        return false
    ok := SaveHBitmapBmp24(hbm, dest)
    DllCall("DeleteObject", "Ptr", hbm)
    return (ok && FileExist(dest)) ? true : false
}

; Vérifie qu'une capture est lisible ; sinon tente de la réparer (ancien format) ou renvoie false
ShotValid(path) {
    if (path = "" || !FileExist(path))
        return false
    if shotOk.Has(path)
        return true
    good := false
    try {
        h := LoadPicture(path)
        if h {
            DllCall("DeleteObject", "Ptr", h)
            good := true
        }
    }
    if !good {
        tmp := path ".fix"
        try FileDelete(tmp)
        if ImageToBmp24(path, tmp) {
            try {
                FileMove(tmp, path, 1)
                good := true
            }
        }
        try FileDelete(tmp)
    }
    if good
        shotOk[path] := 1
    return good
}

; Fichier -> texte base64 (une seule ligne)
FileToB64(path) {
    try data := FileRead(path, "RAW")
    catch
        return ""
    if (data.Size = 0)
        return ""
    n := 0
    DllCall("crypt32\CryptBinaryToStringA", "Ptr", data, "UInt", data.Size, "UInt", 0x40000001, "Ptr", 0, "UInt*", &n)
    buf := Buffer(n + 1, 0)
    DllCall("crypt32\CryptBinaryToStringA", "Ptr", data, "UInt", data.Size, "UInt", 0x40000001, "Ptr", buf, "UInt*", &n)
    return StrGet(buf, "CP0")
}

; Texte base64 -> fichier
B64ToFile(b64, path) {
    n := 0
    if !DllCall("crypt32\CryptStringToBinaryA", "AStr", b64, "UInt", 0, "UInt", 1, "Ptr", 0, "UInt*", &n, "Ptr", 0, "Ptr", 0)
        return false
    buf := Buffer(n, 0)
    if !DllCall("crypt32\CryptStringToBinaryA", "AStr", b64, "UInt", 0, "UInt", 1, "Ptr", buf, "UInt*", &n, "Ptr", 0, "Ptr", 0)
        return false
    try FileDelete(path)
    try {
        f := FileOpen(path, "w")
        f.RawWrite(buf, n)
        f.Close()
    } catch
        return false
    return FileExist(path) ? true : false
}

; Compte les stuffs de la liste qui ont une capture
CountShots(list) {
    n := 0
    for e in list {
        sp := ShotPath(e[1], e[4])
        if (sp != "" && FileExist(sp))
            n += 1
    }
    return n
}

; withImgs : ajoute une ligne @IMG par capture (JPEG en base64). Les anciennes versions ignorent ces lignes.
BuildPack(list, withImgs := false) {
    out := "CS2STUFFPACK;1;" TpZOffset ";" CleanField(curProfile) "`n"
    for e in list
        out .= e[1] " | " e[2] " | " e[3] " | " e[4] " | " e[5] "`n"
    for e in list {
        ft := FlightTime(e[4])
        if (ft != "")
            out .= "@TIME | " e[1] " | " e[2] " | " e[3] " | " ft "`n"
    }
    if withImgs {
        tmp := A_Temp "\stuffshot_export.jpg"
        for e in list {
            sp := ShotPath(e[1], e[4])
            if (sp = "" || !FileExist(sp))
                continue
            try FileDelete(tmp)
            if !ConvertImage(sp, tmp, "jpeg")
                continue
            b := FileToB64(tmp)
            if (b != "")
                out .= "@IMG | " e[1] " | " e[2] " | " e[3] " | " b "`n"
        }
        try FileDelete(tmp)
    }
    return out
}

; Renvoie Map("z", réglage de l'exportateur, "from", profil, "ents", liste) ou "" si invalide
ParsePack(txt) {
    lines := []
    for ln in StrSplit(txt, "`n", "`r") {
        ln := Trim(ln)
        if (ln = "" || SubStr(ln, 1, 3) = "``````")
            continue
        lines.Push(ln)
    }
    hi := 0
    for i, ln in lines {
        if (SubStr(ln, 1, 13) = "CS2STUFFPACK;") {
            hi := i
            break
        }
    }
    if !hi
        return ""
    h := StrSplit(lines[hi], ";", , 4)
    zoff := (h.Length >= 3 && IsNumber(h[3])) ? Number(h[3]) : TpZOffset
    from := (h.Length >= 4) ? h[4] : ""
    ents := []
    imgs := Map()
    tms := Map()
    Loop lines.Length - hi {
        p := StrSplit(lines[hi + A_Index], "|", " `t", 5)
        if (p[1] = "@TIME") {
            if (p.Length >= 5 && IsNumber(p[5]) && Number(p[5]) >= 0.1 && Number(p[5]) <= 60)
                tms[CleanField(p[2]) "|" CleanField(p[3]) "|" CleanField(p[4])] := Number(p[5])
            continue
        }
        if (p[1] = "@IMG") {
            if (p.Length >= 5 && p[5] != "")
                imgs[CleanField(p[2]) "|" CleanField(p[3]) "|" CleanField(p[4])] := p[5]
            continue
        }
        if (p.Length < 4)
            continue
        if !RegExMatch(p[1], "^[A-Za-z0-9_\-]+$")
            continue
        cat := CleanField(p[2])
        nm := CleanField(p[3])
        c1 := SubStr(cat, 1, 1)
        if (cat = "" || nm = "" || c1 = "[" || c1 = "@" || p[4] = "")
            continue
        raw5 := (p.Length >= 5) ? p[5] : ""
        if InStr(raw5, "|") {
            sp5 := SplitInfo(raw5)
            raw5 := JoinInfo(sp5[1], TagsToStr(TagList(sp5[2])))
        }
        ents.Push([p[1], cat, nm, p[4], raw5])
    }
    return Map("z", zoff, "from", from, "ents", ents, "imgs", imgs, "tms", tms)
}

; Statut d'un stuff reçu par rapport au profil de destination
ImportStatus(e, prof, zdelta, cache) {
    b := BlockedCmd(e[4])
    if (b != "")
        return "Refusé (" b ")"
    path := ProfMaps(prof) "\" e[1] ".txt"
    if !FileExist(path)
        return "Nouveau"
    if !cache.Has(path)
        cache[path] := ReadEntries(path)[2]
    for x in cache[path] {
        if (x[2] = e[3]) {   ; même nom (dans n'importe quelle catégorie de la map)
            if (x[1] = e[2] && x[3] = ShiftZ(e[4], zdelta) && x[4] = e[5])
                return "Identique"
            return "Doublon"
        }
    }
    return "Nouveau"
}

; Stuff déjà présent (même map, catégorie, nom) dans le profil, ou "" s'il n'existe pas
FindExisting(e, prof) {
    path := ProfMaps(prof) "\" e[1] ".txt"
    if !FileExist(path)
        return ""
    for x in ReadEntries(path)[2] {
        if (x[1] = e[2] && StrLower(x[2]) = StrLower(e[3]))
            return x
    }
    return ""
}

; Texte lisible des commandes (une commande par ligne)
PrettyCmd(c) {
    t := StrReplace(c, ";", "`r`n")
    return Trim(t, " `r`n`t")
}

; Enregistre la capture reçue d'un stuff importé (sans écraser la tienne sauf remplacement)
; Enregistre le temps de vol importé dans le profil de destination (sans écraser un temps déjà mesuré, sauf si overwrite)
SaveImportedTime(tms, e, cmd, prof, overwrite, stats) {
    if !IsObject(tms)
        return
    key := e[1] "|" e[2] "|" e[3]
    if !tms.Has(key)
        return
    tk := TimeKey(cmd)
    if (tk = "")
        return
    secs := Format("{:.2f}", tms[key])
    if (ProfData(prof) = DataDir) {
        if (times.Has(tk) && !overwrite)
            return
        times[tk] := secs
        SaveTimes()
        stats["time"] += 1
        return
    }
    f := ProfData(prof) "\times.txt"
    lines := []
    found := false
    if FileExist(f) {
        for ln in StrSplit(FileRead(f, "UTF-8"), "`n", "`r") {
            if (ln = "")
                continue
            if (StrSplit(ln, "`t")[1] = tk) {
                found := true
                if !overwrite {
                    lines.Push(ln)
                    continue
                }
                ln := tk "`t" secs
            }
            lines.Push(ln)
        }
    }
    if !found
        lines.Push(tk "`t" secs)
    txt := ""
    for ln in lines
        txt .= ln "`n"
    try {
        DirCreate(ProfData(prof))
        try FileDelete(f)
        FileAppend(txt, f, "UTF-8-RAW")
        if (!found || overwrite)
            stats["time"] += 1
    }
}

SaveImportedShot(imgs, e, cmd, prof, overwrite, tmpImg, stats) {
    if !IsObject(imgs)
        return
    key := e[1] "|" e[2] "|" e[3]
    if !imgs.Has(key)
        return
    dest := ShotPath(e[1], cmd, prof)
    if (dest = "" || (FileExist(dest) && !overwrite))
        return
    if !B64ToFile(imgs[key], tmpImg)
        return
    DirCreate(ShotDir(prof))
    if ImageToBmp24(tmpImg, dest) {
        shotOk[dest] := 1
        stats["img"] += 1
    }
}

; policy : 1 = ignorer les doublons, 2 = garder les deux, 3 = remplacer
ApplyImport(rows, prof, zdelta, policy, imgs := "", tms := "") {
    stats := Map("add", 0, "rep", 0, "skip", 0, "img", 0, "time", 0)
    tmpImg := A_Temp "\stuffshot_import.jpg"
    mdir := ProfMaps(prof)
    DirCreate(mdir)
    DirCreate(ProfData(prof) "\backup")
    saved := Map()
    for e in rows {
        path := mdir "\" e[1] ".txt"
        if !FileExist(path)
            FileAppend("# " e[1] "`n", path, "UTF-8-RAW")
        else if !saved.Has(path) {
            FileCopy(path, ProfData(prof) "\backup\" e[1] ".txt.import.bak", 1)
            saved[path] := 1
        }
        cmd := ShiftZ(e[4], zdelta)
        nm := e[3]
        dup := false
        taken := Map()
        for x in ReadEntries(path)[2]
            taken[StrLower(x[2])] := x   ; les noms sont uniques dans toute la map
        if taken.Has(StrLower(nm)) {
            old := taken[StrLower(nm)]
            sameCat := (old[1] = e[2])
            if (sameCat && old[3] = cmd && old[4] = e[5]) {
                stats["skip"] += 1
                SaveImportedTime(tms, e, cmd, prof, false, stats)
                continue
            }
            if (policy = 1) {
                stats["skip"] += 1
                continue
            }
            if (policy = 3 && sameCat) {
                ReplaceStuffInFile(path, old[1], old[2], e[2], nm, cmd, e[5])
                stats["rep"] += 1
                SaveImportedShot(imgs, e, cmd, prof, true, tmpImg, stats)
                SaveImportedTime(tms, e, cmd, prof, true, stats)
                continue
            }
            n := 2
            while taken.Has(StrLower(nm " (" n ")"))
                n += 1
            nm := nm " (" n ")"
        }
        AppendLine(path, BuildLine(e[2], nm, cmd, e[5]))
        stats["add"] += 1
        SaveImportedShot(imgs, e, cmd, prof, false, tmpImg, stats)
        SaveImportedTime(tms, e, cmd, prof, false, stats)
    }
    try FileDelete(tmpImg)
    return stats
}

; Fenêtre d'import : l'utilisateur choisit quoi garder et où le ranger
ShowImport(txt, ownerHwnd) {
    pack := ParsePack(txt)
    if !IsObject(pack) {
        MsgBox("Aucun pack de stuffs valide trouvé.`nColle le code complet (ligne CS2STUFFPACK incluse) ou choisis un fichier .stuffpack.", "Importer", 0x40030)
        return false
    }
    ents := pack["ents"]
    if (ents.Length = 0) {
        MsgBox("Ce pack ne contient aucun stuff.", "Importer", 0x40030)
        return false
    }
    zdelta := pack["z"] - TpZOffset
    imgs := pack["imgs"]
    tms := pack["tms"]
    res := Map("done", false)
    d := WinNew("Importer des stuffs", "+AlwaysOnTop +OwnDialogs")
    src := (pack["from"] != "") ? " (profil « " pack["from"] " »)" : ""
    d.Add("Text", "x12 y12 w720", ents.Length " stuff(s) reçu(s)" src ". Coche ceux à importer.")
    d.Add("Text", "x12 y46 w150", "Profil de destination")
    cbTarget := d.Add("ComboBox", "x170 y42 w300", ListProfiles())
    d.Add("Text", "x12 y82 w150", "Si le stuff existe déjà")
    ddPolicy := d.Add("DropDownList", "x170 y78 w300 Choose1", ["Ignorer (ne rien changer)", "Garder les deux (renommer le nouveau)", "Remplacer le mien"])
    chkTimes := d.Add("CheckBox", "x490 y80 w240" (tms.Count > 0 ? " Checked" : ""), "Importer les temps de vol")
    chkTimes.Enabled := (tms.Count > 0)
    lv := d.Add("ListView", "x12 y116 w720 r13 Checked NoSort", ["Map", "Catégorie", "Nom", "Statut"])
    lv.ModifyCol(1, 110)
    lv.ModifyCol(2, 190)
    lv.ModifyCol(3, 250)
    lv.ModifyCol(4, 140)
    sumT := d.Add("Text", "x12 y+6 w720", "")
    imgNote := (imgs.Count > 0) ? "Ce pack contient " imgs.Count " capture(s) d'écran, importée(s) avec les stuffs." : "Ce pack ne contient pas de captures d'écran."
    if (tms.Count > 0)
        imgNote .= " Il contient aussi " tms.Count " temps de vol."
    d.Add("Text", "x12 y+4 w720", "Aperçu du stuff sélectionné (clique sur une ligne). " imgNote)
    picPrev := d.Add("Picture", "x582 y+2 w130 h130", "")
    picPrev.Visible := false
    edPrev := d.Add("Edit", "x12 yp w560 r7 ReadOnly -Wrap +HScroll", "")
    d.SetFont("s9 c8A8F96")
    note := "Pour un nouveau profil, écris simplement son nom dans la case. Tes autres stuffs ne sont jamais supprimés, et une copie de sécurité est faite avant l'import."
    if (zdelta != 0)
        note .= "`nHauteur : les coordonnées sont ajustées de " zdelta " pour correspondre à ton réglage TpZOffset."
    d.Add("Text", "x12 y+8 w720 r3", note)
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    btnAll := d.Add("Button", "x12 y+10 w140", "Tout cocher")
    btnNone := d.Add("Button", "x+10 yp w140", "Tout décocher")
    btnNo := d.Add("Button", "x382 yp w140", "Annuler")
    btnOk := d.Add("Button", "x532 yp w200 Default", "Importer la sélection")
    cbTarget.Text := curProfile

    Refill(*) {
        tgt := CleanProfileName(cbTarget.Text)
        if (tgt = "")
            tgt := curProfile
        cache := Map()
        lv.Delete()
        for e in ents {
            stt := ImportStatus(e, tgt, zdelta, cache)
            opt := (stt = "Nouveau" || stt = "Doublon") ? "Check" : ""
            lv.Add(opt, e[1], e[2], e[3], stt)
        }
        UpdateSummary()
        edPrev.Value := "Clique sur un stuff de la liste pour voir ses commandes avant de l'importer."
    }

    UpdateSummary(*) {
        nNew := 0
        nDup := 0
        nSame := 0
        nBad := 0
        Loop lv.GetCount() {
            st := lv.GetText(A_Index, 4)
            if (st = "Nouveau")
                nNew += 1
            else if (st = "Doublon")
                nDup += 1
            else if (st = "Identique")
                nSame += 1
            else
                nBad += 1
        }
        nChk := 0
        r := 0
        while (r := lv.GetNext(r, "Checked"))
            nChk += 1
        sumT.Text := nNew " nouveau(x), " nDup " doublon(s), " nSame " identique(s), " nBad " refusé(s)  -  " nChk " coché(s) sur " lv.GetCount()
    }

    ShowPrev(ctrl, item, sel := 1) {
        if (!sel || item < 1 || item > ents.Length)
            return
        e := ents[item]
        tgt := CleanProfileName(cbTarget.Text)
        if (tgt = "")
            tgt := curProfile
        cmdNew := ShiftZ(e[4], zdelta)
        t := e[1] "  >  " e[2] "  >  " e[3] "`r`n"
        if (e[5] != "")
            t .= "Info : " InfoDisp(e[5]) "`r`n"
        b := BlockedCmd(e[4])
        if (b != "")
            t .= "REFUSÉ : commande dangereuse (" b ")`r`n"
        adj := (zdelta != 0) ? " (hauteur ajustée)" : ""
        t .= "`r`nCommandes reçues" adj " :`r`n" PrettyCmd(cmdNew)
        old := FindExisting(e, tgt)
        if IsObject(old) {
            t .= "`r`n`r`nTon stuff actuel du même nom :`r`n" PrettyCmd(old[3])
            if (old[4] != "")
                t .= "`r`nInfo : " InfoDisp(old[4])
        }
        edPrev.Value := t
        ik := e[1] "|" e[2] "|" e[3]
        tmpP := A_Temp "\stuffshot_preview.jpg"
        if (imgs.Has(ik) && B64ToFile(imgs[ik], tmpP)) {
            try {
                picPrev.Value := "*w130 *h130 " tmpP
                picPrev.Visible := true
            } catch {
                picPrev.Visible := false
            }
        } else {
            picPrev.Visible := false
        }
    }

    CheckAll(on, *) {
        Loop lv.GetCount()
            lv.Modify(A_Index, on ? "Check" : "-Check")
        UpdateSummary()
    }

    DoImport(*) {
        tgt := CleanProfileName(cbTarget.Text)
        if (tgt = "") {
            MsgBox("Choisis ou écris un nom de profil.", "Importer", 0x40030)
            return
        }
        picked := []
        r := 0
        while (r := lv.GetNext(r, "Checked")) {
            if (BlockedCmd(ents[r][4]) != "")
                continue
            picked.Push(ents[r])
        }
        if (picked.Length = 0) {
            MsgBox("Aucun stuff coché (les stuffs refusés ne peuvent pas être importés).", "Importer", 0x40030)
            return
        }
        isNew := !ProfileExists(tgt)
        if isNew
            CreateProfile(tgt)
        st := ApplyImport(picked, tgt, zdelta, ddPolicy.Value, imgs, chkTimes.Value ? tms : "")
        res["done"] := true
        res["target"] := tgt
        res["msg"] := st["add"] " ajouté(s), " st["rep"] " remplacé(s), " st["skip"] " ignoré(s)."
        if (imgs.Count > 0)
            res["msg"] .= "`n" st["img"] " capture(s) d'écran importée(s)."
        if (tms.Count > 0 && chkTimes.Value)
            res["msg"] .= "`n" st["time"] " temps de vol importé(s)."
        d.Destroy()
    }

    Cancel(*) {
        d.Destroy()
    }

    cbTarget.OnEvent("Change", Refill)
    lv.OnEvent("ItemSelect", ShowPrev)
    lv.OnEvent("ItemCheck", (*) => SetTimer(UpdateSummary, -30))
    ddPolicy.OnEvent("Change", (*) => 0)
    btnOk.OnEvent("Click", DoImport)
    btnAll.OnEvent("Click", CheckAll.Bind(true))
    btnNone.OnEvent("Click", CheckAll.Bind(false))
    btnNo.OnEvent("Click", Cancel)
    d.OnEvent("Close", Cancel)
    d.OnEvent("Escape", Cancel)
    Refill()
    WinStyle(d)
    d.Show("AutoSize Center")
    hwnd := d.Hwnd
    WinWaitClose("ahk_id " hwnd)
    try WinActivate("ahk_id " ownerHwnd)
    if res["done"] {
        msg := res["msg"]
        if (res["target"] != curProfile) {
            ans := MsgBox(msg "`n`nActiver le profil « " res["target"] " » maintenant ?`n(le script va se recharger)", "Import terminé", 0x24)
            if (ans = "Yes")
                SwitchProfile(res["target"])
        } else {
            MsgBox(msg, "Import terminé", 0x40040)
        }
    }
    return res["done"]
}

ShowShare() {
    global mgrOpen
    if mgrOpen
        return
    if menuOpen
        CloseMenu()
    LoadMaps()
    mgrOpen := true
    rows := []

    d := WinNew("Profils et partage de stuffs", "+AlwaysOnTop +OwnDialogs")
    d.Add("Text", "x12 y14 w130", "Profil actif :")
    d.SetFont("s" WinSz() " bold")
    d.Add("Text", "x130 y14 w300", curProfile)
    d.SetFont("s" WinSz() " norm")
    tabs := WinTabs(d, ["Profils", "Partager des stuffs", "Sauvegardes"], 6, 48, 762)

    ; ----- Onglet Profils -----
    tabs.UseTab(1)
    d.Add("Text", "x22 y88 w100", "Profil")
    ddProf := d.Add("DropDownList", "x130 y84 w250", ListProfiles())
    btnAct := d.Add("Button", "x+8 yp-1 w100", "Activer")
    btnNew := d.Add("Button", "x+8 yp w100", "Nouveau…")
    btnDelP := d.Add("Button", "x+8 yp w100", "Supprimer")
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "x22 y130 w724 r2", "Un profil est un jeu complet de maps, favoris, cadenas, temps de vol et captures. Le profil Principal est celui de base. « Activer » recharge le menu avec le profil choisi.")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    d.Add("Text", "x22 y190 w724", "Changer de PC ou sauvegarder un profil entier :")
    btnPExp := d.Add("Button", "x22 y216 w240", "Exporter le profil (.zip)…")
    btnPImp := d.Add("Button", "x+8 yp w240", "Importer un profil (.zip)…")
    yEnd1 := 280

    ; ----- Onglet Partager -----
    tabs.UseTab(2)
    d.Add("Text", "x22 y88 w724", "Exporter : coche les stuffs du profil actif à partager (un seul, plusieurs, ou tout).")
    lvEx := d.Add("ListView", "x22 y114 w724 r11 Checked NoSort", ["Map", "Catégorie", "Nom", "Info"])
    lvEx.ModifyCol(1, 110)
    lvEx.ModifyCol(2, 180)
    lvEx.ModifyCol(3, 220)
    lvEx.ModifyCol(4, 190)
    lvEx.GetPos(&lx, &ly, &lw, &lh)
    r1 := ly + lh + 8
    btnAll := d.Add("Button", "x22 y" r1 " w120", "Tout cocher")
    btnNone := d.Add("Button", "x+8 yp w120", "Tout décocher")
    btnFile := d.Add("Button", "x+8 yp w200", "Exporter vers un fichier…")
    btnCode := d.Add("Button", "x+8 yp w200", "Copier le code")
    stCount := d.Add("Text", "x22 y" (r1 + 36) " w724", "")
    chkImg := d.Add("CheckBox", "x22 y" (r1 + 60) " w724 Checked", "Inclure les captures d'écran des stuffs (export vers un fichier uniquement)")
    d.Add("Text", "x22 y" (r1 + 96) " w724", "Importer : reçu d'un ami ?")
    btnImpF := d.Add("Button", "x22 y" (r1 + 122) " w240", "Importer un fichier .stuffpack…")
    btnImpC := d.Add("Button", "x+8 yp w230", "Importer depuis le presse-papiers (code)")
    btnPkO := d.Add("Button", "x+8 yp w140", "Packs en ligne...")
    yEnd2 := r1 + 166

    ; ----- Onglet Sauvegardes -----
    tabs.UseTab(3)
    d.Add("Text", "x22 y88 w724 r3", "Une sauvegarde de tes maps est faite chaque jour, et avant chaque mise à jour. Tu peux revenir à l'une d'elles. Ton état actuel est sauvegardé avant la restauration.")
    btnRest := d.Add("Button", "x22 y140 w260", "Restaurer une sauvegarde…")
    d.Add("Text", "x22 y190 w724 r2", "Une mise à jour du menu pose problème ? Tu peux revenir à la version précédente du programme (tes stuffs ne sont pas touchés).")
    btnRoll := d.Add("Button", "x22 y228 w340", "Revenir à la version précédente du menu...")
    yEnd3 := 280

    tabs.UseTab(0)
    tabH := Max(yEnd1, yEnd2, yEnd3) - 44 + 6
    tabs.Move(6, 44, 762, tabH)
    yStat := 44 + tabH + 10
    d.SetFont("s" WinSz() " c" WinPal()["ok"])
    stT := d.Add("Text", "x12 y" yStat " w756", "")
    d.SetFont("s" WinSz() " c" WinPal()["txt"])
    btnClose := d.Add("Button", "x12 y" (yStat + 32) " w120", "Fermer")

    pick := 1
    for k, pn in ListProfiles() {
        if (pn = curProfile)
            pick := k
    }
    ddProf.Choose(pick)

    Say(m) {
        stT.Text := m
    }

    Fill() {
        while (rows.Length > 0)
            rows.Pop()
        lvEx.Delete()
        for k, mn in mapNames {
            for ent in ReadEntries(mapFiles[k])[2] {
                rows.Push([mn, ent[1], ent[2], ent[3], ent[4]])
                lvEx.Add("", mn, ent[1], ent[2], InfoDisp(ent[4]))
            }
        }
            UpdCount()
    }

    UpdCount(*) {
        n := 0
        r := 0
        while (r := lvEx.GetNext(r, "Checked"))
            n += 1
        stCount.Text := n " stuff(s) coché(s) sur " lvEx.GetCount()
    }

    Picked() {
        out := []
        r := 0
        while (r := lvEx.GetNext(r, "Checked"))
            out.Push(rows[r])
        return out
    }

    CheckAll(on, *) {
        Loop lvEx.GetCount()
            lvEx.Modify(A_Index, on ? "Check" : "-Check")
        UpdCount()
    }

    ExportFile(*) {
        sel := Picked()
        if (sel.Length = 0) {
            Say("Coche au moins un stuff à exporter")
            return
        }
        f := FileSelect("S16", A_Desktop "\mes-stuffs.stuffpack", "Exporter les stuffs", "Pack de stuffs (*.stuffpack)")
        if (f = "")
            return
        if !RegExMatch(f, "i)\.stuffpack$")
            f .= ".stuffpack"
        try FileDelete(f)
        nShots := CountShots(sel)
        withI := (chkImg.Value && nShots > 0)
        FileAppend(BuildPack(sel, withI), f, "UTF-8-RAW")
        Say(sel.Length " stuff(s) exporté(s) dans " f)
        if withI
            MsgBox("Export terminé : " sel.Length " stuff(s) et " nShots " capture(s) d'écran dans le fichier.`n`nTon ami verra les captures à l'import. Elles ne sont incluses que dans les fichiers .stuffpack, pas dans le code copié.", "Export", 0x40040)
        else if (nShots > 0)
            MsgBox("Export terminé SANS captures d'écran (case décochée). Coche « Inclure les captures » pour les envoyer aussi.", "Export", 0x40040)
    }

    ExportCode(*) {
        sel := Picked()
        if (sel.Length = 0) {
            Say("Coche au moins un stuff à exporter")
            return
        }
        A_Clipboard := BuildPack(sel)
        nShots := CountShots(sel)
        if (nShots > 0)
            MsgBox("Code copié, mais SANS les " nShots " capture(s) d'écran : les images sont trop lourdes pour un code à copier-coller.`n`nPour envoyer les captures avec les stuffs, utilise « Exporter vers un fichier… » avec la case « Inclure les captures » cochée.", "Export par code", 0x40030)
        Say("Code copié (" sel.Length " stuff(s)) : colle-le à ton ami, de préférence dans un bloc de code. Pour beaucoup de stuffs, envoie plutôt un fichier.")
    }

    ImportProfileBtn(*) {
        nm := ImportProfileZip(d.Hwnd)
        if (nm = "")
            return
        if (MsgBox("Activer le profil « " nm " » maintenant ? (le menu redémarre)", "Importer un profil", 0x40024) = "Yes")
            SwitchProfile(nm)
    }

    ImportFileBtn(*) {
        f := FileSelect(3, A_Desktop, "Choisir un pack de stuffs", "Pack de stuffs (*.stuffpack; *.txt)")
        if (f = "")
            return
        if ShowImport(FileRead(f, "UTF-8"), d.Hwnd) {
            LoadMaps()
            Fill()
        }
    }

    ImportClipBtn(*) {
        if ShowImport(A_Clipboard, d.Hwnd) {
            LoadMaps()
            Fill()
        }
    }

    ActivateProf(*) {
        pn := ddProf.Text
        if (pn = curProfile) {
            Say("Ce profil est déjà actif")
            return
        }
        SwitchProfile(pn)
    }

    NewProf(*) {
        nm := CleanProfileName(AskText("Nouveau profil", "Nom du profil (vide, avec les mêmes maps) :", "", "ahk_id " d.Hwnd))
        if (nm = "")
            return
        if ProfileExists(nm) {
            Say("Un profil « " nm " » existe déjà")
            return
        }
        CreateProfile(nm)
        SwitchProfile(nm)
    }

    DelProf(*) {
        pn := ddProf.Text
        if (pn = DEFAULT_PROFILE) {
            Say("Le profil Principal ne peut pas être supprimé")
            return
        }
        if (pn = curProfile) {
            Say("Active un autre profil avant de supprimer celui-ci")
            return
        }
        ans := MsgBox("Supprimer définitivement le profil « " pn " » et tous ses stuffs ?`nCette action est irréversible.", "Supprimer le profil", 0x34)
        if (ans != "Yes")
            return
        try DirDelete(ProfDir(pn), true)
        ddProf.Delete()
        ddProf.Add(ListProfiles())
        ddProf.Choose(1)
        Say("Profil « " pn " » supprimé")
    }

    Finish(*) {
        global mgrOpen
        mgrOpen := false
        d.Destroy()
        try WinActivate("ahk_exe cs2.exe")
    }

    btnAll.OnEvent("Click", CheckAll.Bind(true))
    btnNone.OnEvent("Click", CheckAll.Bind(false))
    btnFile.OnEvent("Click", ExportFile)
    btnCode.OnEvent("Click", ExportCode)
    btnImpF.OnEvent("Click", ImportFileBtn)
    btnImpC.OnEvent("Click", ImportClipBtn)
    btnAct.OnEvent("Click", ActivateProf)
    btnNew.OnEvent("Click", NewProf)
    btnDelP.OnEvent("Click", DelProf)
    btnClose.OnEvent("Click", Finish)
    btnRest.OnEvent("Click", (*) => ShowRestore(d.Hwnd))
    btnRoll.OnEvent("Click", (*) => RollbackUpdate(false))
    btnPkO.OnEvent("Click", (*) => ShowPacks(d.Hwnd))
    lvEx.OnEvent("ItemCheck", (*) => SetTimer(UpdCount, -30))
    btnPExp.OnEvent("Click", (*) => ExportProfile(ddProf.Text, d.Hwnd))
    btnPImp.OnEvent("Click", ImportProfileBtn)
    d.OnEvent("Close", Finish)
    d.OnEvent("Escape", Finish)
    Fill()
    WinStyle(d)
    d.Show("AutoSize Center")
}

; =====================================================================
;  Annulation des suppressions de stuffs (Ctrl+Z)
; =====================================================================
; Chaque stuff supprimé est noté dans data\deleted.txt (les 50 derniers).
DeletedFile() {
    return DataDir "\deleted.txt"
}

ReadDeletedLines() {
    lines := []
    f := DeletedFile()
    if !FileExist(f)
        return lines
    for l in StrSplit(FileRead(f, "UTF-8"), "`n", "`r") {
        if (l != "")
            lines.Push(l)
    }
    return lines
}

SaveDeletedLines(lines) {
    out := ""
    for l in lines
        out .= l "`n"
    try FileDelete(DeletedFile())
    if (out != "")
        FileAppend(out, DeletedFile(), "UTF-8-RAW")
}

LogDeleted(path, p) {
    SplitPath(path, &fn)
    ln := fn "`t" p[1] "`t" p[2] "`t" p[3] "`t" ((p.Length >= 4) ? p[4] : "")
    try {
        lines := ReadDeletedLines()
        lines.Push(ln)
        while (lines.Length > 50)
            lines.RemoveAt(1)
        SaveDeletedLines(lines)
    }
}

; Remet le dernier stuff supprimé à sa place. Renvoie [nom, fichier, catégorie] ou "" s'il n'y a rien.
UndoLast() {
    lines := ReadDeletedLines()
    if (lines.Length = 0)
        return ""
    last := lines.Pop()
    SaveDeletedLines(lines)
    p := StrSplit(last, "`t")
    if (p.Length < 4 || !RegExMatch(p[1], "^[A-Za-z0-9_\-]+\.txt$"))
        return ""
    path := MapsDir "\" p[1]
    if !FileExist(path)
        FileAppend("# " RegExReplace(p[1], "\.txt$") "`n", path, "UTF-8-RAW")
    taken := Map()
    for x in ReadEntries(path)[2] {
        if (x[1] = p[2])
            taken[StrLower(x[2])] := 1
    }
    nm := p[3]
    if taken.Has(StrLower(nm)) {
        nm := p[3] " (restauré)"
        k := 2
        while taken.Has(StrLower(nm)) {
            nm := p[3] " (restauré " k ")"
            k += 1
        }
    }
    AppendLine(path, BuildLine(p[2], nm, p[4], (p.Length >= 5) ? p[5] : ""))
    return [nm, p[1], p[2]]
}

UndoPress() {
    if (level = 4 || utilMode) {
        SetStatus("Ouvre d'abord le menu des stuffs.")
        return
    }
    r := UndoLast()
    if !IsObject(r) {
        SetStatus("Rien à annuler")
        return
    }
    ReloadKeep()
    Render()
    SetStatus("Stuff restauré : " r[1])
}

; =====================================================================
;  Sauvegarde automatique des maps (une fois par jour)
; =====================================================================
; Copie maps\*.txt de chaque profil dans data\backup\auto\AAAA-MM-JJ\ et garde les BackupKeep dernières.
SortNames(arr, desc := false) {
    n := arr.Length
    Loop n {
        i := 1
        while (i < n) {
            a := arr[i]
            b := arr[i + 1]
            if (desc ? (StrCompare(a, b) < 0) : (StrCompare(a, b) > 0)) {
                arr[i] := b
                arr[i + 1] := a
            }
            i += 1
        }
    }
    return arr
}

PruneBackups(root) {
    names := []
    Loop Files root "\*", "D" {
        if RegExMatch(A_LoopFileName, "^\d{4}-\d{2}-\d{2}$")
            names.Push(A_LoopFileName)
    }
    SortNames(names)
    while (names.Length > BackupKeep) {
        try DirDelete(root "\" names[1], true)
        names.RemoveAt(1)
    }
}

AutoBackup() {
    if (BackupKeep <= 0)
        return
    stamp := FormatTime(, "yyyy-MM-dd")
    for pn in ListProfiles() {
        mdir := ProfMaps(pn)
        if !DirExist(mdir)
            continue
        root := ProfData(pn) "\backup\auto"
        dest := root "\" stamp
        if DirExist(dest)
            continue
        has := false
        Loop Files mdir "\*.txt" {
            has := true
            break
        }
        if !has
            continue
        ok := true
        try {
            DirCreate(dest)
            Loop Files mdir "\*.txt"
                FileCopy(A_LoopFileFullPath, dest "\" A_LoopFileName, 1)
        } catch {
            ok := false
        }
        if ok
            PruneBackups(root)
    }
}

; =====================================================================
;  Export / import d'un profil complet dans un seul fichier .zip
; =====================================================================
; Réglages emportés avec le profil (jamais les chemins de ce PC)
ProfSettingKeys() {
    return ["MenuKey", "FavKey", "LockKey", "AddKey", "RethrowKey", "TpZOffset", "CloseAfterRun", "AutoDetectMap", "AutoExec"
        , "Shot", "ShotSize", "ShotZoom", "ShotPos", "ShotCorner", "ShotX", "ShotY"
        , "HudAtStart", "HudAuto", "HudX", "HudY", "TimerOn", "TimerAuto", "TimerX", "TimerY", "TimerDur", "TimerBeep", "FlightAsk"]
}

ExportProfile(prof, ownerHwnd) {
    dest := FileSelect("S16", A_Desktop "\Menu-Stuf-" prof ".zip", "Exporter le profil « " prof " »", "Profil (*.zip)")
    if (dest = "")
        return
    if !RegExMatch(dest, "i)\.zip$")
        dest .= ".zip"
    stage := A_Temp "\cs2stuff_profexp"
    try DirDelete(stage, true)
    ok := true
    try {
        DirCreate(stage "\maps")
        DirCreate(stage "\data")
        DirCreate(stage "\data\shots")
        Loop Files ProfMaps(prof) "\*.txt"
            FileCopy(A_LoopFileFullPath, stage "\maps\" A_LoopFileName, 1)
        Loop Files ProfData(prof) "\*.txt"
            FileCopy(A_LoopFileFullPath, stage "\data\" A_LoopFileName, 1)
        Loop Files ProfData(prof) "\shots\*.*" {
            if RegExMatch(A_LoopFileName, "i)\.(bmp|jpe?g)$")
                FileCopy(A_LoopFileFullPath, stage "\data\shots\" A_LoopFileName, 1)
        }
        FileAppend("name=" prof "`nversion=" APP_VERSION "`n", stage "\profil.txt", "UTF-8-RAW")
        for k in ProfSettingKeys() {
            v := IniRead(IniFile, "Settings", k, "")
            if (v != "")
                IniWrite(v, stage "\settings.ini", "Settings", k)
        }
        for k in ["Theme", "Font", "Scale", "X", "Y", "Opacity", "Bg", "Border", "Corner", "BorderColor"] {
            v := IniRead(IniFile, "Overlay", k, "")
            if (v != "")
                IniWrite(v, stage "\settings.ini", "Overlay", k)
        }
        try FileDelete(dest)
        q := "'"
        dq := Chr(34)
        RunWait("powershell -NoProfile -ExecutionPolicy Bypass -Command " dq "Compress-Archive -Path " q stage "\*" q " -DestinationPath " q dest q " -Force" dq, , "Hide")
        ok := FileExist(dest) ? true : false
    } catch {
        ok := false
    }
    try DirDelete(stage, true)
    if ok
        MsgBox("Profil « " prof " » exporté :`n" dest "`n`nSur l'autre PC : « Importer un profil… » dans cette même fenêtre.", "Exporter un profil", 0x40040)
    else
        MsgBox("L'export a échoué.", "Exporter un profil", 0x40010)
}

; Retourne le nom du profil importé ("" si annulé ou échec)
ImportProfileZip(ownerHwnd) {
    src := FileSelect(3, A_Desktop, "Importer un profil", "Profil (*.zip)")
    if (src = "")
        return ""
    tmp := A_Temp "\cs2stuff_profimp"
    try DirDelete(tmp, true)
    DirCreate(tmp)
    q := "'"
    dq := Chr(34)
    try RunWait("powershell -NoProfile -ExecutionPolicy Bypass -Command " dq "Expand-Archive -LiteralPath " q src q " -DestinationPath " q tmp q " -Force" dq, , "Hide")
    if (!FileExist(tmp "\profil.txt") || !DirExist(tmp "\maps")) {
        MsgBox("Ce fichier n'est pas un profil exporté par le menu.", "Importer un profil", 0x40010)
        try DirDelete(tmp, true)
        return ""
    }
    nm := ""
    try {
        for ln in StrSplit(FileRead(tmp "\profil.txt", "UTF-8"), "`n", "`r") {
            if RegExMatch(ln, "^name=(.+)$", &mm)
                nm := mm[1]
        }
    }
    ib := InputBox("Nom du profil sur ce PC (un nom existant est remplacé après sauvegarde) :", "Importer un profil", "w420 h130", CleanProfileName(nm))
    if (ib.Result != "OK") {
        try DirDelete(tmp, true)
        return ""
    }
    nm := CleanProfileName(ib.Value)
    if (nm = "") {
        try DirDelete(tmp, true)
        return ""
    }
    exists := ProfileExists(nm)
    if exists {
        if (MsgBox("Le profil « " nm " » existe déjà. Ses maps et ses données de même nom seront remplacées.`nUne sauvegarde est faite avant.`n`nContinuer ?", "Importer un profil", 0x40024) != "Yes") {
            try DirDelete(tmp, true)
            return ""
        }
        root := ProfData(nm) "\backup\auto"
        safe := root "\avant-import-" FormatTime(, "yyyy-MM-dd_HHmmss")
        try {
            DirCreate(safe "\data")
            Loop Files ProfMaps(nm) "\*.txt"
                FileCopy(A_LoopFileFullPath, safe "\" A_LoopFileName, 1)
            Loop Files ProfData(nm) "\*.txt"
                FileCopy(A_LoopFileFullPath, safe "\data\" A_LoopFileName, 1)
        }
    } else {
        CreateProfile(nm)
    }
    DirCreate(ProfMaps(nm))
    DirCreate(ProfData(nm))
    nStuff := 0
    nBlocked := 0
    try {
        Loop Files tmp "\maps\*.txt" {
            if !RegExMatch(A_LoopFileName, "^[\w\-. ]+\.txt$")
                continue
            out := ""
            for ln in StrSplit(FileRead(A_LoopFileFullPath, "UTF-8"), "`n", "`r") {
                parts := StrSplit(ln, "|")
                if (SubStr(Trim(ln), 1, 1) != "#" && parts.Length >= 3 && BlockedCmd(parts[3]) != "") {
                    nBlocked += 1
                    continue
                }
                if (parts.Length >= 3 && SubStr(Trim(ln), 1, 1) != "#")
                    nStuff += 1
                out .= ln "`n"
            }
            dst := ProfMaps(nm) "\" A_LoopFileName
            try FileDelete(dst)
            FileAppend(RTrim(out, "`n") "`n", dst, "UTF-8-RAW")
        }
        Loop Files tmp "\data\*.txt" {
            if RegExMatch(A_LoopFileName, "^[\w\-. ]+\.txt$")
                FileCopy(A_LoopFileFullPath, ProfData(nm) "\" A_LoopFileName, 1)
        }
        if DirExist(tmp "\data\shots") {
            DirCreate(ProfData(nm) "\shots")
            Loop Files tmp "\data\shots\*.*" {
                if RegExMatch(A_LoopFileName, "i)^[\w\-. ]+\.(bmp|jpe?g)$")
                    FileCopy(A_LoopFileFullPath, ProfData(nm) "\shots\" A_LoopFileName, 1)
            }
        }
    } catch as err {
        MsgBox("L'import a échoué : " err.Message, "Importer un profil", 0x40010)
        try DirDelete(tmp, true)
        return ""
    }
    msg := "Profil « " nm " » importé (" nStuff " stuffs)."
    if (nBlocked > 0)
        msg .= "`n" nBlocked " ligne(s) avec une commande interdite (quit, exec, bind...) ont été ignorées."
    if (FileExist(tmp "\settings.ini") && MsgBox(msg "`n`nAppliquer aussi les réglages de ce profil (apparence, touches, chronomètre) ?", "Importer un profil", 0x40024) = "Yes") {
        for k in ProfSettingKeys() {
            v := IniRead(tmp "\settings.ini", "Settings", k, "")
            if (v != "")
                IniWrite(v, IniFile, "Settings", k)
        }
        for k in ["Theme", "Font", "Scale", "X", "Y", "Opacity", "Bg", "Border", "Corner", "BorderColor"] {
            v := IniRead(tmp "\settings.ini", "Overlay", k, "")
            if (v != "")
                IniWrite(v, IniFile, "Overlay", k)
        }
        msg .= "`nRéglages appliqués (visibles au prochain redémarrage du menu)."
    } else if FileExist(tmp "\settings.ini") {
        msg .= "`nRéglages non appliqués."
    }
    try DirDelete(tmp, true)
    return nm
}

; Avant une mise à jour : copie les maps et les fichiers de data (temps, favoris, cadenas) de chaque profil
PreUpdateBackup() {
    BackupNow("avant-maj-" APP_VERSION "_" FormatTime(, "yyyy-MM-dd_HHmmss"), "avant-maj-*", 5)
}

; Nom de dossier de sauvegarde -> [type lisible, date lisible]
BackupLabel(nm) {
    if RegExMatch(nm, "^(\d{4})-(\d\d)-(\d\d)$", &m)
        return ["Automatique (quotidienne)", m[3] "/" m[2] "/" m[1]]
    if RegExMatch(nm, "^avant-maj-(.+?)_(\d{4})-(\d\d)-(\d\d)_(\d\d)(\d\d)\d\d$", &m)
        return ["Avant la mise à jour " m[1], m[4] "/" m[3] "/" m[2] " à " m[5] " h " m[6]]
    if RegExMatch(nm, "^manuelle-(\d{4})-(\d\d)-(\d\d)_(\d\d)(\d\d)\d\d$", &m)
        return ["Sauvegarde manuelle", m[3] "/" m[2] "/" m[1] " à " m[4] " h " m[5]]
    if RegExMatch(nm, "^avant-restauration-(\d{4})-(\d\d)-(\d\d)_(\d\d)(\d\d)\d\d$", &m)
        return ["Avant une restauration", m[3] "/" m[2] "/" m[1] " à " m[4] " h " m[5]]
    if RegExMatch(nm, "^avant-import-(\d{4})-(\d\d)-(\d\d)_(\d\d)(\d\d)\d\d$", &m)
        return ["Avant un import de profil", m[3] "/" m[2] "/" m[1] " à " m[4] " h " m[5]]
    return [nm, ""]
}

ShowRestore(ownerHwnd) {
    root := DataDir "\backup\auto"
    names := []
    Loop Files root "\*", "D"
        names.Push(A_LoopFileName)
    if (names.Length = 0) {
        MsgBox("Aucune sauvegarde automatique pour le moment.`nElles sont créées une fois par jour, au lancement du script.", "Restaurer une sauvegarde", 0x40040)
        return
    }
    SortNames(names, true)
    d := WinNew("Restaurer une sauvegarde", "+AlwaysOnTop +OwnDialogs")
    d.Add("Text", "x12 y12 w470", "Choisis la sauvegarde à restaurer pour le profil « " curProfile " ».`nTon état actuel est sauvegardé juste avant (sauvegarde « Avant une restauration »).")
    lv := d.Add("ListView", "x12 y58 w470 r10 NoSort -Multi", ["Type", "Date", "Maps", "Dossier"])
    for nm in names {
        cnt := 0
        Loop Files root "\" nm "\*.txt"
            cnt += 1
        fb := BackupLabel(nm)
        lv.Add("", fb[1], fb[2], cnt, nm)
    }
    lv.ModifyCol(1, 230)
    lv.ModifyCol(2, 150)
    lv.ModifyCol(3, 60)
    lv.ModifyCol(4, 0)
    btnNo := d.Add("Button", "x12 y+12 w120", "Annuler")
    btnOk := d.Add("Button", "x282 yp w200 Default", "Restaurer")

    DoRestore(*) {
        r := lv.GetNext(0)
        if !r
            return
        sel := lv.GetText(r, 4)
        ans := MsgBox("Remplacer les maps du profil « " curProfile " » par la sauvegarde « " sel " » ?`nTon état actuel sera sauvegardé avant.", "Restaurer", 0x40024)
        if (ans != "Yes")
            return
        safe := root "\avant-restauration-" FormatTime(, "yyyy-MM-dd_HHmmss")
        try {
            DirCreate(safe)
            Loop Files MapsDir "\*.txt"
                FileCopy(A_LoopFileFullPath, safe "\" A_LoopFileName, 1)
            Loop Files root "\" sel "\*.txt"
                FileCopy(A_LoopFileFullPath, MapsDir "\" A_LoopFileName, 1)
            if DirExist(root "\" sel "\data") {
                Loop Files root "\" sel "\data\*.txt"
                    FileCopy(A_LoopFileFullPath, DataDir "\" A_LoopFileName, 1)
            }
        } catch as err {
            MsgBox("La restauration a échoué : " err.Message, "Restaurer", 0x40010)
            return
        }
        d.Destroy()
        MsgBox("Sauvegarde « " sel " » restaurée. Rouvre le menu pour voir les stuffs.", "Restaurer", 0x40040)
    }

    CancelRestore(*) {
        d.Destroy()
    }

    btnOk.OnEvent("Click", DoRestore)
    btnNo.OnEvent("Click", CancelRestore)
    d.OnEvent("Close", CancelRestore)
    d.OnEvent("Escape", CancelRestore)
    WinStyle(d)
    d.Show("AutoSize Center")
    hw := d.Hwnd
    WinWaitClose("ahk_id " hw)
    try WinActivate("ahk_id " ownerHwnd)
}

; =====================================================================
;  Vérification de l'installation (au lancement, puis une fois CS2 lancé)
; =====================================================================
; Phase 1 : tout ce qui se vérifie sans CS2 (dossiers, fichiers).
; Phase 2 : dès que CS2 est au premier plan, test réel d'envoi de commande via console.log.
Check1() {
    out := []
    tf := cfgDir "\stuff_write_test.tmp"
    okw := false
    try {
        FileAppend("test", tf)
        FileDelete(tf)
        okw := true
    }
    if okw
        out.Push(["ok", "Dossier cfg de CS2 trouvé et accessible en écriture", ""])
    else
        out.Push(["fail", "Impossible d'écrire dans le dossier cfg de CS2", "Vérifie CfgPath dans config.ini (actuellement : " cfgDir ")"])

    pc := cfgDir "\" PracticeCfg ".cfg"
    if FileExist(pc)
        out.Push(["ok", PracticeCfg ".cfg présent dans le dossier cfg", ""])
    else
        out.Push(["fail", PracticeCfg ".cfg introuvable dans le dossier cfg", "Copie cs2_practice.cfg (fourni avec le menu) dans " cfgDir])

    nmaps := 0
    Loop Files MapsDir "\de_*.txt"
        nmaps += 1
    if (nmaps > 0)
        out.Push(["ok", "Profil « " curProfile " » : " nmaps " fichier(s) de map trouvé(s)", ""])
    else
        out.Push(["fail", "Aucun fichier de map dans " MapsDir, "Relance le script avec le dossier maps_default à côté de stuff_menu.ahk"])

    okd := false
    try {
        DirCreate(DataDir)
        FileAppend("test", DataDir "\write_test.tmp")
        FileDelete(DataDir "\write_test.tmp")
        okd := true
    }
    if okd
        out.Push(["ok", "Dossier data accessible en écriture (favoris, cadenas, sauvegardes)", ""])
    else
        out.Push(["fail", "Impossible d'écrire dans le dossier data", "Déplace le menu dans un dossier où tu peux écrire (Bureau, Documents)"])

    steam := ""
    try steam := StrReplace(RegRead("HKEY_CURRENT_USER\Software\Valve\Steam", "SteamExe"), "/", "\")
    if (steam != "" && FileExist(steam))
        out.Push(["ok", "Steam trouvé : le menu peut lancer CS2 avec les bonnes options", ""])
    else
        out.Push(["warn", "Steam introuvable sur ce PC", "Lance CS2 toi-même avec les options " StrReplace(LaunchArgs, "{port}", NetconPort) " dans les options de lancement de Steam"])

    if FileExist(ConsoleLog)
        out.Push(["ok", "console.log trouvé", ""])
    else
        out.Push(["warn", "console.log pas encore créé", "Normal si CS2 n'a jamais tourné avec -condebug : ajoute -condebug dans les options de lancement de CS2 (Steam), puis lance le jeu"])
    return out
}

; Renvoie [liste, envoiOk, peutReessayer]
Check2() {
    global netFailTick
    out := []
    if !FileExist(ConsoleLog) {
        out.Push(["fail", "console.log introuvable alors que CS2 est lancé", "Ajoute -condebug dans les options de lancement de CS2 (Steam), puis relance le jeu"])
        return [out, false, false]
    }
    out.Push(["ok", "console.log présent", ""])
    netFailTick := 0
    if NetOpen() {
        out.Push(["ok", "Connexion directe à CS2 active (port " NetconPort ")", ""])
    } else {
        out.Push(["fail", "Connexion directe à CS2 impossible (port " NetconPort ")", "Ferme CS2, puis relance le menu : il lance le jeu avec -netconport " NetconPort " -insecure. Si ça persiste, ajoute ces options dans les options de lancement de CS2 sur Steam"])
        return [out, false, true]
    }
    ; même commande que la détection de map : si le jeu répond, l'envoi fonctionne
    txt := RunAndReadLog("status", "main lump")
    if !RegExMatch(txt, "i)main lump|hostname|Not connected|loopback|spawngroup") {
        out.Push(["fail", "Test d'envoi de commande : pas de réponse du jeu", "Entre dans une partie (map locale), puis clique sur Relancer la vérification. Vérifie que -condebug est dans les options de lancement de CS2"])
        return [out, false, true]
    }
    out.Push(["ok", "Envoi de commandes vers CS2 : fonctionne", ""])
    ; lit toute la réponse du jeu (le motif ne correspond jamais : on récupère tout le texte reçu)
    ct := RunAndReadLog("sv_cheats", "MOTIF_JAMAIS_TROUVE")
    cv := ""
    if RegExMatch(ct, "i)sv_cheats`"?\s*[=:]\s*`"?(\w+)", &cm)
        cv := StrLower(cm[1])
    if (cv = "0" || cv = "false")
        out.Push(["warn", "sv_cheats est désactivé", "Lance une map locale (pas de serveur ni de matchmaking)"])
    else
        out.Push(["ok", "Cheats : le menu envoie sv_cheats 1 avec chaque commande", ""])
    LoadMaps()
    mp := MapFromStatus(txt)
    if (mp = "")
        mp := DetectMap()
    if (mp = "" && chkAttempts < 5) {
        ; la réponse du jeu peut arriver en retard : on réessaie quelques fois avant de signaler
        return [out, false, true]
    }
    if (mp != "")
        out.Push(["ok", "Map détectée : " mp, ""])
    else
        out.Push(["warn", "Map non détectée (normal dans le menu principal)", "Entre dans une map locale pour que le menu s'ouvre sur la bonne map"])
    return [out, true, false]
}

CheckLine(r) {
    icon := (r[1] = "ok") ? "✔" : (r[1] = "warn") ? "⚠" : "✘"
    ln := icon "  " r[2] "`n"
    if (r[1] != "ok" && r[3] != "")
        ln .= "      → " r[3] "`n"
    return ln
}

CheckRender(head) {
    if !IsObject(chkGui)
        return
    chkHead.Text := head
    out := ""
    for r in chkP1
        out .= CheckLine(r)
    for r in chkP2
        out .= CheckLine(r)
    chkTxt.Text := out
}

CheckClose(*) {
    global chkGui
    SetTimer(CheckTick, 0)
    SetTimer(CheckClose, 0)
    if IsObject(chkGui) {
        try chkGui.Destroy()
    }
    chkGui := ""
}

StartCheck(*) {
    global chkGui, chkHead, chkTxt, chkP1, chkP2, chkAttempts, chkTicks, chkBusy
    CheckClose()
    chkP1 := Check1()
    chkP2 := []
    chkAttempts := 0
    chkTicks := 0
    chkBusy := false
    chkGui := WinNew("Vérification de l'installation", "+AlwaysOnTop")
    chkHead := chkGui.Add("Text", "x12 y12 w620 r2", "")
    chkTxt := chkGui.Add("Text", "x12 y+10 w620 r16", "")
    btnRe := chkGui.Add("Button", "x12 y+12 w220", "Relancer la vérification")
    btnX := chkGui.Add("Button", "x+10 yp w120", "Fermer")
    btnRep := chkGui.Add("Button", "x+10 yp w200", "Créer un rapport...")
    btnRep.OnEvent("Click", (*) => ShowReport())
    btnCfgCopy := chkGui.Add("Button", "x12 y+10 w300", "Copier cs2_practice.cfg dans le cfg de CS2")
    btnCfgOpen := chkGui.Add("Button", "x+10 yp w200", "Ouvrir le dossier cfg")
    CfgCopy(*) {
        src := A_ScriptDir "\" PracticeCfg ".cfg"
        if !FileExist(src)
            src := A_ScriptDir "\cs2_practice.cfg"
        if !FileExist(src) {
            MsgBox("Fichier cs2_practice.cfg introuvable à côté du menu.", "Vérification", 0x40010)
            return
        }
        try {
            FileCopy(src, cfgDir "\" PracticeCfg ".cfg", 1)
            MsgBox("cs2_practice.cfg copié dans :`n" cfgDir, "Vérification", 0x40040)
            SetTimer(StartCheck, -50)
        } catch as err {
            MsgBox("Copie impossible : " err.Message, "Vérification", 0x40010)
        }
    }
    CfgOpen(*) {
        if DirExist(cfgDir)
            Run('explorer "' cfgDir '"')
        else
            MsgBox("Dossier cfg introuvable : " cfgDir "`nCorrige CfgPath dans config.ini.", "Vérification", 0x40030)
    }
    btnCfgCopy.OnEvent("Click", CfgCopy)
    btnCfgOpen.OnEvent("Click", CfgOpen)
    btnRe.OnEvent("Click", (*) => SetTimer(StartCheck, -50))
    btnX.OnEvent("Click", CheckClose)
    chkGui.OnEvent("Close", CheckClose)
    chkGui.OnEvent("Escape", CheckClose)
    CheckRender("Vérification en cours...")
    WinStyle(chkGui)
    if (launcherHwnd && WinExist("ahk_id " launcherHwnd)) {
        ; à droite du launcher (à gauche s'il n'y a pas la place)
        WinGetPos(&lx, &ly, &lw, &lh, "ahk_id " launcherHwnd)
        chkGui.Show("AutoSize NoActivate x" (lx + lw + 12) " y" ly)
        chkGui.GetPos(&cx, &cy, &cw, &ch)
        mon := MonitorGetPrimary()
        MonitorGetWorkArea(mon, &ml, &mt, &mr, &mb)
        if (cx + cw > mr)
            chkGui.Move(Max(ml, lx - 12 - cw), ly)
    } else {
        chkGui.Show("AutoSize NoActivate")
    }
    SetTimer(CheckTick, 2000)
    CheckTick()
}

CheckTick() {
    global chkAttempts, chkTicks, chkP2, chkBusy
    if !IsObject(chkGui) {
        SetTimer(CheckTick, 0)
        return
    }
    if chkBusy
        return
    if !ProcessExist("cs2.exe") {
        CheckRender("Étape 1 terminée. CS2 n'est pas lancé : le menu le démarre au lancement du script (ferme-le puis relance le menu si besoin).`nEntre ensuite dans une map d'entraînement locale : la suite de la vérification se fera toute seule.")
        return
    }
    if (!WinActive("ahk_exe cs2.exe") || menuOpen || dlgOpen) {
        CheckRender("CS2 détecté. Clique dans le jeu et reste dans la partie pour finir la vérification.")
        return
    }
    chkTicks += 1
    if (chkTicks < 2) {
        CheckRender("CS2 détecté. Vérification dans un instant...")
        return
    }
    if (chkAttempts > 0 && Mod(chkTicks, 3) != 0)
        return
    chkBusy := true
    try {
        chkAttempts += 1
        res := Check2()
        chkP2 := res[1]
        if (res[2] || !res[3] || chkAttempts >= 30) {
            SetTimer(CheckTick, 0)
            bad := 0
            for r in chkP1
                bad += (r[1] != "ok") ? 1 : 0
            for r in chkP2
                bad += (r[1] != "ok") ? 1 : 0
            if (bad = 0) {
                CheckClose()
                if (IniRead(IniFile, "State", "InstallOk", "0") != "1") {
                    IniWrite("1", IniFile, "State", "InstallOk")
                    TrayTip("Installation validée : tout est prêt pour t'entraîner.", "Menu Stuf")
                }
            } else {
                CheckRender("Il y a " bad " point(s) à corriger (voir ci-dessous). Le bouton « Créer un rapport » prépare un message à m'envoyer.")
            }
        } else {
            CheckRender("Attente de la partie... (essai " chkAttempts "/30)")
        }
    } finally {
        chkBusy := false
    }
}

; =====================================================================
;  Sauvegarde manuelle, mise à jour : outils communs
; =====================================================================
; Copie les maps et les données (temps, favoris, cadenas) de chaque profil dans backup\auto\<stamp>. Renvoie le nombre de profils sauvegardés.
BackupNow(stamp, pattern, keep) {
    saved := 0
    for pn in ListProfiles() {
        mdir := ProfMaps(pn)
        if !DirExist(mdir)
            continue
        root := ProfData(pn) "\backup\auto"
        dest := root "\" stamp
        try {
            DirCreate(dest "\data")
            Loop Files mdir "\*.txt"
                FileCopy(A_LoopFileFullPath, dest "\" A_LoopFileName, 1)
            Loop Files ProfData(pn) "\*.txt"
                FileCopy(A_LoopFileFullPath, dest "\data\" A_LoopFileName, 1)
        } catch {
            continue
        }
        saved += 1
        names := []
        Loop Files root "\" pattern, "D"
            names.Push(A_LoopFileName)
        SortNames(names)
        while (names.Length > keep) {
            try DirDelete(root "\" names[1], true)
            names.RemoveAt(1)
        }
    }
    return saved
}

ManualBackup() {
    n := BackupNow("manuelle-" FormatTime(, "yyyy-MM-dd_HHmmss"), "manuelle-*", 10)
    if (n > 0)
        MsgBox("Sauvegarde créée (" n " profil(s)) : maps, favoris, cadenas et temps de vol.`n`nPour revenir en arrière : « Profils et partage de stuffs » > Sauvegardes > Restaurer. Les 10 dernières sauvegardes manuelles sont gardées.", "Sauvegarde", 0x40040)
    else
        MsgBox("Rien à sauvegarder : aucun fichier de map trouvé.", "Sauvegarde", 0x40030)
}

; Dernière version publiée sur GitHub ("" si injoignable)
RemoteVersion() {
    tmp := A_Temp "\cs2stuff_version.txt"
    try FileDelete(tmp)
    remote := ""
    try {
        Download("https://raw.githubusercontent.com/" UPDATE_REPO "/main/VERSION", tmp)
        remote := Trim(FileRead(tmp), " `t`r`n")
    } catch {
        return ""
    }
    return RegExMatch(remote, "^\d+(\.\d+)*$") ? remote : ""
}

; =====================================================================
;  Retour à la version précédente du menu
; =====================================================================
RollbackFile() {
    for dir in [A_ScriptDir "\data\backup", DataDir "\backup"] {
        if FileExist(dir "\stuff_menu.ahk.bak")
            return dir "\stuff_menu.ahk.bak"
    }
    return ""
}

; Appelée à chaque erreur non gérée : journal + compteur pendant la période d'essai qui suit une mise à jour
ScriptError(exc, mode) {
    try {
        DirCreate(A_ScriptDir "\data")
        lf := A_ScriptDir "\data\menu_errors.log"
        if (FileExist(lf) && FileGetSize(lf) > 200000)
            FileDelete(lf)
        ln := ""
        try ln := exc.Line
        FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") " v" APP_VERSION " : " exc.Message " (ligne " ln ")`n", lf, "UTF-8")
        if (IniRead(IniFile, "State", "UpdateTrial", "0") = "1") {
            n := ToInt(IniRead(IniFile, "State", "TrialErrors", "0"), 0) + 1
            IniWrite(n, IniFile, "State", "TrialErrors")
            if (n >= 2)
                SetTimer(() => RollbackUpdate(true), -1500)
        }
    }
    return 0
}

EndTrial() {
    IniWrite(0, IniFile, "State", "UpdateTrial")
    IniWrite(0, IniFile, "State", "TrialErrors")
}

RollbackUpdate(auto := false) {
    static busy := false
    if busy
        return
    bak := RollbackFile()
    if (bak = "") {
        if !auto
            MsgBox("Aucune ancienne version enregistrée.`nElle est créée automatiquement à chaque mise à jour du menu.", "Version précédente", 0x40030)
        return
    }
    prev := IniRead(IniFile, "State", "PrevVersion", "")
    prevTxt := RegExMatch(prev, "^\d+(\.\d+)*$") ? "la version " prev : "la version précédente"
    if auto
        msg := "Le menu a rencontré plusieurs erreurs depuis la mise à jour vers la " APP_VERSION ".`n`nRevenir à " prevTxt " ?`nTes stuffs, favoris et profils ne sont pas touchés."
    else
        msg := "Revenir à " prevTxt " du menu ?`nTes stuffs, favoris et profils ne sont pas touchés. Le menu redémarre."
    busy := true
    if (MsgBox(msg, "Menu Stuf - version précédente", 0x40024) != "Yes") {
        busy := false
        if auto
            EndTrial()
        return
    }
    try FileCopy(A_ScriptFullPath, bak ".nouvelle", 1)
    try {
        FileCopy(bak, A_ScriptFullPath, 1)
    } catch as err {
        MsgBox("Impossible de restaurer : " err.Message, "Version précédente", 0x40010)
        busy := false
        return
    }
    IniWrite(APP_VERSION, IniFile, "State", "SkipUpdate")   ; ne pas reproposer cette version automatiquement
    if RegExMatch(prev, "^\d+(\.\d+)*$")
        IniWrite(prev, IniFile, "State", "LastSeenVersion")
    EndTrial()
    IniWrite(1, IniFile, "State", "SkipCheck")
    MsgBox("Ancienne version restaurée. Le menu redémarre.", "Version précédente", 0x40040)
    Reload()
}

; =====================================================================
;  Guide de démarrage (première utilisation, puis bouton du launcher)
; =====================================================================
ShowWelcome(*) {
    static open := ""
    if IsObject(open) {
        try {
            open.Show()
            return
        }
    }
    p := WinPal()
    d := WinNew("Guide de démarrage", "")
    open := d
    d.MarginX := 20
    d.MarginY := 16
    d.SetFont("s" Round(WinSz() * 1.6) " bold c" p["accent"], WinFontName)
    d.Add("Text", "x20 y16 w440", "Bienvenue !")
    d.SetFont("s" WinSz() " norm c" p["dim"], WinFontName)
    d.Add("Text", "x20 y+2 w440", "Trois étapes pour t'entraîner en moins d'une minute.")
    d.SetFont("s" WinSz() " bold c" p["txt"], WinFontName)
    d.Add("Text", "x20 y+18 w440", "1. Lance CS2 depuis le launcher")
    d.SetFont("s" WinSz() " norm c" p["txt"], WinFontName)
    d.Add("Text", "x20 y+4 w440 r3", "Clique sur « Lancer CS2 ». Le menu démarre le jeu avec les bonnes options et charge une map d'entraînement : tu n'as rien à régler dans Steam.")
    btnTest := d.Add("Button", "x20 y+8 w220", "Tester l'installation")
    d.SetFont("s" WinSz() " bold c" p["txt"], WinFontName)
    d.Add("Text", "x20 y+18 w440", "2. Ouvre le menu dans le jeu")
    d.SetFont("s" WinSz() " norm c" p["txt"], WinFontName)
    d.Add("Text", "x20 y+4 w440 r2", "Une fois dans la map, appuie sur " MenuKey ". Les flèches naviguent, Entrée lance un stuff, " AddKey " en crée un.")
    btnKey := d.Add("Button", "x20 y+8 w220", "Changer la touche du menu")
    d.SetFont("s" WinSz() " bold c" p["txt"], WinFontName)
    d.Add("Text", "x20 y+18 w440", "3. Récupère des stuffs")
    d.SetFont("s" WinSz() " norm c" p["txt"], WinFontName)
    d.Add("Text", "x20 y+4 w440 r2", "Importe les packs de stuffs publiés par ProToxEU, ou crée les tiens directement depuis le jeu.")
    btnPk := d.Add("Button", "x20 y+8 w220", "Voir les packs de stuffs")
    btnDone := d.Add("Button", "x20 y+24 w440 h36 Default", "C'est compris")
    TestClick(*) {
        SetTimer(StartCheck, -50)
    }
    KeyClick(*) {
        k := Trim(AskText("Touche du menu", "Nom de la touche (ex. F1, Insert, XButton1) :", MenuKey, "ahk_id " d.Hwnd))
        if (k = "")
            return
        if (!GetKeyVK(k) && !GetKeySC(k)) {
            MsgBox("Touche inconnue : " k "`nExemples : F1, F5, Insert, Home, XButton1.", "Touche du menu", 0x40030)
            return
        }
        IniWrite(k, IniFile, "Settings", "MenuKey")
        MsgBox("Touche enregistrée : " k ".`nLe menu redémarre pour l'appliquer.", "Touche du menu", 0x40040)
        IniWrite("1", IniFile, "State", "WelcomeDone")
        IniWrite(1, IniFile, "State", "SkipCheck")
        Reload()
    }
    PkClick(*) {
        ShowPacks(d.Hwnd)
    }
    Done(*) {
        IniWrite("1", IniFile, "State", "WelcomeDone")
        open := ""
        try d.Destroy()
    }
    btnTest.OnEvent("Click", TestClick)
    btnKey.OnEvent("Click", KeyClick)
    btnPk.OnEvent("Click", PkClick)
    btnDone.OnEvent("Click", Done)
    d.OnEvent("Close", Done)
    d.OnEvent("Escape", Done)
    WinStyle(d)
    if (launcherHwnd && WinExist("ahk_id " launcherHwnd)) {
        WinGetPos(&lx, &ly, &lw, &lh, "ahk_id " launcherHwnd)
        d.Show("AutoSize x" (lx + lw + 12) " y" ly)
        d.GetPos(&cx, &cy, &cw, &ch)
        MonitorGetWorkArea(MonitorGetPrimary(), &ml, &mt, &mr, &mb)
        if (cx + cw > mr)
            d.Move(Max(ml, lx - 12 - cw), ly)
    } else {
        d.Show("AutoSize Center")
    }
}

; =====================================================================
;  Packs de stuffs publiés dans le dépôt GitHub (dossier packs\, lecture seule pour les joueurs)
; =====================================================================
PackUrl(file) {
    return "https://raw.githubusercontent.com/" UPDATE_REPO "/main/packs/" file
}

; Liste [fichier, titre, description] depuis packs\index.txt ; false si injoignable
FetchPackIndex() {
    tmp := A_Temp "\cs2stuff_packs.txt"
    try FileDelete(tmp)
    try {
        Download(PackUrl("index.txt"), tmp)
        txt := FileRead(tmp, "UTF-8")
    } catch {
        return false
    }
    rows := []
    for ln in StrSplit(txt, "`n", "`r") {
        ln := Trim(ln)
        if (ln = "" || SubStr(ln, 1, 1) = "#")
            continue
        parts := StrSplit(ln, "|", " `t")
        if (parts.Length >= 2 && RegExMatch(parts[1], "i)^[\w\-\.]+\.stuffpack$"))
            rows.Push([parts[1], parts[2], (parts.Length >= 3) ? parts[3] : ""])
    }
    return rows
}

ShowPacks(ownerHwnd := 0) {
    static open := ""
    if IsObject(open) {
        try {
            open.Show()
            return
        }
    }
    d := WinNew("Packs de stuffs", "+OwnDialogs")
    open := d
    d.Add("Text", "x12 y12 w560", "Packs de stuffs prêts à l'emploi, publiés par ProToxEU. Choisis-en un pour l'importer (tu décides quoi garder et où le ranger).")
    lv := d.Add("ListView", "x12 y+10 w560 r9 NoSort -Multi", ["Pack", "Description", "Fichier"])
    lv.ModifyCol(1, 190)
    lv.ModifyCol(2, 360)
    lv.ModifyCol(3, 0)
    stT := d.Add("Text", "x12 y+8 w560", "Chargement de la liste...")
    btnImp := d.Add("Button", "x12 y+10 w200 Default", "Importer ce pack")
    btnRef := d.Add("Button", "x+8 yp w120", "Actualiser")
    btnX := d.Add("Button", "x+8 yp w100", "Fermer")
    btnAdm := ""
    if PackAdmin
        btnAdm := d.Add("Button", "x12 y+10 w300", "Publier un pack (administrateur)...")
    Refresh(*) {
        lv.Delete()
        rows := FetchPackIndex()
        if !IsObject(rows) {
            stT.Text := "Impossible de joindre GitHub. Vérifie ta connexion puis clique sur Actualiser."
            return
        }
        for r in rows
            lv.Add("", r[2], r[3], r[1])
        stT.Text := (rows.Length = 0) ? "Aucun pack publié pour le moment." : rows.Length " pack(s) disponible(s)."
    }
    ImportSel(*) {
        r := lv.GetNext(0)
        if !r {
            stT.Text := "Choisis d'abord un pack dans la liste."
            return
        }
        f := lv.GetText(r, 3)
        tmp := A_Temp "\cs2stuff_pack.stuffpack"
        txt := ""
        try {
            try FileDelete(tmp)
            Download(PackUrl(f), tmp)
            txt := FileRead(tmp, "UTF-8")
        } catch {
            stT.Text := "Téléchargement impossible. Réessaie plus tard."
            return
        }
        if ShowImport(txt, d.Hwnd)
            LoadMaps()
    }
    AdminAdd(*) {
        global PackRepoDir
        if (PackRepoDir = "" || !DirExist(PackRepoDir)) {
            pk := DirSelect("*" A_Desktop, 0, "Choisis ton dossier Git du menu (celui qui contient stuff_menu.ahk)")
            pk := RTrim(pk, "\")
            if (pk = "")
                return
            PackRepoDir := pk
            IniWrite(pk, IniFile, "Settings", "PackRepoDir")
        }
        f := FileSelect(3, A_Desktop, "Choisis le pack à publier (.stuffpack)", "Pack de stuffs (*.stuffpack)")
        if (f = "")
            return
        SplitPath(f, &fn, , , &base)
        safe := RegExReplace(fn, "[^\w\-\.]", "_")
        if !RegExMatch(safe, "i)\.stuffpack$")
            safe .= ".stuffpack"
        title := Trim(AskText("Titre du pack", "Titre affiché aux joueurs :", base, "ahk_id " d.Hwnd))
        if (title = "")
            return
        desc := Trim(AskText("Description", "Description courte (map, contenu...) :", "", "ahk_id " d.Hwnd))
        title := RegExReplace(title, "[|`r`n]", " ")
        desc := RegExReplace(desc, "[|`r`n]", " ")
        pdir := PackRepoDir "\packs"
        idx := pdir "\index.txt"
        try {
            DirCreate(pdir)
            FileCopy(f, pdir "\" safe, 1)
            old := FileExist(idx) ? FileRead(idx, "UTF-8") : "# Un pack par ligne : fichier.stuffpack | Titre | Description`n"
            out := ""
            for ln in StrSplit(old, "`n", "`r") {
                if (ln = "")
                    continue
                if (StrLower(StrSplit(ln, "|", " `t")[1]) = StrLower(safe))
                    continue
                out .= ln "`n"
            }
            out .= safe " | " title " | " desc "`n"
            try FileDelete(idx)
            FileAppend(out, idx, "UTF-8-RAW")
        } catch as err {
            MsgBox("Publication impossible : " err.Message, "Packs", 0x40010)
            return
        }
        MsgBox("Pack ajouté dans " pdir ".`n`nPour le publier, dans ce dossier :`ngit add .`ngit commit -m `"Pack " title "`"`ngit push", "Packs", 0x40040)
        Refresh()
    }
    Shut(*) {
        open := ""
        try d.Destroy()
    }
    btnImp.OnEvent("Click", ImportSel)
    lv.OnEvent("DoubleClick", ImportSel)
    btnRef.OnEvent("Click", Refresh)
    btnX.OnEvent("Click", Shut)
    if IsObject(btnAdm)
        btnAdm.OnEvent("Click", AdminAdd)
    d.OnEvent("Close", Shut)
    d.OnEvent("Escape", Shut)
    WinStyle(d)
    d.Show("AutoSize Center")
    Refresh()
}

; =====================================================================
;  Rapport de problème (aucune donnée personnelle : chemins et noms nettoyés)
; =====================================================================
ScrubPath(t) {
    return StrReplace(t, A_UserName, "UTILISATEUR")
}

BuildReport() {
    nl := "`r`n"
    r := "RAPPORT MENU STUF" nl
    r .= "Date : " FormatTime(, "yyyy-MM-dd HH:mm:ss") nl
    r .= "Version du menu : " APP_VERSION nl
    r .= "AutoHotkey : " A_AhkVersion "   Windows : " A_OSVersion (A_Is64bitOS ? " (64 bits)" : "") nl
    r .= "Profil actif : " curProfile nl
    r .= "Dossier du menu : " ScrubPath(A_ScriptDir) nl
    r .= "CS2 lancé : " (ProcessExist("cs2.exe") ? "oui" : "non") "   Connexion directe (port " NetconPort ") : " (NetOpen() ? "oui" : "non") nl
    r .= "Map automatique : " AutoMap nl
    r .= nl "--- Vérification de l'installation ---" nl
    try {
        for x in Check1()
            r .= "[" x[1] "] " ScrubPath(x[2]) nl
    }
    r .= nl "--- Réglages (sans chemins) ---" nl
    try {
        for ln in StrSplit(IniRead(IniFile, "Settings"), "`n", "`r") {
            if (ln = "" || RegExMatch(ln, "i)^(CfgPath|ConsoleLog|PackRepoDir)="))
                continue
            r .= ScrubPath(ln) nl
        }
    }
    r .= nl "--- Données ---" nl
    for pn in ListProfiles() {
        n := 0
        mdir := ProfMaps(pn)
        Loop Files mdir "\de_*.txt"
            n += 1
        r .= "Profil " pn " : " n " fichier(s) de map" nl
    }
    r .= "Ancienne version disponible : " (RollbackFile() != "" ? "oui" : "non") nl
    lf := A_ScriptDir "\data\menu_errors.log"
    r .= nl "--- Dernières erreurs du menu ---" nl
    try {
        if FileExist(lf) {
            lines := StrSplit(FileRead(lf, "UTF-8"), "`n", "`r")
            i0 := Max(1, lines.Length - 12)
            Loop lines.Length - i0 + 1 {
                if (lines[i0 + A_Index - 1] != "")
                    r .= ScrubPath(lines[i0 + A_Index - 1]) nl
            }
        } else {
            r .= "(aucune)" nl
        }
    }
    r .= nl "--- Extraits de console.log (erreurs et commandes du menu) ---" nl
    try {
        if FileExist(ConsoleLog) {
            fo := FileOpen(ConsoleLog, "r", "UTF-8")
            fo.Seek(Max(0, fo.Length - 80000))
            tail := fo.Read()
            fo.Close()
            got := []
            for ln in StrSplit(tail, "`n", "`r") {
                if RegExMatch(ln, "i)unknown command|error|failed|netcon|sv_throw|threw|sv_rethrow")
                    got.Push(ScrubPath(SubStr(ln, 1, 200)))
            }
            j0 := Max(1, got.Length - 15)
            if (got.Length = 0)
                r .= "(rien à signaler)" nl
            Loop got.Length - j0 + 1 {
                if (got.Length > 0)
                    r .= got[j0 + A_Index - 1] nl
            }
        } else {
            r .= "(console.log absent)" nl
        }
    }
    return r
}

ShowReport() {
    static open := ""
    if IsObject(open) {
        try {
            open.Show()
            return
        }
    }
    txt := BuildReport()
    d := WinNew("Signaler un problème", "+OwnDialogs")
    open := d
    d.Add("Text", "x12 y12 w640", "Voici ce qui sera envoyé : version, état de l'installation, réglages et dernières erreurs. Aucun chemin personnel, aucun nom de joueur.")
    ed := d.Add("Edit", "x12 y+8 w640 r18 ReadOnly +VScroll", txt)
    stT := d.Add("Text", "x12 y+8 w640", "")
    btnCp := d.Add("Button", "x12 y+8 w200 Default", "Copier le rapport")
    btnSv := d.Add("Button", "x+8 yp w230", "Enregistrer et ouvrir le dossier")
    btnX := d.Add("Button", "x+8 yp w100", "Fermer")
    CopyRep(*) {
        A_Clipboard := txt
        stT.Text := "Rapport copié : colle-le dans ton message à ProToxEU."
    }
    SaveRep(*) {
        DirCreate(A_ScriptDir "\data")
        f := A_ScriptDir "\data\rapport_" FormatTime(, "yyyy-MM-dd_HHmmss") ".txt"
        try {
            FileAppend(txt, f, "UTF-8")
            Run('explorer /select,"' f '"')
            stT.Text := "Rapport enregistré : envoie ce fichier à ProToxEU."
        } catch as err {
            stT.Text := "Enregistrement impossible : " err.Message
        }
    }
    Shut(*) {
        open := ""
        try d.Destroy()
    }
    btnCp.OnEvent("Click", CopyRep)
    btnSv.OnEvent("Click", SaveRep)
    btnX.OnEvent("Click", Shut)
    d.OnEvent("Close", Shut)
    d.OnEvent("Escape", Shut)
    WinStyle(d)
    d.Show("AutoSize Center")
}

; =====================================================================
;  Mise à jour automatique (depuis GitHub)
; =====================================================================
; Compare le fichier VERSION du dépôt avec APP_VERSION. Si une version plus récente existe et que
; tu acceptes, télécharge l'archive et remplace seulement les fichiers du programme.
; maps\, data\, profiles\ et config.ini ne sont jamais touchés.
CheckUpdate() {
    remote := RemoteVersion()
    if (remote = "" || VerCompare(remote, APP_VERSION) <= 0)
        return
    if (remote = IniRead(IniFile, "State", "SkipUpdate", ""))
        return   ; version abandonnée après un retour à la précédente : proposée seulement depuis le launcher
    msg := "Une nouvelle version est disponible : " remote " (tu as la " APP_VERSION ").`n`n"
    msg .= "Mettre à jour maintenant ?`nTes stuffs, favoris, profils et réglages ne sont pas touchés."
    ans := MsgBox(msg, "Mise à jour du menu", 0x40024)
    if (ans = "Yes")
        InstallUpdate()
}

InstallUpdate() {
    base := A_Temp "\cs2stuff_update"
    try DirDelete(base, true)
    DirCreate(base)
    zip := base "\u.zip"
    q := "'"
    dq := Chr(34)
    try {
        Download("https://github.com/" UPDATE_REPO "/archive/refs/heads/main.zip", zip)
        cmd := "powershell -NoProfile -ExecutionPolicy Bypass -Command " dq "Expand-Archive -LiteralPath " q zip q " -DestinationPath " q base "\x" q " -Force" dq
        RunWait(cmd, , "Hide")
    } catch as err {
        MsgBox("Téléchargement impossible : " err.Message "`n`nRien n'a été modifié.", "Mise à jour du menu", 0x40010)
        return
    }
    src := ""
    Loop Files base "\x\*", "D" {
        src := A_LoopFileFullPath
        break
    }
    if (src = "" || !FileExist(src "\stuff_menu.ahk") || !FileExist(src "\VERSION")) {
        MsgBox("L'archive téléchargée est invalide.`n`nRien n'a été modifié.", "Mise à jour du menu", 0x40010)
        return
    }
    DirCreate(A_ScriptDir "\data\backup")
    try FileCopy(A_ScriptFullPath, A_ScriptDir "\data\backup\stuff_menu.ahk.bak", 1)
    PreUpdateBackup()
    try {
        for fn in ["stuff_menu.ahk", "README.md", "CHANGELOG.md", "LICENSE", "config.example.ini", "cs2_practice.cfg", "VERSION", "update.bat", "update.ps1", "menu_stuf.ico", "install.bat", "install.ps1", "uninstall.bat", "uninstall.ps1", "rollback.bat"] {
            if FileExist(src "\" fn)
                FileCopy(src "\" fn, A_ScriptDir "\" fn, 1)
        }
        if DirExist(src "\maps_default") {
            DirCreate(A_ScriptDir "\maps_default")
            Loop Files src "\maps_default\*.txt"
                FileCopy(A_LoopFileFullPath, A_ScriptDir "\maps_default\" A_LoopFileName, 1)
        }
    } catch as err {
        try FileCopy(A_ScriptDir "\data\backup\stuff_menu.ahk.bak", A_ScriptDir "\stuff_menu.ahk", 1)
        MsgBox("La mise à jour a échoué : " err.Message "`n`nL'ancien script a été restauré.", "Mise à jour du menu", 0x40010)
        return
    }
    MsgBox("Mise à jour terminée. Le menu va redémarrer.", "Mise à jour du menu", 0x40040)
    try IniDelete(IniFile, "State", "SkipUpdate")
    IniWrite(1, IniFile, "State", "SkipCheck")
    Reload()
}

; =====================================================================
;  Raccourcis (actifs uniquement dans CS2)
; =====================================================================
InGame(*) => WinActive("ahk_exe cs2.exe")
MenuActive(*) => menuOpen && WinActive("ahk_exe cs2.exe")

; Une touche invalide dans config.ini ne doit pas empêcher le script de démarrer
SafeHotkey(key, fn) {
    try {
        Hotkey(key, fn)
    } catch {
        MsgBox("La touche « " key " » de config.ini n'est pas valide : elle est ignorée.`n`nCorrige-la dans config.ini (syntaxe AutoHotkey : F1, Insert, XButton1...) puis relance le script.", "Menu Stuf", 0x40030)
    }
}

HotIf(InGame)
SafeHotkey(MenuKey, (*) => Toggle())
Hotkey("~LButton Up", (*) => TmClick())   ; chronomètre : moment où la grenade est lâchée
if (RethrowKey != "")
    SafeHotkey("~" RethrowKey, (*) => TmRethrow())   ; chronomètre : relance avec la touche de sv_rethrow_last_grenade

HotIf(MenuActive)
Hotkey("Up", (*) => Move(-1))
Hotkey("Down", (*) => Move(1))
Hotkey("Right", (*) => Select())
Hotkey("Enter", (*) => Select())
Hotkey("NumpadEnter", (*) => Select())
Hotkey("Left", (*) => Back())
Hotkey("Backspace", (*) => BackspaceKey())
Hotkey("Esc", (*) => EscKey())
Hotkey("Tab", (*) => TabKey())
SafeHotkey(FavKey, (*) => ToggleFav())
SafeHotkey(LockKey, (*) => LockPress())
SafeHotkey(AddKey, (*) => NewStuffPress())
Hotkey("^z", (*) => UndoPress())
HotIf()

; console.log trop gros : on le vide quand CS2 est fermé (le jeu le recrée)
if (LogMaxMB > 0 && FileExist(ConsoleLog) && !ProcessExist("cs2.exe")) {
    try {
        if (FileGetSize(ConsoleLog) > LogMaxMB * 1048576)
            FileDelete(ConsoleLog)
    }
}

; Le menu doit être lancé AVANT CS2 : c'est lui qui démarre le jeu avec la connexion directe (seul moyen d'envoyer les commandes)
newsUnseen := (LauncherOn && ShowChangelogOn && IniRead(IniFile, "State", "LastSeenVersion", "") != APP_VERSION)
TraySetup()
if (IniRead(IniFile, "State", "SkipCheck", "0") != "1") {
    if LauncherOn
        OpenLauncher()
    else
        LaunchFlow()
}
else if LauncherOn {
    OpenLauncher()   ; après un redémarrage du menu (mise à jour, retour arrière, changement de touche) : le launcher se rouvre, sans relancer le jeu
}
CleanLegacy()
if HudAtStart
    HudToggle()
TmApply()
; Après une mise à jour : fenêtre des nouveautés (première installation : la dernière version seulement)
lastSeen := IniRead(IniFile, "State", "LastSeenVersion", "")
if (lastSeen != APP_VERSION) {
    IniWrite(APP_VERSION, IniFile, "State", "LastSeenVersion")
    if (lastSeen != "" && VerCompare(APP_VERSION, lastSeen) > 0 && RollbackFile() != "") {
        ; période d'essai après une mise à jour : deux erreurs et le menu propose de revenir à la version précédente
        IniWrite(lastSeen, IniFile, "State", "PrevVersion")
        IniWrite(1, IniFile, "State", "UpdateTrial")
        IniWrite(0, IniFile, "State", "TrialErrors")
    }
    if (ShowChangelogOn && !LauncherOn)
        ShowNews(lastSeen, (lastSeen = "") ? 1 : 8)
}
if (IniRead(IniFile, "State", "UpdateTrial", "0") = "1") {
    SetTimer(EndTrial, -600000)
    if (ToInt(IniRead(IniFile, "State", "TrialErrors", "0"), 0) >= 2)
        SetTimer(() => RollbackUpdate(true), -4000)
}
if AutoBackupOn
    SetTimer(AutoBackup, -2500)
skipCheck := (IniRead(IniFile, "State", "SkipCheck", "0") = "1")
if skipCheck
    IniWrite(0, IniFile, "State", "SkipCheck")
if (AutoCheck && !skipCheck && !LauncherOn)
    SetTimer(StartCheck, -1500)
if AutoUpdate
    SetTimer(CheckUpdate, -4000)
