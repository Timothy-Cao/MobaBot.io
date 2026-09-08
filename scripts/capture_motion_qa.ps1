$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Resolve-Path (Join-Path $projectRoot ".tools\godot\Godot_v4.7.2-stable_win64_console.exe")).Path
$captureDirectory = Join-Path $projectRoot "output\playtest-v08"
New-Item -ItemType Directory -Force -Path $captureDirectory | Out-Null
foreach ($screenName in @("motion_impact", "motion_impact_reduced", "motion_dash", "motion_lowenergy", "motion_edge", "motion_edge_wide_reduced", "motion_overlap", "motion_charger")) {
    $capturePath = (Join-Path $captureDirectory "$screenName.png").Replace('\', '/')
    & $godot --path $projectRoot --resolution 960x540 -- "--fixture=$screenName" "--capture=$capturePath"
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
