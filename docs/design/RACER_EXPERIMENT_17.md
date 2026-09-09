# Racer Experimental Kit Brief

Status: **owner-approved direction for deep exploration, not a locked final kit and not implemented.** Racer is deliberately more experimental than Vanguard or Marshal. Prove its movement with a small prototype before building a complete ability/module row.

## Core promise

**Racer is a two-speed route fighter:** stable and precise in Cruise, then briefly explosive in Overdrive. The player wins by drawing a good path past danger, correcting it at the right moment and converting that route into damage—not by holding permanent bonus movement speed.

The concept earns a class only if moving itself feels good with MobaBot's mouse controls. More effects, resources or passives cannot rescue unpleasant steering.

## Non-negotiable design pillars

1. **Cruise is real combat.** It has dependable ranged output, precise aiming and defensive control. It is not downtime.
2. **Overdrive is a commitment.** Approximately five or six seconds of speed followed by a similar unavailable period; no permanent refresh loop.
3. **Near-pass, not collision.** Lateral tools damage enemies beside the chassis. Running directly through bodies remains dangerous unless a specific ability says otherwise.
4. **Route quality matters.** A clean curve through several targets should outperform orbiting one boss in a tiny circle.
5. **Speed changes familiar tools.** Q/E/R gain understandable route interactions instead of becoming a separate ten-button kit.
6. **Control and clarity outrank fantasy.** If camera motion, walls or threat reading become worse, reduce speed or change steering before adding safety cheats.

## Movement model to prototype first

Keep the existing MOBA-style right-click/hold steering grammar. During Overdrive:

- acceleration ramps quickly but visibly instead of teleporting to maximum speed;
- holding right-click continuously steers toward the cursor/world target;
- turn response tightens enough to obey corrections but retains a readable wider arc than Cruise;
- E provides the exceptional sharp correction, so ordinary steering need not be either sluggish or perfect;
- thick terrain produces a tangent slide and a short speed loss rather than a long stun or jittering full stop;
- releasing movement input never traps the player in forced forward motion;
- a modest optional camera look-ahead shows more space along velocity, while Reduced effects disables look-ahead and secondary streaking if needed for comfort.

Do not grant blanket invulnerability during Overdrive. The first movement-only prototype should use harmless dummies and obstacle contacts so control feel is judged before damage tuning hides problems.

## Minimum coherent kit hypothesis

| Input/system | Prototype | Cruise behavior | Overdrive relationship |
| --- | --- | --- | --- |
| Permanent system | Stabilized repeater | Reliable automatic pressure independent of movement | Continues unchanged; speed does not create free fire-rate scaling |
| Basic | Kinetic shot | Accurate aimed medium-range hit | Can fire while moving, but a hard turn modestly widens aim/recovery |
| Q | Razor wheel | Straight outward-and-returning disc | Return aims toward Racer's changing position, naturally bending across the route |
| W | Brake lance | Long-range single-target burst with a short honest windup | Stores a capped bonus from distinct near-passes, then rewards the precise Cruise window after Overdrive |
| E | Handbrake sweep | Short close peel and immediate stop/reorientation | Executes a sharp cursor-facing pivot with a lateral sweep; route correction is primary, damage secondary |
| R | Ghost lap | Sends an echo along the last recorded route | Best after a deliberate Overdrive line; echo continues dealing damage while Racer returns to Cruise |
| D | Overdrive | Enters the fixed speed window | Cannot refresh itself or be extended by its own kit |
| F | Vector hop | Short precise emergency reposition | Preserves current movement direction and can correct one bad line without crossing arbitrary terrain |

This is an assistant hypothesis for prototyping, not an owner-approved final table. Keep 1–4 modules out of the first build.

## Why the interactions belong together

- D creates the route.
- Side proximity during that route supplies immediate payoff and a small capped setup for W.
- Q's return path bends because the player moved, producing a visible spatial skill without a special combo rule.
- E fixes one route mistake or makes an intentional sharp pass.
- R repeats a path the player personally authored.
- W gives Cruise a strong purpose: slow down, aim and cash out a successful run.

The kit therefore has synergy without requiring every pair of abilities to create a unique reaction.

## Near-pass rules

Near-pass damage should be a class trait in the experimental slice, not a toggle the player can accidentally leave off.

- Use two truthful side bands, not a hidden circle around the robot.
- Each enemy has a per-source re-hit timer.
- Reward hitting distinct enemies during one Overdrive; do not exponentially multiply damage for crowd size.
- Repeated passes on a boss remain useful but receive no frame-rate or tight-circle advantage.
- Side bands are not touch damage and do not inherit body-contact immunity.
- A clear spark/scrape at the contact side shows which band connected.

If near-pass targeting is visually ambiguous at normal size, abandon the side-band distinction and test a single narrow wake before expanding the kit.

## Cruise must stand on its own

Cruise should contribute roughly half the decision value even if Overdrive contributes more spectacle. Test that the player can survive and make progress using:

- the stable repeater and accurate basic;
- Q as reliable returning ranged damage;
- E as peel/reorientation rather than a useless disabled-mode button;
- W as the deliberate anti-heavy payoff prepared by the prior route;
- ordinary energy recovery and tighter obstacle control.

Do not penalize Cruise with artificially low movement speed. It is the normal chassis state, not exhaustion.

## Anti-degeneracy rules

- Total movement speed has a hard cap across kit, gear and mastery.
- D's cooldown begins after Overdrive ends and cannot be accelerated by D itself.
- Near-pass re-hits use simulation time, not overlap frames.
- Distance/trail sampling uses fixed world spacing, so faster rendering never deals more damage.
- Tight repeated circles around one target cannot be optimal; use target re-hit limits and capped W preparation rather than arbitrary steering penalties.
- Vector hop cannot erase every wall mistake or become a second always-available Overdrive.
- Ghost lap stores a bounded number of path points and has a Reduced-effects representation that preserves damage geometry.

## Presentation direction

Racer should feel **light, aerodynamic and kinetic**, not like Vanguard with brighter particles:

- swept-back panels, visible wheel/runner or stabilizer elements and a forward-weighted silhouette;
- thin directional highlights that stretch with speed, not a large opaque aura;
- a rising motor/air tone on acceleration, lateral scrape accents on near-passes and a heavy decompression/brake cue at the transition to Cruise;
- Ghost lap uses a clean delayed chassis silhouette/path echo rather than foggy full-screen trails;
- Reduced effects retains heading, side-hit geometry and Overdrive start/end, while removing secondary streaks and camera look-ahead.

Astra may help explore a small directional animation set on the home computer. First compare idle/Cruise, acceleration, fast turn, Handbrake and braking at actual combat size before generating a broad asset set.

## Staged prototype with stop gates

| Stage | Build only | Continue only if… |
| --- | --- | --- |
| 1 | Cruise/Overdrive movement, large rocks, harmless markers | Steering is predictable, walls do not snag and camera remains comfortable |
| 2 | Side bands and Handbrake | Near-passes are intentional and E corrects rather than automates routes |
| 3 | Razor wheel | The moving return path is readable and creates satisfying aim choices |
| 4 | Cruise basic and Brake lance | Recovery play feels capable, not like waiting for D |
| 5 | Ghost lap | Replaying a route adds a new decision without unreadable clutter |
| 6 | One module at a time | The module strengthens route play rather than becoming maintenance |

Stop or radically simplify if any of these persist after one focused revision:

- players fight the cursor or lose track of the chassis;
- fast terrain contact creates unavoidable damage or repeated pathing failures;
- optimal play is a tiny circle around the boss;
- Cruise feels like dead time;
- near-pass geometry cannot be explained after seeing it twice;
- Reduced effects removes information needed to steer or judge hits.

## Candidate modules only after the core passes

These are a queue, not a promised 1–4 row:

1. **Coolant wake:** bounded non-stacking trail that rewards long routes through waves.
2. **Kinetic capacitor:** modest shield when Overdrive ends, scaled by distinct targets passed rather than distance farmed safely.
3. **Induction scoop:** wider pickup attraction during Overdrive, useful for collection without directly extending D.
4. **Side-blade tuning:** choose wave-oriented wider bands or boss-oriented narrower stronger bands at a safe build screen, not as constant mode maintenance.

Do not add all four until the class works without them.

## First owner playtest questions

- Did steering fast feel exciting or merely imprecise?
- Could you deliberately pass on one chosen side of an enemy?
- Did Handbrake feel like mastery or an automatic rescue button?
- Did Q's return make your movement matter?
- Were you still making useful decisions during Cruise?
- Would you choose another Overdrive because the route itself was enjoyable?

