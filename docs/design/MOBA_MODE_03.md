# MOBA control iteration — slice 03

September 8, 2026. Implementation decisions, not a claim of finished balance.

## Direction

One main game: an open-workshop survivor with mouse-directed movement and a MOBA-style kit. No WASD in this mode. Preserve the older sample and model regressions, but remove the bolt-only comparison from the player-facing menu.

The player controls one salvager, not an army. Four automatic passives establish a baseline; three regular actives and an ultimate add decisions. Speed, blink/dash and a summon are optional tools, not mandatory damage-rotation buttons. Equipment is freely configurable before a run. Nothing needs an account, subscription or online generation during play.

## Research and what we borrowed

- [League's official introduction](https://www.leagueoflegends.com/en-us/how-to-play/) describes Q/W/E/R champion abilities, an ultimate and separate D/F summoner spells. Borrow the recognizable input grouping, not its exact champion kits, five-player lane structure, progression or artwork.
- [Ahri's official champion page](https://www.leagueoflegends.com/en-us/champions/ahri/) describes a dash that fires at nearby enemies and supports multiple casts. The useful principle is combining repositioning with accessible damage. Our Ram strike is a directional collision attack, while Phase hop is a separate non-damaging mobility tool. No names, visuals or exact kit are copied.
- [Valve's historical Mistwoods update](https://www.dota2.com/mistwoods?c=EUR&l=english&partner=0) documents examples including a movement-enhanced Blade Fury with nearby automatic attacks, vector targeting for Ice Wall, and Forged Spirit unit-count changes. This is historical evidence of design patterns, **not current balance guidance**. It informed our moving damage aura and companion experiments. Our repair beacon is intentionally stationary and cannot be independently micro-managed; that restriction is our design choice.

Design inference: shared mechanical grammar helps an experienced MOBA player learn quickly, while charge storage reduces the penalty for holding an ability. Positional or narrow attacks can have higher potential payoff without requiring everyone to play mechanically. These are hypotheses to test, not evidence that one preset is objectively more fun or that these are ranked fan favorites.

## Input contract

| Role | Default | Behaviour |
|---|---|---|
| Movement | Right mouse | Click a destination or hold to update; camera follows |
| Stop | S | Clear the mouse order immediately; holding RMB cannot restart it until a new click |
| Four passives | P1–P4 labels | No activation keys; number keys remain available for rebinding |
| Three actives | Q / W / E | Instant quick-cast at cursor, nearest target or self, depending on ability |
| Ultimate | R | Never restarts the run |
| Speed | D | Full throttle |
| Blink / dash | F | Mobility, with stored charges |
| One summon | T | Stationary deployment; replaces the previous summon |
| Aim indicator | Shift + hold ability | Preview; release the ability key to cast. Esc or right-click cancels |
| Inspection | Tab | Pauses; Upgrades / Stats / Abilities |
| Pause | Esc | Also automatic on focus loss |

All seven ability bindings accept unique letter/number keys. Assigning an occupied key swaps its previous binding, so no ability becomes inaccessible. S and M remain reserved; Tab, Escape and F2 are system keys. R/D/F describe default keys and fixed slot **roles**, not immovable physical bindings. Loadout changes do not turn an ordinary active slot into a second ultimate. Numeric keys select level-up cards only while that menu is open; they do not cast through it.

Movement has no turn-rate delay, acceleration curve or overshoot. Casts do not lock ordinary movement. Dashes move over 0.18 seconds; blink is instantaneous. The open floor has no collision obstacles or pathfinding yet, so this is not a claim of complete League/Dota navigation parity. Destination and ability range clamp to the arena.

## Equipment and starting numbers

Data lives in `src/salvage/moba_kit.gd`; keep tooltips and implementation in agreement.

| Ability | Role / targeting | Starting effect | Recovery |
|---|---|---|---|
| Homing salvo | Regular / automatic target | 5 seeking shots over 1 sec, 4 damage each; acquisition 440 | 1 charge / 8 sec, max 3 |
| Shock ring | Regular / self | 9 damage, 155 radius, knockback | 7 sec |
| Safety shell | Regular / self | Block one hit within 4 sec | 12 sec |
| Rail spike | Regular / narrow line | 10 damage, up to 4 targets, 620 travel | 1 / 8 sec, max 3 |
| Scrap mortar | Regular / ground | 16 damage, 90 radius after 0.55 sec, 380 cast range | 8 sec |
| Ram strike | Regular / movement | 12 damage once per enemy crossed, 170 dash distance | 1 / 9 sec, max 2 |
| Overdrive | Ultimate / self | 5 sec of 5-damage rings twice/sec, radius 180, +25% speed | 28 sec |
| Foundry lance | Ultimate / aimed line | 55 damage, width 56, up to 620, 0.4 sec telegraph | 28 sec |
| Full throttle | Speed / self | +65% speed for 3 sec | 14 sec |
| Phase hop | Mobility / cursor | Blink up to 185; brief protection | 1 / 8 sec, max 3 |
| Skate jets | Mobility / direction | 220 dash distance; travel protection | 1 / 6 sec, max 2 |
| Bolt sentry | Summon / ground | 18 sec turret; 3 damage every 0.6 sec, 300 attack range | 10 sec |
| Repair beacon | Summon / ground | 18 sec beacon; heal 1 hull every 5 sec while within 100 | 14 sec |

Charges start full and refill **sequentially**, not all together. Cooldowns pause with all menus. Invalid casts don't spend a charge. No mana system in this pass. Heavy bolts also scales Salvo and Rail; Shock ring scales with Pulse rank. D and R speed bonuses add. Pylon and turret share the single summon slot.

Relaxed: Salvo / Shock ring / Shell / Overdrive / Throttle / Phase hop / Sentry / Scout.
Precision: Rail / Mortar / Ram / Lance / Throttle / Skate jets / Sentry / Drone.

Six passive choices, exactly four equipped: Auto bolt (310 range), Scrap orbit, Collection pulse, Ricochet, Long reach (+45 pickup radius), Reactive plating (+0.65 sec post-hit invulnerability). Ricochet requires Scrap orbit. Both presets start with the first four. Pulse and Ricochet work at rank zero when equipped, then improve through run upgrades. Unequipped passive upgrades are excluded from offers. No hidden fifth passive activates from a level-up choice.

One pet: Scout attracts nearby scrap, Drone fires automatically, or None. No pet key. The summon expires but is not enemy-targetable in this prototype; vulnerability and threat targeting are intentionally deferred.

## Rewards and power fantasy

Ordinary kill: 1 scrap. Fast charger: 6. Tank: 12. Foreman: 48 plus one hull. Each reward becomes a visible pickup, scatters outward for roughly a quarter-second, then becomes collectible. Attraction accelerates; collected scraps replenish orbit tools and charge pulses. Pickup audio climbs in pitch during a collection streak. Enemy danger stays coral/plum; rewards stay brass-gold; friendly casts stay teal/cream.

Hard cap: 180 pickup objects. Excess reward merges into the nearest existing pickup without losing XP. Rewards are claimed once before effects trigger, avoiding duplicated rewards or recursive pickup loops. A boss shower is bigger than an ordinary kill, but does not overwhelm the screen with hundreds of independent objects.

The first simulation exposed off-screen auto-gun kills delaying collection. Restricting its acquisition range to 310 moved combat and drops closer. Additional manual Salvo range remains a deliberate choice. Automatic bots can still waste self-area ultimates while enemies are distant; their totals are not a fair skill-tier balance comparison.

## Art, scope and next human test

See `ART_STYLE_SCHEMA.md` for palette, material language, silhouette rules and reusable prompt templates. Reuse the seven existing illustrations, add function-specific glyphs, align code-authored companions and tools to the same material colours. This does not claim pixel-perfect rendering parity between painted inventory art and simplified small world actors.

This remains a 90-second feel slice with an optional late boss, not a finished roguelite or PvP MOBA. All equipment is unlocked. No permanent skill tree, rarity inventory, campaign, network play, obstacles, mana, attack-move command, animation cancelling, music or release packaging is implied. Balance and human enjoyment remain unvalidated.

First feedback, together after a run: does right-click/stop feel responsive; can you tell what each cast did; do the easy abilities feel rewarding; does aiming feel worth its effort; are the pickup bursts satisfying; which icons or effects are ambiguous? Tune those before adding more buttons or content.
