# Marshal — focused static-kit proposal

Status: **organized owner direction plus assistant research for later implementation; not implemented.** The owner has chosen the class name and revised its core abilities. Exact values, D/F, rank milestones and unresolved edge cases remain open.

Date: 9 September 2026.

## Names

The owner chose **Marshal** for this summon kit.

- **Marshal** says the character commands a coordinated force rather than merely building unattended turrets.
- It is short enough for a class card and leaves the relay language available for the individual machines and passive.

The owner approved **Vanguard** as the locked default all-rounder's name.

## Provenance boundary

### Owner direction

- Focus on this summon character and park the combo-kit design for now.
- Each relay normally detects enemies in a medium circle of radius **X**. It may detect and attack as far as roughly **3X** when that enemy is inside another relay's normal detection circle or the player's attack range.
- Relays provide small health and energy regeneration.
- Each player basic attack commands every relay that can legally reach the target within 3X to make an additional attack on a separate timer from its autonomous weapon.
- Q fires a missile from the character and every relay toward the mouse. Its range is roughly 3X and it explodes at maximum distance.
- W becomes a simple medium-radius EMP centered on every relay.
- E becomes a timed high-damage shock along every pair of active non-player relays. It requires two or three relays and uses one line with two or a triangle with three.
- R is Overclock: relays gain massively increased attack speed and extra missiles. Switching bodies during Overclock detonates the body left behind for major damage and puts that relay on a 10-second redeploy cooldown.
- Use three relay slots. If a relay is already placed, press its key once to enter a ranged reposition preview and left-click to place it again; press its key twice to switch bodies instead.
- Relay bodies should visibly resemble Marshal's robot chassis, with different tools attached, so switching reads as transferring software/control between compatible bodies.
- The three relays fire distinct projectile families, including explosive wave-clear and single-target armor-piercing fire.

### Assistant proposal

Individual ability names, relay projectile roles, Battle Order, D/F behavior, non-recursive effect rules and implementation guardrails below are assistant proposals unless explicitly listed as owner direction above.

## One-sentence identity

**Place a squad, make every personal attack become a coordinated attack, then reposition or transfer control between robot bodies to keep the formation useful.**

That sentence is the filter for the entire kit. A generic gun buff, unrelated dash or passive stat bonus does not belong unless it changes network placement, synchronized fire, survival or command decisions.

## Why three relays, not four

Use three deployable summon slots and one network-command slot as the first proposal.

- One relay teaches deployment.
- Two create a line, crossfire and a first escape route.
- Three create a triangle and meaningful encirclement.
- A fourth simultaneous relay adds another health bar, timer, firing origin and mirror without creating a new basic geometric relationship.
- Slot 4 can solve a more important problem: telling every summon whether to focus one marked target or cover separate nearby threats.

This is a complexity and readability recommendation, not a permanent cap. Prototype one relay first, then two, then three; only test a fourth if players still want another placement decision after the full kit is readable.

## Range and shared-target contract

The owner's simplified rule uses two primary distances.

| Range | Meaning | Rule |
| --- | --- | --- |
| **X — local range** | Normal detection and autonomous targeting | A relay independently sees and attacks enemies inside this medium circle |
| **3X — relayed range** | Network-assisted detection and maximum weapon reach | If an enemy is inside another active relay's X circle or the player's attack range, each other relay may attack it only while it is within roughly 3X of that firing relay |

Example: an enemy beside Relay A is published to the squad. Relay B is 2.5X from that enemy, so B may fire. Relay C is 3.2X away, so C may not. Shared information extends acquisition, but 3X remains a hard local range measured from each firing body; walls and projectile collision still apply.

The same 3X distance is the initial range target for Q missiles. A brief shared-target memory can prevent edge flicker, but it must not preserve a target after it leaves every valid detection and firing condition.

Whether health/energy regeneration stacks per active relay, applies globally or requires the player to stand inside X remains open. The conservative first test is a small non-stacking aura within X, followed by a stacking test only if maintaining multiple zones feels unrewarding.

## Proposed full kit

| Input/system | Working name | Function | Network interaction |
| --- | --- | --- | --- |
| Permanent passive | **Relay Network** | Local X detection, shared 3X acquisition and small health/energy regeneration | Another relay or the player can publish a target, but each firing relay still checks its own 3X limit |
| Basic attack | **Command Fire** | Reliable personal attack | Every relay with the target inside its 3X range performs one substantial bonus shot on a command-fire clock separate from its normal attack timer |
| Q | **Synchronized Missile** | Bread-and-butter cursor-directed missile with roughly 3X range | Marshal and all active relays fire from their own positions; each missile explodes at its maximum travel distance |
| W | **EMP Pulse** | Simple medium-radius control/damage blast | Every active relay emits the EMP around itself; the player is not an origin |
| E | **Triangulation Shock** | Timed high-damage relay-to-relay pulse | Two relays fire one beam; three pulse all three triangle edges; the player never forms an edge |
| R | **Overclock** | High-impact attack-speed and missile window | Relays fire massively faster with extra missiles; switching detonates the abandoned relay body and puts that relay slot on a 10-second cooldown |
| D | **Uplink Rush** | Provisional movement-speed escape/reposition tool | Works without a relay; a small benefit near relays may be tested later but is not owner-approved |
| F | **Emergency Hop** | Provisional dependable short blink | No extra summon or mirrored attack in the simplified version |
| 1 | **Needle Relay** | Thirty-second anti-boss turret | Fires armor-piercing single-target rounds; key opens reposition preview, second key press switches bodies |
| 2 | **Blast Relay** | Thirty-second wave-clear turret | Fires slower explosive projectiles; key opens reposition preview, second key press switches bodies |
| 3 | **Arc Relay** | Thirty-second control/generalist turret | Fires lower-damage chaining or slowing shots; key opens reposition preview, second key press switches bodies |
| 4 | **Battle Order** | Provisional toggle between **Focus** and **Coverage** | Focus follows the latest Command Fire target; Coverage assigns different legal nearby targets and avoids wasteful overkill |

## Core ability details

### Basic — Command Fire

The player's basic attack is the simplest and most important Marshal/summon interaction.

- The player's body performs its own attack.
- Every active relay whose distance to that target is at most 3X immediately performs one additional command shot.
- This additional shot has its own cooldown clock. It does not consume, reset or wait for the relay's autonomous attack timer.
- A full three-relay command should deal substantial focused damage and feel recognizably stronger than leaving the turrets unattended.
- Relay type still matters: Needle contributes an armor-piercing shot, Blast an explosive shot and Arc a chaining/control shot, subject to balance caps.
- If a target leaves one relay's 3X range before release, that relay does not cheat the shot. Define windup cancellation consistently before implementation.

This is the Azir-like command layer requested by the owner: placement determines which bodies can answer, while each player basic creates a coordinated attack moment.

### Q — Synchronized Missile

This should be the kit's signature sound-and-motion action, not merely several copies of Impact bolt.

- One input creates a near-simultaneous firing chorus from the player and every active relay.
- Every missile aims toward the current mouse world position from its own origin. The paths therefore fan, cross or converge naturally according to placement.
- Each missile travels roughly 3X. It explodes when it reaches that maximum distance, including when the mouse is farther away; it does not teleport to the cursor.
- Whether an earlier enemy/terrain collision also detonates it or only stops it remains an implementation question for the first feel test.
- Relays may contribute reduced damage, but added origins must remain meaningfully valuable. Use a shared same-target budget or diminishing echo damage only if boss stacking overwhelms other play.
- Give each origin a very short launch cadence offset and one combined low-frequency report. Perfectly simultaneous identical sounds tend to become loud noise rather than a satisfying volley.
- Show a small ready pip over each eligible relay. The player should know before casting whether one, two or three echoes will participate.

The reward is geometric: a tight formation produces reliable concentrated fire; a wide formation sweeps more lanes and may approach a boss from safer angles.

### W — EMP Pulse

Keep W simple: every active non-player relay emits one medium-radius EMP at the same time.

- Each relay shows a short charge ring, then releases a circular electromagnetic blast around its own body.
- The player does not emit an EMP. With no relay placed, W is unavailable and clearly says why.
- Overlapping EMPs should not multiply hard crowd control without a cap. Their damage may overlap if testing shows that clustering relays deserves the lost map coverage.
- Decide whether the EMP interrupts enemy windups, disables projectiles/machines or simply damages/slows only after the base pulse is readable.

### E — Triangulation Shock

E rewards the timing and geometry of two or three non-player relays.

- Two active relays create one telegraphed high-damage laser/shock pulse between them.
- Three active relays pulse all three pairwise edges, forming one triangle.
- The player is never a corner and no continuous passive damage exists between pulses.
- Use a clear anticipation beat so enemies entering the lines at the correct moment are rewarded; do not leave an ambiguous always-on lightning decoration.
- Each enemy is hit at most once per edge per activation. Define whether a target at the triangle corner may take two edges before tuning damage.

This gives repositioning a concrete payoff: the player chooses when and where the network becomes a weapon, while enemies can move between safe and dangerous spaces before the pulse.

### R — Overclock

Overclock makes the autonomous network briefly overwhelming and turns body switching into a sacrificial attack.

- During the window, every active relay gains massively increased autonomous attack speed and adds extra missiles to its attacks.
- Relays remain available for normal reposition previews and body switching.
- When the player switches into a relay body, the previously controlled body becomes the abandoned relay body and immediately explodes for major area damage.
- That exploded relay is removed and its slot enters a 10-second cooldown before it can be deployed again.
- Switching several times can therefore create several positioned explosions, but progressively consumes the firing network. Staying put preserves the overclocked guns.
- With no active relay, R should not generate free machines. It may be unavailable or grant only a weak personal effect; decide after the basic Overclock loop is tested.

The decision is deliberately sharp: retain the huge attack-speed network or sacrifice individual bodies as bombs. The visuals should show the player's control signal leaving one compatible robot shell and entering another, not an unexplained teleport between unrelated objects.

## Summon and swap contract

- If a relay is not active, pressing 1, 2 or 3 opens its placement preview and left-click deploys it within the displayed range.
- If it is already active, the first key press immediately opens a reposition preview. Left-click confirms its new valid location.
- Pressing the same key a second time while that preview is open performs the software/body switch instead. This avoids delaying every single press while the game waits to distinguish a double-tap.
- Right-click or Esc cancels the preview without spending the action.
- In a normal switch, player control and the Marshal tool set move into the relay-shaped body while the old controlled shell assumes that relay's role. During Overclock, the old shell explodes instead and the relay enters its 10-second cooldown.
- All four bodies should share the same core robot chassis and scale. Needle, Blast and Arc use unmistakable weapon attachments, silhouettes and projectile languages so their roles remain readable.
- Destination validation rejects walls, enemy bodies and invalid arena space. Failure spends neither swap nor energy and gives immediate feedback.
- Normal repositioning should not silently heal a relay. Whether it refreshes the 30-second lifetime remains open and must be displayed explicitly either way.
- Relay health, the player's health and cooldown ownership during a software transfer require an explicit rule before code. Avoid a swap that becomes a hidden full heal.
- A relay that naturally reaches 30 seconds gives a clear shutdown tell. Natural expiry does not inherit Overclock's massive explosion unless the owner later requests it.
- Relay death, expiry, repositioning and Overclock sacrifice must be distinguishable in sound, silhouette and reward logic.

## Intended skill curve

| Player stage | Useful behavior | What mastery adds |
| --- | --- | --- |
| First minutes | Place one relay nearby, basic attack and press Q | Understand autonomous fire versus the separate commanded shot and missile |
| Comfortable | Maintain two relays, reposition one and time EMP coverage | Use the X/3X rule and choose Focus versus Coverage if slot 4 survives testing |
| Skilled | Build a triangle and pulse E through a wave or boss | Plan distinct projectile roles, expiry timing and legal command-fire ranges |
| Expert | Overclock, decide which guns to preserve and which bodies to sacrifice | Chain deliberate control transfers into positioned explosions without losing every safe body |

The floor is “my machines answer my attacks.” The ceiling is range coverage, projectile composition, timed geometry, rapid repositioning and positional sacrifice. Individual turret selection or RTS-style box commands are intentionally absent.

## What should make it satisfying

1. **Every basic gets an answer.** The player fires, then every in-range relay responds on its independent command clock.
2. **The missile volley has rhythm.** The player launch leads, relay launches answer in a tight sequence and the maximum-range explosions share one clear impact accent.
3. **Placement changes the result.** Wide and tight formations change X coverage, 3X command reach, EMP zones, triangle pulses and safe body transfers.
4. **Summons feel dependable.** They acquire the expected target, respect walls/range, do not jitter and communicate why they are idle.
5. **There is an authored climax.** Overclock makes the network roar, then lets the player trade individual guns for massive body explosions.
6. **Failure is recoverable.** A destroyed network reduces power but leaves the player a basic, Q, D and F while rebuilding.

## Balance and clarity guardrails

- Summon count, mirrored projectiles, target memory, chain/link checks and effects all need strict caps.
- Mirror calls use a non-recursive damage primitive. They do not spend player energy again or trigger another mirror/proc generation.
- Autonomous turret DPS should be supportive. A low-input player gets value, but commanded basics, placement, Q aim, EMP coverage, triangle timing, transfers and Overclock decisions create the ceiling.
- Same-target scaling and AoE scaling need separate measurement. A fix for boss burst must not make the network irrelevant against waves.
- Shared target data never bypasses wall collision, the 3X hard range or projectile travel.
- Local-X, relayed-3X, expiring, reposition-preview, switch-ready, overclocked and unable-to-fire states must remain legible at normal zoom and Reduced effects.
- Thirty-second lifetimes should be tested for maintenance fatigue. Do not add upgrades that merely hide an unfun replacement chore.
- Practice and automated fixtures must never award permanent loot or touch the real checkpoint.

## Research findings applied

These references inform principles, not names, art, code or copied balance values.

- Riot's official Zed page demonstrates a compact relationship between a temporary remote origin, mirrored attacks and a recast position swap. It also limits same-cast resource reward, a useful reminder that multiple origins need explicit once-per-cast or non-recursive accounting. MobaBot adapts the grammar to destructible machines and PvE spatial coverage rather than copying shurikens or assassination mechanics. [Zed champion page](https://nexus.leagueoflegends.com/en-us/champion/zed/)
- Riot's Azir retrospective says automatic minions were not sufficiently interactive for the intended commander fantasy, while direct commands made the soldiers central; it also candidly describes the resulting complexity, balance and bug burden. Marshal therefore uses one shared command language and no per-unit selection, while treating multi-origin behavior as a high-risk system requiring staged prototypes. [Origins: Azir](https://nexus.leagueoflegends.com/en-us/2017/06/origins-azir/)
- Riot's Naafiri development article identifies the less-visible requirements that make companions feel helpful: correct pathing and positioning, rapid command response, appropriate range and correct target choice, all under performance constraints. Marshal makes those states deterministic and visible; stationary relays reduce formation complexity but do not remove targeting and range obligations. [Champion Insights: Naafiri](https://www.leagueoflegends.com/en-au/news/dev/champion-insights-naafiri/)
- Riot's current Heimerdinger material ties movement to proximity to deployed turrets, while recent patch notes describe how turret range, vision duration and follow-up targeting can create poor feel when their boundaries disagree. This supports visible X/3X range states and brief target memory. [Heimerdinger champion page](https://www.leagueoflegends.com/en-au/champions/heimerdinger/) and [Patch 26.11 notes](https://www.leagueoflegends.com/en-us/news/game-updates/league-of-legends-patch-26-11-notes/)
- Blizzard's Torbjörn page presents a small, legible loop of deployment, direct maintenance and a temporary turret overclock. The transferable lesson is that a construct kit benefits when the player has an active relationship with the machine; Marshal uses command fire, repositioning, transfers and sacrificial Overclock explosions rather than copying repair-hammer or molten-area mechanics. [Torbjörn hero page](https://overwatch.blizzard.com/en-us/heroes/torbjorn/)

The owner's BTD6 comparison is the design prompt for shared local information. This document does not claim an independently verified current BTD6 rule or import its tower, targeting or upgrade values.

## First prototype slice

Do not implement the table all at once. The minimum useful experiment is:

1. One stationary Needle Relay with visible X and 3X range states.
2. Shared target acquisition through the player's attack range, with a short memory window and strict 3X firing check.
3. A player basic causing the Needle Relay's separate armor-piercing command shot without resetting autonomous fire.
4. Q firing from player and relay toward the mouse and exploding at roughly 3X.
5. First key press plus left-click repositioning versus a second key press that transfers control, with clear invalid-destination feedback.
6. Thirty-second expiry with a clear warning.

Test local-X versus shared-3X states, targets at every range boundary, walls, detached camera, normal/reduced effects, expiry during a cast, transfer during a telegraph and fixed-seed projectile counts. After mechanical verification, ask the owner only:

- Did Command Fire and Q feel like two distinct coordinated attacks rather than duplicated clutter?
- Could you predict when the relay would fire?
- Did placing and swapping the relay create a decision worth making?
- Did 30 seconds feel like useful territory, a maintenance chore or too permanent?

Only then add a second relay, EMP and the first E line. The third relay, Battle Order and Overclock should wait until the basic network is fun.

## Open decisions for owner review

- Does Relay Network regeneration stack per relay, apply only once or require standing within X?
- Should Q missiles also explode on the first enemy/terrain collision, or only at maximum distance?
- Is Arc Relay's third projectile better as chaining damage, a slow or another support effect?
- Are summons destructible as well as timed? The current owner note confirms the lifetime but does not settle health.
- Does normal repositioning preserve or refresh the 30-second lifetime?
- During a normal software transfer, which health value and cooldowns follow the player's control software versus the physical chassis?
- Does Focus/Coverage still deserve slot 4 after Command Fire gives the player direct focus control?
- What happens when Overclock ends without any switch: relays simply return to normal, or fire one final missile volley?
