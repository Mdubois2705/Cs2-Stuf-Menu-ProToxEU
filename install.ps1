$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Windows.Forms
$repo = 'Mdubois2705/Cs2-Stuf-Menu-ProToxEU'
$name = 'Menu Stuf'
$files = 'stuff_menu.ahk','README.md','CHANGELOG.md','LICENSE','config.example.ini','cs2_practice.cfg','VERSION','menu_stuf.ico','install.bat','install.ps1','uninstall.bat','uninstall.ps1','update.bat','update.ps1'

function Find-Ahk {
    $c = @(
        (Join-Path $env:ProgramFiles 'AutoHotkey\v2\AutoHotkey64.exe'),
        (Join-Path $env:ProgramFiles 'AutoHotkey\v2\AutoHotkey32.exe'),
        (Join-Path $env:ProgramFiles 'AutoHotkey\v2\AutoHotkey.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'AutoHotkey\v2\AutoHotkey32.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey32.exe')
    )
    foreach ($p in $c) { if ($p -and (Test-Path $p)) { return $p } }
    return $null
}

function Is-Protected($path) {
    $p = $path.TrimEnd('\').ToLower()
    foreach ($x in @($env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:SystemRoot)) {
        if ($x -and $p.StartsWith($x.TrimEnd('\').ToLower())) { return $true }
    }
    return $false
}

# Une ancienne installation est un dossier avec stuff_menu.ahk et au moins une map dans maps\
function Test-Install($d) {
    if (-not $d) { return $false }
    if (-not (Test-Path (Join-Path $d 'stuff_menu.ahk'))) { return $false }
    $m = Join-Path $d 'maps'
    if (-not (Test-Path $m)) { return $false }
    return [bool](Get-ChildItem $m -Filter *.txt -ErrorAction SilentlyContinue | Select-Object -First 1)
}

function Find-OldInstalls($target) {
    $found = [ordered]@{}
    $cands = @()
    $cands += $PSScriptRoot
    try {
        Get-CimInstance Win32_Process -Filter "Name like 'AutoHotkey%'" -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.CommandLine -match '"([^"]*stuff_menu\.ahk)"') { $cands += (Split-Path $Matches[1] -Parent) }
        }
    } catch {}
    $roots = @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('MyDocuments'), (Join-Path $env:USERPROFILE 'Downloads'), $env:USERPROFILE)
    foreach ($dr in [System.IO.DriveInfo]::GetDrives()) {
        if ($dr.DriveType -eq 'Fixed' -and $dr.IsReady) { $roots += $dr.Name }
    }
    $sysRoot = $env:SystemDrive + '\'
    foreach ($r in ($roots | Select-Object -Unique)) {
        if (-not (Test-Path $r)) { continue }
        try {
            $dp = 3; if ($r -eq $sysRoot) { $dp = 2 }
            Get-ChildItem -Path $r -Filter 'stuff_menu.ahk' -Recurse -Depth $dp -File -ErrorAction SilentlyContinue | ForEach-Object { $cands += $_.DirectoryName }
        } catch {}
    }
    foreach ($c in $cands) {
        if (-not (Test-Install $c)) { continue }
        $full = (Resolve-Path $c).Path.TrimEnd('\')
        if ($full.ToLower() -eq $target.ToLower()) { continue }
        $found[$full.ToLower()] = $full
    }
    return @($found.Values)
}

try {
    Write-Host ''
    Write-Host '=== Installation de Menu Stuf ===' -ForegroundColor Cyan

    # 1. AutoHotkey v2
    $ahk = Find-Ahk
    if (-not $ahk) {
        Write-Host 'AutoHotkey v2 est introuvable.' -ForegroundColor Yellow
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if ($winget) {
            Write-Host 'Installation d AutoHotkey v2 avec winget (une fenetre Windows peut demander ton accord)...'
            & winget install --id AutoHotkey.AutoHotkey -e --accept-package-agreements --accept-source-agreements | Out-Host
            $ahk = Find-Ahk
        }
        if (-not $ahk) {
            Start-Process 'https://www.autohotkey.com/download/'
            throw 'Installe AutoHotkey v2 (page ouverte dans ton navigateur : bouton Download v2.0), puis relance install.bat.'
        }
    }
    Write-Host ('AutoHotkey v2 : ' + $ahk) -ForegroundColor Green

    # 2. Dossier d installation
    $dir = $null
    while (-not $dir) {
        $fd = New-Object System.Windows.Forms.FolderBrowserDialog
        $fd.Description = 'Choisis le dossier ou installer Menu Stuf (par exemple D:\Jeux). Un sous-dossier "Menu Stuf" y sera cree. Evite C:\Program Files : le menu y ecrit ses fichiers et Windows le bloque.'
        $fd.ShowNewFolderButton = $true
        $fd.SelectedPath = [Environment]::GetFolderPath('MyDocuments')
        $top = New-Object System.Windows.Forms.Form
        $top.TopMost = $true
        if ($fd.ShowDialog($top) -ne 'OK') { throw 'Installation annulee.' }
        $pick = $fd.SelectedPath
        if (Is-Protected $pick) {
            [System.Windows.Forms.MessageBox]::Show('Ce dossier est protege par Windows (Program Files ou Windows) : le menu ne pourrait pas y enregistrer tes stuffs. Choisis un autre dossier, par exemple D:\Jeux ou Documents.', 'Menu Stuf', 'OK', 'Warning') | Out-Null
            continue
        }
        if ((Split-Path $pick -Leaf) -eq $name -or (Test-Path (Join-Path $pick 'stuff_menu.ahk'))) { $cand = $pick } else { $cand = Join-Path $pick $name }
        try {
            New-Item -ItemType Directory -Force -Path $cand | Out-Null
            $t = Join-Path $cand 'write_test.tmp'
            Set-Content -Path $t -Value 'test'
            Remove-Item $t -Force
            $dir = $cand
        } catch {
            [System.Windows.Forms.MessageBox]::Show('Impossible d ecrire dans ce dossier. Choisis-en un autre.', 'Menu Stuf', 'OK', 'Warning') | Out-Null
        }
    }
    Write-Host ('Dossier : ' + $dir) -ForegroundColor Green

    # 3. Fichiers du programme : depuis ce dossier, sinon telecharges depuis GitHub
    $src = $PSScriptRoot
    $tmp = Join-Path $env:TEMP 'menustuf_install'
    if (-not (Test-Path (Join-Path $src 'stuff_menu.ahk'))) {
        Write-Host 'Telechargement de la derniere version...'
        if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
        New-Item -ItemType Directory -Path $tmp | Out-Null
        $zip = Join-Path $tmp 'u.zip'
        Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/$repo/archive/refs/heads/main.zip" -OutFile $zip
        Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $tmp 'x') -Force
        $src = (Get-ChildItem (Join-Path $tmp 'x') -Directory | Select-Object -First 1).FullName
        if (-not (Test-Path (Join-Path $src 'stuff_menu.ahk'))) { throw 'Archive invalide.' }
    }
    if ((Resolve-Path $src).Path.TrimEnd('\') -ne (Resolve-Path $dir).Path.TrimEnd('\')) {
        foreach ($f in $files) {
            $p = Join-Path $src $f
            if (Test-Path $p) { Copy-Item $p (Join-Path $dir $f) -Force }
        }
        $md = Join-Path $src 'maps_default'
        if (Test-Path $md) {
            New-Item -ItemType Directory -Force -Path (Join-Path $dir 'maps_default') | Out-Null
            Copy-Item (Join-Path $md '*.txt') (Join-Path $dir 'maps_default') -Force
        }
        Write-Host 'Fichiers copies (tes stuffs, profils et reglages existants ne sont pas touches).' -ForegroundColor Green
    } else {
        Write-Host 'Le menu est deja dans ce dossier : aucune copie necessaire.' -ForegroundColor Green
    }

    # 3b. Reprise des stuffs, profils et reglages d'une ancienne installation (rien n'est supprime ni modifie dans l'ancien dossier)
    $targetFull = (Resolve-Path $dir).Path.TrimEnd('\')
    if (Test-Install $dir) {
        Write-Host 'Ce dossier contient deja tes stuffs : ils sont conserves tels quels.' -ForegroundColor Green
    } else {
        Write-Host 'Recherche d une ancienne installation du menu...'
        $olds = @(Find-OldInstalls $targetFull)
        $old = $null
        if ($olds.Count -eq 1) {
            Write-Host ('Ancienne installation trouvee : ' + $olds[0]) -ForegroundColor Yellow
            Write-Host 'Ferme l ancien menu avant de continuer (icone verte H pres de l horloge > Quitter).'
            $a = Read-Host 'Reprendre tes stuffs, favoris, temps de vol, profils et reglages dans le nouveau dossier ? (O/N)'
            if ($a -match '^[oOyY]') { $old = $olds[0] }
        } elseif ($olds.Count -gt 1) {
            Write-Host 'Plusieurs anciennes installations trouvees :' -ForegroundColor Yellow
            for ($i = 0; $i -lt $olds.Count; $i++) { Write-Host ('  ' + ($i + 1) + ') ' + $olds[$i]) }
            Write-Host 'Ferme l ancien menu avant de continuer (icone verte H pres de l horloge > Quitter).'
            $a = Read-Host 'Numero de celle a reprendre (ou N pour ne rien reprendre)'
            if ($a -match '^\d+$' -and [int]$a -ge 1 -and [int]$a -le $olds.Count) { $old = $olds[[int]$a - 1] }
        } else {
            Write-Host 'Aucune ancienne installation trouvee : le menu demarrera vide.'
        }
        if ($old) {
            foreach ($item in 'maps','data','profiles') {
                $sd = Join-Path $old $item
                if (Test-Path $sd) {
                    $dd = Join-Path $dir $item
                    New-Item -ItemType Directory -Force -Path $dd | Out-Null
                    Copy-Item (Join-Path $sd '*') $dd -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            $ci = Join-Path $old 'config.ini'
            if (Test-Path $ci) { Copy-Item $ci (Join-Path $dir 'config.ini') -Force }
            Write-Host ('Stuffs, profils et reglages repris depuis : ' + $old) -ForegroundColor Green
            Write-Host 'L ancien dossier n a pas ete modifie : tu peux le supprimer quand tout fonctionne.'
        }
    }
    New-Item -ItemType Directory -Force -Path (Join-Path $dir 'data') | Out-Null
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

    # 4. Raccourcis (bureau et menu Demarrer)
    $ws = New-Object -ComObject WScript.Shell
    $made = @()
    foreach ($loc in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) {
        if (-not $loc) { continue }
        $lnk = $ws.CreateShortcut((Join-Path $loc ($name + '.lnk')))
        $lnk.TargetPath = $ahk
        $lnk.Arguments = '"' + (Join-Path $dir 'stuff_menu.ahk') + '"'
        $lnk.WorkingDirectory = $dir
        $lnk.IconLocation = (Join-Path $dir 'menu_stuf.ico')
        $lnk.Description = 'Menu Stuf - lineups et entrainement CS2'
        $lnk.Save()
        $made += $loc
    }
    Write-Host ('Raccourcis crees : ' + ($made -join ' ; ')) -ForegroundColor Green

    Write-Host ''
    Write-Host 'Installation terminee.' -ForegroundColor Green
    Write-Host ''
    Write-Host 'A faire une seule fois dans Steam : clic droit sur Counter-Strike 2 > Proprietes > Options de lancement,' -ForegroundColor Yellow
    Write-Host 'puis ajoute :  -condebug' -ForegroundColor Yellow
    Write-Host ''
    $ans = Read-Host 'Lancer Menu Stuf maintenant ? (O/N)'
    if ($ans -match '^[oOyY]') {
        Start-Process -FilePath $ahk -ArgumentList ('"' + (Join-Path $dir 'stuff_menu.ahk') + '"') -WorkingDirectory $dir
    }
}
catch {
    Write-Host ''
    Write-Host ('Erreur : ' + $_.Exception.Message) -ForegroundColor Red
}
