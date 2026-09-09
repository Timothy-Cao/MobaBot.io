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

## Proposed focused roster

Keep every existing ability in the project for now; do not delete the wider catalog. Stash abilities outside the focused set so the best candidates can be refined and tested before other options are reintroduced gradually.

- Use the abilities reviewed in this document as the initial active-design set, subject to their individual keep, replace or consolidate notes.
- For movement, initially retain only the two current defaults: Ghost drive and Phase hop.
- Initially surface one default summon. The owner did not name which summon; do not select it without a later decision.
- The owner's home AI should review the powered toggles and select the four strongest designs. That selection is still pending; do not infer the four here.
- Use focused Practice tests to judge feel and purpose after the retained abilities have been refined.

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
