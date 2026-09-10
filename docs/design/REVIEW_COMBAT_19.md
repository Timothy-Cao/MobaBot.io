# Deliberate combat · 10 September human-review revision

Follow-up override: [0.19.1 progression research and implementation](PROGRESSION_RESEARCH_20.md) supersedes this document's deferred mastery/regen status and its W reference table. New runs have a unified tree; numerical cards, delayed EMP and timed overload are implemented. The original 0.19 decisions below remain historical evidence.

New expeditions opt into `review19`, build family `vanguard-19-deliberate-combat`. Existing checkpoints keep their previous rules and learned tools. Primary Practice uses the new combat rules; Legacy laboratory remains a compatibility tool. No player collection reset, new bitmap assets, music replacement or multiplayer work.

## Approved decisions

Owner approved three successive choose-one-of-three core upgrades per level, removal of chest skill points, removal of the all-rank-five gate, and module purchases after every round using run-only credits. EMP suppresses D/F and 1234 for three seconds, including ongoing drive/orbit/construct functions; QWER, walking, hammer and autonomous MG stay available.

The main-boss HP experiment is now human-approved. Keep that HP. The priorities are deliberate progression, aimed combat openings, meaningful enemy roles and simpler camp navigation. Owner's positive overall feedback and reservations remain dated in QUALITY_BAR; tests do not raise the ratings.

## Progression and purchases

- Future XP income is one-third of the tested build (one-ninth of the earlier pre-reduction Vanguard baseline). Each level queues three selections. Every selection independently offers up to three distinct eligible Q/W/E/R/D/F/MG/hammer tools; capped tools are excluded. Combat pauses. Remaining choices resume after each selection, with no paid rerolls. Collection remains uninterrupted; queued picks open when combat resumes.
- Chests give their existing 20 credits and equipment rolls, without skill points. No bonus compensation credit is added merely because this new policy removes points. This is significant: the reviewed Stage 1 boss result recorded 71 chests and several rank-10 tools despite being only level 17.
- Orbit/Bulwark/Reserve/Overclock start unowned. Every round-clear screen sells the four existing modules and upgrades. Price is `100 + 65 × current earned rank` (100 to learn; 165 for rank 2; 685 for rank 10). Rank cap 10. Purchases reset on a new expedition, persist in the cleared-round checkpoint, and roll back on failed save. Equipment shops keep their stage-end cadence and persistent ownership.
- The UI has peer Round clear / Build / Mastery / Equipment tabs. During combat, Round clear is unavailable and Equipment is inspection-only. Camp receipts use three columns; six normal reward entries fit in two rows. Very large reward batches retain scrolling rather than hiding rewards. Mastery retains its current tree for this pass.

## Mobility, orbit and combo rules

- Base movement speed 205 → 185 before bonuses. D gross upkeep decreases linearly from 28/sec at rank 1 to 10/sec at rank 10. With baseline 100 energy and 8/sec regeneration, early continuous endurance is `100 / (28 - 8) = 5 seconds`; rank-10 long-run duty cycle is `8 / 10 = 80%`. Other skills, orbit, gear/mastery and supply pickups change those values. D never grants invulnerability. Its existing rank-10 cast-while-driving milestone remains.
- F stores one charge below effective rank 5 and two at rank 5+. Storage does not double recharge generation. Existing cost/recharge and rank-10 landing blast remain.
- Orbit's early per-blade damage is 45% of the tested baseline, growing linearly to full baseline at rank 10. Rotation grows from 3 to 10.2 rad/sec. Near radius grows 34 → 82; far radius 52 → 140. Art reads the actual collision radius. Contact lockouts/blade count still affect realized damage; spin speed is not a linear DPS multiplier.
- W hits apply a non-stacking +50% damage-taken window for one second, after the triggering hit. Center hits stun for 1.1 seconds. Bosses/guardians have a four-second guard against another center stun, preventing two-charge lock chains. The vulnerability visual is a gold outline.
- E ending opens a 1.2-second window for one empowered hammer swing, shown by a short gold ring. The window begins on landing, including wall-stop/rebound completion. That swing has 0.12s startup, 3× baseline damage against role-tagged bosses/guardians and 1.5× against ordinary enemies. Ordinary hammer swings use 90% of the tested baseline. It still requires a commanded attack and actual range/angle contact.
- R descends for one second after release (previously .75), creating a reason to set up with W. Existing shield/second-impact milestones remain. W vulnerability, boss recovery exposure and an E combo can multiply together; the 3× bonus is confined to the deliberate follow-up instead of applied to every boss hit.

## Enemy roles and boss rhythm

Fragile fodder and the praised fast pursuers remain. Basic chargers dash faster (780/sec for .3s); Breachers rush at 950/sec for .38s. Thick Practice-style obstacles replace thin campaign rails. Armored tanks approach at 130/sec before campaign speed and telegraph a directional 125-unit melee sweep. Stationary ranged roles receive a reference W-survival floor; mobile Scattergun/Mender/Bomb carrier roles circle/retreat. Arc lancers lead movement; Bomb carriers place five marked blasts spaced .5s apart.

The slow EMP suppressor has a visible emitter, a 1.1-second warning, a linked 160-unit target area and a wave expanding over .8s. A caught player is suppressed once per wave; the emitter then recovers for six seconds. Suppression pauses construct functions while their lifetimes continue; it does not delete purchased tools or spend charges. Existing projectiles are not retroactively removed.

Main bosses retain HP, use a smaller body (48 radius), and move laterally between attacks. Their cycle includes three nine-shot volleys, a shorter-windup charge, five staggered bombs, a rotating 740-unit laser, a ring with gaps and a melee sweep. Recovery remains a damage opportunity. Adds are bounded by the existing pools. When distant, a visible 490/sec pursuit respects walls and makes blink-over-obstacle escapes relevant. The map stays open; no artificial enclosure or silent teleport was added. Boss arrival darkens the environment beneath actors/tells and lights small amber obstacle markers. Reduced effects retains functional warnings.

## Damage estimates and limits

The human results contain final aggregates, not per-round DPS or boss kill time. Fresh versus Continue was not confirmed. Do not divide the restored total time into partial damage counters and label the result measured DPS.

Reference, no gear/mastery/rarity, full head/center contact:

| Earned rank | W center damage | Ordinary hammer head DPS | E-combo hammer head vs boss |
| --- | ---: | ---: | ---: |
| 1 | 76 | 32.57 | 114 |
| 5 | 121.6 | 54.72 | 182.4 |
| 10 | 250.8 | 118.8 | 376.2 |

These are theoretical values, excluding vulnerability/recovery bonuses, energy, movement and misses. W per-hit growth is 1.6× at rank 5 and 3.3× at rank 10, before recharge/area benefits. The revised progression removes the reviewed chest-driven acceleration; it does not justify blindly multiplying every enemy's HP by three.

Enemy HP floors use a fixed design reference of `min(10, 1 + floor(route_index / 2))` for W rank, independent of the player's actual build. Tank ranged HP is at least 1.3 reference center-W hits; melee tanks 2.1; guardians four. Existing stage/round health scaling can exceed these floors. This is a starting design estimate, not a measured player growth curve or adaptive difficulty. Validate specialist survival against focused upgrades and gear in the next human test.

## Deferred and verification

Broad mastery restructuring and new equipment regeneration bonuses are deferred. Existing same-slot tier stats are strictly increasing and are checked without modifying the collection. No claim that these existing increments now satisfy the owner's sense of payoff. No new boss body asset, arena enclosure, teleport or new summon catalog.

`review_rules_test.gd` covers paused choices, chest accounting, specialization, purchases/rollback, checkpoint ownership, mobility references, EMP scope/expiry, vulnerability/stun guard, combo consumption, boss HP and rendered camp/combat. `-- --render` captures ignored review images. The real-session disappearing-impact polygon error is addressed by rejecting subpixel/degenerate shards before drawing. The rendering fixture exercises late rocket impacts at large world coordinates in both effect modes.

Run the full `scripts/check.ps1`, both refined compatibility probes and the current Vanguard probe/soak. An artificial-health soak proves exercise of the route, never human balance; report its actual terminal state and budget rather than claiming completion if it times out. Final evidence belongs in QA_18 and SESSION_HANDOFF.
