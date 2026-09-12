# Bullet-heaven lessons for MobaBot

12 September 2026. Research and code review at `c1905f0`. Recommendations only; no gameplay, assets, saves or release changed. Current contract: three selectable Levels, each containing three five-minute rounds; Vanguard is the campaign benchmark. This document does not revive older eight-Chapter proposals.

## Design direction

Make the first satisfying combat loop arrive early, let the player shape it, and then change the problems it faces. MobaBot's distinction is aimed abilities, resource management, E/Q/hammer/Flash combinations and terrain use. Progression should support that play, while fodder kills and automatic fire provide lower-attention moments between deliberate actions. Constant maximum input demand would undermine the power fantasy; full automation would undermine this class.

The cited games demonstrate mechanisms and developer decisions, not causal proof of commercial success. Timing targets below are proposed experiments for our game, not measured industry averages. No new hands-on sessions of the reference games were conducted for this review.

## What transfers from the reference games

| Reference | Verified observation | Application to MobaBot |
| --- | --- | --- |
| Vampire Survivors | The developer's own starting tips encourage a small initial weapon set, concentrating upgrades, and freely refunding permanent power-ups to experiment. [Official Steam page](https://store.steampowered.com/app/1794680/Vampire_Survivors/) | Give players a reachable investment plan. A large random choice pool is not automatically build variety. Keep useful controls available and let a chosen attack reach a noticeable breakpoint. |
| Survivor.io | Habby's listing emphasizes one-hand horde combat and combinations. Its community skill reference describes fifth-rank weapons evolving with compatible passives. The latter is community documentation, not a verified current balance table. [Habby listing](https://play.google.com/store/apps/details?id=com.dxx.firenow&hl=en), [skill reference](https://survivorio.fandom.com/wiki/Skills) | The transferable lesson is a legible destination for upgrades. Our rank-five/ten changes can provide that destination without adding evolution recipes or copying a mobile economy. |
| Deep Rock Galactic: Survivor | The official description combines mining, movement and automated combat. [Developer store page](https://store.steampowered.com/app/2321470/Deep_Rock_Galactic_Survivor/) | Terrain and resources can produce real route decisions. Our crane, press and cooling vent already support this; develop their encounters before adding another map subsystem. |
| DRG: Survivor's development lessons | In the 1.0 retrospective, Funday says the old overclock unlock gate made early runs feel wasted. It simplified mastery grinding and changed boss rewards to counter incentives to stall and farm. [Developer announcement](https://steamcommunity.com/games/2321470/announcements/detail/534361794856091730), [readable mirror](https://steamdb.info/patchnotes/19997488/) | Put signature play within reach on an early attempt. Check what our rewards encourage, including boss stalling and repetitive gear farming. More progression layers can add friction rather than depth. |
| League Swarm | Riot describes authored wave timing/composition and shared navigation to address crowd clumping and performance. It also documents objective-based unlocks. [Engineering account](https://www.riotgames.com/en/news/the-tech-behind-swarm) | Author encounters around a specific movement problem. Profile density, pathing and effect cost together; do not infer good pressure from a larger enemy count. Reuse our existing spatial systems before replacing them. |
| Swarm's intended scope | Riot's design discussion describes a finite experience that can be completed, rather than requiring endless progression. [Official discussion, French edition](https://www.riotgames.com/fr/actus/swarm-arena-et-limportance-des-modes-de-jeu) | Three satisfying Levels can be a complete demo. Grind length and system count are poor substitutes for distinct runs. |

## Findings in our current build

### 1. Early access to the class identity is less reliable than XP access

`Vanguard.setup` starts Q, D, F, gun and hammer at rank one; W/E/R start unlearned. The banked Head start capstone separately grants starting E. `ReviewRules.candidates` otherwise samples three unique choices uniformly from eight core tools plus XP and pickup range. It does not protect early E access or focused investment.

With ten eligible candidates and no low-health replacement, the probability of never seeing a particular option across the first four offers is `(7/10)^4 = 24.01%`. This is an analytical offer calculation, not a measured player failure rate; selecting other cards can later change the pool, and the heal replacement also changes offers. Four initial picks cannot max a ten-rank tool, so the ten-option assumption holds for a healthy ordinary start during those picks.

Proposed first experiment: guarantee an E offer within the first three choices when E is unlearned. Offer, do not auto-select. Preserve Head start's stronger benefit of having E immediately. Then test mild protection for an owned offensive upgrade in later offers so the player can reach a chosen rank-five payoff. Keep other options genuinely useful; do not always force the same completed build.

### 2. The opening has been tuned by density without a measured learning curve

The latest change raises first-90-second basic spawns from 138 to 257, with no extra specialist types. The current no-gear idle/active/basic probes last 17.7/137.3/56.5 seconds. Those policies are not first-time humans and do not reproduce the owner's gear or dexterity. They identify a calibration risk, not proof that the opening is unfair.

Cheap levels already cost 6/8/10/12 XP, then 20; each level through five gives one pick, then two. All current first rounds suppress basic variants through 90 seconds and specialists through 120 seconds. Level 1 also carries the denser basic opening. This can create a quiet-type introduction followed by a composition transition even while the body count rises continuously.

Proposed opening: plentiful killable fodder with deliberate gaps and concentrated packs that reward an aimed Q or E/hammer sweep. Let gun-only play fall behind gradually. Introduce one readable pursuit problem before adding overlapping ranged demands. Tune access to XP on reachable ground alongside spawn rate: kills alone do not ensure a struggling player can collect their recovery in power.

### 3. We should budget meaningful changes, not just level totals

Current core completion requires 75 additional ranks at the ordinary start; XP/pickup upgrades add ten. Levels two through forty supply 74 picks: four single picks plus 35 pairs. Chest levels advance this schedule; chests collected at cap add further picks. Modules use credits separately. Thus near-completion at the final boss is plausible, but maximum player level is not the same as completing the chosen combat build.

Each numerical pick pauses combat. At an illustrative four seconds per pick, 74 picks add 4m56s before camp/mastery time. No decision-time distribution is currently established by the combat logs. Keep the paused three-card interaction the owner requested, but measure wall-clock friction and low-value repeated decisions.

Track the first functional combo, first rank-five attack, first rank-ten attack, and first useful shop purchase. The older artificial-health full route reached levels 12/33/40 at guardian/guardian/boss arrival; that is a prior reliability sample, not a target or a new human observation. It suggests checking late saturation and the step from the first to second round.

### 4. Difficulty needs several independent budgets

Use fixed per-Level reference builds. Do not scale enemies against the actual player's current investment, which would erase good choices and gear rewards. Separate:

- Fodder clear capacity: can a satisfying attack still clear a cluster? Older fodder should become easier as the build develops.
- Priority-target time to kill: can the player remove a hatchery or ranged attacker during a committed window?
- Durability: how many representative mistakes can expected gear withstand, including simultaneous hits?
- Movement demand: telegraph overlap, safe routes, projectile speeds and escape-resource availability.
- Attention demand: how many different urgent decisions arrive at once?

A mosquito should reward gun investment, while occasional point-blank or well-positioned aimed hits remain possible. A wave must not become unwinnable merely because RNG withheld its preferred counter. Tank durability should create time for a combo, not turn every regular enemy into a sponge.

### 5. Encounters need payoff and recovery phases

Current regular packs, 50-second surges and specialist cadence can stack without representing a distinct authored challenge. Test a first-round sequence with changing emphasis: fodder clusters, pursuit, a brief collection opportunity, ranged pressure, then a miniboss. A 10–20-second lull can still contain easy enemies to enjoy killing. It need not be empty waiting.

Use one optional 20–30-second factory opportunity per round in the initial experiment. Examples: a rich loose-scrap patch near a crane; a dense durable pack that can be lured into a press; a runner crossing beside a cooling vent. These are proposals using existing interactions, not implemented events. Avoid mandatory chores or an additional currency. The map matters when routes have competing value, not when the floor has more decoration.

### 6. Gear should buy resilience without making execution irrelevant

Keep equipment as the main persistent durability progression, matching owner direction. Balance Level 1 for a fresh profile with competent play; assess later Levels against explicitly chosen attainable gear. Better armor should forgive additional mistakes. It should not be required before the player can experience E combinations.

Test identical play policies at starter, intended and one-tier-higher gear. Compare both survival and the size of the advantage from good execution. Avoid automatic enemy scaling to owned armor. Keep distinct roles: run ranks transform combat, field credits buy modules, Salvage/equipment provide long-term growth. Mastery remains the existing run-only layer in this proposal.

Existing hidden recovery aid for failed progression and 45 Salvage on the qualifying prior-Level clear should be measured before adding more pity systems. No suggestion to add paid currencies, energy gates or daily chores.

### 7. Mechanical fairness includes art, sound and performance

During busy scenes the player needs to locate their body, distinguish hostile tells from friendly spectacle, and understand whether a buffered combo executed. Prefer small, specific pose/sound confirmations over more particles or tutorial text. A successful dash-spin should remain recognizable with reduced effects enabled.

Measure damage occurring after an offscreen warning, unavoidable-looking overlaps, input timing under crowd load, and whether players can name the mistake that killed them. Death evidence should remain concise and on demand. Smooth frames protect the mechanical skill test; population and effects have to fit the selected test hardware budget.

## First experiments and acceptance measures

All targets below are provisional. Report median and slow-tail results separately for new players and experienced players, then split by gear. Keep simulation time separate from time spent in menus.

| Measure | Initial hypothesis | What to investigate if missed |
| --- | --- | --- |
| First upgrade | 10–20 seconds for a player engaging and collecting | XP reachability, starter kill rate, first-wave arrival, then threshold |
| First E offer | Within the first three choices when unlearned | Offer protection; no requirement to take E |
| First E/hammer attempt | Within about 45–75 seconds for a player choosing E | Access and natural encounter cues; not a compulsory tutorial |
| First focused rank-five payoff | About 2–3 minutes when actively specializing | Offer dilution and required investment before increasing global XP |
| Sustained pressure | No first-minute trap requiring perfect inputs; short recovery opportunities after bursts | Composition/geometry and simultaneous demands, not only damage |
| Pause burden | Investigate if upgrade decisions exceed roughly 20% of active-plus-upgrade wall time | Repeated low-value picks, poor comparison, too many ranks to spend |
| Main boss | About 60s ideal sustainable execution; 90–120s with realistic dodging/misses | Resource budget, attack opportunities, hit rate, target uptime |
| Build near final boss | Chosen damage plan substantially online, remaining meaningful upgrades possible | Track milestone distribution, not merely level40 |
| Loss / retry | Player can identify a next attempt adjustment; retry is direct | Reward clarity, damage readability, gear wall or excessive menu friction |

For the boss benchmark, `HP / ideal sustainable DPS` estimates the perfect-rotation duration. Real time depends on attack opportunity and landed effectiveness. A 60-second ideal fight becomes 90–120 seconds at roughly 50–67% combined effectiveness. Do not double-count those losses if measuring already-realized DPS. Multi-target credited damage is not single-target DPS and excludes overkill. Our gradual enrage begins at 60 seconds; it must remain mild enough at 90–120 seconds for the intended practical window to work. No recommendation to raise boss HP merely because an older guardian died quickly.

## Recommended order

1. **First 90 seconds and first meaningful build:** offer protection, reachable XP, pack shapes and an early satisfying combo. Do not simultaneously retune every Level.
2. **Round rhythm and purposeful routes:** an authored pressure/payoff sequence plus one opportunity using existing machinery. Compare against the same seed/gear opening.
3. **Whole-run and permanent progression:** measure milestone arrival, pause time and starter-versus-geared outcomes; then adjust late XP, small-upgrade volume or gear rewards one at a time.

Only after these experiments should more enemies, a larger mastery tree or additional progression layers be considered. Keep successful Vanguard mechanics intact. Review/approval of this proposed gameplay direction precedes implementation.
