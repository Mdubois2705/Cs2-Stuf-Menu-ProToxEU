#Requires AutoHotkey v2.0
#SingleInstance Force

; =====================================================================
;  CS2 STUFF MENU - overlay navigable pour s'entraîner en local
;  Config : config.ini   |   Stuffs : dossier maps\ (un .txt par map)
;  Données perso (favoris, récents) : dossier data\
; =====================================================================

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
ToggleKey := IniRead(IniFile, "Settings", "ToggleKey", "F7")
RepeatKey := IniRead(IniFile, "Settings", "RepeatKey", "F8")
SaveKey := IniRead(IniFile, "Settings", "SaveKey", "F9")
FavKey := IniRead(IniFile, "Settings", "FavKey", "F2")
DelKey := IniRead(IniFile, "Settings", "DelKey", "F3")
AddKey := IniRead(IniFile, "Settings", "AddKey", "F4")
CloseAfterRun := (IniRead(IniFile, "Settings", "CloseAfterRun", "1") = "1")
AutoDetect := (IniRead(IniFile, "Settings", "AutoDetectMap", "1") = "1")
ConsoleLog := IniRead(IniFile, "Settings", "ConsoleLog", "")
LastMap := IniRead(IniFile, "State", "LastMap", "")
SettingsKey := IniRead(IniFile, "Settings", "SettingsKey", "F10")
LockKey := IniRead(IniFile, "Settings", "LockKey", "F5")
ManageKey := IniRead(IniFile, "Settings", "ManageKey", "F11")
TpZOffset := Number(IniRead(IniFile, "Settings", "TpZOffset", "-64"))
ShareKey := IniRead(IniFile, "Settings", "ShareKey", "F1")
HudKey := IniRead(IniFile, "Settings", "HudKey", "Insert")
HudInterval := Max(100, ToInt(IniRead(IniFile, "Settings", "HudInterval", "300"), 300))
HudAtStart := (IniRead(IniFile, "Settings", "HudAtStart", "0") = "1")
ExecKey := IniRead(IniFile, "Settings", "ExecKey", "F6")
PracticeCfg := IniRead(IniFile, "Settings", "PracticeCfg", "cs2_practice")
AutoExec := (IniRead(IniFile, "Settings", "AutoExec", "1") = "1")
ConsoleKey := IniRead(IniFile, "Settings", "ConsoleKey", "")
execMap := ""       ; map pour laquelle le cfg d'entraînement a déjà été exécuté

; Apparence du menu (modifiable avec la touche de réglages)
ovFont := IniRead(IniFile, "Overlay", "Font", "")
ovScale := Max(60, Min(200, ToInt(IniRead(IniFile, "Overlay", "Scale", "100"), 100)))
ovX := ToInt(IniRead(IniFile, "Overlay", "X", "30"), 30)
ovY := ToInt(IniRead(IniFile, "Overlay", "Y", "100"), 100)
ovOpacity := Max(80, Min(255, ToInt(IniRead(IniFile, "Overlay", "Opacity", "225"), 225)))
ovBg := IniRead(IniFile, "Overlay", "Bg", "14181D")
ovTitle := Trim(RegExReplace(IniRead(IniFile, "Overlay", "Title", "Menu Stuf V.2 ProToxEU"), "[`r`n`t]+", " "))
if !RegExMatch(ovBg, "^[0-9A-Fa-f]{6}$")
    ovBg := "14181D"

SplitPath(CfgPath, , &cfgDir)
if (CfgPath = "" || !DirExist(cfgDir)) {
    MsgBox("Chemin CfgPath invalide dans config.ini :`n" CfgPath)
    ExitApp
}
if (ConsoleLog = "") {
    SplitPath(cfgDir, , &csgoDir)
    ConsoleLog := csgoDir "\console.log"
}
DirCreate(DataDir)
DirCreate(MapsDir)

; ---------- Constantes ----------
FAV_CAT := "[Favoris]"
REC_CAT := "[Récents]"
LOCK_ICON := "🔒"   ; si le cadenas s'affiche comme un carré, remplace par "[L]"
DEFAULT_LOCKED_CATS := ["Utilitaires"]   ; verrouillées au premier lancement
FALLBACK_CAT := "Non classés"            ; où vont les stuffs d'une catégorie supprimée
NO_TYPE := "(aucun)"
Types := ["Smoke", "Molotov", "Flash", "HE", "Position", "Autre", NO_TYPE]
GiveMap := Map("Smoke", "weapon_smokegrenade", "Molotov", "weapon_molotov", "Flash", "weapon_flashbang", "HE", "weapon_hegrenade")
NUM := "[-+\d.eE]+"

; ---------- État ----------
menuOpen := false
dlgOpen := false
level := 0          ; 0 = maps, 1 = catégories, 2 = stuffs, 3 = recherche
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
pendingKey := ""    ; suppression en attente de confirmation
setOpen := false    ; fenêtre de réglages ouverte
mgrOpen := false    ; fenêtre de gestion ouverte
hudOn := false      ; affichage des coordonnées en temps réel
hudGui := ""
hudTxt := ""
hudLast := ""
hudPos := 0         ; position de lecture dans console.log
cmdBusy := 0        ; > 0 pendant l'envoi d'une commande au jeu
g := ""
titleCtl := ""
listCtl := ""
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
    BuildVirtual()
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
    cmd := "sv_cheats 1; " cmd   ; setpos, give, god, bot_place... exigent sv_cheats 1
    try FileDelete(CfgPath)
    FileAppend(cmd "`n", CfgPath, "UTF-8-RAW")
    Sleep(30)
    Send("{NumpadMult down}")
    Sleep(40)
    Send("{NumpadMult up}")
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
    txt := RunAndReadLog("status", "main lump")
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
;  Affichage
; =====================================================================
Count() {
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

Render() {
    names := []
    sel := 1
    title := ""
    if (level = 0) {
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
        title := loadedMap " > " c
    } else {
        for it in results
            names.Push(DispName(it, true))
        sel := resIdx
        title := "Recherche : " query "_"
    }
    n := names.Length
    if (n = 0) {
        listCtl.Text := (level = 2) ? "(vide - " AddKey " pour ajouter un stuff)" : "(vide)"
    } else {
        start := Max(1, Min(sel - 6, n - 12))
        txt := ""
        Loop Min(13, n) {
            i := start + A_Index - 1
            txt .= (i = sel ? "> " : "   ") names[i] "`n"
        }
        listCtl.Text := txt
    }
    titleCtl.Text := title
    cur := CurrentItem()
    infoCtl.Text := (IsObject(cur) && cur[3] != "") ? "Info : " cur[3] : ""
    hintCtl.Text := HintText() "`n" SaveKey " : sauver la position   " ManageKey " : gestion   " ShareKey " : profils   " HudKey " : coordonnées"
    ShowOverlay()
}

HintText() {
    if (level = 0)
        return "Droite/Entrée : choisir la map"
    if (level = 1)
        return "Droite : ouvrir la catégorie   Tab : recherche   " LockKey " : cadenas`n" AddKey " : nouvelle catégorie   " DelKey " : supprimer la catégorie (2 appuis)"
    if (level = 2)
        return "Entrée : lancer le stuff   Tab : recherche   " FavKey " : favori   " LockKey " : cadenas`n" AddKey " : ajouter un stuff ici   " DelKey " : supprimer le stuff (2 appuis)"
    return "Tape pour filtrer   Entrée : lancer   Échap : retour`n" FavKey " : favori   " LockKey " : cadenas   " AddKey " : ajouter un stuff   " DelKey " : supprimer (2 appuis)"
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
Toggle() {
    global menuOpen, level, mapIdx, catIdx, itemIdx, LastMap
    if menuOpen {
        CloseMenu()
        return
    }
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
}

Move(d) {
    global mapIdx, catIdx, itemIdx, resIdx
    n := Count()
    if (n = 0)
        return
    if (level = 0) {
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
    global level
    if (level = 3) {
        ExitSearch()
        return
    }
    if (level = 0) {
        CloseMenu()
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

; Sous-catégories d'un type : "Smoke - Site A" -> "Site A"
SubCategories(path, typ) {
    subs := []
    seen := Map()
    pre := typ " - "
    for c in AllCategories(path) {
        if (InStr(c, pre) = 1) {
            sub := Trim(SubStr(c, StrLen(pre) + 1))
            if (sub != "" && !seen.Has(sub)) {
                seen[sub] := 1
                subs.Push(sub)
            }
        }
    }
    return subs
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
    if menuOpen
        CloseMenu()
    LoadMaps()
    if (mapNames.Length = 0) {
        MsgBox("Aucun fichier .txt dans " MapsDir)
        return
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
CurrentMapFile() {
    for i, n in mapNames {
        if (n = loadedMap)
            return mapFiles[i]
    }
    return ""
}

FindReal(key) {
    for c in cats {
        if (c = FAV_CAT || c = REC_CAT)
            continue
        for it in items[c] {
            if (it[5] = key)
                return it
        }
    }
    return ""
}

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
                continue
            }
        }
        keep.Push(line)
    }
    if removed
        RewriteFile(path, keep)
    return removed
}

DeleteCategoryFrom(path, cat) {
    if (path = "" || !FileExist(path))
        return 0
    keep := []
    n := 0
    for line in ReadLines(path) {
        t := Trim(line)
        if IsDataLine(t) {
            p := StrSplit(t, "|", " `t", 4)
            if ((p[1] = "@cat" && p.Length >= 2 && p[2] = cat) || (p.Length >= 3 && p[1] = cat)) {
                n += 1
                continue
            }
        }
        keep.Push(line)
    }
    if (n > 0)
        RewriteFile(path, keep)
    return n
}

CatInFile(path, cat) {
    for c in AllCategories(path) {
        if (c = cat)
            return true
    }
    return false
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

ClearPending() {
    global pendingKey
    pendingKey := ""
}

DelPress() {
    global pendingKey
    if (level = 0)
        return
    key := ""
    label := ""
    if (level = 1) {
        if (cats.Length = 0)
            return
        c := cats[catIdx]
        if (c = FAV_CAT || c = REC_CAT) {
            SetStatus("Catégorie automatique : rien à supprimer")
            return
        }
        if locks.Has("cat|" c) {
            SetStatus(LOCK_ICON " Catégorie verrouillée : appuie sur " LockKey " pour la déverrouiller")
            return
        }
        if CatHasLockedItem(c) {
            SetStatus(LOCK_ICON " Contient un stuff verrouillé : déverrouille-le d'abord")
            return
        }
        key := "cat|" c
        if (c = FALLBACK_CAT && items[c].Length > 0) {
            SetStatus("Déplace d'abord les stuffs de " c " vers une autre catégorie")
            return
        }
        label := "la catégorie " c " (ses stuffs iront dans " FALLBACK_CAT ")"
        if CatInFile(MapsDir "\_commun.txt", c)
            label .= " (commune à toutes les maps)"
    } else {
        cur := CurrentItem()
        if !IsObject(cur)
            return
        if locks.Has("it|" cur[5]) {
            SetStatus(LOCK_ICON " Stuff verrouillé : appuie sur " LockKey " pour le déverrouiller")
            return
        }
        key := "it|" cur[5]
        label := cur[1]
        if (cur.Length >= 6 && InStr(cur[6], "_commun.txt"))
            label .= " (commun à toutes les maps)"
    }
    if (pendingKey = key) {
        pendingKey := ""
        if (level = 1)
            DoDeleteCategory(cats[catIdx])
        else
            DoDeleteStuff(CurrentItem())
        return
    }
    pendingKey := key
    SetStatus("Rappuie sur " DelKey " pour supprimer : " label)
    SetTimer(ClearPending, -3000)
}

DoDeleteStuff(it) {
    if locks.Has("it|" it[5])
        return
    real := FindReal(it[5])
    if !IsObject(real) {
        PurgeKey(it[5])
        ReloadKeep()
        Render()
        SetStatus("Entrée obsolète retirée")
        return
    }
    if !DeleteLineFrom(real[6], real[4], real[1]) {
        SetStatus("Ligne introuvable dans le fichier")
        return
    }
    PurgeKey(real[5])
    ReloadKeep()
    Render()
    SetStatus("Stuff supprimé : " real[1])
}

DoDeleteCategory(c) {
    if (locks.Has("cat|" c) || CatHasLockedItem(c))
        return
    moved := 0
    for file in [CurrentMapFile(), MapsDir "\_commun.txt"] {
        if (file = "" || !FileExist(file))
            continue
        for ent in ReadEntries(file)[2] {
            if (ent[1] = c)
                Rekey(loadedMap "|" c "|" ent[2], loadedMap "|" FALLBACK_CAT "|" ent[2])
        }
        moved += DeleteCatKeepStuffs(file, c, FALLBACK_CAT)
    }
    ReloadKeep()
    Render()
    if (moved > 0)
        SetStatus("Catégorie supprimée : " moved " stuff(s) déplacé(s) dans " FALLBACK_CAT)
    else
        SetStatus("Catégorie supprimée : " c)
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

AddPress() {
    global catIdx
    if (level = 0)
        return
    mapFile := CurrentMapFile()
    if (mapFile = "") {
        SetStatus("Map introuvable")
        return
    }
    if (level = 1) {
        name := CleanField(AskText("Ajouter une catégorie", "Nom de la nouvelle catégorie :"))
        if (name = "")
            return
        if (SubStr(name, 1, 1) = "[" || SubStr(name, 1, 1) = "@") {
            SetStatus("Le nom ne peut pas commencer par [ ou @")
            return
        }
        for c in cats {
            if (c = name) {
                SetStatus("Cette catégorie existe déjà")
                return
            }
        }
        AppendLine(mapFile, "@cat | " name)
        ReloadKeep()
        for i, c in cats {
            if (c = name)
                catIdx := i
        }
        Render()
        SetStatus("Catégorie ajoutée : " name)
        return
    }
    ; niveau 2 ou 3 : ajouter un stuff dans la catégorie courante
    preset := ""
    cur := CurrentItem()
    if (level = 2 && cats[catIdx] != FAV_CAT && cats[catIdx] != REC_CAT)
        preset := cats[catIdx]
    else if IsObject(cur)
        preset := cur[4]
    ShowSaveDialog(preset, loadedMap)
}

; =====================================================================
;  Apparence de l'overlay (police, taille, couleurs, position)
; =====================================================================
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

BuildOverlay() {
    global g, titleCtl, listCtl, infoCtl, hintCtl, statusCtl
    if IsObject(g)
        g.Destroy()
    W := Round(460 * ovScale / 100)
    dark := (Lum(ovBg) < 140)
    cTitle := dark ? "FFB000" : "8A4B00"
    cList := dark ? "FFFFFF" : "111111"
    cInfo := dark ? "FFD27A" : "6B4A00"
    cStatus := dark ? "7CFC00" : "1B6E1B"
    cHint := dark ? "FFFFFF" : "000000"
    cFoot := dark ? "B4BAC2" : "444444"
    cBrand := dark ? "7AD7FF" : "005A8C"
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
    listCtl := g.Add("Text", "w" W " r13", "")
    g.SetFont("s" FS(10) " c" cInfo, fText)
    infoCtl := g.Add("Text", "w" W " r3", "")
    g.SetFont("s" FS(9) " c" cStatus, fText)
    statusCtl := g.Add("Text", "w" W " r2", "")
    g.SetFont("s" FS(10) " bold c" cHint, fText)
    hintCtl := g.Add("Text", "w" W " r3", "")
    g.SetFont("s" FS(9) " norm c" cFoot, fText)
    g.Add("Text", "w" W, "Haut/Bas : naviguer   Droite/Entrée : valider   Gauche : retour   Échap : fermer`n" ToggleKey " : ouvrir/fermer   " RepeatKey " : relancer le dernier stuff   " SaveKey " : sauvegarder la position`n" SettingsKey " : réglages du menu (couleur, police, taille, position)`n" ExecKey " : relancer l'exec de " PracticeCfg "`n" ManageKey " : gérer les stuffs et les catégories (déplacer, renommer…)`n" HudKey " : coordonnées en temps réel (coin inférieur gauche)`n" ShareKey " : profils et partage de stuffs (export / import)")
}

ShowOverlay() {
    vl := SysGet(76)
    vt := SysGet(77)
    vw := SysGet(78)
    vh := SysGet(79)
    x := Max(vl, Min(ovX, vl + vw - 100))
    y := Max(vt, Min(ovY, vt + vh - 60))
    g.Show("NA x" x " y" y " AutoSize")
    WinSetTransparent(ovOpacity, g)
}

ShowPreview() {
    titleCtl.Text := "APERÇU DU MENU"
    listCtl.Text := "> Exemple de stuff`n   Autre stuff`n   * Stuff favori`n   Smoke - Site A"
    infoCtl.Text := "Info : message affiché dans le chat"
    statusCtl.Text := ""
    hintCtl.Text := "Droite/Entrée : valider   Gauche : retour"
    ShowOverlay()
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
    old := Map("Font", ovFont, "Scale", ovScale, "X", ovX, "Y", ovY, "Opacity", ovOpacity, "Bg", ovBg)
    vl := SysGet(76)
    vt := SysGet(77)
    vw := SysGet(78)
    vh := SysGet(79)
    xr := Max(1, vw - 100)
    yr := Max(1, vh - 60)
    fonts := ["Par défaut", "Segoe UI", "Consolas", "Arial", "Verdana", "Tahoma", "Calibri", "Trebuchet MS", "Courier New", "Lucida Console"]
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
    x0 := Max(0, Min(ovX - vl, xr))
    y0 := Max(0, Min(ovY - vt, yr))

    d := Gui("+AlwaysOnTop", "Réglages du menu")
    d.SetFont("s10", "Segoe UI")
    y := 14
    ty := y + 4
    d.Add("Text", "x12 y" ty " w110", "Police")
    ddFont := d.Add("DropDownList", "x130 y" y " w260 Choose" fSel, fonts)
    y += 40
    ty := y + 4
    d.Add("Text", "x12 y" ty " w110", "Taille")
    slScale := d.Add("Slider", "x130 y" y " w260 Range60-200 ToolTip", ovScale)
    txScale := d.Add("Text", "x396 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x12 y" ty " w110", "Position X")
    slX := d.Add("Slider", "x130 y" y " w260 Range0-" xr " ToolTip", x0)
    txX := d.Add("Text", "x396 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x12 y" ty " w110", "Position Y")
    slY := d.Add("Slider", "x130 y" y " w260 Range0-" yr " ToolTip", y0)
    txY := d.Add("Text", "x396 y" ty " w70", "")
    y += 40
    ty := y + 4
    d.Add("Text", "x12 y" ty " w110", "Opacité")
    slOp := d.Add("Slider", "x130 y" y " w260 Range80-255 ToolTip", ovOpacity)
    txOp := d.Add("Text", "x396 y" ty " w70", "")
    y += 46
    ty := y + 4
    d.Add("Text", "x12 y" ty " w110", "Couleur de fond")
    ddPreset := d.Add("DropDownList", "x130 y" y " w260 Choose" pSel, pNames)
    y += 40
    ty := y + 4
    d.Add("Text", "x12 y" ty " w110", "Rouge")
    slR := d.Add("Slider", "x130 y" y " w260 Range0-255 ToolTip", r0)
    y += 34
    ty := y + 4
    d.Add("Text", "x12 y" ty " w110", "Vert")
    slG := d.Add("Slider", "x130 y" y " w260 Range0-255 ToolTip", g0)
    y += 34
    ty := y + 4
    d.Add("Text", "x12 y" ty " w110", "Bleu")
    slB := d.Add("Slider", "x130 y" y " w260 Range0-255 ToolTip", b0)
    txHex := d.Add("Text", "x396 y" ty " w70", "")
    y += 46
    btnSave := d.Add("Button", "x12 y" y " w140 Default", "Enregistrer")
    btnReset := d.Add("Button", "x+8 yp w140", "Réinitialiser")
    btnCancel := d.Add("Button", "x+8 yp w140", "Annuler")

    Sync(*) {
        global ovFont, ovScale, ovX, ovY, ovOpacity, ovBg
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
        txHex.Text := "#" ovBg
        SetTimer(ApplyStyle, -40)
    }

    PresetChange(*) {
        if (ddPreset.Value = 1)
            return
        h := pHex[ddPreset.Value]
        slR.Value := Integer("0x" SubStr(h, 1, 2))
        slG.Value := Integer("0x" SubStr(h, 3, 2))
        slB.Value := Integer("0x" SubStr(h, 5, 2))
        Sync()
    }

    RgbChange(*) {
        ddPreset.Choose(1)
        Sync()
    }

    ResetClick(*) {
        ddFont.Choose(1)
        slScale.Value := 100
        slX.Value := Max(0, Min(30 - vl, xr))
        slY.Value := Max(0, Min(100 - vt, yr))
        slOp.Value := 225
        slR.Value := 20
        slG.Value := 24
        slB.Value := 29
        ddPreset.Choose(2)
        Sync()
    }

    Finish(save, *) {
        global setOpen, ovFont, ovScale, ovX, ovY, ovOpacity, ovBg
        if save {
            IniWrite(ovFont, IniFile, "Overlay", "Font")
            IniWrite(ovScale, IniFile, "Overlay", "Scale")
            IniWrite(ovX, IniFile, "Overlay", "X")
            IniWrite(ovY, IniFile, "Overlay", "Y")
            IniWrite(ovOpacity, IniFile, "Overlay", "Opacity")
            IniWrite(ovBg, IniFile, "Overlay", "Bg")
        } else {
            ovFont := old["Font"]
            ovScale := old["Scale"]
            ovX := old["X"]
            ovY := old["Y"]
            ovOpacity := old["Opacity"]
            ovBg := old["Bg"]
        }
        setOpen := false
        d.Destroy()
        BuildOverlay()
        if menuOpen
            Render()
        WinActivate("ahk_exe cs2.exe")
    }

    ddFont.OnEvent("Change", Sync)
    slScale.OnEvent("Change", Sync)
    slX.OnEvent("Change", Sync)
    slY.OnEvent("Change", Sync)
    slOp.OnEvent("Change", Sync)
    ddPreset.OnEvent("Change", PresetChange)
    slR.OnEvent("Change", RgbChange)
    slG.OnEvent("Change", RgbChange)
    slB.OnEvent("Change", RgbChange)
    btnSave.OnEvent("Click", Finish.Bind(true))
    btnReset.OnEvent("Click", ResetClick)
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
;  - ConsoleKey vide : passe par la touche liée (kp_multiply -> exec stuff_run).
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

CatHasLockedItem(c) {
    if !items.Has(c)
        return false
    for it in items[c] {
        if locks.Has("it|" it[5])
            return true
    }
    return false
}

LockPress() {
    if (level = 0)
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

    Finish(*) {
        global mgrOpen
        mgrOpen := false
        d.Destroy()
        WinActivate("ahk_exe cs2.exe")
    }

    ddMap.OnEvent("Change", (*) => RefreshCats(""))
    lvCat.OnEvent("ItemSelect", CatSelected)
    btnCatNew.OnEvent("Click", NewCat)
    btnCatRen.OnEvent("Click", RenCat)
    btnCatDel.OnEvent("Click", DelCat)
    btnCatLock.OnEvent("Click", LockCat)
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
    global hudGui, hudTxt
    if IsObject(hudGui)
        hudGui.Destroy()
    dark := (Lum(ovBg) < 140)
    cTxt := dark ? "FFFFFF" : "111111"
    fnt := (ovFont = "") ? "Consolas" : ovFont
    hudGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000 +E0x20")
    hudGui.BackColor := ovBg
    hudGui.MarginX := 10
    hudGui.MarginY := 6
    hudGui.SetFont("s" FS(11) " bold c" cTxt, fnt)
    hudTxt := hudGui.Add("Text", "w" Round(330 * ovScale / 100) " r3", hudLast)
}

ShowHud() {
    MonitorGet(MonitorGetPrimary(), &ml, &mt, &mr, &mb)
    hudGui.Show("NA AutoSize x" (ml + 12) " y" (mt + 12))
    hudGui.GetPos(, , , &hh)
    hudGui.Move(ml + 12, mb - hh - 12)
    WinSetTransparent(ovOpacity, hudGui)
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
    WriteAndExec("getpos")
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
BuildPack(list) {
    out := "CS2STUFFPACK;1;" TpZOffset ";" CleanField(curProfile) "`n"
    for e in list
        out .= e[1] " | " e[2] " | " e[3] " | " e[4] " | " e[5] "`n"
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
    Loop lines.Length - hi {
        p := StrSplit(lines[hi + A_Index], "|", " `t", 5)
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
    return Map("z", zoff, "from", from, "ents", ents)
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

; policy : 1 = ignorer les doublons, 2 = garder les deux, 3 = remplacer
ApplyImport(rows, prof, zdelta, policy) {
    stats := Map("add", 0, "rep", 0, "skip", 0)
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
                continue
            }
            n := 2
            while taken.Has(StrLower(nm " (" n ")"))
                n += 1
            nm := nm " (" n ")"
        }
        AppendLine(path, BuildLine(e[2], nm, cmd, e[5]))
        stats["add"] += 1
    }
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
    d.SetFont("s9 c8A8F96")
    note := "Pour un nouveau profil, écris simplement son nom dans la case. Tes autres stuffs ne sont jamais supprimés ; une copie de sécurité est faite avant l'import."
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
    }

    CheckAll(on, *) {
        Loop lv.GetCount()
            lv.Modify(A_Index, on ? "Check" : "-Check")
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
        st := ApplyImport(picked, tgt, zdelta, ddPolicy.Value)
        res["done"] := true
        res["target"] := tgt
        res["msg"] := st["add"] " ajouté(s), " st["rep"] " remplacé(s), " st["skip"] " ignoré(s)."
        d.Destroy()
    }

    Cancel(*) {
        d.Destroy()
    }

    cbTarget.OnEvent("Change", Refill)
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
    btnAll := d.Add("Button", "x12 y" r1 " w120", "Tout cocher")
    btnNone := d.Add("Button", "x+8 yp w120", "Tout décocher")
    btnFile := d.Add("Button", "x+8 yp w200", "Exporter vers un fichier…")
    btnCode := d.Add("Button", "x+8 yp w200", "Copier le code")
    d.Add("Text", "x12 y" (r1 + 48) " w740", "Importer : reçu d'un ami ?")
    btnImpF := d.Add("Button", "x12 y" (r1 + 74) " w240", "Importer un fichier .stuffpack…")
    btnImpC := d.Add("Button", "x+8 yp w300", "Importer depuis le presse-papiers (code)")
    d.SetFont("s10 c1B6E1B")
    stT := d.Add("Text", "x12 y" (r1 + 118) " w740", "")
    d.SetFont("s10 cDefault")
    btnClose := d.Add("Button", "x12 y" (r1 + 148) " w120", "Fermer")

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
        rows := []
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
        FileAppend(BuildPack(sel), f, "UTF-8-RAW")
        Say(sel.Length " stuff(s) exporté(s) dans " f)
    }

    ExportCode(*) {
        sel := Picked()
        if (sel.Length = 0) {
            Say("Coche au moins un stuff à exporter")
            return
        }
        A_Clipboard := BuildPack(sel)
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
    d.OnEvent("Close", Finish)
    d.OnEvent("Escape", Finish)
    Fill()
    d.Show("AutoSize Center")
}

; =====================================================================
;  Raccourcis (actifs uniquement dans CS2)
; =====================================================================
InGame(*) => WinActive("ahk_exe cs2.exe")
MenuActive(*) => menuOpen && WinActive("ahk_exe cs2.exe")

HotIf(InGame)
Hotkey(ToggleKey, (*) => Toggle())
Hotkey(RepeatKey, (*) => RepeatLast())
Hotkey(SaveKey, (*) => ShowSaveDialog())
Hotkey(SettingsKey, (*) => ShowSettings())
Hotkey(ExecKey, (*) => ForceExec())
Hotkey(ManageKey, (*) => ShowManager())
Hotkey(HudKey, (*) => HudToggle())
Hotkey(ShareKey, (*) => ShowShare())

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
Hotkey(FavKey, (*) => ToggleFav())
Hotkey(LockKey, (*) => LockPress())
Hotkey(DelKey, (*) => DelPress())
Hotkey(AddKey, (*) => AddPress())
HotIf()

if HudAtStart
    HudToggle()
