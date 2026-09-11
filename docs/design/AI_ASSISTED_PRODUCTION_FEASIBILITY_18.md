# AI-assisted production feasibility

11 September 2026. Research and planning note only; no renderer, gameplay or asset change is authorized by this document.

## Owner direction

Vanguard is in a good place. Preserve it as the current quality baseline and put the next gameplay-design effort into refining another class. Do not combine that class pass with a renderer migration: each change needs a readable before/after and its own playtest.

## Bottom line

Yes, a solo creator using the $200 Codex plan, Godot, Blender and one focused month of Meshy can make a high-quality commercial-looking survivor game. The credible target is **strong, cohesive stylized indie quality**, not unlimited content or the production density of an established studio.

- **Vampire Survivors-level presentation and polish:** highly feasible on the existing 2D foundation. Its standard is not expensive geometry; it is a coherent look, excellent feedback, readable escalation, content tuning and extensive playtesting.
- **Deep Rock Galactic: Survivor-like top-down 3D presentation:** feasible as a small vertical slice, but a full conversion is a major production decision. It needs a new 3D presentation/physics layer, lighting, animation, materials, terrain and performance work. Meshy can accelerate asset starts, not eliminate those disciplines.
- **The original Deep Rock Galactic:** not a credible solo target at this budget. It began with six veteran developers, spent years in open development, and its art director explicitly described choosing lower-detail models to control team/content scope. Its co-op, procedural destruction, first-person animation, audio, level generation and long content tail make it a different production category. [Unreal Engine developer interview](https://www.unrealengine.com/developer-interviews/guns-gold-and-glory-in-the-caverns-of-deep-rock-galactic), [GDC talk description](https://www.gdcvault.com/play/1028756/Independent-Games-Summit-Developing-a).

My recommendation is to target a distinctive **MobaBot-quality stylized survivor game**, initially in 2D or restrained 2.5D, and use DRG/DRG: Survivor as references for silhouette, material language, impact and environmental atmosphere rather than as a feature checklist.

## What the current project makes realistic

Repository inspection on 11 September found a deliberately 2D build: its gameplay scenes are `Node2D`, its player is `CharacterBody2D`, and it uses Godot's GL Compatibility renderer. It also has a useful separation seam: 44 source classes are `RefCounted` simulation/data classes, compared with a small number of scene nodes. This is good for iteration and could preserve some rules during a visual migration.

It is still not a one-click 3D port. A true 3D version would at least replace or adapt:

- `Vector2` spatial rules, 2D collision and navigation;
- camera, selection, mouse projection and terrain intersection;
- custom 2D drawing in the world-art layer;
- projectiles, telegraphs, hit geometry and crowd rendering;
- character/enemy rigs, animation state, materials, lighting and post-processing;
- dense-wave GPU profiling and new visual acceptance fixtures.

Godot itself is capable of this. Its desktop Forward+ renderer is the most feature-rich path and supports clustered lighting and screen-space effects; the current Compatibility renderer is deliberately the least advanced. Godot recommends glTF for 3D scenes and can import `.blend` files through Blender's glTF exporter. [Godot 4.7 renderer features](https://docs.godotengine.org/en/4.7/about/list_of_features.html), [Godot 3D import workflow](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/index.html).

## Feasibility ladder

These scores and schedules are planning estimates for this project, not published industry benchmarks. They assume one committed creator, the existing working combat foundation, no multiplayer and disciplined scope.

| Target | Feasibility | First convincing vertical slice | Credible solo full-game range | Main risk |
| --- | ---: | ---: | ---: | --- |
| Polished 2D / painted survivor presentation | 8/10 | 1–3 months | 9–18 months | Content, animation/audio polish and playtest time |
| Restrained 2.5D: 2D rules with selective 3D environments/actors | 6/10 | 3–6 months | 18–30 months | Mixed visual language and duplicated 2D/3D tooling |
| Full top-down 3D near DRG: Survivor's finish | 4/10 solo | 4–8 months | 2–4 years solo, or materially faster with an experienced small team | Asset consistency, animation, terrain and crowd performance |
| Original DRG-like co-op first-person production | 1/10 solo | A prototype is possible; a representative slice is not a one-person side project | Multi-year experienced team | Multiplayer, procedural worlds, content and production breadth |

The schedule is dominated by human review and revision, not code generation. Vampire Survivors began as a solo project but had outside input from the beginning and later team support. The relevant lesson is that approachable art does not imply a negligible polish burden. [Recent creator interview](https://www.gamespot.com/articles/im-making-this-for-me-not-to-make-everyone-happy-vampire-survivors-creator-on-his-next-game/1100-6536362/).

DRG: Survivor is also an important reality check. It is a solo top-down auto-shooter, but its developer is an established studio; Funday currently describes itself as a company of more than 50 experienced developers with over 60 shipped titles. This does **not** mean all 50 worked on DRG: Survivor, but it does mean the reference came from an experienced production organization rather than a raw solo pipeline. [Funday game description](https://www.fundaygames.dk/), [Funday company profile](https://joinus.fundaygames.dk/jobs).

## Cash cost

### Fixed tools

| Item | Current price | What it buys / does not buy |
| --- | ---: | --- |
| ChatGPT Pro 20x / Codex | $200 per month | High Codex capacity, but not unlimited use. Work and Codex share a task budget; consumption varies with model, context and task complexity, and weekly limits may apply. [Official OpenAI pricing](https://learn.chatgpt.com/docs/pricing) |
| Godot | $0, no engine royalty | MIT-licensed engine; the game remains the creator's work, with the Godot license notice included in distribution. [Godot license](https://godotengine.org/license/) |
| Blender | $0 | Free/open-source 3D suite, commercially usable; Blender's GPL does not apply to artwork created with it. [Blender overview](https://www.blender.org/about/), [Blender license explanation](https://docs.blender.org/manual/en/dev/getting_started/about/license.html) |
| Steam Direct, if/when shipping | $100 per app | Store submission fee, not marketing, QA or certification. [Steamworks documentation](https://partner.steamgames.com/doc/gettingstarted/appfee) |

### Meshy for one asset sprint

As of this research, individual plans are Pro $20/month for 1,000 credits, Premium $40/month for 3,000, and Ultra $100/month for 8,000. Paid plans include private/commercial asset rights and unlimited model downloads. New subscribers are currently advertised 50% off their first individual-plan month; confirm the checkout price because promotions change. [Meshy plan comparison](https://help.meshy.ai/en/articles/12062933-which-meshy-plan-is-right-for-you-free-vs-pro-vs-premium-vs-ultra), [official pricing page](https://www.meshy.ai/pricing).

The **$40 Premium month** is the sensible middle-tier experiment. At 20–25 credits per Meshy 6/7 model generation, 3,000 credits theoretically funds about 120–150 initial generations. That is not 120–150 finished game assets: retries, alternate views, texturing and rejected directions reduce final yield. [Meshy credit reference](https://docs.meshy.ai/en/webapp/pricing).

Do not subscribe until the asset list and style bible are ready. A one-month batch should target roughly:

- one hero-quality robot candidate and a deliberately limited animation test;
- six enemy silhouette families plus variants;
- one boss family;
- 15–25 rocks, walls, machinery and salvage props;
- a small set of pickups and construct bodies;
- alternate generations for the hardest silhouettes.

Treat every output as source material. Meshy's own game-ready guide says it exports a single LOD, may produce floating geometry or holes, and recommends Blender cleanup, decimation and manual LOD creation. Its formats include GLB/FBX/OBJ/BLEND; for this project, prefer GLB/glTF through Blender into Godot, retaining editable `.blend` sources. [Meshy game-ready guide](https://help.meshy.ai/en/articles/15723950-how-to-make-meshy-models-game-ready), [Meshy format list](https://help.meshy.ai/en/articles/9991884-what-3d-file-formats-does-meshy-support-full-export-list).

### Realistic total budgets

These are proposed cash envelopes, not vendor quotations, and exclude the creator's labor and an already-owned computer.

| Scope | Lean cash envelope | What is included |
| --- | ---: | --- |
| One-month art/3D feasibility sprint | $240–$400 | Codex, Meshy Premium, optional small asset/audio purchases; no store fee required |
| Three-month polished vertical slice | $800–$2,000 | Three Codex months, one focused Meshy month, selected licensed assets/audio and optional Steam fee |
| Lean solo commercial 2D/2.5D production | $3,000–$10,000 | Roughly a year of Codex, limited AI/asset subscriptions, store fee, modest audio/art/QA/localization help |
| Contractor-assisted strong indie finish | $15,000–$60,000+ | Specialist animation, key art, audio, trailer, localization, QA and difficult asset cleanup |

The largest hidden cost is time. A $240 tool month can produce a great prototype and reusable pipeline; it cannot purchase taste, coherent animation, encounter variety, audio direction, marketing art or hundreds of hours of player observation.

## What Codex can and cannot replace

Codex is a strong force multiplier for:

- Godot gameplay and editor tooling, import validation, shaders and automated checks;
- Blender Python for naming, pivots, scale, material normalization, batch exports, collision proxies and LOD preparation;
- repeatable screenshot/video fixtures, performance probes and asset manifests;
- rapid implementation of carefully bounded class prototypes;
- maintaining the simulation/presentation boundary during iteration.

It does not independently certify:

- whether motion feels weighty or readable in a real fight;
- whether a generated mesh has a consistent art direction across the whole game;
- whether topology deforms well in every animation;
- whether the audio mix is tiring;
- whether a player understands an encounter or wants another run;
- whether third-party input material is safe to use. Paid output rights do not authorize copyrighted input references.

The $200 plan is likely enough for this repository if work stays milestone-sized and heavy repetitive jobs use smaller models. It is not a fixed number of development hours. Official guidance says usage varies with context and complexity and recommends precise prompts, limited source context and smaller models where appropriate. If a production sprint repeatedly hits limits, buy temporary credits/API capacity or slow the queue; do not design the project around uninterrupted infinite-agent labor.

## Recommended production experiment

Do **not** convert MobaBot to 3D yet. Run a disposable comparison after the next class design is settled:

1. Freeze one representative 5–10 minute Vanguard encounter and record the current 2D baseline.
2. Write a one-page visual bible: silhouette, camera, palette, material roughness, lighting, poly/texture budgets and reduced-effects rules.
3. Build a separate 3D spike with one room, Vanguard, two enemies, one boss fragment, Q/E/R, pickups and 100–150 simultaneous enemies. No progression migration.
4. Generate only a few Meshy candidates, clean them in Blender, and use the exact same damage/timing rules where practical.
5. Compare both builds at actual play zoom for recognition, impact, frame time, authoring time and revision cost.
6. Continue only if the 3D version is clearly more appealing **and** adding the second enemy costs no more than roughly twice the mature 2D workflow.

Success gates for the spike:

- a fresh player recognizes player, basic enemy, specialist, pickup and dangerous tell without explanation;
- the look remains coherent without relying on close-up screenshots;
- 60 FPS is sustained on a named target machine during a representative dense wave;
- one rig supports needed gameplay poses without obvious deformation;
- collisions and telegraphs remain more readable, not less;
- every source and license is recorded;
- the owner prefers the moving build, not merely the isolated model renders.

## Recommended decision

For MobaBot now:

1. Freeze Vanguard as the benchmark.
2. Refine the next class on the current rules and presentation so class quality can be judged independently.
3. Aim for excellent 2D/painterly survivor presentation as the shippable fallback.
4. Prepare a 3D style bible and asset manifest before paying for Meshy.
5. Buy one month of Meshy Premium for a controlled spike, not a wholesale conversion.
6. Decide 2D versus 3D only from a moving, crowded, instrumented vertical slice.

This path makes a polished game realistic without betting the working combat foundation on an aesthetic experiment.
