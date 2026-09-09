# MobaBot.io Ability Taxonomy and Roster Research

Status: **design research and recommendations for future prototyping; not implemented behavior.** This document evaluates the 49-ability catalog as it exists on 9 September 2026. It treats the owner's comments on abilities 1–11 as constraints and concentrates on the still-unreviewed abilities 12–49. “Promising” means the design has a clear reason to prototype; it does not mean the ability has passed a human feel test.

The current implementation remains defined by [`QA_17.md`](QA_17.md), the [root README](../../README.md) and the [ability catalog](../review/abilities.html). The owner's exact notes remain preserved in [`ABILITY_FEEDBACK_17.md`](ABILITY_FEEDBACK_17.md).

**Subsequent owner direction:** the later proposal in `ABILITY_FEEDBACK_17.md` supersedes this document's initial default 1–4 recommendation. The current owner-proposed defaults are orbiting tools on 1, an aggressive aggro-drawing summon on 2, a stored-healing totem on 3 and paired zap robots on 4. Keep the analysis below as research history and as input to later alternatives; do not mistake its Pulse-anchor/four-toggle recommendation for the latest owner decision.

## Executive findings

There is no useful single-axis answer to “what type is this ability?” Q/W/E/R describes **input responsibility**, while single-target/AoE describes **target shape**, burst/DPS/DoT describes **delivery**, and wave clear/anti-boss describes **encounter purpose**. Those labels should be stored as separate axes rather than forced into one list.

The recommended player-facing slot contract is:

| Input | Promise to the player | Allowed families |
| --- | --- | --- |
| Left click | Deliberate repeatable basic attack | The proposed positional hammer swing |
| Q | Reliable main damage | Sustained or repeatable damage with low cost and short downtime |
| W | Reach, setup or committed damage | Long-range poke, delayed strike, burst or a more demanding damage pattern |
| E | Tactical answer | Control, defense, sustain, setup, unusual utility or a committed body check |
| R | Fight-changing commitment | The highest-impact, longest-cooldown burst, channel, zone or transformation |
| D / F | Movement only | Escape, engage or reposition tools with distinct safety/commitment profiles |
| 1–4 | Build modules | One summon and selected powered toggles initially; advanced actives may be considered later |

The proposed hammer should remain outside Q. Otherwise the player's fundamental manual attack and the replaceable Q build choice become the same system, weakening both the fixed control language and the learned-loadout idea.

For the initial focused test roster, the best research-based choices among the unreviewed abilities are:

- **D: Ghost drive** and **F: Phase hop**, as already requested. They are legible opposites: sustained safety versus precise relocation.
- **Default summon: Pulse anchor.** Its periodic area damage is immediately understandable, while the optional position swap creates expert depth without preventing a beginner from getting value.
- **Four powered toggles: Coolant trail, Arc coil, Auto gun and Life converter.** Together they cover movement-shaped DoT, switchable wave-clear/anti-boss offense, independent sustained offense and a non-damage resource tradeoff. They ask four different questions instead of repeating passive damage.
- **Later R alternatives: Core cutter and Siege battery.** Both have strong identity and real commitment, but should not displace Reactor drop from its proposed default position.

The clearest consolidation opportunities are also outside abilities 1–11:

- Fold Collection pulse and Ricochet into Scrap orbit's rank or mastery progression.
- Package Plate magazine and Plate recall as one complete mechanic instead of charging two choices for one functional ability.
- Treat Reactive plating and similar always-on reactions as passive equipment/mastery effects rather than “powered toggles.”
- Fold Wall runner into a barrier or mobility upgrade unless maps consistently make barrier-vaulting useful.
- Keep the rest stashed, not deleted, until focused Practice testing provides evidence.

## What the cross-medium research supports

The strongest shared lesson across action games, MOBAs, shooters, MMOs and tabletop systems is that a tool earns its slot by creating a recognizable decision.

Combat-system analysis describes a useful ability as a combination of a unique advantage—damage, stun, displacement, regeneration and so on—and a cost such as resource use, cooldown, activation time, recovery time or positional risk. The choice becomes interesting when the player can select the right tool for the enemy, distance and timing rather than simply pressing the numerically strongest button.[^1] Riot's Hwei design uses different spell families for damage, utility and control, but still requires every spell within a family to have its own niche and reason to cast.[^2]

Other genres separate the same concepts at different scales. World of Warcraft's official Druid overview labels broad combat roles—tank, healer and damage—while the toolkit description separately includes melee, ranged, healing and crowd-control functions.[^12] Destiny likewise describes a Super as the character's most powerful ability while allowing that high-impact slot to damage, debuff or protect.[^13] The useful common structure is therefore a stable role or slot promise plus more specific functional tags, not one universal list of mutually exclusive ability types.

This evidence supports the owner's instinct to classify function, but it also warns against making “Q ability” the whole taxonomy. A Q is a control promise. Its actual balance still depends on reach, target topology, damage delivery, encounter purpose and commitment.

Three additional principles recur:

1. **Power needs a visible price.** Destiny explicitly ties cooldown tiers to output and warns that ability uptime can turn an intended power spike into the normal state of combat.[^3] Energy, cooldown, aim demand, position, channel time and vulnerability can all pay that price. They should not be piled on arbitrarily; one or two legible costs are better than several hidden ones.
2. **Damage, control, safety and mobility share a power budget.** Riot's Gwen analysis explains that high damage plus extensive crowd control would overload one character's budget.[^4] Mobility guidance similarly argues that broadly available mobility needs an opportunity cost.[^5] A move that damages, stuns, travels, grants immunity and resets needs much stricter limits than a pure reposition.
3. **Immediate readability and long-term depth can coexist.** Mark Rosewater's “lenticular design” describes pieces that give a beginner an obvious useful result while revealing more strategic applications to an expert.[^6] Pulse anchor is a good example: “put down a damaging zone” works immediately; deliberately swapping through it can be learned later. By contrast, a passive that only works after another named passive has little surface value.

Feel is not just balance. Good action presentation follows a cue–action–feedback rhythm: anticipation communicates the commitment, the action shows where power is occurring, and the reaction confirms contact and consequence.[^7] Riot's clarity work adds that visual and audio intensity should correspond to gameplay importance and that effects must truthfully communicate hit geometry, danger and control.[^8] Accessibility guidance recommends communicating important events through more than one sensory channel; for attacks, distinct miss, contact and defeat sounds are a concrete example.[^9]

Those principles make several MobaBot-specific requirements explicit:

- The hammer head and handle need different geometry, impact effects and sounds, not just different hidden numbers.
- Execute thresholds, stored charges, recast windows, summon readiness, toggle drain and invulnerability must be visible without opening a detail panel.
- A rank milestone may look more impressive only if its collision, duration or effect actually changes to match.
- Automatic effects need predictable rules. Surprise power can be spectacular once, but frequent uncommanded outcomes erode planning.

Finally, boss value should not mean only “large single-target number.” Boss design guidance emphasizes testing learned skills, providing clear feedback and allowing multiple approaches.[^10] Anti-boss tags can therefore include reliable uptime, center-hit rewards, a safe channel window, armor breaking, movement denial with explicit boss rules, or a tool that answers a learned boss pattern. “Boss bonus damage” is only one implementation.

## Recommended taxonomy

Each ability should have one exclusive **slot family** and several independent tags. The internal catalog should store all relevant tags; the player-facing card should show only the two or three that help make a loadout decision.

### Axis 1: slot family

This answers, “What control promise does equipping this make?”

| Family | Internal rule |
| --- | --- |
| Basic | Always-available manual combat verb; not learned or replaced like a skill |
| Q — pressure | Reliable main damage; low cost, short downtime, limited control/safety |
| W — reach/payoff | Longer reach, delayed setup, burst or higher-commitment damage |
| E — tactics | Control, defense, sustain, setup, body-check or rule-bending utility |
| R — ultimate | Highest encounter impact and strongest audiovisual hierarchy; long cooldown or major commitment |
| D/F — movement | Movement is the primary purpose; damage/control is secondary and budgeted carefully |
| Module — summon | A placed or moving entity with a visible lifetime, capacity and behavior |
| Module — powered toggle | A player-controlled on/off or mode choice with continuous cost or meaningful state |
| Passive package | Always-on modifier, proc or dependency; belongs in mastery/equipment or inside another skill's progression |

This preserves the owner's Q/W/E/R proposal while preventing passive upgrades from competing under a misleading “toggle” label.

### Axis 2: target topology

This answers, “Where and to how many targets can it apply?” Tags may combine.

| Tag | Meaning |
| --- | --- |
| Self | Changes the player or originates entirely from the player |
| Single | Chooses or meaningfully rewards one target |
| Multi | Selects a bounded number of separate targets |
| Line | Travels or applies along a narrow direction |
| Cone / arc | Wide near the source or sweeps through an angle |
| Ground zone | Uses a chosen world position and area |
| Radial | Applies around a source, target or impact point |
| Deployable | Persists from a placed or summoned source |

“AoE” should remain a plain-language umbrella for line, cone, ground-zone and radial effects, not replace those more actionable geometry tags.

### Axis 3: delivery pattern

This answers, “How does its value arrive over time?”

| Tag | Meaning | Typical satisfaction requirement |
| --- | --- | --- |
| Burst | Most value lands in one short event | Anticipation, decisive impact and a clear miss cost |
| Sustained | Repeated use or continuous contact maintains output | Rhythm, reliable feedback and manageable upkeep |
| DoT | One application continues dealing damage | Visible ownership, duration and refresh/stack rules |
| Channel | Player maintains a vulnerable action | Escalating feedback, cancel rules and payoff worth the lock |
| Delayed | Effect occurs after a telegraphed wait | Predictive placement and a readable landing moment |
| Proc | Fires after a count, damage event or other condition | Visible progress and player influence over the trigger |
| Execute | Gains special value below a health threshold | Obvious eligibility, satisfying finish and safe failure behavior |
| Mode / upkeep | Persists while selected and paid for | State visibility, fast comprehension and meaningful switching |

A coolant puddle can be AoE, ground-zone, DoT, wave-clear and kite-oriented at once. None of those tags contradicts another.

### Axis 4: encounter purpose

This answers, “Why does a player choose it for this stage?”

| Tag | Loadout purpose |
| --- | --- |
| Wave clear | Controls or kills many low-durability enemies efficiently |
| Anti-boss | Converts boss openings, persistent proximity or precise hits into reliable value |
| Peel | Creates safety by pushing, stunning, slowing or blocking threats |
| Grouping / setup | Moves or holds enemies so another tool can land efficiently |
| Zone control | Changes where enemies or projectiles can safely travel |
| Sustain / defense | Preserves hull, creates protection or trades resources for survival |
| Reposition | Changes player location, angle or escape state |
| Build engine | Creates resources, marks, plates, orbiting tools or another later payoff |

Wave clear and anti-boss are contextual strengths, not mutually exclusive classes. Arc coil can switch between them. Core cutter may sweep a line of small enemies but still earn an anti-boss tag through long single-target contact.

### Axis 5: commitment and counterplay

This answers, “What does the player risk and what can go wrong?”

- **Instant:** value happens on input; cost is mostly cooldown/resource/aim.
- **Cast lock:** brief movement or action commitment, as proposed for the hammer.
- **Channel/root:** large ongoing commitment that may be interrupted or cancelled.
- **Recast:** reserves part of the move's value for a time-limited second decision.
- **Toggle/upkeep:** creates a continuing resource and attention decision.
- **Proximity/collision:** asks the player to enter threat range.
- **Self-cost:** spends hull or another normally protected resource.

Commitment is important to fun because it creates anticipation and ownership. It must also be dependable: if the player accepts the risk and executes correctly, collision ambiguity or hidden immunity should not arbitrarily erase the payoff.

### Axis 6: dependency

This answers, “Does the choice work by itself?”

- **Standalone:** fulfills its promise without another named ability.
- **Enabler:** creates a resource, mark, position or setup used by other tools.
- **Payoff:** cashes in a generally available state.
- **Package:** an enabler and its payoff are intentionally acquired as one coherent choice.
- **Hard dependency:** requires another specific learned ability; avoid as a separate loadout tax unless the dependency is automatically granted.

The default preference should be modular synergy: abilities become better together but remain understandable and useful alone. Hard pairs such as Plate magazine plus Plate recall are better sold as one package.

## Slot rules and edge cases

The slot system should classify an ability by its **primary reason to press it**, not by every effect it contains.

- Piston thrust belongs in E because its defining promise is a body-check and stun, even though it deals damage and moves the player.
- Scrap pursuit should not become a default Q merely because it has an 8-second cooldown. Its lunge and kill reset make target selection and chaining its actual identity.
- Core cutter belongs in R because the five-second rooted channel and escape-cancel interaction create ultimate-level commitment, even though its delivery is sustained rather than burst.
- Reactive plating is not a powered toggle because the player does not choose an on/off state or pay upkeep. It is a passive proc.
- Auto gun remains a powered toggle even after the hammer replaces the current basic attack, because its autonomous clock, mode switching and energy economy are its identity.

The owner proposed no ability rebinding. That can improve learnability if every key remains truthful across loadouts, but fixed keys also increase the cost of a misclassified ability. The game should reject invalid slot assignments in data and UI, show learned alternatives grouped by Q/W/E/R/D/F/module family, and move a newly learned same-family skill into inventory rather than replacing the equipped one.

The current rule allowing any general skill on Q/W/E/R/1–4 remains implemented behavior until a migration design covers existing bindings and saves. Fixed slot rules should be prototyped in Practice before becoming a save-format or progression change.

## A practical “fun potential” test

Research can identify design conditions; only play can establish fun. Each prototype should be reviewed against the following questions rather than assigned a false precision score.

1. **Promise:** Can a player explain the ability's purpose after one or two uses?
2. **Decision:** Does it ask a different question from nearby options?
3. **Agency:** Can aim, timing, pathing, mode choice or target choice materially improve the result?
4. **Price:** Is its cooldown, energy, vulnerability or setup proportional and understandable?
5. **Payoff:** Do animation, sound, hit reaction and game state confirm success?
6. **Counterfactual:** Is there a real situation where saving the ability or equipping another one is better?
7. **Growth:** Do rank 5 and rank 10 change play or open strategy, rather than only inflating numbers?
8. **Reliability:** Does correct execution produce predictable geometry and effect?
9. **Independence:** Is the ability useful alone, or is a required package granted together?
10. **Accessibility:** Are critical state and contact cues available through shape/motion and sound rather than color alone?

The expected output is a qualitative label:

- **High prototype potential:** clear distinct decision and credible feel payoff; prioritize a human test.
- **Medium prototype potential:** useful function, but overlap, dependency or feedback needs redesign.
- **Low current potential:** weak standalone purpose or excessive overlap; stash or merge rather than delete.

These are design-confidence labels, not owner approval and not measured enjoyment.

## Ability audit: actives and ultimates 12–21

| # | Ability | Functional tags | Proposed home | Assessment and recommendation |
| --- | --- | --- | --- | --- |
| 12 | Tractor cone | Cone, burst, grouping, proximity | E alternative | **Medium. Stash pending differentiation.** A directional pull is useful, but Gravity well already owns persistent grouping and Repulsor owns the opposite cone. Remove most damage and make this the immediate “pull a chosen pack into hammer range” tool if it returns. It needs a strong cable/traction cue and a clear boss-resistance response. Do not keep it merely as Repulsor with a negative force value. |
| 13 | Scrap crusher | Single, execute, sustain, proximity | E or advanced 1–4 active | **High. Reserve for refinement.** The threshold, heal and boss exclusion produce a clean risk/reward loop against ordinary enemies. Show eligible enemies clearly; a failed target check should not consume the cast. The finish needs a short anticipation and decisive crush/heal response. It is wave-survival sustain, not an anti-boss tool. |
| 14 | Self repair | Self, channel, sustain, interruptible | E or advanced 1–4 active | **High. Reserve for refinement.** The three-second stationary, interruptible channel is an honest price for healing and creates a good “have I made enough space?” decision. Add visible channel progress, bracing animation and separate completion/interruption feedback. Rank milestones should improve strategic reliability—such as reduced interruption loss or a small completion guard—before simply raising healing. |
| 15 | Bulkhead | Ground line, zone control, defense, setup | E alternative | **High. Reserve for refinement.** It changes enemy routes and projectiles rather than adding another damage button. Placement preview must exactly match collision; blocked shots and path changes need readable reactions. Rank 5 could widen or lengthen it; rank 10 could allow one reposition/recast. Avoid attaching routine damage and crowding its defensive identity. |
| 16 | Plate recall | Multi-line, burst, payoff, stun | Packaged E/module | **Medium alone; high as a package. Merge with Plate magazine.** Recall has satisfying stored-position potential, but without Plate magazine it is nonfunctional. Learning or equipping the package should grant both planting and recall through one choice. Show plate count and return paths. Rank milestones can improve placement cap or recall behavior without adding another mandatory slot. |
| 17 | Echo drive | Ground dash, landing burst, recast, reposition | D/F alternative | **High, but stash during the two-movement focus.** The return window creates an engage–escape decision distinct from a simple blink. Make the origin and three-second recast state impossible to miss. Landing damage must stay secondary enough that this remains a movement choice. It is a strong future alternative, not a third initial movement option. |
| 18 | Scrap pursuit | Single, lunge, burst, execute/reset, wave chain | Advanced 1–4 active; possibly E | **High. Reserve for later.** Target selection and a kill refund can create a satisfying chain through weak enemies. It is not a good Q default because resets and forced movement make its cadence volatile. Mark eligible refund targets, never charge for an invalid target, and cap or pace chains so success feels intentional rather than automatic. |
| 19 | Core cutter | Long line, channel, sustained, anti-boss/wave sweep | R alternative | **High. Keep as a later R.** Rooting for up to five seconds, steering with inertia and escaping through D/F creates a strong commitment loop. Build heat, audio and contact intensity through the channel; clearly show cancel and escape options. It can reward uninterrupted boss contact while still sweeping a line of smaller enemies. The owner's earlier positive qualitative note should be confirmed at normal effects and actual combat size. |
| 20 | Orbital entry | Ground radial, delayed burst, reposition, wave clear | R alternative | **Medium. Stash until distinct from Reactor drop.** Both currently promise a delayed circular impact. Orbital entry should be the committed engage/escape ultimate: travel, temporary exposure, landing displacement or terrain crossing should matter more than being a second nuke. If those movement decisions are not valuable in current stages, consolidate its best spectacle into Reactor drop rather than supporting two near-duplicates. |
| 21 | Siege battery | Long-range ground burst, channel/root, recasts, anti-boss/zone | R alternative | **High. Keep for later testing.** Three individually aimed shells create agency and high-impact cadence. Each target reticle and remaining shell must be visible, with escalating fire/recoil feedback. Define whether cancellation preserves or spends unused shells. Its rooted vulnerability and long cooldown are already understandable costs; it does not also need unreliable aiming or excessive energy friction. |

### Priority interpretation

Self repair and Bulkhead are especially useful future E candidates because neither duplicates the current damage roster. Scrap crusher and Scrap pursuit have high thematic potential but should enter only after the baseline combat language is stable; execute and reset mechanics amplify tuning errors. Core cutter and Siege battery are the strongest unreviewed ultimate alternatives because their input patterns—not just their numbers—create different forms of commitment.

## Ability audit: movement 22–28

| # | Ability | Functional tags | Proposed home | Assessment and recommendation |
| --- | --- | --- | --- | --- |
| 22 | Ghost drive | Self, sustained movement, invulnerability, escape/engage | Default D | **High. Keep as requested.** It is a duration-based safety tool: run through danger and ignore slows. Use an unmistakable silhouette/afterimage and a clear end cue. Because three seconds of intangibility is extremely powerful, damage and control should not be added casually. |
| 23 | Ballast roll | Steered movement, collision burst, charge/recast, wave clear | Later D/F alternative | **High spectacle, medium reliability. Stash.** Acceleration and braking can create strong anticipation and comedy, but terrain, steering and collision can make correct play feel arbitrary. A successful crash needs generous truthful geometry and a large reaction; a miss needs a fast recovery path. Reintroduce only when stages consistently provide readable lanes. |
| 24 | Phase hop | Ground blink, charges, brief protection, reposition | Default F | **High. Keep as requested.** It is the clean precision counterpart to Ghost drive. The destination preview must reject or correct invalid terrain consistently, and arrival protection must have a readable duration. Avoid adding damage so the skill remains the pure, dependable positioning baseline. |
| 25 | Tumble jets | Line dodge, charges, next-hit empower, reposition | Later D/F alternative | **High once the hammer exists. Stash for now.** Dodge-then-sweet-spot is a natural skill-expression loop. It should empower the next deliberate hammer head hit, not merely multiply an automatic attack. Show the stored empowerment and let it expire predictably. It is the best candidate to test after the new basic attack is proven. |
| 26 | Veil drive | Line dash, brief intangibility, aggro misdirection | Later D/F alternative or Ghost upgrade | **Low current differentiation. Stash/merge.** It overlaps Ghost drive's pass-through safety and Phase hop's relocation. The “enemies pursue the last position” idea is distinct, but likely better as a Ghost drive rank milestone or a future decoy-focused skill with visibly fooled enemies. |
| 27 | Spring vault | Ground leap, invulnerability, landing burst, terrain crossing | Later D/F alternative | **Medium. Stash.** Terrain crossing plus a timed landing could differ from Phase hop, but the present promise is largely blink safety plus damage. It needs real jump-over threats and a landing-timing decision to earn a slot. If stages do not supply those, fold the slam spectacle into Orbital entry. |
| 28 | Wall runner | Contextual ground vault, barrier dependency, per-object lockout | Bulkhead/Phase upgrade, not standalone | **Low current standalone potential. Merge.** Its value depends on a nearby barrier and therefore fails the immediate-use test in many encounters. Let Phase hop cross barriers by default, or make a Bulkhead milestone allow a follow-up vault. Preserve the prototype for terrain research, but do not ask players to learn or equip it alone. |

Keeping only Ghost drive and Phase hop initially is more than roster reduction: it establishes two reference points against which every later movement ability can be judged. A candidate should be reintroduced only if it creates a meaningfully different reason to move, not because it has a different animation.

## Ability audit: summons 29–34

| # | Ability | Functional tags | Proposed home | Assessment and recommendation |
| --- | --- | --- | --- | --- |
| 29 | Line sentry | Deployable, directional sustained damage, wave/anti-boss | Later summon alternative | **Medium. Stash.** A directional turret is readable, but generic autonomous DPS overlaps Auto gun. It earns a return only if placement and facing reliably create firing lanes that the player actively defends or repositions. Show aim direction before placement and target acquisition after it. |
| 30 | Pulse anchor | Deployable radial sustained damage, zone, recast swap | **Default summon in 1–4** | **High. Recommended default.** Beginners can place a pulsing damage zone and immediately benefit; experts can use the nearby swap for escape, angle changes or bait. That is strong surface value plus optional depth. Show pulse timing, effective radius, lifetime and swap eligibility. Recasting outside swap range must not cause an accidental replacement. |
| 31 | Repair anchor | Deployable sustain, zone, recast teleport | Later support summon | **Medium-high. Reserve.** A safe healing location can change pathing, but teleport overlaps Phase hop and healing overlaps Self repair. Emphasize either “defend this refuge” or “prepare a return point”; doing both at full strength may erase too much risk. The aura boundary and teleport-ready state must remain visible during crowded combat. |
| 32 | Echo sentry | Deployable, conditional mirror, build payoff | Later advanced summon | **High concept, medium clarity. Reserve.** Mirroring chosen casts can create expressive combinations, but the current eligible-skill list and three-second rule are hard to predict. A clearer version would visibly arm, then copy the next eligible cast from its position at reduced strength. List eligibility on the loadout card and give an unmistakable ready/cooldown state. |
| 33 | Winch sentry | Deployable, periodic single pull, grouping | Merge/stash | **Low current differentiation.** It repeats Tractor cone and Gravity well through automation, while bosses ignore its most interesting effect. Its best idea is a stationary grouping anchor; consider making it a Gravity well milestone or a manual tether summon rather than another periodic damage pet. |
| 34 | Blast crawler | Moving deployable, sustained shots, conditional radial burst | Later advanced summon | **High theme, medium agency. Reserve.** A small machine seeking a crowded detonation has strong personality. “Surrounded by four” can also waste the summon unexpectedly. Give the player a visible arming/countdown state and either a detonate command or a predictable end-of-life explosion. Its weak shots should support, not obscure, the bomb identity. |

Pulse anchor is the strongest default because it demonstrates what a summon is without recreating the player's weapon. Its fixed position also creates a useful spatial relationship with the player. Blast crawler and Echo sentry are promising later options once the game can teach more autonomous rules without overwhelming the focused test.

## Ability audit: powered modes and passive-like effects 35–49

The current catalog calls all fifteen of these abilities “toggles,” but only four clearly support a meaningful player-controlled powered state. The rest are passive procs, build packages or equipment-like modifiers. Renaming the top-level group to **modules** would let the UI distinguish powered toggles, summons and passives without pretending they use the same interaction.

| # | Ability | Functional tags | Proposed home | Assessment and recommendation |
| --- | --- | --- | --- | --- |
| 35 | Coolant trail | Movement-shaped ground DoT, wave clear, upkeep | **Initial powered toggle** | **High. Keep.** It turns movement into offense and asks the player to kite enemies through a path. Preserve non-stacking patches and no self-damage. Clearly show active state, energy drain, remaining trail lifetime and enemy contact. Rank milestones can widen the trail or reward deliberate loops without making overlapping patches silently stack. |
| 36 | Arc coil | Mode/upkeep, multi-target sustained or single-target focus, wave/anti-boss | **Initial powered toggle** | **High. Keep.** Chain versus focus directly teaches the wave-clear/anti-boss distinction. The two modes need different silhouettes, cadence and sound, plus an always-visible state label. Switching should be quick enough to respond to target composition but costly enough that leaving it on is an energy decision. |
| 37 | Auto gun | Mode/upkeep, autonomous sustained DPS, range tradeoff | **Initial powered toggle** | **High. Keep.** Machine-gun and sniper modes offer understandable cadence/range tradeoffs and remain independent from the proposed hammer basic. Use separate cooldown clocks as currently required. Aim/firing effects must make misses and non-homing behavior legible; stopping movement must not imply that the autonomous gun stopped. |
| 38 | Scrap orbit | Build engine, pickup conversion, orbiting payoff | Later packaged module | **High identity, incomplete alone. Reserve.** Turning collected scrap into visible orbiting tools is thematic and ties offense to collection routes. It needs a useful base release/spend behavior in the same package. Then Collection pulse and Ricochet can become milestone branches rather than separate required choices. |
| 39 | Collection pulse | Periodic proc, radial burst, resource threshold | Scrap orbit milestone | **Medium as an upgrade; low standalone. Merge.** “Every eight scrap” is predictable only if progress is visible. Add it to Scrap orbit's rank or mastery path and show the counter. It should be one optional payoff for the orbit engine, not an unrelated toggle with no state choice. |
| 40 | Ricochet | Conditional multi-target payoff, hard dependency | Scrap orbit milestone | **Medium as an upgrade; low standalone. Merge.** It explicitly requires Scrap orbit, creating a loadout tax. Package it as a later orbit branch and make shard targets/path readable. It can become the wave-clear alternative to a more single-target orbit spend. |
| 41 | Reactive plating | Damage-triggered defensive proc | Passive equipment/mastery | **Medium. Reclassify.** Extra invulnerability after taking damage can improve fairness, but the player neither powers nor toggles it. Put it in defensive equipment/mastery and communicate the protected window. Check carefully that repeated hits cannot create near-permanent safety. |
| 42 | Recoil shell | Damage-triggered radial proc, wave clear | Passive equipment/mastery | **Low-medium. Stash.** Retaliation provides feedback after a mistake but can reward intentionally taking damage and overlaps Reactive plating as a hit reaction. It could be a low-damage defensive item perk with a cooldown; it is not one of the four powered modes. |
| 43 | Split barrel | Basic-attack multi-target modifier, sustained wave clear | Hammer mastery/retheme or stash | **Low under the proposed hammer.** Side bolts were designed around a commanded gun basic and conflict with the new melee language. If retained, retheme it as hammer-head shrapnel or a shockwave milestone with truthful arc geometry. Do not silently preserve gun bolts on a melee weapon. |
| 44 | Plate magazine | Basic-hit build engine, hard enabler | Package with Plate recall | **Medium alone; high as package. Merge.** Planting plates has no payoff without Recall. One learned module should plant plates through eligible hits and expose Recall as its active/recast. Show the cap and plate locations. This preserves the positional combo without charging two discoveries or loadout slots. |
| 45 | Third contact | Single-target counted proc, sustained/anti-boss | Q/hammer mastery or equipment | **Medium. Reclassify.** A third-hit payoff can make sustained focus matter against bosses, but invisible counters are bookkeeping rather than play. Attach it to a specific Q or hammer mastery, show the count on the target, and give the third hit distinct anticipation. It is not a powered toggle. |
| 46 | Flywheel | Movement build-up, collision proc, wave burst | Ballast roll package | **Medium in package; low standalone. Merge.** It duplicates Ballast roll's acceleration-and-crash fantasy. Use it as a rank milestone for Ballast roll if that movement skill returns. On its own it adds accidental collision damage to ordinary movement and muddies agency. |
| 47 | Hop drive | Post-attack movement proc, reposition | Tumble jets/hammer mastery or stash | **Low current potential.** It technically waits for a move command, but changing the next movement after every basic can still surprise the player and complicate precise positioning. A visible, opt-in Tumble jets empowerment is cleaner. Preserve it as a prototype until hammer locomotion tests show a real need. |
| 48 | Life converter | Mode/upkeep, self-cost, sustain/resource management | **Initial powered toggle** | **High. Keep.** It is the only proposed initial powered mode whose main purpose is not damage. Energy-to-hull versus hull-to-energy creates a genuine situational tradeoff; the 30% safety floor prevents an opaque self-kill. Use very distinct modes, continuously show transfer direction/rate and make low-resource shutdown explicit. |
| 49 | Shoulder drones | Passive autonomous sustained DPS, multi-source | Equipment/pet perk, not initial module | **Low current differentiation. Stash.** Always-on small bolts overlap Line sentry and Auto gun while asking little from the player. The concept fits the existing equipment/pet progression better than a scarce active loadout slot. If retained there, give the drones a non-damage utility or a trigger the player can influence. |

### Why these four powered toggles

| Toggle | Main decision | Coverage it adds |
| --- | --- | --- |
| Coolant trail | Where do I move while spending energy? | Kiting, path-shaped DoT and wave clear |
| Arc coil | Are many targets or one distant target the priority? | Explicit wave-clear/anti-boss switching |
| Auto gun | Which cadence/range mode fits the current threat? | Independent sustained DPS |
| Life converter | Is hull or energy more valuable right now? | Survival and resource strategy |

This set is stronger than four passive damage modifiers because every button changes behavior and creates a state the player can deliberately leave. It also samples four mechanics for focus testing without requiring a dependency chain.

## Proposed focused roster after this review

This is a recommendation for the next design/prototype pass, not a request to delete or immediately migrate anything.

| Control/group | Initial surfaced choice | Near-term alternatives to refine | Stashed examples |
| --- | --- | --- | --- |
| Basic | Proposed hammer swing | None until its head/handle and movement lock feel good | Existing commanded shot kept for regression during transition |
| Q | Impact bolt | Future sustained-damage candidates only after taxonomy tests | Scrap pursuit is not a baseline Q |
| W | Core strike | Return blade | Other burst/range tools remain preserved |
| E | No default selected by this research | Repulsor, Crosswire, Gravity well; later Self repair or Bulkhead | Tractor cone, dependency-heavy tools |
| R | Reactor drop | Core cutter, Siege battery | Orbital entry until differentiated |
| D | Ghost drive | Echo drive or Tumble jets later | Veil drive, Ballast roll during focus |
| F | Phase hop | Tumble jets later | Spring vault, Wall runner |
| Summon module | **Pulse anchor** | Echo sentry, Blast crawler | Line, Repair and Winch sentries during focus |
| Powered modules | **Coolant trail, Arc coil, Auto gun, Life converter** | Scrap orbit after it becomes a complete package | Passive procs and hard dependencies |

The research intentionally does **not** select a default E. The owner described several E options but did not name the default, and that choice materially changes the starting combat lesson. A Practice comparison should test whether the baseline needs peel (Repulsor), setup (Crosswire/Gravity well), or survivability/space-making (Self repair/Bulkhead).

## Rank milestone design

The owner's rank 5 and rank 10 proposals point toward a good general rule: ordinary ranks can improve numbers, while milestone ranks should alter use or create a new tactical reason.

Recommended milestone vocabulary:

- **Rank 5 — reliability or breadth:** extra charge, wider area, longer duration, clearer setup tolerance, or a second valid use case.
- **Rank 10 — transformation or encounter answer:** meaningful recast, mode branch, boss interaction, doubled sequence, ally/self benefit, or a new positional payoff.

Milestones still obey power budget. A rank 10 boss stun should not also add large damage, safety and uptime without a corresponding limit. Boss control needs explicit rules: duration scaling, immunity windows, movement-skill lockout and feedback when an effect is reduced. A “boss affected” icon is preferable to silently applying a shorter effect.

For the unreviewed recommendations:

- Pulse anchor rank 5 could improve zone reliability; rank 10 could deepen the swap, not merely multiply pulse damage.
- Bulkhead rank 5 could improve placement breadth; rank 10 could allow one deliberate reposition.
- Core cutter rank 5 could improve steering/control; rank 10 could reward maintaining a continuous line on one target.
- Scrap orbit rank 5 could unlock Collection pulse; rank 10 could choose Ricochet or a single-target spend rather than granting every payoff automatically.
- Tumble jets rank 5 could preserve hammer empowerment longer; rank 10 could reward a correctly positioned hammer-head hit rather than buff the dodge itself.

These examples should be tuned only after the base versions have a clear purpose.

## Practice research plan

Automated checks can confirm geometry, cost, state and regressions. They cannot establish that these moves are fun. The focused Practice pass should therefore separate three forms of evidence.

### Implementation verification

- Slot-family validation rejects illegal Q/W/E/R/D/F assignments.
- Learned same-family abilities enter inventory without deleting or down-ranking the equipped ability.
- Damage shapes match their visuals at normal and reduced effects.
- Toggle state, energy drain, proc counters, summon capacity and recast windows remain deterministic.
- Practice does not mutate collection or checkpoint data.

### Controlled behavior comparison

Use fixed enemy compositions and seeds for:

- a dense weak-enemy wave;
- a few durable enemies;
- one mobile boss;
- a projectile-heavy encounter;
- an arena with and without useful terrain/barriers.

Record clear time, damage taken, energy starvation, unused cooldown time and failed/invalid casts. These metrics diagnose function and balance; they are not fun scores.

### Human feel questions

After each short test, ask the player:

- What did this ability seem to be for?
- When did you choose not to use it?
- What part of success came from your decision rather than automatic output?
- Could you tell a miss, ordinary hit, sweet-spot hit and boss-reduced control apart?
- Did rank 5 or rank 10 change how you played?
- Would you equip it for a swarm stage, a boss stage, both, or neither—and why?

The most important signal is not a broad “was it fun?” rating. It is whether the player's description matches the intended promise and whether they can name situations in which the tool is and is not the right choice.

## Decisions that remain open

1. Which E teaches the best starting lesson: peel, setup or survival?
2. Are 1–4 exclusively modules, or may advanced actives such as Scrap crusher occupy them?
3. Does a summon consume one of 1–4, or receive a dedicated non-conflicting input? No new input should be invented without reviewing controls and UI.
4. Does Scrap orbit spend tools automatically, on hammer contact or through a command?
5. Is Plate recall an active exposed by equipping Plate magazine, a recast on the same button, or a rank milestone?
6. Which boss-control model applies consistently across Gravity well, Repulsor, Piston thrust and future tools?
7. At what safe location can learned loadouts change? Current camp-only arrangement, run-only mastery and persistent inventory rules need one explicit transaction model.

Until those questions are tested, “stash” should mean excluding an ability from the focused discovery/loadout pool while preserving its source, data and regression coverage.

## Research limits

The sources support principles—clear roles, legible costs, power budgets, readable feedback, beginner surface value, expert depth and deliberate playtesting. They do not determine MobaBot.io's exact damage, cooldown, charge count, rank breakpoints or fun. Several cited articles are developers' explanations of their own games rather than controlled experiments. The self-determination literature can frame competence and autonomy, but a recent critical review cautions against treating that theory as an automatic design recipe.[^11]

This audit is also description- and code-based. It has not replaced the owner's hands-on impressions. The recommendations should be considered hypotheses for focused Practice tests, with the dated owner record kept intact even where later tests disagree.

## Footnotes

[^1]: Sébastien Lambottin, “The Fundamental Pillars of a Combat System,” *Game Developer*. The article frames combat around choosing the right ability for target, distance and timing, with explicit advantages and tradeoffs. [Read the article](https://www.gamedeveloper.com/design/the-fundamental-pillars-of-a-combat-system).
[^2]: Riot Games, “Champion Insights: Hwei.” Hwei's spellbooks separate damage, utility and control while assigning each individual spell a niche. [Read the article](https://www.leagueoflegends.com/en-us/news/dev/champion-insights-hwei/).
[^3]: Bungie, “Destiny 2 Update 3.4.0” and “This Week in Destiny — 06/15/2023.” Bungie describes cooldown tiers tied to output and the problem of excessive uptime making exceptional power routine. [Update 3.4.0](https://www.bungie.net/7/en/News/Article/50880); [15 June 2023 design notes](https://www.bungie.net/7/en/News/article/this-week-in-destiny-6-15-23).
[^4]: Riot Games, “Champion Insights: Gwen.” The design discussion explicitly treats crowd control, utility and raw damage as competing parts of a power budget. [Read the article](https://www.leagueoflegends.com/en-us/news/dev/champion-insights-gwen/).
[^5]: Riot Games, “Quick Gameplay Thoughts: May 28.” The article discusses mobility as a fundamental capability whose systemic availability needs opportunity cost. [Read the article](https://www.leagueoflegends.com/en-us/news/dev/quick-gameplay-thoughts-may-28/).
[^6]: Mark Rosewater, “Lenticular Design,” *Magic: The Gathering*. The article describes designs with obvious beginner utility and additional expert meaning without unnecessary surface complexity. [Read the article](https://magic.wizards.com/en/news/making-magic/lenticular-design-2014-12-15).
[^7]: Rob Kay, “An Artist's Eye: Applying Art Techniques to Game Design,” *Game Developer*. The article applies anticipation, action and reaction to game feedback and stresses testing the whole sensory response. [Read the article](https://www.gamedeveloper.com/design/an-artist-s-eye-applying-art-techniques-to-game-design).
[^8]: Riot Games, “Clarity in League.” Riot describes gameplay hierarchy, matching presentation to importance, and communicating what happened so players can respond. [Read the article](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/). Riot's public [VFX Style Guide](https://nexus.leagueoflegends.com/wp-content/uploads/2017/10/VFX_Styleguide_final_public_hidpjqwx7lqyx0pjj3ss.pdf) provides related practical treatment of focal points and visual noise.
[^9]: Microsoft, “Xbox Accessibility Guideline 103: Additional Channels for Audio and Visual Cues.” The guideline recommends redundant sensory channels for critical information and uses distinct attack-contact sounds as an example. [Read the guideline](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103).
[^10]: Itay Keren, “Boss Up: Creating and Tuning Memorable Boss Battles,” GDC 2018. The presentation emphasizes clarity, testing learned skills, player expression and multiple approaches. [Read the presentation](https://media.gdcvault.com/gdc2018/presentations/Keren_Itay_BossUp.pdf).
[^11]: Sebastian Tyack and Elisa Mekler, “Self-Determination Theory in HCI Games Research: Current Uses and Open Questions,” 2024. The critical review examines limitations in how the framework is applied. [Read the paper](https://arxiv.org/abs/2405.12639). For the earlier empirical link between need satisfaction and game enjoyment, see Andrew Przybylski, Richard Ryan and C. Scott Rigby, “The Motivating Role of Violence in Video Games,” 2009, [PDF](https://selfdeterminationtheory.org/SDT/documents/2009_PrzbylskiRyanRigby_PSPB.pdf).
[^12]: Blizzard Entertainment, “Druid,” *World of Warcraft*. The official class overview separates tank, healer and damage roles while describing melee, ranged, healing and control functions within the toolkit. [Read the class overview](https://worldofwarcraft.blizzard.com/en-us/game/classes/druid).
[^13]: Bungie, “Your Guardian: Subclasses, Abilities and Gear.” Bungie's official guide describes Supers as the most powerful abilities while noting that they may damage, debuff or protect. [Read the guide](https://help.bungie.net/hc/en-us/articles/45080200239892--3-Your-Guardian-Subclasses-Abilities-and-Gear).

## Sources

1. [The Fundamental Pillars of a Combat System — Game Developer](https://www.gamedeveloper.com/design/the-fundamental-pillars-of-a-combat-system)
2. [Champion Insights: Hwei — Riot Games](https://www.leagueoflegends.com/en-us/news/dev/champion-insights-hwei/)
3. [Champion Insights: Gwen — Riot Games](https://www.leagueoflegends.com/en-us/news/dev/champion-insights-gwen/)
4. [Clarity in League — Riot Games](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/)
5. [League of Legends VFX Style Guide — Riot Games](https://nexus.leagueoflegends.com/wp-content/uploads/2017/10/VFX_Styleguide_final_public_hidpjqwx7lqyx0pjj3ss.pdf)
6. [Quick Gameplay Thoughts: May 28 — Riot Games](https://www.leagueoflegends.com/en-us/news/dev/quick-gameplay-thoughts-may-28/)
7. [Destiny 2 Update 3.4.0 — Bungie](https://www.bungie.net/7/en/News/Article/50880)
8. [This Week in Destiny — 06/15/2023 — Bungie](https://www.bungie.net/7/en/News/article/this-week-in-destiny-6-15-23)
9. [Lenticular Design — Magic: The Gathering](https://magic.wizards.com/en/news/making-magic/lenticular-design-2014-12-15)
10. [An Artist's Eye: Applying Art Techniques to Game Design — Game Developer](https://www.gamedeveloper.com/design/an-artist-s-eye-applying-art-techniques-to-game-design)
11. [Xbox Accessibility Guideline 103 — Microsoft](https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/103)
12. [Boss Up: Creating and Tuning Memorable Boss Battles — GDC 2018](https://media.gdcvault.com/gdc2018/presentations/Keren_Itay_BossUp.pdf)
13. [Self-Determination Theory in HCI Games Research — Tyack and Mekler](https://arxiv.org/abs/2405.12639)
14. [The Motivating Role of Violence in Video Games — Przybylski, Ryan and Rigby](https://selfdeterminationtheory.org/SDT/documents/2009_PrzbylskiRyanRigby_PSPB.pdf)
15. [Druid class overview — World of Warcraft](https://worldofwarcraft.blizzard.com/en-us/game/classes/druid)
16. [Your Guardian: Subclasses, Abilities and Gear — Bungie](https://help.bungie.net/hc/en-us/articles/45080200239892--3-Your-Guardian-Subclasses-Abilities-and-Gear)
