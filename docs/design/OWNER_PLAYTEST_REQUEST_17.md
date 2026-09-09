# Owner Implementation and Playtest Request

Status: **organized handoff for the next development session; no item in this document is implemented merely because it appears here.** Pull the latest `main`, read the linked source notes, implement coherent prototypes in small milestones, run relevant automated checks, and keep owner experience separate from technical verification.

This document consolidates the owner's 9 September 2026 directions. It is a working request, not a replacement for the full detail in:

- [`ABILITY_FEEDBACK_17.md`](ABILITY_FEEDBACK_17.md)
- [`ABILITY_TAXONOMY_RESEARCH_17.md`](ABILITY_TAXONOMY_RESEARCH_17.md)
- [`ENVIRONMENT_FEEDBACK_17.md`](ENVIRONMENT_FEEDBACK_17.md)
- [`SWARM_DESIGN_RESEARCH_17.md`](SWARM_DESIGN_RESEARCH_17.md)
- [`KIT_DESIGN_BRAINSTORM_17.md`](KIT_DESIGN_BRAINSTORM_17.md)
- [`RELAY_MARSHAL_DESIGN_17.md`](RELAY_MARSHAL_DESIGN_17.md)
- [`PRACTICE_SANDBOX_RESEARCH_17.md`](PRACTICE_SANDBOX_RESEARCH_17.md)
- [`QUALITY_BAR.md`](QUALITY_BAR.md)
- [`QA_17.md`](QA_17.md)

If summaries conflict, the latest dated owner statement in the detailed feedback documents wins. Preserve old implementations as regression/stashed content until replacements are verified; do not delete the wider ability catalog.

## Provenance boundary

The default kit, progression, controls, modules, ability refinements, terrain direction, Practice cleanup and Robot AI concept below originate from owner feedback. Implementation cautions and unresolved questions organize that direction without claiming owner approval for the answers.

The section titled **Assistant research findings: Swarm** is analytical output, not an owner statement. The implementation sequence and playtest exercises are also assistant-authored scaffolding for carrying out the owner's requests safely.

## Vanguard — locked default kit for testing

The owner locked this first kit on 9 September 2026 and later approved the simple name **Vanguard**. For the next focused design pass, treat it as one static all-rounder kit: do not offer cross-kit ability swapping or discovery replacements. Ranks and milestones may improve its fixed tools, but its composition stays stable. Revisit ability swapping only after several complete static kits have distinct, testable identities.

Vanguard's play identity is intentionally straightforward: remain mostly at mid range and let the player-controlled robot do the primary work through individually strong abilities. Its summon and totems provide support, space or temporary power windows; they must not turn Vanguard into a second Marshal or make remote bodies the main damage source.

| Input/system | Locked tool | Core test question |
| --- | --- | --- |
| Permanent passive | Autonomous machine gun; always owned, upgradeable, cannot be unequipped | Does it provide continuity without making manual play irrelevant? |
| Left click | Large positional hammer swing | Is the head/handle distinction readable and worth the movement commitment? |
| Q | Impact bolt | Does it remain a satisfying reliable damage baseline? |
| W | Core strike | Does long-range center payoff feel different from Q? |
| E | Body slam/Piston thrust | Does aim → collision → push feel like the best default tactical verb? |
| R | Reactor drop | Does it read as the highest-impact event and support meaningful rank milestones? |
| D | Hold-to-use Ghost drive | Is active lockout acceptable while passives continue? |
| F | Full-blink Phase hop | Are cast-origin buffering and thick-wall traversal predictable? |
| 1 | Close/fast versus far/slow orbiting tools | Do the two modes change positioning? |
| 2 | Targetable aggressive summon with weak gun, local pulse and short aggro draw | Does it create useful temporary space without tanking the whole encounter? |
| 3 | Stored-healing totem with energy/damage overflow | Is leave-and-return timing understandable and bounded? |
| 4 | Short-lived cooldown/energy totem | Does a five-second burst window create exciting ability sequences without becoming mandatory or self-looping? |

This lock is a design direction for a future implementation pass, not a statement about the current build. Preserve the existing shared pool and older abilities for regression until a static-kit migration is designed and verified.

## Owner kit concepts and assistant brainstorm

The owner next requested three highly synergistic static-kit directions: a summon network whose machines mirror casts and can trade places with the player, a geometry-heavy combo kit whose abilities transform one another, and a speedster with powerful but deliberately intermittent speed windows. The organized assistant proposals, interaction grammar, risks and prototype order are in [`KIT_DESIGN_BRAINSTORM_17.md`](KIT_DESIGN_BRAINSTORM_17.md). They are brainstorm material, not approved ability specifications; only the first/default kit above is locked.

Later owner direction parks the combo kit for now and names the summon-network character **Marshal**. Each relay detects autonomously within X and may fire as far as roughly 3X when the target is inside another relay's X circle or the player's attack range. Player basics command a substantial extra relay attack on a separate clock; Q launches maximum-range exploding missiles from all bodies; W creates a medium EMP at every relay; E pulses damage along every relay pair; and Overclock massively increases fire rate/missiles while turning body transfers into relay-sacrifice explosions with a 10-second redeploy wait. Slots 1–3 deploy distinct-projectile robot bodies and use press → left-click to reposition or a second key press to transfer control. Full wording, unresolved cases and source-backed design reasoning are in [`RELAY_MARSHAL_DESIGN_17.md`](RELAY_MARSHAL_DESIGN_17.md).

For the third and final current class concept, the assistant recommends returning to the owner's speedster idea under the simple working name **Racer**. Its fun-first gameplay axis is alternating a short controllable Overdrive with a capable ranged recovery state, using near-pass damage and route-shaped effects rather than a large combo dictionary. This remains a brainstorm proposal in [`KIT_DESIGN_BRAINSTORM_17.md`](KIT_DESIGN_BRAINSTORM_17.md), not a locked kit.

## Requested progression flow

The bullets below preserve the owner's earlier progression concept. The later static-kit decision narrows it for the next design pass: a player may still learn or rank the fixed abilities belonging to the selected kit, but cross-kit discoveries, storage swaps and replacement choices are deferred with general ability swapping. Do not implement the older inventory/replacement bullets until the owner revisits that system.

- Before all skills are learned, alternate XP rewards between an existing-skill upgrade event and a locked-skill learn event.
- Never mix owned and locked abilities in one choice.
- Treat locked abilities as rank 0 and learning as raising one to rank 1.
- Do not pause combat for an ability popup.
- Show eligible level-up indicators on owned live abilities; support Ctrl + assigned key and a small clickable upgrade control.
- Provide a compact non-modal route to rank-0 skills that are not on the live bar.
- Newly learned same-family skills enter storage. They may replace the equipped skill only at a safe between-phase/stage arrangement point.
- Consider faster XP only after the new interaction proves readable and pending rewards do not create pressure.

Resolve stacking pending rewards, max-rank fallback, controller access, storage interaction and exact stage timing before changing save or discovery rules.

## Requested combat and control behavior

### Permanent gun and hammer

- Keep the autonomous machine gun independent from the manual hammer and from ability cooldowns.
- Keep the gun working during Ghost drive and other passive-compatible states.
- Make the hammer a roughly 90-degree committed left-click swing with a high-value head and low-value handle.
- The head deals greater damage, pushes and briefly stuns; the handle deals little damage and does not push.
- Initial hammer cadence target is approximately one swing every two seconds.

### D — Ghost drive

- Hold for movement speed used for escape, traversal and collection.
- While held, block the hammer/basic and every active ability, including F and active modules.
- Keep the permanent machine gun and all other passives running on their own clocks.
- Existing orbit effects and already-deployed constructs continue if they are passive/persistent, but D blocks toggling, casting or redeploying them until released.
- Add a readable afterimage and dedicated speed sound.

### F — Phase hop

- Implement a true instantaneous blink with departure/arrival smoke-poof and a dedicated sound; do not draw a travel trail.
- If F follows an eligible ability input by less than 0.1 seconds and that ability has not released, originate the effect from the post-blink location.
- Spend each action once and define aim preservation per targeting family.
- If a capped endpoint is inside thick terrain and past its midpoint along the blink ray, land at the nearest valid far-side point; otherwise remain/snap to the near side.
- Include the owner's 1.9-times-wall test and body-clearance/corner/connected-obstacle cases.

### E — body slam

- Approximate eight-second cooldown and short aimed dash.
- Extend the enemy hit shape slightly beyond the robot's front.
- Stop on first enemy contact and create a circular damage impact around the robot.
- Push ordinary enemies; bosses and future heavy enemies resist displacement.
- At base rank, briefly ignore touch damage only. Projectiles, poison and other enemy abilities still damage.
- Rank 5 adds a very brief stun.
- Rank 10 grants a clear full-immunity shield during the dash and for one second after successful impact.
- Add a speed/air-resistance envelope, launch sound and impact sound without implying pre-impact fire damage.

Define touch damage as a separate source type with a repeat-hit grace policy. Projectile and poison damage must not consume or inherit touch grace.

## Requested default modules

### 1 — orbiting tools

- Close/fast default mode and far/slow alternate mode.
- Make radius and angular speed affect actual positioning and contact, not only appearance.
- Decide contact damage, energy and switch cadence after the two modes are visually readable.

### 2 — aggressive summon

- Weak machine gun plus low local AoE pulse.
- Targetable, destructible and visibly durable enough to matter briefly.
- Draw enemy aggro only within a smaller local range than the player's.
- Show health, pulse timing and aggro transfer.

### 3 — healing totem

- Store healing while the player is away, up to a cap; discharge when the player returns.
- Apply value in order: missing hull → missing energy → small damaging shock wave.
- Cap every conversion and block recursive generation.

### 4 — cooldown/energy totem

- Replace the paired zap robots; relay-pair damage now belongs exclusively to Marshal.
- Deploy a short-lived power totem, initially suggested at approximately five seconds of uptime and a 15-second cooldown.
- While the benefit applies, double cooldown recovery so affected abilities recharge in roughly half their normal time and give the player unlimited energy.
- The totem must not accelerate its own cooldown or recursively extend its own uptime.
- Decide whether the benefit requires standing inside a visible aura, when the 15-second cooldown starts, whether R/D/F are affected, and how stored charges recover before tuning uptime.

### Non-aggro deployment rule

- Slot 3 and slot 4 deployables are not targetable or killable.
- They expire after a finite lifetime.
- Natural expiry normally starts a 10-second redeploy wait; the slot-4 power totem's newer approximately 15-second cooldown proposal supersedes that generic timing for its own ability.
- Manual redeployment before expiry replaces/moves the construct and resets its lifetime, encouraging active repositioning.
- Specify whether stored healing survives a move and whether repositioning the power totem refreshes its duration.

## Requested ability directions

Implement only after the baseline kit is isolated and testable. The exact owner descriptions in `ABILITY_FEEDBACK_17.md` win.

- Impact bolt: default Q; preserve its bread-and-butter identity.
- Welding torch: longer facing/movement-directed channel with rank 5/10 width/duration/range changes; not default E.
- Reactor drop: default R; rank 5 heals/speeds the player inside; rank 10 strikes twice and stuns.
- Return blade: W alternative; larger, farther, slower, piercing, with player movement affecting return.
- Gravity well: low damage and primarily grouping; larger/longer milestones; later explicit boss movement denial.
- Core strike: default W; rank 5 stores three charges, rank 10 stores four with more reach and larger center.
- Crosswire: preserve as an older E/module idea, but do not duplicate the relay-pair geometry now reserved for Marshal.
- Repulsor: E alternative focused on shove; rank 5 wider, rank 10 boss interaction/stun.
- Guard sweep: replace conceptually with the hammer, preserving old implementation for regression until transition is proven.
- Rim cutter: stash/consolidate useful purpose into Repulsor; do not delete.
- Piston thrust: use the later body-slam E rules, which supersede the initial always-stun note.

## Requested terrain exploration

Create greybox alternatives before environment art:

1. A few long, thick terrain masses forming broad corridors.
2. Clusters of natural blob-like and partially rigid forms creating pockets with several exits.
3. A large circular structure or enclosure with four wide entrances and combat space inside/outside.

Terrain must look and collide as substantial volume, retain clear starts and ability space, route ordinary enemies without snagging, support bosses, and remain below threats/pickups in visual hierarchy. Preserve the current layout as a regression reference.

## Owner research request: Practice sandbox cleanup

The owner wants Practice cleaned up into a faster combat laboratory. Preserve its strict progression/checkpoint isolation, but research a live left-side interface for selecting complete loadouts, changing focused player stats, choosing enemies and placing them with the mouse. Use one simple smallish test arena with a few substantial large and medium rocks rather than another campaign map.

The source comparison, proposed four-section dock, mouse-placement grammar, greybox ingredients, honest modified-test labels, metrics and phased acceptance plan are in [`PRACTICE_SANDBOX_RESEARCH_17.md`](PRACTICE_SANDBOX_RESEARCH_17.md). The leading recommendation is a collapsible live dock with Build, Player, Enemies and Session sections; Point/Line/Ring/Cluster placement; a few named test scenarios; and a collapsed per-source measurement strip. Do not expose every internal variable on the main surface, implement a campaign editor or let Practice write rewards/loadouts back to the real profile.

This is research and future implementation direction only. `QA_17.md` remains the current Practice behavior until the redesign is implemented and verified.

## Future robot perspective and animation bookmark

Revisit whether the player robot and related bodies should use a **true top-down presentation** rather than the current perspective. Explore camera perspective and character animation together: changing the view affects silhouette, readable facing, weapon attachment points, shadows, collision honesty and the directional poses or frames required.

The owner wants to revisit this on the home computer, where the Astra model may be useful for animation-oriented exploration. Treat that as a candidate production tool, not evidence that it can already produce a coherent shippable animation set. Before replacing assets, compare a very small representative motion test—idle/move, basic attack, one aimed cast, body slam and one damage/death reaction—at actual combat size, normal zoom and Reduced effects. Preserve current assets and provenance until the owner selects a perspective after seeing the motion tests.

## Owner research request: Robot AI mode

The owner proposes researching a low-input **Robot AI mode**. The motivation is to let time and earlier progression compound into useful results without making autoplay the strongest way to clear new content.

### Owner concept

- The AI pilots the player's robot with intentionally mediocre ability use and lower effectiveness than a capable human.
- It farms lower ascensions or easier stages only after the player has become strong enough for that content.
- It should not push the player's current hardest stage or replace manual mastery of new encounters.
- The feature creates a reason to maintain two kinds of builds:

| Build goal | Desired strengths |
| --- | --- |
| Low-input / farming | Passive power, magnet or pickup reach, drop rate, reliability, survivability and tolerance for mediocre decisions |
| Level pushing | Maximum potential damage, precise active combos, manual outplay, stage-specific counterplay and higher execution ceiling |

The split is intended to make low-input power a legitimate build axis without making it universally optimal.

### Research required before implementation

Do not treat “AI mode,” “auto-repeat” and “offline progress” as synonyms. The next agent should compare at least:

1. **Visible autoplay:** the actual simulation runs and the owner can watch or take control.
2. **Background/auto-repeat:** completed runs repeat with limited interaction while the application remains active.
3. **Offline simulation:** elapsed real time converts into rewards without running combat.

These models have different engineering, balance, energy-use, save-integrity and player-expectation consequences. Research should answer:

- What proof unlocks automation for a stage: one manual clear, several clears, a power threshold, an ascension gap or a combination?
- Must a player manually clear each stage/ascension before AI farming, and how far below the highest clear must AI remain?
- Does AI use the live combat simulation or a deterministic reward model?
- What reward percentage, drop table and daily/session cap preserve the value of active play without making the feature feel pointless?
- May AI earn permanent equipment, credits and unlocks, or only already-farmable resources?
- Can the player watch, interrupt and take over without duplicating rewards or corrupting a checkpoint?
- How are death, timeout, disconnected sessions, app closure and save failures resolved transactionally?
- How deliberately weak should AI targeting, dodging, ability timing and loadout selection be?
- Will players feel encouraged to design reliable farming builds, or merely obligated to leave the game running?
- Does drop-rate equipment become mandatory for unattended progression and distort the active game economy?
- How does this interact with the current rule that automated tests and fixtures never grant permanent loot?

### Initial guardrails to evaluate

These are conservative research hypotheses, not settled owner rules:

- Require a manual clear before a stage can be automated.
- Keep AI at least one meaningful difficulty tier below the highest manually proven content.
- Never let AI claim a first clear, unlock a new stage/ascension or complete a skill-check achievement.
- Make rewards atomic: validate the result, write once, and roll back any failed transaction.
- Use a separate saved farming loadout so switching back to the pushing build is effortless.
- Show expected time, likely reward range, allowed content and why a stage is locked before starting.
- Prefer finite queued runs or a capped claim window over an uncapped always-on economy until data supports more.
- Keep the AI intentionally understandable rather than secretly scaling its competence to guarantee success.

The next research artifact should review idle/AFK games, auto-battlers and auto-repeat systems in adjacent action RPGs. It should distinguish healthy convenience and return motivation from compulsory uptime, inflation, battery/compute waste and progression that bypasses play.

## Assistant research findings: Swarm

The following findings come from [`SWARM_DESIGN_RESEARCH_17.md`](SWARM_DESIGN_RESEARCH_17.md). They are not explicit owner thoughts or approved implementation requirements.

- Continuous baseline offense can lower attention demand while manual tools preserve a higher skill ceiling.
- Map destinations, pickups and short optional objectives give movement a purpose beyond retreating in circles.
- Rank/evolution moments feel stronger when they transform function and presentation rather than only raising numbers.
- Wave direction, shape, composition and terrain relationship can provide content variety before adding many enemies.
- Synergies are strongest when the player can see and plan the setup/payoff relationship.
- Persistent progression can give failure direction, but must not conceal unfair balance or make starter difficulty depend on grinding.
- Large enemy/effect counts create clarity and performance costs; bounded spectacle is more relevant to MobaBot than copying Swarm's scale.

One derived terrain hypothesis is to give each greybox at most one original functional landmark or short optional route objective. Test destination → exposure → payoff without copying Swarm's maps, fountain, cannon or art.

The research explicitly advises against importing Swarm's champion classes, exact weapon/passive recipes, modal level-up flow, co-op balance, fifteen-minute pacing, map devices or enemy counts.

## Implementation sequence

| Pass | Scope | Do not combine yet |
| --- | --- | --- |
| 0 | Practice left dock, mouse placement and simple test greybox as specified in the separate research note | Campaign terrain, balance or save-format changes |
| 1 | Permanent gun, hammer, Q/W and body-slam E in isolated Practice | Terrain overhaul, new progression, all four modules |
| 2 | Ghost drive restriction/effects and Phase hop blink rules/effects | XP increase |
| 3 | Each 1–4 module alone, then combined with explicit caps | Stashed skill reintroduction |
| 4 | Non-modal alternating learn/upgrade interaction | Faster XP until usability passes |
| 5 | Three terrain greyboxes and one-landmark variants | Finished environment art |
| 6 | Rank milestones, wave grammar and selected synergies | Broad catalog expansion |
| 7 | Focused owner playtest, tune, then decide what returns | Deletion of old content |
| 8 | Robot AI research and economy/gating proposal only | Autoplay implementation before owner selects a model |

Commit coherent verified milestones. Preserve saves, user music, migration fixtures and old skill data. Practice and automated tests must never award permanent loot.

## Focused owner playtest script

### Session A — baseline combat

Use the same short encounter with permanent gun only, then gun + hammer/Q/W/E/R.

- Can the player identify what continues automatically?
- Does the hammer head feel substantially better than the handle?
- Is body slam chosen for engage/peel rather than ordinary travel?
- Does Q remain useful after W/E/R are available?
- Can the player explain what hit them?

### Practice usability setup

Before the combat sessions, ask the owner to load the Vanguard rank-5 preset, place ten weak enemies by a large rock, replace them with an armored dummy, reset measurement and return every modifier to Normal without instructions. Record completion time, mistaken clicks, placement precision and any hidden/clipped control. Confirm on exit that equipment, collection and checkpoint are unchanged.

### Session B — D/F

- Hold D while enemies, pickups and passive gun targets are present.
- Confirm every active/manual input is blocked with feedback while passives continue.
- Test ordinary F, F through three terrain thicknesses and four representative ability → F buffers.
- Ask whether D feels intentionally restricted and F feels instantaneous/predictable.

### Session C — modules

- Test each slot alone, then all four together.
- Ask the player to explain both orbit modes, why the summon drew aggro, when the totem pays out and what the zap line damages.
- Allow natural expiry once, then proactive redeployment.
- Observe whether active upkeep is engaging or becomes four maintenance timers.

### Session D — progression flow

- Alternate at least three upgrade and three learn rewards without pausing.
- Let one reward remain pending through combat and create two pending rewards.
- Learn a same-family replacement and fit it only at the intended safe point.
- Measure missed inputs, time-to-choice and whether indicators feel rewarding or stressful.

### Session E — terrain and wave shape

- Run identical enemies/loadout through all three greyboxes.
- Repeat with one optional landmark and with wave directions that use each entrance/corridor.
- Record path failures, unavoidable traps, camping exploits, travel downtime and location recall.
- Ask which geometry created useful decisions and which merely obstructed movement.

### Conditional Session F — Robot AI

Run only after the separate research resolves the automation model, unlock gate and reward policy.

- Compare the same manually cleared lower-stage content with manual play and the intentionally mediocre AI.
- Test a low-input farming loadout and a level-pushing loadout under AI; the farming build should be more reliable without becoming the best manual push build.
- Verify the AI cannot enter or first-clear unapproved content.
- Interrupt, take over, close/reopen and fail the run while checking that rewards commit exactly once.
- Record success rate, run time, rewards per active hour, rewards per unattended hour and failure causes.
- Ask whether the system feels like optional convenience and accumulated progress or compulsory upkeep.

## Evidence to return to the owner

Keep three sections in the handoff:

1. **Implemented:** exact behavior and intentionally deferred questions.
2. **Verified:** automated checks, rendered actual-size captures and fixed-scenario measurements.
3. **Experienced:** owner's comments, confusion, preferred option and remaining feel issues.

Do not call a feature fun because tests pass. Do not raise `QUALITY_BAR.md` scores without corresponding human evidence. Preserve every new dated owner comment verbatim or faithfully paraphrased without overwriting older snapshots.
