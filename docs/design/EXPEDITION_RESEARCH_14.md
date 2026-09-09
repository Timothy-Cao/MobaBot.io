# MobaBot.io expedition design

## Design position

MobaBot.io is best positioned as a mouse-controlled action roguelite: the crowd pressure and temporary build growth of a survivor game, with a small number of deliberate MOBA decisions. Its differentiator is not the number of spells. It is the coexistence of an independent automatic weapon, commanded basic attacks, aimed skills, energy-powered toggles and placeable machines. Movement should create damage opportunities, not merely delay inevitable contact.

Riot's Swarm is a particularly relevant precedent. Its official introduction describes a survivor mode using League characters, automatic or manually aimed basic weapons, environmental pickups, persistent progression, several difficulty levels and combinations of weapons and augments. Importantly, Swarm uses WASD; it is evidence that the audience and mechanical combination are plausible, not evidence that League mouse movement automatically works in a survivor game. MobaBot must validate that control choice independently. [1](https://www.leagueoflegends.com/en-us/news/game-updates/anima-squad-2024-everything-you-need-to-know/)

The north stars are:

- **Useful movement:** a short reposition can line up a return blade, reach a chest, dodge a charge or bring a construct into play.
- **Visible growth:** a good build increases coverage and changes positioning decisions, not just floating numbers.
- **Manageable inputs:** the automatic gun remains useful; active commands offer additional agency rather than an eight-button maintenance rotation.
- **Recoverable failure:** a lost run ends its temporary build but leaves a bounded equipment collection worth returning to.
- **Consistent readability:** the player, threats, reward objects and action effects remain distinguishable under load.

These are design judgments, not claims of commercial validation. No successful reference removes the need for representative human playtesting.

## Lessons from established games

| Reference | Relevant design lesson | Adaptation | Boundary |
| --- | --- | --- | --- |
| League / Swarm | Combine recognizable combat actions with repeatable PvE progression | Independent auto gun plus deliberate commands | No champion names, copied art, multiplayer or Summoner's Rift simulation |
| Vampire Survivors Adventures | A fresh limited arsenal can coexist with an enduring account | Run-only skill discovery; persistent equipment | Avoid importing its exact currencies or ascension formula |
| Slay the Spire | Difficulty tiers support different skill levels; metrics complement feedback | Sequential A0–A5 access, disclosed modifiers, repeatable simulations | Automated win rate is not a fun score |
| Hades | Repeated defeat can still produce meaningful progress and varied builds | Bank equipment and resources at safe breaks | Do not assume a narrative-driven retention loop exists without narrative content |
| Survivor.io | Crowd-clearing, boss-focused and protective tools fill different needs | Coverage versus aimed burst versus defense versus constructs | Avoid making one universal damage stat the only relevant choice |

Poncle's Adventures FAQ describes chapter-specific setups and winning conditions, a largely fresh progression path and retained main-game unlocks. It also describes merchants and resetting an Adventure through ascension. The page contains differing historical ascension numbers in adjacent answers, so those figures should not be treated as a clean current tuning specification. The durable lesson is the separation of progression scopes. [2](https://poncle.games/adventures-faq)

The Slay the Spire GDC presentation explicitly connects balance with iteration, internal playtesters, community feedback, metrics and sequential ascension unlocks. Its caution that data is evidence rather than a conclusion is especially relevant here: a controller that survives for longer is not necessarily a build people enjoy. Balance analysis should compare play styles, not collapse them into a single simulated optimum. [3](https://media.gdcvault.com/gdc2019/presentations/Giovannetti_Anthony_SlayTheSpire.pdf)

Supergiant's Hades FAQ describes both build variation and permanent progression, with additional difficulty customization. These are complementary axes: a player can become more capable while opting into a harder challenge. MobaBot should offer lower-ascension farming without requiring repetitive farming before the basic game becomes playable. [4](https://www.supergiantgames.com/blog/hades-faq/)

Apple's Survivor.io editorial guide distinguishes defensive tools, area-clearing tools and boss-focused weapons, and highlights weapon evolution and timing pickups. This is useful descriptive evidence, although it is an editorial guide rather than a developer's design postmortem. The adaptation is to give each family a recognizable job and make pickup timing matter. Exact live balance values are not being borrowed. [5](https://apps.apple.com/gb/iphone/story/id1641743438)

## Controls and action economy

There are two separate attack systems. The autonomous gun continuously looks for a nearby target when powered. It does not obey S or commanded movement. The commanded basic attack obeys right-click enemy orders, approaches into range, and stops when S is pressed. A followed by a click selects an attack-move objective using cursor priority. This separation is important: an automatic weapon should not unexpectedly stop because the player used a familiar MOBA command.

The danger is that two basic systems become indistinguishable. Their projectiles need different lengths, cadence or brightness, and damage accounting must identify the source. Only commanded basics should trigger mechanics that reward deliberate attack orders. Otherwise an item described as rewarding skillful kiting actually rewards simply standing nearby with the automatic gun enabled.

Q remains a common starting skillshot across classes. W/E provide additional actions through discovery; R is a high-impact commitment; D/F are escape or movement tools; T owns construct deployment. Slots 1–4 are powered modes, not four more rotational spells. The player should be able to discover a low-mechanics build without losing access to meaningful movement choices.

Input recasts need explicit ownership. Echo drive returns to its saved origin only during its short window. Crosswire accepts a second endpoint only while the first anchor exists. Artillery accepts a bounded number of shells. Cancelling a channel must not also execute an unrelated move or spend another charge accidentally. A short recast indicator belongs on the existing ability tile; a new explanatory panel does not.

The three classes are starting biases rather than exclusive content silos. Gunner rewards commanded attacks and spacing. Brawler trades range for hull, repair and close-range damage. Engineer gains more value from construct placement and capacity. Different presets can share several abilities without becoming the same experience because their range, defenses and ownership rules differ.

Riot's Naafiri design discussion is useful for the summon direction. It describes the technical work required to make a pack responsive, correctly positioned and easy to command. A simple control scheme can depend on substantial behavior logic underneath it. For MobaBot, constructs should follow consistent target policies and never require selecting several units individually. [6](https://www.leagueoflegends.com/en-us/news/dev/champion-insights-naafiri/)

## Ability families and tradeoffs

### Aimed range

Return blade rewards movement after the cast, because the return path changes with the player's position. A per-leg hit ledger prevents a large target from taking damage every simulation tick. Core strike rewards aiming its smaller center. Gravity well buys room and groups ordinary enemies, but bosses resist its pull. Crosswire rewards geometry and planning rather than reflexive button mashing.

Plate magazine and Plate recall form a deliberate two-part build. Commanded hits leave a bounded number of plates; recall converts the layout into intersecting damage lines. A three-hit payoff uses a target-specific counter with expiry. Side bolts have their own source tag and cannot trigger another generation of side bolts. These restrictions protect both balance and frame time.

### Melee

Rim cutter distinguishes its inner and outer region. Standing directly inside every enemy is less rewarding than landing the outer rim. Healing has a per-cast cap so a huge wave does not instantly restore full hull. Guard sweep offers a temporary block only when it connects. Piston thrust gives a predictable empowered third cast; its longer geometry must be visible, not merely numerical.

Tractor cone and Repulsor are opposite positional tools. The former can bring ordinary enemies into a melee payoff; the latter creates an escape lane and interacts with placed plates. Scrap crusher has strict eligibility: an ordinary, sufficiently weakened target, not a boss execution shortcut. Self repair is a commitment interrupted by movement or damage, not passive invulnerability disguised as healing.

### Movement

Tumble is a short dodge with a next-basic reward. Echo drive adds a temporary return point. Veil drive creates a brief pursuit decoy and intangibility. Spring vault and Orbital entry visibly commit to landing impacts. Wall runner requires an actual barrier and keeps per-barrier reuse limits. Scrap pursuit refunds a charge only on its own successful kill.

Ballast roll is a steerable acceleration-and-crash tool, not an instantaneous blink. Speed and impact damage are capped. Flywheel offers a related powered build: movement creates a collision payoff, followed by recovery time. Hop drive must never move the player without a command; it stores permission for a short hop after a commanded basic attack.

### Constructs and powered modes

The major-summon registry owns stable IDs, lifetime, capacity and replacement order. A capacity increase must create an additional entity, not silently extend one legacy dictionary. Forward-fire, pulse, repair, mirror, hook and moving-explosive behaviors share a mechanical body grammar but retain distinguishable symbols.

Mirror effects call a non-recursive effect primitive, not the player's cast function. They do not spend player energy a second time or activate another mirror. Repair and pulse constructs offer teleport/swap interactions without adding a new global key. Small mounted drones are a different budget from major constructs; the equipped pet remains one choice.

Powered toggles should have opportunity costs. Short-range fast Tesla fire versus slower long-range fire changes positioning. Poison stops laying patches when disabled, but existing patches expire normally. The life converter needs a lower health floor, a maximum-energy cap and no resource creation from rounding. Utility such as pickup reach remains outside the passive-slot tax.

## Progression and reward economy

Four separate progression channels serve different purposes:

1. **Ranks** improve the currently equipped abilities. Milestones increase meaningful geometry or behavior.
2. **Discoveries** unlock or replace a slot. A duplicate active grants two ranks, with capped-rank overflow converted to field currency.
3. **Run mastery** supplies reusable build decisions, including utility, defense, energy and command strength.
4. **Equipment** supplies enduring collection goals through replacements, duplicate stars and bonus rerolls.

These channels should not all pay out from every dot. Ordinary XP pickups support a frequent, legible rhythm. Chests belong to stronger enemies, occasional level milestones and round completion. Equipment is the rarer chest outcome. This preserves anticipation while avoiding a constant sequence of nested modal rewards.

Early chest choices should include useful locked slots. They should not strand a player with several duplicate rewards before W or E appears. Later choices can mix new actions, duplicates and rarity increases. Replacement consequences must be stated before confirmation: the incoming ability occupies the displayed slot and starts its own rank progression. Randomness should alter a build, not silently invalidate it.

Field credits are a run-shopping resource. Banked credits belong to the permanent workshop. The distinction prevents buying permanent upgrades with a number that appears to reset, or allowing a failed run's temporary shop balance to leak unpredictably into the account. Shops between stages provide a change of pace and a safe place to reconsider equipment or refund mastery.

Eight equipment slots and five sets create forty base combinations. The asset problem is therefore eight silhouettes and five coherent motif variations—not forty independent concept paintings. Exactly two- and four-piece thresholds create useful mix-and-match decisions. Only equipped items contribute. A large collection should expand options, not grant hidden cumulative power from every item ever owned.

Persistent power needs a ceiling. Stars stop at five; one owned copy is retained; rerolls affect the bonus rather than rewriting the base item; stat budgets cap extremes such as movement speed, cooldown acceleration and summon capacity. Lower tiers remain farmable, while harder ascensions offer modest reward advantages. The goal is to make equipment matter without erasing the action game.

Community discussions disagree about permanent stat progression. Some developers value it as a route past a player's mechanical skill ceiling; others worry that it replaces learning with repetition. These are anecdotal perspectives, not population-level evidence. The practical response is to keep A0 viable with starter equipment and judge both survival and repetition during playtests. [7](https://www.reddit.com/r/gamedev/comments/j7c6ct)

## Campaign pacing and pressure

The route has 22 rounds across eight stages. Neutral rounds establish crowd patterns; boss rounds test aimed damage, evasion and commitment; loot rounds offer a shorter, denser reward opportunity. Shops occur after stages two, five and seven. Ascension zero is the base route; subsequent tiers introduce disclosed combinations of harder enemy damage, hull, movement, recovery windows or resource pressure.

An authored schedule is preferable to increasing spawn rate forever. A useful pressure sequence is approach, surge, response window and reward. Faster units alter escape routes; tanks hold space; aimed attacks punish standing still; bosses temporarily concentrate the player's attention. Recovery windows should permit a counterattack rather than simply allow more running away.

Boss identities can initially share a body, but their behavior must differ. Ordered patterns, reinforcement timing, recovery periods and escalation thresholds are more important than a new name and a larger health bar. The final encounter should combine learned responses rather than introduce several unreadable mechanics simultaneously. Reused arena sectors are acceptable for a first expedition, provided they are not advertised as eight distinct handcrafted maps.

Obstacles create additional movement decisions but are also a major exploit risk. Ordinary enemies need a route around barrier ends. Projectiles and ordinary dashes must respect the visible wall. Vaults and explicitly phasing actions are exceptions. Large bosses need a clear way to break or bypass barriers so a temporary wall cannot permanently disable them.

## Visual hierarchy and interface

Riot's VFX style guidance connects effect importance to gameplay importance. A basic attack should not command the visual attention of an ultimate; color, shape, value and timing should communicate function and power. This supports restrained automatic shots, a distinct aimed Q and more conspicuous committed impacts or channels. More brightness on every effect would weaken that hierarchy. [8](https://nexus.leagueoflegends.com/en-us/2017/10/dev-leagues-vfx-style-guide/)

Riot's clarity article emphasizes readable silhouettes, truthful hit areas and minimal accumulated noise. Its later Lee Sin visual update specifically describes reducing distracting elements and toning down basic-attack brightness where it implied too much power. These are useful examples of subtraction improving perceived quality. [9](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/) [10](https://www.leagueoflegends.com/en-gb/news/dev/dev-modernizing-the-monk/)

The medium-detail salvage-tech icon family should remain consistent across HUD, rewards, loadout, mastery and equipment. Steel edges, teal housings, brass accents and cream highlights are enough to convey mechanical objects at small size. Silhouette does the primary work; material differences are secondary. Threats retain contrasting colors and unmistakable timing cues. Reduced effects removes decoration, not the information required to dodge.

Riot's item-shop update explicitly prioritizes small-size icon recognition and matching icon theme to gameplay. It does not recommend making inventory icons miniature wallpapers. For MobaBot, eight clear slot shapes with controlled set treatments are a stronger production foundation than richly painted but mismatched pieces. [11](https://www.leagueoflegends.com/en-us/news/dev/preseason-item-shop-update/)

The interface stays small: five home actions, a short class/difficulty preparation screen, the existing combat dock and two Build pages. Mastery may contain many nodes without putting forty-eight paragraphs onscreen. Node icons, prerequisite lines, ranks and one hover/focus inspector are sufficient. Equipment needs fitted slots, a filtered collection and one comparison—not a separate dashboard for every system.

Minimalism must not conceal transactions. Costs, replacement consequences, unspent points, save failures and irreversible abandonment remain visible when relevant. Equipment set explanations belong in hover details; a failed save does not. Input bindings belong in settings, not across the center of the arena.

## AI-assisted production and quality

Recent r/aigamedev discussions expose disagreement about the label “AI slop.” Some participants emphasize originality and intentional design; others emphasize inconsistent art, animation, fonts and UI. A separate discussion contrasts attractive presentation with unengaging play. These are selected anecdotes from a self-selected community, not proof of what most customers believe. Their useful common denominator is that output must be evaluated as a complete playable experience. [12](https://www.reddit.com/r/aigamedev/comments/1w4k98u/here_is_why_most_ai_games_are_ai_slop/) [13](https://www.reddit.com/r/aigamedev/comments/1vwwggs/what_creates_slop/)

Two consistency discussions describe the difficulty of maintaining a style across many generated assets. Advice to reuse a style guide is plausible, but examples also report references failing to transfer cleanly. There is no basis here to promise that a single prompt or subscription solves the animation bottleneck. [14](https://www.reddit.com/r/aigamedev/comments/1smb4k4/art_style_consistency_volume/) [15](https://www.reddit.com/r/aigamedev/comments/1tobieh/how_do_you_manage_consistency_and_coherence/)

The recommended division of labor is therefore deliberate. Use deterministic code-native art for repeatable icons, actors, collision-aligned effects and simple mechanical animation. Reserve generated bitmap illustration for places where a single accepted image has high value, such as the existing title background. Preserve provenance and do not describe native variations as separately painted illustrations. A future artist can replace a well-defined family without having to reverse-engineer forty unrelated images.

Animation should come from reliable primitives: rotation, recoil, banking, extension, landing, fading and trails. The robot theme makes these legitimate expressive choices rather than placeholders for missing human animation. Distinct actions still need distinct timing and response. Reusing the same pulse for every spell would undermine both clarity and perceived authorship.

## Engineering and verification

Godot's optimization guidance recommends identifying bottlenecks through measurement rather than speculative optimization. The existing simulation/presentation separation and projectile spatial index are useful foundations. New systems need explicit bounds: major summons, blades, fields, plates, wall count, chain targets, hit ledgers and visual event pools. Profiling should include a busy late build, not only a clean title screen. [16](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html)

Godot's saving guide demonstrates explicit serialization and notes the need to transform unsupported data types when using JSON. A production-oriented local save should additionally validate fields, version its schema, write a temporary file and preserve unreadable originals. These safeguards are recommendations for this project, not a claim that the tutorial itself guarantees transactional persistence. [17](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)

The save boundary should be a round break. Equipment rewards, the remaining chest count and the checkpoint belong in one transaction so a reload cannot award the same collection item again. Random state should persist rather than reroll offers on restart. A resumed run should retain consumables, allocated points, purchased equipment and its existing stat snapshot. A damaged checkpoint must be rejected without overwriting the source file.

Verification requires several kinds of evidence. Unit tests check geometry, eligibility, recasts, costs, source tags, caps and save validation. Integration tests check complete transitions between combat, upgrades, chests, camp, shops, equipment and resumption. Rendered captures check actual scale, clipping and hierarchy. Behavior probes compare idle, moving and actively managed builds. Human testing answers the remaining questions: whether dodging feels crisp, new tools arrive quickly enough, rewards are satisfying, and the full route is worth finishing.

## Sources

Sources were consulted for design principles and implementation guidance, not copied balance tables. Historical developer articles are dated below; community posts are anecdotal and not representative samples.

1. Riot Games. [Anima Squad 2024: Everything You Need To Know](https://www.leagueoflegends.com/en-us/news/game-updates/anima-squad-2024-everything-you-need-to-know/). July 17, 2024.
2. poncle. [Adventures FAQ](https://poncle.games/adventures-faq). Undated living FAQ; adjacent ascension figures are inconsistent.
3. Anthony Giovannetti / Mega Crit. [Slay the Spire: Metrics Driven Design and Balance](https://media.gdcvault.com/gdc2019/presentations/Giovannetti_Anthony_SlayTheSpire.pdf). GDC 2019, especially slides 6–15 and 20.
4. Supergiant Games. [Hades FAQ](https://www.supergiantgames.com/blog/hades-faq/). Living FAQ, updated July 16, 2025.
5. Apple App Store. [5 tips for Survivor.io](https://apps.apple.com/gb/iphone/story/id1641743438). Undated editorial guide.
6. Riot Games / Karnifexlol. [Champion Insights: Naafiri](https://www.leagueoflegends.com/en-us/news/dev/champion-insights-naafiri/). June 22, 2023.
7. r/gamedev participants. [Roguelite meta-progression](https://www.reddit.com/r/gamedev/comments/j7c6ct). October 8–9, 2020.
8. Riot Jino. [/dev: League's VFX Style Guide](https://nexus.leagueoflegends.com/en-us/2017/10/dev-leagues-vfx-style-guide/). October 25, 2017.
9. Riot Games / bananaband1t. [Clarity in League](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/). March 12, 2021.
10. Riot Games. [/dev: Modernizing the Monk](https://www.leagueoflegends.com/en-gb/news/dev/dev-modernizing-the-monk/). 2024.
11. Riot Games. [Preseason Item Shop Update](https://www.leagueoflegends.com/en-us/news/dev/preseason-item-shop-update/). 2020.
12. r/aigamedev participants. [Here is why most AI games are AI slop](https://www.reddit.com/r/aigamedev/comments/1w4k98u/here_is_why_most_ai_games_are_ai_slop/). September 1–3, 2026.
13. r/aigamedev participants. [What creates slop?](https://www.reddit.com/r/aigamedev/comments/1vwwggs/what_creates_slop/). August 24, 2026.
14. r/aigamedev participants. [Art Style Consistency & Volume](https://www.reddit.com/r/aigamedev/comments/1smb4k4/art_style_consistency_volume/). April 15, 2026.
15. r/aigamedev participants. [How do you manage consistency and coherence](https://www.reddit.com/r/aigamedev/comments/1tobieh/how_do_you_manage_consistency_and_coherence/). May 26, 2026.
16. Godot Engine contributors. [General optimization tips](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html). Stable documentation, accessed September 8, 2026.
17. Godot Engine contributors. [Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html). Stable documentation, accessed September 8, 2026.
