# Balance benchmarks · 10 September 2026

Owner direction: a correctly built, perfectly executed boss fight should take about **60 seconds**, with **90–120 seconds** available for dodging and misses. Balanced investment should maintain roughly comparable difficulty within an Operation; specialization should create advantages and weaknesses. Increase mechanical demands as mobility develops, and alternate tension with occasional relief.

This document defines acceptance targets, not claims that the current build meets them. The offline benchmark is implemented; special-round variants below are an authored design specification, not playable content yet. Existing Operations and saves are unchanged by this milestone.

## Fixed reference, meaningful choices

Balance against an authored reference loadout, never the player's live DPS, equipment or purchases. Otherwise investment is cancelled by adaptive enemy scaling. Earlier Chapters should become easier with better permanent gear; equally geared players who distribute run investment reasonably should see similar *relative* pressure across rounds. A higher Chapter may require better gear, but its gear expectation must be published in the design before tuning it.

Initial within-Operation checkpoints: levels **5 / 14 / 24**, based on the previous arrival probes, at A0. Compare balanced core ranks and four equal-point mastery allocations: balanced, offense, defense, utility. Run each with no gear and full tiers 1, 3 and 5. Full sets are controlled sensitivity cases, not a prediction of loot ownership. Core selection is an ideal budget allocation without random-card restrictions. Later add actual fixed-seed offer policies and mixed gear inventories to measure acquisition variance.

Report both medians and worst cases across builds/seeds; do not make a single winning bot the balance target. Treat Ascension separately from the base campaign. No dynamic punishment of a successful build.

## Acceptance targets

| Measure | Initial target | Why / how to assess |
|---|---|---|
| Boss ideal execution | 55–65 seconds, centered on 60 | Resource-legal, actual single-target damage including combo timing, attack animations and owned modules. Stationary contact reference first, moving boss separately. |
| Boss delivered damage | 50–67% of ideal → 90–120 seconds | Delivery combines contact time, misses and lost casts; do not independently apply three arbitrary penalties. |
| Overload | Begin at 120 seconds for standard bosses after calibration | Telegraph at least 10 seconds before escalation. It is a pressure ramp, not a forced loss. Current shipped deadline remains 180 seconds until actual legal-rotation calibration. |
| Guardian ideal execution | 15–25 seconds | Short exam between waves; 25–40 seconds with movement. Do not use the full boss budget. |
| Normal-round offensive drift | Reference enemy HP / appropriate hit damage stays within ±20% of round-one ratio | Use the same enemy role; an entire wave's total HP is a separate workload measure. |
| Normal-round defensive drift | HP lost to the same normalized hit stays within ±20% of round-one fraction | Includes player health, resistance and enemy damage. Separately test real attack sizes and overlapping hits. |
| Small swarm | One well-landed active hit; several basic-gun hits | Fragile individually; pressure comes from approach angles and space, not tank HP. |
| Mobile ranged / pursuer | About 0.6–1.0 center-W damage worth of HP | Movement is its defense. Do not also give it immobile-tank durability. |
| Stationary ranged tank | 1.2–1.6 center Ws | Must survive one reference W. |
| True melee tank | 2.0–2.5 center Ws | Its reach/attack timing matters; slow travel alone is not a challenge. |
| Ordinary hit / heavy telegraph | 8–15% / 20–30% of reference maximum HP | Starting bands for actual attacks, not a requirement that every bullet has equal damage. Cap simultaneous unavoidable overlap separately. |
| Mistake recovery | Survive two heavy mistakes from full HP; recovery requires an opening | Exclude overload and explicitly advertised challenge variants. Measure time to recover, not just nominal regen. |
| Pressure cycle | 15–25 seconds active pressure, then 4–8 seconds lower pressure | Recovery can allow attacking or collecting; it need not mean no enemies. Avoid sustained full-screen denial. |
| Skillful boss payoff | W setup + E→hammer produces ≥20% more delivered damage than equally resourced uncoordinated casting | Measure in actual combat, not the sum of isolated tooltip multipliers. Avoid compulsory perfect combos for ordinary survival. |
| Mobility budget | Early D about 5 seconds from full base energy; late base duty about 80% without spell spending | Also report simultaneous combat + 20% drive + one flash per 12 seconds. Gear/utility may exceed the base reference; that is a reward. |
| Final build completion | Level 23–25 on arrival; occasional level 26 | Keep separate from survival success. Report a distribution over at least 10 seeds before claiming the target is met. |
| AFK effectiveness | Passive-only clears <35% of active policy's wave workload | Compare identical gear, seeds, time and survivability conditions. Artificial-health policies are useful only for workload, not fairness. |

For a stationary legal rotation, recommended boss HP = damage actually delivered in 60 seconds, including starting charges. For an analytical sustained reference, HP ≈ DPS × 60 is only a first estimate. A cast schedule may deliver burst in discrete packets: verify the real kill time rather than rounding a continuous quotient and calling it exact.

Difficulty is multidimensional. Keep four separate readings: **kill effort**, **mistake cost**, **movement demand**, **decision load**. Raise one or two at a time. Increasing HP, incoming damage, shot density and movement speed together hides what caused a failure. Resistance counts as effective health: HP × (1 + resistance/100) under the current mitigation formula. Regeneration is reported separately because burst can kill before regeneration matters.

## Implemented measurement

Run from the repository:

```powershell
& '.tools/godot/Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/balance_benchmark_test.gd -- --report
```

Writes an ignored local table to `output/balance/current.md`. Uses live ability previews, actual costs, cooldowns, mastery, equipment, role floors and incoming-damage functions. Exercises 144 cases: Chapters 1/4/8 × three rounds × four gear tiers × four mastery policies. Integrity checks run in `scripts/check.ps1`. A passing integrity check does **not** certify that the target bands pass.

The reference includes ordinary hammer/MG, sustained QWER, one E-empowered hammer per eligible E, averaged non-stacking W vulnerability excluding W's own triggering damage, and rank-ten gun/R multipliers. Spell throughput uses a 60-second energy envelope (regen plus full starting energy divided by 60). Movement reserve reports 20% D duty and one flash per 12 seconds separately. Full contact and proportional spell allocation are assumptions; this is **not an executable perfect rotation**. Opening charge burst, cast-lock interactions, spatial travel, modules, companion damage and mastery proc damage are omitted. These omissions act in different directions, so the number is neither a rigorous upper nor lower bound.

The normalized defense probe uses one hull-unit attack with current chapter/round/boss scaling, no temporary shield, regeneration, dodge or overload. Tank/W is the minimum role floor divided by the reference W; actual spawn base HP can exceed the floor. Neither is a measured death or hit-count replay.

## Initial findings on 0.20

Equal-core level-24 balanced mastery, full tier-one gear, no modules/pets/procs:

| Chapter | Boss HP | Analytical DPS | Quotient kill time | At half delivery |
|---|---:|---:|---:|---:|
| 1 | 6,000 | 338.5 | 17.7s | 35.5s |
| 4 | 9,960 | 338.5 | 29.4s | 58.8s |
| 8 | 15,240 | 338.5 | 45.0s | 90.0s |

This flags the early boss as potentially too short **for coordinated contact**, and shows fixed Chapter growth with identical gear. It does not justify blindly changing HP to the roughly 20,310 implied by the formula: previous moving-boss bot fights lasted much longer and did not use this loadout. First measure a legal W/R/E/hammer rotation and module contribution; then tune boss HP and the deadline together. The current 180-second overload has 120 seconds of margin relative to the requested ideal, rather than the requested 30–60 seconds.

The Chapter-1 tank floor falls from **1.81 reference Ws in round one to 0.99 in round three** for the balanced tier-one case. Rank-ten spikes plus mastery outgrow the existing rank-8 floor. This misses both stable role durability and the two-W tank goal. Use a complete authored build reference rather than raw skill rank when revising these floors.

The same reference takes **7.0% / 7.4% / 9.8%** maximum HP per normalized hit in Chapter 1: roughly 40% higher fractional damage by the final boss. Some of that is the explicit boss multiplier; compare ordinary-round attacks separately before claiming uniform survival scaling. Offensive/defensive profiles expose the intended tradeoff without modifying the enemy for each profile.

## Variation schedule to implement after calibration

Keep standard three-round Operations as the teaching baseline. Preview any variant on Chapter selection; serialize its authored ID in checkpoints and logs before adding it to routes. Old checkpoints retain their schedule. Challenge rewards bank only after a clear, using the existing rollback transaction. No surprise duplicate final boss or hidden difficulty roll.

| Variant | Duration / workload budget | Challenge | Reward / safeguard |
|---|---|---|---|
| Salvage sprint | 30-second bonus segment between rounds | Pickup routing, a few clearly warned hazards | Field credits only, capped at 25% of that Operation's normal field budget. No extra core XP: preserve the final-level target. Never replaces a level-bearing survival round without redistributing its XP. |
| Elite hunt | One guardian at 1.35× normal guardian HP | Fewer swarm bodies, one additional attack interaction | 1.25× guardian field reward; bounded HP avoids a prolonged damage sponge. |
| Twin guardians | Two guardians, 0.6× normal guardian HP each | Prioritize a target and track two positions | Share an attack scheduler: alternate major attacks, retain an escape lane. Never two independent full-strength patterns. |
| Terrain crossing | 30–45-second marked objective window inside survival | Body-blocking obstacles, moving between safe pads | Keep projectile-pass-through wall rules. Guarantee a walking route; flash gives advantage but is not mandatory. |
| Reactor surge | 20-second high-pressure wave then 8-second recovery | Change target priority to a visible emitter | Clear warning, fixed end time, no sustained chain EMP. Reduce other pressure while teaching the emitter. |

Intro schedule: Chapter 1 standard; Chapter 2 salvage sprint; Chapter 3 elite hunt; Chapter 4 terrain crossing; Chapter 5 twin guardians; Chapter 6 standard with a reactor-surge window; Chapter 7 salvage sprint; Chapter 8 mixed exam using already taught mechanics. At most one major variant per Operation at first. The final boss remains recognizable. This schedule is a proposal for the next content milestone, not a statement that the current route already runs these events.

Movement progression should unlock richer patterns, not erase reaction windows with unlimited speed growth: early single aimed shots → predicted shots with clear windup → sweeping beams / staggered zones → alternating attacks from two sources. Audit the required escape distance divided by available travel time against the reference walking/D/F kit. Do not require an ability still locked by card luck, and avoid pairing EMP with an otherwise flash-only escape.

## Next calibration order

1. Capture a resource-legal ideal boss rotation plus boss-only damage, encounter start/end and combo contribution; compare stationary and moving targets. Include affordable module builds and several offers/seeds. Calibrate 60-second HP, then 120-second standard overload.
2. Rebase ordinary role floors and incoming damage on fixed complete balanced reference builds. Check specializations retain strengths and weaknesses. Keep permanent equipment's advantage in earlier Chapters.
3. Ship one salvage-sprint and one twin-guardian variant, including explicit route/checkpoint/reward tests and human readability review, before multiplying the content matrix.

No human fun score or balance acceptance follows from the analytical harness. The aim is a repeatable explanation of why a round is harder, then confirmation that its particular challenge is enjoyable.
