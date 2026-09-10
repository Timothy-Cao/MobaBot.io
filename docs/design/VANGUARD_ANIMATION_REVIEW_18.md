# Vanguard animation review

9 September 2026. Scope: Vanguard only. Original code-authored shapes and pose timing; no purchased/imported/generated bitmap animation pack. Combat delays, damage, collision, energy and cooldowns are unchanged. This is a style-review candidate, not a claim of artist-finished animation or owner approval.

## Where to get assets

| Source | Useful for us | Important distinction |
|---|---|---|
| [Brackeys VFX Bundle](https://brackeysgames.itch.io/brackeys-vfx-bundle) | Best first pack to evaluate: particle textures, flipbooks and pre-drawn sprite sheets | Publisher lists CC0, including commercial use and redistribution; original contributors are credited on its page. Still inspect each included file/license before importing. |
| [Kenney Particle Pack](https://kenney.nl/assets/particle-pack) and [Smoke Particles](https://kenney.nl/assets/smoke-particles) | Simple, clean effect building blocks | CC0; these are textures/building blocks, not a complete character animation set. |
| [GDQuest Godot 4 VFX](https://github.com/gdquest-demos/godot-4-VFX-assets) | Godot particle/shader implementation references | Code is MIT, but its art assets are CC-BY-NC-SA 4.0. Do not assume all its textures are suitable for this commercial-intent project. |
| [Effekseer](https://effekseer.github.io/en/) | Dedicated effect-authoring tool to evaluate later | A tool, not a matching Vanguard asset pack. Integration and export workflow would need a separate evaluation. |

These listings were checked during this pass. No external pack was downloaded or committed. A public repository needs redistribution-compatible terms, not merely permission to ship an embedded asset in a game. Generic pixel-effect packs also need style matching; mixing hard pixels with the current clean vector-like robot is not automatically an improvement.

Yes, AI image generation can produce concept art, key poses and sprite-sheet candidates. A generated sheet still needs frame-count, registration/pivot, silhouette, alpha and temporal-consistency inspection. For this small mechanical kit, deliberately authored shapes, 6–8 stepped effect poses and a few smooth rigid transforms are currently the more controllable route. That is a project judgment, not a claim that AI cannot animate. No generative raster asset was used in this pass.

## Maturity assessment

Assessments are qualitative assistant judgments from code, earlier captures and the current rendered fixtures. **None are player-approved.** They are separate from the retained numeric game-quality ratings in QUALITY_BAR.md. “Decent” means coherent enough to test without a redesign; “candidate” means improved and technically checked, awaiting your style/feel verdict.

| Animation | Before | This pass / motion definition | Remaining maturation |
|---|---|---|---|
| Hero idle / movement | Decent basic hover | Retained face, bank and paired jets; D travel effects now follow velocity, not gun aim | Medium: directional body posing is still limited. A replacement character rig is not included. |
| Hammer | Serviceable, soft follow-through | Existing 200ms anticipation → fast 84ms stroke → held result → short recovery; truthful wider milestone arcs, steel head and charged rails | Small–medium: candidate. Judge head weight and whether the upgraded reach feels attached to the hand. |
| MG | Decent projectile distinction, little muzzle response | Tiny 65ms muzzle cue; stronger fifth-shot core remains clearly below Q in prominence | Small: candidate. Tune perceived cadence with audio; no listening verdict yet. |
| Q / Impact bolt | Already decent missile | Retain finned projectile and exhaust; replace generic impact ring with an eight-pose compact burst | Small: candidate. Judge missile/contact continuity at maximum zoom-out. |
| W / Core strike | Too similar to R | Narrow steel impact dart → accelerating descent → four-spoke contact burst → clean fade; center marker retained | Small–medium: candidate. Check whether the center-damage sweet spot reads under enemies. |
| E / Body slam | Motion readable, contact generic | Preserve plow and travel → directional impact wedges facing the actual dash → hollow full-radius shock | Medium: candidate. Shoulder animation could still use a dedicated chassis pose if this direction is approved. |
| R / Reactor drop | Larger W with generic ring petals | Wide caged drum → opening braces → heavier descent → eight-spoke reactor burst with brief core and optional vapor arcs; echo uses same language | Medium: candidate. Needs owner judgment of ultimate weight, especially during its second impact. |
| D / Ghost drive | Bare rectangular trails | Rounded chassis echoes with a small face streak; exhaust chevrons follow travel instead of target-facing aim | Small: candidate. Reduced mode removes echoes. Retain simple speed readability, not a screen-filling trail. |
| F / Phase hop | Generic expanding circle | Instant relocation unchanged; six-pose paired brackets contract into a narrow residual seam | Small: candidate. No travel ribbon implying collision or delayed arrival. |
| 1 / Orbit | Already decent | Retain near/far motion, tier trails and faster close orbit; do not add constant sparks to every blade | Small: retained. Biggest improvement would be more readable contact sound/feedback, not more rotating decoration. |
| 2 / Bulwark | Static deployment; functional barrel | Feet unfold over 240ms; barrel keeps its actual aim/recoil and fifth-shot cue; pulse now uses support-colored spokes | Medium: candidate. Assess whether the decoy looks sturdy enough without making its gun seem like an ultimate. |
| 3 / Reserve | Weak explanation through motion | Unfold → bank gauge → mint transfer motes only while stored reserve can discharge in range → mint overflow pulse | Medium–large: still the weakest. Transfer can be brief when the bank empties; test whether the bank/range relationship is understandable without hover text. |
| 4 / Overclock | Timer on a static object | Unfold → blue powered center → blue rotating brackets on the player only while inside → five-second timer expires | Medium–large: clearer but still needs an unmistakable recharge/energy association in player testing. No extra numerical UI added. |

## Shared animation specification

- Materials: matte teal shell, steel structure, cream hard highlight, brass impact; mint repair and blue overclock. Enemy coral/plum stays distinct.
- Timing: immediate input response; do not insert gameplay delays for animation. Rigid missiles, hammer and legs use eased transforms. Explosions use eight shape poses; blink uses six. Fades remain smooth so effects disappear cleanly.
- Sequence: setup → one contact accent → readable follow-through → disappear. Do not solve every action with concentric rings or increasing opacity.
- The strongest solid flash occupies only the central quarter-radius, lasts less than one quarter of the effect and is reduced in Reduced effects. Full damage boundaries remain thin and read from simulation.
- Secondary inner shards, vapor and afterimages disappear in Reduced effects; hit area, direction, shield, timer and in-range support state remain.
- No screen shake, actor-center displacement, random presentation seed consumption, new bitmap dependency or changed combat balance.

## Review reel and reproduction

Local artifact: `output/vanguard-animation-review.mp4`, encoded from actual Godot frames, 960×540 at 30fps. Not a generated video, manually illustrated mockup or synthetic reconstruction. There is no HUD/audio in this isolated motion fixture, so it is **not** proof of full-game readability or sound quality. Actual HUD/default-size stills were reviewed separately. Reserve starts with an artificial bank to demonstrate transfer; this fixture never writes player saves.

Ranks 5 and 10 each run through Q, W, E, R, D, F, Orbit, Bulwark, Reserve, Overclock, Hammer, MG in two-second segments. Rank 10 starts at 00:24. Early blank tails deliberately show effect expiry. The standard visual test additionally covers rank 1 and Reduced effects.

```powershell
& '.tools/godot/Godot_v4.7.2-stable_win64_console.exe' --path . --script res://tests/skill_visual_test.gd -- --vanguard-showcase --folder=res://output/vanguard-motion
ffmpeg -y -framerate 30 -i output/vanguard-motion/frame-%04d.png -c:v libx264 -preset fast -crf 20 -pix_fmt yuv420p -movflags +faststart output/vanguard-animation-review.mp4
```

The frames/video are ignored local review artifacts, not production assets. Production drawing source: `src/salvage/vanguard_motion.gd`, `vanguard_art.gd` and the Vanguard-gated sections of `workshop_art.gd`.

## Your review

Technical evidence: all 24 regression scripts passed; 460 Vanguard checks; 2,972 standard skill-visual checks; 2,936 Vanguard showcase checks with 1,440 captured frames. Ranks 1/5/10 and normal/reduced drawing are covered by the standard fixture. Current A0 bot outcomes and A5 full-route completion match the preceding build's fixed-seed simulation outcomes; A5 completes all 22 rounds at 4,354.3 simulated seconds using artificial health. This is not evidence of human animation recognition or fun. One previously observed intermittent two-object test-exit warning occurred in the broad suite; the focused verbose rerun is recorded separately in QA_18. No logged engine errors occurred. Existing raw-PNG inspection warnings are test-only.

Start with W → E → R and then the three constructs. For each: **keep / adjust / replace**, plus one reason. Useful specifics: “too spiky,” “impact too brief,” “want rounder smoke,” “R should linger,” or “cannot tell when the well works.” The main open style decision is whether these crisp mechanical shapes suit the game, or whether we should test a small CC0 hand-drawn flipbook family next. Do not expand this to other kits before your verdict.
