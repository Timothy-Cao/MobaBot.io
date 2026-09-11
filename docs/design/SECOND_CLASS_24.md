# Second-class design: Conductor

0.24 follow-up: a playable Practice-only QWER prototype now exists; see COMBOS_ART_24 for exact implemented behavior and limitations. The proposal below remains design history. Baton, full class balance and campaign availability are not implemented.

11 September 2026. Design proposal, not a playable class. The owner authorized independent exploration after the Vanguard support/art pass. Preserve Vanguard's current kit and campaign. **A future grapple class is explicitly requested**; reserve that identity for a later wall-attachment, reel, swing and release experiment.

## Identity and decisions

Conductor shapes short-lived electrical routes while moving. Vanguard rewards landing impact combinations; Conductor rewards arranging an angle, then deciding whether to preserve that route or spend it. Every skill must remain useful without setup. There is no stationary transformation, mandatory turret camping or passive damage network.

| Input | Proposed action | Decision beyond damage |
| --- | --- | --- |
| Q: Arc bolt | Aimed narrow shot; crossing an owned relay forks once toward the cursor direction. One enemy cannot receive both branches. | Direct accuracy versus a wider prepared angle. |
| W: Relay | Places one of at most two temporary relays. No automatic damage. Oldest expires on a third placement. | Offensive firing angle or a useful future movement route. |
| E: Slip current | A short independent dash with a small departure pulse. Passing close to a relay moves that relay to the departure point. | Dodge, leave an attack behind, or rearrange the route while escaping. No forced snap or teleport. |
| R: Discharge | After a visible delay, strike the line between two relays and consume them. With fewer than two, discharge a shorter aimed line from the player. | Cash out a prepared route or use an immediate fallback and rebuild later. |
| Left click: Arc baton | Short close-range sweep. A recent successful Q grants one stronger sweep, with a bounded boss bonus. | Approach for efficient damage or continue safe ranged pressure. |

Independent gun and D/F remain familiar at first. Reuse the approved support shop, energy, equipment and three-pick progression so the prototype changes one major variable. Relay preview must show actual collision width and expiry. Electrical art uses cream/cyan cores, teal hardware and restrained purple accents; enemy warnings keep their own palette. Pixelated icons follow the same source/import/shader pipeline as Vanguard.

## Initial measurement contract

- Reference rank progression and equipment must match Vanguard for comparisons. Start from equal energy-legal single-target damage over a full 60-second rotation; do not add relay and direct damage twice. The existing analytical benchmark alone cannot establish this.
- A basic direct Q/attack policy should remain viable. Prepared play should earn an initial target of 20–30% delivered damage or coverage advantage, not a several-fold boss multiplier. Tune after measuring rather than treating this target as achieved.
- No recursive forks, repeated hits from the same discharge, offscreen acquisition or passive relay DPS. Each cast has one bounded hit set. Keep player damage and enemy tells readable with both normal and reduced effects.
- E must work with no relays, near walls and while aiming away from a relay. Do not let relay movement bypass body collision or reposition the camera/spawn origin.
- Compare energy spent, moving time, missed damage, boss kill time and unavoidable damage at equal gear. An interesting route must not require standing still long enough to lose every trade.

## Prototype order

1. Isolated Practice experiment for Q/W: two relays, readable previews, single-hit rules and a moving target. No campaign selector or collection writes.
2. Add E and the baton; check whether repositioning is useful without becoming input-heavy. If relay relocation is confusing, replace it with a brief relay charge rather than forcing a complex control scheme.
3. Add R only once the route is understandable. Test one boss and one swarm, normal/reduced effects, before producing final class art or enabling campaign runs.

The next implementation milestone is this isolated prototype. No second class, grapple mechanic, new map or class-selection UI is shipped by 0.23.
