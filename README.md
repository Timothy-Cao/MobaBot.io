# MobaBot.io — 0.15 Expedition

A Windows-first, single-player survivor-like with MOBA mouse controls. Build a salvage robot through an eight-stage expedition: independent automatic fire, commanded basic attacks, aimed abilities and deployed machines.

**Implemented:** three classes, 22 rounds, chest discoveries, 34 active choices, 15 powered passives, a 48-node mastery tree, 40 equipment items, shops, Ascensions 0–5 and between-round checkpoints. The old three-round scene remains a regression fixture, not the normal entry point.

[Research and design](docs/design/EXPEDITION_RESEARCH_14.md) · [0.14 systems](docs/design/QA_14.md) · [0.15 art pass](docs/design/QA_15.md) · [Quality bar and current ratings](docs/design/QUALITY_BAR.md)

0.15 focuses on skill motion and icon recognition: returning blades, directional pulls/cuts, strike descent, deployable machinery and distinct movement symbols. The quality bar separates automated verification from player feel; it is not a claim of finished balance or public-demo polish.

## Play

Double-click **Play MobaBot.io.cmd**. Close an older game window and relaunch to load this version.

Fresh clone: run `scripts/setup.ps1` first. The portable Godot 4.7.2 engine is intentionally not committed. Use `scripts/open_editor.ps1` for the editor. Paths containing spaces work.

This is a Godot development project, not an exported Windows release. No accounts, API keys or online services are needed to play. [Repository](https://github.com/Timothy-Cao/MobaBot.io).

## Controls

| Input | Action |
| --- | --- |
| Right-click ground / hold | Move / steer; automatic gun continues |
| Right-click enemy | Approach and perform commanded basic attacks |
| A, then left-click | Cursor-priority attack move, with range preview |
| S | Stop movement and commanded attacks, never the automatic gun |
| Q / W / E | Three active slots; Q starts as an aimed Impact bolt |
| R | Ultimate; default Core cutter channels up to 5s, right-click steers with inertia, R cancels |
| D / F | Speed/escape and mobility; default Ghost drive / charged Blink |
| T | Deploy a major summon; replaces oldest when capacity is full |
| 1 | Machine gun → sniper → off |
| 2–4 | Powered passive modes; energy upkeep while enabled |
| 5 / 6 | Repair 40 hull / restore 50 energy; two of each initially |
| Hold Tab | Build: Overview and Mastery; also accessible between rounds |
| Esc | Settings or back; cancels targeting first |
| L / hold Space | Toggle camera lock / temporarily recenter |
| Screen edge | Pan with unlocked camera |
| Wheel | Zoom 65–100% |
| M / F2 | Mute / reduced effects |

No WASD. Settings contains four options and a separate keybinding page. Ability bindings can swap; reserved movement/menu/item inputs remain protected. Changes to bindings apply next run. Shift + ability previews and casts on release. Reactor drop and non-laser R use confirm targeting unless Area quick cast is enabled. Right-click cancels targeting; during Siege battery it cancels the channel.

The automatic gun and commanded basic attacks have separate clocks. Energy depletion can switch powered passives off, including the gun; their keys re-enable them. S does not switch the gun off. Committed short dashes finish before stopping.

## Classes and skills

All classes start with the auto gun and Q; D/F remain immediate safety tools. W/E/R/T and passive slots 2–4 are discovered in chests, not unlocked by a timer.

- **Gunner:** long-range basics, brief movement burst after commanded fire. Preferred discoveries: Return blade, Core strike, Line sentry.
- **Brawler:** short-range heavy basics, more speed, resistance and regeneration. Preferred discoveries: Rim cutter, Guard sweep, Pulse anchor.
- **Engineer:** two major summons and construct bonuses. Preferred discoveries: Gravity well, Repulsor, Echo sentry.

Loadout edits the selected class's preferred first discoveries. It does not immediately grant every skill. Q is fixed at run start; later chests can replace it. Fifteen passives include the retained gun/orbit/lightning/poison family and seven additions: Split barrel, Plate magazine, Third contact, Flywheel, Hop drive, Life converter and Shoulder drones.

The new active roster includes returning blades, two-anchor stuns, center/rim damage tests, directional displacement, healing commitments, barriers, kill-refund lunges, return dashes, vaults, rolling crashes, aimed artillery and six summon behaviors. Default R remains the steerable laser. See the [mechanic inventory](docs/design/QA_14.md) for the exact mapping.

Major summon capacity starts at one, or two for Engineer, and can reach four through mastery/gear. Small mounted drones do not consume it. One separately equipped pet remains available. Pulse anchor swaps positions and Repair anchor teleports you when cast near an existing matching construct, using the normal charge and energy cost.

## Run progression

1. XP gives numerical upgrade choices. Ranks cap at 10; ranks 5 and 10 improve actual size, reach, duration, healing or behavior.
2. Chests from stronger enemies, every fifth Power level and round completion unlock or replace skills. Duplicate actives grant two ranks; overflow becomes 20 field credits per excess rank. Duplicate passives grant 40 field credits. Replacement resets that slot's rank. Common/Rare/Epic variants affect active damage and recharge; selected complex abilities have lower discovery weights.
3. Mastery starts with one point and earns two per subsequent Power level. Its 48 nodes cover Armament, Mobility, Hull, Reactor, Salvage and Command. Spend in Tab; refund freely between rounds. Prerequisites and rank caps apply.
4. Equipment is a rarer chest outcome and the permanent progression track.

Magnet remains free utility outside passive slots. Its automatic ranks improve pickup reach and pull speed; mastery adds more reach. Bonus drops still require close collection. Ordinary kills retain independent baseline 1/25 credit-cache and 1/15 temporary-boost chances, modified by capped drop bonuses. Strong enemies scatter larger rewards.

### Route

| Stage | Rounds | Afterwards |
| --- | --- | --- |
| 1 | Neutral, neutral, boss | Camp |
| 2 | Neutral, neutral, boss | Shop |
| 3 | Neutral, boss, loot | Camp |
| 4 | Neutral, boss | Camp |
| 5 | Neutral, boss | Shop |
| 6 | Neutral, boss, neutral, boss | Camp |
| 7 | Loot, neutral, boss | Shop |
| 8 | Boss, final boss | Finish |

Neutral rounds last 50s, loot rounds 40s, and boss rounds have a 35s lead-in followed by the fight. Modal choices pause combat. A clear gathers remaining rewards, restores 20% hull and refills energy. Finish pending chests before advancing.

Eight named boss configurations share the industrial boss body but use different pattern sequences. The final boss adds hull and combines learned patterns. Enemies scale across stages; higher ascensions add damage, speed, hull, resource pressure and tighter recovery windows. Winning unlocks the next ascension up to A5. Lower ascensions remain replayable for gear.

The world reuses three sectors of the existing large arena. New barriers block projectiles and ordinary movement; actors use local end-of-wall detours. Vault/phasing actions can cross walls. This is not eight new maps or a general navigation-mesh implementation.

## Equipment and saves

Eight slots: helmet, chest, legs, boots, charm, ring, flower, cape. Five sets: Courier, Bastion, Dynamo, Relay, Reclaimer. Forty original native icon variants use eight silhouettes and controlled material/motif changes—not forty separate paintings.

- Equip only owned items. Only equipped pieces contribute stats.
- Sets activate at two and four pieces. Hover the set label for effects.
- Reroll the bonus for 35 banked credits; the result can improve, worsen or stay equal.
- Star N costs N spare copies and 25 × N credits, up to five stars. Each star adds 20% of the base stat. One owned copy remains.
- Higher-tier accessories have an individual specialty even without a set.
- Field credits buy items during the three shops; those purchases enter the permanent collection.
- Banked credits pay workshop costs. Cleared-round loot banks separately from temporary field money.
- Equipment changes between rounds apply immediately. Changes at home apply to new runs.

Equipment, banked credits, class preferences and ascension access persist. Ability discoveries/ranks/rarity, mastery, XP, consumables and field credits reset for a new run.

**Continue run** restores the last cleared-round checkpoint, including pending chests, build, consumables and shop stock. Closing during a fight returns you to that camp, not the exact combat frame. Starting over asks before replacing the checkpoint. A lost run clears it; already banked gear stays.

Save folder remains `%APPDATA%/Godot/app_userdata/Workshop Salvager`. New collection/checkpoint: `mobabot_expedition.json`. The old `mobabot_equipment.json` is read-only migration input and remains intact; the new snapshot records the mapping and original collection. Preferences remain `salvage_settings.cfg`; local diagnostics use `salvage_runs.jsonl`. No telemetry or cloud sync.

Writes use validation, a temporary file and rename. Failed transactions roll back. Corrupt/unreadable saves are preserved and visibly block progression writes. Automated tests and captures never earn permanent loot.

## Art, audio and verification

One code-native icon/actor/effect family, plus the existing generated foundry title illustration. [Art schema](docs/design/ART_STYLE_SCHEMA.md). Older generated equipment illustrations remain archived with provenance, not mixed into the HUD. User music plays by menu, camp, combat and boss context.

Run `scripts/check.ps1` for the complete suite. It checks engine errors even when Godot exits with code zero. Additional probes:

```powershell
.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/expedition_behavior_probe.gd
.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/expedition_behavior_probe.gd -- --soak
.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/mobabot09_behavior_probe.gd -- --refined
.\.tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/mobabot10_behavior_probe.gd -- --refined
```

The soak uses artificial health for completion/performance, not balance. Render menus/skills with `tests/expedition_ui_test.gd -- --render` using the normal renderer; captures go to ignored `output/`.

Remaining release work: human balance/feel testing, audio listening, music-rights confirmation, export packaging, wider hardware checks and richer stage identity. See [QA_14](docs/design/QA_14.md). Earlier QA/design documents describe historical versions unless explicitly carried forward.
