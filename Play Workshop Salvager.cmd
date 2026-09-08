@echo off
if not exist "%~dp0.tools\godot\Godot_v4.7.2-stable_win64.exe" (
    echo The portable Godot engine is missing. Run scripts\setup.ps1 first.
    pause
    exit /b 1
)
start "Workshop Salvager" "%~dp0.tools\godot\Godot_v4.7.2-stable_win64.exe" --path "%~dp0."
