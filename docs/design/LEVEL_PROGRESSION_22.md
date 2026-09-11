# Level progression · 0.22

Owner authorized the accumulated progression/menu changes, then explicitly paused replacement of the energy/turret modules. The latest human verdict is that combat feels good, each ability has a purpose, E has several useful roles, and Reserve is strong. Preserve that evidence rather than using crude bots to justify a broad combat rewrite.

## Implemented

- Eight numbered **Levels**, each three rounds. No Ascension selection or new-run Ascension bonus. Old checkpoint difficulty remains compatible. Next round/Finish level is always visible across the four camp tabs. Victory leads to the next level's preparation screen; Level 8 leads to level selection. Loss offers Retry level.
- Existing W damage/status behavior is retained; new-run recharge takes 15% longer. E, R, boss HP/patterns, Bulwark, Overclock and Reserve mechanics are retained. Reserve gets a readable fill bar, inward charging marker and dormant marker. Player local HP bar grows from 46×4 to 70×9 logical pixels with high-contrast depleted background and quarter ticks; energy remains separate below it.
- Equipment is the main persistent durability source. Same-slot HP/resistance tier multipliers are now **1 / 2 / 3.5 / 5.5 / 8**. Boots give **8.5 / 12 / 17 / 23 / 30%** movement speed: bounded rather than multiplied without limit. Tier-one starting equipment is unchanged. Existing owned items retain ownership and receive the new stat values; no inventory wipe.
- Crates still cost 150 Salvage. Tier odds are **94 / 5.5 / 0.48 / 0.02 / 0%**, disclosed on hover. Higher-tier direct drops are rarer; three identical pieces still forge upward. Auto craft resolves all eligible chains; Auto equip picks the highest owned tier in every slot. They are explicit buttons, not automatic consumption upon acquiring an item. Bulk actions and camp checkpoint updates roll back on save failure. Crafting replaces an equipped item when its final copy is consumed; Auto equip handles all other optimal-slot choices.
- Hidden recovery assist: a loss at the next uncleared level, after at least 90 simulation seconds and 60 kills, arms **45 Salvage** for fully clearing the previous level. Levels 2–8 only. At most once per frontier level for the lifetime of the profile; failures cannot stack or renew a consumed assist. No reward for quitting, Practice, automation or already-cleared challenges. Beating the frontier clears an unused assist. Redemption is part of the existing atomic camp transaction. This discourages farming; it is not a claim to prevent save-file editing or every possible deliberate-death strategy.

## Run-only mastery

New runs use one root and three branches. Older checkpoints retain their existing mastery tree. Every node remains hoverable while unavailable; purchases require the parent fully ranked. No new raw health/resistance/damage mastery branch. There are 31 possible point spends and at most 26 regular earned points, so choices remain.

| Branch | Nodes, in order |
|---|---|
| Utility | Hammer reach +8/rank; ability/drive energy cost −4% and regen +0.2/sec per rank; EMP duration −10%/rank; Q stores one extra charge |
| Looting | Pickup XP +3%/rank; field-coin and banked-Salvage value +4%/rank; unlock rare monster resource supplies; 1% double field-credit chest |
| Pet | Untargetable helper, 2 damage/rank every 1.5s at 240 range; collection radius +12/rank; 0.15 HP/sec/rank after 3s without damage; single ordinary-target 0.25s stun every 6s |

Each non-capstone has three ranks; each capstone has one. Root adds 10 pickup radius. Helper is suppressed by EMP, does not tank/aggro, and cannot stun bosses. The Utility capstone uses an extra Q charge because an unlearned-ability reward would often be obsolete by that point in a run; it does not speed recharge or add a key.

Energy/repair drops from monsters are off until Resource recovery is learned. Its total drop chance is 1% per rank, choosing energy or repair equally; amounts are 12+4×rank energy or 2+rank **HP**, without the legacy hull-unit multiplier. Legacy speed/reset supplies are also off for these new runs. Coin drops remain. Survival XP, base chest credits and crate tier odds are unaffected by Looting; the branch earns more opportunities rather than changing hidden rarity. Pet bombs, blindness resistance and new enemy vision mechanics are not claimed as shipped.

The `level22` flag distinguishes new-run behavior. Forge profile remains v3 with optional recovery fields; malformed mastery dependencies, point counts and inconsistent recovery state are rejected. Player saves are never test fixtures.

## Deferred modules: brainstorm, not implementation

Keep the current modules for this review. No stationary siege form, form-swapped QWER, support detonation or restored projectile-wall collision in this pass.

1. **Returning capacitor:** throw a device through a pack, then recover it for energy. Early recall gives a small safe refund; letting it travel or hit several enemies increases the return. E can reposition for collection or bounce out after retrieving it. It trades route/safety for casting endurance, rather than adding another unconditional aura.
2. **Mobile overdrive:** a brief manually triggered gun/hammer boost that builds heat. End it early to retain a modest energy refund; push it longer for damage but temporarily lose the boost afterward. Walking remains available, E/F remain normal. Measure it against ordinary attacks so pressing it on cooldown is not always correct.
3. **Recall anchor:** place a short-lived decoy that draws a limited number of ordinary enemies; recall it to pull nearby enemies toward its old position. Useful for grouping W, escaping, and creating a Reserve return window. It should do little or no independent damage, and bosses should resist displacement.

Preferred first Practice prototype: returning capacitor. It addresses the weak energy module with movement, aim and retrieval decisions. Prototype one replacement at a time; preserve Reserve's working identity and the current core-kit feel. No new module purchases or migration rules should ship until the prototype is selected.

## Verification

`level_progression_test.gd` exercises mastery effects/dependencies/resume, bulk transactions, failed-save rollback, bounded recovery redemption, pet damage/suppression, supply HP units and actual menu navigation. `-- --render` captures all camp tabs, victory, level selection and normal/reduced combat with silent fixture audio. Full `scripts/check.ps1` includes it. `balance_benchmark_test.gd` now uses this tree/W with Utility/Looting/Pet reference allocations; old numerical findings in BALANCE_BENCHMARKS_21 remain historical 0.20 observations.

Current ordinary bots still die early; this does not override the owner's newer positive human verdict. Full-route soak uses artificial health, not human balance. Exact final results live in QA_18 and SESSION_HANDOFF. No gameplay restart or player rewards were performed for verification.
