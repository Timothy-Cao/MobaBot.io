# Workshop Salvager — v0.8 demo / Stage 1, Levels 1–3

Windows-first survivor-like in Godot 4.7.2, with mouse movement, four toggleable passive slots, three regular actives, an ultimate, movement abilities, one pet and one summon. A little robot breaks machines and turns scrap into weapons. World art, action icons, animation and sound are code-authored; seven generated item illustrations are included locally. Playing needs no API keys or paid service.

## Start here

**Double-click `Play Workshop Salvager.cmd` in this folder.** No terminal or Godot editor needed. Keep `.tools/godot` beside the project: this is a local development launcher, not a standalone exported executable.

Latest QA pass: **0.8 Demo**. Automatic pulses no longer cause persistent shake; damage recoil is small and player-only. Fixed dash lean, reduced-effects tank flashes, stale held steering after menus, blocked mobility consuming charges, aim-readiness colors, charge warnings and arena-edge player visibility. Full test/capture evidence and tomorrow's handoff: [QA_08.md](docs/design/QA_08.md). Relaunch to load changes; an already-open older window does not hot-update.

Play one Stage with three Levels: Loading bay has 75 seconds of mobs only; Assembly line has 90 seconds of harder mobs plus two required wardens; Reactor floor has 90 seconds of mobs followed by the Foreman. The first two clears offer an ability promotion or reactor cache. Defeating the Foreman ends the demo—there is no Level 4. Target: roughly five combat minutes, with human choice time still to be measured.

Carry the whole build between levels. Rank ceilings rise from 5 to 8 to 10, putting the first transformation in Level 1 and final milestones in Level 3. HUD “Power” means XP growth, distinct from encounter Level. Wardens teach committed charges and marked ground attacks; the Foreman combines these with a projectile fan and a faster half-health phase. Gold EXPOSED recovery windows take +50% damage. Walking can evade the telegraphs; blink is optional insurance.

New in v0.7: labelled edge pointers find required enemies; the nearest objective owns the boss bar. Wardens now have distinct plow/barrel silhouettes. Damage identifies its source and defeat explains a relevant response. Boss cues are protected from loot feedback. Tab navigates menu buttons normally; hold-Tab inspection remains in combat. Audit and comparisons: [BLINDSPOT_AUDIT_07.md](docs/design/BLINDSPOT_AUDIT_07.md).

Coral bumpers chase, purple wedges charge, and plated tanks take more hits. Warned pressure packs include faster runners and tougher elites. Spawns begin off-screen. Ordinary/charger/tank/final-boss drops scatter 3/10/20/72 scrap dots; wardens drop 30, with extra loot from pressure elites. Difficult enemies also drop energy cells and some hull patches. Remaining earned scrap and supplies are banked when a level clears.

- Right-click: move to a point; hold to steer. S: stop walking immediately (a committed short dash still finishes). **No WASD movement.**
- Q: Homing salvo; W: Shock ring; E: Safety shell; R: Overdrive ultimate (default Relaxed preset).
- D: speed boost. F: charged blink. T: deploy one turret, replacing the old one.
- 1–4: toggle the four equipped passives. The pet is automatic. Some toggles consume energy over time; others are free.
- Quick-cast on ability press. For an indicator, hold Shift while pressing/holding an ability, then release the ability key to cast. Esc or right-click cancels the preview.
- 1 / 2 / 3 or click: choose an upgrade. Menus also support focus navigation and Enter.
- Esc: open settings (or cancel an aimed cast / close inspection first). Switching away also pauses a human-controlled run.
- Hold Tab: inspect loadout, upgrades and stats; release to return without losing pending choices. Inspection pauses this solo game.
- Mouse wheel: zoom between 65% and 100%. The original view is the closest limit; the widest view shows about 54% more world width. Settings also has a zoom slider.
- Restart through the pause or results menu. R never restarts.
- M: sound toggle. F2: reduced effects (no shake or hit-color flashes, fewer fragments).
- Close the window to exit.

The workshop is 5360x3400 world units, with a following, zoomable camera, painted bays and floor panels. Gold minimap markers are scrap caches: approach one to release eight scrap. Paths between caches are open; floor markings are not obstacles. The map has distant boundaries and is not infinite. Each level starts in a different sector of this same arena, not a separate obstacle map.

**Main menu > Loadout**: select Relaxed or Precision, customize individual abilities and four passive slots, cycle the equipped pet, and rebind keys. Letters and numbers are supported; occupied keys swap. S and M are reserved. R/D/F are default keys for fixed ability roles, but those keys can be rebound. Changes apply to the next run. Precision replaces the easy spells with Rail spike, Scrap mortar, Ram strike and Foundry lance; it uses a dash and attack drone. No unlock grind in this prototype.

Build → Upgrades separates Skills, Weapons and Utility. Seven equipped cast slots and eight weapon/support tracks each have ten ranks. Damage/rate bonuses progress +20/25/30/35/40%, then continue to +65% at rank 10; ranks 5 and 10 add milestones such as larger rings, longer volleys, extra shield hits and wider beams. Click each rank for exact before/after numbers. Offers exclude unsupported mechanics and include a focused continuation when possible. This is a run-rank browser, not a permanent unlock tree.

Magnet is separate, free utility: no passive slot, no energy drain, no combat choice spent. Start at 250 px reach and gain a free rank every three level-ups, reaching 650 px with faster pull speed. Rank 5 sweeps all scrap every 15 seconds. Legacy saves with Magnet in a passive slot migrate that slot to the defensive Recoil shell; other equipment and keys stay intact.

Energy starts at 100 and regenerates at 8/second before toggle upkeep. Q/W/E/R/T generally cost energy; D/F movement and basic automatic attacks stay free. Reactor and cell ranks improve regeneration and capacity, with milestone boosts. Emergency cell trades one hull for 55 energy (70/85 at its milestones), never your last hull point. Boss rarity promotions remain Common → Rare → Epic, separate from numerical ranks. Cooldowns recover charges one at a time, preserve progress through upgrades, and pause in menus. All run ranks and rarity reset next run.

Default seed: 2407, fixed for repeatable decisions. No metaprogression or mid-run save yet. Preferences, keybinds, loadouts and completed run summaries persist locally in `%APPDATA%\Godot\app_userdata\Workshop Salvager`. Nothing is uploaded.

Completed v0.7 runs also record the last 32 hull-hit causes and time spent in combat, choices, inspection and pauses. These local diagnostics help find unclear damage and excessive menu time; they do not record keystrokes or upload analytics.

## Develop and verify

From PowerShell **in this project folder**:

```powershell
.\scripts\open_editor.ps1
```

F5 runs Workshop Salvager. Its main scene is `src/salvage/workshop.tscn`. You can also launch directly:

```powershell
.\scripts\run_game.ps1
```

Run the original sample test, salvage regressions, MOBA controls/ability tests, stage/resource tests, simulated runs and a dense legacy combat stress check:

```powershell
.\scripts\check.ps1
```

If `.tools/godot` is missing after cloning or moving the repository, restore the portable editor with:

```powershell
.\scripts\setup.ps1
```

To refresh GPU-rendered screen fixtures, run `scripts/capture_screens.ps1`. It opens brief game windows and writes twenty-nine captures to `output/playtest-v08`. `scripts/capture_motion_qa.ps1` adds eight targeted motion/edge/effect fixtures. These are constructed fixtures; `completed-run.png` shows an actual automated run. Earlier screenshots remain in their original versioned folders.

Reproduce a rendered automated playthrough:

```powershell
& '.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe' --path . -- --autoplay --quit-on-result
```

Optional arguments after `--`: `--seed=2408`, `--fixture=home` (or gameplay, upgrade, pause, result, build, stats, world, loadout, passives, keys, abilities, loot, stage_reward, settings, zoom), `--capture=C:/absolute/path.png`, `--capture-on-result`. Screenshot directories must exist; screenshots require real rendering, not `--headless`.

## Code map and scope

- `src/salvage/run_model.gd`: deterministic combat, spatial collision index, pressure waves, supplies and upgrades.
- `demo_campaign.gd`: three-level demo pacing, sector transitions, wardens, final-boss state machines and test-only steering policy.
- `progression.gd`: ten-rank curves, milestone descriptions and exact preview values.
- `moba_kit.gd`: loadout catalog, validation, charges, targeting, spells, pets and summons.
- `workshop.gd`: input, state transitions, settings and test hooks.
- `workshop_art.gd`: original shapes, motion, telegraphs and impact effects.
- `workshop_ui.gd`: menus, HUD and upgrade cards.
- `build_view.gd`: upgrade graph, rank previews and source-linked stats.
- `loadout_view.gd`: pre-run equipment, passive/pet selection, presets and key editor.
- `ability_icon.gd`: consistent square code-native action icons; `ability_glyph.gd` retains the earlier symbol vocabulary.
- `mini_map.gd`: world/camera position and remaining caches.
- `synth_audio.gd`: synthesized cues and bounded voice pool.

One open arena with three sectors/levels, 14 selectable ability definitions, six combat passive choices, two pets, fifteen ten-rank combat tracks and a five-rank free Utility track. Three ordinary enemy types, pressure variants, two warden move sets and a final boss combining their lessons. No music, metaprogression, Steam integration or packaged standalone release. No obstacle navigation, attack-move command or full MOBA animation-cancelling system yet. Summons cannot be attacked in this prototype. Matching Godot export templates are not installed; they are unnecessary for the included local launcher. Keyboard/mouse is the main mode; no controller or WASD support in this version of the salvager.

## First playtest

Try Relaxed first, then optionally Precision from Loadout. Send one combined reaction: movement/stop feel; first upgrade that felt different; most confusing hit; dullest stretch; best power moment; whether the final boss felt fair. Automatic runs validate operation, not your experience or final balance. Further campaign progression is frozen until this demo is playtested.

## Earlier sample and research

The original **Neon Collector** sample is preserved at `src/main/main.tscn`. Open it and press F6; F5 always runs the new game. Its smoke test remains in the check script.

Current direction, research, north stars and scope: [MVP_NORTH_STARS.md](docs/design/MVP_NORTH_STARS.md). Priorities and playtest questions: [MVP_TASK_BOARD.md](docs/design/MVP_TASK_BOARD.md). Previous rank/utility numbers: `docs/design/ITERATION_05.md`; earlier design/references: `docs/design/ITERATION_04.md` and `docs/design/MOBA_MODE_03.md`. Shared art palette, vocabulary, prompt template and audit: `docs/design/ART_STYLE_SCHEMA.md`. Verification: `docs/design/IMPLEMENTATION_STATUS.md`. Earlier research: `output/pdf/godot-survivor-research.pdf`; original design: `docs/design/ART_FIRST_DESIGN.md`; learning notes: `docs/GODOT_WORKFLOW.md`.
