# 0.16 — Focused design and damage pass

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
