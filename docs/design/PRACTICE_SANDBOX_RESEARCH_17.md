# Practice Sandbox Redesign Research

Status: **owner-requested research and implementation notes, 9 September 2026. Nothing in this document is implemented merely because it is proposed here.** The current behavior remains the contract in [`QA_17.md`](QA_17.md) until a later implementation is verified.

Routing: this is Phase 1 in [`NEXT_SESSION_BRIEF_17.md`](NEXT_SESSION_BRIEF_17.md) and the first intended implementation workstream.

## Owner direction

The Practice tool needs a cleanup pass focused on quickly testing builds and combat interactions. The owner wants:

- a left-side UI for choosing complete loadouts, changing relevant stats and selecting enemies;
- mouse placement of selected enemies in the arena;
- a simple, fairly small test map with a few large and medium rocks;
- research into useful ideas from League of Legends' Practice Tool, Bloons TD 6 Sandbox and other focused testing modes;
- a tool that makes many comparisons easy without becoming a second progression mode.
- class selection as the normal build choice; players do not assemble arbitrary mixed kits in the primary Practice flow;
- old, legacy and unreleased tools remain confined to Practice until the owner explicitly releases them.

This is a request to research and record the best direction for the home development agent. It is not authorization to replace the current Practice implementation in this notes session.

## Current MobaBot baseline

The existing Practice mode already has a valuable foundation:

- fit any discoverable skill to a legal key at rank 0, 5 or 10;
- spawn 1, 5, 10, 25, 50 or 100 of a selected dummy, ordinary enemy, ranged threat or boss;
- independently enable god mode, infinite energy and instant recharge;
- clear threats and effects, restore resources and use Tab to switch between setup and play;
- never spend equipment, award permanent loot or replace the real checkpoint.

The main limitation is interaction, not the absence of a sandbox. Setup currently occupies a large two-column overlay, fits one skill at a time and automatically arranges spawned enemies around the player. It cannot assemble a whole kit at a glance, change a focused set of combat variables, place a test subject at a chosen world position or show measurement results.

## What the references suggest

These references inform general testing-tool principles, not MobaBot content or visual design.

### League of Legends Practice Tool

Riot's additions separate precise test controls by subject: dummy health and defenses, game-clock advancement, neutral-monster spawning and progression-stack controls. This is stronger than a single generic difficulty slider because a tester can change one variable while holding the rest constant. Source: [League of Legends Patch 10.8 Practice Tool additions](https://www.leagueoflegends.com/en-gb/news/game-updates/patch-10-8-notes/).

Useful translation for MobaBot:

- expose a short list of explicit player, enemy and session variables;
- keep reset/refill/clear actions close to the test controls;
- provide common scenarios as one-click presets, while retaining individual overrides;
- do not reproduce League's exact controls or Summoner's Rift layout.

### Bloons TD 6 Sandbox

Ninja Kiwi's Update 53.0 notes pair zero-cost Sandbox experimentation with more detailed per-tower performance summaries such as damage and value. The useful idea is that a sandbox should remove economy anxiety and make the result of a build comparison visible. Source: [Bloons TD 6 Update 53.0 developer announcement](https://steamcommunity.com/games/960090/announcements/detail/525367916192858220).

Useful translation for MobaBot:

- Practice selections use temporary copies and consume nothing;
- show damage by skill/summon and a compact DPS result after a test;
- keep performance data separate from the live combat HUD so measurement does not bury feel and readability;
- never let Practice rewards or configurations leak back into campaign progression.

### Warframe Simulacrum

Digital Extremes exposes focused state controls including invincibility, paused AI and killing spawned enemies in the Simulacrum. Its later patch history also records a case where paused AI incorrectly enabled a damage bonus and produced inauthentic loadout results. Sources: [Warframe Update 21.1.0](https://www.warframe.com/es/patch-notes/pc/21-1-0) and [Warframe Update 27.3.0](https://www.warframe.com/en/patch-notes/pc/27-3-0).

Useful translation for MobaBot:

- include pause/resume AI and clear controls because they make setup repeatable;
- visibly label every nonstandard test condition;
- mark results as **modified** when god mode, frozen AI, instant cooldown, free energy or non-1× time is active;
- do not treat DPS measured under a modified state as comparable to a normal combat result.

## Recommended design

Use one persistent, collapsible **left dock over the live arena**, not another full-screen menu. At the current 960×540 logical size, begin around 300–330 pixels wide and validate the actual width in a rendered fixture. Tab hides or restores the dock without resetting the test.

Do not show every internal stat simultaneously. Four compact tabs or accordion groups provide enough breadth without becoming a developer inspector:

| Section | First-version controls | Deliberately deferred |
| --- | --- | --- |
| **Build** | Static kit/class, Q/W/E/R/D/F/1–4 overview, permanent passive/basic, rank preset, individual rank overrides, equipment tier/preset | Arbitrary internal resource IDs, invalid cross-kit combinations, save editing |
| **Player** | Current/max hull and energy, damage, attack speed, movement speed, cooldown recovery, energy regeneration, pickup radius; god/free-energy/instant-recharge toggles | Every derived or hidden coefficient on the main surface |
| **Enemies** | Type, count, ascension or stage-strength preset, behavior state and placement formation; arm placement with the mouse | A full wave-authoring language or campaign editor |
| **Session** | Pause/resume, heal/refill, clear enemies, clear projectiles/effects, reset scenario, 0.5×/1×/2× time, measurement reset | Saving rewards, changing unlocks or writing campaign state |

The dock header should always show **Pause/Resume**, **Reset**, **Clear** and a visible `NORMAL` or `MODIFIED TEST` state. Advanced controls stay collapsed by default. Values changed from their normal preset receive a small dot or tint and have a one-click reset.

### Full-loadout handling

The first useful workflow is choosing one of the static-kit prototypes—Vanguard first, then Marshal or later kits as they are implemented—and seeing the full row immediately. **The normal user choice is the class, not each individual ability.** A tester should be able to:

1. choose the kit or a saved Practice-only preset;
2. set all skills to rank 0, 5 or 10 with one action;
3. override an individual slot's rank;
4. choose a small equipment/stat preset such as Starter, Mid-run or End-run;
5. apply once, then begin a clean measurement window.

Do not offer unrestricted skill mixing in the primary flow. Old, stashed and unreleased tools may exist only in a clearly labeled **Practice prototypes / legacy** area until the owner explicitly releases them; they never enter ordinary class selection, progression or loot by existing here. If arbitrary fitting remains necessary for regression, keep it inside that testing-only area.

Practice presets, if added, belong in a separate Practice-only file and must never alter `mobabot_forge.json`, collection data, checkpoint state, equipment ownership or unlocks. **Copy current campaign build into Practice** can be one-way; Practice can never write the result back.

### Enemy mouse placement

Selecting **Place** turns the world cursor into a placement preview:

- show enemy silhouettes/footprints and the selected count before committing;
- left-click places the preview at the world position;
- right-click or Esc cancels placement;
- Shift + left-click repeats the current placement for rapid setups;
- invalid rock/edge overlap displays red and does not spawn;
- placements use the world cursor and simulation coordinates, never the detached camera center;
- leave simulation paused while arranging unless **Live placement** is explicitly enabled.

For the first version, offer four formations: **Single/Point**, **Line**, **Ring** and **Cluster**. Point places one enemy regardless of the count control; the other formations use the chosen count. Formation spacing should respect enemy body sizes and should never silently stack bodies into unavoidable damage.

One-click scenario presets make common tests faster:

| Preset | Purpose |
| --- | --- |
| Single dummy | Aim, animation, damage and cooldown baseline |
| Armored dummy | Compare sustained and anti-heavy damage |
| Ten weak enemies | Wave clear, grouping and readability |
| One ranged threat | Dodge/body-slam/terrain interaction |
| Mixed pressure | One melee group plus one ranged threat |
| Boss | Displacement immunity, burst windows and survival |

Presets should fill the controls and preview the placement; they should not instantly spawn an unseen arrangement.

### Test map

Build one small dedicated greybox rather than reusing an Expedition sector or creating several ornate rooms. Recommended ingredients:

- a generous open center around the initial player position;
- three or four large, thick rock masses;
- four to six medium rocks, with no decorative pebble collision;
- one open long-range lane for Q/W/projectile testing;
- one broad choke and one thick obstacle for Repulsor, body slam, pathing and Phase hop tests;
- enough clear perimeter space for Ring/Cluster placement and summon networks;
- restrained floor marks at useful range intervals, with no implication that they are collision boundaries.

The rocks should have substance and mixed natural/partially rigid shapes, matching the owner's broader terrain direction, but this map is an instrument rather than a showcase. Avoid a maze, narrow dead ends, objectives, loot, wave gates or environmental hazards in the first pass. A reset must return the player and all test state to the same deterministic starting positions.

### Measurement without clutter

A small collapsible result strip on the opposite side or bottom can show:

- elapsed measurement time;
- total damage and rolling DPS;
- damage by permanent gun, basic, each ability and each summon;
- kills, hits and misses where meaningful;
- damage taken by source family;
- energy spent/regenerated and time energy-capped;
- summon uptime and alive count.

Measurement starts only when the tester presses **Start/Reset measurement** or deals the first damage after a reset. It stops while the whole simulation is paused. Every result records the active kit preset, ranks, enemy preset and modifiers so a screenshot or copied text is interpretable.

Do not infer fun from the metrics. Damage and uptime help diagnose balance; animation weight, clarity, rhythm and decision quality remain human review questions.

## Safety and truthfulness rules

- Practice remains an isolated scratch simulation: no XP, mastery, credits, chests, equipment drops, unlocks, ascension progress or checkpoints.
- Entering and leaving Practice must leave the player profile byte-for-byte unchanged, apart from an explicitly separate Practice-preference/preset file if one is later approved.
- Clear/reset removes enemies, projectiles, hazards, drops and summons deterministically and restores resources without awarding anything.
- Test-only cheats never become campaign settings.
- Show a persistent modified-state label when measurements are affected by invulnerability, frozen AI, free energy, instant recharge, custom time scale or custom stat multipliers.
- Keep simulation and presentation separate: placement previews do not create enemies, rendered ranges match collision geometry and a detached camera never changes spawn coordinates.
- Old, legacy and unreleased abilities may be exercised in Practice, but remain clearly labeled and cannot enter the released class roster, campaign rewards or unlocks until the owner explicitly releases them.

## Recommended implementation order

| Pass | Deliverable | Acceptance evidence |
| --- | --- | --- |
| 1 | Persistent left dock, Tab show/hide, safe pause/reset/clear, small rock greybox | Mouse/UI fixture plus rendered inspection at intended window sizes |
| 2 | Enemy preview and click placement with Point/Line/Ring/Cluster | Exact world-coordinate, collision, camera-detach and cancel tests |
| 3 | Full static-kit/rank/equipment presets and focused player stats | Complete build applies atomically; campaign/profile snapshots remain unchanged |
| 4 | Scenario presets and compact per-source metrics | Fixed-seed repeatability and explicit modified-result labeling |
| 5 | Usability and art/audio polish | Owner can build, place, reset and compare without instructions |

Keep the current Practice behavior available as a regression reference until the new dock passes isolation, input and render checks. Do not combine this work with campaign terrain, progression, balance or save-format changes.

## First owner test

Without instructions, ask the owner to:

1. load Vanguard at rank 5 with a mid-run stat preset;
2. place ten weak enemies in a cluster beside a large rock;
3. clear them, place an armored dummy in the long lane and reset measurement;
4. compare Q, W, hammer and the permanent gun;
5. turn enemy AI off, notice the modified-test warning, then restore Normal;
6. leave Practice and confirm the real equipment, collection and checkpoint are unchanged.

Record time to complete each task, mistaken clicks, clipped controls, whether placement felt precise and which comparison the tool still made awkward. That is the evidence needed before adding more controls.

## Open decisions for the owner

- Is a single rank preset plus per-slot overrides enough, or is direct rank 1–10 entry useful?
- Should equipment be represented by a few power presets first or a full eight-slot editor?
- Should opening the dock pause by default, or remember the previous pause state?
- Are Practice-only named presets worth adding before the core placement workflow is proven?
- Which metrics are actually useful during feel testing, and which would distract from animation/readability review?

Owner decision: normal users choose a class, while old/legacy/unreleased content remains Practice-only until explicitly released. The remaining recommended defaults are rank presets plus individual overrides, three equipment presets before a full editor, pause on first open, no named presets in the first pass, and a collapsed metrics strip limited to elapsed time, total damage, DPS and damage by source.
