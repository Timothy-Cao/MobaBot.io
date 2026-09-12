# Intentional progression and combat readability

12 September 2026. Owner authorized a 30–60 minute implementation/review pass from `96e3628`, following BULLET_HEAVEN_LESSONS_38 while preserving MOBA inputs and mechanical challenge. This document describes the final implementation; experiments are identified separately.

## Direction

Early access to the class's useful actions matters more than simply raising every reward. Clear approach groups give area attacks and repositioning a purpose; brief reductions in arrivals give players time to collect and prepare. Riot describes authored wave timing, composition, frequency and shape in [The Tech Behind Swarm](https://www.riotgames.com/en/news/the-tech-behind-swarm). Our ten-second approach groups and fifty-second pacing cycle are local design experiments, not borrowed numerical standards.

The owner clarified during this pass that **maxed abilities before the final boss are acceptable**. The final encounter can test execution with a completed build. A trial of rising late XP costs was removed. Existing XP costs, caps, chest levels, two picks after level five, boss HP and reward economy remain.

Cleared-round Salvage and equipment are banked before a later boss loss. Field credits remain run-only shop money. Merely reaching a boss does not grant a separate arrival reward. No reward change was made in this pass.

## Implemented rules

New campaign runs enable `intent39`; Continue preserves its stored rules. Practice remains outside the pacing/offer policy.

- Move six existing base survival XP points into the first fifteen seconds of round one, then distribute the remaining budget across the rest of the round. The full-round survival budget is unchanged. Level one costs six XP, so the current 1.25 multiplier produces the first choice by 12.5 seconds even without perfect collection. Later rounds keep the original distribution.
- Every other choice offers another rank in the most recently selected offensive tool, if eligible. The initial focus is Q. Choice two offers E if still unlearned; choice three offers W if still unlearned. All remain voluntary. Protected choices occupy stable slots, stay unique and coexist with the low-health heal card. Opening/reopening a popup does not reroll it.
- Regular packs approach from one side for ten seconds, then rotate. Existing offscreen and world-edge safeguards remain. Detached camera movement never changes spawn positions. This changes approach shape, not individual enemy targeting or speed.
- After 100 survival seconds, each fifty-second cycle starts with twelve seconds of slightly faster arrivals (delay ×0.9), then twenty-three seconds at normal cadence, then fifteen seconds of fewer arrivals (delay ×1.8). Only occasional packs in the opening burst are elite/runner packs. Existing fifty-second surges, specialist schedule and bosses remain. Recovery reduces new arrivals; it does not despawn threats or make the player safe.
- Hammer follow-ups preserve a longer existing stun instead of replacing W's 1.1 seconds with 0.25 seconds. No damage/range/cooldown/input-window increase.
- Hammer spin now sweeps visibly over most of its existing 0.3-second effect. Vulnerability uses broken brass brackets; stun uses small electrical marks. Normal/reduced effects retain the same information. Crowd status geometry is batched into four drawing calls; only badges are culled, never offscreen attack tells.
- Local result logs include actual offered/selected cards, selected ranks, spin attempts/contact counts, and sampled health/energy/enemy counts. These are bounded, process-local observations, not saved campaign history or a hit-rate estimator for other abilities. Continue begins a new observation segment. Existing screen timers remain the source for pause-time totals.

## Evidence and limits

Read-only log baseline: 184,685 bytes, last write 12 September 11:51:51 local. Latest tagged discovery35 record was a Level 3 loss at 154.52 simulation seconds, level seven. It was still level one at 30 seconds, had E by the 75-second sample, and no rank-five tool by 150 seconds. It used mixed tier-two-to-four gear and predates this pass. No raw player records were committed.

`intent39_probe.gd` uses fixed spawn/offer/loot seeds, **default starter equipment**, no purchased modules/mastery, normal health, and a limited movement/casting policy. It cannot judge feel or approximate an expert player. Three paired seeds:

| Measurement | Previous rules | Final intent39 |
| --- | --- | --- |
| First choice | 21.3–21.5s | 12.5s |
| E learned | 46.5–61.4s | 33.3–37.5s |
| First rank five | None before those runs died | 120.0 / 122.8s in two seeds; not reached in the third |
| Death time | 117.5 / 153.4 / 156.5s | 154.2 / 155.4 / 157.5s |
| Stationary gun-only seed | Dies at 17.7s | Dies at 17.8s |

The first concentrated-elite trial worsened two runs to 106–110 seconds. It was revised to occasional fast packs rather than continuous elite arrivals. This is a concrete rejected iteration, not evidence that the final wave rhythm is human-approved.

An artificial-health Level 3 route with the final flat XP curve completes all three stages in 1,010.6 simulation seconds, reaches levels 14/31/40 at stage-end encounters, and has all core skills maxed before the final boss. Peak population forty, sampled simulation p95 about 0.90ms. Artificial health allows unsafe hammer uptime and is strictly a reliability test. Boss completion interval includes the twelve-second collection phase; do not label it pure time-to-kill. Headless timing is not rendered FPS.

Initial unbatched all-status 180-enemy render reached roughly 100ms frame cadence. The batched version measured approximately 45ms normal and 51ms reduced with all statuses, versus 43ms without statuses in that run. This deliberately extreme paused fixture includes rendering/wait/scheduling overhead, and initial concurrent test load differed; it is not an isolated GPU benchmark. It catches the expensive per-enemy implementation, but existing extreme-crowd rendering still needs work.

Normal/reduced actual-size spin/status captures preserve simulation and RNG. `scripts/check.ps1` includes the new intent39 tests; historical refined probes and current full-route reliability probes remain required. Automated fixtures never save player rewards. Existing bitmap masters, pixelation, controls and equipment are preserved.

## Next human review

Start a **new run** to exercise the new policy. Check whether the first two minutes provide useful E/W choices, whether approach groups create enjoyable area attacks and escape routes, and whether the final boss remains demanding with a completed build. Look at real screen-time totals and card decisions before reducing choice frequency. No new fun/quality score is claimed.
