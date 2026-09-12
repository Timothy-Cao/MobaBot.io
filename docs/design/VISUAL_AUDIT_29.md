# Visual audit and field pickups — 12 September 2026

Owner requested plain “Levels” wording, occasional quarter-health drops, independent roughly minute-spaced magnets, then an audit of graphics, art and design. This audit uses fresh local rendered captures, current source and the existing ART_STYLE_SCHEMA. It is a visual/design assessment, not player research or an approved broad art implementation.

## Implemented in this milestone

The current selector already says “Levels”; the legacy result label “Demo complete” now says “Run complete.” Future player-facing wording should use Levels. Internal demo identifiers remain to preserve saved rules and diagnostics.

Current campaign kills start two independently randomized 45–75 second deadlines, one for health and one for magnets. Each reward drops from the next enemy killed after its deadline, then rolls a new interval. Mean interval is 60 seconds with frequent kills; pauses do not advance gameplay time, and low kill frequency delays rewards. The schedules can occasionally coincide by chance, but do not share a timer. They use their own seeded RNG, leaving the established loot RNG sequence untouched. New runs and resumed runs initialize the deadlines afresh; no catch-up burst. Stage transitions keep the timers through the same run. Practice kills do not generate these rewards.

Health packs restore 25% of maximum HP, capped at full health. Magnets immediately claim existing ground XP, supply drops (including credits/health/energy) and dropped loot chests across the map. They do not open terrain objects or buy shop items. Collected magnets are marked spent before processing, preventing recursive sweeps and duplicate rewards. Snapshot processing leaves any new loot produced by collection-triggered effects for later. New supply kinds cap at twenty live drops each rather than merging into stronger health packs. All rewards remain within normal gameplay; tests do not save rewards.

New icons are native green medical cases and red/cream horseshoe magnets with the existing ink outline and readable small shapes. They reuse repair/boost sounds and concise collection feedback.

## Evidence inspected

Fresh 1600×900 captures: `output/menu-foundry.png`, `output/levels22/Levels.png`, `Mastery.png`, `Equipment.png`, `Round-clear.png`, and `output/field-pickups.png`. Current miniboss normal/reduced previews were also inspected in the preceding milestone. The round-clear fixture has no unclaimed loot, so its empty receipt cannot establish how a full reward grid feels. Static captures establish layout/shape/color issues, not animation quality or rendered performance during a full fight.

## Ranked improvements

| Priority | Current evidence | Proposed improvement | First reviewable slice |
|---|---|---|---|
| 1 — Terrain identity and depth | Combat has a broad flat grid; capsule obstacles read mostly as outlined floor shapes. Home promises a richer factory. | Recognizable top-down machinery: conveyor beds, cooling tanks, presses, cable trenches, loading pallets. Add restrained contact shadows, top/side plane separation and sparse amber practical-light patches. | Replace the appearance of two existing obstacle shapes while preserving exact collision, plus three floor decals. Compare in the same arena. |
| 2 — Enemy silhouette and state animation | New minibosses share a rectangular faceplate and treads; distinctive rings currently do much of the identification. | Drift rammer gets a low wedge nose and long wheelbase; Bulwark gets broad armored shoulders and a visible central rotor. Use recoil, charge lean, recovery venting and an opening shield assembly to communicate state. | One rammer and one Bulwark with idle, windup, attack and recovery poses. Keep tell geometry and movement timing unchanged. |
| 3 — Coherent menu system | Home has a strong brass/steel foundry identity. Secondary screens are large flat panels with repetitive rectangles. | Apply the same material edges, recessed sections and action hierarchy to camp/mastery/equipment. Strong active tab, clear next action, smaller supporting controls. Keep keyboard focus and readable real text. | One camp frame with tabs and shared buttons, reused by all four tabs. |
| 4 — Mastery hierarchy | Three branches are understandable, but thirteen similar wide boxes and dim labels compete. Badges are small relative to their panels. | Smaller connected nodes, clearer purchased/current/future path states, brighter locked-node labels, larger effect badges and a distinct capstone silhouette. Preserve the user's reusable base-emblem + badge approach and hover access. | Restyle one branch using the current three emblems; no need to generate thirteen new paintings. |
| 5 — Equipment readability and style | Gear paintings are crisp and dimensional while skill/mastery images are heavily pixelated. Empty inventory icons are very dark; tier quantity markers are tiny. | Apply the established pixelation/palette treatment consistently in a reversible preview. Separate ownership, equipped state and tier. Show the selected piece as a bench inspection with a concise comparison. | One helmet family at all five tiers; inspect at actual inventory size before rolling out. |
| 6 — Reward presentation | The current camp frame has space for a stronger visual hierarchy; the empty fixture puts a lone chest above a wide module row. | A compact “recovered cargo” tray, grouped rewards and a distinct shop shelf. Keep the existing multi-column receipt and always-visible next action. | Review a populated 20-chest fixture and an empty receipt side by side. |
| 7 — Combat impact and pickups | The player and new pickups are readable but small; much combat identity is carried by lines/rings and HUD icons. | Short hammer impact arc, rocket exhaust, small repair motes and a brief inward magnet sweep. Ground loot gets consistent shadows and icons. Preserve danger tells above decorative effects. | Polish one hammer hit and one magnet collection at normal/reduced settings. |
| Quick correction — build label | Home still displays the historical “0.18” footer. | Source the label from the actual build/release metadata so tester screenshots identify the build accurately. | Verify local and exported builds show the correct respective labels. |

## Reusable art production plan

Start with a small factory kit: eight prop concepts, six floor/edge decals, one shared shadow/material treatment and two miniboss silhouette sheets. The props should share top-down camera angle, light direction, steel/brass/cream palette and low-detail floor-facing surfaces. Generate clean source masters only where illustrated props or concepts help; keep masters, provenance and alpha validation, then use the established shared pixelation process. Review 32/64-pixel samples at real combat zoom before expanding the pack.

Keep UI text, borders, status badges, health bars and collision-linked tells native. Existing skill/mastery masters and equipment source art should remain intact; introduce reversible display variants. The current cartoony game stays the reference. The previously discussed high-fidelity presentation remains a separate future experiment.

## Acceptance checks for the next art pass

- Obstacles read as solid from combat zoom, with visible walkable gaps; decorative overhangs do not suggest false collision.
- Players can distinguish rammer and brawler from silhouette, and identify the brawler's safe center and exposed recovery without relying only on color.
- UI separates primary action, selected tab, owned/equipped/locked state and descriptive text without adding more scrolling.
- Normal/reduced effects preserve the same actionable information. Decorative lights/particles stay behind hostile tells.
- Compare the same 180-enemy scene before/after. Prefer baked shadows and bounded reusable effects; no assumption that a static art preview proves frame-rate quality.

Recommended next milestone: terrain materials/props and the two miniboss silhouettes, followed by the shared camp/menu frame. Keep gameplay fixed while reviewing those visual changes. No new human fun/quality score is assigned by this audit.
