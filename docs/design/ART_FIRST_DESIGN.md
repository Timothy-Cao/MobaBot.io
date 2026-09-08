# Workshop salvager: art-first design decision

Prepared September 7, 2026. Windows-first. Final pre-implementation recommendation, subject to Timothy's visual/playtest judgment. Descriptive working label, not a cleared public game title.

This brief narrows the earlier survivor research; it does not replace its evidence or authorize gameplay implementation in this turn. No game code, paid service or new dependency is required for this design pass.

## Decision

Make a **charming little salvage machine in a toy-like repair workshop**, with automatic attacks and a visibly growing assembly of reclaimed tools. The emotional arc is: a scrappy little underdog becomes the center of a ridiculous, powerful machine.

The art rule is **growth through assembly, not repeated character redesign**. Keep the same recognizable body, then add and animate weapons around it. Put production effort into silhouettes, timing, collection, impacts and sound rather than many-direction humanoid animation.

Implementation is not risk-free: crowd performance, upgrade interactions and feel still need iteration. However, this direction lets much of the visible motion be authored and adjusted deterministically rather than regenerated frame by frame.

## Why this theme over the alternatives

| Candidate | Art/motion advantage | Main downside | Decision |
|---|---|---|---|
| Toy-like salvage machines | Rigid components rotate, recoil, orbit and break apart; same parts express gameplay | Can look generic or overly mechanical without a memorable hero and tactile feedback | Recommended |
| Slimes / microscopic organisms | Squash, stretch and pulses can carry movement | Similar blobs can obscure enemy roles; convincing deformation and changing silhouettes add work | Credible alternative, not first choice |
| Floating spellbook / magical tools | Static books, runes and spell icons plus motion are viable | Effects can become the entire identity; many spells risk looking alike | Runner-up if fantasy is more appealing |
| Detailed humanoid survivor | Familiar fantasy and expressive acting | Directional walks, attacks, equipment, anatomy and consistent frames multiply art obligations | Exclude from first project |

This ranking is a production judgment for our team, not a benchmark proving AI is best at one subject. Robots are advantageous because the required motion can be simple, not because every generated robot will be consistent.

## Evidence that changed the recommendation

- A June 2026 r/aigamedev art-bottleneck discussion includes firsthand use of static images with procedural animation, shaders and particles. Other replies still describe cleanup and custom pipelines. Treat this as workflow evidence, not a representative success-rate survey. [YoshiBanana3000 and replies, June 1, 2026](https://www.reddit.com/r/aigamedev/comments/1ttv7ua/stuck_on_artassets_production_after_building_a/).
- A developer's space-sim showcase reports an appealing style built from code-drawn primitives. It is a 3D/WebGL example, not evidence that our Godot 2D assets are already solved. The useful inference is that simple geometry can be a deliberate visual language. [Space-sim creator and replies, June 27, 2026](https://www.reddit.com/r/aigamedev/comments/1ugx9nt/impressed_with_ai_art_for_my_fledgling_space_sim/).
- A more recent animation discussion describes simple cycles as more workable than complex actions, but still hit-or-miss. We do not adopt its suggestion to reskin ripped commercial sprites. [r/aigamedev participants, August 8, 2026](https://www.reddit.com/r/aigamedev/comments/1vitcgx/what_is_your_guys_opinion_on_useing_ai_like/).
- PixelLab's own skeleton-animation guide includes pose correction, manual fixes and regeneration. This is stronger support for preserving a cleanup budget than vendor claims of effortless animation. [PixelLab, living guide, accessed September 7, 2026](https://www.pixellab.ai/docs/tools/animate-with-skeleton).
- Godot supports animation of transforms, sizes, pivots, opacity and color alongside sprites and particles. Its cutout tutorial carries a not-yet-updated-for-4.7 warning, so verify exact APIs against the installed version when coding. We need only simple transforms initially, not a sophisticated skeleton rig. [Godot contributors, living documentation](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html).

## Visual direction

**Tone:** mischievous, tactile, colorful machinery. Not grim apocalypse, realistic military hardware, or neon effects on a black void. The hero should be easy to like even before it is powerful.

**Camera:** fixed-scale elevated top-down 2D view in a landscape arena. Do not rotate the camera or require directional redraws. A front-biased character face can stay readable while the body banks slightly; radial tools can rotate independently.

**Shape language:** hero = compact rounded body with a simple dark face and two eye lights. Chaser = round bumper. Charger = wedge. Ranged threat = box with an obvious nozzle. Space-denying enemy = wider, armored shape. Shape and behavior distinguish roles; color is supplementary.

**Rendering:** crisp illustrated cutouts or code-authored vector-like shapes, broad color areas and restrained two-tone shading. No pixel-art grid requirement, painterly microtexture or complex baked lighting. Keep ground shadows separate so they do not rotate with tools. Avoid detailed asymmetric text/logos on mirrored sprites.

**Palette proposal:** cream/teal hero, gold collection and player-energy accents, coral warning telegraphs, plum/red-orange enemy bodies, quiet gray-blue floor. This palette is a proposal to inspect at actual gameplay size, not an accessibility guarantee.

**Scale proposal:** a body roughly 36-44 pixels tall at the current 960x540 reference viewport, with larger readable weapon coverage. Validate at both the reference viewport and a larger desktop window. Do not enlarge the player's damage hitbox as a cosmetic reward; the body remains identifiable inside its arsenal.

**Environment:** one sparse workshop floor, large seams, a few edge props and generous clear fighting space. Avoid a dense, beautifully illustrated floor that competes with scraps and danger. No complex seamless AI tile generation is necessary; simple base surfaces and sparse decals suffice.

## Gameplay supported by that art

Move with WASD/arrows, attacks automatic. No manual aiming, complex inventory or required extra action in the first comparison. Add controller support before wider playtests, not to delay the first local experiment.

1. A weak baseline attack breaks a small machine enemy.
2. It pops into a few cosmetic pieces and one clear salvage pickup.
3. Moving near the pickup pulls it in; XP is credited once.
4. Collection also loads a visible piece into a small capped orbit around the hero.
5. Orbit pieces strike nearby enemies, are consumed according to a simple readable rule, and can be replenished by the next collection sweep.

A proposed starting cap is six pieces; tune it in play. Keep the baseline attack active when empty. Do not make firing spend XP or permanently shrink the character. Merge distant pickup values if necessary while preserving rewards. Cosmetic fragments are not all independent physics objects.

Collection must feel like a rewarding sweep, not manual housekeeping. Test attraction distance, pickup acceleration and how often the arsenal feels empty. If the supply loop is frustrating, retain salvage as a clearly visible burst-charge resource instead of making every orbit hit consume a piece. That is a bounded fallback within the theme, not an excuse to add a second economy.

## Three distinct ways to feel powerful

| Build | Visible behavior | Player experience | New art obligation |
|---|---|---|---|
| Grinder | Orbit pieces become broader saw-like sweeps | Skim crowds and cut a path through them | One disc/tool silhouette plus rotation and impact |
| Ricochet | Spent pieces become short-lived bouncing projectiles | Feed an expanding ranged chain by sweeping salvage trails | Reuse the piece sprite, add a trail and bounce cue |
| Collection pulse | A visible ring charges through pickups and releases a pulse | Route through a risky trail, then enjoy a clear crowd-clearing release | A ring, charge indicator and reusable impact shapes |

These are three branches to test after the base interaction, not three systems to implement immediately. Every major upgrade should affect motion, attack shape, coverage or a readable trigger. Numerical upgrades are allowed when their effect is perceptible; cosmetic complexity alone is not progress.

Use build changes rather than new anatomy to show escalation. Avoid a final phase where the hero disappears under its own weapons. No more than a few strong simultaneous effect families; cap chain generation and decorative effects independently.

## Motion and sound are part of the art budget

| Event | Visual treatment | Audio / timing intention |
|---|---|---|
| Move | Gentle body bank, hover bob and separate shadow | Responsive movement; no floaty input lag |
| Shoot | Small tool recoil and clean projectile | Short mechanical tick, not a huge impact every time |
| Hit | Local flash/recoil on the target | Distinct impact; controlled simultaneous voices |
| Kill | Brief shape breakup, then clearly visible salvage | Compact pop/rattle; no lengthy corpse animation |
| Collect | Accelerating curved pull into a visible slot | Short rising collection phrase with a cap/reset |
| Upgrade | Tool snaps into position; show its behavior immediately | A stronger one-off assembly cue |
| Big combo | Clear pulse or sweep, then a readable aftermath | A rare, stronger release rather than nonstop loudness |

Use real timing tests. Static artwork cannot prove these feelings. Avoid global hit-stop on every automatic hit; start with local feedback. Provide reduced shake/flash options. Never sacrifice enemy telegraph visibility for player spectacle.

## Who makes what

**AI image generation:** visual exploration; one approved hero reference; selected isolated static bodies, props or illustrations. Generate one bounded asset against an approved reference when production begins. Do not regenerate the whole world with every prompt.

**Code-authored art and Godot:** clean icons, tool geometry where simple, eye expressions, separate shadows, animation transforms, trajectories, trails, telegraphs, UI and effect timing. These are the repeatable pieces that let us polish without requesting new frames.

**Existing assets:** one coherent source family if it improves the result. Kenney's [Space Shooter Remastered](https://kenney.nl/assets/space-shooter-remastered), [Space Shooter Extension](https://kenney.nl/assets/space-shooter-extension), [Top-down Tanks Remastered](https://kenney.nl/assets/top-down-tanks-remastered) and [Robot Pack](https://kenney.nl/assets/robot-pack) are listed as 2D CC0 assets. They are candidates and production references, not a promise that all match this art direction or camera. Do not mix them wholesale. [Sci-fi Sounds](https://kenney.nl/assets/sci-fi-sounds) is an available audio candidate; audition and mix before adoption.

The no-service fallback is a complete, coherent code-authored cutout style: rounded machine bodies, inset faces, distinct enemy shapes and simple rotating tools. That still requires deliberate art direction and visual review, but it does not depend on successful AI walk-cycle generation or a subscription.

## First art gate and scope boundary

Before adding a content catalogue, review a moving sample with one hero, two enemies, one salvage pickup, one projectile/tool, one ground treatment and the reusable hit/death/collection effects. The first playable comparison remains 90 seconds. It should include enough presentation to judge the promise fairly, not an elaborate marketing scene.

Approve only if: the hero and danger are readable at small scale; movement has character; hits and collection feel satisfying; style stays coherent; the same pieces support early and powered-up states; and adding a variant does not restart the art pipeline.

If the hero cannot be produced consistently, simplify its construction or choose a coherent pack-based body. If the gameplay lacks fun, change movement, enemies or the salvage rule before buying more art. If the generated visual target contains extra detail, treat it as something to cut, not an obligation to reproduce.

**Locked recommendations:** Windows, 2D landscape, automatic attacks, one workshop, compact machine bodies, separately animated tools, readable salvage loop, no paid dependency required.

**Still tunable through play:** attraction distance, orbit consumption/cap, run duration, upgrade cadence, enemy density, precise palette and effect intensity.

**Excluded initially:** humanoid animation libraries, eight-direction art, character-specific attack sheets, changing visible outfits, procedural worlds, multiplayer, live generative content, complex rigs and large skill trees.

## Research stopping point

The focused follow-up added production examples, corrected old asset URLs to current Remastered pages, and compared three viable non-humanoid directions. It did not establish a new benchmark of AI quality or require reopening the broad genre research. The most valuable next evidence is a moving art/gameplay slice under the user's control.

The visual-target prompt is saved alongside this brief. The first built-in image-generation attempt failed with a network error; a bounded retry did not finish promptly and its wait was stopped. No completed image was available to inspect or deliver. Consequently, this pass does not validate generated asset quality, repeatability, small-scale readability or animation. Those remain explicit checks for the first art/gameplay slice. No game implementation occurred in this iteration.
