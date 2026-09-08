# Demo blind-spot audit — v0.7

September 8, 2026. Stage 1 / Levels 1–3 only. This pass improves comprehension and failure diagnosis without adding campaign scope or raising damage to manufacture difficulty.

## Research and comparison

- [Riot: Clarity in League](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/) emphasizes recognizable silhouettes, visible power sources, facing and a hierarchy where consequential information wins attention. Applied here: a directional plow for Ram Warden, twin barrels for Artillery, protected threat audio, and warnings that routine loot notices cannot replace. Our conclusion: clearer information is more valuable than adding more effects to every event.
- [Riot: Champion Counterplay](https://www.leagueoflegends.com/en-us/news/dev/quick-gameplay-thoughts-may-14/) argues for comprehensible responses to dangerous actions. Applied here: retain existing walking counterplay and explain actual damage after it occurs. A marked boss fan must actually fire even when friendly bullets fill the pool. We did not make blink mandatory or change enemy damage.
- [Game Developer: Starbreeze designer's pacing method](https://www.gamedeveloper.com/design/feature-starbreeze-designer-shares-game-pacing-method) summarizes Filip Coulianos's method of separating gameplay activities and measuring time in each. Applied here: local combat/choice/inspection/pause timing, plus probes for rapid choice chains. The article is a historical interview summary, not a current Godot implementation guide.

The hybrid comparison remains useful: Survivor-like play tolerates a strong automatic baseline; champion combat needs readable threats and deliberate solutions. A player should be able to win with few buttons and good positioning. Automatically demanding seven-button mastery would contradict the accessible preset. However, four scripted probes cannot establish human balance.

## Findings → implemented changes

| Blind spot | Evidence in previous code | Change |
|---|---|---|
| Required enemies can leave the view or hide under the HUD | Minimap dots existed, but no labelled direction cue; boss bar selected first array entry | Screen-edge pointers for both wardens/final boss; nearest live objective owns the health bar. Tested both zoom limits and camera edges. |
| Wardens shared almost the same body | Both used a scaled gear and rectangular face | Directional bronze plow versus twin-barrel chassis, retaining the established workshop materials. No bitmap-generation dependency. |
| Failed attacks could be silently omitted | A full projectile pool rejected all additions, including hostile shots | Hostile shots replace an existing friendly bullet at capacity. Entirely hostile pool remains bounded. Normal unsaturated behavior unchanged. |
| Feedback could hide the important event | Every announcement overwrote the previous one; all sounds shared the same rotating voices | Priority-protected boss/phase messages; three sound voices reserved for important events. Added windup, phase, arrival, clear and milestone cues. |
| Player could not explain a lost hull point | Damage counter had no cause; death screen only totals | Short damage-source HUD text, steady direction arc, context-specific defeat tip and the last 32 real hits in local summaries. Shield blocks/invulnerability do not overwrite it. |
| Rebinding made opening instructions wrong | Opening prompt always said Q W E; sector event immediately replaced it | Prompt uses actual configured keys and survives initial event draining. |
| Hold-Tab disabled ordinary menu navigation | Input handler consumed Tab even on the home/loadout screens | Only consume the inspection shortcut where it applies; actual Tab focus movement is regression-tested. |
| Five-minute claim ignored menu time | Saved data measured simulation time only | New runs record wall time and seconds by screen locally; restart resets measurements. Pauses stay distinguishable from choices. |

## Evidence

- Original smoke test + **929 checks**, zero failures: 165 salvage / 102 MOBA / 55 iteration-04 / 476 iteration-05 / 43 demo / 88 readability. Storage readback passed.
- New saturation test fills all 240 projectile slots and confirms that a promised five-shot fan still emits five hostile projectiles, without exceeding the cap.
- New geometry tests cover two simultaneous required targets, five directions, two zoom values and three camera/player locations. Visible/dead enemies do not produce redundant pointers.
- Five constructed 960×540 captures inspected, including widest zoom with reduced effects. Warden silhouettes were revised after the first capture because their new attachments were too obscured by the old body. Final warden capture has correct Level 2 labels/health.
- A full rendered Relaxed/2407 run completed: 291.48s, 950 kills, 4,424 scrap, Power 32, one hit (Charger charge at 142.22s). RTX 5070 prefix sample: 19,940 intervals, median 4.947ms, p95 9.258ms, peak 46 enemies in that sampling window. Not a hardware guarantee. This run preceded the final silhouette, menu-Tab and screen-time refinements, which were subsequently captured or regression-tested.

### Less-informed behavior probes

`tests/demo_behavior_probe.gd` uses normal health, random offered upgrades, movement decisions at 5 Hz and enemy positions only. It never reads windup state, hazard timing or future input. Few-buttons tries Q/W/E/R every three seconds; it never uses D/F/T. Passive-only casts nothing. Upgrade choices are instantaneous, so this is not measured human wall time.

| Policy | Seed | Outcome | Combat seconds | Hull hits | Power |
|---|---:|---|---:|---:|---:|
| Passive-only | 2407 | Lost, final boss | 349.82 | 6 | 31 |
| Passive-only | 2408 | Won | 365.32 | 2 | 32 |
| Few buttons | 2407 | Won | 307.23 | 2 | 32 |
| Few buttons | 2408 | Won | 304.47 | 3 | 33 |

Each probe produced 30–32 upgrade choices. No chain of multiple choices less than one combat second apart occurred. That does not prove thirty choices feel good: human reading time is the important missing variable. Heal pickups permit total hits above starting hull. These are four positional policies, not four representative people. No difficulty change was justified by this sample.

## Remaining priorities, not speculative features

1. P0: Human readability at crowded moments: does a player recognize charge versus blast, and understand the defeat tip? Functional tells are not enough if attention never lands on them.
2. P1: Human movement/aim feel and whether the limited-button route stays engaging. Compare purposeful casting during recovery to circling passively; do not simply add more keys.
3. P1: Use screen timing to locate excessive choice time. If choices dominate, improve summaries or offer pacing before extending the run.
4. P1: Check whether rank-5/10 transformations are felt, not just read. Strengthen only the relevant ability's shape/audio if necessary.
5. P2: Sector identity remains light. Add one useful landmark or encounter-layout change only if the three-level arc is hard to notice. Avoid obstacle/pathfinding scope until required.

No new assets, credentials or user decisions block this pass. Commercial polish, actual sound-mix preference and human fun are not certified by tests. The next build should respond to the largest observed issue inside this demo, not grow a fourth level.
