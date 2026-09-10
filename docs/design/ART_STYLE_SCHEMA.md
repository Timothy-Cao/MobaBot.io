# MobaBot.io — art style schema 2.0

## v0.18 Vanguard override

9 September tower milestones: rank 5 adds paired steel-edged side housings; rank 10 adds brass crown fins and an outer collar. Bulwark adds twin barrel rails. Preserve the central barrel/cross/lightning glyph to distinguish functions. Read radius and lifetime from the deployed unit, including live upgrades; never enlarge only the decorative range. Secondary pulse accents use current skill rank. Reduced effects retains hardware and functional rings. No raster additions. Review captures: skill_visual_test `-- --milestones`.

9 September follow-up: owner finds the full-detail family too polished for the world. Trial a reversible runtime 32×32 pixel grid on all twelve Vanguard icons, saturation ×0.85 and brightness ×0.97. Retain original source PNGs and 128px imports unchanged; no new raster provenance needed. This is a display filter, not replacement artwork or a pixel-art redraw. Review actual combat size in normal/reduced effects before judging style fit.

Complete Vanguard icon follow-up: owner approves QWER's painterly MOBA direction. D/F, 1–4, hammer and MG now match it with generated 128px imports. Distinct silhouettes: cyan propulsion boot, violet blink rifts, three orbiting blades, armored turret, green repair reservoir, blue open-fork well, block hammer, multi-barrel gun. Preserve QWER unchanged. First D rocket-shaped draft rejected for confusion with Q. Exact prompts/hashes in `assets/vanguard_icons/REMAINING_PROVENANCE.md`. This extends icons only, not world animation. New eight still need owner approval at combat size.

Owner-selected Painted-only follow-up: Settings no longer exposes skins. Vanguard Q/W/E/R use original generated painterly MOBA ability illustrations in `assets/vanguard_icons`, inspired by LoL/Dota's broad high-contrast action-icon language while retaining teal salvage machinery, steel/brass and cream. Q diagonal warm rocket, W narrow blue precision dart, E horizontal shoulder impact, R wide golden reactor blast. Opaque backgrounds, imported at 128×128 with mipmaps; source masters, exact prompts and hashes in `assets/vanguard_icons/PROVENANCE.md`. Existing icons remain for other skills/equipment, and native fallbacks remain solely for missing assets/regression. This supersedes earlier Base/Painted selection instructions. Review at actual 40/54px HUD size; do not infer player approval from generation or passing tests.

Current animation-review pass: original `vanguard_motion.gd` defines eight-pose shard bursts and six-pose blink brackets. W is a narrow impact dart; R is a wide caged drum, not merely a scaled W. E burst wedges follow the dash direction. Support pulses stay mint; Overclock's in-range brackets are blue. Construct legs unfold, Reserve transfer motes require a bank and proximity, and Ghost echoes follow travel direction. Smooth rigid transforms coexist with stepped impact shapes; no new bitmap or third-party asset dependency. See `VANGUARD_ANIMATION_REVIEW_18.md` for per-animation maturity, timing, sources and review instructions. This supersedes older generic-ring descriptions below, not the collision, palette or reduced-effects contracts.

Cursor family: original 40×40 SVGs in assets/cursors. Menu uses a cream/steel arrow with teal inset/brass tail; combat uses open steel/teal brackets around a precise center dot; armed aim/Practice placement uses a brass diamond. Native hardware cursor, no trails, bobbing or zoom scaling. Menu pointer returns over interactive controls; native text/resize cursors remain. Hotspots and actual-size light/dark contrast are verified by cursor_test.gd. No generated bitmap assets.

Third playtest: keep the paired hull/energy strips below the player's feet (fixed screen-size bars with a body-space offset), not above the magnet. Walls remain physical movement obstacles but no longer visually clip current-rule projectiles or laser rays; tells and damaging ray endpoints must agree.

Second playtest animation pass: Body slam carries a steel/brass leading shoulder arc and an expanding contact burst; W/R use finned canisters with bright cores and accelerating vertical descent. R's larger reactor detonates into a short central star, expanding paired rings and separated blast petals; secondary shards are reduced-effects optional. Preserve actual simulation radii, ground centers and threat layering. No generated animation pack or new bitmap dependency.

Post-playtest HUD refinement: three compact translucent top readouts instead of a full-width slab, and an open-upper-edge ability dock with a shallow backing strip. Preserve skill icon sizes and horizontal key positions. Practice damage readouts use outlined cream totals, quiet steel DPS and brass floating hits; same semantics in Reduced effects. Do not add particles or screen shake to measurement feedback.

Reuse the Painted/Base icons; no new bitmap assets or provenance claims. Fixed HUD mappings use existing hammer-adjacent/thrust, reactor, pulse-sentry, medic and converter silhouettes. World motion remains native: a steel-head/teal hammer anticipation and 90° stroke, body-slam compression trails and impact ring, abrupt blink endpoints with no travel streak, Ghost afterimages, descending W/R cores, and grounded support tripods. Reserve uses mint, recovery uses blue, and impact uses restrained brass. Reduced effects drops afterimages/secondary rays but retains hit areas, shield, totem ranges and timers. Practice terrain uses solid low-contrast capsule greyboxes whose thickness matches collision; this is not a finished environment-art pass.

## v0.17 motion override

The title illustration is now two generated layers from our own v1 artwork: stationary empty foundry plus transparent robot, with small native hover and jet motion. Reduced effects freezes both variations. Exact prompts, source IDs and hashes are in `assets/menu/LAYERS_PROVENANCE.md`; originals remain. This supersedes the static-title rule below only. Do not claim a rigged or generated animation set.

Heavy commanded attacks use slow brass-core slugs, a 0.2-second barrel charge, six-unit recoil and directional hit sparks. Autonomous shots stay small and pale with quieter audio. Close-range effects expand only with actual geometry; Guard sweep moves a steel blade across its true cone. Casts briefly open the barrel assembly without changing player collision/position. Arc lancer, Burst battery and Bomb carrier share hostile shell materials but use one long barrel, paired barrels and three mortar tubes respectively. Laser/bomb warnings remain above friendly spectacle and unchanged by Reduced effects. Existing Painted/Base icons are retained.

## v0.16 Painted / Base skin override

The owner's new request explicitly introduces generated bitmap icons. **Painted** is the experimental default; **Base** preserves the native icon drawings and is selectable in Settings. This supersedes the older no-bitmap instructions below, not the combat-motion or readability rules. World actors and skill animations remain native; this is not a replacement character-animation pack.

Art direction: medium-detail digital gouache / cel-painted salvage machinery. Use bold functional silhouettes, three broad value groups, matte petrol-teal enamel, steel working surfaces, ochre-brass joints and a cream upper-left edge light. Orange identifies heat, icy blue electricity, violet gravity and mint repair. Use broad material planes; avoid chrome, bloom fog, ornament and microtexture. See `assets/painted/manifest.json` for the reusable shared generation prompt and every subject. These are AI-generated illustrations, not claims of human authorship.

Each of 49 skill/toggle icons and 40 equipment icons is generated individually. The rocket establishes the reference material language; subsequent jobs reference its style, not its shape. The laser was revised after inspection because the first result resembled a saw rather than a continuous beam. Keep source originals, recorded hashes and revision provenance. Equipment has eight silhouettes across five **tiers**, no set effects. Richer tiers may add structural detail, but a cape must still read as a cape at small size.

The icon backgrounds deliberately remain opaque dark navy, matching the UI. Alpha validation therefore requires fully opaque square sources, not transparent cutouts. No bitmap is used as a world sprite. Import at a maximum 256 pixels with mipmaps for stable small-scale presentation; retain full source PNGs for revision. Validate with `painted_art_test.gd`: 128 / 64 / 32 px alongside 32 px Base symbols. A recognizable silhouette matters more than details visible only when enlarged. Missing images fall back to Base.

Color restraint: preserve the warm player/pickup highlights and hostile warning contrast. Three floor-sector families gain muted blue, warm foundry and violet variation without making the floor compete with damage tells. Resource bars above the player are compact, partially transparent and outlined; no repeated numeric labels. Normal and reduced effects must preserve the same gameplay information.

The Painted experiment still needs the owner's recognition/preference test. Keep the Base escape hatch; do not infer better art or better gameplay from the number of generated assets.

## v0.15 motion and recognition override

Use distinct mechanical motion within the existing native family. Returning blades spin with steel edges and change the hub/trail from teal outbound to brass inbound. Gravity arms and motes travel inward. Pull/push cones use oppositely directed chevrons; hold their initial contrast before a quick fade. Rim cuts trace the actual outer payoff and inner boundary. Thrusts use a piston-like shaft and directional head. Delayed strikes show a descending steel core and a countdown on the true ground radius. Impacts use a fast expanding thin ring and a few material shards, never an opaque disc over threats.

Constructs unfold a tripod, then show their function: barrel recoil, pulse, repair mote, opening mirror cores, aimed hook or moving tread. Remaining-life arcs use actual upgraded lifetime, not a fixed 20-second assumption. Barriers retain a visible collision line from the first frame while endpoint posts deploy. Movement trails stay behind the actor; roll armor and repair brackets do not shift its center. Reduced effects removes secondary trails and reduces repeated motifs without erasing ranges or directional feedback.

Icons must separate neighboring functions at 32 px: Core strike is a descending canister, Orbital entry a landing chassis, Siege battery three shells, Bulkhead solid slabs, Crosswire wired anchors, Plate recall converging plates, and Piston thrust an extending actuator. Tumble, Echo, Veil, Spring vault and Wall runner have separate silhouettes. Preserve the fixed canvas, shared bevel, palette and original in-game text. No new raster pack or animation-generation dependency was introduced.

Use [QUALITY_BAR.md](QUALITY_BAR.md) for acceptance and the honest current assessment. Technical coverage and a magnified render do not establish player recognition, perceived weight or fun. Retain simple world actors, existing menu illustration and user music; do not describe this as a complete character/environment art replacement.

## v0.14 expedition override

Extend the native 64-unit icon family, not the archived painted equipment style. Twenty-eight new action drawings and eight gear silhouettes use steel edges, enamel bodies and sparse brass/cream highlights. Forty equipment variants are five controlled set treatments over those eight shapes; their small motif counts supplement color. They are not forty independently painted assets. `expedition_icon.gd` is the original source; no new external art pack or bitmap generation was used in this pass.

Six mastery branches use stat-specific icons, two prerequisite lanes, four depths, small rank counters and one hover/focus inspector. Equipment shows eight fitted slots, five matching collection variants and one signed comparison, including removed stats. Keep the two Build pages and four basic settings. Chest choices display a slot, icon and short Unlock/Replace/+2 ranks consequence; mechanics remain in tooltips. Do not add a dashboard for each progression currency.

Constructs share a tripod grammar but use distinct barrel, pulse ring, repair cross, paired mirror cores, hook and crawler tread details. The major-summon limit is separate from small shoulder drones and the one equipped pet. Returning blades use non-self-intersecting steel polygons. Cones use their actual angle/reach; only center-critical strikes show an inner damage ring. Barrier width, dash landing points and previews respect collision rules. Milestones improve actual effect geometry, reach, healing or lifetime; a bigger decorative circle alone is not an upgrade.

The campaign reuses three world sectors and eight boss pattern configurations on the same industrial body. Retain hostile coral/plum and functional telegraphs above friendly effects. Do not imply eight original boss illustrations or eight independently built maps. The foundry menu illustration and user music remain unchanged. See `QA_14.md` for rendered checks and remaining art scope.

## v0.13 pruning override

Keep existing art; reduce interface surface area. Home: title, Play, Loadout, Equipment, Settings, Quit, tiny version. No subtitle or route itinerary. Build: Overview/Mastery only; current-kit icons and six stat rows replace separate dashboards. Equipment: fitted items, collection, selected comparison; no decorative robot schematic. Settings: four option rows, separate Controls page. Remove repeated instructions and zero-value rank clutter; inspect by hover or selection. Preserve readable costs, locked states, warnings, mastery choices and numerical upgrade gains. Stable top-right Back and restrained tab underlines remain the navigation language.

## v0.12 additions

Keep the foundry title and native icon family. Coolant trail uses one cream/teal vial silhouette with a brass cap on the existing 64-unit canvas; no new raster style. World patches use a low-opacity mint fill and thin coverage edge matching their 26-unit damage radius. Reduced effects removes decorative bubbles but keeps coverage visible. Basic/automatic shots are small pale streaks; sniper streaks are longer. Q retains its much larger finned missile/exhaust. The A range preview is temporary and centered on the player, not the camera; a gold ring identifies the ordered target. No persistent arena control prose.

## v0.11 override

The title screen now uses one original generated foundry illustration with native text and controls, replacing v0.10's enlarged code-native robot vignette. All interactive icons remain the shared code-native family, with quieter inset backgrounds. Major panels and cards are square; native small buttons retain subtle rounding. Equipment uses an assembly schematic, grouped collection and signed stat comparison. Mastery uses three compact routes and one stable hover/focus inspector. Gameplay has a smaller grouped dock and three-sector mission rail. See the updated format rules below and `PRESENTATION_RESEARCH_11.md` for rationale. Music skips any Dummy audio driver, including a rendered session without an output device.

## v0.10 override

Current UI uses the original `ability_icon.gd` drawing family for **all** actives, passives, mastery nodes and equipment. Existing generated PNG masters remain archived with provenance, but are not rendered in this UI. Do not mix the old detailed raster illustrations back into the new medium-detail tiles. 64-unit canvas; broad steel/teal/brass material planes, one upper-left bevel, a small lower-right shadow, no texture noise. Match silhouettes, not intricate surface detail. Main-menu artwork is the actual code-native robot at a larger presentation scale.

UI corners are now 0–2 px; prefer whitespace, ruled stat rows, thin connectors and individual icon frames over repeated large cards. Equipment separates fitted slots, the collection and one selected item. Skill explanations and cost rules belong in hover details. Operational save failures remain visible.

Q uses a finned steel missile, broad exhaust and a separate impact cue. Automatic fire remains small. E is the descending reactor strike. R is a sustained cream-core/brass/teal cutter with damage-width outer rails and a remaining-channel ring. Milestones enlarge the actual geometry and use brass accents. Arc Coil uses a jagged cream/teal path; threat effects remain coral/plum and render above friendly effects. Ghost drive has a rotating pale-teal ring, without camera shake.

Foreman is a 120-unit-wide radial machine with paired piston arms and a reactor core; its cutter rotation accelerates when overclocked. Ring and fan warnings use the same directions as the damaging projectiles. Warm-up strokes are less bulky, not invisible. Older sections below describe historical assets and still supply palette/material guidance unless overridden here.

## v0.9 additions

The game is now MobaBot.io. Preserve the salvage-tech material language below. Static equipment uses three slot silhouettes: pulse core, broad robot chassis, paired thrusters. Mk I/II share the silhouette and differ through explicit labels/stats; do not pretend there are six unique paintings. New chassis/drive images are transparent PNGs with mipmaps, inspected in actual UI; rejected painted checkerboard outputs are not assets. Accepted prompts and origins: assets/upgrades/EQUIPMENT_PROVENANCE.md.

Q uses a rocket silhouette, W a flame, R a descending strike over concentric rings. QWER stay larger than DF/T. The flame preview is a cone matching its damage angle/reach; the nuke preview radius matches its collision radius. Gold/cream nuke impact and short flame jets add response without full-screen flashes or camera shake. Friendly FX stay below hostile tells.

Health, energy and XP form one compact HUD group. Gameplay has no permanent control footer, tool count or scrap counter. Controls belong in Settings; credits and equipment are inspectable in Tab. Equipment descriptions state actual effects, not hype.

## Style in one sentence

**Chunky salvage-tech toys: teal enamel, brushed silver machinery, warm brass fittings, cream faceplates and graphite outlines; broad cel-shaded forms, a top-left light and small purposeful wear.**

Art serves recognition at combat scale. Friendly equipment looks like it belongs to one repair workshop. Opponents are corrupted industrial machines from that same world, not unrelated fantasy monsters. The fantasy is rebuilding a powerful little machine from the scrap it collects.

## Vocabulary to reuse

Chunky, compact, readable silhouette, bevelled housing, hand-painted cel shading, broad material planes, enamel teal, brushed silver, brass fasteners, dark graphite seams, cream highlight, mechanically plausible, playful industrial, salvage workshop, controlled wear, generous negative space, isolated equipment, cohesive game asset.

Avoid: cinematic concept art, hyperrealism, wet chrome, intricate filigree, full-surface grime, dense greebles, cyberpunk neon fog, bloom clouds, random runes, glowing text, painterly backgrounds in icons, different camera angles between related assets, inconsistent pixel-art resolution, photoreal metal beside flat cartoon characters.

## Palette and meaning

| Token | Colour | Use |
|---|---|---|
| Graphite | #14242C | Outlines, seams, deepest UI surfaces |
| Panel slate | #21333D | UI cards, inset equipment areas |
| Floor slate | #293E46 / #304851 | Low-contrast walkable workshop |
| Enamel teal | #399C99 | Friendly machine shells |
| Signal teal | #78CBB6 | Ready/selected, helpful effects, friendly targeting |
| Steel | #BDD3CE | Blades, barrel rails, structural braces |
| Brass | #EFC16B | Fasteners, rewards, ultimate emphasis |
| Cream | #FFF0C7 | Faceplate, hard highlights, projectile cores |
| Threat coral | #EE796C | Common hostile bodies, incoming damage |
| Threat plum | #B2809C | Charging/heavier variants |
| Quiet text | #A0B3B7 | Secondary labels, not primary interactions |

Palette is a target, not a requirement that every generated pixel match a swatch. Use hue families and material relationships. Colour alone must not convey function: pair hostile colours with distinctive bodies and telegraphs; pair friendly equipment colours with glyphs and category labels.

## Shape and material grammar

- Hero: compact rounded square, visible cream face and two teal eyes, paired thruster pods, small horseshoe magnet. Silhouette must survive at ~45 screen pixels.
- Scout/drone: a smaller teal shell with a single face module; Scout has a brass magnet, Drone a steel barrel. One pet at a time.
- Summon: broad tripod footprint, stable grounded silhouette, teal body, steel legs, brass collar. Sentry has a barrel; repair beacon has a cream cross and a quiet circular range indicator.
- Bumper: round coral shell. Charger: plum wedge with a committed directional telegraph. Tank: rectangular plated body with steel brow and brass rivets. Boss: larger gear/radial silhouette with a persistent health bar.
- Demo wardens: Ram uses a bronze directional plow/wedge and dark inset visor; Artillery uses a rounded plum chassis with paired bronze mortar barrels. Foreman retains the large radial gear silhouette. Do not distinguish these threats by color alone. Functional danger remains coral/cream; gold means exposed recovery. Direction arrows use dark backplates and coral chevrons, not new decorative asset styles.
- Motion QA rule: do not shift actor centers away from hit geometry for shake. Automatic pulses never shake the world; hurt may use a brief small player-only angular recoil. Clamp dash lean to the normal movement range. Reduced effects suppresses both recoil and every enemy's hit-color flash. Charge tells use swept capsules with endpoint caps. Arena overscan is dark graphite outside the existing floor boundary, not extra walkable space.
- Blades and tools: steel cutting edge, teal hub, brass centre pin. Avoid making every component gold; gold must still make rewards conspicuous.
- Wear: two or three deliberate edge chips at illustration scale; omit at actor scale. Broad bevel highlights, not noise textures.
- Light: upper left, darker lower-right body plane, short grounded/hover shadow below. No mixed photoreal HDR lighting.

## Asset formats and detail budget

Inventory/upgrade illustrations: isolated transparent PNG, one centred object, approximately 12% safe margin, three-quarter view, readable at 48 px; inspect at 32, 64 and 128 px. Export square variants for new work where practical. Keep mipmaps enabled for scaled icons. Existing non-square images fit by aspect ratio, never stretch.

World actors: code-native shapes for now, with 2–3 material blocks and 1–2 strong highlights. Animation is transform-based: hover, bank, recoil, squash, short flashes. Generated animation is not a runtime dependency. Match material language rather than forcing painterly detail into 30 px enemies.

UI (0.11): graphite/slate planes, square major panels and cards, fine separator rules, restrained 1 px borders and 2 px selected outlines. Small existing buttons may retain a 6 px corner radius at the 960x540 logical canvas. Tabs use an underline, not nested filled rectangles. Cream names, muted metadata, teal ready state, gold key information. Short labels; descriptions explain effects, not marketing. Details belong in hover/focus or one stable inspector. No slogans such as “unleash your potential”.

Action icons (0.11): dedicated square drawings use a 64-unit canvas, quiet slate inset with a restrained corner bevel, broad steel/cream silhouette and limited brass highlights. No repeating diagonal background stripes. Reuse the identical icon across HUD, loadout, equipment, inspection and rarity rewards. Distinct motifs: salvo bolts, concentric shock rings, shield, rail needle, mortar crosshair, ram housing, broad beam, speed chevrons, paired blink portals, sentry and repair cell. The health-to-energy cell has a coral drop. Rarity is an external border and written label, never a recoloured functional symbol. No raster variants or bespoke animation sheets required for these icons. Original source: `src/salvage/ability_icon.gd`.

Title illustration (0.11): one full-bleed foundry launch bay, not a collection of oversized isolated icons. Keep left third dark and quiet for native typography/navigation; place the cream-face, teal-shell, coral-magnet hero in warm reactor light on the right. Broad cel-shaded planes, architectural depth and few wear marks. Graphite shadows separate the robot from warm brass machinery. No baked lettering, invented UI, copied characters, photoreal chrome or neon fog. The illustration stays static; no gratuitous parallax/shaking. Small native UI hover states provide feedback. `assets/menu/PROVENANCE.md` records the exact generation prompt and inspection. Image is intentionally opaque, 1672×941; use aspect-preserving cover and mipmapped filtering. Display scale was checked in actual Godot captures.

## FX and audio rules

Slice 05 milestones keep the action icon stable. Use stepped increases in actual ring radius, beam width, orbit/tool size or volley count, plus restrained gold cast accents and starred rank labels. Functional telegraphs must grow with collision/range. Pressure elites use gold outer hardware accents and runner streaks while retaining hostile coral/plum bodies. Supply drops: teal lightning cell versus coral repair cross; distinct symbols prevent colour-only identification. Reuse current geometry and materials rather than adding unrelated asset packs.

- Kill -> a few material fragments -> brass pickup scatter -> accelerating attraction trails -> short rising pickup notes -> orbit tool/pulse reward. Do not delay control to sell an effect.
- Friendly targeting: thin teal outline and restrained fill; danger telegraphs: coral with a contrasting core. Big ultimate can expand its ring/beam but must leave hostile projectiles readable.
- No full-screen white flash. Brief small impact shake only, disabled in Reduced effects. Reduced effects keeps functional targeting and reward feedback.
- Pickup tones climb over a short streak, with bounded pitch and voice count; not a separate loud sound for every dot in a 48-item burst.

## Reusable generation prompt

> One isolated [OBJECT], a game inventory illustration for Workshop Salvager. Chunky compact salvage-tech toy machinery, enamel teal housing, brushed silver working parts, warm brass fasteners, cream edge highlights and dark graphite seams. Broad hand-painted cel-shaded planes, mechanically readable silhouette, subtle bevels and only two or three small wear marks. Three-quarter equipment view, consistent upper-left light, no cast background shadow. Transparent background, centred single object, generous 12 percent clear margin. Clearly readable at 48 pixels. No text, no lettering, no logo, no frame, no particles, no scenic background, no photorealism, no dense greebles, no neon fog. [FUNCTIONAL SILHOUETTE: e.g. paired magnetic poles, a large central coil, or a broad steel saw blade]. Match the supplied Grinder / Pulse / Heavy bolts reference illustrations in materials, line weight and finish.

Variants change **one** thing at a time: functional silhouette, power-tier attachment, or threat material accent. Preserve the rest of the prompt and references. Do not independently improvise a new art direction for each ability.

## Review checklist / current audit

9 September Vanguard rank pass: code-native hammer icon and effects use the existing graphite/steel/teal/brass palette. Rank 5 adds broader geometry and charged accents; rank 10 adds cream cores and a second restrained trail. Q exhaust, W/R cores and impact rings, E shoulder plates, D/F travel accents, orbit trails and construct indicators share these materials. No bitmap asset or provenance changes. Hammer sweep boundaries use the collision angle/range; cosmetic rocket exhaust is not a hitbox. Inspect rank 1/5/10 at actual combat/icon size in normal/reduced modes with `tests/skill_visual_test.gd` and `tests/vanguard_test.gd -- --render` (captures ignored under output).

Existing seven generated PNGs: retain as the equipment master set. Prompts and origins stay in `assets/upgrades/PROVENANCE.md`. They already share teal/steel/brass forms. Rapid/Capacity have non-square source canvases; UI aspect-ratio fitting is intentional.

This pass: world outlines and reward gold aligned to UI; orbit tools shifted from solid gold to steel/teal/brass; pet, sentry and beacon use the common construction language; tank threat uses plated plum/steel; ability glyphs distinguish reused equipment; pickup trails and cast telegraphs follow semantic colours.

Known mismatch: inventory illustrations have richer bevels than the simplified world characters. This is acceptable at current scale but is not a claim of identical rendering style. Before a commercial asset pass, compare hero/enemy sprites alongside the item master sheet at actual play scale. New generation must be visually reviewed for silhouette, alpha edge, scale readability, lighting and theme; a good prompt alone is not acceptance.
