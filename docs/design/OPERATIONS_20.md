# Chapter Operations · working review build 0.20

10 September 2026. After requesting research and completion of the feedback, the owner said to keep going. The agent explicitly proceeded with the recommended Chapter/Operation structure as a working version for review; no questionnaire choice was received. [Research and original proposal](PROGRESSION_RESEARCH_20.md) explain the design. Human feel remains unverified.

## The playable loop

**Chapter** is a replayable numbered selection. Eight Chapters currently reuse the existing eight boss configurations and three world sectors; this is not hundreds of finished levels or eight unique maps. Clear the highest available Chapter to unlock the next. Earlier Chapters remain replayable.

**Operation** is one attempt at a Chapter, consisting of three **rounds**. Survival lasts 90, 105 and 120 seconds, followed by a guardian in rounds one/two and the Operation boss in round three. Every clear has 12 seconds of collection and a field shop. The third clear finishes the Operation. The framework can be extended with authored content later; 2-/5-round variants are not currently shipped.

A new Operation resets earned ability ranks, modules, run mastery and field credits. It starts with Q/D/F/MG/hammer at rank one; W/E/R are learned through the paused cards. Equipment, Salvage and Chapter clears persist. Continue resumes a cleared-round checkpoint. Existing 22-round checkpoints keep their original route and progression flags; creating a new Operation uses the existing replace-checkpoint confirmation and preserves banked ownership.

## Short-run progression budget

- Every level grants three successive choose-one-of-three core picks; cards show numerical differences and retain full mechanics on hover.
- Core XP cost is 20 per level. Level 26 completes the 75 remaining picks for all eight core tools. No level beyond 26 in an Operation; modules still have their separate rank cap and purchase budget.
- Survival contributes 40 / 60 / 80 XP gradually across the three survival segments, then stops during the encounter/collection. These claims are persisted per round, preventing resume/repeated-step duplication. Without kills/pickups the foundation reaches only level 10, leaving most progression earned through collection.
- Pickup XP divides raw value by `18 × (1 + 0.36 × (Chapter − 1))`. This is a fixed authored density adjustment, independent of the player's actual build. Later Chapters spawn more enemies; this adjustment prevents that density from maxing the build early. Existing non-Operation progression retains its earlier curve.
- Design target: level 23–25 on entering the final boss, 88–96% of the core-upgrade budget, with occasional completion during the fight. Fixed-seed A5 artificial-health tests reached final-boss entry at levels 23 (Chapter 1) and 24 (Chapter 8); those are policy samples, not a population distribution or guaranteed human result.
- Unified run mastery: 13 nodes, one root and three branches, one point per level, 29 maximum purchases. Old saved trees retain their rules. Module spending supports a chosen build rather than automatically completing all four modules.

## Two separate currencies

**Field credits** buy and upgrade Orbit/Bulwark/Reserve/Overclock after any round. Chests award 20 field credits, without equipment or skill points in Operations. Coin supply drops enter this wallet, not permanent currency. Round-clear field grants are 350 / 500 / 650. No field-to-Salvage conversion. Module price remains `100 + 65 × current rank`; ownership ends with the Operation.

**Salvage** is the existing persistent credit balance, displayed with a distinct name. No value is deleted or converted at a loss. Each cleared round banks `40 + 15 × round_index + 5 × Chapter` Salvage (plus the existing Ascension banking multiplier). A Chapter's first completion grants 100 extra Salvage once. Replays grant normal cleared-round Salvage, and do not repeat the first-clear bonus. The first-clear flag, balance and checkpoint are saved in one transaction. Failure restores the profile and retains pending rewards for retry.

At Home → Equipment, 150 Salvage buys one supply crate. Exact tier chances are 80% / 17% / 2.8% / 0.2% / 0% for tiers 1–5; slots are equally likely. The button states the price and its tooltip states odds. The result selects the received item for inspection and reports its name. Three-copy forging remains the path to higher tiers, including tier 5. Purchases restore currency, inventory and RNG state on failure; capped inventory does not consume currency. Crate randomness is saved independently of combat RNG.

Profiles remain Forge v3 with optional `chapter_cleared` and `crate_rng` fields. Old v3 files lacking them remain valid; originals/migration sources are not rewritten by tests. Equipment's existing copies, equipped items and balances remain. Tier-3+ helmets/chests retain the 0.19.1 regen additions.

No permanent mastery purchases, random module permissions or persistent potions in this pass. Those were tentative ideas and would complicate the requested temporary-build reset. New module variety can be introduced through deterministic Chapter unlocks later.

## Encounter budgets

Operation bosses use a separate budget: `6000 × (1 + 0.22 × (Chapter − 1)) × (1 + 0.12 × Ascension)`. At A0 this is 6,000 HP in Chapter 1 and 15,240 in Chapter 8. The old 22-round boss HP is unchanged. The reduction belongs to the new shorter structure with fewer earned resources; it does not reinterpret the owner's earlier approval of the old real-boss HP.

Operation overload starts three minutes after boss arrival, with a visible countdown. It ramps incoming damage up to 10x, accelerates gapped projectile rings and shortens recovery; it never directly sets a loss. The long-route compatibility build retains its five-minute deadline. A5/undergeared bot completion after overload is possible with artificial health and is not evidence that a human can survive it.

Ordinary enemy HP uses Chapter factor `1 + 0.22 × (Chapter − 1)` and round factors 0.8 / 1.25 / 1.9. Ranged/melee role floors reference W ranks 2 / 5 / 8 with the actual 1.2 kit multiplier. Incoming damage starts at 55% of the earlier base and grows by round/Chapter; movement growth stays capped. Boss HP/damage, mastery and equipment assumptions are explicit rather than adaptively matching the player's live damage.

Most specialist types arrive by round two; EMP begins in Chapter 2. Current combat retains W vulnerability/center stun, E→hammer boss combo, delayed R, moving bosses, thick terrain, restrained early Orbit and costly early D. Bosses keep the existing body/attack family; additional unique assets are not implied.

## Verification and next review

`tests/operation_test.gd` covers reset boundaries, all eight Chapter definitions, legacy v3 acceptance, checkpoint resume, first-clear idempotence, failed-save rollback, currency separation, fixed-seed crate distribution and actual Chapter/equipment UI flow. `tests/review_rules_test.gd` covers combat/mastery/card details. Render tests use explicit Dummy audio because the host WASAPI device is unavailable; silent rendering is not audio validation.

Current probes use `-- --vanguard` for Chapter 1; add `--soak --chapter=8` for the last Chapter with artificial health. `--long-route` retains the 22-round comparison. Run seeds and the default combat loot seed remain unchanged. Probe output now includes encounter arrival levels/times. No automated rewards are written to the player's profile.

Next human review: (1) opening pacing, learning W/E/R and the number of paused selections, (2) final-boss counterplay and overload time with real health, (3) Chapter replay/Salvage/field-credit clarity and equipment payoff. No fun-score increase follows from passing tests.
