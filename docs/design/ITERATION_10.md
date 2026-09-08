# MobaBot.io 0.10 — direction and references

## Aim

Make deliberate casts and escapes valuable without turning Stage 1 into a mechanical exam. Keep the three-level scope. Menus should expose decisions first and explain details only on inspection.

## References used

- [Riot: Clarity in League](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/): prioritise important spells, readable silhouettes and matching hit geometry. Applied as a large, directional Q missile versus small automatic bolts; a sustained R beam; shorter but still visible boss tells. We did not interpret “less obvious” as invisible attacks.
- [Riot: Vel’Koz](https://www.leagueoflegends.com/en-us/champions/velkoz/): the official description establishes a cursor-following channeled beam. Our original Core cutter uses the requested five-second duration, RMB target steering, angular inertia and a recast cancel. It does not reproduce League's damage system, assets or exact timing.
- Last Epoch visual references: [passive-tree screenshot](https://gfn.ru/media/images/screenshot-last-epoch-344e636e.original.jpg) and [equipment/stat screenshot](https://cdn.pcgame.com/gen_screenshots/pcg/87298/screenshots/large/6-1920x1080.jpg), both inspected in the browser. Observations: compact node icons with allocation counts and connectors; fitted slots separated from the item grid; aligned stat rows; selected/hovered item details. Our interpretation is a nine-node, three-rail mastery tree, a three-slot equipment layout and a compact stat sheet. These are older screenshots, not claims about the current live interface. No images or assets were copied into the project.
- [r/aigamedev: consistent UI](https://www.reddit.com/r/aigamedev/comments/1vsxwfs/has_anyone_found_out_how_to_create_consistent_ui/): useful anecdotal advice is the implement–render–inspect loop and concrete hierarchy/spacing feedback. We used actual game captures, not just source inspection. Commercial tool recommendations and unsupported prompting claims in comments were not adopted.
- [r/aigamedev: consistent assets](https://www.reddit.com/r/aigamedev/comments/1tgdw6j/consistent_game_assets_how_people_do_it/): the thread illustrates how hard it is to keep separately generated assets aligned. Our decision, not a proven universal rule: remove the mixed-detail icon presentation and use one authored drawing system with shared materials. No new generation service, model installation or subscription was needed.

## Design decisions

### Kit

Q remains a straight impact missile. It now has a steel body, directional fins, a broad teal/brass exhaust and a separate impact sound/ring. Rank 5/10 increases visible projectile and explosion size.

E inherits Reactor drop: 85 damage, 135 radius, 0.65-second warning, 16-second recharge, 28 energy. Press its binding and confirm with left click; optional quick cast is in Settings.

R is Core cutter: 75 damage/second, 700 range, 46 width, up to five seconds, 40 energy, 30-second recharge. Starting it stops walking. RMB sets the steering target; holding RMB follows the cursor. Angular speed is capped at 1.25 radians/second with 3.5 radians/second² acceleration. R cancels immediately, without refund. A successful D/F cast cancels into an escape. Other active casts are blocked while channeling. Pauses freeze combat and silence the beam hum. Rank 5/10 widens the actual damage strip by 25/50% and accents its outer rails.

D is Ghost drive: +65% speed; three seconds of damage/slow immunity. Higher ranks shorten recharge, and milestones extend the speed duration to four/five seconds, not the immunity. Baseline recharge is 18 seconds.

Default passives: Auto bolt, Scrap orbit, Arc coil, Reactive plating. Arc coil hits up to four enemies locally every 1.8 seconds; its number key cycles chain → focused double-damage strike → off → chain. Weapon power ranks scale its damage. Collection pulse, Ricochet and Recoil shell remain loadout alternatives.

Passive upkeep is now 2/2/4/2 energy per second for the default set. Pulse costs 3, Ricochet 2, Recoil shell 1. Base regen is 8 before equipment/upgrades. On depletion, powered passives switch off; sufficient energy and their number keys reactivate them. Orbit can be reactivated after a brownout, then resumes near/far toggling.

### Mastery

Run-only; separate from ability ranks and persistent equipment. One starting point, then one every two Power levels. No forced prompt. HUD ◇ counter; hold Tab to purchase. Main-menu tree is read-only. Each child requires one point in its parent.

| Rail | Nodes |
| --- | --- |
| Salvage | Long reach: +35 pickup range ×3 → Fast learner: +10% XP ×3 → Lucky find: +25% relative drop odds ×3 |
| Survival | Reinforced: +1 max/current hull ×3 → Second wind: +1 energy/sec ×3 → Unstoppable: halve slows; D restores 1 hull |
| Overload | Hot core: +6% active damage ×3 → Static lock: Arc/Impact bolt stun ordinary enemies for 0.35s → Aftershock: wider secondary Q blast |

Bosses resist stuns. XP fractions accumulate rather than rounding away on one-dot pickups. Aftershock scales with the missile's damage multiplier. Utility increases are intentionally generous, but rare bonus drops retain the close-collection requirement.

### Challenge

Foreman: 60-unit collision radius (was 31), 1800 HP (was 900), faster pursuit, 0.9/0.65-second tells, 560-unit committed charge, seven-shot fan, radial attack with a gap, and periodic off-screen reinforcements. Half health overclocks it. Recovery is shorter and still gives +50% incoming damage.

Wardens: 230/280 HP, larger bodies, alternating attacks. Boss charge hits for 3 hull; contact, shells and boss projectiles hit for 2. Heavy/elite monsters hit for 2. Tanks and the boss's radial projectiles can apply a 20% slow for 1.2 seconds. Ordinary contact remains 1. Damage protection between hits is 0.85s, with Reactive plating adding 0.65s. Normal pursuit is faster; charger dash distance remains exactly matched to its tell.

### Interface and art

Fitted gear / collection / one selected item. Disabled unaffordable actions; cost rules on hover. Removed the quoted equipment paragraph and repetitive instructional notices. Compact aligned stat rows; hover for source details. Loadout descriptions moved to tooltips, also fixing the new fourth ability-grid row overlapping the old description block.

One 64-unit code-native icon family now covers equipment, passives and actives. Broad steel, teal, brass planes; upper-left bevels and restrained shadows. Existing generated PNGs are preserved, but are not mixed into this interface. Main menu uses the actual robot, enlarged, with quiet navigation. This is deliberately a stylised prototype art pass, not a claim of professional hand-painted art.

## Next human checks

- Is R's turn rate comfortably deliberate, or frustrating? Is the five-second maximum useful with the shorter boss openings?
- Does D feel like a reliable escape? Are three-hull boss charges fair with the visible windup?
- Are passive brownouts clear enough from the dim icons and brief notice?
- Are mastery/gear hover details easy to find? Do the new icons hit the desired middle detail level?

Tune these after a human run. Do not add a fourth level, more equipment slots or a larger tree to avoid answering these questions.
