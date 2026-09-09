# Ability direction and owner feedback · 9 September 2026

Status: **owner notes for future research, design and playtesting; not implemented behavior.** These notes were made from the text descriptions while away from the playtesting computer. Abilities 1–8 have initial feedback; abilities 9–49 remain unreviewed. Preserve the distinction between description-based expectations and hands-on experience.

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

## Pending review

Abilities 9–49 have no new owner verdict in this note. Do not infer approval, rejection or requested changes for them. Continue the numbered review from ability 9 when the owner returns.
