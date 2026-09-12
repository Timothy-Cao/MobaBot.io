# Encounter pressure — 12 September 2026

Owner requests mobile melee tanks, removal of Uplink and EMP, more varied minibosses with counterplay, and a more aggressive final boss. This supersedes those entries in the demo27 roster.

## Current behavior

- Current arsenal melee tanks chase at 90% of the corresponding swarm speed: 97.2/108/118.8 before the shared level/stage movement multiplier. Previous code used 130; the perceived slowness likely involved attack pauses, not low chase speed. Melee recovery is reduced from 1.1 to 0.75 seconds. HP and melee damage unchanged.
- Uplink and EMP suppressor are absent from the current campaign selection and current Practice selector. Historical code remains for compatibility/tests. Mender remains because only Uplink was retired.
- Demo stages gain one roaming miniboss at 3:00: Drift rammer, Bulwark, Drift rammer. These supplement the existing five-minute guardians/final boss. They bypass the ordinary specialist limit but respect the global population cap, retrying until capacity exists before survival ends. Killing one grants an ordinary in-run chest; it does not mark a stage/boss complete. They are also selectable in Practice, which gives no persistent rewards.

| Miniboss | Pattern | Counterplay |
|---|---|---|
| Drift rammer | 0.85s windup, 820-unit/s charge for up to 0.85s; turns at most 0.45 radians/s | Step across its heading, force a wide turn or wall stop; 1.8s recovery |
| Bulwark | Alternates marked dash-spin and outer shockwave with a gapped projectile ring | Leave the spin destination; stand inside the shockwave's 85-unit inner radius or outside 210 units; attack during recovery |

Rammer base HP 650; Bulwark 800, with existing non-boss stage/level scaling. Bulwark takes 55% damage while guarded and 135% during its 1.8s recovery. Shield ring changes from thick blue to thin gold. Spin radius 130; damage tests include player radius. Shockwave boundaries and center-safe tell match hit geometry. Movement respects walls; crowd separation does not shove committed miniboss attacks. Bodies/treads, shield and tells are native art following the existing style; no bitmap asset replacement.

## Final boss

The Level 3 main boss (and current Practice boss) gains four nine-shot fans instead of three, six bombs instead of five at 0.4s spacing, summons every 9s/7s rather than 12s/8s, 25% shorter recovery, and a 0.45s charge tell instead of 0.55s. Its approach decision interval is 0.5s rather than 0.7s. HP, damage per hit, laser rotation and enrage rules remain unchanged. Level 1/2 main bosses retain their previous aggression.

## Review boundaries

Normal/reduced renders and simulation tests check geometry and state transitions, not whether players recognize the new weaknesses. The owner already found Level 3 hard; test these additional encounters before adding further enemy damage or HP. Ordinary active crowds retain soft separation rather than absolute rigid collision.
