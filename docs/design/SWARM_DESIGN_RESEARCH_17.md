# Swarm Design Research for MobaBot.io

Status: **source-backed design research and adaptation hypotheses; not implemented behavior.** This study examines Riot Games' 2024 mode *Swarm | Operation: Anima Squad* for transferable principles. It does not recommend copying its characters, maps, assets, recipes, encounter counts or pacing.

Routing: this is supporting research only. [`NEXT_SESSION_BRIEF_17.md`](NEXT_SESSION_BRIEF_17.md) decides when a specific Swarm-derived hypothesis enters a prototype.

The current MobaBot implementation remains defined by [`QA_17.md`](QA_17.md). Current owner direction is consolidated in [`OWNER_PLAYTEST_REQUEST_17.md`](OWNER_PLAYTEST_REQUEST_17.md), with detailed ability and terrain notes in [`ABILITY_FEEDBACK_17.md`](ABILITY_FEEDBACK_17.md) and [`ENVIRONMENT_FEEDBACK_17.md`](ENVIRONMENT_FEEDBACK_17.md).

## Executive conclusions

Swarm's most useful lesson is not “put more enemies and weapons on screen.” Its design joins several loops that reinforce one another:

- A low-attention baseline weapon keeps combat moving while the player navigates.
- A small number of manually activated character abilities create clutch agency.
- Map pickups and optional objectives give movement a purpose beyond fleeing.
- Weapon/passive combinations create anticipated transformation moments.
- Elite drops delay or unlock those transformations, turning combat rewards into build decisions.
- Four maps use different landmarks and hazards to change route planning without changing the basic movement language.
- Persistent objectives and upgrades make failed runs produce visible progress.
- Enemy waves are data-authored so composition, direction, density and timing can vary without requiring a new engine for every encounter.

Riot's own retrospective attributes Swarm's reception to novelty and progression, and warns that sustained PvE engagement requires a continuing content pipeline.[^1] MobaBot should borrow the **loop connections** while rejecting the scale assumptions. Its differentiator should be a single configurable robot with a permanent gun, deliberate hammer and active tools, stage-tailored loadouts, physical terrain and non-modal growth—not League champions inside another bullet-heaven ruleset.

The highest-value near-term inspirations are:

1. Make the permanent machine gun a dependable floor while the hammer and Q/W/E/R provide intentional upside.
2. Give terrain a usable landmark or temporary opportunity, not just collision.
3. Design rank 5 and rank 10 as visible evolutions with functional changes.
4. Author synergies around verbs and geometry—group, line, orbit, collide, return—rather than exact mandatory item pairs.
5. Use short optional route objectives to interrupt circling without opening a modal screen.
6. Treat wave shape, direction, role mixture and terrain relationship as content, not only enemy health and count.

## Swarm's documented structure

Riot describes Swarm as a one-to-four-player bullet-heaven PvE mode with WASD movement, four maps, three difficulties, an aim/auto-aim toggle, bosses, persistent progression, nine champions, 20 weapons and numerous power-ups.[^2] Players explore for pickups, combine character strengths in co-op, complete achievements that unlock champions/weapons/augments, and gain account-level power even after failure.

Secondary documentation fills in mechanics Riot's overview does not enumerate. Swarm maps contain destructible pods with immediate rewards, elite-dropped Access Cards, optional Yuumi quests, and one major map feature such as a healing fountain, ion cannon or freeze device.[^3] Weapon evolution requires a weapon at maximum rank, its matching passive, and an eligible Access Card.[^4] These details are useful for structural analysis, but community guides are not authoritative design rationales.

Swarm's released format and MobaBot's proposed direction differ materially:

| Dimension | Swarm | MobaBot direction |
| --- | --- | --- |
| Player identity | One of several fixed champions | One persistent configurable robot; no classes |
| Baseline offense | Champion weapon, manual or automatic aim | Permanent autonomous machine gun plus manual hammer |
| Manual abilities | Champion-specific E/R | Fixed Q/W/E/R role language plus D/F movement |
| Build acquisition | Random weapons/passives and evolutions | Learned inventory, fixed-family loadouts and non-modal rank/unlock events |
| Run geography | One map for a roughly 15-minute survival and boss | Eight-stage, 22-round expedition with camps/checkpoints |
| Map purpose | Pickups, optional events, landmark mechanisms and boss | Terrain currently mostly cover/routing; owner wants substantial pockets/corridors |
| Social structure | Solo or up to four-player co-op | Single-player; multiplayer is out of scope |
| Long-term progression | Objectives, unlocks and purchased permanent upgrades | Persistent equipment/ascension; abilities and mastery reset for a new run under current rules |

This difference is productive. Inspiration should improve MobaBot's own loop rather than erase it.

## Strategy 1: continuous floor, deliberate ceiling

Swarm allows the champion's basic weapon to be aimed or set to automatic.[^2] That serves accessibility and attention management: a player can move and survive while offense continues, then opt into more precise control. Character abilities provide larger, timed interventions.

MobaBot's new owner direction can create a sharper version of the same principle:

- The autonomous machine gun is permanent, always equipped and independently upgradeable.
- The hammer is a slower manual basic with a positional head/handle payoff.
- Q is reliable repeatable damage.
- W is reach or committed payoff.
- E is a tactical body slam.
- R is the largest event.
- Holding D disables manual attacks and actives while the permanent gun and passives continue.

This creates three attention levels: passive continuity, repeatable intentional pressure and high-commitment actions. The fun hypothesis is that low-execution play remains viable while precise positioning and timing produce clearly better outcomes.

The danger is passive dominance. If the machine gun clears ordinary encounters alone, the hammer and abilities become cosmetic. If the passive is too weak, D feels like a button that prevents the player from participating. Practice testing should compare passive-only, ordinary deliberate play and expert combos without treating equal damage as the goal.

## Strategy 2: movement with destinations

Swarm's official overview explicitly tells players to explore for pickups.[^2] Its maps also place large limited-use mechanisms: a central healing fountain, a cannon that accepts a carried fuel cell, and freeze zones that ask the player to occupy a location.[^3] These turn movement into more than endless retreat.

The transferable pattern is **destination → exposure → payoff**:

1. The map advertises an opportunity.
2. Reaching or activating it asks the player to cross dangerous space, hold a zone or return later.
3. The payoff changes the immediate fight.
4. A cooldown prevents the landmark from becoming a permanent safe answer.

MobaBot already has promising pieces for this pattern:

- Ghost drive makes a deliberate collection or escape run.
- The healing totem stores value while the player is away and pays it out on return.
- A targetable summon can create temporary local safety.
- Thick terrain pockets and corridors can make route choice legible.
- Stage-specific loadouts let a player respond to a difficult map.

The first terrain prototype should therefore test one functional landmark per layout, not simply thicker walls. Examples that fit the salvage-machine theme include a coolant vent that briefly slows a lane, a charge terminal that accelerates a deployed module, or a crusher that can be armed against a wave. These are original hypotheses, not requests to reproduce Swarm's fountain or cannon.

Map features must remain optional tactical advantages. A player should not lose because a required objective spawned behind an unreadable corridor, and the strongest route should not reduce the map to camping one corner. Community guidance for Swarm often recommends avoiding tight spaces without sufficient AoE, illustrating how geometry can create real build-dependent routing but can also produce dead areas.[^5]

## Strategy 3: transformation milestones

Swarm's weapon evolutions create a recognizable anticipation loop: build the weapon, obtain a matching passive, then use an elite reward to transform it.[^4] The transformation is memorable because it changes function and presentation, not just a hidden percentage.

MobaBot should borrow the **visible transformation** but avoid the exact recipe. Requiring one named passive for one named weapon creates dead discoveries and conflicts with the owner's goal of keeping learned skills useful. Better options are:

- Rank 5 improves breadth or reliability.
- Rank 10 changes behavior or adds an encounter answer.
- A broad taxonomy condition can unlock a synergy: for example, any grouping skill improves a radial summon, or any movement module changes an orbit pattern.
- A single packaged skill can contain both enabler and payoff, as proposed for Plate magazine/recall.

This makes builds discoverable without requiring a wiki. Every synergy should have surface value before completion, an in-UI preview of the possible milestone, and a visible confirmation when it activates.

Good candidates from current owner direction include:

| Base tool | Milestone or synergy direction | Why it could feel good |
| --- | --- | --- |
| Hammer | Tumble or body-slam setup enables a stronger head hit | Physical preparation leads to a visible precision payoff |
| Body slam E | Rank 5 adds stun; rank 10 adds a full immunity shield | Each milestone changes commitment and tactical use |
| Reactor drop R | Rank 5 supports the player in the zone; rank 10 creates a second impact | The ultimate grows from damage into a fight-defining area |
| Orbiting tools | Close/fast versus far/slow mode; later contact behavior changes | The upgrade changes how the player positions rather than only DPS |
| Healing totem | Stored heal overflows into energy, then a bounded shock wave | Returning at the right time avoids wasting recovery |
| Paired robots | Geometry/rank alters the line or rewards crossing placement | Two placements produce a constructed combat space |

Overflow conversion is satisfying because value is not visibly wasted, but it can erase tradeoffs. Healing should remain primarily healing; energy and damage overflow need strict caps so full health does not turn the best sustain tool into the best offense.

## Strategy 4: optional micro-objectives during survival

Swarm uses optional events and map pickups to create short local goals during a longer survival timer.[^3] They alter movement and attention without ending the run. This addresses a common survivor-game weakness: once a build stabilizes, optimal play can become repetitive circling.

MobaBot's proposed non-modal leveling already protects combat flow. It could later add lightweight objectives that use existing verbs:

- Hold a salvage pad briefly while enemies converge.
- Carry a volatile part to a visible machine, disabling one active while carrying it.
- Break several marked scrap pods before a short timer ends.
- Route a zap line through designated targets using the paired robots.
- Collect a trail of parts using Ghost drive without taking touch damage.

The reward should be immediate and modest: a temporary module overcharge, a burst of collection, one stored rank choice, or a stage resource. Do not add these until the default kit and ordinary wave pacing are fun. Optional events are rhythm changes, not a substitute for good combat.

## Strategy 5: wave composition as authored content

Riot built Swarm's waves as data controlling spawn time, despawn time, unit mix, quantity, frequency, location and shape, with scaling by player count and difficulty.[^6] That matters because “more enemies” is not one experience. A ring closing around the player, a stream through a corridor and a durable blocker shielding ranged threats ask different questions.

MobaBot should expand encounter identity through a compact wave grammar:

- **Direction:** ring, wedge, lane stream, staggered flank, pocket emergence.
- **Pressure role:** body swarm, ranged denial, charger, durable anchor, support/producer.
- **Terrain relationship:** funnels through entrances, guards a landmark, flushes the player from a pocket, blocks a return route.
- **Build check:** wave-clear density, anti-boss durability, peel demand, reposition demand.
- **Tempo:** sustained flow, warning then burst, short relief, elite interruption.

This grammar can make eight stages feel different before new art or enemy families are added. It also makes the ability taxonomy testable: a wave tagged “grouping payoff” can reveal whether Gravity well plus Reactor drop actually produces a distinct advantage.

Avoid scripted hard counters. Each encounter should reward a tool without making other coherent loadouts impossible. The owner wants stage-tailored loadouts as a way past difficulty, not a hidden key that must be equipped.

## Strategy 6: failure that produces direction

Riot's overview tells players that failure still grants persistent progress, while achievements unlock content and difficulties.[^2] Riot later reported that Swarm-specific progression gave invested players objectives and contributed to longer engagement.[^1] The important component is not permanent stat inflation alone; it is that a failed run suggests a next action.

MobaBot already separates run mastery from persistent equipment and ascension. It should keep those boundaries. Useful inspiration would be:

- After a failure, name the stage and pressure pattern that ended the run.
- Surface newly available loadout alternatives at camp/home without an intrusive modal.
- Let Practice reproduce the relevant stage conditions without granting permanent loot.
- Use achievements or research objectives to unlock sidegrade abilities, not mandatory raw power.
- Make the next achievable goal concrete: learn a control tool, test a boss-oriented W, or forge one equipment tier.

The risk is grind masking balance. A0 with starter equipment must remain viable, and failure should not imply that the player merely needs more permanent stats.

## Strategy 7: novelty through combinations, not catalog size

Swarm launched with nine champions, 20 weapons, power-ups and co-op combinations.[^2] Riot nevertheless concluded that longer-lived PvE would require scheduled content updates.[^1] This is a warning for a small project: a 49-entry catalog does not create durable novelty when many entries overlap.

MobaBot's better route is a smaller number of tools with cross-system consequences:

- Terrain changes the value of orbit radius, line summons and body slam.
- Enemy weight changes knockback and grouping.
- Damage-source types change defensive decisions.
- The same summon can be offense, cover or aggro diversion depending on placement.
- Rank milestones change function.
- A learned inventory supports different stage loadouts.

These relationships create combinatorial variation without requiring dozens of new effects. The focused roster should be refined before stashed abilities return.

## Strategy 8: spectacle under readability and performance limits

Riot's first Swarm balance patch replaced an invisible boss-enrage rule with clearer behavior and concentrated on performance, quality of life and weak builds.[^7] Riot's later engineering account describes clumping as both a clarity and performance problem, data-driven waves for iteration, and particles as a major client bottleneck. Swarm shipped with a controlled limit around 550 active minions, sometimes spiking near 1,000.[^6]

Those counts are not MobaBot targets. The transferable principles are:

- Make lethal escalation visible rather than silently multiplying damage.
- Bound every summon, projectile, plate, orbit tool, trail and status effect.
- Measure combinations, not only isolated abilities.
- Let reduced-effects mode remove decoration while preserving ranges, danger and state.
- Prefer a few strong contact reactions over constant particles.
- Use data-authored wave changes so design iteration does not require new bespoke scripts.

The proposed D afterimage, F smoke poof, atmospheric body-slam envelope and three default deployables should be tested together. Each may be clear alone but become noise when simultaneous.

## Synergy concepts worth prototyping

These are original MobaBot hypotheses derived from the research and owner direction.

| Synergy | Player action | Payoff | Guardrail |
| --- | --- | --- | --- |
| Body slam → hammer | Push a group, reposition, then land the hammer head | Deliberate close-range combo | E damage stays moderate; hammer sweet spot remains the payoff |
| Body slam → Reactor drop | Hold enemies briefly inside the delayed R | Earned AoE setup | Rank-5 stun must be very short; bosses use reduced rules |
| Aggro summon → far orbit | Divert a local pack and cut through it with the wide orbit | Placement plus mode choice | Summon aggro radius stays local and its health is readable |
| Healing totem → Ghost drive | Leave the charging totem, collect/escape, then return | Movement loop ends in recovery | Stored charge cap and return radius prevent passive full healing |
| Paired robots → corridor | Place a line across an entrance and kite through it | Terrain becomes part of the build | Enemies must not become permanently trapped or stun-locked |
| Gravity/grouping → pulse summon or R | Gather enemies before a periodic or delayed impact | Clear setup/payoff language | Grouping tool itself stays low damage |
| F → cast origin | Start an eligible windup, blink, release from new location | High-skill repositioned cast | Under-0.1-second window, single cost and per-family aim rules |
| Scrap orbit → collection route | Choose paths that build visible orbit resources | Pickups affect immediate offense | Avoid requiring delayed pickup hoarding or hidden recipes |

The default kit should not activate all synergies automatically. A good synergy is something the player can notice, plan and improve at.

## What not to import

| Swarm element | Why it should not be copied directly |
| --- | --- |
| Champion roster/classes | The owner explicitly wants one robot and learned loadouts rather than classes |
| Five weapons plus five passive-stat slots | It would compete with fixed Q/W/E/R/D/F/1–4 and learned inventory |
| Exact weapon/passive evolution recipes | Hard dependencies can create dead choices and outside-the-game lookup pressure |
| Frequent modal level-up selections | The owner wants non-interrupting indicators and shortcuts |
| Fifteen-minute single-map cadence | MobaBot uses short rounds, stage transitions, camps and checkpoints; its current full route is already long |
| Co-op-specific ability balance | Multiplayer is out of scope; translate cooperation into intra-build synergy only |
| Hundreds of enemies as a quality goal | MobaBot needs readable deliberate hits, not scale for its own sake |
| Exact map devices or layouts | Use the destination/exposure/payoff pattern with original salvage-world mechanisms |
| Permanent power as the only failure answer | Starter A0 must remain viable and skill/loadout learning must matter |

## Recommended order of experimentation

1. Prove the permanent machine gun, manual hammer, Impact bolt and body-slam E as one readable baseline combat loop.
2. Add D/F restrictions and effects, then verify that passives continue during D and buffered casts remain predictable around F.
3. Prototype the four default modules in isolation, then together under strict entity/effect caps.
4. Replace modal learn/upgrade flow with pending non-modal choices before raising XP.
5. Test three substantial terrain greyboxes, each with at most one original functional landmark.
6. Author several wave shapes against the same enemy roster to test whether geometry alone changes decisions.
7. Add rank 5/10 transformations and a small number of cross-tool synergies.
8. Only then decide which stashed skills deserve reintroduction.

This order isolates causes. Introducing terrain, modules, progression, damage typing and rank transformations simultaneously would make a positive or negative playtest impossible to diagnose.

## Research limits

Riot's sources describe features, engineering and high-level outcomes, not a full Swarm design postmortem. Riot reports relative engagement conclusions without publishing raw player counts in the cited retrospective. Community guides document mechanics and common strategies but represent particular authors and versions. Swarm was a limited-time 2024 mode; later League systems should not be treated as evidence about that release unless explicitly identified as a broader design comparison.

Most importantly, Swarm's success does not establish that a similar mechanic will work in MobaBot. The hypotheses above require focused human playtests in MobaBot's movement, camera, enemy-density and run-length context.

## Footnotes

[^1]: Riot Games, “[/dev: Looking Forward for Arena and Swarm](https://www.leagueoflegends.com/en-ph/news/dev/dev-looking-forward-for-arena-and-swarm/),” 2024. Riot identifies novelty, mode-specific progression and PvE content cadence as its three main Swarm takeaways.
[^2]: Riot Games, “[Anima Squad 2024: Everything You Need To Know](https://www.leagueoflegends.com/en-gb/news/game-updates/anima-squad-2024-everything-you-need-to-know/),” 17 July 2024. Official overview of mode format, controls, maps/difficulties, progression, roster, weapons and power-ups.
[^3]: League of Legends Wiki contributors, “[Swarm](https://leagueoflegends.fandom.com/wiki/Swarm_%28League_of_Legends%29),” accessed 9 September 2026; and MobaFire, “[How To Play Swarm](https://www.mobafire.com/league-of-legends/news/swarm-guide),” accessed 9 September 2026. Secondary descriptions of pods, optional quests, elite rewards and map mechanisms.
[^4]: Riot Games, “[EMEA Creator Challenge: Swarm](https://www.leagueoflegends.com/en-gb/news/community/emea-creator-challenge-swarm/),” 16 July 2024. Riot states that weapons evolve at maximum level when paired with the correct passive; Access Card behavior is documented by the secondary sources in footnote 3.
[^5]: Mobalytics, “[LoL: Swarm Map Guide](https://mobalytics.gg/lol/guides/swarm-map-guide),” accessed 9 September 2026. This is strategy guidance, not an official design explanation; it is used only as evidence that players perceived open/tight regions and map mechanisms as route decisions.
[^6]: Riot Games, “[The Tech Behind Swarm](https://www.riotgames.com/en/news/the-tech-behind-swarm),” 2025. Official engineering account covering flow-field pathfinding, data-driven wave parameters, effect batching, progression infrastructure, performance measurement and entity limits.
[^7]: Riot Games, “[Patch 14.15 Notes](https://www.leagueoflegends.com/en-au/news/game-updates/patch-14-15-notes/),” 30 July 2024. The first Swarm update emphasized performance/QoL, improved boss-enrage clarity and buffed underperforming builds while limiting nerfs.

## Sources

1. [Anima Squad 2024: Everything You Need To Know — Riot Games](https://www.leagueoflegends.com/en-gb/news/game-updates/anima-squad-2024-everything-you-need-to-know/)
2. [/dev: Looking Forward for Arena and Swarm — Riot Games](https://www.leagueoflegends.com/en-ph/news/dev/dev-looking-forward-for-arena-and-swarm/)
3. [The Tech Behind Swarm — Riot Games](https://www.riotgames.com/en/news/the-tech-behind-swarm)
4. [Patch 14.15 Notes — Riot Games](https://www.leagueoflegends.com/en-au/news/game-updates/patch-14-15-notes/)
5. [EMEA Creator Challenge: Swarm — Riot Games](https://www.leagueoflegends.com/en-gb/news/community/emea-creator-challenge-swarm/)
6. [Swarm — League of Legends Wiki/Fandom](https://leagueoflegends.fandom.com/wiki/Swarm_%28League_of_Legends%29)
7. [How To Play Swarm — MobaFire](https://www.mobafire.com/league-of-legends/news/swarm-guide)
8. [LoL: Swarm Map Guide — Mobalytics](https://mobalytics.gg/lol/guides/swarm-map-guide)
