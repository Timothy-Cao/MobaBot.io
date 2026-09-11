# 0.26 · Arsenal and support enemies

11 September 2026. Owner-authorized follow-up to 0.25. Applies to new runs and primary Practice (`arsenal26`); old checkpoints retain their prior rules. Build tag: `vanguard-26-arsenal-support`.

## Vanguard

- E keeps 209 unfueled travel and rank-one impact damage. Recharge improves from 8 to 6.2 seconds before equipment/mastery cooldown bonuses. Rank five retains the impact stun; rank ten stores four charges. No E shield. Q fuel still adds 110 travel per ordinary Q charge, once per E.
- Arena boundaries now support the same single rebound as internal terrain. Corners reflect both axes; a second collision ends the cast.
- Press E during E to queue one further cast aimed at the selected world point. It consumes a charge and energy only on arrival; an unavailable cast is discarded. Repeated inputs replace that one queued aim. Buffered hammer resolves before a queued E. Flash arrival also resolves buffers.
- E/hammer spin accepts an in-flight buffer or a click within 0.1 seconds after arrival. An accepted buffered spin commits despite a previous hammer cooldown. Spin damage is 15% higher than the existing combo calculation; ordinary hammer is unchanged. Gold/white arc plus restrained teal motion accent; reduced effects removes the secondary accent.
- Slot 4 replaces Energy reserve with Missile Barrage: 60-second activation recharge, eight seconds, unlimited small Q rockets paced at 0.3 seconds, **5 energy per rocket**. Activation retains the existing module energy cost. Rockets preserve ordinary Q stocks; E fuel still consumes real stocks. EMP suppresses Barrage while its timer continues, leaving normal Q available.
- Each mini rocket deals 24% of Q direct-plus-blast damage, growing to 27% with module rank; 60% blast radius and no Q rank-ten aftershock. Twenty-seven perfectly paced shots deal approximately 110–124% of an equal-rank R's complete damage, before target-specific modifiers, costing 135 shot energy plus activation. This is a ceiling, not a resource-legal boss DPS measurement. Energy starvation, misses and differing Q/R ranks change the comparison.

## Enemy pressure

11 September Mosquito follow-up: double HP on these rules (20 base, same scaling) and at most four alive through normal spawning, additionally subject to the shared ranged cap. Explicit Practice spawning bypasses population limits for stress tests. Dodge planning retains 17 directions/100ms, staggered across frames; clear candidate paths skip repeated four-unit collision sweeps, falling back to the original solver near obstacles/arena edges.

Visual follow-up: Barrage (owner calls it Missile Frenzy) uses the same Q rocket hull, fins and exhaust at 75% visual scale. This replaces the initial bolt-like mini-projectile drawing; damage, collision and cadence are unchanged.

- Hatchery: four pursuing runners per eight seconds, valid nearby spawn points only; 16 living children per hatchery plus global population limits.
- Uplink: 280-radius aura heals other enemies at 2% maximum HP/second capped at 12 HP/second. Grants 30% movement speed, linearly decaying over three seconds outside. Multiple auras refresh rather than stack; no self-healing. Includes bosses. Movement remains wall-respecting.
- These specialists enter after Level 1's first round and remain in later Levels; their native silhouettes are also selectable in Practice.
- Boss sweep retains its windup and hit cadence but rotates a full 360 degrees in four seconds. Boss health and gradual enrage are unchanged.

## Verification and next review

`tests/arsenal26_test.gd` covers firing cadence/resources, EMP fallback, E reach/damage/recharge/storage, buffers, arena rebound, checkpoint compatibility, spawning caps, aura healing/movement/decay and full boss sweep. Optional `--render` captures normal/reduced effects without persistent saves. Full regression includes this suite. See QA_18 for execution evidence.

Human priorities: chained E aim/Flash timing; whether 5-energy rockets leave enough mobility; whether support enemies create useful target choices; whether the laser sweep feels fair. No new human balance or fun rating is implied.
