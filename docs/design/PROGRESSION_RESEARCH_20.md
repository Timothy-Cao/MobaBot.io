# Progression direction · 10 September 2026

Status: researched recommendation, with independent 0.19.1 improvements implemented. Replacing the 22-round route with Chapter Operations is awaiting the owner's answer to the single directional question. The owner described that replacement, loot-box rewards, persistent mastery and potions as possibilities, not a settled specification. Do not report these as playable.

## What the comparison supports

| Game | Evidence | Useful lesson here |
| --- | --- | --- |
| Vampire Survivors | Poncle's publisher description separates gems/in-run weapon development from gold spent helping the next survivor. It recommends focusing a few offensive weapons. [Publisher Steam page](https://store.steampowered.com/app/1794680/Vampire_Survivors/) | Reset the combat build while keeping a small, understandable permanent layer. |
| Vampire Survivors Adventures | Poncle describes self-contained chapter sequences, limited starting arsenals, and progression that does not erase main-game unlocks. [Official FAQ](https://poncle.games/adventures-faq) | Short authored sequences can coexist with persistent ownership and replay. This is a structural reference, not the base game's exact rules. |
| Survivor.io | HABBY's release notes explicitly add numbered chapters into the hundreds. [Developer App Store listing](https://apps.apple.com/us/app/survivor-io/id1528941310) The community skills reference describes temporary skills resetting each chapter, five ranks and evolution. [Community skills reference](https://survivorio.fandom.com/wiki/Skills) | Use numbered, replayable content with a reset boundary. A long chapter list is a content pipeline; it does not require shipping hundreds of distinct encounters now. |
| League Swarm | Riot describes objective unlocks, gold-funded lobby upgrades and transferring owned upgrades into a match. [Riot engineering account](https://www.riotgames.com/en/news/the-tech-behind-swarm) | Keep run spending and persistent spending separate in both data and UI. Unlock variety gradually. |
| Swarm boss deadline | Riot's 14.15 notes describe a five-minute timer, visible red enrage, then a lethal nova after 30 seconds. [Official patch notes](https://www.leagueoflegends.com/en-au/news/game-updates/patch-14-15-notes/) | Announce the deadline clearly. Our implementation instead escalates physical attacks and damage without a scripted loss. |

These sources do not establish a transferable enemy HP/XP curve for our aimed QWER combat. No exact Survivor.io chapter-health table or Swarm XP formula was verified. Their currencies, attack uptime and run lengths differ; copying raw numbers would not establish balance.

## Recommended vocabulary and reset boundary

- **Chapter**: numbered replayable difficulty/content selection. Beat the highest unlocked Chapter to unlock the next. Older Chapters remain available for equipment farming.
- **Operation**: one attempt at a Chapter. Start with three rounds; allow an authored 2–5-round definition later. Completing or losing an Operation ends its temporary build.
- **Round**: survival segment, guardian/boss and collection, followed by a field shop. The final round ends with the Operation boss.
- **Field credits**: buy/upgrade the four modules during an Operation. Reset at its end.
- **Salvage**: persistent earned currency for equipment supply crates outside Operations. Reuse/migrate existing persistent credit balances without deleting value; no conversion from unspent field credits.
- **Mastery**: run-only in the first pass. Existing equipment is the primary long-term stat growth. Adding permanent mastery now duplicates that job and complicates the requested reset.

Initial implementation recommendation: eight authored Chapter definitions using the existing sectors/boss bodies, three rounds each. The data structure can accommodate additional chapters; do not advertise unique maps or an unlimited finished campaign. Earlier Chapter repetition yields ordinary rewards; first-clear bonuses are granted once, transactionally.

## Completion targets and why the current curve cannot just be shortened

The current new kit starts with Q, D, F, MG and hammer at rank one. Eight core tools at rank ten require 80 earned ranks in total, so **75 picks remain**. Three picks per level require 25 level-ups: full completion at level 26. The proposed final-boss-entry target is level 23–25 (66–72 picks, 88–96% of that upgrade budget), with strong runs occasionally reaching level 26. This describes earned ranks; equipment's +1 is not a spent pick.

The unified mastery has 29 purchasable points; one point per level yields 23–25 points at that target. Thus mastery can also approach completion without being automatically finished. It resets each Operation.

For the proposed three-round Operation, use initial median level targets of 6 / 14 / 23 at each encounter's arrival. These are design targets, **not verified outputs of today's 22-round XP curve**. Keep the first segment restrained and back-load income. A 2- or 5-round Operation redistributes the same total core-pick budget rather than changing final-boss build completion arbitrarily. Do not restore chest skill points to meet the target.

Module progression is a separate spending choice, not part of the 75-pick claim. At current prices, all four rank-ten modules cost 15,700 field credits. A short Operation should initially support a focused module build, not automatically max every shop item. Target roughly 1,600–2,400 spendable credits over three rounds, then measure purchase choices. Do not inflate equipment drops to fund this budget; field rewards and permanent rewards must be separate.

Level-up popups pause combat, so 22–24 sets of three choices add real wall time. Simulated survival duration is not total play duration. Measure decision time before claiming a ten-minute Operation.

## Damage and encounter budgets

Reproduce the baseline with `tests/progression_budget.gd`. No gear/mastery/module bonuses; assumes perfect contact and simultaneous basic/skill use, then separately limits skill demand to base energy regeneration. It omits cast lockouts, movement, misses, recovery vulnerability and E combos. Therefore it is an analytical reference, not measured player DPS or a guaranteed achievable upper bound for every build.

| Uniform rank | Actual center W | Perfect-contact reference DPS | Energy-limited reference DPS |
| --- | ---: | ---: | ---: |
| 1 | 91.2 | 67.5 | 67.5 |
| 5 | 145.92 | 117.6 | 115.2 |
| 9 | 207.94 | 181.1 | 166.8 |
| 10 | 300.96 | 269.7 | 244.2 |

Correction to the 0.19 notes: W's 76 base center damage also receives the kit's 1.2 multiplier. The prior 76/121.6/250.8 table omitted it. Role-survival reference floors now include that multiplier. Boss HP itself remains unchanged pending the campaign decision and human test.

For an Operation redesign, start with `boss HP = reference sustained DPS × contact fraction × desired fight seconds`. Explore contact fractions 0.35–0.55 and 75–110 seconds, then add separately measured mastery/equipment/module effects. These fractions are assumptions to test. A 25,000-HP boss against an unmodified rank-nine reference already takes about 150 seconds at ideal continuous contact, and around 300 seconds at half contact. That is strong evidence that shorter Operations need their own authored boss budgets. Today's unchanged long route uses a five-minute overload window; this is a testable starting value, not a human-validated deadline.

Keep normal swarms fragile. Durable ranged and melee tanks are budgeted by W hits; fast ranged buy survival through movement. Speed/cadence increases stay bounded, while HP/damage grow against a fixed design curve. Never scale enemies directly against the player's live build: specializing should retain its advantage.

Enemy rollout: first round teaches swarms/pursuers plus Breacher, Volley, Lancer and Scattergun; second round adds Mender/Bomber; EMP waits until Stage 2 in the current route (Chapter 2 in the proposal). Later chapters introduce pattern combinations before further stats. User's 'almost all by the second round' and 'some in later stages' are compatible under this schedule.

## Persistent economy recommendation, not yet enabled

Start with equipment-only supply crates bought using earned Salvage. Show the price, exact tier odds and inventory result before/after purchase; save atomically and roll back currency, inventory and random state on failure. A concrete trial distribution is tier 1: 80%, tier 2: 17%, tier 3: 2.8%, tier 4: 0.2%, tier 5: 0%; slot uniform. These are proposed odds, not imported industry numbers. Preserve three-copy forging and a path to tier 5 through it.

Do not put permanent mastery, ability permissions or consumable potions into the initial random reward pool. Randomly withholding shop mechanics complicates difficulty testing; potions add a second inventory lifecycle. Prefer later deterministic Chapter unlocks for new modules. None of these speculative rewards are implemented in 0.19.1.

## Feedback disposition

Implemented in 0.19: paused core picks, credit modules, combo combat, mobile/offensive bosses, practice-style obstacles, enemy roles, early orbit/mobility changes, peer tabs and reward grid. Implemented in 0.19.1: numerical card deltas, one-root/three-branch mastery, mid-tier regen, delayed EMP introduction, announced boss overload and interval progression evidence.

Awaiting the single campaign-direction answer: numbered Chapter selection, Operation reset, short-route XP/HP budgets and persistent Salvage economy. Deliberately optional/deferred design suggestions: arena closure (open pursuit already exists), additional unique boss bodies, permanent mastery, random ability unlocks and carried potions. No claim that every brainstorm item was requested as a mandatory feature.

Next human validation priorities: (1) early pacing and three-choice decision burden, (2) aimed boss damage versus overload timing, (3) mastery clarity and reward payoff. Passing tests do not establish any of these experiences.
