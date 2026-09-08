# Building a 2D survivor roguelite

## Research brief and pre-production plan

Prepared for Timothy | September 7, 2026 | Windows-first

**Recommendation:** use Godot to build a small, single-player survivor-like with automatic attacks, satisfying crowd destruction, and one distinctive movement-driven interaction. Borrow the accessibility of Survivor.io and the build authorship of Balatro and Slay the Spire. Do not combine all of their systems.

The leading prototype is a **salvage robot that turns defeated enemies' wreckage into an orbiting weapon supply**. It should feel like assembling a ridiculous machine while narrowly escaping a horde. This is a testable direction, not an approved final concept, final name, or claim of market novelty.

**Art has a workable production solution, not a turnkey AI solution.** Start with one coherent asset family or a tightly controlled simple cartoon style. Animate stable bodies through Godot; make weapons and effects carry the spectacle. Pilot AI-generated assets before making them a dependency.

**Use the assistant as an implementing, testing and investigating collaborator.** Keep design intent, current implementation state, content rules and repeatable tests in the project. Timothy remains the final judge of feel and taste through short, concrete playtests. No large feature should arrive without a runnable result and evidence of verification.

**Ready to begin a bounded prototype, not a full production commitment.** Research has reduced the engine, workflow and art-pipeline uncertainty. It cannot establish that the proposed mechanic is fun, that a chosen art workflow is repeatable, or that a horde will run well on a target PC before we test them.

### Reading map

- Pages 2-3: community findings and lessons from the reference games.
- Pages 4-5: power fantasy, feedback, upgrades and pacing.
- Pages 6-7: proposed concept, alternatives and your existing systems.
- Pages 8-9: art/animation pipeline, tools and costs.
- Pages 10-12: Godot architecture, performance, tests and collaboration.
- Pages 13-14: prototype scope, milestones, blockers and next step.

This report separates primary evidence, community anecdotes and proposed design decisions. Source titles are clickable. Research sampled public discussions; it is not a census of Reddit or a market-success forecast. No game code was changed, paid tools purchased, or third-party accounts connected during this research.

<!--page-->
# 01 / What the communities actually teach us

The strongest repeated lesson is that **a working demo and a coherent finished game are different achievements**. The sampled r/aigamedev discussions contain useful experiments, unfinished projects, founder promotion and conflicting opinions. A polished clip does not establish maintainability, animation coverage, performance, sales or completion.

### Four findings worth acting on

**1. Animation remains a recurring bottleneck.** In recent threads, developers describe sprite sheets that look plausible as still images but shift shape, color or position during playback. One September 2026 poster had spent a week struggling with sheets and modular assets. These are anecdotes, but they directly match your concern. Sources: [sprite-sheet workflow](https://www.reddit.com/r/aigamedev/comments/1w5bc78/sprite_sheet_generation_workflow/) and [consistency failures](https://www.reddit.com/r/aigamedev/comments/1w8kzd8/struggling_to_get_consistent_segastyled_animations/).

**2. Successful AI animation examples often hide a production pipeline.** A positive workflow described reference generation, several specialist tools and Aseprite repairs after weeks of experimentation. Another developer explicitly reported camera jitter, frame selection and cleanup in a video-to-sprite workflow. These support experimentation, not an expectation of one prompt producing a production-ready animation library. Sources: [multi-tool success account](https://www.reddit.com/r/aigamedev/comments/1s76q5f/finally_figured_out_how_to_make_decent_animations/) and [animation smoothness discussion](https://www.reddit.com/r/aigamedev/comments/1ui3i8e/sprite_animations_and_smoothness_feedback/).

**3. The useful AI workflows make the game inspectable.** An 18-month Godot project account describes small scoped changes, headless rule tests, controlled windowed captures and human playtesting. It also describes abandoning generated art in favor of licensed packs. It is a developer's self-report, including promotion, not an independent audit. [Prigod Games' workflow account](https://www.reddit.com/r/aigamedev/comments/1w9l9r8/how_i_used_claude_on_a_godot_project_that_was/).

**4. More generated content is not the main design shortage.** Player discussions complain about tiny upgrades, samey builds and long periods after decisions stop. Other players enjoy that final period of effortless dominance. We should test the duration of the payoff instead of treating either preference as universal. Sources: [meaningful upgrades](https://www.reddit.com/r/roguelites/comments/1lbre2v/need_a_game_where_upgrades_feel_meaningful_not/) and [upgrade-slot disagreement](https://www.reddit.com/r/gamedesign/comments/1cvg34m/why_does_vampire_survivors_limit_the_amount_of/).

### How the evidence was filtered

The review covered r/aigamedev's public homepage, new/top views and targeted threads, with adjacent discussion in r/godot, r/gamedev, r/gamedesign and r/roguelites. Technical recommendations were checked against original documentation. Vendor claims establish documented features, not accepted-asset quality. Private Discord discussions, deleted content and uninspected video material were excluded from substantive evidence. Votes and search rankings were not treated as representative surveys.

<!--page-->
# 02 / Borrow the right parts

For planning, the closest label is **2D action roguelite / survivor-like / bullet heaven**: repeated runs, automatic attacks, escalating pressure and build choices. A deckbuilder such as Slay the Spire is a valuable design reference without being the same production task.

| Reference | What we should borrow | What to leave out initially |
|---|---|---|
| Survivor.io | Simple movement, dense crowds, obvious weapon growth | Live-service economy, equipment grind, daily systems |
| Vampire Survivors | Rapid escalation, discoveries, generous spectacle | A large catalogue and long stretches without decisions |
| Megabonk | Movement and resource-seeking can matter alongside the build | 3D traversal, many characters, large map scope |
| Slay the Spire | Contextual choices, commitment, alternatives under uncertainty | A full deck, map, shop and card-combat layer |
| Balatro | Short individual rules that combine into dramatic results | Opaque trigger chains and excessive explanation |
| Binding of Isaac | Run stories, surprises, resource tradeoffs and unlocks | Huge room/item/boss libraries and years of accumulated content |

The Survivor.io publisher description emphasizes one-hand controls, large crowds and skill combinations; Megabonk's description emphasizes random maps, upgrade offers, character abilities and synergies. The movement lesson for Megabonk is our inference, not a located statement of developer intent. Sources: [Habby's Survivor.io listing](https://play.google.com/store/apps/details?id=com.dxx.firenow&hl=en_US) and [Megabonk's official listing](https://store.steampowered.com/app/3405340/Megabonk/).

Luca Galante described available asset-pack art shaping Vampire Survivors' setting, with separate inspiration for its visual effects. That is evidence that production constraints can guide identity, not that any cheap pack automatically works. [GameSpot interview with Galante](https://www.gamespot.com/articles/how-vampire-survivors-went-from-hobby-project-to-game-of-the-year/1100-6511980/).

LocalThunk described deliberately simple individual rules and incremental interacting Jokers. He also discussed iterative presentation work and was already an experienced artist. Balatro therefore supports a simple-rule design strategy, not an effortless-art narrative. [LocalThunk's developer/artist AMA](https://www.reddit.com/r/Games/comments/1bdtmlg/ama_i_am_localthunk_developer_and_artist_for/).

Edmund McMillen's Isaac postmortem describes random resources, rewards and unlocks as important to repeated discovery. We can borrow that sense of a run developing a story without reproducing Isaac's content volume. [The Binding of Isaac postmortem](https://www.gamedeveloper.com/business/postmortem-mcmillen-and-himsl-s-i-the-binding-of-isaac-i-).

**Design direction:** one easy physical verb plus choices that visibly change its consequences. We want both “I am much stronger now” and “this is the build I made.” A different skin over the same upgrade list is a weaker differentiator than a mechanic that changes the player's route through a crowd.

<!--page-->
# 03 / Power fantasy is a contrast we can feel

Calling these games “dopamine machines” does not tell us what to implement. A useful working model is **response, contrast, authorship, anticipation, discovery and mastery**. This is design synthesis, not a clinical or neuroscientific claim.

A six-study research paper associated enjoyment and desire for future play with perceived competence and autonomy. It also acknowledged self-report and geographic limitations. This is relevant background, not direct evidence for a particular survivor game's upgrade cadence. [Przybylski, Ryan and Rigby, 2009](https://selfdeterminationtheory.org/SDT/documents/2009_PrzbylskiRyanRigby_PSPB.pdf). A later critical review warns against uncritical use of self-determination theory in game research; we should use it as a lens, not a recipe. [Tyack and Mekler, 2024](https://arxiv.org/abs/2405.12639).

### Proposed feedback rules

| Desired feeling | Concrete implementation | Failure to watch for |
|---|---|---|
| My hit mattered | Clear impact, brief recoil/flash, distinct kill response | An enemy silently loses health; effects cover the result |
| I became stronger | A familiar enemy crosses from three hits to one | Every enemy scales immediately, erasing the comparison |
| I made this happen | Upgrade preview and recognizable combo cue | Random explosions with no readable cause |
| That was a release | Pressure, breakthrough, then room to enjoy dominance | Constant maximum pressure or permanent idle cleanup |
| I want another try | Clear death cause and one plausible next adjustment | Unavoidable damage, unclear rules or obligatory grinding |

**Give power a reference point.** Keep familiar fodder in later waves. Introduce new enemy behaviors and formations to challenge positioning instead of universally matching every increase in player damage. Large numerical damage gains can still be satisfying when they cross a visible breakpoint.

**Make spectacle hierarchical.** Enemy danger telegraphs and the player silhouette win visual priority. Player attacks sit below them; decorative particles sit below gameplay information. A major evolution earns a stronger cue than an ordinary pickup. More flashes on every event would flatten the emotional range.

**Treat audio as part of the mechanic.** Distinguish impact, kill, collection, upgrade and danger sounds. Limit simultaneous voices and repeated pickup sounds so a big collection feels like a satisfying sweep rather than a clipped wall of noise. Reserve low-frequency impact and stronger camera response for major events. These are proposed mix rules to test, not measured optimal settings.

**Protect control.** Avoid global hit-stop on every automatic hit in a dense horde. Use local recoil and impact animation first. Make screen shake and flash intensity adjustable, communicate hazards with shape as well as color, and keep upgrade menus readable with keyboard focus. The aim is spectacular combat the player can still understand.

<!--page-->
# 04 / Builds, choices and the rhythm of a run

The Slay the Spire developers describe using offer/pick information, winning decks and enemy damage alongside subjective feedback. Their GDC material explicitly treats data as evidence to interpret, not a conclusion. Our lesson is to ask specific questions of playtest data, not have an optimizer decide what is fun. Sources: [developer interview](https://www.gamedeveloper.com/design/how-i-slay-the-spire-i-s-devs-use-data-to-balance-their-roguelike-deck-builder) and [GDC 2019 slides](https://media.gdcvault.com/gdc2019/presentations/Giovannetti_Anthony_SlayTheSpire.pdf).

### A small vocabulary with understandable combinations

Start with three build directions and a small shared modifier set. An offered choice should serve a recognizable purpose: reinforce this build, solve its weakness, or open a credible alternative. Include ordinary numerical improvements, but ensure early choices also change behavior. Avoid presenting three filler choices simply to reach a content count.

For the salvage prototype, possible rules are: wreckage orbits the player; impacts release shards; collecting wreckage charges a burst; a full orbit can absorb a hit. Give effects clear trigger names and show one-line consequences. Do not initially ship every possible combination. Verify three deliberate build paths before widening the pool.

Avoid upgrades that work only after an obscure, unrevealed prerequisite. Show requirements, mark relevant tags, and provide a bounded reroll or a useful fallback when the pool cannot support a build. Randomness should ask the player to adapt, not merely wait for the correct roll.

### Proposed ten-minute pacing experiment

| Run segment | Intended experience | What we would observe |
|---|---|---|
| 0:00-0:30 | Immediate movement, attack and first collection | Does the player understand the loop without a lecture? |
| 0:30-2:00 | Early upgrade and a glimpse of the signature mechanic | Can they identify a change in behavior? |
| 2:00-5:00 | Commit to a build; introduce distinct threats | Do choices and movement change together? |
| 5:00-8:00 | A combo comes online; enjoy crowd-clearing power | Is dominance gratifying or already boring? |
| 8:00-10:00 | Final pressure pattern and ending encounter | Does the build remain relevant and the ending feel earned? |

These times are tunable prototype settings, not research-established ideals. First test 90 seconds; only extend the run if that works. Pause simulation during upgrade selection, keep pick animations brisk, and test whether frequent interruptions harm flow.

**Initial metaprogression:** no permanent stat grind is needed to validate combat. Later, favor new starting options, weapons and challenge modifiers. Permanent strength is a separate test; it can provide progress but can also conceal a weak first-run experience. Player complaints about grind and long fixed runs are useful warning signals, not a unanimous verdict. [r/roguelites discussion](https://www.reddit.com/r/roguelites/comments/1kur1vd/anyone_else_tired_of_survivorlikes/).

<!--page-->
# 05 / Recommended concept: the salvage prototype

**Pitch:** a small salvage robot survives a malfunctioning machine swarm by turning enemy wreckage into its own weapon supply. You steer through the battlefield; most attacks happen automatically. The fantasy grows from scavenging loose parts to towing a destructive orbiting machine.

This is a descriptive prototype label. The theme is provisional, and the proposal requires playtesting before we decide to build a full game around it.

### The signature interaction

An enemy dies and leaves a small wreckage pickup. Moving close pulls it toward the player. Instead of disappearing only into an XP bar, it visibly replenishes a bounded orbiting arsenal. Contact or automatic attacks consume or transform that supply. Collection is therefore both progression and a combat decision: the trail of defeated enemies becomes a tempting route through danger.

Keep XP accounting dependable: collecting a wreckage pickup awards its XP once, while its combat-charge role is separate. Never make firing the arsenal spend already-earned XP. Keep a weak baseline automatic attack so running out of salvage cannot make the run unwinnable. Boss encounters need a planned replenishment opportunity, not accidental starvation.

### Three build hypotheses

| Build | Rule combination | How movement changes |
|---|---|---|
| Grinder | Wider orbit plus durable impact pieces | Skim the edge of dense groups while protecting your body |
| Ricochet | Spent pieces launch shards that bounce once | Sweep pickup trails to sustain ranged crowd damage |
| Collection burst | Several pickups charge one visible pulse | Choose a risky collection route, then enjoy its release |

The first comparison needs only basic orbiting salvage, not all three builds. Additional conversion rules belong in the next slice if the fundamental interaction earns them. Chains must have explicit limits so spectacle cannot create unbounded simulation work.

### What makes this more than a reskin?

The proposed differentiator is **the same visible object changing from enemy remains to a resource to a weapon**, with the player's route determining replenishment and risk. It must be legible in a short clip and enjoyable before a large upgrade library exists.

A nearby-market check found substantial overlap: [Void Scrappers](https://store.steampowered.com/app/2005210/Void_Scrappers/) already uses enemy scrap, upgrades and kinetic orbitals; [Orbital Survivor](https://store.steampowered.com/app/4057400/Orbital_Survivor/) advertises gravity-driven movement and scraps; [Junkyard Saints: Scrapstorm](https://store.steampowered.com/app/4794490/Junkyard_Saints_Scrapstorm/) already occupies scrap-themed survivor territory. Consequently, “scrap plus survivors” is not a novelty claim, and “Scrapstorm” should not be our proposed title.

**The test:** compare the salvage version with plain auto-shooting under the same wave seed. If players cannot explain its unique benefit, or collecting feels like chores, simplify or discard the mechanic. A strong prototype must earn its extra rules.

<!--page-->
# 06 / Your existing games are useful design material

Your archive suggests an interest in **simple rules that interact spatially or trigger satisfying consequences**. That is an inference from the local projects, not a claim to remember every game you have made. Current source files and READMEs were preferred over older design plans where they disagreed.

| Local project | Relevant material inspected | What to carry forward |
|---|---|---|
| Super Wizard Tactics | README: 3x3 auto-battler; pure deterministic game rules separated from UI | Small composable effects and testable combat rules |
| Pet Painters | README: autonomous pets, roles, facing and territory effects | Characterful simple behaviors; placement changes outcomes |
| Misconfigured | Current engine types: conveyors, rotation, teleporters, plates and filters | Spatial interaction as a later arena twist, not a full puzzle layer |
| Fling-Thing | Expanded-blocks design: attraction, repulsion, ricochet and grouped activation | Physical-looking cause and effect; a bounded knockback experiment |
| Black Queen | README: headless arenas and paired seed evaluations | Reproduce failures and compare changes against the same cases |

These are patterns to translate into Godot, not TypeScript systems to transplant wholesale. Real-time motion and physics do not automatically inherit a card simulator's determinism. Keep content selection and effect math reproducible first; promise exact replays only after testing that property.

### Two alternatives if salvage does not appeal

**Circuit formation survivor.** Two orbiting devices produce a visible connection that damages enemies. Upgrades change pulse behavior and formation. This borrows your interest in arrangement and interactions, with modest character-animation demand. Its test is whether steering the formation is immediately understandable. Do not begin with a wiring editor or inventory puzzle.

**Impact-chain survivor.** Automatic attacks knock enemies into one another and into a few obvious arena objects. Impacts can produce a shockwave or splinters. This borrows Fling-Thing's physical feedback. Its test is whether knockback creates satisfying setups rather than scattering targets out of reach. Avoid full rigid-body crowds in the first version.

Do not combine these alternatives into the salvage prototype simply because the parts sound compatible. A small game with one successful interaction is a better decision basis than a large prototype whose best part cannot be isolated.

### Local provenance

Inspected under `C:/Users/tctct/Downloads/claude/`: `Archive/Super Wizard Tactics/README.md`; `Archive/pet painters/pet-painters/README.md`; `misconfigured/src/engine/types.ts`; `Archive/Fling-Thing/docs/superpowers/specs/2026-05-15-expanded-blocks-design.md`; `black queen/README.md`. The Fling-Thing document describes planned mechanics; its generic README was not used as implementation evidence. No archive files were modified.

<!--page-->
# 07 / An art pipeline that does not hold the game hostage

**Default route:** one cohesive asset family, stable character bodies, separate weapons, authored motion and effects. A deliberately restrained visual language can become the game's finished identity; it need not be a temporary compromise while waiting for sophisticated AI animation.

For a rounded cartoon direction, inspect [Kenney Monster Builder](https://kenney.nl/assets/monster-builder-pack). For a pixel direction, inspect [Kenney Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon) or [0x72 DungeonTileset II](https://0x72.itch.io/dungeontileset-ii). The creator pages identify CC0 licensing. These are alternative style directions, not packs to mix indiscriminately. We have not imported or audited their complete animation coverage in our scene.

The 0x72 creator explicitly describes separate swinging weapons rather than supplied character attack animations. This is a useful production pattern: adding a weapon should not require redrawing every character. Godot supports transform-based cutout animation and combinations of cutout and frame animation. [Godot cutout animation documentation](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html).

### Approve a golden set before a library

Create one player, one basic enemy, one dangerous enemy, a pickup, a projectile, a ground treatment and one upgrade icon. Review them at actual gameplay size, moving, against the arena and under effects. Approval of a large beautiful contact sheet is not approval of in-game readability.

Lock perspective, outline weight, palette logic, scale, lighting and shadow treatment. A possible cartoon specification is a slightly elevated view with compact bodies and left/right facing. A hovering robot avoids foot-contact and eight-direction walk cycles. That convenience is a reason to test the theme, not a reason to force it on you if you dislike it.

### Asset production and acceptance

1. Select or create the reference asset, then approve it in-engine.
2. Make variants against that reference; do not prompt each animation frame independently.
3. Normalize canvas, transparency, pivot, naming and import settings.
4. Add bob, squash, recoil, hit response and death effects in Godot.
5. Test the asset in a crowded scene; reject inconsistent or unclear output.
6. Save accepted originals, editable sources, provenance and license information locally.

For pixel art, verify the actual pixel grid and filtering. For all styles, verify alpha fringes, clipping, loop continuity, identity drift and coverage of required states. Color differences must be reinforced by silhouette or shape.

**Fallback:** use the chosen pack consistently, with procedural weapons, telegraphs and UI. A later commission can target one hero, boss or key art piece. Do not turn a failed AI pilot into an automatic local-model-training project. Our objective is making the game, not building an asset-generation business.

<!--page-->
# 08 / AI art tools: use selectively, measure throughput

There is no need to subscribe to several services before we can start. Measure **accepted assets per hour and cost per accepted asset**, including failed generations and cleanup. Vendor operation prices alone do not tell us production cost.

| Route | Good use in this project | Constraint / decision |
|---|---|---|
| Existing art + Godot motion | Reliable first playable; enemies, basic props, effects | Audit style and missing animation states |
| General image generation | Concepts, selected static icons, isolated custom assets | Consistency and frame correctness require inspection |
| PixelLab | A bounded pixel-character or animation pilot | Size limits, references and manual repair matter |
| Scenario | A larger static library after a style exists | Training needs coherent examples; video-to-sheet is multi-step |
| Aseprite workflow | Cleanup and repeatable sheet exports | Editor access may be needed; CLI is useful once configured |

PixelLab's official skeleton workflow includes correcting poses, rough manual fixes, inpainting and regeneration. Its API publishes operations for direction/animation work with estimated charges; the subscription pricing page did not expose a reliable current figure in this review. Programmatic access is restricted to the official API by its terms. Sources: [skeleton guide](https://www.pixellab.ai/docs/tools/animate-with-skeleton), [API](https://www.pixellab.ai/pixellab-api), [terms](https://www.pixellab.ai/termsofservice).

Scenario's spritesheet guide uses generated video, key-frame extraction, external arrangement/alignment and loop checking. Its pricing page describes style training from example images and distinguishes paid commercial licensing from free personal/evaluation output. Exact billing amounts were not used in our budget because the annual/monthly toggle state was ambiguous. Sources: [spritesheet workflow](https://help.scenario.com/articles/9088582240-create-spritesheets-with-scenario) and [pricing/licensing](https://www.scenario.com/pricing).

Aseprite documents command-line sheet and data export. This is repeatable integration work the assistant can automate if we use that editor. [Aseprite CLI](https://www.aseprite.org/docs/cli/). No such tool was installed during this research.

### Proposed pilot and stop rule

No additional spending is required for the pack/procedural prototype, assuming existing equipment and assistant access. If desired later, authorize a small paid pilot with a proposed total cap of $30-50, no annual commitment. This cap is a planning choice, not a quote or current provider price.

Timebox hands-on work on one player, one enemy and an icon family to roughly two hours. If acceptable output is not repeatable, take the fallback and keep developing. Do not count waiting on generation as proof that cleanup is cheap.

Keep a provenance manifest: asset ID, creator/source, license copy, modifications, AI tool/model where applicable, and whether it ships. A game-use license does not automatically authorize training a model on purchased art. Recheck provider terms before purchasing or publishing.

<!--page-->
# 09 / Why Godot fits, and how to structure the game

Godot is a credible choice for this genre, not merely a theoretical option: its official showcase includes **Brotato**, an auto-firing wave survivor. This establishes feasibility; it does not establish our performance ceiling or shipping schedule. [Godot's Brotato showcase](https://godotengine.org/showcase/brotato/).

The local project already has portable Godot **4.7.2**, a working introductory sample, input actions, editor/run launchers and a headless smoke-test script. The binary version was rechecked during research. Keep the pinned version for the prototype; no engine upgrade is needed to answer the first design question.

### Proposed small architecture

| Part | Responsibility | Why separate it |
|---|---|---|
| Run controller | Time, phases, spawn schedule, ending | Pacing can change without rewriting weapons |
| Player and enemy scenes | Movement, health, hitboxes, presentation | Easy to inspect and tune in the editor |
| Combat rules | Damage, status, trigger eligibility and limits | Test math independently of effects |
| Content resources | Weapons, enemies, upgrades, wave entries | New content follows validated data definitions |
| Event presentation | Sound, particles, numbers, animation | Effects do not decide whether damage occurred |
| UI and debug scenes | Upgrade choices, run summary, test fixtures | Reproduce a late-run state without replaying it |

Use typed GDScript and native scenes/resources initially. Each weapon needs explicit timing, targeting and hit behavior; share the genuinely common pieces without inventing a universal ability language. Content definitions should use stable IDs, declared tags and clear prerequisites. When Resources are shared, keep mutable per-run state separate from the definition.

Resolve gameplay events before decorative effects. Prevent repeated death rewards and recursively self-triggering explosions. Keep seeded random streams for upgrade offers and wave choices separate from cosmetic variation. Add bounded event chains rather than relying on an accidental infinite combo to define power.

### Learning route, not a production dependency

[GDQuest's survivor-style Godot 4 tutorial](https://www.gdquest.com/library/first_2d_game_godot4_vampire_survivor/) directly covers movement, aiming, projectiles, enemies and spawning. It is useful for understanding the editor and inspecting a familiar loop. Its page labels code MIT and game assets CC BY-NC-SA, while the video description shows different asset-license language. Verify the exact downloaded archive's license before any reuse; the safest production path is our own logic and separately cleared art.

We do not need a Godot MCP integration to begin. The engine's command line supports direct project launches, scripts and exports. Add editor tooling only if a specific repetitive operation cannot be handled reliably through files, scripts and controlled captures. [Godot command-line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html).

<!--page-->
# 10 / Performance and verification before content growth

Crowd size is not a meaningful performance promise without enemy logic, collisions, particles, resolution and hardware. A Reddit account reports major gains from pooling, spatial partitioning and MultiMesh rendering, but its frame-rate numbers are specific to that project. We should reproduce bottlenecks in our own scene. [r/godot performance account](https://www.reddit.com/r/godot/comments/1ssmrmj/from_12fps_to_a_120fps_floor_four_godot_4/).

Godot's official guidance prioritizes measurement. Node-based scenes are a reasonable starting point; lower-level servers are an option after higher-level approaches become a measured bottleneck. MultiMesh batches drawing, not game logic or collision. Its tutorial also warns that it has not yet been updated for 4.7 and notes per-instance culling limitations. Sources: [CPU optimization](https://docs.godotengine.org/en/stable/tutorials/performance/cpu_optimization.html), [servers](https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html), [MultiMesh](https://docs.godotengine.org/en/stable/tutorials/performance/using_multimesh.html).

### Staged stress experiment

Test the actual gameplay mix at roughly 100, 300 and 600 enemies, with representative attacks and pickups. These are test tiers, not commitments to final counts. Record hardware, renderer, resolution, release/debug mode, average and high-percentile frame time, worst burst and object counts. A proposed target is smooth 60 fps, corresponding to a 16.7 ms frame interval, with headroom on a declared test PC.

First inspect unnecessary collision pairs, per-enemy scanning, allocation spikes and excessive transparent effects. Merge nearby pickup values while conserving rewards. Use cosmetic fragments to imply abundance without simulating every fragment. Introduce pooling, spatial queries or batched drawing only for a measured cause. Pooling requires complete state reset; drawing batches require checking depth order and animation behavior.

GPU work also matters: dense transparent effects can remain expensive after CPU optimization. A powerful development PC can conceal weaker-hardware problems. [Godot GPU guidance](https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html).

### Three different kinds of evidence

- **Logic:** damage and upgrade formulas; one reward per death; XP conservation; valid offers; bounded triggers; safe restart; save round-trip when persistence exists.
- **Rendered behavior:** real-window capture of early/mid/late combat, crowded upgrade UI, screen resizing, worst effects and player/hazard visibility. Headless success is not a visual test.
- **Human play:** clear movement, impact, build identity, fair failure, pacing and desire to retry. Neither screenshots nor simulations establish these experiences.

Record build ID, seed, loadout and death cause. Gather weapon damage and upgrade offer/pick data to investigate questions, not automatically rank items by win correlation. Selection and survival biases can make an item appear stronger than it is. A run should be easy to reproduce before we create hundreds of things that can break it.

<!--page-->
# 11 / How to get the most useful work from the assistant

You should not have to become an expert programmer or type perfect prompts. The productive division is: **you provide direction and reactions; I turn them into small implementations, tests and concrete comparisons**. I can propose design changes and diagnose failures, but your taste decides what belongs in the game.

OpenAI's guidance recommends clear goals, context, constraints and completion criteria, practical repository instructions, and testing/review. It also advises adding tools when they remove a real repeated bottleneck. [OpenAI best practices](https://learn.chatgpt.com/guides/best-practices).

### Keep a small source of truth

Before implementation, prepare a short project brief, a current-state/next-step note, a combat/content schema, an art specification and a playtest log. A concise AGENTS.md should identify run/check commands and completion rules, pointing to details rather than duplicating them. These are proposed development documents, not a large documentation system to build first.

“Current state” must distinguish working, partially implemented and planned features. Update it after a verified slice. This prevents an old brainstorm from quietly becoming an assertion that something already exists. Public complete-game workflow discussion independently emphasizes rendered feedback, bounded tasks and product coherence. [r/aigamedev workflow discussion](https://www.reddit.com/r/aigamedev/comments/1vtpgo6/what_is_your_actual_workflow_for_making_a/).

### The normal development loop

1. Inspect the relevant implementation and the last playtest observation.
2. State the intended player-facing change and what must stay unchanged.
3. Implement one runnable slice, using the existing architecture.
4. Run logic checks and a controlled graphical test where relevant.
5. Review the diff; update the implemented-state note.
6. Give you the build, the meaningful change and one focused playtest question.

Use one task for one coherent outcome. If Codex and Claude work concurrently, isolate their branches/worktrees and file ownership; do not have both modify the same checkout at once. Use research or review help on independent pieces, not competing rewrites of the entire project.

### Feedback that makes iteration faster

“Boring” is useful; a little context makes it actionable: “At 3:20 I stopped moving because nothing could reach me,” or “The new weapon is stronger but I can't see its shots.” A seed, screenshot or short clip lets me reproduce the state. I should translate that observation into a testable change, not require you to diagnose the code.

A practical prompt: **“Implement only the pickup-to-orbit mechanic. Preserve movement and base shooting. XP must be awarded once; the orbit must be capped. Add tests, show a crowded rendered scene, and give me a 90-second comparison against plain shooting. Do not add progression menus.”**

For a blocker, I should report the exact failed step, evidence, what I tried, the safe fallback and the smallest help needed. You should not receive a vague request to “set everything up” or paste secrets into chat.

<!--page-->
# 12 / The prototype contract

This is a proposed scope for approval, not work already implemented. The current Neon Collector remains untouched. Use it as a tooling/reference project; keep the new game's scope and progress unambiguous.

### Gate A: is the physical loop worth pursuing?

Build a 90-second arena with movement, a baseline automatic attack, basic collection and two contrasting enemy behaviors. Compare plain auto-shooting with pickup-to-orbit salvage under the same spawn schedule. Include enough impact and audio feedback to judge it fairly, but no metaprogression or production art library.

Pass when you understand the differentiator without a long explanation, prefer or see clear promise in its feel, and can identify a positioning choice it adds. If not, adjust collection timing/range and danger readability, then compare again. If the idea still fails, test one alternative rather than adding more upgrades to hide the problem.

### Gate B: can we produce the visual language?

Approve the golden set from page 8 in the actual arena. Verify transparent edges, pivots, motion, dangerous silhouettes and a maximum-effects scene. If AI output is inconsistent, retain the coherent pack/procedural route. Development must not wait for a hypothetical future animation breakthrough.

### Gate C: does a run have distinct builds?

Expand to one approximately ten-minute run, one arena, one player, four regular enemy roles, an elite variant and one ending encounter. Start with three weapon/build families, twelve upgrade definitions, three deliberately tested combinations and one small set of reusable effects. These are caps and hypotheses, not a requirement to fill every slot.

The enemy roles should alter movement: a slow group that creates density, a telegraphed charger, a ranged area threat and a durable space-denying enemy. Do not introduce them all at once. Make the final encounter test the same movement/build skills without abruptly invalidating the player's chosen strategy.

Pass when two builds feel different, a losing run suggests an adjustment, and you voluntarily want another run. Record early confusion and dead time. Small playtests are qualitative feedback, not proof of commercial demand.

### Gate D: can someone else reliably play it?

Package a Windows build, launch it outside the editor, test pause/restart/settings and controller navigation if included, and run the late-game stress scene. Add persistence only after deciding what must persist; then test missing, older and invalid saves. A build that only works from the developer's editor has not passed this gate.

**Explicitly out of scope:** multiplayer, online accounts, leaderboards, mobile release, live-service economy, runtime generative AI, procedural campaigns, elaborate equipment rendering, many biomes and a large character roster. Revisit them only after the core loop and production route prove themselves. Progress is measured by these gates, not a promised number of coding hours.

<!--page-->
# 13 / Readiness, blockers and the decision to start

### What is ready now

Windows-first is confirmed. Godot 4.7.2, project-relative launchers and a smoke-test harness exist. Neon Collector is a movement/collection/avoidance sample, not the proposed survivor game. The binary version and repository setup were rechecked; no new gameplay or horde benchmark was run.

### What remains to prove, and how you can help

| Open item | Next safe step | Your help, if needed |
|---|---|---|
| Concept preference | Start with the salvage comparison or pick one alternative | Say whether the core fantasy appeals; the name/theme can change |
| Art direction | Show a tiny in-engine golden set | Choose cartoon or pixel direction; react to readable examples |
| Art throughput | Run the small pilot with a fallback ready | Approve spending only if you want an optional paid tool |
| Performance floor | Profile a representative late-run scene | Identify a weaker Windows PC if broad hardware reach matters |
| Windows distribution | Install matching export templates and test an exported build | Approve a scoped download if required; test the resulting package |
| Gameplay feel | Reproducible 90-second and ten-minute tests | Play briefly and report the most enjoyable/confusing moment |

No version entries were found in the portable export-template directory, and no export preset exists in the project root. Packaging is an upcoming step, not a prototype blocker. [Windows export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html).

Steam's current AI survey focuses on player-consumed shipped content, including art, sound and narrative, distinguishing pre-generated from live-generated content. Record provenance now; recheck requirements at release. [Steamworks Content Survey](https://partner.steamgames.com/doc/gettingstarted/contentsurvey).

### Why stop broad research here?

Further broad searching now has diminishing value. The remaining uncertainties require our own combat comparison, art pilot and stress test.

This is not an exhaustive subreddit scrape, paid-tool benchmark or novelty claim. The nearby-game check already changed our naming recommendation. Recheck prices, licenses and living documentation when used.

**Recommended next step:** approve a Windows-first, 90-second salvage-mechanic prototype with a coherent temporary art set and a plain-shooter comparison. No paid tools or large content pipeline are necessary to begin. I can handle the implementation and verification; your most valuable contribution is deciding whether the result feels good enough to deserve the next slice.
