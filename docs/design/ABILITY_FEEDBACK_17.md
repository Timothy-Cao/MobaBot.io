# Ability direction and owner feedback · 9 September 2026

Status: **owner notes for future research, design and playtesting; not implemented behavior.** These notes were made from the text descriptions while away from the playtesting computer. Abilities 1–11 have initial feedback; abilities 12–49 remain unreviewed. Preserve the distinction between description-based expectations and hands-on experience.

`QA_17.md` and the root README continue to describe the current build until a later implementation is verified.

## Research request: classify abilities by function

Research how ability roles are normally classified across several game mediums, choose a practical taxonomy for MobaBot.io, and research what gives each type a satisfying purpose and feel. Do not settle the taxonomy from intuition alone.

The owner wants the taxonomy to cover at least these independent dimensions:

1. **Number or shape of targets:** single-target, multi-target and area-of-effect.
2. **Damage delivery:**
   - Damage over time: one application continues to poison, rust or otherwise damage the target.
   - Burst: high immediate damage, normally balanced by a longer cooldown.
   - Sustained DPS: consistent repeated damage, such as the machine gun, commanded basic attack or Impact bolt.
3. **Encounter purpose:**
   - Wave clear: larger area and lower per-target damage for clearing swarming small enemies.
   - Anti-boss: high single-target output or an explicit boss-relevant advantage.
4. **Non-damage roles:** support, utility, crowd control, movement, summons, powered toggles and other passive-like effects also need useful categories.

The result should explain how each category earns a distinct purpose, how it feels good in play, and how categories can overlap without becoming vague labels. Categorization should help balance, loadout construction, discovery rules and communication; it should not imply that every ability needs only one tag.

## Proposed fixed slot identities

The owner is considering less input flexibility and does not currently want players to rebind abilities. Define which ability families may occupy each key:

| Key | Intended role |
| --- | --- |
| Q | Main sustained-damage ability. Low energy cost, relatively short cooldown, medium-to-low damage per use and consistent availability. |
| W | Longer-range ability and/or high-damage burst ability with a longer cooldown. |
| E | Utility, crowd control or another unusual tactical effect. |
| R | Highest-cooldown, highest-impact ability. The exact function may vary, but it must feel significant. |
| 1–4 | Flexible slots; may hold any allowed ability type. |

This is design direction, not permission to remove current binding behavior before the full slot taxonomy and migration/UI consequences are reviewed.

## Ability ownership and stage loadouts

- Do not replace abilities frequently.
- If the player learns another Q-family ability while already carrying a Q, place the new ability in inventory instead of forcing a replacement.
- Let players choose a loadout from their learned ability inventory so they can tailor a build for a stage or boss where they are stuck.
- Work out when and where loadouts can change, how current ranks/rarities are preserved, and how this interacts with run-only progression before implementation.

## Non-interrupting skill progression proposal

The owner wants leveling to create frequent rewards without repeatedly stopping combat. Remove modal ability-learn and ability-upgrade popups from the proposed flow.

While at least one ability remains locked, alternate XP level rewards between two homogeneous event types:

1. **Upgrade event:** choose one already-owned, non-maxed ability and increase its rank.
2. **Learn event:** choose one locked ability, represented as rank 0, and raise it to rank 1.

Never mix locked and already-owned abilities in the same choice. A given reward should ask one clear question—either which existing ability to improve or which new ability to learn. Once every ability has been learned, subsequent eligible rewards can remain upgrade events.

The proposed interaction is non-modal:

- Eligible already-owned abilities display a small level-up indicator on or immediately above their ability control.
- The player may click that indicator or use **Ctrl + the ability's assigned key** to spend the pending upgrade.
- Locked abilities appear as rank-0 choices during a learn event and use the same general level-up interaction to become rank 1.
- Combat continues while a reward is pending; there is no full-screen selection interruption.
- The UI must distinguish “upgrade an equipped ability,” “learn a stored ability” and ordinary ability activation so a click or shortcut cannot cast or rearrange a skill accidentally.

Learning does not authorize a combat-time loadout replacement. A newly learned ability enters the player's learned inventory/storage. If its fixed family is already occupied—for example, a new Q when Q is equipped—it may be fitted only at a safe between-phase arrangement point. The intended rhythm is to handle these loadout changes after stages rather than displaying a replacement popup during play.

This proposal is intended to support somewhat faster XP gain and a higher frequency of rewarding moments without the previous flow interruption. Increase XP only after the non-modal interaction is implemented and tested; reward frequency, unspent indicators and faster leveling could otherwise create visual pressure or input overload.

Details to resolve before implementation:

- Whether pending upgrade/learn rewards stack, and how their order remains clear if the player delays spending them.
- Where all locked rank-0 abilities appear without crowding the combat HUD; they cannot all occupy live ability slots.
- Whether “after stages” means the unlock itself is awarded at stage completion or only that a previously learned skill can be fitted there.
- How Ctrl shortcuts work for abilities in storage, summons/modules without a live binding and players using non-keyboard input.
- How the rank-10 maximum, no-eligible-upgrade cases and the transition after the final unlock affect the alternating sequence.
- How the indicator stays readable at normal and reduced effects without competing with cooldown, charge, energy and recast information.

This is future design direction, not current behavior. The current modal timing, discovery, camp arrangement and save rules remain governed by `QA_17.md` until this flow has a full state model, migration plan and verification coverage.

## Permanent baseline machine gun

The player's default autonomous machine gun is a permanent passive system, not a learned or equippable ability.

- It is always owned and cannot be unequipped for now.
- It may still be upgraded through an appropriate progression track.
- It does not occupy Q/W/E/R, D/F or 1–4 and should not appear among rank-0 locked-skill choices.
- It continues firing independently while Ghost drive is active, just like other passive effects.
- It remains separate from the proposed manual left-click hammer attack.

The current catalog's Auto gun/powered-mode implementation needs an explicit migration decision: reuse it as this permanent baseline, preserve optional modes as later upgrades, or keep a separate historical fixture. Do not leave both systems active accidentally or make the permanent gun removable through an old loadout path.

## Default movement refinement: D and F

Keep Ghost drive and Phase hop as the two default movement tools, but give them very different control promises.

### D — Ghost drive

The owner likes the current D direction. Preserve it as the movement-speed tool that the player holds to use. Its important uses include escaping a dangerous situation, quickly crossing open ground and collecting scattered orbs during a safe collection window.

- The hold state should be immediately legible and should end responsively when D is released.
- Preserve the successful current feel rather than adding another attack, collision payoff or complicated combo.
- Keep D distinct from F: D improves movement over time, while F is an instantaneous discontinuous relocation.
- Give the active speed state a visible afterimage effect. It should communicate direction and continued movement without implying a damaging trail or a second body.
- Give D its own movement-speed sound treatment, with a clear start, sustained state and/or end as appropriate to the final hold implementation.
- While D is active, block manual basic attacks and every active ability. The proposed hammer therefore cannot swing, and Q/W/E/R/F/1–4 actives cannot be cast during the held speed state.
- Do not suspend the permanent autonomous machine gun or other passive effects. Their independent timers and effects continue normally during D.
- Already-active orbit effects and deployed constructs continue if they are persistent/passive, but the player cannot toggle, cast or redeploy them until D is released.
- Confirm the final duration, cooldown, early-release behavior and relationship between the held speed state and current intangibility before implementation; this note does not supply new balance numbers.

### F — Phase hop as a full blink

Refine F so it feels like League of Legends' Flash in responsiveness and terrain interaction. This is a mechanical reference, not permission to copy presentation, assets or unrelated rules.

**Cast-origin buffering:**

- The player may begin an eligible ability cast and then press F within a target window of less than 0.1 seconds.
- F resolves immediately while the ability's windup continues.
- If the pending ability has not released yet, its projectile, sweep, zone or other effect originates from the player's post-blink position.
- The numerical cast time is not necessarily shortened. The player is allowed to begin the windup before blinking, which reduces the time spent waiting at the destination and creates fast Flash–ability combinations.
- The original ability spends its cost and cooldown exactly once. Flash must not cancel, duplicate or retroactively move an effect that already released.

The exact input-window boundary, eligible ability list and aim rule need an explicit contract. In particular, define whether a cast preserves its original world target, preserves its direction, or re-aims from the new origin for each targeting family. Channels, self-casts, movement abilities and the proposed hammer may need different eligibility rules.

**Thick-terrain traversal:**

- F is a true blink, not a dash. The player does not travel through or collide with intermediate space.
- If the requested endpoint is valid walkable space, land there normally, up to the base blink range.
- If the requested endpoint lies inside blocking terrain, compare how far the endpoint penetrates through that terrain along the blink direction.
- When the endpoint is beyond the terrain's halfway point, place the player at the closest valid position immediately outside the far side. This may make the final displacement longer than the nominal blink range.
- When the endpoint has not passed the halfway point, place the player at the closest valid position on the near side rather than carrying them through.
- “Valid position” must include the player's full body clearance, arena bounds and non-overlap with other blocking terrain, not merely a free point for the player's center.

Give F a teleport smoke-poof or similarly abrupt departure/arrival effect so it reads as a blink rather than very fast travel. F also needs its own distinctive teleport sound. The effect must not draw a continuous trail between endpoints because no path is traversed.

Concrete owner example: if the player begins at the near edge of a wall whose thickness along the blink ray is 1.9 times F's normal range, a maximum-range blink ends just past the midpoint. The player should therefore land immediately outside the far edge of that wall, even though the corrected destination is farther than the normal range.

The terrain rule should operate on the connected obstruction crossed by the blink, not become an unlimited search through several adjacent walls. Define a safe failure or near-side fallback when there is no legal far-side landing. This is especially important if the thicker terrain and corridor direction in [`ENVIRONMENT_FEEDBACK_17.md`](ENVIRONMENT_FEEDBACK_17.md) is implemented.

### Required prototype checks

- Ability input followed by F inside the buffer window releases from the post-blink origin.
- F outside the window does not relocate an already-released effect.
- The ability and F each spend their cost/charge once, including rapid repeated input.
- A clear endpoint uses normal range; a near-half endpoint stays on the near side; a past-half endpoint exits the far side.
- Test the owner's 1.9-times-wall example with player-body clearance.
- Corners, diagonal walls, concave shapes, touching obstacles, arena borders and an unavailable far-side destination resolve consistently.
- No transient movement along the blink path triggers body contact, pickups, hazards or on-move collision effects unless a later design explicitly opts them in.
- Visual and audio feedback communicates departure and arrival without drawing a false travel path.
- Inspect the D afterimage and F poof at actual combat scale in normal and reduced-effects modes. Reduced effects may simplify secondary particles but must retain movement state and blink endpoints.

This section records desired behavior only. Current Phase hop range, charge count, cooldown and protection values are not approved or replaced by this note.

## Leading default E proposal: body slam / Piston thrust

The owner proposes refining Piston thrust into the default E: a committed body slam that uses movement to deliver control rather than acting as a general-purpose escape.

### Base behavior

- Target cooldown: approximately 8 seconds.
- Dash rapidly in the aimed direction.
- Give the attack a collision/hit shape that extends slightly beyond the robot's body so a visually convincing near-front contact registers reliably.
- Stop on the first valid enemy contacted and create one circular damage impact centered around the robot.
- Push ordinary enemies in the impact away from the robot.
- Bosses and future heavy enemies resist the push. Formal weight and movement-resistance attributes can be defined later.
- Give the robot a very short protection window against **touch/contact damage only** so committing to the collision does not immediately punish the intended use.
- Projectile, poison, ground-zone and other non-touch damage continue to work during that base protection window.

The body slam should use a speed/air-resistance presentation—such as compression, streaking or an atmospheric-entry-like envelope—to communicate force during the dash. It also needs a distinct launch and impact sound. The effect should sell speed without implying that nearby enemies take fire damage before the actual collision.

### Rank milestones

- **Rank 5:** add the brief impact stun. This supersedes the earlier note that Piston thrust should always stun at base rank.
- **Rank 10:** upgrade the commitment protection into an explicit full-immunity shield for the entire dash and for 1 second after impact.

The rank-10 shield should be visually unmistakable and mechanically separate from the base touch-damage protection. Define what happens when the dash misses, hits terrain or is otherwise interrupted; “1 second after impact” currently names the successful enemy-impact case only.

### Damage-source rules required by this proposal

Damage sources should carry explicit types rather than relying on one global invulnerability rule:

| Damage type | Intended interaction with base body slam |
| --- | --- |
| Enemy body/touch | Suppressed during the short contact-protection window |
| Projectile | Still damages normally |
| Poison / DoT | Continues on its own tick rules |
| Ground zone or enemy ability | Still damages unless explicitly tagged as touch damage |
| Rank-10 full shield | Suppresses every damage type for its stated duration |

Touch damage also needs its own repeat-hit cooldown or grace policy so several overlapping bodies cannot drain the player's hull many times in one instant. Projectile hits and poison ticks should not consume or inherit that touch-damage cooldown. Decide whether touch grace is tracked per attacking enemy, per player or through another bounded policy; a single broad global invulnerability timer could accidentally erase legitimate projectiles after a body hit.

### Assistant assessment for owner review

This is currently the strongest default E candidate if the goal is immediate feel and a clear tactical verb. It creates a readable sequence—aim, commit, collide, push—works naturally with the proposed close-range hammer, and differs from D/F because it should stop on enemies and should not cross terrain. Moving the stun to rank 5 and full immunity to rank 10 gives both milestones a visible change.

Its main risk is mobility overload: the base kit would have speed on D, blink on F and a third movement action on E. Keep the slam short, enemy-collision-focused and committed so it is a poor substitute for escaping. It also should not receive high damage, long stun, strong push and broad safety simultaneously.

The best non-overlapping E alternatives remain:

| Candidate | What it teaches | Why it is not the leading default right now |
| --- | --- | --- |
| Repulsor | Immediate peel and space creation | Clear and safe, but less expressive and less connected to the hammer's positioning game |
| Gravity well | Grouping and setup for other abilities | Strong combo tool, but slower to explain and overlaps the default summons' area control |
| Bulkhead | Defensive terrain and route control | Distinctive, but highly dependent on pathfinding and the unfinished terrain redesign |
| Self repair | Create safety, then channel recovery | Good risk/reward, but starts the player with sustain rather than an active combat interaction |
| Crosswire | Pre-plan a control line | Interesting setup, but overlaps the proposed paired robots on slot 4 |

Recommendation: prototype body slam as the default E first, with Repulsor as the simplest comparison option. Treat this as an assistant recommendation awaiting owner confirmation and a human Practice test.

## Current owner proposal for default 1–4 modules

The latest owner direction replaces the earlier idea of an initial module pool built around one summon plus four assistant-selected powered toggles. The current proposed default mapping is:

| Key | Default concept | Primary purpose |
| --- | --- | --- |
| 1 | Orbiting tools | Player-centered positional offense with two orbit modes |
| 2 | Aggressive summon | Sustained damage, local AoE and limited aggro diversion |
| 3 | Healing totem | Stored recovery with overflow conversion |
| 4 | Paired zap robots | Two-point line damage and active redeployment |

These are design notes, not final names, numbers or implemented assignments.

### 1 — orbiting tools

- Start with tools orbiting close to the player at high speed.
- Toggling changes them to a wider, slower orbit.
- The close/fast and far/slow states should create a positional choice rather than being cosmetic variants.
- This concept should build from Scrap orbit, but its contact damage, target rules, energy cost and toggle cadence still need design.
- Show the active radius and mode through the orbit itself; avoid a persistent large range overlay during ordinary play.

### 2 — aggressive summon

- Deploy a robot or construct that attacks nearby enemies with a weak machine gun.
- It also pulses for low local area damage.
- Enemies may target and destroy it.
- Give it enough durability to survive briefly and make placement meaningful rather than disappearing immediately.
- It draws enemy aggression within a smaller range than the player's normal aggro range. The intent is useful local distraction, not a full-arena taunt.
- Its gun, pulse, health state and aggro draw need separate readable feedback.

This combines parts of Line sentry and Pulse anchor into a new default concept. Whether it replaces those entries, packages them, or leaves them stashed is an implementation decision for a later pass.

### 3 — healing totem

- Deploy a non-aggressive healing structure.
- It stores healing energy while the player is away, up to a cap. “Away” is the current interpretation of the owner's wording because the stored value resolves when the player returns; confirm this before implementation.
- When the player returns to its activation area, spend the stored value to restore missing hull.
- Convert healing beyond full hull into energy.
- If that conversion would exceed maximum energy, convert the remaining overflow into a small damaging shock wave.

The conversion order should remain explicit: missing hull first, then missing energy, then a small shock wave. Caps and conversion rates are unresolved. Prevent feedback loops in which the shock wave, pickups or another totem recursively generate more stored healing.

This is a rework direction for the Repair anchor concept, replacing a simple continuous healing aura with a leave-and-return rhythm.

### 4 — paired zap robots

- Deploy the first robot, then place its partner within four seconds.
- Once paired, they zap enemies in the space or line between them.
- Their main decision is the angle, separation and timing of the two placements.
- Clearly show the first robot's four-second pairing window, the valid second-placement area and the damaging connection.
- Define what happens if the second robot is not placed in time without spending an invisible or unusable deployment.

This resembles Crosswire's current two-endpoint structure but changes the fantasy to a persistent robot pair. Decide later whether it replaces Crosswire, becomes its module version or shares only the underlying placement code.

### Targeting, expiry and active redeployment

- The aggressive slot-2 summon is the aggro-drawing, targetable and killable exception.
- Deployables that do not draw aggro should not be targetable or killable. Under the current mapping, this clearly applies to the slot-3 healing totem and slot-4 robot pair; orbiting tools remain attached to the player rather than becoming enemy targets.
- Non-aggro deployables expire after a finite lifetime.
- If one expires naturally, the player waits 10 additional seconds before deploying it again.
- If the player redeploys it before expiration, move or replace it and reset its lifetime timer. This lets active management maintain the effect and encourages repositioning.
- A redeploy must be visibly different from placing an additional copy. Old collision/effects should end cleanly, and summon-capacity accounting must not leak an extra entity.

Still unresolved: lifetimes, placement range, energy costs, the aggressive summon's death cooldown, whether redeployment itself has a short input cooldown, what happens to stored healing on a moved totem, and whether both slot-4 robots move together or are placed again as a new pair.

## Proposed focused roster

Keep every existing ability in the project for now; do not delete the wider catalog. Stash abilities outside the focused set so the best candidates can be refined and tested before other options are reintroduced gradually.

- Use the abilities reviewed in this document as the initial active-design set, subject to their individual keep, replace or consolidate notes.
- For movement, initially retain only the two current defaults: Ghost drive and Phase hop.
- Use the latest owner-proposed default 1–4 mapping above: orbiting tools, aggressive summon, healing totem and paired zap robots.
- Preserve the earlier research recommendation—Pulse anchor plus Coolant trail, Arc coil, Auto gun and Life converter—as historical design analysis, not the current default-loadout direction. Its principles may still help refine or offer later alternatives.
- Use focused Practice tests to judge feel and purpose after the retained abilities have been refined.

See [`ABILITY_TAXONOMY_RESEARCH_17.md`](ABILITY_TAXONOMY_RESEARCH_17.md) for the reasoning behind those recommendations and the audit of abilities 12–49.

"Stash" means preserve the implementation and data while removing an ability from the initial player-facing test/selection pool. Exact availability, migration and unlock behavior still need design before implementation.

## Initial ability feedback

### 1. Impact bolt

**Verdict:** good. This is a fun, classic bread-and-butter ability and should remain the default Q.

### 2. Welding torch

**Verdict:** currently feels weak and looks underwhelming from the available impression. It should not be the default E for now.

- Follow the direction the player is facing, interpreted here as the direction in which the player is walking.
- Base duration: 3 seconds.
- Rank 5: 6-second duration and a wider cone.
- Rank 10: 8-second duration and greater reach.
- Target cooldown: 10 seconds, making it nearly continuously available at maximum rank.
- Improve its visual presentation and perceived impact.
- The owner referenced Rumble as the feel/directional model to research; do not copy unrelated mechanics or assets.

### 3. Reactor drop

**Verdict:** sounds good as an ultimate and should be the default R.

- Rank 5: if the player is inside the affected area, grant healing and movement speed.
- Rank 10: cast twice in quick succession and stun enemies caught in it.

The exact healing, speed, stun, timing and stacking rules remain to be designed and tested.

### 4. Return blade

**Verdict:** if this is the current boomerang-like ability, the present version was not enjoyable. It could become a W option.

- Pass through enemies.
- Travel farther.
- Use a larger, more readable blade.
- Move more slowly so player movement has a stronger effect on its return path.

### 5. Gravity well

**Verdict:** the idea is liked. Its main job should be grouping enemies for other abilities, not dealing damage.

- Reduce damage to approximately 3 damage per second.
- Rank 5 and rank 10 should increase radius and duration.
- At rank 10, root and slow bosses so they cannot dash or blink out of the field.
- Keep a reasonably long cooldown.

The distinction between a boss root, slow and movement-skill lockout needs explicit rules before implementation.

### 6. Core strike

**Verdict:** if this is the Xerath-W-like center-payoff strike, it is a strong ability and should become the default W.

- Rank 5: store three charges.
- Rank 10: store four charges, gain longer range and enlarge the high-damage center.

### 7. Crosswire

**Verdict:** sounds good as an E option; hands-on testing is still needed.

The owner also suggested possibly moving it into the passive-like family, which may later be renamed or reorganized around summons and toggles. This is unresolved and should be considered during the taxonomy research.

### 8. Repulsor

**Verdict:** suitable as an E option.

- Remove the additional planted-plate projectile interaction; focus the ability on shoving enemies away.
- Rank 5: wider cone.
- Rank 10: affect bosses and add a stun.

### 9. Guard sweep / proposed hammer swing

**Verdict:** replace the current Guard sweep concept with a large hammer swing, and consider making the hammer the player's default basic attack instead of the regular commanded shot.

- A visible hammer appears and sweeps through an approximately 90-degree arc in the chosen direction.
- The hammer head is the meaningful sweet spot: it deals extra damage, pushes enemies and briefly stuns them.
- The longer handle deals little damage and does not push enemies.
- The difference between the head and handle should reward deliberate player positioning.
- Treat this as a melee basic attack. Left-click swings in the cursor direction.
- Briefly pause movement while committing to the swing.
- Initial cadence target: one swing every 2 seconds.
- The hammer should be large enough, and its damage high enough, for each slower hit to feel meaningful.

This proposal changes the current basic-attack and mouse-input contract. Before implementation, resolve how left-click swinging coexists with aimed casts, UI interaction, attack move and the independent powered Auto gun. "Auto attack" here means the player's repeatable basic attack, not an attack that fires without input.

### 10. Rim cutter

**Verdict:** its separate purpose is unclear. Consolidate its useful role into Repulsor rather than presenting it as another overlapping close-range sweep.

Keep the existing ability implementation stashed for now rather than deleting it. The owner did not specify whether its outer-rim damage or healing should survive the consolidation; do not assume either mechanic carries over.

### 11. Piston thrust

**Verdict:** liked if it functions as a committed body-check ability, comparable in broad intent to Gragas E.

- Always stun enemies hit by the thrust.
- While executing it, contact with non-boss enemy bodies should not damage the player.
- Enemy abilities and projectiles can still damage the player during the action.
- Contact after the ability finishes can damage the player normally.
- When the thrust hits an enemy, grant a short invulnerability window to prevent immediate body-contact damage.

The invulnerability duration, boss interaction, collision rules and distinction between body damage and ability damage require explicit design and tests. The external reference describes the desired body-check feel; do not copy unrelated mechanics or assets.

The later [default E proposal](#leading-default-e-proposal-body-slam--piston-thrust) refines and supersedes parts of this initial note: approximately 8-second cooldown, base push with touch-only protection, stun added at rank 5, and full dash-plus-one-second immunity added at rank 10.

## Pending review

Abilities 12–49 have no new owner verdict in this note. Do not infer approval, rejection or requested changes for them. Continue the numbered review from ability 12 when the owner returns.
