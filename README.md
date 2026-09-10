# MobaBot.io — 0.18 Vanguard

New session: [current handoff](SESSION_HANDOFF.md). Human testing: [playtest protocol](docs/design/PLAYTEST_PROTOCOL.md), with a read-only result summary via `scripts/read_playtest.ps1`. Freeze the build while testing; results finalize on victory/defeat, not continuously.

A Windows-first, single-player survivor-like with MOBA mouse controls. Build a salvage robot through an eight-stage expedition: independent automatic fire, commanded attacks, aimed skills and deployed machines.

New expeditions use the fixed **Vanguard** kit and non-modal skill progression. The 22-round route, 48-node run mastery tree, eight equipment slots × five tiers, shops, Ascensions 0–5 and cleared-round checkpoints remain. Existing 0.17 checkpoints retain their shared-pool rules rather than losing learned skills. Legacy abilities remain in Practice. Marshal, Racer and offline progression are not implemented.

[0.18 changes, verification and known limits](docs/design/QA_18.md) supersedes the older shared-pool controls and progression below for **new runs**.

[Vanguard animation assessment and asset sources](docs/design/VANGUARD_ANIMATION_REVIEW_18.md): per-skill maturity, current motion definitions and a reproducible 48-second Godot review reel. Latest pass separates W/R silhouettes, sharpens E/hammer contact, animates construct deployment/support and removes duplicate legacy impact rings. No combat balance changes or new bitmap pack.

## Current Vanguard controls

Survival rounds are now **two minutes**, followed by the guardian/boss and 12-second collection. Vanguard adds Breacher charges, Mender repair support and Scattergun fans; all three are available in Practice. Enemy HP/damage rise each round as well as each stage, with capped movement/specialist-count growth. Hits below 50% hull have amber edge feedback; below 25%, stronger red edges and a heavier sound. Empty-energy casts, special supplies, big XP pickups, mode changes and construct deployment have distinct cues. [Pressure and sound audit](docs/design/PRESSURE_AUDIO_18.md).

Chests now show their actual contents: a brief combat notification plus a saved round-clear receipt with item icons and quantities. The opening reveal is skippable; Reduced effects shows results immediately. Field credits buy equipment at the end of **every stage**, including Stage 1 (not after each individual round). Field credits reset on a new expedition; banked equipment persists. [Reward presentation and economy notes](docs/design/REWARD_REVEAL_18.md).

Random special supplies are now one-tenth as frequent by default. Luck mastery provides stronger improvements, capped at 5× that new baseline. Magnet starts at 65 units and caps at 320 (the turret's normal range). Guaranteed boss rewards and end-of-round collection remain unchanged.

Stage pressure: enemy health/damage scale consistently, including surges and ranged units, with the additional per-round growth described above. Main bosses retain 50× their earlier HP and main-boss encounters add 25% incoming damage before stage/round scaling. XP remains at one-third. Equipment tiers have distinctive names and silver/green/blue/violet/gold glow frames with tier pips; saved items/stats are unchanged. See BALANCE_16 for the tuning curve and boss-duration caution.

Latest milestone pass: universal skill points learn **or** upgrade any eligible tool. All twelve tools (including MG/hammer) must have earned rank 5 before any rank 6+ purchase. Existing higher ranks are preserved; Practice presets bypass the gate. Future Vanguard XP gain is one-third of the preceding build; current XP/ranks are retained.

D rank 5 reduces upkeep; rank 10 permits casting while driving. F rank 5 reduces energy/recharge, rank 10 adds a landing blast. E travels 209 / 292.6 / 397.1 units at ranks 1 / 5 / 10. Towers gain visible hardware and stronger milestone effects. Settled nearby XP drops coalesce under load without losing value; fresh loot showers and flying pickups remain separate.

E now rebounds once from walls: reflected direction, 2× the unused dash distance, at 1.5× dash speed. Another wall stops the rebound; enemy contact retains its normal blast. No extra charge or energy cost.

The complete Vanguard icon family now uses the approved painterly MOBA direction: QWER plus D/F, 1–4, hammer and MG, all imported at 128px. New artwork is UI-only; combat animations and mechanics are unchanged. Exact new prompts and source hashes: `assets/vanguard_icons/REMAINING_PROVENANCE.md`.

Interface follow-up: Painted icons are always used; QWER has a new painterly MOBA set imported at 128×128. Settings has sound (0=mute, 100%=full mix), camera-speed and in-game mouse-speed sliders; no icon-skin selector. Empty buttons no longer create blank tooltips.

Camera lock **on** follows only the player; screen edges cannot pan it. Switching lock on immediately snaps home. **Unlocked** enables edge-panning; Space temporarily recenters. Hold left-click/drag on the minimap to inspect: releasing returns to the player when locked, otherwise keeps that location. Focused gameplay confines the cursor in either mode; menus and Alt-Tab release it. Mouse speed applies only during confined gameplay, not to the desktop or menus.

Vanguard icons display through a reversible 32×32 pixel-grid filter, 15% less saturation and slightly lower brightness. Original artwork and 128px imports remain intact. Modules 1–4 show an active ring instead of persistent status words (steady in reduced effects). HUD defaults to 90%; Settings → Options has one 70–100% size slider. Settings → Controls sets Quick/Normal separately for 1–4/QWER. Default Normal: 2/3/4/R; others Quick. Normal waits for left-click; Esc/right-click cancels. Non-targeted toggles still act immediately.

Practice: Build has one shared **1 / 5 / 10** choice for all tools, hammer and MG. Player retains the four test modifiers plus Damage numbers. Enemies selects type/count for cluster placement. No Session tab, per-skill rank selectors or Clear button. **B** arms a single target dummy; **C** clears enemies without opening a menu (an explicit system-key rebind has priority). Reset remains and resets combat at the selected kit rank. This supersedes older Practice descriptions below.

Vanguard 1 always spins at the fast (10.2 rad/s) speed. Its toggle changes near/far radius, not rotation speed.

The commanded hammer upgrades from rank 1–10 through the HUD's LMB tile. Rank 5 expands its reach and sweep; rank 10 allows swings while moving, including attack-move. Practice's Build rank selector includes Hammer and Gun separately. Vanguard damage has pronounced rank-5/10 spikes; see `docs/design/BALANCE_16.md` for the measured curve.

HUD: grouped 1234 modules on the left, central QWER, then D/F and mouse weapons. Flat full-width upgrade bars sit above eligible icons. QWER is only slightly larger than the other icons. Consumable 5/6 buttons are hidden from this HUD; existing keyboard shortcuts remain.

Right click moves or approaches a target for hammer attacks. Left click swings the hammer; A provides attack-move. S stops movement and commanded attacks, never the permanent automatic gun. Q is Impact bolt, W Core strike, E Body slam, R Reactor drop. Hold D for Ghost drive; below rank 10, release it before casting. F blinks. Modules: 1 orbit near/far, 2 Bulwark, 3 Reserve, 4 Overclock well. T has no Vanguard ability.

Backtick (`) toggles the gun; MG shows OFF while disabled. Q/W each store two charges, with charge pips on the HUD; Q recharges in 4s at rank one before bonuses. Close orbit spins three times faster than before and hits more frequently. Camera lock defaults to L and can be rebound in Settings → Controls to keyboard or mouse (a mouse binding replaces that button's gameplay action).

MG ranks 1–10 increase damage and fire rate. Before rank 5, E/body slam and held D/Ghost drive suspend its fire; rank 5 removes that restriction. Walking and S never disable it. At rank 10 every fifth successful shot deals double damage, reaches 450 (normally 265), and pierces up to four targets. Bulwark's gun shares MG damage/rate/milestones with its own shot counter and 320/520 range; its own skill ranks improve hull and pulse. Rank-10 MG tile shows the next shot in its five-shot cycle.

E also stores two charges. Walls stop movement, including E, but no longer stop friendly/enemy shots or enemy laser beams in the current expedition and Practice. Character hull/energy bars sit below the feet.

Custom native cursors: cream/teal menu pointer, open combat crosshair, brass diamond while aiming or placing Practice enemies. Interactive UI restores the menu pointer; click positions and camera controls are unchanged.

Start with gun/Q/D/F. Levels and chests grant universal skill points. Click a small HUD **+**, or Ctrl + the skill key. Gun and hammer have clickable upgrade controls. Choices do not pause combat; no ability replacement or binding swaps in this fixed kit. Tab toggles Build, Esc opens Settings, wheel zooms, L toggles camera lock and Space recenters.

Practice uses a collapsible left dock. Choose a kit rank or individual rank, set player modifiers, and place enemies in clusters with a paused preview (default: one target dummy). Left click commits; Shift repeats; right click/Esc cancels. Tab resumes/configures. The Legacy laboratory preserves the older fitting tool. Practice grants no loot and cannot write campaign progress.

Practice → Enemies → Target dummy provides an immortal target with per-target burst damage/DPS. Three seconds without damage resets its readout. DPS uses first-to-latest-hit simulation time, excluding the idle grace; one instantaneous hit shows no DPS. Session → Damage numbers toggles floating hit values (on by default); Reset measurement clears meters. Automatic gun hits count, so leave its range to end a burst.

The sections below retain 0.17 compatibility details; where controls/skills/progression differ, this section and QA_18 take precedence. Equipment, route and save locations are unchanged.

[Next development brief](docs/design/NEXT_SESSION_BRIEF_17.md) · [Documentation index](docs/README.md) · [Current changes and audit](docs/design/QA_17.md) · [Visual ability review](docs/review/abilities.html) · [Prior damage study](docs/design/BALANCE_16.md) · [Quality bar](docs/design/QUALITY_BAR.md) · [Art schema](docs/design/ART_STYLE_SCHEMA.md)

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

Every revised round has 120 seconds of survival, then a miniboss for neutral/loot rounds or a boss for boss rounds. The timer changes to ELITE/BOSS. Defeating it starts 12 seconds of safe collection, with a LOOT countdown; remaining rewards are collected at camp. Legacy choices pause combat but do not interrupt collection; Vanguard skill points remain non-modal. Clearing repairs 20% hull and refills energy. The full 22-round route has a 44-minute survival budget, excluding bosses and menus; checkpoints make it resumable.

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
