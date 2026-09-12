param([string]$Version = "0.26.0-test.1")
$ErrorActionPreference = 'Stop'
if ($Version -notmatch '^[A-Za-z0-9._-]+$') { throw 'Invalid version label' }
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$godot = Join-Path $projectRoot '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
$template = Join-Path $projectRoot '.tools/export-templates/windows_release_x86_64.exe'
if (-not (Test-Path -LiteralPath $template)) { throw 'Install the official Godot 4.7.2 Windows x86_64 release template at .tools/export-templates/windows_release_x86_64.exe first.' }
$folder = Join-Path $projectRoot "exports/MobaBot-Windows-$Version"
if (Test-Path -LiteralPath $folder) { throw 'Export folder exists; use a fresh version label.' }
New-Item -ItemType Directory -Path $folder | Out-Null
$exe = Join-Path $folder 'MobaBot.exe'
$messages = & $godot --headless --path $projectRoot --export-release 'Windows Desktop' $exe 2>&1
$code = $LASTEXITCODE
$messages | ForEach-Object { Write-Host $_ }
if ($code -ne 0 -or ($messages | Select-String '(^|\s)(SCRIPT ERROR:|ERROR:)')) { throw 'Export failed' }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'release/PLAY-ME.txt'), (Join-Path $PSScriptRoot 'release/Create Desktop Shortcut.vbs') -Destination $folder
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'release/GODOT-LICENSE.txt'), (Join-Path $PSScriptRoot 'release/GODOT-THIRD-PARTY.txt') -Destination $folder
git -C $projectRoot rev-parse HEAD | Set-Content (Join-Path $folder 'BUILD-COMMIT.txt')
Compress-Archive -LiteralPath $folder -DestinationPath "$folder.zip"
Get-FileHash -LiteralPath "$folder.zip" -Algorithm SHA256
