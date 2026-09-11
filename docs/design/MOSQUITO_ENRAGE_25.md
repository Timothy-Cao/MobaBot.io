# Mosquito and gradual enrage · 0.25

11 September 2026. Owner requested an evasive, fragile ranged threat as a reason to invest in the independent machine gun. Their completed milestone direction is **level 5: +25% range; level 10: pierce up to three enemies total**. They clarified that dodging is movement, not immunity: well-placed, overlapping or point-blank attacks should still land. They also authorized enrage starting at one minute and ramping gently, for calibration through play.

## Implemented enemy

Mosquito is a small steel-winged needle drone, selectable in Practice → Enemies. It orbits approximately 310 units from the player at 420 units/sec and uses 720 units/sec when escaping a detected threat. HP is `10 × (1 + 0.22 × (Level - 1)) × (1 + 0.15 × round_index)`; its radius is 12. It is explicitly excluded from the tank/ranged W-survival floor. It fires a small hostile shot every 1.8 seconds while visible and within 500 units.

Every 0.1 seconds it evaluates sixteen escape directions and its preferred orbit direction over a 0.16-second horizon. Candidate movement respects arena/body-wall collision. It scores visible Q/projectile paths, W/R circles and the active E path, favoring escaping covered space while staying outside hammer reach. There is no future-input reading, teleport, damage immunity or guaranteed perfect avoidance. Multiple zones are evaluated together; if no clean exit exists it takes the least-covered option and remains hittable. Stun and gun knockback still apply. An Anchor can still draw it, like other ordinary enemies.

The first Level-1 round is unchanged. From round two (or Level 2 onward), every third specialist opportunity is a Mosquito; Levels 3 and 6 use every second opportunity. The existing specialist/enemy cap remains, so this varies composition without unbounded extra spawns. All rounds still use their normal survival timing. The native silhouette works in normal/reduced effects; no bitmap generation or collision-size inflation.

## Machine gun

Current support-rule runs use 340 base range and 425 at rank five. Rank ten gives **two pierces, three total hits**, on every shot. The prior every-fifth-shot double damage/extended reach is removed for these runs, including its obsolete HUD counter. Existing rank damage/fire-rate progression remains. The gun now fires during movement at every rank, so rank five's utility milestone is range rather than unlocking mobile fire.

It prioritizes in-range Mosquitoes, then falls back to ordinary acquisition. Shots travel at 2600 units/sec with no random spread. A shot aimed at a Mosquito tracks that target until its first collision, then continues through the remaining pierce budget. This is a reliable counter rather than an enemy immunity bypass: range, lifetime, target death and intervening enemies still matter. Other friendly abilities can kill the drone if their geometry catches it. Old non-support-rule checkpoints retain historical gun milestones.

Upgrade cards, hover information and the analytical balance reference now use these gun rules. Piercing is not counted as extra single-target boss DPS. The benchmark still is not a legal executed rotation or balance acceptance.

## One-minute enrage

Current support-rule bosses start overtime at 60 seconds after the survival segment. Damage is continuous at the threshold, then increases by **0.5× per minute**, capped at 5×: 1× at boss minute one, 1.5× at minute two, 2× at minute three. Additional rotating gapped rings first appear 30 seconds into overtime, then accelerate from roughly six-second spacing toward a two-second floor. Recovery shortens gradually over three overtime minutes toward 0.6 seconds. Existing low-health aggression remains. No boss-HP change or scripted instant loss.

Earlier checkpoint rule families retain their prior deadlines and steep ramp. Practice disables boss overtime. This is an initial testable curve, not a calibrated difficulty claim. Review whether the first minute feels purposeful and later pressure remains readable.

## Verification

`mosquito25_test.gd` verifies base/milestone gun range, exactly three actual piercing hits, lack of old double damage, target priority, a tracking hit against a moving drone, escape from an isolated W, point-blank vulnerability, stage variation and continuous enrage scaling. `-- --render` captures actual-size normal/reduced combat. Full regression includes the fixture; detailed outcomes and probe caveats are recorded in QA_18. Raw test outputs remain ignored; no player saves/rewards are written.
