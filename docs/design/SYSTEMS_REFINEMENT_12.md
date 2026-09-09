# Combat foundations and the eight-stage loop

Design direction, implementation boundary and backlog · 8 September 2026

## Decision

Build a survivor-like with **two simultaneous layers**: autonomous tools create steady spectacle, while deliberate basic attacks, aimed skills and positioning create agency. Three eventual classes emphasize ranged kiting, melee sustain or summon placement. They share the same input language and art grammar.

0.12 implements the first combat foundation: immediate auto gun + Q, a separate commanded basic attack, cursor-priority attack move, gun/sniper/off modes, an energy-powered coolant trail and one mastery point per Power level. It does **not** implement an eight-stage campaign, class selection, chest-based unlocks, shops, ascension selection, a large tree or forty new equipment items. The existing three-round demo remains playable while those systems are designed. D/F and later timed unlocks remain as a temporary compatibility bridge; they are not the intended chest-based progression.

## Confirmed interpretations

- The auto machine gun is independent of basic attacks. S, ground movement and attack targeting do not switch it off. Its toggle and existing energy brownout rules control its powered state.
- Shunpo is removed. Do not implement dropped-dagger interactions from the original note.
- “Singed W” means a poison **trail** in this project, not adhesive: on costs energy; off costs nothing; no self-poison or extra-potency mode. Existing laid patches expire naturally.
- Most combat progress should reset. Some substantial permanent progress should support grinding lower ascensions. The creator authorized selecting the split below.
- “Snowball,” “bastion heal,” and “drop SFX potency” remain unanswered specifics. They are parked, not silently interpreted.

## What the references contribute

Riot's historical Ezreal page describes a line projectile with cooldown reward for a hit. The useful building block is an aimed hit with a clearly bounded payoff—not imported names, numbers, textures or an entire kit. Our existing Q already supplies a line projectile and impact explosion; a later on-hit cooldown node could be layered onto that. [Riot: Ezreal](https://nexus.leagueoflegends.com/en-us/champion/ezreal/).

Riot's historical Aurelion Sol page explicitly describes orbiting stars and an expanded orbit. This is the **old orbit design**, not the current reworked champion. It supports the near/far orbit reference without confusing versions. [Riot: historical Aurelion Sol](https://nexus.leagueoflegends.com/en-us/champion/aurelionsol/).

Darius's outer-blade damage/healing and pull illustrate how one simple circular or cone shape can reward positioning. Xerath's area strike rewards its center. These support outer-ring and center-hit variants that reuse readable native geometry. [Riot: Darius](https://nexus.leagueoflegends.com/en-us/champion/darius/), [Riot: Xerath](https://www.leagueoflegends.com/en-us/champions/xerath/).

Riot's current Singed page lists Poison Trail separately from Mega Adhesive. The creator's clarification—not the key letter—determines our implementation. [Riot: Singed](https://www.leagueoflegends.com/en-us/champions/singed/).

Some current champion pages expose only part of their interactive ability text to the browser. This is not a frame-by-frame comparison or hands-on League playtest. For the remaining shorthand, the matrix below is a **proposed adaptation**, not a claim of exact current League behavior. Values below are our tuning proposals. We are not copying Riot art or claiming mechanical parity.

## Combat contract

| Input / source | Behavior in 0.12 |
| --- | --- |
| Right-click enemy | Lock that living, active enemy; approach until in basic range; maintain attack order as it moves |
| Right-click ground / hold | Move/steer; cancel commanded basic attacks; autonomous gun continues |
| A, then left-click | Preview basic range; prioritize the enemy closest to the clicked point among those in range; otherwise move toward the point and acquire in-range enemies |
| S | Stop movement and commanded attacks; leave autonomous weapons enabled |
| 1 by default | Auto machine gun → auto sniper → off → machine gun |
| Q | Existing aimed Impact bolt; distinct large finned missile and explosion |
| Escape / another skill / modal | Cancel the armed A preview; never turn a UI click into an attack |

Basic and autonomous weapons have independent cooldowns and damage sources. Projectiles can miss and cannot exceed their configured travel range. Repeated clicks cannot reset shot cooldowns. Target IDs are stable; dead/retired targets are discarded. Attack-move reacquires; a direct order does not select distant enemies through the camera. Camera movement changes neither combat range nor spawn ownership. There is no obstacle navigation or destructible-prop attack model yet.

Initial values: basic 2 damage / 0.43s / 310 range; machine gun 1.5 damage / 0.16s / 265 range / shallow deterministic spread; sniper 7 damage / 0.8s / 470 range. Auto weapon upkeep is 2 energy/sec. Weapon damage/rate ranks affect both weapons; cooldown clocks remain separate. These values need human tuning, particularly the extra combined DPS.

Coolant trail: 26-radius patches, 4s lifetime, 8 base damage/sec, 3 energy/sec while enabled. Overlaps never stack; at most 40 patches. Heavy-bolt damage ranks scale damage. Switching off ends new placement/upkeep but does not erase the trail already laid. Functional coverage remains visible under Reduced effects.

## Permanent versus run progression

**Chosen direction: permanent equipment collection; run-based skill build.** Do not launch two enormous permanent power systems together.

| Layer | Keep between attempts | Reset each attempt |
| --- | --- | --- |
| Account | Class access, highest cleared ascension, collection discovery | Nothing already unlocked is lost |
| Workshop | Owned equipment, each item's stars/bonus, duplicate/material bank | No automatic starting combat ranks |
| Combat | Only the equipped permanent items' bounded effects | Ability discovery, ranks, rarity promotions, tree points/allocations, consumables and temporary effects |
| Economy | Banked crafting materials | Field money used in run shops |

Permanent gear should be a bounded advantage and build identity, not infinite multipliers. Keep the five-star ceiling. Lower ascensions still drop duplicates/materials, while higher ascensions improve access to high-tier bases and affixes. Do not simultaneously make higher difficulties much harder **and** much less rewarding. Ascension selection must disclose modifiers and reward eligibility before a run. Unlock A(n+1) by clearing the full route at A(n); allow replaying any unlocked lower tier.

Future migration: preserve the existing three-slot save as a legacy profile/backup, create a versioned eight-slot schema and show a conversion receipt before retiring old equipment. Never reinterpret Core/Chassis/Drive IDs as arbitrary new armor. No migration or reset has occurred in 0.12.

## Eight-stage route

The sketch contains **22 combat/reward rounds plus three shop visits**, not eight encounters. At an average minute per round plus bosses, shopping and upgrade decisions, budget roughly 25–35 minutes as a hypothesis to test. We should not multiply the five-minute demo's pacing eightfold without measurement.

| Stage | Round sequence | Exit |
| --- | --- | --- |
| 1 | Neutral · Neutral · Boss | Establish the first build |
| 2 | Neutral · Neutral · Boss | Shop before Stage 3 |
| 3 | Neutral · Boss · Loot | Recovery / build correction |
| 4 | Neutral · Boss | New pressure pattern |
| 5 | Neutral · Boss | Shop before Stage 6 |
| 6 | Neutral · Boss · Neutral · Boss | Endurance test with recovery between pairs |
| 7 | High-loot · Neutral · Boss | Final shop before Stage 8 |
| 8 | Boss · Final boss | Bank rewards; unlock next ascension on first clear |

Loot rounds should still have decisions: move between caches, choose a guarded high-value cache or a safe lower-value route. They are not unskippable confetti timers. Shops are safe, pause the run, show actual comparisons and offer a skip/continue button. Prototype stock bought with field money expires after the attempt; permanent crafting stays in the workshop. Clearly label temporary purchases so players never mistake them for collection unlocks.

Build the route runner as data-driven Stage → Round → Encounter, not more conditions against `model.stage`. Current rank caps, music, HUD labels, reward handling and terminal checks assume three levels and must migrate together. First validation target is only Stage 1 with the new discovery loop, then Stage 2 + the first shop, then the full route.

### Ascension proposal

Start with A0–A5, not twenty untested tiers. Apply cumulative, explicit modifiers; each step changes two or three axes. Numbers are initial proposals, not implemented balance.

| Tier | New modifiers |
| --- | --- |
| A0 | Baseline route |
| A1 | Enemy damage +10%; elite frequency +10% |
| A2 | Enemy speed +5%; boss health +10% |
| A3 | Maximum energy −10%; elite damage +10% |
| A4 | Regeneration effectiveness −10%; boss recovery windows −10% |
| A5 | Mixed elite packs; final boss gains one additional attack pattern |

Set floors/caps: preserve dodgeable movement speed, readable tells, viable energy sustain and escape reliability. Reserve gameplay-changing modifiers for tested encounters. Rarity reductions are optional later modifiers, not the first lever; rare drops are part of why players accept the harder run.

## Discovery, ranks and tree

Replace the combat-time unlock schedule with ability chests from dangerous enemies and every fifth Power level. Keep the first guaranteed new slot early enough that Q + gun does not occupy the whole first stage. Proposed pity rule: a locked useful slot is guaranteed on the first two discovery chests; afterward allow weighted duplicates. Show the three actual chest choices and let the player select one.

- New ability: choose a compatible empty slot, or explicitly replace one if full. Never silently overwrite a key's ability.
- Duplicate: grant **two ranks** to that ability, without awarding player XP or triggering another chest. Clamp to the current cap; convert overflow to field currency with a short receipt.
- Ability rarity affects discovery weight and potential, not just a colored border. Keep discovery rarity distinct from later promotions.
- The menu loadout becomes class/starting choices and a codex; it cannot pre-unlock the entire run build.
- One tree point per Power level is active in 0.12. The existing nine-node tree remains; the future larger tree consumes the same separate pool.
- Interpret repeated investment as multi-rank nodes, not a binary unlock forest. Respec should be possible in safe/shop screens, with prerequisite checks. Mid-combat healing/refund loops must be impossible.

Proposed large tree: six branches × roughly eight meaningful nodes = about 48 nodes, several with 3–5 ranks. Branches: Armament, Mobility, Hull, Reactor, Salvage, Command. Mix foundational stats with distinct endpoints; do not make 48 tiny +1% travel taxes. Examples: outer-ring reward, third-hit discharge, return-shot pierce, summon tether bonus, capped cooldown refund. One selected inspector, filter by class/build tags, preserve position/focus, no permanent paragraphs over the arena.

### Stat prerequisites

Before percentage resistance or health regeneration, migrate the five-integer-hull model to a higher-resolution health model (e.g. 100 max health with proportional conversion), or fractional accumulation. A 10% damage modifier must not round down to zero on a one-hull hit. Use one central stat resolver for combat and displayed previews.

Recommended resistance rating: incoming multiplier = `100 / (100 + resistance)` for nonnegative resistance, with a final mitigation cap. Resistances add as ratings; do not multiply independent reductions into accidental invulnerability. Split basic attack rate/range/pierce, autonomous-tool rate/range and ability damage where a node is intentionally specific. A general damage modifier must state whether it includes summons/DoT. Luck affects documented loot rolls, not every unrelated random event.

Pure pickup sound/visual intensity belongs in Settings unless “drop SFX potency” means an actual drop effect. It must never spend a combat point merely to make the screen louder.

## Class identities

| Class | Distinct payoff | Cost / constraint | First additional mechanics |
| --- | --- | --- | --- |
| Ranged | Short move-speed burst on **commanded basic hit** | Lower passive durability; automatic gun cannot maintain permanent speed buff | Skillshot, returning blade, third-hit proc |
| Melee | Higher base movement, resistance and recovery | Must enter threat range; sustain requires interaction | Outer-ring sweep, directional thrust, pull |
| Summoner | More capacity and meaningful summon interactions | Lower personal conventional damage; needs setup and positioning | Cursor-facing sentry, pulse/heal emitter, swap/teleport |

Classes are not implemented yet. Avoid making ranged payoffs proc on every 0.16s autonomous shot. Avoid making every summoner ability another independent unit with its own AI; mounted modules can be attached effects owned by one summon.

## Ability translation backlog

These are reusable mechanics, not a promise to implement every named reference. Use original names and native silhouettes. **Existing** means a related mechanic exists, not exact equivalence.

| Notes | Proposed implementation unit | State / risk |
| --- | --- | --- |
| Tumble | Short directional dodge + next-basic modifier | Existing dash base; modifier pending |
| Snowball | Rolling momentum attack **or** mark/dash | Clarification pending |
| LeBlanc W | Dash impact + timed return anchor | Pending; clear return marker and expiry |
| Pantheon R | Confirmed long landing zone + arrival damage | Pending; high commitment, camera/range testing |
| Invisible pass-through dash | Brief untargetability + no body collision | Ghost already supplies immunity; invisibility/aggro rules pending |
| Fizz E | Short untargetable hop + landing ring | Pending; use existing blink/ring parts |
| Talon E | Obstacle vault with per-obstacle lockout | Blocked by absent obstacle/navigation model |
| Irelia Q | Targeted lunge; conditional kill/mark reset | Pending; one reset per target, no unlimited chains |
| Ez Q | Straight impact skillshot | Q exists; cooldown-on-hit synergy pending |
| Black hole | Pulling area + damage over time | Pending; boss pull resistance, bounded density |
| Xerath W | Delayed area strike, stronger center | Existing nuke base; center-hit variant pending |
| Xerath R | Limited aimed artillery shots during channel | Pending; do not replace laser without choice |
| Sivir Q | Outbound and returning blade | Pending; per-leg hit ledger |
| Runaan's | Extra side projectiles from a basic attack | Item/passive modifier, not another active key |
| Xayah autos | Piercing shots leave recoverable feathers/plates | Pending; return mechanic needs explicit follow-up |
| Three-hit procs | Per-target counter → capped payoff | Pending; despawn/reset policy, source tags |
| Irelia E | Two placed endpoints form a stun segment | Pending; timeout and cancellation rules |
| Syndra E | Directional push; amplify via placed objects | Pending; reuse summon/projectile ownership |
| Yone W | Wide sweep + conditional temporary shield | Pending; per-cast shield cap |
| Darius Q | Ring sweep; reward outer edge | Pending; enemy-count healing cap |
| Yasuo Q | Narrow thrust; third-use empowered variant | Existing line geometry; combo state pending |
| Darius E / area push | Cone pull / radial knockback | Radial push exists; pull pending |
| Rumble Q | Sustained directional flame | Existing W |
| Tahm eat | Consume ordinary enemy; bounded heal/release | Pending; bosses excluded, readability concerns |
| Bastion heal | Self-repair channel or healing structure | Clarification pending |
| Wall summon | Temporary obstacle / line-of-sight tool | Blocked by absent navigation/obstacle model |
| Poison trail | Energy-powered persistent trail | Implemented as Coolant trail |
| Old Asol stars | Medium/far orbit | Existing orbit; visual/range tuning later |
| Rammus momentum | Build speed → capped impact/resistance | Pending; deliberate steering, crash recovery |
| Kalista-like toggle | Command-triggered short hop after basic release | Pending; never auto-jitter the character |
| Auto gun / sniper | Independent automatic weapon modes + off | Implemented |
| Tesla short/fast vs long/slow | Arc coil cadence/range toggle | Existing chain/focus is different; new mode pending |
| Energy ↔ health converter | Toggle transfer modes + off | Existing one-shot sacrifice only; safe floor/cap and no runaway regen |

### Summon mechanics

First implement an owner/capacity registry: one active major summon now, class capacity later; replacement is explicit. Each entity needs a stable ID, owner, lifetime, cost, target policy and damage source. Start with three behavior modules: forward shot, heal aura, pulse damage.

Then add, in order: relocate/teleport-to-summon; swap positions; mirrored skillshots; mirrored melee; hook; nearby stat tether; moving major summon; surrounded detonation; small mounted companions; extra pets. Never allow mirrored casts to trigger mirrors recursively, duplicate health/resource costs, or grant on-cast rewards twice. Clamp proc chains and targets. Summons cannot block all enemy access and trivialize bosses. The current sentry and repair beacon are useful bases, but there is not yet a multi-summon system.

## Five equipment sets / forty base assets

Eight slots × five sets = **40 base items**: helmet, chestplate, leggings, boots, charm, ring, flower and cape. Rarity borders, stars and affixes should not require new painted assets. Start by proving eight slot silhouettes, then derive five material/motif families; do not independently generate forty unrelated images.

| Set | Material / motif | Two-piece identity | Four-piece identity |
| --- | --- | --- | --- |
| Courier | Lean teal fins, brass chevrons | Short move burst on commanded hit | Moving builds a capped next-basic charge |
| Bastion | Broad steel plates, cream brace | Hull and resistance | Capped close-range damage grants a brief barrier |
| Dynamo | Brass coils, ceramic insulators | Energy capacity / recovery | Spending energy primes a bounded discharge |
| Relay | Teal antennae, paired sockets | Summon duration / capacity budget | Nearby major summon mirrors one eligible cast periodically |
| Reclaimer | Brass hooks, mint glass, magnet motif | Pickup reach and loot luck | Collecting a cache primes a capped utility/repair effect |

Flower is a mechanical coolant bloom, cape a segmented service mantle, ring a coil band, charm a hanging tool token. Keep the robot theme; do not turn these into mismatched fantasy jewelry. Common/uncommon pieces carry basic durability and occasional movement stats. Rare/epic signature pieces may have one strong solo effect. The combined build must not gain every signature through tiny unequipped inventory bonuses: only equipped pieces count, each slot once; exactly 2/4 thresholds, no hidden fifth-piece rule.

No forty-item assets or set bonuses are implemented in 0.12. Before generation: lock silhouette sheet, naming IDs, consistent frame/padding, slot icon size and actual equipped-state UI. Preserve the earlier artwork and provenance; the eventual set art can use the image-generation workflow after the eight-slot screen exists.

## Evaluation and ordered work

The notes improve the game's identity, but they describe a much larger roguelite than the original three-round slice. The largest risks are **interactions, progression architecture and encounter variety**, not writing fifty isolated spell functions. Art can remain manageable if mechanics share well-defined shapes and animation primitives.

1. **Done in 0.12:** independent attacks; input arbitration; starting gun; gun modes; poison toggle; per-level tree points; tested visual/range behavior.
2. **Next:** central high-resolution stats + attack/source tags; chest discovery, duplicate +2 rank, overflow and pity; remove timed unlocks; guarantee useful early progression. Playtest one Stage 1 run before adding classes.
3. **Then:** class choice + three representative skills (returning shot, outer-ring sweep, summon relocation). Confirm equal viable pathways, not just equal tooltip DPS.
4. **Then:** expanded run tree with data-driven nodes, safe respec, tag filtering and clear prerequisites. Keep damage/energy/defense budgets visible to tuning tools.
5. **Then:** versioned eight-slot equipment + eight approved slot silhouettes + five set families + workshop migration. Validate rerolls, duplicates and bank-on-clear transactions before real save conversion.
6. **Then:** Stage/Round runner, first shop, A0 route; reuse enemy bodies but author distinct patterns rather than repeat the same boss twenty times.
7. **Finally:** A1–A5 modifiers, reward bands, lower-ascension farming balance, mid-run resume and full-run performance/UX audit.

Explicit open questions are parked above. No permanent data migration, guessed Snowball/Bastion mechanic, new paid asset dependency or untested full campaign is hidden inside this patch.
