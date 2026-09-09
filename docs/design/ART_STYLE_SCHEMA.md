# MobaBot.io — art style schema 1.7

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

Existing seven generated PNGs: retain as the equipment master set. Prompts and origins stay in `assets/upgrades/PROVENANCE.md`. They already share teal/steel/brass forms. Rapid/Capacity have non-square source canvases; UI aspect-ratio fitting is intentional.

This pass: world outlines and reward gold aligned to UI; orbit tools shifted from solid gold to steel/teal/brass; pet, sentry and beacon use the common construction language; tank threat uses plated plum/steel; ability glyphs distinguish reused equipment; pickup trails and cast telegraphs follow semantic colours.

Known mismatch: inventory illustrations have richer bevels than the simplified world characters. This is acceptable at current scale but is not a claim of identical rendering style. Before a commercial asset pass, compare hero/enemy sprites alongside the item master sheet at actual play scale. New generation must be visually reviewed for silhouette, alpha edge, scale readability, lighting and theme; a good prompt alone is not acceptance.
