#Requires AutoHotkey v2.0
#SingleInstance Force

; =====================================================================
;  CS2 STUFF MENU - overlay navigable pour s'entraîner en local
;  Config : config.ini   |   Stuffs : dossier maps\ (un .txt par map)
;  Données perso (favoris, récents) : dossier data\
; =====================================================================

APP_VERSION := "2.12.1"   ; à garder identique au fichier VERSION du dépôt
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
ShotOn := (IniRead(IniFile, "Settings", "Shot", "1") = "1")                         ; captures d'écran des stuffs
ShotSize := Max(40, Min(300, ToInt(IniRead(IniFile, "Settings", "ShotSize", "100"), 100)))   ; zone capturée (px)
ShotZoom := Max(60, Min(500, ToInt(IniRead(IniFile, "Settings", "ShotZoom", "160"), 160)))   ; taille d'affichage (px)
ShotPlace := Max(1, Min(2, ToInt(IniRead(IniFile, "Settings", "ShotPos", "1"), 1)))   ; 1 = coin supérieur droit, 2 = position libre
ShotCorner := Max(0, Min(30, ToInt(IniRead(IniFile, "Settings", "ShotCorner", "3"), 3)))   ; arrondi des coins de la capture (px)
ShotX := ToInt(IniRead(IniFile, "Settings", "ShotX", "520"), 520)
ShotY := ToInt(IniRead(IniFile, "Settings", "ShotY", "100"), 100)
PracticeCfg := IniRead(IniFile, "Settings", "PracticeCfg", "cs2_practice")
AutoExec := (IniRead(IniFile, "Settings", "AutoExec", "1") = "1")
ConsoleKey := IniRead(IniFile, "Settings", "ConsoleKey", "")
; Touches que le script « appuie » lui-même pour parler à CS2 (choisies par l'utilisateur au premier lancement)
; [nom AutoHotkey, nom CS2, libellé]
KEYTAB := [
    ["NumpadMult", "kp_multiply", "* du pavé numérique"],
    ["NumpadDiv", "kp_slash", "/ du pavé numérique"],
    ["NumpadSub", "kp_minus", "- du pavé numérique"],
    ["NumpadAdd", "kp_plus", "+ du pavé numérique"],
    ["ScrollLock", "scrolllock", "Arrêt défil (Scroll Lock)"],
    ["Pause", "pause", "Pause"],
    ["Insert", "ins", "Inser (Insert)"],
    ["Delete", "del", "Suppr (Delete)"],
    ["Home", "home", "Début (Home)"],
    ["End", "end", "Fin (End)"],
    ["PgUp", "pgup", "Page précédente"],
    ["PgDn", "pgdn", "Page suivante"]
]
ExecKey := KeyOk(IniRead(IniFile, "Settings", "ExecKey", "NumpadMult"), "NumpadMult")
HudKey := KeyOk(IniRead(IniFile, "Settings", "HudKey", "NumpadDiv"), "NumpadDiv")
if (StrLower(ExecKey) = StrLower(HudKey))
    HudKey := (StrLower(ExecKey) = "numpaddiv") ? "NumpadSub" : "NumpadDiv"
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
    try {
        FileCopy(practiceSrc, practiceDst)
        practiceCopied := true
    }
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
hudBound := false   ; la touche des coordonnées est liée dans le jeu
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
        info := (p.Length >= 4) ? p[4] : ""
        items[c].Push([p[2], p[3], info, c, mapName "|" c "|" p[2], path])
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
    try FileDelete(CfgPath)
    FileAppend(cmd "`n", CfgPath, "UTF-8-RAW")
    Sleep(30)
    Send("{" ExecKey " down}")
    Sleep(40)
    Send("{" ExecKey " up}")
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
    if !FileExist(ConsoleLog)
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
    k := m[1] "_" m[2] "_" m[3]
    k := StrReplace(StrReplace(k, "-", "m"), ".", "p")
    return ShotDir(prof) "\" mapName "_" k ".bmp"
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

; Affiche (ou cache) la capture du stuff sélectionné. preview = true : aperçu depuis les réglages F10
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
MainLabels() {
    return ["Stuffs (maps et catégories)", "Utilitaires (bots, god mode, noclip...)", "Relancer le dernier stuff", "Sauvegarder la position actuelle", "Gérer les stuffs et les catégories", "Profils et partage de stuffs", "Réglages du menu", "Relancer l'exec de " PracticeCfg, "Vérifier l'installation", "Fermer"]
}

MainSelect() {
    global level
    i := mainIdx
    if (i = 1) {
        OpenStuffs()
        return
    }
    if (i = 2) {
        OpenUtil()
        return
    }
    CloseMenu()
    if (i = 10)
        return
    Sleep(60)
    if (i = 3)
        RepeatLast()
    else if (i = 4)
        ShowSaveDialog()
    else if (i = 5)
        ShowManager()
    else if (i = 6)
        ShowShare()
    else if (i = 7)
        ShowSettings()
    else if (i = 8)
        ForceExec()
    else if (i = 9)
        SetTimer(StartCheck, -50)
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
    infoCtl.Text := (IsObject(cur) && cur[3] != "") ? "Info : " cur[3] : ""
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
        mainIdx := Mod(mainIdx - 1 + d + n, n) + 1
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
            hay := it[4] " " it[1] " " it[3]
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

ShowSaveDialog(presetCat := "", presetMap := "") {
    global dlgOpen
    if dlgOpen
        return
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
    if (ShotOn && WinActive("ahk_exe cs2.exe")) {
        Sleep(100)
        shotPending := CaptureShot(tmpShot)
    }

    ; Position + map actuelles (via console.log)
    posCaptured := ""
    detected := ""
    if FileExist(ConsoleLog) {
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
    d := Gui("+AlwaysOnTop", "Sauvegarder un repère")
    d.SetFont("s10", "Segoe UI")
    d.Add("Text", "xm w95", "Map")
    ddMap := d.Add("DropDownList", "x110 yp-3 w340 Choose" mapSel, mapNames)
    d.Add("Text", "xm y+14 w95", "Type")
    ddType := d.Add("DropDownList", "x110 yp-3 w340 Choose1", Types)
    d.Add("Text", "xm y+14 w95", "Catégorie")
    cbCat := d.Add("ComboBox", "x110 yp-3 w340", [])
    d.Add("Text", "xm y+14 w95", "Nom")
    edName := d.Add("Edit", "x110 yp-3 w340")
    d.Add("Text", "xm y+14 w95", "Info chat")
    edInfo := d.Add("Edit", "x110 yp-3 w340 r3")
    d.Add("Text", "xm y+14 w95", "Position")
    edPos := d.Add("Edit", "x110 yp-3 w340 r2", posCaptured)
    if (posCaptured = "")
        d.Add("Text", "xm y+8 w450 cC0392B", "Position non capturée : lance le jeu avec -condebug, ou colle ici la sortie de getpos.")
    if shotPending {
        d.Add("Text", "xm y+14 w95", "Capture")
        d.Add("Picture", "x110 yp-3 w" ShotSize " h" ShotSize, tmpShot)
        chkDy := ShotSize // 2 - 10
        chkShot := d.Add("CheckBox", "x+14 yp+" chkDy " Checked", "Joindre cette capture au stuff")
    }
    chkGive := d.Add("CheckBox", "xm y+14 Checked", "Donner la grenade du type choisi (give)")
    chkFav := d.Add("CheckBox", "xm y+6", "Ajouter aux favoris")
    btnSave := d.Add("Button", "xm y+14 w170", "Enregistrer")
    btnCancel := d.Add("Button", "x+10 yp w170", "Annuler")

    FillCats(*) {
        fcTxt := cbCat.Text
        cbCat.Delete()
        fcLst := AllCategories(mapFiles[ddMap.Value])
        if (fcLst.Length > 0)
            cbCat.Add(fcLst)
        cbCat.Text := fcTxt
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
                ddType.Choose(ccType)
                return
            }
        }
    }

    CatChange(*) {
        SetTimer(CatSync, -30)
    }

    CloseDlg(*) {
        global dlgOpen
        dlgOpen := false
        d.Destroy()
        try FileDelete(tmpShot)
        WinActivate("ahk_exe cs2.exe")
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
        if (sub = "") {
            if (typ = NO_TYPE) {
                MsgBox("Choisis ou tape une catégorie.", "Sauvegarde", 0x40030)
                return
            }
            catFull := typ
        } else {
            catFull := ""
            for scC in AllCategories(mapFiles[ddMap.Value]) {
                if (scC = sub) {
                    catFull := scC
                    break
                }
            }
            if (catFull = "")
                catFull := (typ = NO_TYPE) ? sub : typ " - " sub
        }
        cmdFull := pnorm
        if chkGive.Value {
            gv := GiveMap.Get(typ, "")
            if (gv != "")
                cmdFull .= "; give " gv
        }
        inf := CleanInfo(edInfo.Value)
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
    ddMap.OnEvent("Change", FillCats)
    cbCat.OnEvent("Change", CatChange)
    btnSave.OnEvent("Click", SaveClick)
    btnCancel.OnEvent("Click", CloseDlg)
    d.OnEvent("Close", CloseDlg)
    d.OnEvent("Escape", CloseDlg)
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
    d := Gui("+AlwaysOnTop", title)
    d.SetFont("s10", "Segoe UI")
    d.Add("Text", "w340", prompt)
    ed := d.Add("Edit", "w340", defVal)
    btnOk := d.Add("Button", "Default w165", "OK")
    btnNo := d.Add("Button", "x+10 yp w165", "Annuler")
    Done(ok, *) {
        if ok
            res["v"] := ed.Value
        d.Destroy()
    }
    btnOk.OnEvent("Click", Done.Bind(true))
    btnNo.OnEvent("Click", Done.Bind(false))
    d.OnEvent("Close", Done.Bind(false))
    d.OnEvent("Escape", Done.Bind(false))
    d.Show("AutoSize Center")
    ed.Focus()
    hwnd := d.Hwnd
    WinWaitClose("ahk_id " hwnd)
    WinActivate(back)
    return res["v"]
}

; Touche AddKey : ouvre la fenêtre de création d'un nouveau stuff (catégorie courante pré-remplie)
NewStuffPress() {
    if (level = 4 || utilMode)
        return
    preset := ""
    pmap := ""
    if (level >= 1 && level <= 3 && loadedMap != "") {
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

; =====================================================================
;  Touches utilisées par le script pour parler à CS2 (ExecKey, HudKey)
; =====================================================================
; Nom AutoHotkey valide de la liste (sinon la valeur par défaut)
KeyOk(v, def) {
    for e in KEYTAB {
        if (StrLower(e[1]) = StrLower(Trim(v)))
            return e[1]
    }
    return def
}

; Nom CS2 (bind) d'une touche AutoHotkey de la liste
KeyBind(ahk) {
    for e in KEYTAB {
        if (StrLower(e[1]) = StrLower(ahk))
            return e[2]
    }
    return StrLower(ahk)
}

AddUsed(used, ours, key, cmd) {
    key := StrLower(Trim(key))
    cmd := Trim(cmd, ' "`t;')
    if (key = "" || cmd = "")
        return
    if RegExMatch(cmd, "i)exec\s+(stuff_run|hud_pos)") {
        ours[key] := cmd
        return
    }
    if !used.Has(key)
        used[key] := cmd
}

; Touches déjà liées dans la configuration de CS2 (touches enregistrées par le jeu + fichiers cfg).
; Renvoie Map(nom CS2 en minuscules -> commande). Les liaisons du script lui-même vont dans ours.
UsedBinds(&ours) {
    used := Map()
    ours := Map()
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
    ; 1) touches enregistrées par CS2 : Steam\userdata\<id>\730\local\cfg\cs2_user_keys*.vcfg
    for st in steams {
        try {
            Loop Files st "\userdata\*", "D" {
                ud := A_LoopFilePath
                Loop Files ud "\730\local\cfg\cs2_user_keys*.vcfg" {
                    try {
                        for ln in StrSplit(FileRead(A_LoopFilePath, "UTF-8"), "`n", "`r") {
                            if RegExMatch(ln, '^\s*"([^"]+)"\s+"([^"]*)"\s*$', &m)
                                AddUsed(used, ours, m[1], m[2])
                        }
                    }
                }
            }
        }
    }
    ; 2) lignes bind des fichiers cfg (autoexec.cfg...), hors fichiers du script
    try {
        Loop Files cfgDir "\*.cfg" {
            nm := StrLower(RegExReplace(A_LoopFileName, "\.cfg$"))
            if (nm = StrLower(PracticeCfg) || nm = "stuff_run" || nm = "hud_pos")
                continue
            try {
                txt := FileRead(A_LoopFilePath, "UTF-8")
            } catch {
                continue
            }
            for ln in StrSplit(txt, "`n", "`r") {
                if RegExMatch(ln, 'i)^\s*bind\s+"?([^"\s]+)"?\s+"?([^"]*)', &m)
                    AddUsed(used, ours, m[1], m[2])
            }
        }
    }
    return used
}

; Réécrit les liaisons du script dans cs2_practice.cfg (dossier cfg de CS2) avec les touches choisies
WritePracticeBinds(execBind, hudBind, ours) {
    f := cfgDir "\" PracticeCfg ".cfg"
    if !FileExist(f)
        return
    try {
        txt := FileRead(f, "UTF-8")
    } catch {
        return
    }
    out := []
    echoAt := 0
    for ln in StrSplit(txt, "`n", "`r") {
        if InStr(ln, "menu-stuf")
            continue
        if RegExMatch(ln, 'i)^\s*bind\s+"[^"]+"\s+"exec\s+(stuff_run|hud_pos)"\s*$')
            continue
        if RegExMatch(ln, "i)^\s*//\s*(-+\s*Liaison avec le menu|Ne pas modifier : cette touche|Coordonnées en temps réel \(le script)")
            continue
        out.Push(ln)
    }
    while (out.Length > 0 && Trim(out[out.Length]) = "")
        out.Pop()
    blk := ["", "// menu-stuf : liaison avec le script (touches choisies dans le menu, à ne pas modifier à la main)"]
    for k, c in ours {
        if (k != execBind && k != hudBind)
            blk.Push('unbind "' k '" // menu-stuf')
    }
    blk.Push('bind "' execBind '" "exec stuff_run" // menu-stuf')
    blk.Push('bind "' hudBind '" "exec hud_pos" // menu-stuf')
    ; insère le bloc avant la dernière ligne echo, sinon à la fin
    for i, ln in out {
        if RegExMatch(ln, "i)^\s*echo\s")
            echoAt := i
    }
    res := []
    for i, ln in out {
        if (i = echoAt) {
            for b in blk
                res.Push(b)
            res.Push("")
        }
        res.Push(ln)
    }
    if (echoAt = 0) {
        for b in blk
            res.Push(b)
    }
    ; pas de lignes vides en double (sinon le fichier grossirait à chaque réécriture)
    joined := ""
    prevBlank := false
    for ln in res {
        blank := (Trim(ln) = "")
        if (blank && prevBlank)
            continue
        joined .= ln "`n"
        prevBlank := blank
    }
    if (StrReplace(txt, "`r`n", "`n") = joined)
        return
    try FileDelete(f)
    FileAppend(joined, f, "UTF-8-RAW")
}

; Fenêtre de choix des 2 touches (stuffs et coordonnées). first = true au démarrage.
ShowKeyPicker(first := true) {
    global ExecKey, HudKey
    ours := Map()
    used := UsedBinds(&ours)
    scr := Map()
    for k in [MenuKey, FavKey, LockKey, AddKey]
        scr[StrLower(k)] := 1
    opts := []
    for e in KEYTAB {
        why := ""
        if scr.Has(StrLower(e[1]))
            why := "utilisée par le menu"
        else if used.Has(e[2])
            why := "déjà liée à : " used[e[2]]
        opts.Push([e[1], e[2], e[3], why])
    }
    sorted := []
    for o in opts {
        if (o[4] = "")
            sorted.Push(o)
    }
    for o in opts {
        if (o[4] != "")
            sorted.Push(o)
    }
    strs := []
    for o in sorted {
        suf := (o[4] = "") ? "   (libre)" : "   (" o[4] ")"
        strs.Push(o[3] suf)
    }
    PickIdx(pref, avoid) {
        for i, o in sorted {
            if (StrLower(o[1]) = StrLower(pref) && o[4] = "" && i != avoid)
                return i
        }
        for i, o in sorted {
            if (o[4] = "" && i != avoid)
                return i
        }
        return (avoid = 1) ? 2 : 1
    }
    i1 := PickIdx(ExecKey, 0)
    i2 := PickIdx(HudKey, i1)

    g := Gui("+AlwaysOnTop", "Menu Stuf - choix des touches")
    g.SetFont("s9", "Segoe UI")
    g.MarginX := 14
    g.MarginY := 12
    intro := "Pour parler à CS2, le menu appuie lui-même sur 2 touches du clavier (tu n'as jamais à les utiliser). Choisis 2 touches que tu n'utilises jamais, ni dans CS2, ni dans un autre logiciel.`n`nSi une touche est déjà utilisée, des armes peuvent changer toutes seules ou le menu peut ne pas fonctionner. Les touches « libres » ne sont liées à rien dans ta configuration CS2 : garde-en de préférence une de celles-là."
    g.Add("Text", "w440", intro)
    g.Add("Text", "xm y+14 w440", "Touche pour lancer les stuffs et les utilitaires :")
    d1 := g.Add("DropDownList", "xm w440 Choose" i1, strs)
    g.Add("Text", "xm y+12 w440", "Touche pour les coordonnées en temps réel :")
    d2 := g.Add("DropDownList", "xm w440 Choose" i2, strs)
    g.SetFont("s8 c8A8F96")
    g.Add("Text", "xm y+10 w440", "Vérifie aussi que Discord, un logiciel de clavier ou de souris (Razer, Logitech, Corsair...) n'utilise pas ces touches. Tu pourras les changer plus tard : réglages du menu, bouton « Touches du script ».")
    g.SetFont("s9 cDefault")
    okBtn := g.Add("Button", "xm y+14 w150 Default", "Valider")
    noBtn := g.Add("Button", "x+8 yp w150", first ? "Plus tard" : "Annuler")
    okFn(*) {
        a := sorted[d1.Value]
        b := sorted[d2.Value]
        if (a[1] = b[1]) {
            MsgBox("Choisis deux touches différentes.", "Menu Stuf", 0x40030)
            return
        }
        warn := ""
        if (a[4] != "")
            warn .= a[3] " : " a[4] "`n"
        if (b[4] != "")
            warn .= b[3] " : " b[4] "`n"
        if (warn != "") {
            if (MsgBox("Attention :`n`n" warn "`nCette touche risque de déclencher autre chose pendant le jeu. La garder quand même ?", "Menu Stuf", 0x40134) != "Yes")
                return
        }
        g.Destroy()
        ApplyKeys(a, b, ours)
    }
    okBtn.OnEvent("Click", okFn)
    noBtn.OnEvent("Click", (*) => g.Destroy())
    g.OnEvent("Close", (*) => g.Destroy())
    g.OnEvent("Escape", (*) => g.Destroy())
    g.Show()
    try WinWaitClose("ahk_id " g.Hwnd)
}

ApplyKeys(a, b, ours) {
    global ExecKey, HudKey, hudBound
    IniWrite(a[1], IniFile, "Settings", "ExecKey")
    IniWrite(b[1], IniFile, "Settings", "HudKey")
    IniWrite("1", IniFile, "State", "BindsV")
    changed := (StrLower(a[1]) != StrLower(ExecKey) || StrLower(b[1]) != StrLower(HudKey))
    WritePracticeBinds(a[2], b[2], ours)
    ; si CS2 tourne, on réapplique tout de suite avec l'ancienne touche (si elle est encore liée dans le jeu)
    sent := false
    if (changed && WinExist("ahk_exe cs2.exe")) {
        try {
            WinActivate("ahk_exe cs2.exe")
            if WinWaitActive("ahk_exe cs2.exe", , 2) {
                Sleep(300)
                WriteAndExec("exec " PracticeCfg)
                sent := true
            }
        }
    }
    ExecKey := a[1]
    HudKey := b[1]
    hudBound := false
    txt := "Touches enregistrées :`n`n  Stuffs et utilitaires : " a[3] "`n  Coordonnées : " b[3] "`n`n"
    if sent
        txt .= "Le cfg a été relancé dans CS2. Si les stuffs ne se lancent pas, tape quand même exec " PracticeCfg " dans la console du jeu."
    else
        txt .= "Dans CS2, tape exec " PracticeCfg " dans la console (une seule fois, à chaque lancement du jeu) pour activer ces touches."
    MsgBox(txt, "Menu Stuf - touches", 0x40040)
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
    old := Map("Font", ovFont, "Scale", ovScale, "X", ovX, "Y", ovY, "Opacity", ovOpacity, "Bg", ovBg, "Theme", ovTheme, "Border", ovBorder, "Corner", ovCorner, "BorderCol", ovBorderCol, "ShotOn", ShotOn, "ShotSize", ShotSize, "ShotZoom", ShotZoom, "ShotPlace", ShotPlace, "ShotCorner", ShotCorner, "ShotX", ShotX, "ShotY", ShotY, "Hud", hudOn, "HudAuto", HudAuto, "HudX", HudX, "HudY", HudY)
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

    d := Gui("+AlwaysOnTop", "Réglages du menu")
    d.SetFont("s10", "Segoe UI")
    tabs := d.Add("Tab3", "x6 y6 w500 h700", ["Menu", "Captures", "Coordonnées"])
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
    y += 40
    ty := y + 4
    d.Add("Text", "x22 y" ty " w110", "Opacité")
    slOp := d.Add("Slider", "x140 y" y " w260 Range80-255 ToolTip", ovOpacity)
    txOp := d.Add("Text", "x406 y" ty " w70", "")
    y += 46
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
    yEnd1 := y

    ; ----- Onglet Captures -----
    tabs.UseTab(2)
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
    y += 46
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "x22 y" y " w460 r4", "Le liseré de la capture (épaisseur et couleur) suit automatiquement celui du menu (onglet Menu) et se dessine par-dessus l'image. La zone capturée s'applique aux prochaines captures. Pour refaire la capture d'un stuff : F11, modifier le stuff, bouton « Refaire la capture ».")
    d.SetFont("s10 cDefault")
    y += 80
    yEnd2 := y

    ; ----- Onglet Coordonnées -----
    tabs.UseTab(3)
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
    y += 46
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "x22 y" y " w460 r8", "Affiche la map, ta position (X, Y, Z) et ton angle de vue dans le coin inférieur gauche de l'écran.`n`nSi tu l'actives puis cliques sur Enregistrer, il reste activé à chaque lancement du script, jusqu'à ce que tu le désactives ici.`n`nAttention : le script envoie une touche (celle choisie pour les coordonnées) à chaque mise à jour, avec son propre fichier : il ne gêne plus les stuffs. Désactive quand même l'affichage avant d'ouvrir la console ou le chat, sinon le caractère / s'y écrit.")
    d.SetFont("s10 cDefault")
    y += 150
    yEnd3 := y
    tabs.UseTab(0)
    tabH := Max(yEnd1, yEnd2, yEnd3) + 6
    tabs.Move(6, 6, 500, tabH)
    y := tabH + 18
    btnSave := d.Add("Button", "x12 y" y " w150 Default", "Enregistrer")
    btnReset := d.Add("Button", "x+8 yp w150", "Réinitialiser")
    btnCancel := d.Add("Button", "x+8 yp w150", "Annuler")
    btnChkS := d.Add("Button", "x12 y+10 w227", "Vérifier l'installation")
    btnKeys := d.Add("Button", "x+8 yp w227", "Touches du script...")

    Sync(*) {
        global ovFont, ovScale, ovX, ovY, ovOpacity, ovBg, ovBorder, ovCorner, ShotOn, ShotSize, ShotZoom, ShotPlace, ShotCorner, ShotX, ShotY, HudAuto, HudX, HudY
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
        global ovTheme
        ovTheme := ""
        ddTheme.Choose(1)
        ddFont.Choose(1)
        slScale.Value := 100
        slX.Value := Max(0, Min(30 - vl, xr))
        slY.Value := Max(0, Min(100 - vt, yr))
        slOp.Value := 225
        slR.Value := 20
        slG.Value := 24
        slB.Value := 29
        ddPreset.Choose(2)
        slBw.Value := 2
        slCr.Value := 14
        ddBc.Choose(1)
        edBc.Text := ""
        ovBorderCol := ""
        chkHud.Value := 0
        ddHudPos.Choose(1)
        slHudX.Value := Max(0, Min(12 - vl, xr))
        slHudY.Value := Max(0, Min(900 - vt, yr))
        chkShotOn.Value := 1
        slShotSz.Value := 100
        slShotZm.Value := 160
        slShotCr.Value := 3
        ddShotPos.Choose(1)
        slShotX.Value := Max(0, Min(520 - vl, xr))
        slShotY.Value := Max(0, Min(100 - vt, yr))
        Sync()
    }

    Finish(save, *) {
        global setOpen, ovFont, ovScale, ovX, ovY, ovOpacity, ovBg, ovTheme, ovBorder, ovCorner, ovBorderCol, ShotOn, ShotSize, ShotZoom, ShotPlace, ShotCorner, ShotX, ShotY, HudAuto, HudX, HudY
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
            HudSet(old["Hud"])
            if hudOn {
                BuildHud()
                ShowHud()
            }
        }
        setOpen := false
        d.Destroy()
        BuildOverlay()
        if menuOpen
            Render()
        WinActivate("ahk_exe cs2.exe")
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
    btnKeys.OnEvent("Click", (*) => ShowKeyPicker(false))
    btnCancel.OnEvent("Click", Finish.Bind(false))
    d.OnEvent("Close", Finish.Bind(false))
    d.OnEvent("Escape", Finish.Bind(false))
    d.Show("AutoSize x" Max(0, A_ScreenWidth - 520) " y60")
    Sync()
}

; =====================================================================
;  Exec automatique du cfg d'entraînement
; =====================================================================
; Exécute cs2_practice dans le jeu.
;  - ConsoleKey vide : passe par la touche liée (ExecKey -> exec stuff_run).
;    Il faut avoir lancé "exec cs2_practice" une fois à la main pour créer cette touche.
;  - ConsoleKey renseignée : ouvre la console, tape la commande et la referme.
RunPractice() {
    if (ConsoleKey != "") {
        Send(ConsoleKey)
        Sleep(300)
        SendText("exec " PracticeCfg)
        Sleep(60)
        Send("{Enter}")
        Sleep(200)
        Send(ConsoleKey)
        Sleep(300)
    } else {
        WriteAndExec("exec " PracticeCfg)
        Sleep(400)
    }
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
;  Gestion des stuffs et des catégories (fenêtre F11)
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
        if (p[1] != "@cat" && p.Length >= 3 && p[1] = cat && p[2] = name)
            return BuildLine(cat, name, p[3], info)
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

    d := Gui("+AlwaysOnTop", "Gestion des stuffs et des catégories")
    d.SetFont("s10", "Segoe UI")
    d.Add("Text", "x12 y16 w50", "Map")
    ddMap := d.Add("DropDownList", "x64 y12 w320 Choose" selMap, labels)
    d.Add("Text", "x12 y54 w260", "Catégories")
    d.Add("Text", "x290 y54 w300", "Stuffs de la catégorie")
    lvCat := d.Add("ListView", "x12 y78 w260 r14 -Multi", ["Catégorie", "Stuffs", "Cad."])
    lvSt := d.Add("ListView", "x290 y78 w470 r14", ["Nom", "Cad.", "Info"])
    lvCat.ModifyCol(1, 140)
    lvCat.ModifyCol(2, 50)
    lvCat.ModifyCol(3, 45)
    lvSt.ModifyCol(1, 190)
    lvSt.ModifyCol(2, 45)
    lvSt.ModifyCol(3, 215)
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
    d.Add("Text", "x290 y" row2t " w100", "Déplacer vers")
    cbDest := d.Add("ComboBox", "x395 y" row2 " w230", [])
    btnMove := d.Add("Button", "x+8 yp-1 w125 Default", "Déplacer")
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "x12 y" note " w748 r3", "Double-clique sur un stuff (ou « Modifier… ») pour tout changer : type, catégorie, nom, coordonnées, commandes, info. Supprimer une catégorie garde ses stuffs : ils sont déplacés dans « " FALLBACK_CAT " ». Sélectionne plusieurs stuffs avec Ctrl ou Maj. Un élément verrouillé ne peut être ni supprimé, ni renommé, ni déplacé.")
    d.SetFont("s10 c1B6E1B")
    stText := d.Add("Text", "x12 y" status " w748", "")
    d.SetFont("s10 cDefault")
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
        for ent in ReadEntries(MapPath())[2] {
            if (ent[1] = cc)
                lvSt.Add("", ent[2], locks.Has("it|" StuffKey(cc, ent[2])) ? LOCK_ICON : "", ent[4])
        }
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
        for cn in ReadEntries(MapPath())[1] {
            if (cn = nm) {
                Say("Cette catégorie existe déjà")
                return
            }
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
                cur := ent[4]
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
        if (dest == sc) {
            Say("Ces stuffs sont déjà dans cette catégorie")
            return
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
        d.Destroy()
        WinActivate("ahk_exe cs2.exe")
    }

    ddMap.OnEvent("Change", (*) => RefreshCats(""))
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
    d.Show("AutoSize Center")
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

    d := Gui("+AlwaysOnTop", "Modifier le stuff")
    d.SetFont("s10", "Segoe UI")
    d.Add("Text", "xm w110", "Type")
    ddType := d.Add("DropDownList", "x130 yp-3 w380 Choose1", Types)
    d.Add("Text", "xm y+14 w110", "Catégorie")
    cbCat := d.Add("ComboBox", "x130 yp-3 w380", [])
    d.Add("Text", "xm y+14 w110", "Nom")
    edName := d.Add("Edit", "x130 yp-3 w380", oldName)
    d.Add("Text", "xm y+14 w110", "Info chat")
    edInfo := d.Add("Edit", "x130 yp-3 w380 r3", ent[4])
    d.Add("Text", "xm y+14 w110", "Position")
    edPos := d.Add("Edit", "x130 yp-3 w380 r2", posTxt)
    btnRecap := d.Add("Button", "x130 y+6 w380", "Recapturer ma position actuelle (en jeu)")
    d.Add("Text", "xm y+14 w110", "Autres commandes")
    edOthers := d.Add("Edit", "x130 yp-3 w380 r2", others)
    d.SetFont("s9 c8A8F96")
    d.Add("Text", "xm y+6 w500", "Exemples : give weapon_smokegrenade ou sv_rethrow_last_grenade. Sépare les commandes par un point-virgule.")
    d.SetFont("s10 cDefault")
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
    btnSave := d.Add("Button", "xm y+14 w180 Default", "Enregistrer")
    btnCancel := d.Add("Button", "x+10 yp w180", "Annuler")

    for ec in AllCategories(path)
        cbCat.Add([ec])
    ddType.Choose(typeSel)
    cbCat.Text := oldCat

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
        WinActivate("ahk_exe cs2.exe")
        WinWaitActive("ahk_exe cs2.exe", , 2)
        Sleep(250)
        np := CapturePos()
        WinActivate("ahk_id " d.Hwnd)
        if (np = "")
            MsgBox("Position non capturée. Vérifie que tu es en jeu et que -condebug est actif.", "Modifier", 0x40030)
        else
            edPos.Value := np
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
        ReplaceStuffInFile(path, oldCat, oldName, nCat, nName, nCmd, CleanInfo(edInfo.Value))
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
        WinActivate("ahk_exe cs2.exe")
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

    btnShotNew.OnEvent("Click", ShotRedoClick)
    btnShotDel.OnEvent("Click", ShotDelClick)
    cbCat.OnEvent("Change", CatChange)
    ddType.OnEvent("Change", TypeChange)
    btnRecap.OnEvent("Click", Recap)
    btnSave.OnEvent("Click", SaveClick)
    btnCancel.OnEvent("Click", CancelClick)
    d.OnEvent("Close", CancelClick)
    d.OnEvent("Escape", CancelClick)
    d.Show("AutoSize Center")
    hwnd := d.Hwnd
    WinWaitClose("ahk_id " hwnd)
    WinActivate("ahk_id " ownerHwnd)
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

; Les coordonnées ont leur propre fichier (hud_pos.cfg) et leur propre touche (HudKey) :
; elles ne touchent jamais à stuff_run.cfg ni à la touche des stuffs.
HudPing() {
    global hudBound
    if !hudBound {
        WriteAndExec('bind "' KeyBind(HudKey) '" "exec hud_pos"')
        hudBound := true
        return
    }
    Send("{" HudKey " down}")
    Sleep(40)
    Send("{" HudKey " up}")
}

; Crée hud_pos.cfg (contenu fixe) dans le dossier cfg de CS2
HudWriteCfg() {
    f := cfgDir "\hud_pos.cfg"
    want := "sv_cheats 1; getpos`n"
    try {
        if (!FileExist(f) || FileRead(f) != want) {
            try FileDelete(f)
            FileAppend(want, f, "UTF-8-RAW")
        }
    }
}

; Affiche (true) ou masque (false) les coordonnées
HudSet(on) {
    if (on && !hudOn)
        HudToggle()
    else if (!on && hudOn)
        HudToggle()
}

HudToggle() {
    global hudOn, hudPos, hudLast, hudBound
    hudOn := !hudOn
    if hudOn {
        hudBound := false
        HudWriteCfg()
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
    Loop lines.Length - hi {
        p := StrSplit(lines[hi + A_Index], "|", " `t", 5)
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
        ents.Push([p[1], cat, nm, p[4], (p.Length >= 5) ? p[5] : ""])
    }
    return Map("z", zoff, "from", from, "ents", ents, "imgs", imgs)
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
        if (x[1] = e[1] && x[2] = e[2]) {
            if (x[3] = ShiftZ(e[4], zdelta) && x[4] = e[5])
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
ApplyImport(rows, prof, zdelta, policy, imgs := "") {
    stats := Map("add", 0, "rep", 0, "skip", 0, "img", 0)
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
        for x in ReadEntries(path)[2] {
            if (x[1] = e[2])
                taken[StrLower(x[2])] := x
        }
        if taken.Has(StrLower(nm)) {
            old := taken[StrLower(nm)]
            if (old[3] = cmd && old[4] = e[5]) {
                stats["skip"] += 1
                continue
            }
            if (policy = 1) {
                stats["skip"] += 1
                continue
            }
            if (policy = 3) {
                ReplaceStuffInFile(path, old[1], old[2], e[2], nm, cmd, e[5])
                stats["rep"] += 1
                SaveImportedShot(imgs, e, cmd, prof, true, tmpImg, stats)
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
    res := Map("done", false)
    d := Gui("+AlwaysOnTop +OwnDialogs", "Importer des stuffs")
    d.SetFont("s10", "Segoe UI")
    src := (pack["from"] != "") ? " (profil « " pack["from"] " »)" : ""
    d.Add("Text", "x12 y12 w720", ents.Length " stuff(s) reçu(s)" src ". Coche ceux à importer.")
    d.Add("Text", "x12 y46 w150", "Profil de destination")
    cbTarget := d.Add("ComboBox", "x170 y42 w300", ListProfiles())
    d.Add("Text", "x12 y82 w150", "Si le stuff existe déjà")
    ddPolicy := d.Add("DropDownList", "x170 y78 w300 Choose1", ["Ignorer (ne rien changer)", "Garder les deux (renommer le nouveau)", "Remplacer le mien"])
    lv := d.Add("ListView", "x12 y116 w720 r13 Checked NoSort", ["Map", "Catégorie", "Nom", "Statut"])
    lv.ModifyCol(1, 110)
    lv.ModifyCol(2, 190)
    lv.ModifyCol(3, 250)
    lv.ModifyCol(4, 140)
    sumT := d.Add("Text", "x12 y+6 w720", "")
    imgNote := (imgs.Count > 0) ? "Ce pack contient " imgs.Count " capture(s) d'écran, importée(s) avec les stuffs." : "Ce pack ne contient pas de captures d'écran."
    d.Add("Text", "x12 y+4 w720", "Aperçu du stuff sélectionné (clique sur une ligne). " imgNote)
    picPrev := d.Add("Picture", "x582 y+2 w130 h130", "")
    picPrev.Visible := false
    edPrev := d.Add("Edit", "x12 yp w560 r7 ReadOnly -Wrap +HScroll", "")
    d.SetFont("s9 c8A8F96")
    note := "Pour un nouveau profil, écris simplement son nom dans la case. Tes autres stuffs ne sont jamais supprimés, et une copie de sécurité est faite avant l'import."
    if (zdelta != 0)
        note .= "`nHauteur : les coordonnées sont ajustées de " zdelta " pour correspondre à ton réglage TpZOffset."
    d.Add("Text", "x12 y+8 w720 r3", note)
    d.SetFont("s10 cDefault")
    btnOk := d.Add("Button", "x12 y+10 w200 Default", "Importer la sélection")
    btnAll := d.Add("Button", "x+10 yp w140", "Tout cocher")
    btnNone := d.Add("Button", "x+10 yp w140", "Tout décocher")
    btnNo := d.Add("Button", "x+10 yp w140", "Annuler")
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
            t .= "Info : " e[5] "`r`n"
        b := BlockedCmd(e[4])
        if (b != "")
            t .= "REFUSÉ : commande dangereuse (" b ")`r`n"
        adj := (zdelta != 0) ? " (hauteur ajustée)" : ""
        t .= "`r`nCommandes reçues" adj " :`r`n" PrettyCmd(cmdNew)
        old := FindExisting(e, tgt)
        if IsObject(old) {
            t .= "`r`n`r`nTon stuff actuel du même nom :`r`n" PrettyCmd(old[3])
            if (old[4] != "")
                t .= "`r`nInfo : " old[4]
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
        st := ApplyImport(picked, tgt, zdelta, ddPolicy.Value, imgs)
        res["done"] := true
        res["target"] := tgt
        res["msg"] := st["add"] " ajouté(s), " st["rep"] " remplacé(s), " st["skip"] " ignoré(s)."
        if (imgs.Count > 0)
            res["msg"] .= "`n" st["img"] " capture(s) d'écran importée(s)."
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
    d.Show("AutoSize Center")
    hwnd := d.Hwnd
    WinWaitClose("ahk_id " hwnd)
    WinActivate("ahk_id " ownerHwnd)
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

    d := Gui("+AlwaysOnTop +OwnDialogs", "Profils et partage de stuffs")
    d.SetFont("s10", "Segoe UI")
    d.Add("Text", "x12 y14 w130", "Profil actif :")
    d.SetFont("s10 bold")
    d.Add("Text", "x130 y14 w300", curProfile)
    d.SetFont("s10 norm")
    d.Add("Text", "x12 y50 w130", "Profils")
    ddProf := d.Add("DropDownList", "x130 y46 w250", ListProfiles())
    btnAct := d.Add("Button", "x+8 yp-1 w100", "Activer")
    btnNew := d.Add("Button", "x+8 yp w100", "Nouveau…")
    btnDelP := d.Add("Button", "x+8 yp w100", "Supprimer")
    d.Add("Text", "x12 y92 w740", "Exporter : coche les stuffs du profil actif à partager (un seul, plusieurs, ou tout).")
    lvEx := d.Add("ListView", "x12 y118 w740 r12 Checked NoSort", ["Map", "Catégorie", "Nom", "Info"])
    lvEx.ModifyCol(1, 110)
    lvEx.ModifyCol(2, 190)
    lvEx.ModifyCol(3, 220)
    lvEx.ModifyCol(4, 190)
    lvEx.GetPos(&lx, &ly, &lw, &lh)
    r1 := ly + lh + 8
    yImg := r1 + 36
    yImpT := r1 + 78
    yImpB := r1 + 104
    yStat := r1 + 148
    yClose := r1 + 178
    btnAll := d.Add("Button", "x12 y" r1 " w120", "Tout cocher")
    btnNone := d.Add("Button", "x+8 yp w120", "Tout décocher")
    btnFile := d.Add("Button", "x+8 yp w200", "Exporter vers un fichier…")
    btnCode := d.Add("Button", "x+8 yp w200", "Copier le code")
    chkImg := d.Add("CheckBox", "x12 y" yImg " w740 Checked", "Inclure les captures d'écran des stuffs (export vers un fichier uniquement)")
    d.Add("Text", "x12 y" yImpT " w740", "Importer : reçu d'un ami ?")
    btnImpF := d.Add("Button", "x12 y" yImpB " w240", "Importer un fichier .stuffpack…")
    btnImpC := d.Add("Button", "x+8 yp w300", "Importer depuis le presse-papiers (code)")
    d.SetFont("s10 c1B6E1B")
    stT := d.Add("Text", "x12 y" yStat " w740", "")
    d.SetFont("s10 cDefault")
    btnClose := d.Add("Button", "x12 y" yClose " w120", "Fermer")
    btnRest := d.Add("Button", "x+8 yp w230", "Restaurer une sauvegarde…")

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
                lvEx.Add("", mn, ent[1], ent[2], ent[4])
            }
        }
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
        WinActivate("ahk_exe cs2.exe")
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
    d.OnEvent("Close", Finish)
    d.OnEvent("Escape", Finish)
    Fill()
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
    d := Gui("+AlwaysOnTop +OwnDialogs", "Restaurer une sauvegarde")
    d.SetFont("s10", "Segoe UI")
    d.Add("Text", "x12 y12 w470", "Choisis la sauvegarde à restaurer pour le profil « " curProfile " ».`nTon état actuel est sauvegardé juste avant (dossier avant-restauration).")
    lv := d.Add("ListView", "x12 y58 w470 r10 NoSort -Multi", ["Sauvegarde", "Maps"])
    for nm in names {
        cnt := 0
        Loop Files root "\" nm "\*.txt"
            cnt += 1
        lv.Add("", nm, cnt)
    }
    lv.ModifyCol(1, 330)
    lv.ModifyCol(2, 80)
    btnOk := d.Add("Button", "x12 y+12 w200 Default", "Restaurer")
    btnNo := d.Add("Button", "x+10 yp w120", "Annuler")

    DoRestore(*) {
        r := lv.GetNext(0)
        if !r
            return
        sel := lv.GetText(r, 1)
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
    d.Show("AutoSize Center")
    hw := d.Hwnd
    WinWaitClose("ahk_id " hw)
    WinActivate("ahk_id " ownerHwnd)
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

    if FileExist(ConsoleLog)
        out.Push(["ok", "console.log trouvé", ""])
    else
        out.Push(["warn", "console.log pas encore créé", "Normal si CS2 n'a jamais tourné avec -condebug : ajoute -condebug dans les options de lancement de CS2 (Steam), puis lance le jeu"])
    return out
}

; Renvoie [liste, envoiOk, peutReessayer]
Check2() {
    out := []
    if !FileExist(ConsoleLog) {
        out.Push(["fail", "console.log introuvable alors que CS2 est lancé", "Ajoute -condebug dans les options de lancement de CS2 (Steam), puis relance le jeu"])
        return [out, false, false]
    }
    out.Push(["ok", "console.log présent", ""])
    ; même commande que la détection de map : si le jeu répond, l'envoi fonctionne
    txt := RunAndReadLog("status", "main lump")
    if !RegExMatch(txt, "i)main lump|hostname|Not connected|loopback|spawngroup") {
        out.Push(["fail", "Test d'envoi de commande : pas de réponse du jeu", "Entre dans une partie (map locale) sans ouvrir la console, puis clique sur Relancer la vérification. Si ça persiste, tape une fois exec " PracticeCfg " dans la console de CS2, puis relance la vérification. Si les armes changent toutes seules ou rien ne se passe, change les touches du script dans les réglages (bouton Touches du script)"])
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
    chkGui := Gui("+AlwaysOnTop", "Vérification de l'installation")
    chkGui.SetFont("s10", "Segoe UI")
    chkHead := chkGui.Add("Text", "x12 y12 w620 r2", "")
    chkTxt := chkGui.Add("Text", "x12 y+10 w620 r16", "")
    btnRe := chkGui.Add("Button", "x12 y+12 w220", "Relancer la vérification")
    btnX := chkGui.Add("Button", "x+10 yp w120", "Fermer")
    btnRe.OnEvent("Click", (*) => SetTimer(StartCheck, -50))
    btnX.OnEvent("Click", CheckClose)
    chkGui.OnEvent("Close", CheckClose)
    chkGui.OnEvent("Escape", CheckClose)
    CheckRender("Vérification en cours...")
    chkGui.Show("AutoSize NoActivate")
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
        CheckRender("Étape 1 terminée. Lance maintenant CS2 puis une map d'entraînement locale.`nLa suite de la vérification se fera toute seule.")
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
            } else {
                CheckRender("Certains points demandent ton attention (voir ci-dessous).")
            }
        } else {
            CheckRender("Attente de la partie... (essai " chkAttempts "/30)")
        }
    } finally {
        chkBusy := false
    }
}

; =====================================================================
;  Mise à jour automatique (depuis GitHub)
; =====================================================================
; Compare le fichier VERSION du dépôt avec APP_VERSION. Si une version plus récente existe et que
; tu acceptes, télécharge l'archive et remplace seulement les fichiers du programme.
; maps\, data\, profiles\ et config.ini ne sont jamais touchés.
CheckUpdate() {
    tmp := A_Temp "\cs2stuff_version.txt"
    try FileDelete(tmp)
    try {
        Download("https://raw.githubusercontent.com/" UPDATE_REPO "/main/VERSION", tmp)
        remote := Trim(FileRead(tmp), " `t`r`n")
    } catch {
        return
    }
    if !RegExMatch(remote, "^\d+(\.\d+)*$")
        return
    if (VerCompare(remote, APP_VERSION) <= 0)
        return
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
    DirCreate(DataDir "\backup")
    try FileCopy(A_ScriptFullPath, DataDir "\backup\stuff_menu.ahk.bak", 1)
    try {
        for fn in ["stuff_menu.ahk", "README.md", "CHANGELOG.md", "LICENSE", "config.example.ini", "cs2_practice.cfg", "VERSION", "update.bat", "update.ps1"] {
            if FileExist(src "\" fn)
                FileCopy(src "\" fn, A_ScriptDir "\" fn, 1)
        }
        if DirExist(src "\maps_default") {
            DirCreate(A_ScriptDir "\maps_default")
            Loop Files src "\maps_default\*.txt"
                FileCopy(A_LoopFileFullPath, A_ScriptDir "\maps_default\" A_LoopFileName, 1)
        }
    } catch as err {
        try FileCopy(DataDir "\backup\stuff_menu.ahk.bak", A_ScriptDir "\stuff_menu.ahk", 1)
        MsgBox("La mise à jour a échoué : " err.Message "`n`nL'ancien script a été restauré.", "Mise à jour du menu", 0x40010)
        return
    }
    MsgBox("Mise à jour terminée. Le menu va redémarrer.", "Mise à jour du menu", 0x40040)
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

; Choix des touches du script (une fois, ou tant que l'utilisateur répond « Plus tard »)
if (IniRead(IniFile, "State", "BindsV", "") != "1")
    ShowKeyPicker(true)
else
    WritePracticeBinds(KeyBind(ExecKey), KeyBind(HudKey), Map())   ; remet les liaisons si cs2_practice.cfg a été recopié
if HudAtStart
    HudToggle()
if AutoBackupOn
    SetTimer(AutoBackup, -2500)
skipCheck := (IniRead(IniFile, "State", "SkipCheck", "0") = "1")
if skipCheck
    IniWrite(0, IniFile, "State", "SkipCheck")
if (AutoCheck && !skipCheck)
    SetTimer(StartCheck, -1500)
if AutoUpdate
    SetTimer(CheckUpdate, -4000)
