# Current session handoff

Updated 10 September 2026. Stable entry point; human feedback and technical evidence stay in their dated review documents.

## Next action: owner review of 0.19

The owner finished the frozen-build playtest of clean commit `02ac283` and authorized implementation after three final directional questions. All answers were received and implemented. The new pass is **0.19 deliberate combat**, build family `vanguard-19-deliberate-combat`; use `git log -1 --oneline` and `git status --short` for the actual checkout. See [exact rules and balance estimates](docs/design/REVIEW_COMBAT_19.md), [QA evidence](docs/design/QA_18.md) and [dated owner feedback](docs/design/QUALITY_BAR.md).

Next test should start a **new expedition** after launching the new build. Continue intentionally retains a saved run's original rules; no old ranks/modules were removed. Preserve collection/settings/music. Follow [PLAYTEST_PROTOCOL](docs/design/PLAYTEST_PROTOCOL.md), record commit/log baseline, and freeze source/assets while the owner plays. Do not restart mid-test.

## What is playable now

- Godot 4.7.2; `expedition.tscn`; fixed Vanguard. Eight stages / 22 rounds, **120-second survival + guardian/boss + 12-second collection**. Eight boss configurations still reuse one body and three sectors; no new maps or multiplayer.
- New-run XP income is one-third of the tested 0.18 build. Each level gives three paused selections, each offering up to three eligible QWERDF/MG/hammer tools. Chests give credits/items, no skill points. No all-rank-five gate. Existing 0.18 checkpoints keep non-modal progression.
- Buy and upgrade 1234 (Orbit/Bulwark/Reserve/Overclock) after **every round**, with run-only field credits. New runs start without them. Equipment still persists, with its stage-end shops. Failed module saves roll back; checkpoints preserve purchases.
- W hits grant one-second +50% vulnerability; center hits stun for 1.1s, with a four-second boss stun guard. E landing grants one 1.2s hammer-combo opportunity; combo gets 3x boss/guardian damage. Ordinary hammer is 90% of the preceding baseline. R descends in one second. Main-boss HP remains at the owner-approved 50x setting.
- Main bosses move laterally, use denser volleys, staggered bombs, shorter-windup charge, sweeping laser and melee, and pursue at distance while respecting thick obstacles. Environment dims for real-boss presence while actors/tells remain readable. No enclosure or teleport.
- Thicker Practice-style campaign obstacles; fast lunges, melee tanks, durable/evasive ranged roles and predictive shots. EMP suppressor warns before a wide pulse; caught players lose D/F and 1234 functions for three seconds. QWER/MG/hammer/walking stay usable. EMP is available in primary Practice.
- Early orbit has reduced damage, radius and spin. Base speed is 185 before bonuses. D upkeep is 28/sec at rank 1, decreasing to 10/sec at rank 10 (five-second early endurance / 80% late duty-cycle references assume base energy/regen and no other spending). F stores one charge before rank five, two thereafter.
- Camp has peer Round clear / Build / Mastery / Equipment tabs and three-column receipts. Combat Equipment is inspection-only. Broad mastery redesign and new equipment regen stats are deferred. Existing same-slot tier stats are checked to increase strictly.
- Mouse commands, independent backtick MG, S stops commands not MG, L camera lock, Tab Build, D drive and F blink remain. Friendly/enemy projectiles still pass through walls; bodies do not. Primary Practice uses current combat; old rules remain in compatibility fixtures/Legacy laboratory. Marshal/Racer/offline rewards are not implemented.

## Evidence and open risks

- Human baseline `02ac283`: owner reports "so far so great, i like it" and later approves real-boss HP. Main complaints: too much power too soon, button-mashing boss uptime, reliable AFK orbit, overwhelming low-payoff mastery/equipment, narrow scrolling receipts. Do not undo the boss-HP approval because the earlier guardian was easy.
- Two matching finalized records after the visible 01:55 PDT launch. Later result: A0 Stage 1 round 3 loss, level 17, 766 kills, 71 chests; Q/W/E/R/orbit at rank 10. Fresh/Continue not confirmed. Logs do not provide a per-round DPS timeline; recent damage and frame samples are bounded. Raw player logs/captures remain ignored under `output/playtest-2026-09-10/`.
- Full regression has 29 suites. Dedicated review checks cover progression, transactions, saves, combat and actual controller/UI flow. Rendered 1600x900 camp/upgrade/combat checked in normal/reduced effects. Late rocket-impact triangulation errors observed during human testing no longer reproduce after the degenerate-shard guard. Existing two WAV ObjectDB exit warnings remain.
- Both refined compatibility probes and legacy expedition comparison complete without engine errors. Current Vanguard ordinary bots lose early (idle 12.6s, active 19.7s, basics 20.3s): crude policies, not human win rates. The combined early mobility/XP/difficulty change needs particular owner attention.
- Current A5 artificial-health soak reaches **round 21 at 7,996.8 simulated seconds, still running**, not a full-route completion. Peak 180 enemies; timings are CPU diagnostics, not GPU FPS or a valid before/after benchmark. Do not tune approved boss HP solely to make this bot finish.
- Next human checks: early upgrade/credit pacing, energy pressure and single-stock blink; landing W -> R/E -> hammer versus moving bosses; EMP readability and counterplay; specialist durability; boss pressure without exhausting projectile clutter. No new human feel/audio verdict or quality score is implied by passing tests.

## Read order

1. This file and PLAYTEST_PROTOCOL.
2. README's 0.19 override, REVIEW_COMBAT_19, newest QA_18 and QUALITY_BAR entries.
3. Targeted code: `review_rules.gd`, `review_enemies.gd`, `review_enemy_art.gd`, `review_view.gd`, then existing Vanguard/expedition/save code.
4. QA_17, earlier QA_18 sections and numbered roadmap documents are history/compatibility, not instructions to restart old phases.

Commit coherent verified milestones; keep source/assets/tests in Git and raw records/output private. Preserve dated owner feedback, separate implementation evidence from human quality, and refresh this handoff before switching sessions.
