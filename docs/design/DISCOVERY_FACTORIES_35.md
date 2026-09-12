# Discovery and factory interactions · 12 September 2026

Owner feedback: early progression is too slow for the pressure; chests should mean an immediate level; add XP and pickup-range upgrades; remove no-op equipment messages; replace plain level buttons with illustrated panels; give maps structure and interactions. Owner supplied pickup range as the second upgrade: +10–50%.

## New-run rules

`discovery35` requires factory31/demo27 and never silently upgrades an older checkpoint. Practice stays unchanged. Campaign remains three Levels, three five-minute survival rounds each.

- XP costs to leave player levels 1–4 are 6/8/10/12, then 20. Existing pickup and survival XP gain ×1.25. One upgrade pick for each level gained through level 5; two from level 6. Cap 40, allowing roughly 74 level-earned picks before chest overflow. This replaces the old cap26/three-pick contract for new runs.
- Every Level opens with 90 seconds of ordinary basic bodies: no fast pressure runners, tanks, chargers or elite pack multiplier. Specialists wait until 2:00 in round one, then use the existing gradual roster. Later rounds keep their existing enemies; boss HP unchanged.
- One chest is eligible on the next ordinary kill after an independent 50–70-second deadline. Bosses/guardians/minibosses drop two. Collected chests immediately advance one level, retaining partial XP; at cap they grant one upgrade pick. Existing double-chest mastery can double the award once. No deferred chest credits/equipment or automatic end-round chest in new rules. Permanent equipment economy remains at camp/level banking and Home crates.
- Chest collection pauses into the same upgrade overlay, including the collection interval. Remaining floor loot is swept when collection begins so rewards finish before camp. Timers stop while choosing. Old reward receipts/checkpoints still render historical chest rewards.
- XP gain and pickup range each offer five ranks: +10/20/30/40/50%. XP applies to pickups and survival grants; range multiplies effective pickup radius, including supplies/chests. Fill missing choices with 200 field credits; no empty/one-card endgame screen. Bonuses reset with the run and validate on resume.
- Corrected the XP bar's previous-level threshold. Added bonus/reach values to Build; no new permanent HUD prose. Equipment bulk actions return without saving when no change is possible and use concise successful messages.

## Map interactions and presentation

Three illustrated portrait panels with native level labels, retained button focus/locking, clipped steel edges and selected brass outline. Built-in generated masters, provenance, reversible pixelation and actual-size inspection in assets/levels. No painted labels or renderer-owned gameplay.

New map rules add loading pens, staggered cross-lines and broken outer cooling banks to the existing route families. Three pressure plates per map arm after standing on them for 0.35s, trigger after 0.8s and recharge in 45s. Plate locations deterministically shift around solids; no camera/player-position dependence.

- Yard crane gathers current ground pickups, including chests.
- Assembly press hits the marked 210-radius area for three reference Ws; only enemies are damaged. It is a useful positional lure, not another damaging hazard for the player.
- Cooling vent slows ordinary enemy displacement to 45% for seven seconds inside its 300-radius field; main bosses retain 80%. The slow does not change attack clocks. Wall-safe correction retains terrain collision.

Flush control plates, wires, crane rails, press marks and vent grilles use native geometry. Active effect boundaries match simulation. Cooldowns, windup and active rings read actual state; reduced effects retains these functional tells. Press hardware remains a relatively simple native treatment, not a generated environment sprite pack.

## Verification and review limits

`discovery35_test.gd`: cheap thresholds, 1→2 picks, chest timing/instant pause/double-boss awards, XP/range caps, credit fallback/duplicate selection, opening composition, old rules, checkpoint corruption, clear-to-camp, all nine route connectivity samples, control reachability, press damage, vent slow and Practice exclusion. Render fixture produces selector, maps and normal/reduced choice cards without saving.

Level1 artificial-health full route completed in 1000.9 simulation seconds, peak21 enemies, final boss about64.6s. Guardian arrivals: player levels12/33; final boss40. This bot picks all sorts of upgrades and is not a resource-perfect DPS benchmark. Normal-health active/basic policies reached player level6 and lost at146.3/132.9s; idle lost27.8s atlevel1. These are reliability/relative-pressure observations, not human fun or difficulty acceptance. Human review should check opening choice cadence, first specialist transition, chest pause frequency, control discoverability and whether the late run grows too quickly.

The illustrated selector is substantially richer than the native combat world. More environment art may still be worthwhile after the owner reviews the interaction/layout changes. Do not claim a finished map-art replacement or solved balance.


Release: [0.35.0-test.1](https://github.com/Timothy-Cao/MobaBot.io/releases/tag/v0.35.0-test.1), source49be864. All43 suites plus final111 focused checks pass. Level3 artificial-health route completed in1098.1s, peak85 enemies, final boss about104s. The ZIP includes this milestone and the prior button/copy changes. Old checkpoints retain old progression; start a new run for review.
