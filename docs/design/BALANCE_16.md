# 0.16 — Focused design and damage pass

## Vanguard milestone / pacing follow-up · 9 September 2026

Supersedes earlier mobility/tower/pacing numbers for Vanguard only. E reach: 209 / 292.6 / 397.1 at ranks 1 / 5 / 10 (1 / 1.4 / 1.9×); same movement speed, damage, two charges and one 2×-remaining wall rebound. D upkeep starts at 12/sec, tapers to 11.4 at rank 4, then 7 at rank 5 and 6 at rank 10; rank 10 removes the drive casting/hammer restriction. D is held upkeep, not a cooldown skill. F unmodified recharge is 10.8 / 6.4 / 5.4 seconds at ranks 1 / 5 / 10, costs 20 below 5 and 12 thereafter; rank 10 arrival blast has 110 radius and 30×damage_scale(f) damage (118.8 without gear/mastery/rarity). One arrival hit, not departure damage.

Bulwark retains MG-linked gun output; its own damage/hull curve remains. Rank 5 pulse interval 2.4→1.8s and radius 125→145; rank 10 radius 165 plus 0.3s stun on ordinary enemies. Reserve retains its power curve (rank 5 larger bank/rate/radius); rank 10 banks even while inside, creating ongoing repair. Overclock lasts 5 / 7 / 9 seconds, with recharge 2 / 2 / 3×; free skill energy and expiry-started cooldown remain. Live upgrades update deployed hull proportionally, radius and remaining duration; they do not heal a damaged unit to full.

Universal level/chest points replace alternating learn/upgrade. Earned rank 6+ requires all twelve tools at earned rank 5, including MG/hammer and initially unlearned tools. Gear bonuses do not satisfy the gate. Old high ranks are not removed; older queued learn/upgrade strings become universal points without save-schema changes. Practice 1/5/10 remains unrestricted.

XP pickups grant one-third the previous XP, retaining fractional gains and prior threshold taper. Raw collected value, loot quantity, credits and chests are unchanged. Existing XP/ranks stay intact. This combination delays milestones substantially: fixed-seed Vanguard naive active/basic policies now lose in round 1 at 28.5/24.2s (idle 17.4s), versus prior basic policy reaching round 15. Policy choice and timing are sensitive to progression; this is a serious early-pacing playtest flag, not a human win-rate prediction. Enemy damage has not been lowered to hide this change.

## MG follow-up · 9 September 2026 (supersedes MG numbers below)

| MG metric | Rank 1 | Rank 5 | Rank 10 |
|---|---:|---:|---:|
| Ordinary damage | 1.20 | 1.80 | 2.88 |
| Shots/sec | 4.17 | 5.00 | 6.67 |
| Average single-target DPS | 5.00 | 9.00 | 23.04 |
| Bulwark gun average DPS | 4.25 | 7.65 | 19.58 |
| Fire during E/D | No | Yes | Yes |

Rank-ten averages include 4 ordinary + 1 double-damage round per five actual shots. Damage multipliers: 1/1.07/1.14/1.21/1.50/1.64/1.78/1.92/2.06/2.40. Shot intervals: .240/.232/.224/.216/.200/.190/.180/.170/.160/.150 seconds. Rank 5 buys 1.8× baseline sustained damage plus dash uptime; rank 10 buys 2.56× rank-five single-target DPS plus 450-range, four-target piercing shots. Normal range stays 265; Bulwark uses 320/520. No target means no shot/counter progress. Piercing density, misses, overkill, dash uptime and energy affect real output.

Bulwark gun power and cadence now follow MG ranks instead of independently multiplying its own damage rank. Bulwark's own HP/pulse growth remains. Rank-one MG is intentionally slower than the preceding 7.5-DPS build (now 5 DPS); preserve active-skill/enemy numbers until owner review. The diagnostic `VANGUARD_POWER gun_dps` column reports ordinary-shot DPS (19.2 at rank ten), not the fifth-shot cycle average shown here.

## Vanguard rank-power pass · 9 September 2026

Current Vanguard only; historical shared-pool formulas below remain regression references. Damage multipliers by earned rank 1–10: **1 / 1.08 / 1.16 / 1.24 / 1.60 / 1.77 / 1.94 / 2.11 / 2.28 / 3.30**. Gear's learned-rank bonus remains capped at 10.

Fresh Practice fixture, no gear/mastery/rarity bonuses, theoretical continuous hits:

| Metric | Rank 1 | Rank 5 | Rank 10 |
|---|---:|---:|---:|
| Hammer head DPS | 36.19 | 60.80 | 132.00 |
| Hammer reach / full angle | 125 / 90° | 156.25 / 120° | 187.5 / 140° |
| Hammer movement during swing | Stops | Stops | Allowed |
| Independent MG DPS | 7.50 | 13.33 | 30.94 |
| Q/W/E/R sustained damage ratio | 1.00 | 1.80 | 4.40 |
| Active effect radius ratio | 1.00 | 1.25 | 1.50 |

The requested approximately 2× then another 2–3× is a **practical-power target**, not a mathematically measurable fun score. Active sustained damage rises 1.8× then 2.44×; increased area and milestone utility supply additional reliability. Hammer's wider arc/reach and removal of attack rooting add substantial usability beyond its raw DPS. MG grows 1.78× then 2.32×. These figures exclude energy starvation, travel, missed centers, armor, enemy density and interrupted casts. Radius must not be multiplied blindly into single-target DPS.

R rank 10 splits its 3.3× per-cast budget 80% primary / 20% echo, instead of doubling the new curve again. Orbit per-blade damage divides by sqrt(blade_count / 3), partially compensating for its extra blades; unmodified capacity gives total blade-budget ratios approximately 1 / 2.07 / 4.67, not guaranteed delivered DPS. Bulwark HP/gun/pulse and Reserve storage/banking/overflow share the curve; Reserve discharge scales by its square root. Mobility and the five-second Overclock well keep their existing utility rules and recharge bonuses. Overclock doubles charge refill as well as cooldown ticking.

Automated verification: `tests/vanguard_test.gd` prints this damage table and checks rank/save/movement/geometry invariants. Bot probes validate simulation and pressure only. Human review should compare rank 1/5/10 against the same dummy and cluster, with MG disabled when measuring hammer or actives.

## 0.18 second-playtest addendum (9 September 2026)

Third-playtest follow-up: E stores two charges at its existing recharge/damage/energy cost. This increases available burst/escape storage, not sustained charge generation. Walls no longer absorb friendly or enemy shots in current rules; cover-based survivability changes even though no enemy damage values changed. Re-evaluate ranged pressure in human playtests.

Owner-requested Vanguard tuning supersedes older values only for Vanguard: Q rank-one sequential recharge 4.0s, with two-charge storage (storage was already two). Its prior unmodified rank-one recharge was 2.7s, so sustained generation is 67.5% of the previous value; individual hit damage is unchanged. W storage increases from one to two at ranks 1–4; its recharge and damage are unchanged, so burst availability rises but steady-state generation does not. Existing rarity/mastery/rank reductions still apply.

Close orbit rotates at 10.2 rather than 3.4 rad/s, and the per-blade hit lockout is 0.14 rather than 0.28s. Far mode stays 1.6 rad/s / 0.28s. Neither ratio is a reliable DPS multiplier: blade count, target size, orbit distance, movement and contact windows matter. Dummy meters are the intended owner comparison tool. Enemy stats, E/R damage and energy costs are unchanged in this pass.

## Decision

Preserve enemy difficulty. Owner feedback after the previous build was positive; this is not evidence that eight stages or all builds are balanced. Make one small ability adjustment: Welding torch total damage **24 → 26** (+8.3%), still eight ticks across two seconds, same range/cost/recharge. Mirrored torch damage follows the new value.

Its 190-range exposure, continuous steering and modest single-target throughput justify a small bump. No blanket buffs to the gun, laser or enemy damage. Discovery flexibility itself is a substantial balance change; test that before larger numerical changes.

## Output model

Single-target sustained ceiling = damage per activation / recharge. Charges change burst storage, not long-term charge generation. Expected useful output additionally depends on hit fraction, targets reached, overkill, availability, energy and exposure. Do not balance a heal, displacement, wall or escape as a zero-DPS failed attack.

At rank zero, Common rarity, no gear/mastery:

| Skill | Full activation | Recharge | Single-target ceiling DPS | Energy / activation |
| --- | ---: | ---: | ---: | ---: |
| Impact bolt | 15 direct + 8 blast | 3s | 7.67 | 8 |
| Welding torch, revised | 26 across 2s | 7s | 3.71 | 18 |
| Reactor drop | 85 | 16s | 5.31 | 28 |
| Core cutter | 375 across 5s | 30s | 12.50 | 40 |
| Return blade | 22 out + 22 back | 7s | 6.29 | 14 |
| Core strike | 32 edge / 64 center | 9s | 3.56 / 7.11 | 18 |
| Gravity well | 36 across 3s | 13s | 2.77 | 24 |
| Piston thrust | 25 | 3s | 8.33 | 9 |
| Siege battery | 3 × 65 | 30s | 6.50 | 36 |

Autonomous machine gun: 1.5 / 0.16 = **9.375 DPS** before misses; sniper 7 / 0.8 = **8.75 DPS**, trading throughput for reach/precision. Commanded ranged basics: 2 / 0.43 = **4.65 DPS**, plus deliberate targeting and class/proc interactions. Brawler basics: 7 / 0.43 = **16.28 DPS**, paid for with short range. These mechanisms are separate.

With just the auto gun enabled, 8 regeneration − 2 upkeep leaves 6 energy/sec. Q consumes 8/3 = 2.67 energy/sec at continuous charge use. More powered toggles and actives compete for the remainder. Nine available general slots do not imply nine abilities can be sustained simultaneously.

The tier-5 companion adds one autonomous gun, not one per armor piece. It follows gun damage/interval, fires straight projectiles, and has finite range. Permanent tier bonuses are intentionally nonstacking to avoid an eight-piece +8-rank jump.

## Measured geometry, not predicted human accuracy

`tests/skill_damage_probe.gd` invokes the actual skill and collision code against one high-health ordinary target. No spawning, gear, mastery, automatic gun or passive damage. One activation; 20-second observation. Melee/cone fixtures start at 130 units, others at 260. Movement uses 12 deterministic phases, 70–120 lateral amplitude and 1.3–2.1 rad/sec. Snapshot aims at the initial position. Tracking updates sustained aim and uses the fixture's known trajectory to lead eligible projectile/delayed attacks. That is an optimistic policy, not a realistic player bot.

Measured fraction of the listed activation budget, before the torch's proportional damage increase (fractions are unchanged by that increase):

| Skill | Snapshot mean | Tracking / prediction mean |
| --- | ---: | ---: |
| Impact bolt | 33.3% | 100% |
| Welding torch | 58.3% | 100% |
| Reactor drop | 100% | 100% |
| Core cutter | 33.6% | 90.1% |
| Return blade | 33.3% | 100% |
| Core strike | 58.3% | 100% |
| Gravity well | 72.4% | 72.4% |
| Orbital entry | 83.3% | 100% |
| Siege battery | 66.7% | 88.9% |

All 18 tested stationary activation budgets matched their simulated damage. Immediate melee casts hit before this fixture starts moving; their 100% is not real-fight reliability. The fixture overrides enemy position, so crowd-control benefits are not measured. Broad blasts cover this lateral path, explaining 100% Reactor drop—not proving it never misses. Crowds, target size, walls, knockback, energy, overkill and human reaction need encounter tests.

The laser's raw ceiling is high, but its movement lock and tracking demands create a distinct cost. Do not nerf it just because 375 is the largest single number. Look at realized damage per exposure window, escape use and deaths while channeling.

## Reference application

Riot's clarity discussion prioritizes recognition, hierarchy and restrained noise. Application here: unique icon silhouettes, stable key positions, quieter environment colors and small local resource bars; meaningful danger retains visual priority. Those implementation choices are ours, not Riot's numerical recommendations. [Clarity in League](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/).

The VFX guide provides a reference for coordinating shape, value, color and timing. Application: a brief lid-open anticipation, outward rays, then settled rewards; no full-screen flash or input lock. Keep teal/steel as shared materials, with orange heat, mint repair, blue electricity and a limited gravity accent. [League VFX Style Guide](https://nexus.leagueoflegends.com/en-us/2017/10/dev-leagues-vfx-style-guide/).

Godot's image-import documentation describes size limits and mipmaps. Application: retain original illustrations, import icons at 256px with mipmaps, inspect them at the actual 32/64/128px sizes; source resolution is not evidence of HUD clarity. [Importing images](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html).

## Next measurements

- Three owner runs: time in choices, accidental replacements, slot recall, first-boss deaths and felt power jumps.
- Damage/usefulness by chosen skill and acquisition time; avoid comparing a late pickup with the starter's full-run damage.
- Time to first forge and first tier 4; don't require grinding to make A0 enjoyable.
- Whether nine flexible slots produce satisfying choice or just excessive energy shutdowns.
- Crowded normal/reduced-effects screenshots and actual audio listening, not only headless checks.
