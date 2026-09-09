$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Resolve-Path (Join-Path $projectRoot ".tools\godot\Godot_v4.7.2-stable_win64_console.exe")).Path

& $godot --headless --path $projectRoot --editor --import --quit
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/smoke_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/salvage_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/moba_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/iteration04_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/iteration05_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/demo_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/readability_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/motion_qa_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/mobabot09_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/layout_audit.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/mobabot10_test.gd"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $godot --headless --path $projectRoot --script "res://tests/mobabot11_test.gd"
exit $LASTEXITCODE
