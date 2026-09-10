# Current session handoff

Updated 10 September 2026. Stable entry point: update this file instead of inventing a new numbered kickoff document each session.

## Next action: human playtest, not another rewrite

The owner wants to play while the next session learns the game, then compare logs with their impressions. Follow [PLAYTEST_PROTOCOL](docs/design/PLAYTEST_PROTOCOL.md). Freeze code/assets during the test. Do not restart the game, pull over the tested checkout, reset saves or tune numbers mid-run. No outstanding blocker prevents testing.

Latest gameplay milestone: `c358496` (pressure/audio). The handoff-only follow-up adds documentation and result metadata, not balance changes. Use `git log -1 --oneline` and `git status --short` to record the actual checkout. New result build tag: `vanguard-18-pressure-audio`, schema 2. This tag identifies the gameplay family, not an exact commit.

## What is actually playable

- Windows Godot 4.7.2; `expedition.tscn`; 0.18 fixed Vanguard. Eight stages / 22 rounds, **120 seconds survival + guardian/boss + 12 seconds collection**. Legacy shared-pool checkpoints/Practice remain compatible; Marshal, Racer and offline progression are not implemented.
- Q Impact bolt, W Core strike, E Body slam, R Reactor drop (not the old laser). D held Ghost drive, F blink. 1 orbit, 2 Bulwark, 3 Reserve, 4 Overclock. Independent backtick-toggle MG and commanded hammer. All twelve earned ranks reach 5 before rank 6+ purchases. Practice bypasses the gate with shared 1/5/10 presets.
- League-like mouse commands; S stops commands, not MG. Locked camera follows only; L rebindable; unlocked edge pan. Tab toggles Build. Minimal Home/Settings; no main-menu Loadout.
- Forty persistent equipment pieces across eight slots/five tiers; forge three identical pieces. No sets/stars/rerolls. T4 learned-rank bonus and T5 gun pet apply once. Ability ranks, mastery and field credits reset on a new run. Cleared-round Continue is not an exact combat save.
- Most recent pass: Breacher/Mender/Scattergun roles, stage + round enemy scaling, low/critical-health feedback, energy/cooldown rejection and pickup/telegraph sounds. Exact chest receipts and a shop at every Vanguard stage end precede this pass.

## Read order and navigation

1. `AGENTS.md`, this file, [playtest protocol](docs/design/PLAYTEST_PROTOCOL.md).
2. [README](README.md), newest sections of [QA_18](docs/design/QA_18.md), [QUALITY_BAR](docs/design/QUALITY_BAR.md).
3. [Pressure/audio](docs/design/PRESSURE_AUDIO_18.md), [reward reveal](docs/design/REWARD_REVEAL_18.md), latest [balance addenda](docs/design/BALANCE_16.md).
4. Read targeted source/tests while the owner plays. `run_model.gd` + `vanguard.gd`: combat; `expedition.gd`: route; `field_enemies.gd` + `ranged_threats.gd`: specialists; `workshop.gd`: orchestration/results; `synth_audio.gd` + `combat_feedback.gd`: feedback; `forge_equipment.gd`: save ownership. Files are under `src/salvage/`.
5. QA_17 and numbered research are compatibility/history. Do **not** restart the old Phase 0 roadmap. Follow focused references when relevant, not every historical proposal.

## Evidence and unresolved risks

- Full `scripts/check.ps1`: 28 suites pass after handoff metadata additions. No gameplay changes in this follow-up. These passes do not certify fun, listening quality or low-end GPU performance.
- Latest ordinary Vanguard bots lost early (idle 13.3s, active 32.3s, basics 21.9s). Crude policies, not human win rates. Owner previously called Stage 1 very fun and Stage 2 too easy; retain that feedback despite bot outcomes.
- Latest A5 artificial-health soak reached route round 20 at its 8,000-second simulation budget, **not full-route completion**. Peak 180 enemies; p95 simulation step ~1.79ms, not rendered frame time. Bosses retain the owner's experimental 50× earlier HP: prolonged boss fights are a priority risk, not solved balance. Older completed soaks describe older builds.
- Human review still needed: specialist fairness, later-round pressure, XP/rank-five gate pacing, boss duration, chest outcomes, low-health/energy sound clarity and mix fatigue.
- Known two leaked WAV ObjectDB instances on shutdown; documented warning, unresolved. Source-PNG warning in refinement fixture is expected. No engine-error waiver.
- Logs only finalize at victory/defeat; no replay, continuous telemetry or visual/audio judgment. Continued-run counters have mixed restoration coverage. See protocol before calculating DPS or comparing runs.

## Keep the handoff reusable

At each verified milestone, update this file's build/state/next action/known limits; append dated owner feedback to QUALITY_BAR and implementation evidence to QA_18 (or its explicit successor). Keep human judgment separate from tests. Preserve previous dated ratings. Update `RunDiagnostics.BUILD` for materially changed gameplay families and record the exact commit in playtest notes. Keep raw player logs and captures in ignored local output, not Git. Never rewrite old logs to relabel them.

This is explicit repository continuity, not automatic transfer of the entire chat. AGENTS.md links this entry point following [OpenAI's project-instruction guidance](https://learn.chatgpt.com/docs/agent-configuration/agents-md). New sessions should read it and ask only about genuinely missing decisions.
