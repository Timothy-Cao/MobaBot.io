param([switch]$Uncached, [string]$Name = ('probe-' + (Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference = 'Stop'
if ($Name -notmatch '^[A-Za-z0-9_-]+$') { throw 'Invalid probe name' }
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$folder = Join-Path $projectRoot "output/web-probes/$Name"
if (Test-Path -LiteralPath $folder) { throw 'Use a new probe name; existing outputs are preserved.' }
$staged = Join-Path $folder 'project'
$web = Join-Path $folder 'web'
New-Item -ItemType Directory -Path $staged,$web -Force | Out-Null
foreach ($part in @('src','assets','music','.godot')) {
    $source = Join-Path $projectRoot $part
    if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination $staged -Recurse }
}
$project = [IO.File]::ReadAllText((Join-Path $projectRoot 'project.godot')).Replace('res://src/salvage/expedition.tscn','res://src/diagnostics/web_render_probe.tscn')
[IO.File]::WriteAllText((Join-Path $staged 'project.godot'),$project)
$presets = [IO.File]::ReadAllText((Join-Path $projectRoot 'export_presets.cfg')).Replace('src/diagnostics/*,','').Replace('res://.tools/',($projectRoot.Replace('\','/')+'/.tools/'))
[IO.File]::WriteAllText((Join-Path $staged 'export_presets.cfg'),$presets)
if ($Uncached) {
    $probe = Join-Path $staged 'src/diagnostics/web_render_probe.gd'
    $text = [IO.File]::ReadAllText($probe).Replace('art=TimedArt.new();','art=TimedArt.new(); art.web_cached_art=false;')
    [IO.File]::WriteAllText($probe,$text)
}
$godot = Join-Path $projectRoot '.tools/godot/Godot_v4.7.2-stable_win64_console.exe'
foreach ($arguments in @(@('--editor','--import','--quit'),@('--export-release','Web',(Join-Path $web 'index.html')))) {
    $messages = & $godot --headless --path $staged @arguments 2>&1
    $code = $LASTEXITCODE
    $messages | ForEach-Object { Write-Host $_ }
    if ($code -ne 0 -or ($messages | Select-String '(^|\s)(SCRIPT ERROR:|ERROR:)')) { throw 'Probe export failed.' }
}
@{ commit=(git -C $projectRoot rev-parse HEAD); dirty=[bool](git -C $projectRoot status --porcelain); uncached=[bool]$Uncached; builtUtc=[DateTime]::UtcNow.ToString('o') } | ConvertTo-Json | Set-Content (Join-Path $folder 'probe.json')
Write-Host "Serve only $web on an unused loopback port. The benchmark runs automatically, logs WEB_RENDER_PROBE, and never loads player profiles."
