# Playtest session protocol

10 September 2026. Goal: learn alongside a human playtest, then join measured evidence with the owner's experience. Do not manufacture a fun score from tests.

## Before play

1. Read root SESSION_HANDOFF.md and current instructions. Inspect Git status/log without changing the checkout. Record commit, dirty files, local start time and existing result-log size/last-write time. Never print or upload unrelated profile data.
2. Ask only if unclear: New expedition, Continue or Practice? Record ascension and relevant equipment from the result or owner. Preserve saves; don't silently start a fresh run to simplify measurement.
3. If the owner requests launch, use `scripts/run_game.ps1` from the project (the script resolves its own root). Check whether the game is already running first. Do not close their existing game. Practice is isolated from permanent collection/checkpoint.
4. Freeze the tested code/assets. Do not update balance, Git checkout, import assets, launch competing tests or restart during the human test. Read-only code/docs work is appropriate while they play.

## While the owner plays

Trace the actual Vanguard damage/resource/cooldown flow, current enemy scaling, reward receipt path and tests. Prepare hypotheses, not conclusions. Offer a short update if useful, then let them play. No continuous observation is implied: result logs are not a screen feed. Use only an explicitly authorized available screen-observation tool if requested.

Results append only on victory/defeat. An unchanged log while alive, shopping or in Practice is expected. Quitting mid-run may leave no final record; do not require the player to deliberately die. Ask them to say **finished** and provide notable moments/screenshots. If they explicitly request continuing background monitoring, use the app's supported monitor mechanism; don't promise to monitor after ending a normal turn.

## Read the results

Run once after completion:

```powershell
.\scripts\read_playtest.ps1 -Last 3
```

The default local source is `%APPDATA%/Godot/app_userdata/Workshop Salvager/salvage_runs.jsonl`. Reader is read-only, examines at most the last 500 lines and excludes tagged Practice/automation by default. `-IncludeTests` is diagnostic only; `-LogPath` accepts a separate fixture. Match timestamp and the recorded baseline; don't assume the last record belongs to this session. Old entries have unknown human/test origin and old build labels. New schema-2 entries include build family, test/practice tags and the twelve earned Vanguard ranks; equipment rank bonuses are not earned ranks.

Useful evidence: result, final route/stage/ascension, level/kills, damage received, last damage cause/recent damage, damage credited by source, cast counts, energy spent, tool ranks, equipped gear and sampled frame timings.

Limits:

- Final aggregate is not a per-round timeline. Recent damage keeps only a bounded tail. Some projectile causes are generic; do not confidently attribute them to a specific enemy.
- Continue restores some campaign counters but not every damage/cast counter. Mark resumed runs explicitly. Do not blindly divide damage by cumulative restored time or compare with fresh-run DPS.
- No hit-rate estimator, attempted/failed-cast history, positioning replay, pickup route, audio recording or evidence that an effect felt satisfying. Cast counts alone don't explain why something went unused.
- Frame timings sample a bounded part of running gameplay (initial warmup excluded), not every frame of a long expedition. CPU simulation probes are not GPU FPS. Wall/screen timing is process-local, not a complete resumed campaign clock.
- Schema tagging begins with the handoff build; historical records stay untouched. Logs contain no exact Git commit: the session baseline supplies it.

## Review with the owner

Ask at most three targeted questions after seeing the result, adapting to what happened. Useful starting questions:

1. Where did pressure become unfair, trivial or slow? Which enemy/round was involved?
2. Which skill or movement decision felt strongest, and which felt weak or unclear?
3. Were rewards and injury/energy cues readable without becoming annoying?

Present **observations → plausible explanations → uncertainties**, then the top three improvements ordered by player impact. Avoid a giant feature backlog. Confirm gameplay changes before implementing during a playtest-only session.

Append a compact dated review to QUALITY_BAR: build/commit, fresh/Continue/Practice, route reached, owner's wording, measured facts, uncertainties and agreed next action. Keep raw logs/captures local and ignored. No new in-game dashboard. Refresh SESSION_HANDOFF.md so the next session can repeat this workflow with minimal setup.
