# Static-kit design brainstorm

Status: **owner direction plus assistant proposals for later review; no implementation is authorized merely because an idea appears here.** The first/default kit is locked as a design target. The other three kits are deliberately concrete enough to discuss and prototype, but their names, rules, numbers and slot assignments remain suggestions.

Date: 9 September 2026.

**Later owner focus:** park the Circuit Weaver/combo proposal without deleting it. It is not ready for approval or implementation. Focus current kit design on the summon character, now named **Marshal** and refined in [`RELAY_MARSHAL_DESIGN_17.md`](RELAY_MARSHAL_DESIGN_17.md). That focused document supersedes the initial Relay Architect sketch below.

## Provenance

### Owner direction

- Use static kits for now. Defer ability swapping between kits until the kits themselves feel coherent.
- Lock the first/default kit already recorded in `OWNER_PLAYTEST_REQUEST_17.md`.
- Explore a kit whose summons mirror its abilities, share awareness, interact with one another, can be self-detonated and let the player switch places with them by pressing their summon input again. Summons expire after roughly 30 seconds.
- Explore a high-expression combo kit in which abilities are individually modest but become powerful when their paths or areas intersect. A spiraling escaping orbit crossing a straight-line attack and producing an explosion with chain lightning is one example, not a locked mechanic. R and modules may participate in the combo identity.
- Explore a speedster whose high-speed state has about half uptime. Passing near enemies can deal damage, and speed should synergize with trail effects. The kit must still feel capable and satisfying outside the speed window.

### Assistant contribution

Everything below the locked default-kit record is an assistant-authored synthesis. It translates the owner concepts into consistent input roles and testable interaction grammars. Treat it as a proposal to critique, not as owner approval.

## Kit 1 — Default kit (locked; Vanguard proposed)

Identity: readable all-rounder. Its tools mostly work alone, cover the major combat jobs and teach the common control language before later kits ask for tighter setup.

| Input/system | Locked tool | Job |
| --- | --- | --- |
| Permanent passive | Autonomous machine gun | Continuous low-input pressure |
| Left click | Positional hammer swing | Committed melee hit with head sweet spot |
| Q | Impact bolt | Reliable bread-and-butter DPS |
| W | Core strike | Long-range burst with center payoff |
| E | Body slam/Piston thrust | Engage, shove and later stun/safety |
| R | Reactor drop | Highest-impact area event |
| D | Ghost drive | Sustained escape/collection movement with active lockout |
| F | Phase hop | Precise instantaneous blink |
| 1 | Two-mode orbiting tools | Close/fast versus far/slow positioning |
| 2 | Aggressive summon | Local damage and limited aggro relief |
| 3 | Healing totem | Leave-and-return sustain economy |
| 4 | Paired zap robots | Active line placement |

“Locked” means the composition should not be reopened during the next concept pass. Exact tuning, visuals, rank milestones and unresolved edge cases still require implementation and owner playtesting. The current 0.17 shared-pool build remains authoritative until that work is requested.

## Shared design rule for the next kits

Each kit needs one short sentence that predicts how it wins:

- The default kit wins by choosing the right self-contained tool. **Vanguard** is the assistant's proposed simple name, pending owner approval.
- Marshal wins by creating useful firing origins and preserving its network.
- Circuit Weaver wins by making different geometries touch at the right time.
- Redline Runner wins by banking value, spending it during a speed window and surviving recovery.

Every fixed input should reinforce that sentence. A mechanically strong ability that does not reinforce the kit belongs elsewhere.

## Initial Kit 2 sketch — Relay Architect (superseded)

The focused [`RELAY_MARSHAL_DESIGN_17.md`](RELAY_MARSHAL_DESIGN_17.md) proposal supersedes this first sketch. It remains below as brainstorm history, not a competing current specification.

### Core promise

Build a temporary combat network. Summons turn one player input into attacks from several positions; swapping makes the network both weapon and escape route. Losing or badly placing the network is the kit's weakness.

The owner's BTD6-style shared vision idea needs translation because the current arena has no meaningful fog of war. The useful version is **shared acquisition**: if the player or any relay detects a target, every connected summon may track and prioritize it within its own weapon range and line-of-fire rules. If later maps hide enemies or use true sight blockers, literal shared vision can be reconsidered.

### Proposed interaction grammar

- Slots 1–4 deploy four specialized relays. Each lasts 30 seconds.
- Pressing the same occupied summon slot again swaps the player with that relay, subject to a short swap cooldown and a valid destination.
- A swap preserves the relay's remaining health and lifetime; it is not a free heal or duration refresh.
- Q/W/E specify an origin-independent command. The player casts at full value and active relays mirror a reduced, non-recursive form from their locations.
- Mirrored effects never mirror another mirror, spend player energy again or recursively trigger cast procs.
- Several relays improve coverage and angles more than raw single-target multiplication. Same-target echo hits need diminishing value or a shared cap.
- Natural expiry produces a small, predictable shutdown burst. A deliberate ultimate can convert remaining relays into stronger detonations, so self-destruction is a decision rather than free background damage.

### Proposed fixed loadout

| Input/system | Proposal | Synergy purpose |
| --- | --- | --- |
| Passive | Relay mesh | Shares target acquisition; clearly displays connected, isolated and expiring relays |
| Basic | Command round | Modest shot that marks one enemy as the network's priority |
| Q | Sync bolt | Player and relays fire the same aimed low-cooldown projectile; primary spatial DPS tool |
| W | Convergence beam | Each origin fires toward one point; distinct angles create one capped focus burst, rewarding surrounding a boss |
| E | Magnetic crosslink | Temporarily strengthens links between relays, slowing or pulling ordinary enemies crossing them and giving the player a setup tool |
| R | Scuttle cascade | Overclocks all active relays briefly, then detonates them in visible sequence; swaps can alter the final pattern before commitment |
| D | Network stride | Short movement-speed burst that is stronger while moving along an active relay link; usable even with no relay at reduced value |
| F | Failsafe hop | Small independent blink so losing every summon does not also remove the kit's emergency movement |
| 1 | Striker relay | Precise single-target fire; mirrors aimed casts |
| 2 | Pulse relay | Local periodic AoE and wave control |
| 3 | Ward relay | Weak protection/repair around itself; trades damage for a safer swap destination |
| 4 | Breach relay | Shorter-lived armored relay with the strongest shutdown/detonation effect |

### Why this version could feel good

- A beginner gets value by deploying machines and pressing Q.
- An expert earns more through triangle/encirclement placement, target marking, safe swap routes and detonation order.
- Relays create a changing map inside the map. Moving the player changes aim; moving through the network changes survival options.
- The kit has a real failure state: expired or destroyed relays reduce both offense and mobility until rebuilt.

### Main risks to prototype

- Four simultaneous relays plus mirrored casts could overwhelm effects, performance and damage scaling.
- Recast-to-swap must never accidentally replace a relay or spend a new deployment.
- Swapping into blocked terrain, an enemy body or a lethal telegraph needs one consistent validation rule.
- Thirty seconds may create maintenance rather than strategy. Test visible lifetime rings and staggered expiry before adding duration upgrades.
- Shared acquisition should not let projectiles ignore walls or weapon range.

## Kit 3 proposal — Circuit Weaver

### Core promise

Lay down simple attack shapes, then make unlike shapes intersect for stronger reactions. Individual casts remain usable, but deliberate geometry creates the kit's real ceiling.

The scalable solution is a small **reaction grammar**, not a unique rule for every pair of buttons. Three persistent shapes create three learnable pair reactions:

| Intersection | Reaction | Combat job |
| --- | --- | --- |
| Spiral + line | Arc burst | Explosion plus bounded chain lightning; burst/wave payoff |
| Spiral + field | Vortex discharge | Pulls ordinary enemies inward, then bursts; grouping payoff |
| Line + field | Prism sweep | Refracts the line across part of the field; coverage/long-range payoff |

This delivers the owner's “any two abilities matter together” feeling without requiring players to memorize dozens of exceptions.

### Proposed fixed loadout

| Input/system | Proposal | Synergy purpose |
| --- | --- | --- |
| Passive | Resonance | Unlike shapes that touch become primed; a clear symbol previews the resulting reaction |
| Basic | Tuning shot | Nudges a nearby spiral and refreshes a primed reaction briefly; low damage on its own |
| Q | Escaping spiral | Sends a projectile outward in a widening spiral; repeatable DPS and the spiral component |
| W | Rail trace | Long straight attack that lingers briefly as a conductive line |
| E | Containment field | Places a circular slow zone; utility alone, powerful when another shape enters it |
| R | Catalyst pulse | Lower-cooldown ultimate that triggers all currently primed reactions at reduced individual power, without inventing a fourth geometry |
| D | Vector drive | Short dash that can drag the nearest spiral's center, changing its future intersection path |
| F | Trace blink | Blink that leaves a short-lived origin-to-destination line; movement can complete a combo but never deals large damage alone |
| 1 | Orbit regulator | Toggle spirals between tight/fast and wide/slow paths |
| 2 | Polarity switch | Toggle field reactions between stronger pull and weaker push; state must be visually obvious |
| 3 | Capacitor | Stores one otherwise-wasted primed reaction for a short time; one visible charge only |
| 4 | Prism lens | Powered mode that improves reaction coverage at an energy cost, not base single-target damage |

### Why this version could feel good

- The player can understand three shapes before learning three pair outcomes.
- The same cast has different value depending on its angle and timing, creating expression without demanding faster button presses.
- R becomes a frequent punctuation mark for combo planning rather than a disconnected giant nuke.
- Missed intersections still produce modest standalone effects, preventing total dead inputs while keeping a meaningful ceiling.

### Main risks to prototype

- Reaction feedback can become unreadable in a crowd. Preview the reaction at the intersection before detonation and keep colors secondary to shape.
- If standalone abilities are too weak, learning feels punitive; if too strong, geometry becomes decorative. Compare isolated, accidental and deliberate use separately.
- One reaction must trigger once per eligible pair, not once per simulation frame or overlapping body.
- R should accelerate decisions, not automatically solve every prepared field. Cap simultaneous reactions and preserve the need to place them.
- The module row may be too busy. Prototype Q/W/E/R first, then add one module at a time only if it strengthens the grammar.

## Kit 4 proposal — Redline Runner

### Core promise

Alternate between a stable setup/recovery phase and a short high-speed release. The normal state banks power and aims precisely; the fast state turns route choice and near-passes into damage. Neither state should feel like waiting for the other.

### Proposed state model

- D activates approximately six seconds of Overdrive followed by approximately six seconds in which it cannot be activated. This creates a theoretical half-uptime ceiling before tuning.
- Overdrive improves speed but reduces turn sharpness enough that route planning matters.
- Passing near an enemy damages it with visible wheel spikes or side blades. Each enemy has an explicit re-hit cooldown, so circling a boss does not create frame-rate-dependent damage.
- Distance lays trail segments at fixed spacing. Moving faster makes a longer trail, not denser overlapping patches.
- The recovery phase restores better aiming, energy generation and access to stored-momentum payoffs. It is a combat mode, not a cooldown penalty box.

### Proposed fixed loadout

| Input/system | Proposal | Normal-state value / Overdrive value |
| --- | --- | --- |
| Passive | Flywheel bank | Basics, pickups and purposeful movement bank capped momentum / Overdrive spends it to sustain pass-by tools |
| Basic | Stabilized repeater | Reliable ranged pressure and faster banking / still fires, but less accurate while turning hard |
| Q | Wheel bolt | Reliable straight returning wheel / gains penetration and a wider return path at speed |
| W | Kinetic lance | Cashes out banked distance as a capped long-range burst, strongest during recovery / Overdrive primarily charges it |
| E | Handbrake sweep | Close push and brief control while slow / sharp drift turn with a damaging side arc while fast |
| R | Ghost lap | Records a short route, then an afterimage retraces it and damages along the path; the echo continues into recovery |
| D | Overdrive | Enters the fixed high-speed window; cannot be refreshed into permanent uptime |
| F | Vector hop | Short directional dash that preserves momentum and can correct one bad Overdrive angle |
| 1 | Side blades | Enables near-pass damage with truthful reach and per-target cooldown |
| 2 | Coolant exhaust | Leaves non-stacking path-shaped DoT at distance-based intervals |
| 3 | Kinetic capacitor | Converts a capped portion of banked momentum into a shield when Overdrive ends |
| 4 | Induction magnet | Pickups modestly help refill the bank; hard caps prevent infinite orb loops or runaway AFK scaling |

### Why this version could feel good

- Speed is both offense and a steering challenge rather than a permanent stat advantage.
- The high-speed route creates value that pays off after it ends: W spends banked distance, the capacitor protects recovery and Ghost lap keeps attacking.
- Normal mode still has a dependable basic/Q, better precision, a defensive E and the kit's largest aimed cash-out.
- Wave clear favors long curved routes and trails; bosses favor controlled near-passes followed by a Kinetic lance. The same identity serves different encounters.

### Main risks to prototype

- High speed can break camera readability, obstacle routing and enemy telegraphs. Start in a simple arena and never compensate with blanket invulnerability.
- Movement-speed multipliers need a hard total cap across gear, mastery and the kit.
- Near-pass damage needs truthful side geometry and separate touch-damage handling.
- If optimal play is tight circles, the fantasy collapses into repetitive orbiting. Reward route variety, distance and changing targets rather than raw time near one enemy.
- Trail, side-blade and R path effects need bounded segments and effect pools at both normal and reduced-effects settings.

## Recommended prototype order

Do not build all three at once.

1. Keep the locked default kit as the control condition.
2. Prototype Marshal with one relay, command fire, Q mirroring, repositioning and body transfer. Add the other relays only after the basic loop is readable.
3. Prototype Circuit Weaver with only Q, W, E and the three pair reactions. Add R after players can intentionally create each pair.
4. Prototype Redline Runner with D, side blades, Q and W in an empty arena. Add trail and Ghost lap after steering and camera behavior feel safe.

For each slice, compare beginner value, expert ceiling, damage taken, energy pressure, invalid actions and whether the player can explain the kit's win sentence. Automated probes can verify caps and geometry; only human play can decide whether maintaining relays, constructing intersections or alternating speed states is enjoyable.

## Decisions for the owner after a first skim

- Should all kits share the permanent autonomous gun, or may a kit replace it with a different permanent passive weapon?
- For Marshal, should 1–3 remain distinct relays with slot 4 as a network command?
- Should mirrored casts copy the player's aim direction or converge on the marked target?
- Should Circuit Weaver reward exactly the three pair reactions above, or should R change which reaction is produced?
- During Redline Overdrive, should active abilities remain usable in transformed versions, or should the speed state emphasize steering and modules only?
- Are the tentative kit names useful, or should naming wait until the mechanics survive a playtest?
