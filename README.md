# MobaBot.io — 0.17 Field Test

A Windows-first, single-player survivor-like with MOBA mouse controls. Build a salvage robot through an eight-stage expedition: independent automatic fire, commanded attacks, aimed skills and deployed machines.

One shared skill pool, 22 rounds, 34 active choices, 15 powered passives, a 48-node run mastery tree, eight equipment slots × five tiers, shops, Ascensions 0–5 and cleared-round checkpoints. Practice mode supports isolated loadout and enemy testing. The old three-round scene remains a regression fixture.

[Current changes and audit](docs/design/QA_17.md) · [Visual ability review](docs/review/abilities.html) · [Prior damage study](docs/design/BALANCE_16.md) · [Quality bar](docs/design/QUALITY_BAR.md) · [Art schema](docs/design/ART_STYLE_SCHEMA.md)

## Play

Double-click **Play MobaBot.io.cmd**. Close an older game window and relaunch to load changes. Fullscreen is the default; Settings can switch to a window.

Fresh clone: run `scripts/setup.ps1` first. The portable Godot 4.7.2 engine is not committed. `scripts/open_editor.ps1` opens the editor; paths with spaces work.

This is a Godot development project, not an exported Windows release. Playing needs no account, API key or online service. [Repository](https://github.com/Timothy-Cao/MobaBot.io).

## Controls

| Input | Action |
| --- | --- |
| Right-click ground / hold | Move / steer; automatic gun continues |
| Right-click enemy | Approach and perform commanded basic attacks |
| A, then left-click | Cursor-priority attack move with range preview |
| S | Stop movement and commanded attacks, never the automatic gun |
| 1–4 / Q W E R T | Nine flexible active/toggle positions |
| D / F | Two movement skills; may swap with each other |
| 5 / 6 | Repair 40 hull / restore 50 energy |
| Tab | Toggle Build; toggle configuration in Practice |
| Esc | Settings / back; cancels targeting first |
| L / hold Space | Toggle camera lock / temporarily recenter |
| Screen edge | Pan with unlocked camera |
| Wheel | Zoom 65–100% |
| M / F2 | Mute / reduced effects |

No WASD. A, Space, Tab and Esc can be rebound in Settings, outside the skill keys and fixed S/L/M/5/6/F2 controls. Settings has six options: sound, reduced effects, camera lock, area quick cast, fullscreen and icon skin.

New skills fit empty keys. If there is no space, the tool is learned and stored. At camp, **Tab → Overview → Arrange skills** swaps keys or fits stored tools. Displaced tools retain their ranks in storage; learned skills cannot be lost for that run. Combat-time binding swaps are disabled. D/F remain a separate movement pair. There is no Y or main-menu Loadout.

Shift + skill previews and casts on release. Reactor drop and ground ultimates use click confirmation unless Area quick cast is enabled. The laser starts immediately; press its assigned key again to cancel. Right-click steers the laser with inertia; it cancels aimed targeting and Siege battery.

Automatic gun and commanded attacks have independent clocks. The gun key cycles machine gun → sniper → off; S never toggles it. Powered passives can turn off when energy runs out. Short committed dashes finish before stopping.

## Skills and Practice

Start with the automatic gun on 1, Impact bolt on Q, Ghost drive on D and charged Phase hop on F. Other positions are empty until discoveries.

Classes are removed from the main game. The first chest offers Return blade alongside randomized options. Orbit cannot be stored while its dependent Ricochet is equipped.

**Practice** is on the main menu. Choose a skill, key and rank 0/5/10; click Fit. Choose an enemy and count (1–100); Spawn resumes combat. Tab returns to configuration. God mode, infinite energy and instant recharge are separate options. Target dummies, ordinary hordes, all three new ranged threats, both wardens and the boss are available. Practice neither spends equipment nor overwrites the real checkpoint.

The roster includes returning blades, two-anchor stuns, center/rim damage tests, displacement, healing commitments, barriers, kill-refund lunges, return dashes, vaults, rolling crashes, artillery and six summon behaviors. Powered passives include machine gun/sniper, orbit, lightning, poison, basic-attack procs, momentum, energy conversion and shoulder drones.

Major summons start at one and reach four through mastery. The tier-5 gun companion and shoulder drones do not consume this capacity.

## Run progression

1. XP offers three numerical upgrades. Effective ranks cap at 10; 5/10 milestones change size, reach, duration, healing or behavior. The choice screen is 80% of its previous linear size.
2. Chests from stronger enemies, every fifth Power level and round completion discover skills. Duplicate actives grant two ranks. Passives with a shared weapon track improve that track by two; other passive duplicates grant 40 field credits. Capped ranks return 20 field credits each. Common/Rare/Epic active variants affect damage/recharge.
3. Mastery starts with one point and earns two each Power level. Spend in Tab; refund freely between rounds. All 48 nodes and prerequisites remain.
4. Equipment is rarer chest loot and the persistent progression track.

Magnet is free utility, not a skill slot. Automatic ranks improve pickup reach and pull speed; mastery adds reach. Bonus drops still require close collection. Ordinary kills retain independent baseline 1/25 credit-cache and 1/15 temporary-boost chances, modified by capped drop bonuses. Cooldown-reset drops refill learned non-ultimate actives regardless of their keys.

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

Every round has 180 seconds of survival, then a miniboss for neutral/loot rounds or a boss for boss rounds. The timer changes to ELITE/BOSS. Defeating it starts 12 seconds of safe collection, with a LOOT countdown; remaining rewards are collected at camp. Choices pause combat, but do not interrupt this collection period. Clearing repairs 20% hull and refills energy. Finish pending chests before advancing. The full 22-round route has a 66-minute minimum survival budget, excluding bosses and menus; checkpoints make it resumable.

XP requirements rise smoothly from +25% through level 5, to +50% at 20 and +75% at 35 (hard cap). This means more XP per level, not a 75% reduction in XP gain.

Eight boss configurations share one industrial body with different pattern sequences. Three existing world sectors use restrained blue-slate, warm foundry and violet-slate floor families. This is not eight new maps. Scattered rail obstacles preserve wide lanes; clearance-aware endpoint routing handles detours. Sparse Arc lancers, Burst batteries and Bomb carriers add aimed pressure. Ascensions add pressure; winning unlocks the next up to A5.

## Equipment and saves

Eight slots: helmet, chest, legs, boots, charm, ring, flower, cape. Five tiers, **no sets, stars or rerolls**.

- Three identical pieces forge one of the next tier. No credit fee. The equipped copy counts toward the three; an equipped item advances automatically when forged.
- Better pieces provide hull and resistance; boots also provide speed.
- Tier 4 grants +1 learned ability rank, once across all equipped pieces—not +1 per piece. Shared passive weapon tracks gain one effective rank; fixed-effect toggles gain 20% primary potency (plate capacity, hop distance, conversion efficiency, damage or protection duration).
- Tier 5 also equips one following machine-gun companion. Additional tier-5 pieces do not add more companions.
- Shop purchases use temporary field credits. Banked credits remain preserved but forging no longer spends them.
- Equipment changes at camp apply immediately; resuming recalculates stats from currently equipped pieces.

Equipment, banked credits and ascension access persist. Skills, numerical ranks/rarity, mastery, XP, consumables and field credits reset for a new run.

**Continue run** restores the last cleared-round checkpoint, including pending chests, keyboard positions and shop stock. Closing mid-fight returns to that camp, not the exact frame. Starting over confirms replacing the checkpoint; losing clears it. Already banked equipment stays.

Save folder: `%APPDATA%/Godot/app_userdata/Workshop Salvager`. New profile: `mobabot_forge.json` (v3). The previous `mobabot_expedition.json` and `mobabot_equipment.json` remain untouched. Migration pools previous items into tier-1 copies by equipment slot and returns duplicates invested in old stars; it stores the complete old snapshot. This deliberately converts set identities rather than awarding new top-tier effects from old set names. Preferences remain `salvage_settings.cfg`; diagnostics remain local in `salvage_runs.jsonl`.

Writes validate and use a temporary file/rename. Failed transactions roll back. Corrupt saves are preserved and block progression writes. Tests never earn permanent loot. No telemetry/cloud sync.

## Art and verification

**Painted** is the new default icon skin; **Base** preserves the original native icons. The generated skill/equipment set has a shared medium-detail cartoon-painting brief, with individual prompts and local provenance. World animation remains native, so gameplay never depends on generated animation. User music still follows menu/camp/combat/boss context.

Run `scripts/check.ps1` for regression; it treats logged engine errors as failures even when Godot exits zero. Additional checks:

- `tests/keyboard_ui_test.gd -- --render`: current menus, placement, forging and HUD captures.
- `tests/painted_art_test.gd -- --render`: original alpha/shape validation, import budget and 128/64/32px comparisons against Base.
- `tests/skill_damage_probe.gd`: stationary and 12-phase moving-target measurements; not human hit-rate estimates.
- `tests/expedition_behavior_probe.gd`: fixed-seed current-class behavior; `-- --soak` uses artificial health for full-route reliability, not balance.
- `tests/skill_visual_test.gd`: skill geometry/state checks; `-- --showcase` renders motion fixtures.

Use these scripts with the bundled Godot executable, `--path . --script res://tests/NAME.gd`; headless is suitable except for image captures. Captures go to ignored `output/`.

Remaining release work: human balance/feel, music-rights confirmation, audio listening, export packaging, wider hardware checks and richer stage identity. Earlier QA documents are historical unless carried forward explicitly.
