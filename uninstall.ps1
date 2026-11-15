$name = 'Menu Stuf'
Write-Host ''
Write-Host '=== Desinstallation de Menu Stuf ===' -ForegroundColor Cyan
Write-Host 'Ferme d abord le menu (clic droit sur son icone pres de l horloge, puis Quitter).'
foreach ($loc in @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))) {
    $p = Join-Path $loc ($name + '.lnk')
    if (Test-Path $p) { Remove-Item $p -Force; Write-Host ('Raccourci supprime : ' + $p) }
}
Write-Host ''
Write-Host 'Les raccourcis sont supprimes. Ton dossier (stuffs, profils, reglages) est conserve :'
Write-Host $PSScriptRoot
Write-Host 'Supprime-le toi-meme si tu veux tout effacer.'
