$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$godot = (Resolve-Path (Join-Path $projectRoot ".tools\godot\Godot_v4.7.2-stable_win64_console.exe")).Path

function Invoke-GodotCheck {
    param([string[]]$EngineArguments)
    # Godot can return exit 0 after a GDScript error. Check its output as well.
    $testOutput = & $godot --headless --path $projectRoot @EngineArguments 2>&1
    $testExit = $LASTEXITCODE
    $testOutput | ForEach-Object { Write-Host $_ }
    if ($testExit -ne 0 -or ($testOutput | Select-String -Pattern '(^|\s)(SCRIPT ERROR:|ERROR:)')) {
        throw "Godot check failed: $($EngineArguments -join ' ')"
    }
}

Invoke-GodotCheck -EngineArguments @('--editor', '--import', '--quit')
foreach ($testName in @(
    'smoke_test', 'salvage_test', 'moba_test', 'iteration04_test', 'iteration05_test',
    'demo_test', 'readability_test', 'motion_qa_test', 'mobabot09_test', 'layout_audit',
    'mobabot10_test', 'mobabot11_test', 'mobabot12_test', 'mobabot13_test',
    'expedition_test', 'expedition_ui_test', 'skill_visual_test', 'keyboard_forge_test', 'keyboard_ui_test', 'painted_art_test', 'refinement_test', 'vanguard_test', 'practice_meter_test', 'cursor_test', 'interface_polish_test', 'loot_receipt_test', 'pressure_feedback_test', 'run_diagnostics_test', 'review_rules_test', 'operation_test', 'balance_benchmark_test', 'level_progression_test'
)) {
    Invoke-GodotCheck -EngineArguments @('--script', "res://tests/$testName.gd")
}
exit 0
