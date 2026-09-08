$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Resolve-Path (Join-Path $projectRoot ".tools\godot\Godot_v4.7.2-stable_win64.exe")).Path

& $godot --path $projectRoot
