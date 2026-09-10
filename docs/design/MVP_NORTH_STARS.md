# Demo charter — Survivor.io progression × League-like champion control

> **Historical v0.9 charter.** It is preserved for early design provenance, not current scope. For the implemented 0.17 contract use [QA_17.md](QA_17.md); for latest future direction use [NEXT_SESSION_BRIEF_17.md](NEXT_SESSION_BRIEF_17.md).

Updated September 8, 2026. At v0.9 this was the current product brief: Stage 1, Levels 1–3 were the entire MVP. The constraints below describe that milestone and do not override the later eight-stage expedition or current class direction.

## The feeling

**I control a small, precise champion who grows into a crowd-clearing machine. I harvest ordinary enemies, read dangerous opponents, dodge their committed attacks, and punish their openings. By the final boss, my build visibly does things it could not do at the start.**

The quiet satisfaction is steering through loot and watching a build come together. The exciting moment is a deliberate cast, sidestep or blink that changes a bad fight into a winning one. The reward is a readable burst of destruction and a milestone that changes the next fight. Automatic weapons support that experience; they must not make player decisions irrelevant. Conversely, no player should need to piano-play seven active keys to handle the demo.

## Research → decisions

| Reference | Evidence worth borrowing | Our application / deliberate omission |
|---|---|---|
| [League official how-to-play](https://www.leagueoflegends.com/en-us/how-to-play/) | A champion kit combines a passive, three basics, an ultimate and D/F spells; experience strengthens abilities/stats. | Retain Q/W/E/R roles, D/F mobility, right-click movement, S stop, aimed/quick casts and clear cooldowns. Do not import lanes, last-hit gold, PvP teams, a shop or a forty-minute match. Our four toggle slots remain an original hybrid feature. |
| [Riot: Champion Counterplay](https://www.leagueoflegends.com/en-us/news/dev/quick-gameplay-thoughts-may-14/) | Clear responses support fairness and depth; high-impact effects need proportionate opportunities to respond, generally not a mandatory special ability. | Boss attacks lock aim, telegraph, resolve and recover. Walking can avoid a marked blast or charge; blink is insurance or optimization, not the only answer. |
| [Riot: Clarity in League](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/) | Visual attention should match gameplay importance; silhouettes and effects must communicate function and match hitboxes. | Threat outlines are drawn above friendly spectacle. Boss name/health and exposed windows are visible. Expand indicators with evolved abilities. A larger circle must mean a larger functional area. |
| [HABBY's Survivor.io App Store listing](https://apps.apple.com/tt/app/survivor-io/id1528941310) | Emphasizes massed enemies, accessible controls, roguelite skill combinations and changing stage difficulty. | Borrow the pressure → clear → collect → upgrade loop and escalating encounter density. The listing's crowd-size marketing claim is not our performance requirement; we retain a tested enemy cap. Do not borrow ads, monetized friction or progression gates. |
| [Survivor.io community evolution guide](https://www.reddit.com/r/Survivorio/comments/186lhr6/skill_evolution/) | Historical community explanation describes weapon/support combinations producing evolutions. This is community guidance, not authoritative current balance data. | Keep visible numerical steps and transformative milestones, but avoid hidden prerequisite recipes in the MVP. The tree exposes rank 5/10 outcomes in advance. |

This is a design synthesis, not a claim that these ingredients automatically make a fun game. Survivor.io provides the run structure and accumulation fantasy; League provides moment-to-moment agency. Copying either game's full complexity would work against the short demo.

## North stars and acceptance gates

| North star | What the player should say | Gate before calling the demo polished |
|---|---|---|
| Precise control | “It moved/stopped/cast exactly when I expected.” | Correct cursor coordinates at both zoom limits and edges; no stuck movement/aim after Tab, Esc, focus loss or transitions. Human mouse feel must be signed off. |
| Visible growth | “That upgrade changed what I can do.” | Focused build reaches a rank-5 milestone in Level 1 and can reach rank 10 in Level 3. Player identifies the change without being told the percentage. |
| Earned power fantasy | “Crowds that threatened me now melt, but I still respect the boss.” | Escalating horde and build strength; miniboss/final-boss counterplay remains relevant. No difficulty tuning solely to make a bot lose. |
| Readable danger | “I know what hit me and what I could try next.” | Ground/charge/projectile tests pass; at 65% zoom, a player can identify the windup and a viable escape. Reduced effects preserves every functional tell. |
| Generous flow | “Loot and utility help me keep fighting.” | Magnet is free and separate; no XP lost at object caps; reward/inspection screens preserve choices. Human test finds no exhausting chain of menus. |
| Small, coherent demo | “Those three levels made a complete mini-adventure.” | One start, two meaningful transitions, a final boss and a definite endpoint. No Level 4, metagame or placeholder future progression needed. |

## Stage 1: the authored arc

| Level | Combat target | Encounter / map identity | Progression and intended feeling |
|---|---|---|---|
| 1 — Loading bay | 75 seconds + short clear beat | Open workshop sector, ordinary mobs, two reinforcements. No boss. | Learn movement, stopping, collection and a preferred cast. Ranks up to 5. First milestone turns survival into confidence. |
| 2 — Assembly line | 90 seconds, longer only if wardens remain | New workshop start sector and painted assembly lanes. Harder crowds. Ram Warden at 25s; Artillery Warden at 60s. Both must die. | Carry the entire build. Rank ceiling rises to 8. Use abilities intentionally against readable threats; smaller reinforcement groups during a live warden. |
| 3 — Reactor floor | 90 seconds of mobs + roughly 30–50s boss | Reactor-floor sector/ring marking; strongest waves, then the Foreman. No further ordinary spawns during the capstone fight. | Ranks up to 10. Final transformations and the complete build face combined lessons. Defeat the Foreman to end the demo. |

Working target: about five minutes of active combat; about six to eight minutes with human upgrade choices. These are testable hypotheses, not measured human completion times. Existing bot runs are roughly 292–302 seconds. The three areas are sectors of the current open workshop, not three newly authored obstacle maps. Decorative lanes/rings are walkable; navigation-obstacle work is deferred until it helps this demo rather than breaking crisp movement.

XP growth is called **Power** in the HUD to distinguish it from **Level 1/2/3**. Run ranks, rarity, utility and equipment carry between levels. End-level rewards remain distinct from ordinary XP choices, with one hull repair and an energy refill. Existing damage ranks, free magnet, pets, summon, bindings and art palette stay; no additional ability families are required to prove the demo.

## Boss contract

Ram Warden: approach, lock a charge corridor, wind up, charge, recover. Artillery Warden: approach, mark ground under the player's snapshot position, detonate, recover. The Foreman alternates charge, triple ground marks and a projectile fan. At half health it announces overclocking and shortens windups from 1.25s to 0.95s; recovery remains 1.5s rather than 2s. Recovery grants +50% incoming damage and suppresses contact damage, rewarding commitment. Killed casters cancel pending ground hazards. No hidden tracking charge, instant arena-wide damage or required Flash check.

Boss AI is an explicit state machine, not machine learning. New AI must remain inspectable and deterministic. The autonomous playtest steering policy is separate and is never used to pilot a human player or let a boss read future input.

## Management and scope rule

Current task board: [MVP_TASK_BOARD.md](MVP_TASK_BOARD.md). Work in this order: correctness blockers → control/telegraph clarity → first-three-level pacing → visual/audio feedback. Record observations, change one tuning family at a time, rerun the relevant tests, and request one combined human feedback pass. Research should answer a named uncertainty or guide a concrete change, not become indefinite browsing. No recurring background task or new agent task is implied by this board.

Expansion is locked until a human has completed the three-level loop and we have addressed the biggest control/readability/pacing issue from that playtest. Beyond Stage 1 stays an ideas list at most—not implementation or a detailed progression plan.
