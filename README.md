# MobaBot.io — 0.9 demo

A Windows-first, single-player survivor-like with MOBA mouse controls. Build a small salvage robot into a crowd-clearing machine. Stage 1 contains three levels and ends with the Foreman.

## Play

Double-click **Play MobaBot.io.cmd**. Relaunch any older game window to load this version.

On a fresh clone, run `scripts/setup.ps1` first; the portable Godot 4.7.2 engine is intentionally not committed. Then launch the game or run `scripts/open_editor.ps1`. The launcher works with spaces in the folder path.

This is a Godot development project, not a standalone exported Windows release. No accounts, API keys or online services are required to play. Repository: [Timothy-Cao/MobaBot.io](https://github.com/Timothy-Cao/MobaBot.io).

## Controls

| Input | Action |
| --- | --- |
| Right-click / hold | Move to a point / steer |
| S | Stop walking; a committed short dash still finishes |
| Q | Impact bolt: straight skillshot; impact and end-of-range explosion |
| W | Welding torch: two-second cone, steered with the cursor |
| E | Safety shell |
| R, then left-click | Target and confirm Reactor drop; right-click or Esc cancels |
| D / F | Sprint / charged blink |
| T | Deploy one sentry; replaces the previous one |
| 1–4 | Passive toggles; orbit alternates close/wide radius |
| 5 / 6 | Repair +2 hull / restore 50 energy; two of each per run |
| L / hold Space | Toggle camera lock / temporarily follow |
| Screen edges | Pan when the camera is unlocked |
| Wheel | Zoom 65–100% |
| Hold Tab | Inspect abilities, upgrades, stats and equipped gear; release to return |
| Esc | Settings; cancels targeting first |
| M / F2 | Mute audio / reduced effects |

No WASD movement. Settings offers camera lock and optional R quick cast. Other actives quick-cast by default; Shift + ability previews and casts on key release. Loadout edits and ability bindings apply next run. S, L, M, Space, Tab, Esc, 5 and 6 are reserved. Occupied ability bindings swap; older bindings that conflict with the new reserved keys migrate to a free letter.

Start with Q, D and F. Unlocks follow combat time: passive 1 at 10s, W at 20s, passive 2 at 32s, E at 45s, passive 3 at 58s, R at 70s, T at 95s, passive 4 at 110s. Pauses do not advance this clock. The default kit is aimed; the optional Relaxed kit and individual loadout choices retain low-mechanics alternatives. Every run repeats this short onboarding sequence.

## The demo

- Level 1 — Loading bay: 75 seconds of mobs.
- Level 2 — Assembly line: 90 seconds of harder mobs and two required wardens.
- Level 3 — Reactor floor: 90 seconds of mobs, then the Foreman.

The build carries between levels; the demo ends after the boss. Numerical rank ceilings rise 5 → 8 → 10. Ranks 5 and 10 transform effect size or behavior. End-level promotions raise ability rarity separately from ranks. XP Power is separate from encounter Level.

The map is 5360 × 3400 world units, with three sectors, caches and distant boundaries. It is not infinite and has no obstacle/pathfinding system yet. Off-screen spawns stay centered on the player even when the camera is panned elsewhere.

Magnet is separate free utility: 88 → 180 px reach, a free rank every three level-ups, and faster pull speed. There is no full-map vacuum in the main demo. Bonus drops require 48 px proximity. Ordinary kills have independent baseline chances of 1/25 for 25 credits and 1/15 for a six-second speed boost or QWE charge refill. Drop bonuses multiply those chances, with caps. Wardens/bosses also drop 75 credits. Difficult enemies retain larger scrap showers and energy/repair supplies.

## Equipment

Main menu → Equipment. Three slots: Core, Chassis, Drive; two equipment types per slot. Mk I and Mk II deliberately share each slot's art silhouette.

- Equip a replacement without consuming the old item.
- Reroll only the bonus for 35 credits. Results can be better, worse or the same.
- Add up to five stars with spare copies of that exact item and credits. Star N costs N duplicates and 25 × N credits. One owned copy is always retained.
- Each star adds 20% of that item's base stat, not 20 percentage points.
- Starter gear includes one spare of each equipped item and 150 credits, so you can try both systems immediately.
- Each cleared level awards one random equipment copy and 50 credits in addition to collected money. Level 1–2 rewards bank when you select the clear reward; final rewards bank on victory. Collected credits also bank on defeat. Quitting/restarting mid-level abandons that level's unbanked loot.
- Equipment is persistent; combat ranks, ability rarity and consumables reset each run. Equipment purchases apply next run.

Saves use a temporary file followed by replacement; failed purchases roll back. Unreadable/corrupt equipment saves are preserved rather than overwritten. Automated runs and screenshot fixtures cannot earn persistent rewards.

Preferences and local run diagnostics retain the original folder for compatibility:
`%APPDATA%/Godot/app_userdata/Workshop Salvager`.
Equipment: `mobabot_equipment.json`. Preferences: `salvage_settings.cfg`. Results: `salvage_runs.jsonl`.
No telemetry is uploaded. There is no mid-run save or cloud sync.

## Art and audio

Original code-native world graphics, ability icons and animation; nine generated inventory illustrations. New chassis and thruster art follows the existing teal enamel / steel / brass / cream style. [Art schema](docs/design/ART_STYLE_SCHEMA.md) and [equipment prompts/provenance](assets/upgrades/EQUIPMENT_PROVENANCE.md).

User-provided MP3s in `music/` play by context: menu, settings, equipment/results, the three levels, wardens, Foreman and overclocked Foreman. Two music voices crossfade; combat inspection and upgrade screens keep the current track. Mute affects both music and synthesized effects. Music defaults quieter than effects. Music is disabled under the headless dummy driver; normal Windows playback is enabled.

## Verify and continue development

Run from the project folder:

```powershell
.\scripts\check.ps1
.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/mobabot09_behavior_probe.gd
```

The full check includes legacy simulations, MOBA mechanics, progression, boss readability, movement at multiple physics rates, v0.9 mechanics/equipment/camera tests and UI text layout. The optional behavior probe compares idle, stationary casting and moving casting with normal health. Neither is a substitute for human playtesting.

[Latest audit and handoff](docs/design/QA_09.md). Earlier iteration documents are historical; this README and QA_09 supersede their controls and scope. Preserve the old Neon Collector sample at `src/main/main.tscn`.

Commit coherent, verified changes; do not commit engine/cache folders, generated test captures, temp files or local player records. Public-release work still includes export packaging, audio balance/listening, music-rights confirmation, and human tuning of camera speed, rewards and combat difficulty.
