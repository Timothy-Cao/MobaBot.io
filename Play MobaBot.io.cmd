@echo off
if not exist "%~dp0.tools\godot\Godot_v4.7.2-stable_win64.exe" (
  echo Run scripts\setup.ps1 first. See README.md.
  pause
  exit /b 1
)
start "MobaBot.io" "%~dp0.tools\godot\Godot_v4.7.2-stable_win64.exe" --path "%~dp0."
