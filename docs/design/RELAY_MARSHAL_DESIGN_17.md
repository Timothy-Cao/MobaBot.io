# Relay Marshal — focused static-kit proposal

Status: **assistant research and design proposal for owner review; not an approved specification and not implemented.** The owner supplied the core fantasy and range constraints. Exact names, numbers, upgrade milestones and the proposed three-relay structure remain open.

Date: 9 September 2026.

## Working name

**Relay Marshal** is the recommended class name.

- **Relay** names the spatial network and the way attacks are repeated from remote origins.
- **Marshal** says the character commands a coordinated force rather than merely building unattended turrets.
- It is short enough for a class card and distinct from the locked all-rounder, Default Salvager.

Earlier notes called the concept Relay Architect. That remains a useful description, but Relay Marshal better emphasizes active command and synchronized fire. Alternatives such as Signal Warden or Meshwright can be revisited only if the owner dislikes this name.

## Provenance boundary

### Owner direction

- Focus on this summon character and park the combo-kit design for now.
- Turrets have real range and must never shoot beyond it.
- Linked turrets share target awareness: a target seen within the network can be used by other reasonably nearby towers, subject to their own range.
- One likely ability fires a missile from both the character and every summon toward the mouse.
- Preserve the earlier fantasy: summons mirror abilities, their summon input can switch places with them, they expire after roughly 30 seconds, and summon interactions or self-detonation may be central.

### Assistant proposal

The complete loadout, three-relay limit, range model, focus/coverage command, effect caps and names below are proposed solutions, not owner decisions.

## One-sentence identity

**Place a connected squad, command attacks from every useful angle, then trade places with the squad to preserve or cash out the network.**

That sentence is the filter for the entire kit. A generic gun buff, unrelated dash or passive stat bonus does not belong unless it changes network placement, synchronized fire, survival or command decisions.

## Why three relays, not four

Use three deployable summon slots and one network-command slot as the first proposal.

- One relay teaches deployment.
- Two create a line, crossfire and a first escape route.
- Three create a triangle and meaningful encirclement.
- A fourth simultaneous relay adds another health bar, timer, firing origin and mirror without creating a new basic geometric relationship.
- Slot 4 can solve a more important problem: telling every summon whether to focus one marked target or cover separate nearby threats.

This is a complexity and readability recommendation, not a permanent cap. Prototype one relay first, then two, then three; only test a fourth if players still want another placement decision after the full kit is readable.

## Range and network contract

Do not use “vision” as a loose synonym for unlimited range. The kit needs three visible, separately enforced distances.

| Range | Meaning | Rule |
| --- | --- | --- |
| Link range | Whether two nodes can relay commands and target data | A summon joins the player's network if it connects to the player or to another already connected relay within this large radius |
| Sensor range | Whether a node can discover an enemy for the network | Any connected node can publish a target detected inside its sensor radius |
| Hard firing range | How far a shot from one origin may travel | Every player or turret shot checks distance from its own origin and expires or lands at its own maximum range; shared data never extends it |

In the initial prototype, sensor range should be slightly shorter than hard firing range. Shared data therefore lets a connected relay use the outer portion of its legal weapon reach without pretending that its own sensors found the target. Links may chain, but keep the network within a broad player-centered command radius or at most two relay hops so three clever placements cannot stretch damage across the entire arena.

Practical example: Relay A detects an enemy. Relay B may immediately acquire that enemy from shared data only if B is connected and the enemy is also within B's hard firing range. B does not fire across the map. An isolated relay keeps its own local behavior but neither publishes targets nor mirrors player casts.

The network should remember a published target for only a brief grace window. This prevents tiny sensor-edge movements from making every turret chatter between firing and idle, while still dropping genuinely unavailable targets quickly.

## Proposed full kit

| Input/system | Working name | Function | Network interaction |
| --- | --- | --- | --- |
| Permanent passive | **Mesh Command** | Maintains links, shared target acquisition and one priority mark | Shows connected/isolated state; shared knowledge never bypasses local hard firing range or line of fire |
| Basic attack | **Command Rivet** | Reliable medium-range aimed shot with modest personal damage | A hit briefly marks that enemy; linked relays in Focus order prioritize it if each can legally fire |
| Q | **Synchronized Salvo** | Low-cooldown bread-and-butter missile fired toward the mouse | The Marshal and every connected relay launch one missile from their own locations toward the cursor; each missile has its own capped path and cannot recursively mirror |
| W | **Siege Designator** | Long-range, higher-commitment target or ground designation | After a short readable lock, every eligible origin fires a heavier converging shot at the designated point; origins without local range show unavailable rather than cheating range |
| E | **Pinning Grid** | Utility/CC window that energizes current network links | Links become visible tripwires for a short time, slowing ordinary enemies that cross; crossing two distinct links produces one brief stun with a per-target lockout |
| R | **Zero-Hour Protocol** | High-impact network cash-out | Relays become temporarily protected and overclocked; during the window their summon inputs still permit swaps, then all active relays self-detonate in a clearly ordered sequence |
| D | **Uplink Rush** | Short hold-to-move escape/reposition tool | Base speed increase works anywhere; moving along or toward a connected link is faster, rewarding routes through the network without trapping a relay-less player |
| F | **Emergency Hop** | Small dependable cursor blink | Leaves a very short-lived non-targetable signal echo at the origin that can contribute one reduced Q missile, then disappears; it is not a fourth maintained summon |
| 1 | **Needle Relay** | Deployable anti-boss/priority turret; 30-second lifetime | Fast precise local fire; press 1 again to swap with it while valid |
| 2 | **Pulse Relay** | Deployable wave-control turret; 30-second lifetime | Slower radial pulse plus modest local fire; press 2 again to swap with it |
| 3 | **Aegis Relay** | Deployable defensive/anchor turret; 30-second lifetime | Lower damage, local aggro relief and a small protective zone; press 3 again to swap with it |
| 4 | **Battle Order** | Toggles **Focus** and **Coverage** with a short lockout | Focus prioritizes the Command Rivet mark; Coverage assigns different legal nearby targets and avoids wasteful overkill |

## Core ability details

### Q — Synchronized Salvo

This should be the kit's signature sound-and-motion action, not merely several copies of Impact bolt.

- One input creates a near-simultaneous firing chorus from the player and each connected relay.
- Every missile aims toward the current mouse world position from its own origin. The paths therefore fan, cross or converge naturally according to placement.
- If the cursor is beyond an origin's hard range, that missile travels in the cursor direction and ends at its maximum distance. It does not teleport to the cursor.
- Relays may contribute reduced damage, but added origins must remain meaningfully valuable. Use a shared same-target budget or diminishing echo damage only if boss stacking overwhelms other play.
- Give each origin a very short launch cadence offset and one combined low-frequency report. Perfectly simultaneous identical sounds tend to become loud noise rather than a satisfying volley.
- Show a small ready pip over each eligible relay. The player should know before casting whether one, two or three echoes will participate.

The reward is geometric: a tight formation produces reliable concentrated fire; a wide formation sweeps more lanes and may approach a boss from safer angles.

### W — Siege Designator

Q rewards frequent repositioning; W pays off a network that already surrounds or reaches a high-value point.

- The player designates an enemy or ground point at longer range and sees which relays can legally contribute.
- After a short lock-on tell, all eligible nodes launch heavy converging rounds.
- Multiple angles should improve reliability and modestly improve damage, but do not multiply crowd control per missile.
- A relay outside local firing range stays silent and displays a muted range cue. This makes bad placement legible instead of feeling bugged.
- Against crowds, the impact may have a small local blast. Against one boss, converging hits provide the kit's anti-boss payoff.

### E — Pinning Grid

The summons need a reason to form something other than a pile beside the player.

- Temporarily energize links between connected nodes and the player.
- An ordinary enemy crossing one link is slowed and takes low damage.
- Crossing a second distinct link during the same activation causes one brief stun, then that target becomes immune to another grid stun for the rest of the cast.
- Heavy enemies and bosses resist displacement; a boss may receive only the slow unless later testing approves a clearly reduced stun.
- The link effect must use the same geometry as the network display. Decorative curves cannot imply a hit area that the simulation does not use.

This gives triangle placement a concrete wave-control purpose without making passive link lines constant free damage.

### R — Zero-Hour Protocol

The ultimate converts maintained territory into a deliberate climax.

- Start a short overclock window. Active relays become visually armed, briefly protected from ordinary chip damage and fire/mirror more aggressively.
- The player may use 1–3 recasts during this window to swap and reposition the eventual blast locations.
- At the end, the player emits a smaller safety pulse and active relays detonate in their displayed order. The sequence is fast enough to feel connected but slow enough to read and steer between swaps.
- Detonation consumes the relays and never grants duplicate expiry rewards. It should be substantially stronger than letting them time out naturally.
- Casting with no relays still gives the player's small pulse, but it is intentionally a poor use. The ultimate's full value requires prior network setup.

The dramatic arc is setup → arm → frantic reposition/swap → cascade. That is more distinctive than a generic screen-wide explosion.

## Summon and swap contract

- Each summon input has three unambiguous states: **deploy**, **swap ready**, or **unavailable**.
- First press places that relay at the confirmed valid point.
- Pressing the same slot while its relay exists swaps positions; it never silently redeploys or heals the summon.
- Hold or an explicit placement modifier may preview a redeploy only at a safe time if later testing proves repositioning is necessary. Do not overload a quick recast with both swap and replacement.
- Swap preserves both actors' remaining health, relay lifetime, cooldowns and current network membership after positions are recalculated.
- Destination validation rejects walls, enemy bodies and invalid arena space. Failure spends neither swap nor energy and gives immediate feedback.
- A relay that naturally reaches 30 seconds gives a short shutdown tell, performs only a small expiry burst and enters redeploy cooldown.
- Relay deaths and expiry must be distinguishable from ultimate detonation in sound, silhouette and reward logic.

## Intended skill curve

| Player stage | Useful behavior | What mastery adds |
| --- | --- | --- |
| First minutes | Place one relay nearby, leave Coverage on, press Q toward enemies | Understand that the extra missile comes from a real origin with real range |
| Comfortable | Maintain two relays, use a marked target, swap away from danger | Preserve uptime and choose Focus versus Coverage |
| Skilled | Build triangles, energize crossing links, surround bosses for W | Plan geometry, expiry timing and legal firing angles |
| Expert | Swap several times during Zero-Hour and choose the cascade pattern | Trade network safety for a precisely placed ultimate cash-out |

The floor is “my machines help when I press Q.” The ceiling is network geometry, target policy and positional sacrifice. Individual turret selection or RTS-style box commands are intentionally absent.

## What should make it satisfying

1. **The network visibly wakes up.** A command travels along links before relays rotate and fire; response must still be mechanically immediate.
2. **The volley has rhythm.** The player shot leads, relay launches answer in a tight sequence, and convergence gets one clear impact accent.
3. **Placement changes the result.** Wide and tight formations produce observably different lanes, link traps and safe swaps.
4. **Summons feel dependable.** They acquire the expected target, respect walls/range, do not jitter and communicate why they are idle.
5. **There is an authored climax.** Zero-Hour sacrifices accumulated board state for a large, player-shaped payoff.
6. **Failure is recoverable.** A destroyed network reduces power but leaves the player a basic, Q, D and F while rebuilding.

## Balance and clarity guardrails

- Summon count, mirrored projectiles, target memory, chain/link checks and effects all need strict caps.
- Mirror calls use a non-recursive damage primitive. They do not spend player energy again or trigger another mirror/proc generation.
- Autonomous turret DPS should be supportive. A low-input player gets value, but active marking, placement, Q/W aim, swaps and R timing create the ceiling.
- Same-target scaling and AoE scaling need separate measurement. A fix for boss burst must not make the network irrelevant against waves.
- Shared target data never bypasses wall collision, hard range or projectile travel.
- Connected, isolated, expiring, swap-ready, armed and unable-to-fire states must remain legible at normal zoom and Reduced effects.
- Thirty-second lifetimes should be tested for maintenance fatigue. Do not add upgrades that merely hide an unfun replacement chore.
- Practice and automated fixtures must never award permanent loot or touch the real checkpoint.

## Research findings applied

These references inform principles, not names, art, code or copied balance values.

- Riot's official Zed page demonstrates a compact relationship between a temporary remote origin, mirrored attacks and a recast position swap. It also limits same-cast resource reward, a useful reminder that multiple origins need explicit once-per-cast or non-recursive accounting. MobaBot adapts the grammar to destructible machines and PvE spatial coverage rather than copying shurikens or assassination mechanics. [Zed champion page](https://nexus.leagueoflegends.com/en-us/champion/zed/)
- Riot's Azir retrospective says automatic minions were not sufficiently interactive for the intended commander fantasy, while direct commands made the soldiers central; it also candidly describes the resulting complexity, balance and bug burden. Relay Marshal therefore uses one shared command language and no per-unit selection, while treating multi-origin behavior as a high-risk system requiring staged prototypes. [Origins: Azir](https://nexus.leagueoflegends.com/en-us/2017/06/origins-azir/)
- Riot's Naafiri development article identifies the less-visible requirements that make companions feel helpful: correct pathing and positioning, rapid command response, appropriate range and correct target choice, all under performance constraints. Relay Marshal makes those states deterministic and visible; stationary relays reduce formation complexity but do not remove targeting and range obligations. [Champion Insights: Naafiri](https://www.leagueoflegends.com/en-au/news/dev/champion-insights-naafiri/)
- Riot's current Heimerdinger material ties movement to proximity to deployed turrets, while recent patch notes describe how turret range, vision duration and follow-up targeting can create poor feel when their boundaries disagree. This supports separate visible sensor/fire ranges, brief target memory and Uplink Rush near the network. [Heimerdinger champion page](https://www.leagueoflegends.com/en-au/champions/heimerdinger/) and [Patch 26.11 notes](https://www.leagueoflegends.com/en-us/news/game-updates/league-of-legends-patch-26-11-notes/)
- Blizzard's Torbjörn page presents a small, legible loop of deployment, direct maintenance and a temporary turret overclock. The transferable lesson is that a construct kit benefits when the player has an active relationship with the machine; Relay Marshal uses command fire, swapping and a sacrificial overclock rather than copying repair-hammer or molten-area mechanics. [Torbjörn hero page](https://overwatch.blizzard.com/en-us/heroes/torbjorn/)

The owner's BTD6 comparison is the design prompt for shared local information. This document does not claim an independently verified current BTD6 rule or import its tower, targeting or upgrade values.

## First prototype slice

Do not implement the table all at once. The minimum useful experiment is:

1. One stationary Needle Relay with visible link and hard firing ranges.
2. Shared target acquisition with a short memory window and strict local firing check.
3. Q firing from player and relay toward the mouse, including cursor-beyond-range behavior.
4. Press 1 again to swap, with invalid-destination feedback and no lifetime refresh.
5. Thirty-second expiry with a clear warning.

Test isolated and connected states, targets at every range boundary, walls, detached camera, normal/reduced effects, expiry during a cast, swap during a telegraph and fixed-seed projectile counts. After mechanical verification, ask the owner only:

- Did one Q feel like a coordinated volley rather than duplicated clutter?
- Could you predict when the relay would fire?
- Did placing and swapping the relay create a decision worth making?
- Did 30 seconds feel like useful territory, a maintenance chore or too permanent?

Only then add a second relay, Focus/Coverage order and crossfire. E, W and R should wait until the basic network is fun.

## Open decisions for owner review

- Keep **Relay Marshal** as the class name?
- Are Needle/Pulse/Aegis the right three summon roles, or should every relay be mechanically identical so only position matters?
- Should Q missiles simply fly through the mouse direction, or explode at the mouse point when that point is locally in range?
- Should summons be destructible, merely timed, or vary by type? The proposal assumes destructible plus timed.
- Should natural expiry cause any damage, or should only the R sacrifice detonate?
- Does Focus/Coverage deserve slot 4, or would a fourth summon be more fun despite the added complexity?
- Should a relay outside the player's connected component continue firing autonomously, or fully power down until reconnected? The proposal keeps weak local behavior so one placement error is not total loss.
