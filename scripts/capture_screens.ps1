$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Resolve-Path (Join-Path $projectRoot ".tools\godot\Godot_v4.7.2-stable_win64_console.exe")).Path
$captureDirectory = Join-Path $projectRoot "output\playtest-v08"
New-Item -ItemType Directory -Force -Path $captureDirectory | Out-Null
foreach ($screenName in @("home", "gameplay", "upgrade", "pause", "result", "build", "stats", "world", "loadout", "passives", "keys", "abilities", "loot", "stage_reward", "settings", "zoom", "utility", "utility_tree", "weapons", "milestone", "milestone_tree", "demo_charge", "demo_shells", "demo_recovery", "demo_level2", "wardens", "threats", "damage", "death_recap")) {
    $capturePath = (Join-Path $captureDirectory "$screenName.png").Replace('\', '/')
    & $godot --path $projectRoot --resolution 1280x720 -- "--fixture=$screenName" "--capture=$capturePath"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
