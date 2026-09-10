# Workshop Salvager implementation

> **Historical record through v0.9.** For the current v0.17 implementation and handoff, see [QA_17.md](QA_17.md) and the [documentation index](../README.md).

## v0.8 snapshot — demo / motion, shake and visual QA

September 8, 2026. Reproductions, fixes, limitations and handoff: `QA_08.md`.

- Removed repeated pulse-driven actor displacement; hurt uses bounded player recoil, dash lean is capped, and reduced-effects tank flashes are corrected. Physics-aligned camera, HUD-safe arena-edge clearance and visible boundary; unchanged playable bounds.
- Held steering cancels on UI/focus interruptions. Blocked zero-travel mobility no longer spends charges. Ground abilities allow self-centered targeting. Cast previews use actual affordability/target validation. Charger warning width/caps and clamped boss-charge direction corrected; overlapping threat labels stay out of the boss HUD.
- Smoke + **1,288 checks pass** (929 previous + 359 motion QA), plus a 3,169-label width audit with zero issues. Thirty repeated menu cycles do not accumulate UI nodes. Storage readback passed with preferences preserved.
- Real-render v0.8 run won in 291.48s, 950 kills, Power 32, one hull hit; wall/screen timings persisted. RTX 5070 sampled prefix median 5.009ms / p95 7.79ms. Final edge-camera/charge-normal/layout changes separately tested and captured afterward. Evidence: `output/playtest-v08`.
- Small-window and 4:3-window content layouts reviewed. Explicitly no guarantee about every display's subjective high-refresh smoothness. No account/art/setup blocker; playable launcher ready for tomorrow. Human feel, pacing and fun remain open acceptance gates.

## v0.7 history / readability and blind-spot audit

September 8, 2026. Research, before/after findings, probe results and limitations: `BLINDSPOT_AUDIT_07.md`.

- Required-target edge markers with nearest-objective boss HUD; distinct directional-plow and twin-mortar wardens. Damage-source HUD, directional arc and defeat hint, with bounded local damage history.
- Critical boss messages and sound voices protected from routine loot. Boss fan retains all five shots at full friendly projectile capacity. Opening hint respects keybinds; menu Tab navigation no longer swallowed by combat inspection. Local per-screen/wall timing added for future human pacing evidence.
- Smoke + **929 checks pass**, zero failures (841 existing + 88 readability); storage integration passed. New geometry checks cover both zoom limits, camera edges and simultaneous objectives. Functional tells retained with reduced effects.
- Full GPU run won in 291.48s, 950 kills, Power 32, one Charger-charge hit. Sampled prefix median 4.947ms / p95 9.258ms on RTX 5070. Last silhouette/Tab/timing edits subsequently verified separately; no broad performance or human-balance claim.
- Less-informed Relaxed probes with random upgrades: few-buttons won both seeds in 304–307s; passive-only won one and lost one at the final boss in 350–365s. No difficulty tuning made from this small sample. Versioned visual evidence: `output/playtest-v07`.

Human control feel, fun, choice dwell time, visual comprehension and sound-mix preference remain open acceptance gates. Three-level scope unchanged.

## v0.6 history / Stage 1, Levels 1–3

September 8, 2026. Current scope/research: `MVP_NORTH_STARS.md`. Priorities and human acceptance gates: `MVP_TASK_BOARD.md`. These supersede the older three-boss stage structure below.

- Main demo: 75s mobs-only Loading bay → 90s harder Assembly line plus two required wardens → 90s Reactor floor waves plus the Foreman. No Level 4. Existing open arena reused with distinct start sectors and decorative floor landmarks.
- Full build carries between levels; combat rank ceilings 5/8/10 make early and final milestones reachable. HUD Power means XP growth, not encounter Level. End-level promotions/cache, utility and supply banking retained.
- Ram charge and Artillery ground-mark state machines teach committed targeting, walking counterplay and recovery. Foreman combines charge, triple blasts and projectile fans, with a half-health overclock. Gold EXPOSED windows grant +50% incoming damage. Functional threat outlines remain with reduced effects. Dead casters cancel hazards; final boss death also cancels hostile projectiles during the clear beat.
- Original smoke test and **841 checks pass**: 165 salvage, 102 MOBA, 55 iteration-04, 476 iteration-05, 43 demo. Camera assertions now respect saved zoom rather than assuming 100%. Storage readback passed with current preferences preserved.
- Four normal-health model runs (Relaxed/Precision × seeds 2407/2408) won in 292–302s. Level 1 ended at Power 11, Level 2 at Power 21–23, final Power 32–33. Focused ranks reached 5/8/10. Bots know telegraphs exactly; these are operation checks, not human difficulty evidence.
- Actual GPU-rendered Relaxed/2407 run won: **291.48s, 950 kills, 4,424 scrap, Power 32, one hull hit**. Level durations: 76.40 / 91.40 / 123.68s including clear beats. First rank-5 milestone at 29.35s; both focused skills rank 5 before Level 1 cleared. Rank-10 skills reached at 187.77/202.92s. Local summary includes per-level build snapshots.
- RTX 5070 sampled prefix: 19,940 frame intervals after warmup, median 5.0ms / p95 7.023ms, peak 46 enemies within that sampling window. Not whole-run peak or a hardware guarantee. The final HUNT label and post-victory projectile guard were separately verified after this rendered run.
- Constructed 1280×720 demo/upgrade/reward captures, 960×540 home/build/boss captures and the organic completed-run result visually inspected. Wide zoom with reduced effects preserves charge and ground tells. Evidence lives in `output/playtest-v06`; constructed fixture states are not organic battle observations.

Remaining acceptance work is human: crispness, perceived transformation, pressure, loot flow, attack clarity and boss fairness. No art/account dependency blocks local play. Five combat minutes are measured; six-to-eight minutes including human choices is only a hypothesis. No commercial polish, separate obstacle maps or post-demo progression claimed.

## Slice 05 history / rank milestones, utility and wave pressure

September 8, 2026. Exact design and caveats: `ITERATION_05.md`.

- Fifteen ten-rank combat tracks (seven equipped cast slots + eight weapon/support tracks). Numerical ladders, rank-5/10 functional milestones, clickable before/after previews, focused continuation offers, rank-aware ability HUD and rarity stacking.
- Magnet moved out of combat passives into free Utility pages; 250–650 px reach, stronger attraction, automatic ranks and rank-five periodic map sweep. Old passive-Magnet saves migrate to a free Recoil shell without changing active loadouts or keys.
- Denser grouped waves, warned fast/armored packs, recovery periods, higher boss health, off-screen spawn-side selection at world boundaries. Expanded scrap showers, separate energy/repair drops and bounded type-preserving reward pools. XP pacing retuned for more loot.
- Original smoke test and 798 checks pass: 165 salvage, 102 MOBA, 55 slice-04, 476 slice-05. New coverage includes all rank purchases/stat previews, milestone cast effects, free utility cadence, 1,500 spawn candidates, typed loot conservation, surge uniqueness and lethal Recoil safety. Fewer UI TextureRect assertions account for the changed salvage count. Storage integration passed.
- Full rendered v0.5 Relaxed run won: 217.27s, 898 kills, 4,864 scrap, level 33, eight hits. RTX 5070 prefix sample of 19,940 intervals after warmup: median 5.043ms / p95 8.034ms, peak enemies 40 within that sampling window. Final preview/summary refinements and unequipped Recoil edge guard were separately tested afterward. Not a hardware/difficulty guarantee.
- Small- and large-window layouts plus actual result inspected; versioned captures in `output/playtest-v05`. Stationary/no-cast pressure test lost after 29.5s. Moving model tests can win with normal health. No user credentials/assets required.

Human validation remains: milestone payoff, magnet generosity, spike fairness, clarity in large loot bursts and preset balance. Same map and boss archetype; no persistent unlock economy or commercial polish claimed.

## Slice 04 history / stages, resources and action icons

September 8, 2026. Design, exact costs, progression and cited research: `ITERATION_04.md`.

- Wheel zoom 65–100%, saved settings slider, zoom-aware world/cursor/minimap; hold Tab inspection with exact return state; Esc settings. Old view remains closest. Eleven conflict-safe bindings include four toggle keys and legacy-save migration.
- Free and energy-powered toggles, energy regeneration/capacity stats and upgrades, explicit ability costs, free D/F movement, optional nonlethal hull-for-energy active. Fourteen cast abilities, six passive choices, nine XP upgrade families.
- Three one-minute wave stages with required scaling bosses; first two have three-card end rewards, final boss wins. Common/Rare/Epic ability promotions, reactor cache option, earned-loot conservation and inter-stage refill. Same arena and boss archetype; no metaprogression.
- Dedicated consistent code-native action icons on HUD/loadout/inspection/rewards. Existing equipment PNGs retained. Updated schema 1.1 documents the two detail levels.
- Original smoke test and 175 salvage + 102 MOBA + 55 iteration checks passed (332 checks). Two natural-health staged model runs won in 199.25s / 201.90s. Final edge tests cover boss spawning at enemy capacity and both zoom limits.
- Actual GPU autoplay won: seed 2407, 201.48s, 558 kills, 1987 scrap, level 27, four hull hits. RTX 5070, 19,940 measured frame intervals, median 5.639ms / p95 11.888ms, peak enemies 34. Not a hardware guarantee. This run preceded the final utility-tooltip correction and saturated-enemy boss-spawn guard; both subsequently regression-tested.
- Nine 1280x720 fixtures, six 960x540 fixtures and actual result visually inspected; captures in `output/playtest-v04`. Storage integration passed with preferences preserved. No asset/account blocker.

Still requires human testing: movement/aim feel, resource friction, wide-zoom encounter pressure, rarity impact and consecutive XP choices after stage banking. Automated wins do not prove fun or fair difficulty. No new maps, boss move sets, music, persistent economy, networking or standalone export claimed.

## Slice 03 history / MOBA main mode

September 8, 2026. See `MOBA_MODE_03.md` for design choices, ability values and cited primary references; `ART_STYLE_SCHEMA.md` for the shared art schema and prompt template.

- Main controls: right-click/hold movement, S stop, Q/W/E actives, R ultimate, D speed, F charged blink/dash, T one replaceable stationary summon. WASD and the R-restart shortcut removed from the main controller. Default quick-cast plus Shift/hold/release aiming, with cancellation. No obstacle navigation or full MOBA animation-cancelling system is claimed.
- 13 ability definitions, six passive choices with four equipped, one of two optional pets, Relaxed and Precision presets. Category-checked loadouts and conflict-safe number/letter rebinding save locally and apply next run. Menus freeze the simulation and charge timers. Numeric upgrade choices cannot also cast through the menu.
- Visual ability HUD with equipment art, action glyphs, cooldowns, recharge bars and charge counts. Loadout editor, passive/pet selector, key editor, read-only Abilities tab, updated upgrade eligibility and ten-source damage stats. Existing seven item PNGs retained; code-native world art aligned in palette/materials. Painted inventory art remains more detailed than world actors, explicitly noted in the art schema.
- Fast chargers drop six scrap, plated tanks twelve and the boss 48. Outward scatter, accelerating attraction, trails and rising collection notes added. Pickup cap conserves XP through merging; duplicate claims remain guarded. Auto-bolt acquisition now stops at 310 range to reduce off-screen kills and distant rewards.
- Original smoke test passes. Salvage regression suite: 161 checks, zero failures (the old fixed Ricochet-offer assertion now checks the actual offered card; four old icon checks disappeared when damage stats became a ten-source layout). MOBA suite: 102 checks covering movement/stop, charges, aim/cancel, rebinding, passives, damage, dash collisions, range agreement, summon replacement, pet fire, loot conservation, camera coordinates and UI state. Six legacy and six MOBA simulated seed/preset runs reach terminal states.
- Thirteen GPU-rendered 1280x720 fixtures reviewed; final loadout/passive/HUD/stats/aim views also checked at physical 960x540. Fixed pet-description overflow found in visual review. Versioned captures remain under `output/playtest-v03`; fixtures are constructed states, not organic playthroughs.
- Full rendered MOBA playthrough: 90.02 seconds, seed 2407, 153 kills, 223 scrap, level 9, no hull damage, boss not defeated. Local record and completed-run screenshot saved. RTX 5070: 14,852 measured frame intervals after warm-up, median 5.314 ms / p95 10.152 ms, peak enemies 25. This run preceded the optional aim-indicator/label-layout refinements; simulation changes afterward only extended aimed beam range to match its indicator, not the Relaxed preset used here. This is a single machine/run, not a performance guarantee.
- Storage integration passed: current audio/effects preferences, loadout, keys and completed run read back, with user settings preserved. No credentials, new subscriptions or missing assets block local play.

Remaining: human control feel, relative preset strength, pickup satisfaction and difficulty are not validated by automated tests. The easy preset's bot took no damage; it may need more encounter pressure. Ninety-second prototype only; no music, metaprogression, campaign, unlock economy, PvP/networking, enemy-targetable summons or standalone exported package. All equipment is unlocked for experimentation. Next step is one combined human playtest response, not additional speculative scope.

## Slice 02 history

User's first-play feedback implemented: shorter menu copy, seven generated upgrade illustrations, visual rank graph, derived stats/source view, larger scrolling workshop, caches and minimap. Design/research and scope caveats: `UI_REWORK_02.md`. Original slice-01 record is preserved below as history.

- Original smoke test and 165 salvage checks passed; includes camera/spawn movement, edge clamping, one-time cache rewards, every rank preview, combat/formula consistency, illustrated-slot sizes, upgrade/build return-state preservation and bulk-pulse accounting.
- All seven local PNGs imported successfully; transparent corner checks passed. Mipmaps reduce small-icon aliasing. Original files and generation prompts recorded in `assets/upgrades/PROVENANCE.md`.
- Eight GPU-rendered screen fixtures checked at 1280x720. Upgrade graph, stats and upgrade choices also inspected at physical 960x540. Captures: `output/playtest-v02`.
- Full rendered slice-02 playthrough: 90.02 seconds, seed 2407, 148 kills, 169 scrap, level 8, two hull hits; local result saved. After warm-up: 17,683 measured frame intervals, median 4.973 ms and p95 5.81 ms, peak enemies 28, RTX 5070. This is one machine/run, not a broad performance guarantee. The later bulk-pulse accounting fix was separately regression-tested and did not change the six simulated outcomes.
- Six simulated seed/mode runs all reached a win. A larger open field is easier to evade in; human difficulty and reward pacing remain unvalidated.
- No credentials, paid subscriptions or user choices blocked this pass. A permanent skill tree/new upgrade families are not implied by the rank browser. First priority for further iteration: exploration pacing and player experience, not blindly adding more stats.

## Slice 01 history

User approved implementation. Build one polished 90-second Windows-first slice before expanding content.

1. Pure combat/run model, bounded salvage and upgrade rules: complete for slice 01.
2. Code-authored art, animation, feedback/audio and menus: implemented and visually checked.
3. Regression tests, real-render captures and stress checks: complete for the first local playable.
4. Local launch readiness: double-click launcher included. Standalone release export is not claimed; matching export templates are not installed.

Preserve the original Neon Collector scene and test. No paid art or image-generation dependency. Research and visual direction remain in ART_FIRST_DESIGN.md.

## Verification — September 7, 2026

- Godot 4.7.2 import and original sample smoke test passed.
- Salvage suite: 58 checks, zero failures. Covers duplicate rewards, XP conservation at capacity, upgrade pause/selection, swept collision, spatial-index edge cases, source attribution, invulnerability, terminal states, determinism, caps, scene controls and restart.
- Six model-driven playthroughs: three seeds per mode. All reached win/loss without exceptions. The simple steering bot won three salvage runs and one baseline run. This tiny biased sample does not prove human fun or final balance.
- Real GPU-rendered 90-second run completed on RTX 5070 / OpenGL compatibility. Seed 2407, 153 kills, 200 scrap, level 8, one hull hit, Foreman not defeated. Result read back from the local JSONL file. `output/playtest/completed-run.png` shows its real result screen.
- Rendered run after 60 warm-up frames: 17,923 measured frame intervals, median 4.998 ms, p95 5.160 ms, peak simultaneous enemies 19. Observations for this machine only, not a promise for weaker hardware or full-cap crowds. That run preceded the later collision-index optimization; art/rendering was unchanged.
- Dense synthetic model test: initially 180 enemies / 240 projectiles, 120 ticks. Mean tick cost improved from ~16.3 ms to ~4.7 ms after spatial indexing; latest maximum ~9.5 ms. Excludes GPU/UI cost; projectile population changes during simulation. Re-profile when content grows.
- Home, gameplay, upgrade, pause and result fixtures rendered at 1280x720 and inspected. Logical canvas 960x540. The gameplay fixture deliberately constructs a denser scene than the automated run.
- Upgrade cards also inspected at a physical 960x540 window. Separate opt-in storage test passed: current preferences saved/read unchanged and completed run read back successfully.
- Fixed audio teardown warnings in regression tests, truthful save-failure messaging, pickup-array mutation during pulses and projectile scan scaling. Added reduced effects and automatic pause on focus loss.

## Implemented

One arena; auto bolt gun; two common enemy behaviors and optional late boss; collectable scrap; bounded replenishing orbit; grinder, ricochet and pulse branches; four supporting upgrades; paused choices; hull/invulnerability; win/loss screens; same-seed replay; baseline comparison; local preferences and summaries; original procedural sound effects and motion.

## Remaining limits — not blockers to local play

- Short feel prototype, not a complete roguelite. No campaign, metaprogression, music, inventory, unlocks, Steam integration or standalone release package.
- No external generated-art deliverable or subscription is needed to iterate this scope.
- Escalation, sound mix, first-upgrade timing and boss health need human judgment. Power fantasy is not yet validated.
- Controller left-stick movement exists; complete controller-only operation is not physically tested. Keyboard/mouse is the supported first-play path.
- Reduced effects is an option, not a comprehensive accessibility certification. Working title is not legally cleared as a commercial brand.
- No user decisions, credentials or paid assets block the playable. Next input: one combined reaction after a run about appealing art, satisfying interactions and confusing/annoying moments.
# v0.9 snapshot

At v0.9, the then-latest user request superseded earlier scope exclusions for equipment and free-camera controls. `QA_09.md` is authoritative only for that historical milestone; use `QA_17.md` for current implemented behavior. Historical entries below describe previous builds, not current defaults.
