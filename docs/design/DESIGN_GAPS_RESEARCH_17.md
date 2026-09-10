# MobaBot.io · Design Gaps Research

9 September 2026. This report investigates the six research areas requested after the 0.17 documentation cleanup: encounters, progression/economy, onboarding, accessibility/camera comfort, art/animation production and playtesting. It is a design input for future milestones, not a description of implemented behavior.

## Executive recommendation

MobaBot does not need six new systems at once. It needs one repeatable learning loop:

1. rebuild Practice as a safe, fast experiment surface;
2. use Vanguard as the first stable test kit;
3. test a small encounter grammar, teaching sequence, camera profile and representative animation set together;
4. improve those until players can read, control and enjoy the first three rounds;
5. only then tune permanent/offline progression around measured manual play.

The strongest common lesson across the reference games is **structured variation**. Left 4 Dead varies pressure inside an authored pacing envelope; Doom combines a small readable enemy vocabulary; Plants vs. Zombies introduces one idea at a time; Hades combines repeated runs with bounded permanent help; League prioritizes gameplay hierarchy over spectacle. None succeeds by maximizing the number of enemies, abilities, rewards or visual effects.

### Priority matrix

| Area | Current risk | First useful artifact | Decision gate |
| --- | --- | --- | --- |
| Practice foundation | Current tool is too slow for systematic comparison | Class-first left dock, mouse placement, reset, local test summary | Owner can set up the same fight twice without instructions |
| Encounter design | Weakest rated area; repeated spaces and long flat survival windows | Three encounter cards using existing enemies and greybox terrain | Each card creates a different response and includes a genuine recovery window |
| Vanguard onboarding | Future kit adds many simultaneous verbs | A non-modal, do-once teaching sequence | Fresh players use movement, hammer, Q and one escape without coaching |
| Camera/accessibility | Racer, detached camera and dense VFX can compound discomfort | Normal, Reduced and Racer comfort profiles | Critical threats remain readable with effects reduced; 30-minute comfort pass has no forced-motion blocker |
| Animation production | Perspective and generated-animation workflow are unresolved | One five-action comparison sheet in current, top-down and hybrid views | One direction wins at actual combat size without lying about collision or multiplying asset cost |
| Progression/economy | Boxes, charms, consumables and offline salvage could obscure the core game | Source/sink ledger plus deterministic 1,000-claim simulation | Manual play remains the best way to progress; offline claims are safe and understandable |
| Playtesting method | Owner notes, automated tests and research can blur together | One shared session record and decision log | Every meaningful change names its evidence, finding and retest condition |

## Evidence rules

- **External evidence** explains a reusable principle or a precedent. It does not prove the same result in MobaBot.
- **Project recommendation** is the assistant's synthesis for this game.
- **Prototype value** is a starting hypothesis, not borrowed balance data.
- **Owner decision** remains authoritative where it conflicts with a recommendation.
- **Human experience** is never inferred from a passing fixture, bot survival time or rendered screenshot.

## 1. Enemy and encounter design

### What has worked elsewhere

Valve's Left 4 Dead director separates pacing from raw difficulty. It estimates player intensity, builds pressure, sustains a peak briefly, lets the current fight fade and then enforces a quiet period. Valve explicitly describes changing the **frequency** of danger rather than its amplitude, and keeping bosses outside this adaptive loop because their presence defines the larger rhythm.[1]

The same system uses “structured unpredictability”: designer-bounded random intervals, spatial rules and mixtures of common enemies, rushes, special threats, bosses and resources. It avoids both perfectly static memorization and unbounded randomness.[1] This distinction matters for MobaBot. A run can vary without allowing three Bomb carriers and two Arc lancers to create an unreadable off-screen checkmate.

Doom's durable enemy vocabulary is based on orthogonal sizes, speeds, durability, movement and attack patterns. Mixing a durable anchor with fodder asks for crowd management plus focus fire; flying or ranged pressure changes the useful terrain; melee pressure in tight space changes movement.[2] The content value comes from interactions between readable roles, not from every enemy owning a long move list.

Riot defines counterplay as actions, choices or strategies that mitigate a threat. Tactical counterplay includes dodging, interrupting windups and positioning; strategic weaknesses should create a disadvantage without turning the encounter into a no-chance matchup.[3] Its clarity framework adds that effect prominence, hitbox truth and information hierarchy should track gameplay importance.[4]

Riot's Star Guardian: Invasion team began with a grey square and enemies from four corners. That prototype made damage dealers feel useful but left support and non-AoE kits weak. The team then built situations around familiar enemy archetypes so existing MOBA kit verbs had jobs and players could learn threats economically.[5] The relevant lesson is to test whether an encounter validates the whole kit, not merely whether enemies die.

Boss research frames a boss as a reward and a skill test: build anticipation, telegraph attacks, leave negative space where survival is possible, support more than one solution and add phases only when they change/combine mechanics or create a mental break.[6]

### Recommended MobaBot enemy vocabulary

Every ordinary enemy should have one primary combat verb and at most one modifier. Use these roles as tags in data and Practice:

| Role | Primary question for the player | Existing or likely example | Design guardrail |
| --- | --- | --- | --- |
| Crowd | Can I maintain space and wave clear? | Basic melee swarm | Low individual salience; should not hide priority tells |
| Pursuer | Can I change route or spend movement? | Faster melee unit | Avoid unavoidable speed without turn/commitment limits |
| Anchor | Can I focus or displace a durable space-holder? | Tank/heavy | Durability must support another threat, not only lengthen time-to-kill |
| Line pressure | Can I leave a declared lane? | Arc lancer | Lock aim before fire; beam and collision agree |
| Spread pressure | Can I read and route through a pattern? | Burst battery | Pattern should open a route, not fill the screen uniformly |
| Ground denial | Can I leave or avoid a future zone? | Bomb carrier | Cancel or clearly resolve pending attacks on death |
| Disruptor | Can I preserve position/action timing? | Future shove, pull or silence threat | One disruption at a time; clear immunity/resistance rules |
| Support | Can I identify and remove an enemy multiplier? | Future shield/heal/buff unit | Effect source must be visible; no hidden global aura |
| Objective | Can I trade position for a temporary priority? | Elite, beacon or guarded cache | Reward and completion state are explicit |

Do not add another enemy because its projectile color is new. Add it only if its primary question is missing or if it forms a tested interaction with terrain and a class verb.

### Encounter-card grammar

Author encounters as small data cards rather than one endlessly rising spawn curve. Each card should contain:

| Field | Meaning |
| --- | --- |
| Intent | One sentence: “hold a broad lane while periodically leaving locked beams” |
| Tested verbs | The player actions expected to matter, such as wave clear, dash timing or focus fire |
| Cast | Counts or budgets for crowd, anchor and priority roles |
| Entry | Point, line, ring, cluster or authored edge/door pattern |
| Terrain affordance | Open loop, broad choke, cover island, four-entry pocket or long lane |
| Counterplay | At least two reasonable responses; name what makes each legible |
| Peak | The short interval of highest combined pressure |
| Recovery | A real period to reposition, collect or attack a priority target |
| Reward | Why the player is glad this encounter happened |
| Failure signature | What an unfair or boring version looks like in observation/data |

Start with three cards using current content:

1. **Lane Change:** crowd pressure through a broad lane plus one Arc lancer. Tests ordinary kiting and line departure.
2. **Break the Anchor:** one heavy protects intermittent Burst battery pressure while fodder approaches from two entrances. Tests focus choice, displacement and route planning.
3. **Claim the Pocket:** a valuable pickup/objective inside a four-entry pocket with staggered Bomb carrier zones. Tests intentional entry/exit rather than endless circling.

These names and compositions are proposals. Their purpose is to create three distinct testable situations before commissioning new enemies or finished terrain.

### Pacing model

Use a simple four-state envelope inspired by, but not copied from, Left 4 Dead:

| State | MobaBot behavior | Exit signal |
| --- | --- | --- |
| Build | Add the card's normal cast within a threat budget | Pressure score reaches the card target or timer expires |
| Peak | Maintain the planned interaction; no surprise priority-role injection | Short fixed window ends or player suffers a major setback |
| Fade | Stop adding priority roles; let committed attacks resolve | No active priority tell and pressure score falls |
| Recover | Sparse crowd only; allow collection, repositioning and cooldown planning | Minimum calm time plus progress condition |

The pressure score can start simple: nearby enemy weight + active hostile-tell weight + recent hull-loss weight + disabled/low-energy weight. It should be inspectable in Practice. Do not secretly lower enemy damage or health inside the director. If a run needs adaptive difficulty later, make that a separate, disclosed system.

Prototype hypotheses for early A0 testing:

- no more than one priority ranged role in the first teaching encounter;
- no more than two simultaneous high-salience hostile tells in the first stage;
- every designed peak followed by at least one clearly observable recovery interval;
- bosses remain authored and are not omitted by a dynamic pacing system;
- spawns and attacks use the player-centered playable view, never the detached camera position.

These are conservative starting constraints, not genre benchmarks.

### Boss worksheet

Every boss configuration should answer these before tuning health:

1. What one-sentence thesis distinguishes it?
2. Which previously taught action does it test?
3. What is its primary telegraph shape and sound?
4. Where is the safe or lower-risk negative space?
5. When may the player counterattack rather than only flee?
6. What changes at each phase, and why is a new phase better than one evolving pattern?
7. Which class strengths are rewarded without hard-invalidating another class?
8. What does the last 20% do to signal an approaching conclusion without becoming the least fair part?

### Measurements and stop conditions

Record locally per encounter:

- damage received by source and whether a tell was on-screen;
- number of simultaneous priority tells;
- time under peak pressure versus recovery;
- distance traveled and repeated-loop percentage;
- priority-enemy lifetime;
- ability and mobility use by encounter state;
- player explanation of the threat that caused each major hit or death.

Stop adding content when players cannot name what hit them, optimal play becomes one repeated perimeter loop, recovery exists only on paper, or the encounter makes a class's defining verb irrelevant.

## 2. Progression, boxes, charms, consumables and offline economy

### What has worked elsewhere

Incremental-game research describes the attraction of progress without constant interaction and distinguishes core and metagame loops.[7] The safer interpretation for MobaBot is not “make the game play itself”; it is “let elapsed time preserve a sense of continuity without beating meaningful manual play.” Melvor Idle provides an explicit precedent for capped offline calculation, opt-in offline combat, return summaries and deterministic accounting of gains and costs.[8]

Hades combines varied run builds, permanent progression and optional difficulty assistance. Its God Mode increases resilience after deaths rather than replacing play, and its wider difficulty modifiers let players choose challenge separately from basic access.[9] Supergiant also reworked permanent talents to reveal rows gradually, pair alternatives and support refunds—useful evidence for limiting simultaneous progression decisions.[10]

A closed single-player economy still needs controlled faucets, sinks and converters. A recent GDC economy primer recommends modeling those explicitly and using a spreadsheet to predict progression; common failure modes include flooding, starvation, undervalued items and inflexible models.[11]

Random rewards require special care even when initially earned rather than sold. The FTC highlights transparency, confusing currency conversion and links between heavy loot-box spending and problem-gambling measures, while acknowledging limits in causal evidence.[12] Apple requires odds disclosure for randomized virtual items sold for money.[13] MobaBot should avoid designing a paid-random-reward dependency now.

Two successful mitigation patterns are visible in live games: Hearthstone protects against unusable duplicates until a collectible threshold is met,[14] while Apex discloses rates, prevents duplicate cosmetics, converts exhausted pools to crafting material and guarantees high-rarity outcomes after bounded dry streaks.[15] MobaBot cannot directly remove equipment duplicates because its forge intentionally needs three identical pieces; it needs **useful-duplicate protection**, not absolute duplicate prevention.

### Economy boundaries

Keep these ledgers separate:

| Scope | Resource | Earned from | Spent on | Reset |
| --- | --- | --- | --- | --- |
| Run | XP/Power | Combat pickups | Numerical run upgrades | New run |
| Run | Field credits | Combat/cache/overflow | In-run shop | New run |
| Run | Mastery points | Power levels | Run mastery | New run |
| Account | Equipment copies | Manual eligible rewards; later bounded automation | Three-copy forging | Never |
| Account | Salvage currency | Manual clears; later slow offline salvage | Clearly priced deterministic purchases | Never |
| Account | Decorative collection | Explicit cosmetic rewards or boxes | Appearance only | Never |
| Future session | Consumables | Shops/rewards | Optional C-menu use | Define later |
| Future account | Charms | Undefined | Small bounded modifiers | Do not implement yet |

Do not use one currency for both a temporary combat decision and a permanent account purchase. Do not let offline salvage award a first clear, Ascension unlock, mastery, ability unlock or best-in-slot exclusive.

### Offline salvage model

The owner's target is precise enough for a first deterministic model:

```text
eligible_hours = clamp(elapsed_hours, 0, 48)
run_equivalents = eligible_hours / 16
offline_value = reference_run_value * run_equivalents
```

At 48 hours this equals three reference runs. “Reference run value” should initially come only from the last **manually cleared** stage/Ascension and use a stored reward snapshot or versioned reward table, not a fresh simulation. This is a recommendation pending the owner's explicit decision.

Manual play must retain at least four advantages:

- it unlocks new content and raises the reference;
- it gives full-rate rewards;
- it permits targeted build/equipment decisions;
- it owns rare or choice-driven outcomes until those systems are deliberately modeled.

On return, show elapsed eligible time, capped time, reference level, deterministic currency, any bounded items and the next cap. Never imply that the robot secretly completed actual combat if the feature is arithmetic salvage.

### Useful-duplicate and bad-luck rules

For equipment boxes, use this proposed order:

1. roll reward category and tier from a disclosed table;
2. prefer a missing equipment slot within that tier until the player owns one usable copy per slot;
3. after coverage, allow duplicates because 3:1 forging needs them;
4. once a duplicate cannot advance a meaningful forge path, convert it to a named crafting/salvage value;
5. track a dry-streak guarantee for rare tiers if tests show long non-progress streaks;
6. show the current protection state in plain language.

Do not invent exact odds until the collection size, expected run yield and target time-to-tier are modeled. “Exciting” cannot mean “the expected outcome is obscure.”

### Boxes, charms and consumables

| System | Potential value | Main risk | Recommendation |
| --- | --- | --- | --- |
| Equipment box | Compact reward reveal; long collection goal | Duplicate frustration, grind masking weak core play | Earned-only prototype after forge pacing is modeled |
| Decorative box | Expression without combat power | Asset burden and low-value clutter | Use duplicate-free pool or direct choice; later than core presentation pass |
| Charm | Build specialization | Hidden permanent power stack and balance explosion | Define a strict modifier budget and small slot count before producing any |
| Health/energy consumable | Emergency resource choice | Hoarding, mandatory farming, C-menu interruption | Prototype only after Vanguard resource pressure is understood |
| Money | Flexible deterministic sink | Inflation or meaningless stockpile | Every source needs a named sink and time-to-purchase target |

The future `C` interaction should open or cycle a very small quick-use inventory without pausing combat by surprise. Accessibility needs a single-press alternative to any hold/radial behavior. Do not design consumable drop rates before deciding whether they reset per run or persist.

### Economy workbook specification

Before implementation, create one reproducible workbook or script with:

- every faucet, cadence, amount, variance and eligibility rule;
- every sink, price, repeatability and account/run scope;
- every converter, including 3:1 forging and overflow conversion;
- target time to first equipment, first forge, tier 4 and tier 5;
- results for new, median and near-complete collections;
- manual, visible-AI and offline reward rates side by side;
- 1,000 seeded claims/runs with median, p10, p90 and worst dry streak;
- versioned assumptions so tuning changes can be compared rather than overwritten.

Hard stop: do not add charms, paid boxes or multiple consumables to compensate for an economy that has not been modeled and playtested.

## 3. Onboarding and control burden

### What has worked elsewhere

George Fan's Plants vs. Zombies tutorial principles are unusually relevant: blend teaching into play, prefer doing over reading, spread mechanics out, require the player to perform an action once, use few words, keep messages unobtrusive and adaptive, teach visually and leverage familiar concepts.[16] Greg Kasavin similarly describes structural exposition as deliberate pacing of content and cites Plants vs. Zombies introducing choices, plants, enemies and twists at a comfortable rate.[17]

Microsoft's accessibility guidance adds that a static control map is not a tutorial; tutorials should be interactive or demonstrative and revisitable.[18] Input burden is not only key count: speed, simultaneous presses and long holds can exclude players even when keys are remappable.[19]

Brawl Stars spent more than a year iterating fundamental controls and progression and found multiple designs that could have worked.[20] The lesson is not that MobaBot needs prolonged indecision. It is that core controls deserve comparative prototypes and player evidence before content is built around them.

### Separate three concepts

1. **Kit assignment:** Vanguard always owns its designed Q/W/E/R/D/F/1–4 roles.
2. **Physical input mapping:** a player may need a different button to perform “Vanguard Q” for accessibility.
3. **In-run progression:** rank or learn states change power/availability, not the kit's identity.

The owner's desire for stable class keys is compatible with action-level accessibility remapping. A remapped action remains Q's gameplay role and should be displayed with its actual physical prompt. If full remapping is deferred, document that as an accessibility limitation rather than treating fixed defaults as a complete solution.

### Vanguard teaching ladder

Use Practice onboarding and the first expedition minutes to teach one decision at a time. Do not necessarily lock the rest of the kit; visually de-emphasize untaught tools and introduce prompts at safe moments.

| Beat | Player action to elicit | Teaching method | Success evidence |
| --- | --- | --- | --- |
| 1. Move | Right-click a marked safe point | World marker plus three-to-six words | Player moves without searching the HUD |
| 2. Trust the gun | Approach one weak enemy and watch autonomous fire | No prompt until target enters range; small source label after hit | Player understands that movement does not stop the gun |
| 3. Commit | Left-click hammer toward a close target | One safe target positioned for head/handle contrast | Player notices the pause and aims the head at least once |
| 4. Maintain damage | Aim/cast Impact bolt | Straight target lane and truthful range preview | Player uses Q again without a prompt |
| 5. Escape contact | Use Body slam or Ghost drive in a controlled pinch | One slow threat and visible exit | Player can state which damage the dash protected against |
| 6. Aim burst | Use Core strike on an obvious center target | Large stationary cluster, then one moving target | Player understands center payoff before charges are introduced |
| 7. Blink | Cross a short obstacle with Phase hop | First flat ground, then a purpose-built thick wall | Player predicts which side receives them |
| 8. Ultimate | Use Reactor drop during a staged peak | Audio/visual readiness cue; no text wall | Player identifies it as the highest-impact event |
| 9. Modules | Add one module at a time in Practice | A focused encounter that gives the module a job | Player describes why it was worth activating/placing |

The first uncontrolled expedition encounter should not require mastery of all nine active positions. A player can own the full kit while early cards primarily demand movement, hammer, Q and one escape.

### Non-modal learn/upgrade flow

The owner's flow direction is sound: alternate “learn a locked rank-0 kit ability” and “rank an owned ability,” indicate eligible slots and avoid a full-screen choice interruption.

Add these safeguards:

- only one opportunity type is active at a time;
- available actions pulse once, then retain a quiet persistent plus indicator;
- clicking the small affordance and pressing `Ctrl + action` perform the same transaction;
- offer an accessibility “upgrade mode” key so no simultaneous chord is required;
- show rank, milestone effect and opportunity count before confirmation;
- never expire an earned opportunity during combat;
- suppress reminders during a hostile peak and surface them in recovery;
- let Practice simulate the exact learn order without mutating progression.

### Comprehension checks

After five and fifteen minutes, ask behavior-first questions:

- “Show me how you would keep doing damage while moving.”
- “Show me your safest escape from this group.”
- “Which action do you expect to be the biggest commitment?”
- “What would you press to improve an owned ability without clicking?”

Do not ask “Did you understand Q?” Agreement is cheap and often hides confusion. Observe the action and ask the player to explain after the attempt.

Stop the onboarding pass if it requires paragraphs during combat, if the player is punished while reading, if a prompt arrives before its concept has a job, or if the permanent gun causes players to miss the difference between autonomous and commanded damage.

## 4. Accessibility and camera comfort

### What has worked elsewhere

Microsoft recommends multiple channels for critical cues so color, sound or vision is not the sole requirement. Text labels plus symbols can reduce cognitive load, and gameplay-critical audio/visual events should have alternate representation.[21]

Its camera and motion guidance recommends disabling or scaling camera shake, blur, speed lines, automatic camera movement and other secondary motion. Sliders should reach zero if they are the off mechanism. It also recommends camera sensitivity controls and previews in realistic contexts.[22]

For input, Microsoft recommends mapping actions rather than only swapping physical buttons, updating every displayed prompt, offering toggle/auto-hold alternatives and avoiding mandatory rapid, simultaneous or prolonged activation.[19]

Hades demonstrates a useful separation between a game's intended challenge and an opt-in assistance mode; God Mode changes resilience while preserving the core game loop.[9] MobaBot does not need to copy that mechanic, but it should distinguish accessibility options, difficulty selection and automation instead of treating one as a substitute for another.

### Minimum option set for the next public-facing build

| Setting | Minimum behavior |
| --- | --- |
| Reduced effects | Removes secondary trails, debris and repeated flashes; preserves hit areas, hostile tells, player location and state changes |
| Screen shake | 0–100%, default restrained; zero truly disables every shake path |
| Full-screen flash | Off/on or intensity with true zero |
| Speed lines/afterimages | Separate intensity or included in Reduced effects; Ghost drive state remains readable without them |
| Camera lock | Persistent setting plus temporary recenter behavior |
| Edge-pan speed | Adjustable and capable of zero; no surprise detached-camera spawn relocation |
| Zoom | Bounded range with stable player-centered default |
| Cursor | At least size and high-contrast options before dense testing |
| Cast behavior | Confirm/quick-cast options where already supported; prompts remain accurate |
| Hold behavior | Ghost drive hold default plus a toggle alternative |
| Cue redundancy | Hostile tells use shape/timing plus color and sound, not color alone |

### Camera behavior by class

**Vanguard:** stable player-centered camera by default. Impact feedback should be local recoil, hit stop in presentation, object motion and sound before screen shake. Detached panning remains player-controlled.

**Marshal:** the camera should follow the currently controlled body, not average all relays. On transfer, use a short bounded transition or immediate cut option. Off-screen relays need edge indicators for status, not repeated forced camera pulls.

**Racer:** camera comfort is part of the prototype gate. Do not tie zoom directly to every speed fluctuation. If Overdrive changes framing, use a capped target zoom with slow entry/exit, preserve a stable screen-space player reference and offer “fixed Racer camera.” Speed lines and afterimages must be independently reducible. Camera lag may make fast mouse steering feel dramatic but can also make collision prediction dishonest; test zero lag first.

### True top-down perspective accessibility implications

A true top-down robot may align body/collision and reduce foreshortening, but it can hide facing, weapon anticipation and chassis personality. A three-quarter view exposes those cues but can exaggerate the visible footprint beyond the actual collider. The art experiment in the next section must test both gameplay and comfort:

- can players locate facing without relying on a tiny barrel;
- does the sprite remain inside its collision/readability envelope;
- can Hammer head versus handle be distinguished;
- do Relay bodies remain identifiable when clustered;
- does fast rotation create flicker or visual instability;
- do Reduced effects and color-vision checks preserve all critical states?

### Accessibility verification

Run two 30-minute sessions through representative normal and dense combat:

1. default settings;
2. screen shake/flash/speed lines at zero, Reduced effects on, alternate hold behavior active.

Inventory every forced camera movement and critical cue. A pass requires that disabled effects truly remain disabled, player/enemy collision reads remain stable, and the reduced profile still communicates every damaging area and movement state. Add a separate Racer session before the class can pass its movement gate.

## 5. Art and animation production experiments

### What has worked elsewhere

Riot describes prototype kits built from modified placeholder models, effects and sounds so mechanics can be evaluated months before final art.[23] That is a useful production defense: polished assets should follow a proven gameplay sentence, not make a weak action expensive to discard.

For final combat animation, Riot's Xayah case uses a large anticipation pose, a brief attack pose and follow-through within a tiny interruptible window. The team emphasizes distinct poses and responsiveness over adding blended frames everywhere.[24] Its VFX guide separates a functional primary element from thematic secondary detail; the primary element communicates the main gameplay purpose and the secondary layer supports it.[25]

Godot's `AnimationPlayer` can animate node/resource properties and event tracks, while `AnimationTree` provides state machines, one-shots, blend spaces and filtered layers for more advanced transitions.[26] These tools support a layered robot pipeline, but simulation remains authoritative: animation events may present a committed action; they must not silently redefine hit timing or geometry.

### Production sequence

Use four increasingly expensive passes:

1. **Gameplay blockout:** collider, range preview, timing markers and plain shapes.
2. **Motion blockout:** anticipation, contact, follow-through and recovery using transforms/parts.
3. **Identity pass:** accepted perspective, silhouette, material groups and unique audio/VFX primary shape.
4. **Polish pass:** secondary particles, frame refinement, variants and final generated/painted assets.

Every pass is independently discardable. Do not use a detailed image-generation batch to decide whether Hammer's head/handle rule is understandable.

### Representative perspective experiment

Create only the following five actions in three visual directions:

| Action | Why it is diagnostic |
| --- | --- |
| Idle + rotate/facing | Basic silhouette, chassis identity and directional stability |
| Move + stop | Locomotion weight, foot/wheel language and response |
| Hammer swing | 90-degree arc, head/handle distinction, commitment and follow-through |
| Body slam | Speed, air-resistance cue, collision envelope and impact recovery |
| Phase hop | Disappearance/arrival ownership, smoke readability and precise destination |

Compare:

- **Current three-quarter:** strongest volume/personality; greatest footprint and direction mismatch risk.
- **True top-down:** strongest geometric truth; weakest side profile and expressive pose risk.
- **Hybrid tactical:** mostly top-down footprint with deliberately visible top/front surfaces and oversized functional parts.

Use the same timing, collision and VFX budget in all three. Judge at default and maximum zoom-out, normal and Reduced effects, against five ordinary enemies and one priority tell.

### Evaluation rubric

Score each direction separately from 1–5 on:

- facing recognized in under one second;
- action recognized without icon/text;
- collision and damage region predicted correctly;
- player remains findable in a dense scene;
- motion feels responsive at the real cancel/commit timings;
- class identity reads as Vanguard rather than generic robot;
- production cost for eight directions, damage states and future classes;
- consistency across generated and native pieces;
- Reduced effects remains complete rather than broken-looking.

Do not average away a critical failure. A direction that looks best but makes Hammer geometry unclear is not the winner.

### Animation architecture

Keep two layers:

- **simulation state:** position, facing, hurtbox, cast phase, invulnerability, hit ledger, cooldown;
- **presentation state:** chassis lean, barrel/arm pose, anticipation, recoil, trails, smoke, sound and optional camera response.

Suggested animation graph:

```text
Locomotion: Idle <-> Move <-> Overdrive
One-shots: Hammer | Cast Q/W/R | Body slam | Phase depart | Phase arrive | Hit react
Overlays: Low hull | Shield | Ghost drive | Overclock | Carrying upgrade
```

One-shots can interrupt or filter upper/tool layers only where the design allows. A visual blend must never move the actual body away from its simulation collision. Root motion should be presentation-only unless one central movement controller consumes a validated curve.

### Astra / generated-art experiment protocol

Use Astra or another generator for exploration only after motion blockouts pass. Request one identity sheet and the five representative actions, not the full roster. Preserve prompts, references, model/version when available, dates, edits and hashes in provenance.

Acceptance requires:

- stable chassis proportions and recognizable primary silhouette;
- clean alpha and no baked background/light contamination;
- consistent facing and light direction;
- separable functional parts when the animation needs them;
- no invented weapon/state that changes gameplay meaning;
- actual-size inspection through `tests/skill_visual_test.gd` or an equivalent character fixture;
- a clear manual-edit path rather than dependence on exact regeneration.

If only isolated hero frames are coherent, use them for concept/reference and keep deterministic native motion. Bulk generation is not a milestone by itself.

### Asset manifest

For every accepted action, record: class, perspective, direction count, frames/duration, cancel/commit point, simulation event timestamps, primary gameplay read, secondary decoration, Reduced-effects behavior, source/provenance, actual-size review result and owner approval status.

## 6. Structured playtesting and decision making

### What has worked elsewhere

Valve's playtesting guidance emphasizes direct observation and the importance of what players do, while acknowledging observer and interpretation bias.[27] Volition's GDC work recommends combining observation with back-end logging because either method alone misses context.[28]

Games user-research guidance recommends matching sample size to the question: roughly six representative players to discover usability problems, around twelve to explore/define player groups and much larger samples for quantitative measurement. It explicitly recommends repeated small tests over treating five as a universal magic number.[29] Surveys are good for measuring opinion or reported behavior, but observation and probing are needed to understand why a player failed repeatedly.[30]

Research-process guidance separates understanding, usability and player experience, with lower-layer comprehension/usability problems addressed before monetization conclusions. It also recommends ranking issues, avoiding design defense during sessions and using diaries for experiences that unfold over many sessions.[31]

### Evidence ladder for MobaBot

| Evidence | Answers | Does not answer |
| --- | --- | --- |
| Unit/integration fixture | Does the rule execute deterministically and preserve state? | Is it understandable or fun? |
| Render capture | Is geometry present, aligned and unclipped in this frame? | Can a player track it over time? |
| Behavior probe | Can a defined policy survive/deal damage under a fixed seed? | Is that policy human, enjoyable or representative? |
| Owner playtest | Does the intended direction feel right to the owner? | Will a new target player understand it? |
| Moderated fresh-player test | Where and why do representative players struggle/react? | Population-level preference or retention rate? |
| Larger unmoderated test | How frequently do measured outcomes occur? | Why, unless followed by qualitative work? |

Keep these labels in every report: **Implemented, Automatically verified, Human-observed, Owner-approved, Unresolved**.

### Study sequence

| Study | Participants | Scenario | Primary question | Decision |
| --- | --- | --- | --- | --- |
| Owner feel gate | Owner, repeated often | One Practice micro-scenario | Does the action/class direction deserve more work? | Continue, revise or park |
| First-use comprehension | 5–6 fresh target players | First 15 minutes, no coaching | Can players move, damage, escape and identify threats? | Fix common blockers, retest with new players |
| Combat feel A/B | 5–6 relevant players | Matched Practice scenarios | Which timing/perspective/effect version feels clearer and better, and why? | Select a version only if behavior and explanation agree |
| First-three-round pacing | 6 players | Fresh A0 profile through first boss | Are growth, pressure and recovery paced well? | Tune cards/rewards, not the entire route at once |
| Build/class comprehension | About 12 across experience groups | Vanguard and Marshal vertical slices | Do identities and intended decisions emerge? | Revise or narrow; do not infer balance from tiny win rates |
| Longitudinal progression | 12–20 manageable players | Several sessions with short diary after each | Why return, stop, farm or push? | Tune cadence/economy after actual patterns exist |
| Quantitative balance | 100+ if available | Stable instrumented build | Frequency of deaths, choices and outcomes | Use distributions; follow anomalies qualitatively |

The sample suggestions come from practitioner guidance, not a guarantee. One external player is still more informative than none when resources are limited; iterate rather than waiting for an ideal sample.

### Standard session record

```text
Build/commit:
Date and device:
Participant segment and relevant game experience:
Scenario/seed/class/Ascension:
Research question (one primary, at most two secondary):
Settings and any Practice modifiers:

Observed behavior with timestamps:
-

Participant explanation (after the event):
-

Local metrics:
-

Finding:
Severity: blocker / major / moderate / minor
Confidence: repeated / single observation / owner preference / automated only
Recommended decision:
Retest condition:
Owner decision:
```

### Moderation rules

- Tell participants the game is being tested, not them.
- Do not explain a control until the predetermined rescue threshold is reached; timestamp the rescue.
- Ask neutral questions: “What were you expecting?” and “What told you that?”
- Separate observations from quotations and from interpretation.
- Do not debate or defend the design during the session.
- Ask preference after behavior, not before.
- Randomize A/B order when learning carryover could bias the second version.
- Use new participants to confirm an onboarding fix; trained participants cannot become new again.

### Minimal local instrumentation

Extend existing local diagnostics rather than building a telemetry service. Keep player records private and uncommitted. Useful event fields:

- commit/version, test scenario, seed, class, Ascension and settings profile;
- action learned/ranked/used, cast start/cancel/hit and damage source;
- hostile tell start, visibility, resolve, hit/miss and overlap count;
- movement state, camera lock/zoom and wall correction;
- encounter state transitions and threat score;
- reward source, claim ID, conversion and save result;
- death/clear time and checkpoint transition.

Do not record personal identifiers. For shared test data, export an intentionally scrubbed aggregate or hand-written summary rather than committing raw player records.

### Issue severity and actionability

| Severity | Definition | Response |
| --- | --- | --- |
| Blocker | Cannot progress, control, see a critical threat or preserve data | Fix before further content testing |
| Major | Repeatedly causes unintended failure or defeats the feature's purpose | Fix in the next focused iteration |
| Moderate | Creates confusion/friction but player recovers | Batch after blockers; retest in context |
| Minor | Cosmetic or rare friction without outcome impact | Record; do not derail the milestone |

A finding is actionable only when it names the observed behavior, likely cause, affected players, proposed change and retest. “Make it more fun” is not a finding.

## Integrated implementation plan

This research does not replace the work order in `NEXT_SESSION_BRIEF_17.md`; it sharpens its gates.

### Phase A · Enable experiments

- implement the planned Practice left dock, deterministic reset and mouse formations;
- add encounter-card selection and a compact local session summary;
- preserve campaign/checkpoint isolation byte for byte;
- build Normal, Reduced and zero-camera-effects profiles.

### Phase B · Prove Vanguard's first minute

- block out Hammer, Q, Body slam and one escape before final art;
- implement the do-once, non-modal teaching beats;
- run owner feel tests, then 5–6 fresh-player comprehension sessions;
- fix control/threat blockers before adding the remaining modules.

### Phase C · Prove encounter grammar

- build Lane Change, Break the Anchor and Claim the Pocket with current enemies/greybox terrain;
- add Build/Peak/Fade/Recover instrumentation without adaptive damage;
- author one boss thesis and counterattack window;
- test first-stage pacing before extrapolating to 22 rounds.

### Phase D · Select presentation direction

- compare the five representative actions in current, top-down and hybrid views;
- score actual-size readability and production cost;
- validate Reduced effects and camera comfort;
- only then expand a class animation set or use generated assets at scale.

### Phase E · Model progression

- measure real manual run value and time first;
- build the source/sink/forge/offline workbook and 1,000-claim simulation;
- prototype visible AI with no permanent rewards;
- prototype one offline salvage currency with idempotent claims;
- add boxes, then charms/consumables, only through separate owner-approved milestones.

## Decisions to defer until evidence exists

- exact encounter director weights and calm durations;
- new enemy roster size;
- final boss health or phase count;
- whether every physical ability input is remappable and the exact UI;
- final camera framing for Racer and Marshal transfer;
- final robot perspective;
- box odds, tier pity, charm slots and consumable persistence;
- the split of offline value between currency and item boxes.

## Sources

1. Michael Booth, Valve. [The AI Systems of Left 4 Dead](https://steamcdn-a.akamaihd.net/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf). AIIDE 2009.
2. JP LeBreton. [Doom: The Classic](https://media.gdcvault.com/GD_Mag_Archives/GDM_April_2010.pdf). *Game Developer*, April 2010.
3. Riot Games. [Quick Gameplay Thoughts: May 14 — Champion Counterplay](https://www.leagueoflegends.com/en-au/news/dev/quick-gameplay-thoughts-may-14/). 14 May 2021.
4. Riot Games. [Clarity in League](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/). 12 March 2021.
5. Riot Games. [Building Star Guardian: Invasion](https://nexus.leagueoflegends.com/en-us/2017/09/dev-building-star-guardian-invasion/). 2017.
6. Itay Keren. [Boss Up: Boss Battle Design Fundamentals and Retrospective](https://media.gdcvault.com/gdc2018/presentations/Keren_Itay_BossUp.pdf). GDC 2018.
7. Anthony Pecorella, Kongregate. [Idle Games: The Mechanics and Monetization of Self-Playing Games](https://www.gdcvault.com/play/1022065/Idle-Games-The-Mechanics-and). GDC 2015.
8. Melvor Idle. [Version 0.21 — Offline Combat](https://wiki.melvoridle.com/w/V0.21). 2021.
9. Supergiant Games. [Hades FAQ](https://www.supergiantgames.com/blog/hades-faq/). Updated 16 July 2025.
10. Supergiant Games. [Hades: The Nighty Night Update Patch Notes](https://www.supergiantgames.com/blog/hades-the-nighty-night-update-patch-notes/). 10 March 2020.
11. Monica Fan. [Gameplay System Design for Indies](https://media.gdcvault.com/gdc2025/Slides/Fan_Monica_Gameplay%2BSystem%2BDesign.pdf). GDC 2025.
12. US Federal Trade Commission. [Video Game Loot Box Workshop: Staff Perspective](https://www.ftc.gov/system/files/documents/reports/staff-perspective-paper-loot-box-workshop/loot_box_workshop_staff_perspective.pdf). August 2020.
13. Apple. [App Review Guidelines, section 3.1.1](https://developer.apple.com/app-store/review/guidelines/). Living guidelines, accessed 9 September 2026.
14. Blizzard Entertainment. [Ashes of Outland 17.0 Patch Notes — Duplicate Protection](https://hearthstone.blizzard.com/en-us/news/23357896/ashes-of-outland-patch-17-0-march-26). 26 March 2020.
15. Electronic Arts. [Apex Legends FAQ — Duplicate and Bad-Luck Protection](https://www.ea.com/en-gb/games/apex-legends/about/frequently-asked-questions). Living FAQ, accessed 9 September 2026.
16. George Fan, PopCap. [How I Got My Mom to Play Through Plants vs. Zombies](https://media.gdcvault.com/gdc2012/slides/Design%20Track/Fan_George_How%20I%20Got.pdf). GDC 2012.
17. Greg Kasavin, Supergiant Games. [I Don't Want to Know: Delivering Exposition in Games](https://media.gdcvault.com/gdconline10/slides/11488-I_Dont_Wantto_Know.pdf). GDC Online 2010.
18. Microsoft. [Xbox Accessibility Guideline 109: Objective Clarity](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/109). Updated 4 March 2026.
19. Microsoft. [Xbox Accessibility Guideline 107: Input](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/107). Living guideline, accessed 9 September 2026.
20. Antti Summala, Supercell. [Designing Two Tasty Cores Three Times Over: The Case of Brawl Stars](https://www.gdcvault.com/play/1025751/Designing-Two-Tasty-Cores-Three). GDC 2019.
21. Microsoft. [Xbox Accessibility Guideline 103: Additional Channels for Visual and Audio Cues](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/103). Living guideline, accessed 9 September 2026.
22. Microsoft. [Xbox Accessibility Guideline 117: Visual Distractions and Motion Settings](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/117). Updated 4 March 2026.
23. Riot Games. [/dev: On Champion Prototypes](https://nexus.leagueoflegends.com/en-us/2016/10/dev-on-champion-prototypes/). 2016.
24. Riot Games. [/dev: On Animating Xayah](https://nexus.leagueoflegends.com/en-us/2017/05/dev-on-animating-xayah/). 2 May 2017.
25. Riot Games. [League of Legends VFX Style Guide](https://nexus.leagueoflegends.com/wp-content/uploads/2017/10/VFX_Styleguide_final_public_hidpjqwx7lqyx0pjj3ss.pdf). 2017.
26. Godot Engine contributors. [Using AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html). Stable documentation, accessed 9 September 2026.
27. Mike Ambinder, Valve. [Valve's Approach to Playtesting](https://media.gdcvault.com/gdc09/slides/GDC09_Ambinder_ValvesApproach.pdf). GDC 2009.
28. Jordan Lynn, Volition. [Playtesting and Metrics: Getting the Most Out of Your Usability Testing](https://gdcvault.com/play/1015581/Playtesting-and-Metrics-Getting-the). GDC 2012.
29. Steve Bromley. [How Many Players Do I Need for a Playtest?](https://gamesuserresearch.com/how-many-players-do-i-need-for-a-playtest/). Updated 24 September 2022.
30. Steve Bromley. [How to Write a Playtest Survey](https://gamesuserresearch.com/how-to-write-a-playtest-survey/). Updated 12 January 2022.
31. Graham McAllister. [Implementing Games User Research Processes Throughout Development](https://media.gdcvault.com/gdcchina14/presentations/833798_GrahamMcAllister_EveryGameIsA_EN.pdf). GDC China 2014.

## Research limits

This report relies mainly on developer talks, official documentation and first-party postmortems. They describe what teams built and why; most do not publish controlled evidence that one isolated design decision caused commercial or retention success. Live games also changed after the cited articles. Recommendations above are therefore hypotheses tailored to MobaBot's current single-player prototype and must pass the explicit owner and fresh-player gates before becoming a quality claim.
