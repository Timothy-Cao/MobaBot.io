# MobaBot.io — 0.13 Minimal UI

A Windows-first, single-player survivor-like with MOBA mouse controls. Build a small salvage robot into a crowd-clearing machine. Stage 1 contains three levels and ends with the Foreman.

0.13 aggressively prunes the interface: five home actions, two Build pages, two Loadout pages and four basic settings. Combat and progression are unchanged from 0.12. The larger campaign overhaul remains planned, not implemented. See [systems direction](docs/design/SYSTEMS_REFINEMENT_12.md) and [menu changes / QA](docs/design/QA_13.md).

## Play

Double-click **Play MobaBot.io.cmd**. Relaunch any older game window to load this version.

On a fresh clone, run `scripts/setup.ps1` first; the portable Godot 4.7.2 engine is intentionally not committed. Then launch the game or run `scripts/open_editor.ps1`. The launcher works with spaces in the folder path.

This is a Godot development project, not a standalone exported Windows release. No accounts, API keys or online services are required to play. Repository: [Timothy-Cao/MobaBot.io](https://github.com/Timothy-Cao/MobaBot.io).

## Controls

| Input | Action |
| --- | --- |
| Right-click ground / hold | Move / steer; autonomous gun keeps firing |
| Right-click enemy | Approach into basic-attack range and attack |
| A, then left-click | Show basic range; cursor-priority attack move |
| S | Stop movement and commanded basic attacks, NOT the auto gun; committed short dash still finishes |
| Q | Impact bolt: straight skillshot; impact and end-of-range explosion |
| W | Welding torch: two-second cone, steered with the cursor |
| E, then left-click | Reactor drop; right-click or Esc cancels |
| R | Channel Core cutter for up to 5s; right-click steers slowly, R again cancels |
| D / F | Ghost drive (3s intangible) / charged blink; either can interrupt R |
| T | Deploy one sentry; replaces the previous one |
| 1 | Auto machine gun → auto sniper → off → machine gun |
| 2–4 | Passive toggles; orbit close/wide; Arc Coil chain/focused/off |
| 5 / 6, or their HUD buttons | Repair +2 hull / restore 50 energy; two of each per run |
| L / hold Space | Toggle camera lock / temporarily follow |
| Screen edges | Pan when the camera is unlocked |
| Wheel | Zoom 65–100% |
| Hold Tab | Overview of equipped kit and six core stats; Mastery to spend points |
| Esc | Settings; cancels targeting first |
| M / F2 | Mute audio / reduced effects |

No WASD movement. Settings → Options contains Sound, Reduced effects, Camera lock and Area quick cast. Settings → Controls contains keybindings (including while paused); changes apply next run. The zoom slider is removed; wheel zoom remains. Other actives quick-cast by default; Shift + ability previews and casts on key release. R channel starts immediately. A, S, L, M, Space, Tab, Esc, 5 and 6 are reserved. Occupied ability bindings swap; older conflicting bindings migrate to a free letter. Old R-nuke saves migrate to E nuke / R laser; custom Q/W choices remain. Choose **Loadout → Default kit** to try the full new preset.

Tab has only **Overview** and **Mastery**. Overview combines equipped ability/passive/gear icons with hull, energy, ability damage, auto fire rate, movement speed and pickup reach. Hover or select a tile for detail; Esc closes detail before Build. Separate stat dashboards, damage-source charts and ability-rank preview pages are removed from normal navigation. Upgrade choices still show their numerical gains. The title-screen mastery preview and decorative route itinerary are removed. In-run Settings retains a confirmed Main menu exit.

Default passives are Auto gun, Scrap orbit, Arc coil and Reactive plating. Fully enabled they consume 10 energy/sec before 8/sec base regeneration. Energy depletion switches powered passives off; use their number keys to restore them once energy is available. Reactor upgrades and equipment improve the budget. R costs 40 energy and roots you while firing; D/F remain free escapes. The autonomous gun ignores S, movement and channels; its powered state and energy budget control it. Basic attacks have a separate cooldown and require attack orders.

Slot 1 is the starting gun. Select slots 2–4 in Loadout to try **Coolant trail**: 3 energy/sec on, no upkeep off, no self-damage. Laid patches persist four seconds and deal 8 base damage/sec; overlapping patches do not stack. Weapon power scales the damage. Old custom loadouts are normalized in memory to include the starting gun while preserving Orbit/Ricochet dependencies.

Mastery is run-only: start with one point, earn another every Power level. The HUD ◇ count shows unspent points. Tab opens the tree first when points await; no extra level-up popup. The current nine-node tree remains; the larger six-branch tree is planned. There is no main-menu mastery button.

Start with the auto gun and Q; D/F also remain immediately available. Later unlocks still follow combat time: W at 20s, passive 2 at 32s, E at 45s, passive 3 at 58s, R at 70s, T at 95s, passive 4 at 110s. Pauses do not advance this clock. Chest discovery and duplicate +2 ranks will replace this temporary schedule in the next progression milestone. The optional Relaxed kit and individual loadout choices retain low-mechanics alternatives.

## The demo

- Level 1 — Loading bay: 75 seconds of mobs.
- Level 2 — Assembly line: 90 seconds of harder mobs and two required wardens.
- Level 3 — Reactor floor: 90 seconds of mobs, then the Foreman.

The build carries between levels; the demo ends after the boss. Numerical rank ceilings rise 5 → 8 → 10. Ranks 5 and 10 transform effect size or behavior. End-level promotions raise ability rarity separately from ranks. XP Power is separate from encounter Level.

The map is 5360 × 3400 world units, with three sectors, caches and distant boundaries. It is not infinite and has no obstacle/pathfinding system yet. Off-screen spawns stay centered on the player even when the camera is panned elsewhere.

Magnet is separate free utility: 88 → 180 px reach, a free rank every three level-ups, and faster pull speed. Mastery can add 105 reach. There is no full-map vacuum. Bonus drops require 48 px proximity. Ordinary kills have independent baseline chances of 1/25 for 25 credits and 1/15 for a six-second speed boost or QWE charge refill. Drop bonuses multiply those chances, with caps. Wardens/bosses also drop 75 credits. Difficult enemies retain larger scrap showers and energy/repair supplies.

Enemies now hit harder. Heavy/elite contact and boss shots/blasts cost 2 hull; boss charges cost 3. Foreman is larger, faster, summons reinforcements and overclocks at half health. Tanks and radial shots can briefly slow you by 20%. D blocks damage and slows for three seconds. Mastery can raise maximum hull from 5 to 8.

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

Original code-native world graphics, animation and one unified icon family across abilities, passives, mastery and equipment. The nine earlier generated illustrations remain preserved but are not mixed into the current interface. [Art schema](docs/design/ART_STYLE_SCHEMA.md), [research and design decisions](docs/design/ITERATION_10.md), and [archived equipment provenance](assets/upgrades/EQUIPMENT_PROVENANCE.md).

User-provided MP3s in `music/` play by context: menu, settings, equipment/results, the three levels, wardens, Foreman and overclocked Foreman. Two music voices crossfade; combat inspection and upgrade screens keep the current track. Mute affects both music and synthesized effects. Music defaults quieter than effects. Music is disabled under the headless dummy driver; normal Windows playback is enabled.

## Verify and continue development

Run from the project folder:

```powershell
.\scripts\check.ps1
.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/mobabot09_behavior_probe.gd -- --refined
.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/mobabot10_behavior_probe.gd -- --refined
```

The full check includes legacy simulations, MOBA mechanics, progression, boss readability, movement at multiple physics rates, equipment/camera, UI text layout, laser/ghost/lightning and mastery effects. Behavior probes compare idle, stationary, passive-only, moving-casting and adaptive policies with normal health. They do not establish human difficulty or fun.

[Latest audit and handoff](docs/design/QA_13.md). Use `--refined` for current combat; omitting it retains the historical probe baseline. Earlier iteration documents are historical; this README and QA_13 supersede their menu descriptions. Preserve the old Neon Collector sample at `src/main/main.tscn`.

Commit coherent, verified changes; do not commit engine/cache folders, generated test captures, temp files or local player records. Public-release work still includes export packaging, audio balance/listening, music-rights confirmation, and human tuning of camera speed, rewards and combat difficulty.
