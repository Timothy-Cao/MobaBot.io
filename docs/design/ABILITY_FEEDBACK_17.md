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

## Default movement refinement: D and F

Keep Ghost drive and Phase hop as the two default movement tools, but give them very different control promises.

### D — Ghost drive

The owner likes the current D direction. Preserve it as the movement-speed tool that the player holds to use. Its important uses include escaping a dangerous situation, quickly crossing open ground and collecting scattered orbs during a safe collection window.

- The hold state should be immediately legible and should end responsively when D is released.
- Preserve the successful current feel rather than adding another attack, collision payoff or complicated combo.
- Keep D distinct from F: D improves movement over time, while F is an instantaneous discontinuous relocation.
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

This section records desired behavior only. Current Phase hop range, charge count, cooldown and protection values are not approved or replaced by this note.

## Proposed focused roster

Keep every existing ability in the project for now; do not delete the wider catalog. Stash abilities outside the focused set so the best candidates can be refined and tested before other options are reintroduced gradually.

- Use the abilities reviewed in this document as the initial active-design set, subject to their individual keep, replace or consolidate notes.
- For movement, initially retain only the two current defaults: Ghost drive and Phase hop.
- Initially surface one default summon. The owner did not name one; the later research document recommends Pulse anchor as an assistant proposal pending owner review and playtesting.
- The later research document recommends Coolant trail, Arc coil, Auto gun and Life converter as the four strongest initial powered toggles. This is an assistant recommendation, not a recorded owner verdict.
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

## Pending review

Abilities 12–49 have no new owner verdict in this note. Do not infer approval, rejection or requested changes for them. Continue the numbered review from ability 12 when the owner returns.
