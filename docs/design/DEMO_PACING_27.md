# Three-level demo pacing — 12 September 2026

Owner confirmed three selectable Levels, each containing three stages with five-minute survival rounds. Level 3 already feels very hard. This replaces the eight-level menu for new runs, not the player's stored collection or historical checkpoint format.

## Contract

- New campaign runs carry `demo27`; three stages each last 300 survival seconds, followed by the existing guardian/boss and collection phase. About 15 minutes of survival per level, plus fights and decisions.
- Three picks per level-up remain unchanged. Survival XP remains 40/60/80 per stage, now delivered over 300 seconds. Pickup XP and field-credit pickups use 30%/35%/40% of previous values, corresponding to the previous 90/105/120-second durations. Field-credit pickups round to whole credits. End-stage shop grants remain unchanged.
- Pressure surges occur every 50 seconds instead of 17. Ordinary elite chest probability is scaled by the same reward rate to limit longer-round loot inflation. This is a first-pass budget, not a measured guarantee of identical rewards or difficulty.
- Enemy stage/level HP, damage, speed scaling and boss HP/enrage are unchanged. Slower upgrades and longer exposure can still change difficulty; Level 3 requires human review.
- Hatchery base HP rises from 120 to 360 under current arsenal rules (including Practice); ordinary campaign scaling still applies. It is destructible and produces up to four fast runner/chaser enemies every eight seconds, with sixteen living children per Hatchery. Blocked spawn positions and population caps may reduce a wave.
- New-run selection stops at Level 3. Existing Levels 4–8 progress remains valid and old checkpoints can Continue with their prior timing. `demo27` checkpoints validate only Levels 1–3 and retain pacing when resumed. No profile reset or automated rewards.

## Enemy roster

Times below are earliest eligibility in Level 1, not a guaranteed on-screen encounter. Specialists are requested every 30 seconds and share a three-alive cap; occupied capacity can postpone or skip an introduction. Once eligible, they remain in the rotation. Levels 2 and 3 begin with the full roster eligible.

| Enemy | Function | Earliest Level 1 eligibility |
|---|---|---|
| Bumper / swarm | Basic contact fodder | Stage 1, start |
| Fast chaser / runner | Fast pursuit | Stage 1, 0:45 |
| Charger | Telegraph then fast lunge | Stage 1, 1:30 |
| Breacher | Wedge charge | Stage 1, 1:30 |
| Tank | Durable melee pressure | Stage 1, 2:30 |
| Burst battery | Projectile fan burst | Stage 1, 2:30 |
| Arc lancer | Predictive beam | Stage 1, 2:00 |
| Scattergun | Close spread fire | Stage 1, 4:30 |
| Mosquito | Evasive ranged harassment; gun priority | Stage 2, 0:30 |
| Mender | Heals nearby enemies | Stage 2, 1:30 |
| Bomb carrier | Sequential ground blasts | Stage 2, 2:30 |
| Hatchery | Durable fast-chaser spawner | Stage 2, 3:30 |
| Uplink | Healing and decaying speed aura | Stage 2, 4:30 |
| EMP suppressor | Temporarily disables D/F and 1234 | Stage 3, 2:00 |
| Rammer guardian | Charging miniboss | Stage 1, 5:00, every Level |
| Artillery guardian | Ranged miniboss | Stage 2, 5:00, every Level |
| Main boss | Combined attacks, summons, gradual enrage | Stage 3, 5:00, every Level |
| Target dummy | Stationary damage testing | Practice only |
| Legacy heavy shooter | Older base enemy AI | Legacy modes only; not standalone demo roster |

Main boss titles are Gatekeeper (Level 1), Stamp press (Level 2), Coolant keeper (Level 3). Later titles/configurations remain in compatibility data and are not selectable in the demo. These reuse the existing boss body; they are not new assets.

## Verification

`demo_pacing_test.gd` covers timing, survival/pickup budgets, introductions, base-enemy gating, checkpoint preservation/validation, and destructible Hatchery fast children. The level UI test now checks three choices. Current `expedition_behavior_probe.gd -- --vanguard` uses demo pacing for Levels 1–3; `--legacy-pace` retains prior Operations timing and `--chapter=8` remains a compatibility probe.

Full-route artificial-health probes finished Level 1 in 1088.4 seconds and Level 3 in 1172.4 seconds, including fights and collection. Final-boss arrival was at player level 18 and 19 respectively. These are deterministic automated policies, not human balance evidence. Normal-health Level 3 policies died in the first stage; no claim that the hardest level is now easy or calibrated.


## 12 September follow-up - ranged pressure and swarm spacing

Owner requested earlier/farther lasers, bombers that shoot more over time, and individual enemy space rather than stacked sprites. Arc lancer now first becomes eligible at Level 1 stage 1, 2:00 (previously 3:30). Under current arsenal rules, lance reach is 940 instead of 740, visible engagement distance 720 instead of 560, and warning 0.7 instead of 0.8 seconds. Rendering and collision share the same endpoint. Boss lasers are unchanged.

Current bomb carriers issue individual bombs every 0.45 seconds, each with a fresh 1.05-second ground warning aimed around current player movement. Barrage count is capped at eight: 5 + stage index + one after 150 seconds within the stage. Recovery is 3.0/2.7/2.4 seconds by stage. Thus late stages add sustained pressure, not an unbounded damage or projectile ramp. Earlier rule families keep their attacks.

Current arsenal enemies receive soft circular separation using 64-unit spatial buckets, cached movement weights and bounded displacement. Larger bodies yield less. Bosses, dummies and committed windups/charges do not get shoved; neighbors yield around them. Walls and arena bounds constrain every correction. Practice freeze stops spacing. This reduces ordinary crowd overlap rather than promising hard collision during every charge or dense spawn. No player-body collision or friendly-projectile blocking was added.
