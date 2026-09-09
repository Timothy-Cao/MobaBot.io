# MVP task board

> **Historical task board through v0.9.** For current scope and verification priorities, see [QA_17.md](QA_17.md), [QUALITY_BAR.md](QUALITY_BAR.md) and the [documentation index](../README.md).

Scope: Stage 1, Levels 1–3 only. Owner: the current game-development task. Authority: user-approved Survivor.io × League direction. Updated September 8, 2026.

## Done in this iteration

- [x] Review League kit/experience, Riot counterplay/clarity, Survivor.io publisher positioning and community evolution guidance; separate evidence from design hypotheses.
- [x] Define the feeling, north stars, level arc, quality gates and scope lock in MVP_NORTH_STARS.md.
- [x] Main mode becomes mobs-only Level 1 → harder mobs/two wardens Level 2 → mobs/final boss Level 3.
- [x] Carry builds/rewards across levels; pace rank ceilings at 5/8/10; distinguish Power XP from encounter Level labels.
- [x] Give wardens and Foreman explicit approach/windup/attack/recovery states, committed targeting and punish windows.
- [x] Add ground danger, charge corridors, projectile-fan previews, phase announcement and prominent boss status/health.
- [x] Record per-level duration, build snapshot, Power, kills, hull and miniboss completions in local run summaries.
- [x] Test level gates, no post-demo progression, charge/ground counterplay, phase transition, recovery damage and cancelled hazards.
- [x] Simulate two presets × two seeds with normal health and no forced kills; all four reached the endpoint at roughly five minutes.

## Verification

Current handoff: **v0.8**, [QA_08.md](QA_08.md). All reproducible bugs found in this pass have fixes and targeted evidence: movement/edge visibility, shake/reduced effects, cast readiness, charge geometry, menu state and UI label placement. Smoke + 1,288 checks and the 3,169-label width audit pass. Human gates below remain open; an automated check cannot approve them on the player's behalf.

Latest pass: [BLINDSPOT_AUDIT_07.md](BLINDSPOT_AUDIT_07.md). v0.7 adds required-target guidance, distinct wardens, damage explanations, protected boss feedback, projectile-pool fairness, menu-Tab correction and local choice/pause timing. Final smoke + 929 checks and storage readback pass. Four limited-information behavior probes are recorded in the audit; they do not replace the human gates below.

- [x] Final full regression suite: original smoke + 841 checks, zero failures, including saved-zoom-independent camera assertions and post-victory projectile cancellation.
- [x] GPU-rendered complete demo: 291.48s, 950 kills, Power 32, one hit; result and per-level telemetry inspected. Full evidence/limitations in IMPLEMENTATION_STATUS.md.
- [x] Small-window / wide-zoom / reduced-effects boss readability checks; functional tells remain. Human comprehension still needs testing below.
- [x] Local storage integration: preferences preserved and completed run read back.
- [x] Launch final demo for the human playtest; v0.6 Demo window confirmed responding.

## Next human playtest — required before a “polished MVP” claim

- [ ] One first-time Relaxed run without coaching beyond the controls; record actual wall time and where help was needed.
- [ ] One Precision run if the player wants more aiming; do not require it to validate the accessible route.
- [ ] Ask one combined response: movement/stop feel; first upgrade that felt different; most confusing hit; dullest stretch; best power moment; whether the final boss felt fair.
- [ ] Compare feedback to the gates below; fix the largest issue within Levels 1–3, then replay. Do not add a fourth level as a response to boredom.

## Research questions / experiments, not extra features

| Priority | Uncertainty | Smallest useful check | Action threshold |
|---|---|---|---|
| P0 | Can a new player read attacks amid loot? | Observe first warden and final boss at 65% zoom and reduced effects. Ask what the warning meant. | Any unclear death: fix hierarchy/contrast/timing before raising damage. |
| P0 | Does mouse control feel like an intentional champion? | Click-turn-stop, Shift aim/cancel, blink near edges, Tab release and return from settings. | Any lost command/stuck target: reproduce and fix; do not tune around it. |
| P1 | Do ranks 5 and 10 feel transformative? | Ask the player to identify a before/after difference without numbers. Compare upgraded ability usage. | If only stats are noticed, strengthen silhouette/FX or the milestone mechanic inside the same art family. |
| P1 | Are five combat minutes the right demo length? | Measure real time including choices, and ask where momentum dipped. | Trim dead time/menu bursts before adding more enemies or extending timers. |
| P1 | Is the accessible build too automatic? | Compare whether a normal player uses a deliberate cast/defense to solve wardens. A scripted perfect-dodge bot is not sufficient evidence. | If decisions never matter, adjust encounter patterns/openings rather than imposing more keys. |
| P1 | Is the precise build worth aiming? | Compare satisfaction and boss opportunities, not just aggregate damage from one seed. | Improve payoff/readability before broadly nerfing the simple preset. |
| P2 | Do workshop sectors feel distinct enough? | Ask whether the player noticed the transition and could name its combat purpose. | Add a small landmark/encounter-layout change if needed; obstacle navigation only with dedicated movement QA. |

## Deliberately not scheduled

Stage 2 or Level 4+, new heroes, permanent talent economy, monetization, randomized equipment affixes, multiplayer, a large art pack, procedural map generator, controller support, Steam release packaging. Existing code outside the demo is preserved but is not the active product roadmap.

## Evidence discipline

Automated wins prove operation, not fun. Report test seeds/loadouts, actual outcomes, and limitations. Distinguish constructed screenshots from organic runs. Do not change difficulty only to manufacture an appealing win rate. Keep user data local; no accounts or paid assets are required. Human validation remains openly pending until feedback arrives.
# v0.9 handoff

Current implemented/tested: aimed Q/W, click-confirm R, staged ability unlocks, orbit radius toggle, L/Space/free camera, compact HUD, consumables, rare bonus drops, persistent equipment, matching static art, music routing, GitHub delivery. See QA_09.md for evidence and the consolidated remaining checklist. Older board entries below are historical; no Level 4 is in scope.
