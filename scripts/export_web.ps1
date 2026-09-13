param([switch]$Release)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$godot = Join-Path $projectRoot '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
$variant = if ($Release) { 'release' } else { 'debug' }
$template = Join-Path $projectRoot ".tools/export-templates/web_nothreads_$variant.zip"
if (-not (Test-Path -LiteralPath $template)) {
    & python (Join-Path $PSScriptRoot 'setup_web.py')
    if ($LASTEXITCODE -ne 0) { throw 'Web template setup failed.' }
}
$folder = Join-Path $projectRoot 'exports/web'
New-Item -ItemType Directory -Force -Path $folder | Out-Null
New-Item -ItemType File -Force -Path (Join-Path $projectRoot 'exports/.gdignore') | Out-Null
# Import before export, including newly added globally named scripts.
foreach ($arguments in @(@('--editor', '--import', '--quit'), @("--export-$variant", 'Web', (Join-Path $folder 'index.html')))) {
    $messages = & $godot --headless --path $projectRoot @arguments 2>&1
    $code = $LASTEXITCODE
    $messages | ForEach-Object { Write-Host $_ }
    if ($code -ne 0 -or ($messages | Select-String '(^|\s)(SCRIPT ERROR:|ERROR:)')) { throw 'Web export failed.' }
}
$commit = git -C $projectRoot rev-parse --short HEAD
$dirty = [bool](git -C $projectRoot status --porcelain)
@{ commit=$commit; dirty=$dirty; builtUtc=[DateTime]::UtcNow.ToString('o'); variant=$variant } | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $folder 'build.json')
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'release/GODOT-LICENSE.txt'), (Join-Path $PSScriptRoot 'release/GODOT-THIRD-PARTY.txt'), (Join-Path $projectRoot 'assets/fonts/OFL-NotoSansSymbols2.txt') -Destination $folder -Force
Write-Host 'Web build ready. Run scripts/run_web.ps1 -NoBuild to serve it.'
