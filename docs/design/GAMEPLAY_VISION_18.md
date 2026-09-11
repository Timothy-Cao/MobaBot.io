# Gameplay vision — owner direction

10 September 2026. This is the current owner-authored north star for evaluating combat, progression and future kits. It describes the intended experience, not what automated tests prove and not a command to rebalance the frozen playtest build immediately. Where older notes emphasize isolated power or a particular implementation, use this vision to judge the result.

## The intended experience

**Power should create more good decisions, not remove the need to make them.** The player grows from a scrappy robot into a powerful machine while still reading threats, choosing the right part of the kit and changing plans as the fight changes.

1. **Use the whole kit situationally.** Combat alternates between repositioning, retreating, sustained damage, kiting and burst. Varied immediate threats change the useful action order: the same tools may be sequenced or aimed differently against a boss, a crowd, a ranged threat or a dangerous approach. One repeated rotation should not solve every encounter.
2. **Different tools solve different problems.** Players may focus upgrades temporarily, but one skill, combo or item must not overshadow the rest of the kit. Easy-to-execute, high-impact, boss-focused, crowd-focused, close-range and long-range tools can all be strong in their intended contexts without being universal answers.
3. **Both sides visibly grow.** The player should feel stronger within a round and after every stage. Enemies should keep pace through readable new pressure and mechanics, not health inflation alone. Progress may come from tactical understanding, ability upgrades, mastery or—when appropriate—replaying cleared content for equipment.
4. **Support active and passive play without confusing their roles.** Frontier progression emphasizes active decisions and outplay. Cleared or lower-difficulty content may support reliable low-input/AFK builds, and a fortunate run may temporarily overpower the current round. Controlled variance should create struggle, relief and occasional dominant highs without making outcomes arbitrary. Effort and choices should leave the player with some useful progress even when a run is not a full clear.
5. **Every ability needs a reason and a cost.** Each tool should feel meaningful, interesting or fun and create some decision about timing, target, position or resource. A tool that is always pressed whenever available needs a tradeoff or a more specific purpose. A tool that is consistently ignored needs a clearer use, stronger payoff or replacement. Alternatives do not need identical power, but they should be close enough in total value that the player briefly considers which solution fits the moment.

## Desired combat rhythm

Read the immediate threat → select a response → position and execute → take the payoff or recover → reassess.

This rhythm may produce short damage windows, defensive retreats, collection windows and moments of overwhelming power. The encounter should keep asking a new question before the previous answer becomes an automatic loop. Passive damage supplies continuity; it should not erase aiming, movement, timing or target selection when the player is pushing difficult content.

## Design tests for abilities and encounters

Use these questions before changing numbers:

- In what situation is this tool the best answer, and in what situation is it a poor answer?
- What does the player give up by using it now: position, time, energy, safety, future cooldowns or another opportunity?
- Does another part of the kit provide a credible alternative, setup or follow-up?
- Can enemy composition or behavior change the useful cast order?
- Does an upgrade make the tool more expressive or applicable without erasing its weakness?
- If players use it constantly, is that intentional passive continuity or an active button with no real decision?
- If players avoid it, is the problem power, clarity, execution burden, opportunity cost or lack of a relevant encounter?

Equal usage is not the goal. Situational purpose, understandable tradeoffs and multiple viable responses are the goal.

## Progression and variance guardrails

- Let players focus a few tools for a period, while ensuring the full kit continues to progress and remains relevant.
- Introduce enemy mechanics that reward different answers. Avoid solving difficulty mainly by extending health bars.
- Preserve meaningful run variance: some runs should be tense and some should produce an exciting power spike. Avoid a single rare roll that makes every later decision irrelevant.
- Reward partial progress proportionally. Persistent gains should make another attempt feel worthwhile without making grinding mandatory for a learnable baseline difficulty.
- Low-input farming should be safest on content the player has already demonstrated they can clear. Level-pushing builds should retain a meaningful advantage from active execution.

## Current playtest feedback and combat hypotheses

These are the owner's latest observations and ideas. The hull-bar issue is direct presentation feedback; restored projectile cover is a proposal rather than implemented behavior. A briefly proposed guided hold-Q has been withdrawn: normal-mode Impact Bolt should remain simple and straight.

### Make the player hull bar substantially easier to read

The world-space hull bar over/below the player is currently too small. Increase its width, height, contrast and depleted-background clarity enough to read health peripherally at normal combat zoom and maximum zoom-out. Low-health state changes should remain visible without relying only on color, but the bar must not obscure the robot, aim direction or nearby collision. Check actual gameplay size, HUD scaling and Reduced effects rather than approving a magnified fixture.

### Keep normal-mode Impact Bolt simple

The owner withdraws the guided hold-Q proposal. Preserve the immediate straight rocket as Vanguard's normal Q rather than adding manual flight control. Long-range and alternate-fire complexity belongs in the temporary turret form described below.

### Reconsider permeable projectile cover

The owner now leans toward making projectiles collide with walls again. Treat this as the latest desired direction for a future prototype; the current build still allows shots through walls. A first coherent rule should make discrete friendly and hostile projectiles respect thick cover symmetrically. Normal Impact Bolt should explode on wall contact.

Define ground-targeted W/R, continuous beams, enemy targeting, turret acquisition and boss attacks separately instead of calling every effect a projectile. Enemies should not repeatedly fire ordinary shots through known blocking cover, previews must communicate legal paths, and collision must use the same wall thickness the player sees. Restored cover should create lane, flank and safety decisions without enabling effortless permanent hiding or making fights stall.

## Encounter and drop ideas to consider

These are owner ideas for later prototypes, not implemented rules.

### Rare monster health drops

Ordinary or selected enemies may rarely drop a clearly recognizable hull-repair pickup. This could create clutch recovery, a reason to enter danger to collect it and occasional relief during a difficult round. Keep the chance low enough that baseline encounters remain winnable without receiving one and do not tune incoming damage around lucky healing. Decide whether elites have a higher chance, whether the drop expires, whether missing hull affects its probability and how magnet/AFK builds interact with it. A suitable test asks whether the pickup creates a meaningful route decision rather than merely erasing the last mistake.

### Enemies that interfere with vision

Explore a readable specialist that temporarily limits the visible world to a circle roughly comparable to Impact Bolt's range. The source, warning, affected boundary, duration and way to end the effect must be understandable; possible counterplay includes killing the jammer, leaving its area, breaking line of sight or using a future cleanse/sensor response.

A second “hacked” variation could interfere with perception in a different way—such as controlled signal noise, false contacts or unreliable peripheral information—without simply making the entire screen illegible. Preserve the player, HUD, terrain immediately around the player, critical damage tells and valid aim/collision information. Avoid rapid flashing, camera shake, forced blur and color-only communication; Reduced effects and accessibility settings must retain the mechanic while reducing discomfort.

Vision pressure should change positioning and target priority, not create unavoidable damage from attacks the game made impossible to read. Prototype one mild version in Practice before combining it with other specialists, and test it at different resolutions, zoom levels and effect settings.

## Vanguard modules to reconsider

These are owner hypotheses for the next design discussion, not locked replacements and not approval to change the current playtest build before feedback.

The latest candidate 1–4 layout is: 1 Orbit unchanged; 2 energy-regeneration totem; 3 stored-repair Reserve; 4 temporary turret/siege form. This removes Bulwark's autonomous firing body from Vanguard and keeps independent turret damage as a stronger fit for Marshal.

### Reserve — preserve the distinct idea

The stored-repair module is promising because it asks the player to leave its area, let it accumulate value and deliberately return. Preserve that leave-and-return identity. Its presentation must clearly communicate three states:

- **Charging while away:** a visible meter/fill motion grows and energy flows into the totem.
- **Draining while occupied:** stored value visibly transfers toward the player and the meter falls.
- **Empty while occupied:** the housing becomes visibly dormant and uses a slow, restrained cue that teaches the player to step away before it can charge again.

Test whether stored amount and readiness can be understood without a tooltip. Moving/replacing still clears its store. Reactivating the deployed totem should instead detonate and remove it, trading its remaining support value for damage; exact damage scaling, trigger confirmation and cooldown timing remain open.

### Replace Bulwark with an energy-regeneration totem

Remove the autonomous shooting/aggro turret from Vanguard's candidate kit. In slot 2, explore a totem that supplies very fast energy regeneration inside a clearly visible area but does not modify cooldowns. This supports a sustained casting position without supplying free remote damage.

Like Reserve, pressing its key again while deployed should detonate and remove it for damage. Detonation must sacrifice meaningful remaining support time or stored value so it is a choice rather than a free expiry explosion. Define lifetime, aura size, whether it is targetable, recharge timing, detonation scaling and whether repositioning is allowed before implementation. Follow the existing ownership rule unless deliberately changed: a non-aggro support construct is untargetable and expires rather than drawing attacks.

Do not let the two detonations become interchangeable damage buttons. Their output or secondary behavior should reflect what is being sacrificed—for example, remaining energy-support time versus stored Reserve charge—and each should have a situation where retaining the field is preferable.

### Replace Overclock well with a temporary turret form

Slot 4 becomes a high-damage siege decision rather than a deployable cooldown aura. Activation takes about one second and visibly transforms Vanguard into a planted turret. The player cannot move under their own control while transformed. D and F are disabled; neither Ghost Drive nor Phase Hop can escape the commitment. Leaving takes about 0.5 seconds; the mode ends automatically after at most ten seconds. A second slot-4 press should begin the early exit unless later input testing finds a clearer command.

Turret form temporarily replaces Q/W/E/R:

| Input | Turret-form action | Intended decision |
| --- | --- | --- |
| Q | Rapid, high-spread stream of small explosive missiles at roughly the permanent machine gun's cadence. The normal passive machine gun is disabled during the form. | Sustained damage and distributed crowd pressure when the player has found a safe firing position. |
| W | Much longer-range bombardment with roughly a two-second recharge. | Reach priority targets or distant packs while immobile. Exact projectile/ground-target and wall rules remain open. |
| E | Channeled self-repair; no other action can be performed during the channel. | Sacrifice the siege damage window to recover when remaining planted is safer than exiting. |
| R | Large high-damage local EMP/pulse on roughly a 30-second cooldown. | Emergency answer when a swarm reaches the immobile player; not a routine part of every form. |

Q's initial damage target is approximately 1.5 times the combined normal-Q plus permanent-gun single-target output over the same comparison window. Balance this as a time-window budget, not “each miniature missile deals 1.5×”: individual missiles should be substantially smaller and weaker. Measure splash separately and use small radius, falloff or another cap so a modest single-target increase does not become an uncontrolled crowd multiplier.

The owner is open to reducing some normal-form damage because siege form may become a major damage source. Do this only after measuring achievable siege uptime and damage in representative encounters; entering an unsafe form should not be required merely to recover power removed from the dependable normal kit.

The transformation should show chassis anchoring, weapon deployment and a clear completion frame without delaying control beyond the real one-second rule. The action bar should visibly change to the turret Q/W/E/R set, and the turret should track mouse aim without implying it can move. Existing passives may continue unless a specific interaction proves degenerate; the permanent gun explicitly does not. D/F remain unavailable from entry commitment through completed exit. Hammer, other modules, interruption by damage, protection during transformation, W targeting and cooldown persistence across form changes still require decisions before implementation. R's 30-second cooldown should not reset by leaving and re-entering.

The intended test is whether the player recognizes a genuinely safe damage opportunity, commits, then chooses among sustained Q, distant W, defensive E, emergency R or early exit. If the correct answer is always to enter on cooldown and hold Q for ten seconds, the form has failed the gameplay vision.

### Conveyor belts as terrain synergy

Explore clearly directional conveyor belts in selected maps or Practice. A planted turret cannot walk, but a belt may carry its world position, creating planned firing routes, forced exits and unusual siege angles. Conveyors may also affect enemies if that produces predictable positioning play. Their direction, speed, start/end and collision consequences must be obvious before commitment; they must not drag the player into an unavoidable hazard or softlock them against terrain. Test ordinary movement, E/body slam, F, constructs, pickups and enemy routing separately rather than assuming every object rides the belt.

## Evidence needed from future tests

Current completion logs and cast totals cannot establish this vision by themselves. Future playtests should pair player comments with:

- successful casts, hit rate, targets hit and damage by source;
- healing, damage prevented, aggro diverted and cooldown time saved for utility tools;
- energy spent, time ready-but-unused and time active for toggles/stances;
- common ability sequences by threat type rather than one global usage total;
- deaths or major damage shortly after a committed action;
- the player's stated reason for using or withholding each tool.

Treat an ability as a balance concern when its measured behavior and the player's explanation agree. A low cast count alone may mean the relevant situation never appeared; a high count alone may reflect short cooldown rather than meaningful value.

## Current decision boundary

Use this document to interpret the next Vanguard playtest. Do not tune every ability toward equal damage or equal cast count, and do not implement every module alternative at once. First identify which current actions are automatic, which are ignored, and which threat patterns genuinely change the player's plan. Then prototype one tradeoff at a time in Practice before changing campaign progression.
