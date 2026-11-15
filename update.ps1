$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$repo = 'Mdubois2705/Cs2-Stuf-Menu-ProToxEU'
$dst = $PSScriptRoot
$tmp = Join-Path $env:TEMP 'cs2stuff_update'
try {
    Write-Host 'Telechargement de la derniere version...'
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    New-Item -ItemType Directory -Path $tmp | Out-Null
    $zip = Join-Path $tmp 'u.zip'
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/$repo/archive/refs/heads/main.zip" -OutFile $zip
    Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $tmp 'x') -Force
    $src = (Get-ChildItem (Join-Path $tmp 'x') -Directory | Select-Object -First 1).FullName
    if (-not (Test-Path (Join-Path $src 'stuff_menu.ahk')) -or -not (Test-Path (Join-Path $src 'VERSION'))) { throw 'Archive invalide' }

    $bk = Join-Path $dst 'data\backup'
    New-Item -ItemType Directory -Force -Path $bk | Out-Null
    $old = Join-Path $dst 'stuff_menu.ahk'
    if (Test-Path $old) { Copy-Item $old (Join-Path $bk 'stuff_menu.ahk.bak') -Force }

    foreach ($f in 'stuff_menu.ahk','README.md','CHANGELOG.md','LICENSE','config.example.ini','cs2_practice.cfg','VERSION','menu_stuf.ico','install.bat','install.ps1','uninstall.bat','uninstall.ps1') {
        $p = Join-Path $src $f
        if (Test-Path $p) { Copy-Item $p (Join-Path $dst $f) -Force }
    }
    $md = Join-Path $src 'maps_default'
    if (Test-Path $md) {
        New-Item -ItemType Directory -Force -Path (Join-Path $dst 'maps_default') | Out-Null
        Copy-Item (Join-Path $md '*.txt') (Join-Path $dst 'maps_default') -Force
    }
    Write-Host ''
    Write-Host 'Mise a jour terminee. Relance stuff_menu.ahk.' -ForegroundColor Green
    Write-Host 'Tes stuffs, favoris, profils et reglages n ont pas ete touches.'
}
catch {
    Write-Host ('Erreur : ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'Verifie ta connexion Internet et reessaie. Une copie de ton ancien script est dans data\backup.'
}
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
