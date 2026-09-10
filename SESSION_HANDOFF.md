# Current session handoff

Updated 10 September 2026. Stable entry point; human feedback and technical evidence stay in their dated review documents.

## Next action: campaign direction and owner review of 0.19.1

The owner finished the frozen-build playtest of clean commit `02ac283` and authorized implementation after three final directional questions. Those answers were implemented in `97d9747`. Follow-up work from `fcc5164` is **0.19.1 progression review**, build family `vanguard-19.1-progression-review`; use `git log -1 --oneline` and `git status --short` for the actual checkout. See [research, completion budgets and pending proposal](docs/design/PROGRESSION_RESEARCH_20.md), [earlier combat rules](docs/design/REVIEW_COMBAT_19.md), [QA evidence](docs/design/QA_18.md) and [dated owner feedback](docs/design/QUALITY_BAR.md).

One async directional question is pending: replace the 22-round route with replayable numbered Chapters, each initially a three-round Operation; reset abilities/mastery/field credits per Operation and keep equipment/earned Salvage persistent, excluding permanent mastery/potions/random ability permissions initially. The owner called this direction tentative. No answer has been received. Do not claim Chapter Operations or a Salvage crate shop are implemented. Independent feedback improvements are implemented and verified below.

Next test should start a **new expedition** after launching the new build. Continue intentionally retains a saved run's original rules; no old ranks/modules were removed. Preserve collection/settings/music. Follow [PLAYTEST_PROTOCOL](docs/design/PLAYTEST_PROTOCOL.md), record commit/log baseline, and freeze source/assets while the owner plays. Do not restart mid-test.

## What is playable now

- Godot 4.7.2; `expedition.tscn`; fixed Vanguard. Eight stages / 22 rounds, **120-second survival + guardian/boss + 12-second collection**. Eight boss configurations still reuse one body and three sectors; no new maps or multiplayer.
- New-run XP income is one-third of the tested 0.18 build. Each level gives three paused selections, each offering up to three eligible QWERDF/MG/hammer tools. Cards show numerical changes; hover retains mechanics. Chests give credits/items, no skill points. No all-rank-five gate. Existing 0.18 checkpoints keep non-modal progression.
- Buy and upgrade 1234 (Orbit/Bulwark/Reserve/Overclock) after **every round**, with run-only field credits. New runs start without them. Equipment still persists, with its stage-end shops. Failed module saves roll back; checkpoints preserve purchases.
- W hits grant one-second +50% vulnerability; center hits stun for 1.1s, with a four-second boss stun guard. E landing grants one 1.2s hammer-combo opportunity; combo gets 3x boss/guardian damage. Ordinary hammer is 90% of the preceding baseline. R descends in one second. Main-boss HP remains at the owner-approved 50x setting.
- Main bosses move laterally, use denser volleys, staggered bombs, shorter-windup charge, sweeping laser and melee, and pursue at distance while respecting thick obstacles. Environment dims for real-boss presence while actors/tells remain readable. No enclosure or teleport. Boss bar shows a five-minute overload countdown: afterwards damage increases by 0.1x per second up to 10x, rotating gapped rings accelerate and recovery shortens. No scripted loss. Human fairness is unverified.
- Thicker Practice-style campaign obstacles; fast lunges, melee tanks, durable/evasive ranged roles and predictive shots. EMP suppressor warns before a wide pulse; caught players lose D/F and 1234 functions for three seconds. QWER/MG/hammer/walking stay usable. EMP is available in primary Practice.
- Early orbit has reduced damage, radius and spin. Base speed is 185 before bonuses. D upkeep is 28/sec at rank 1, decreasing to 10/sec at rank 10 (five-second early endurance / 80% late duty-cycle references assume base energy/regen and no other spending). F stores one charge before rank five, two thereafter.
- Camp has peer Round clear / Build / Mastery / Equipment tabs and three-column receipts. Combat Equipment is inspection-only. New `unified_mastery` runs use 13 nodes, one root, three branches, 29 maximum spends and one point per level. Older checkpoints keep their tree. Tier 3/4/5 helmets add 0.4/0.8/1.2 energy/sec; chest pieces add 0.25/0.5/0.75 health/sec. Same-slot tier stats remain strictly increasing.
- Most specialists appear by round two; EMP waits for Stage 2. Reference W survival floors now include the actual 1.2 kit damage multiplier. `tests/progression_budget.gd` produces reproducible theoretical references; do not equate them to human DPS.
- Mouse commands, independent backtick MG, S stops commands not MG, L camera lock, Tab Build, D drive and F blink remain. Friendly/enemy projectiles still pass through walls; bodies do not. Primary Practice uses current combat; old rules remain in compatibility fixtures/Legacy laboratory. Marshal/Racer/offline rewards are not implemented.

## Evidence and open risks

- Human baseline `02ac283`: owner reports "so far so great, i like it" and later approves real-boss HP. Main complaints: too much power too soon, button-mashing boss uptime, reliable AFK orbit, overwhelming low-payoff mastery/equipment, narrow scrolling receipts. Do not undo the boss-HP approval because the earlier guardian was easy.
- Two matching finalized records after the visible 01:55 PDT launch. Later result: A0 Stage 1 round 3 loss, level 17, 766 kills, 71 chests; Q/W/E/R/orbit at rank 10. Fresh/Continue not confirmed. Logs do not provide a per-round DPS timeline; recent damage and frame samples are bounded. Raw player logs/captures remain ignored under `output/playtest-2026-09-10/`.
- Full regression has 29 suites. Dedicated review checks cover progression, transactions, saves, combat and actual controller/UI flow. Rendered 1600x900 camp/upgrade/combat checked in normal/reduced effects. Late rocket-impact triangulation errors observed during human testing no longer reproduce after the degenerate-shard guard. Existing two WAV ObjectDB exit warnings remain.
- Both refined compatibility probes and legacy expedition comparison complete without engine errors. Current Vanguard ordinary bots lose early (idle 12.6s, active 19.7s, basics 20.3s): crude policies, not human win rates. The combined early mobility/XP/difficulty change needs particular owner attention.
- Current A5 artificial-health soak reaches **round 21 at 7,996.8 simulated seconds, still running**, not a full-route completion. Peak 180 enemies; timings are CPU diagnostics, not GPU FPS or a valid before/after benchmark. Do not tune approved boss HP solely to make this bot finish.
- Next human checks: early upgrade/credit pacing, energy pressure and single-stock blink; landing W -> R/E -> hammer versus moving bosses; EMP readability and counterplay; specialist durability; boss pressure without exhausting projectile clutter. No new human feel/audio verdict or quality score is implied by passing tests.
- 0.19.1: all 29 final regression suites pass, including 188 focused checks. Normal-size cards/unified mastery rendered and inspected with explicit Dummy audio due to the host WASAPI failure. Both refined probes complete; current A0 bots still lose in round one. The updated artificial-health A5 soak again reaches round 21, 7,996.8 simulated seconds, still running (14,869 kills, level 41, peak 180 enemies); not a full-route pass. This remains a reason to settle the route/budget direction, not to force a bot victory by changing approved HP.
- Future result logs include up to 96 completed 15-second interval samples with ranks, mastery, credits, level, boss HP and credited damage rate. Counters rebase after round changes/Continue; no imported aggregate is divided by restored time. These are all-target damage intervals, not hit rates or boss-only DPS.

## Read order

1. This file and PLAYTEST_PROTOCOL.
2. README's 0.19 override, REVIEW_COMBAT_19, newest QA_18 and QUALITY_BAR entries.
3. Targeted code: `review_rules.gd`, `review_enemies.gd`, `review_enemy_art.gd`, `review_view.gd`, then existing Vanguard/expedition/save code.
4. QA_17, earlier QA_18 sections and numbered roadmap documents are history/compatibility, not instructions to restart old phases.

Commit coherent verified milestones; keep source/assets/tests in Git and raw records/output private. Preserve dated owner feedback, separate implementation evidence from human quality, and refresh this handoff before switching sessions.

## Post-commit launch limitation

The normal visible launcher was attempted after implementation commit 97d9747. Godot reported WASAPI output initialization failure and dummy-audio fallback, and still had no titled main window after roughly two minutes while consuming CPU. The attempted process was stopped before any human run. This does not invalidate the automated/render checks, but the interactive launch is not verified ready. Investigate the local startup/audio environment before the next owner test; do not overwrite player settings or saves. Logs: ignored output/playtest-2026-09-10/review-launch.*.log.
