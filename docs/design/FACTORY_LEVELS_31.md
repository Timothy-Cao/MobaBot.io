# Factory level layouts — 12 September 2026

Owner requested three subtly thematic but spatially distinct levels, with fresh movement decisions instead of only palette/stat changes. Implemented as new-run factory31 rules; older checkpoints and Practice retain previous geometry.

## Reference findings

Vampire Survivors stage discussions identify the Library/Tower corridor layouts as materially different movement spaces (community evidence, not developer intent): https://www.reddit.com/r/VampireSurvivors/comments/1u3fbjf/forgettable_stages/ . Poncle also organizes Adventures as themed chapter sequences: https://poncle.games/adventures-faq . Riot explicitly encourages exploring Swarm maps for advantages: https://www.leagueoflegends.com/en-ph/news/game-updates/anima-squad-2024-everything-you-need-to-know/ . The Mobalytics map guide describes central healing, a battery-fed cannon and alternating freeze locations: https://mobalytics.gg/lol/guides/swarm-map-guide . Those examples inform the principle of different positioning decisions; this implementation does not copy those mechanics or assets.

## Implemented identities

| Level | Factory layout | Spatial quirk / intended decision |
|---|---|---|
| 1 — Loading yard | Twelve separated loading/press islands, marked bays, broad central apron | Long kiting sweeps with optional turns around loading islands; generous escape routes |
| 2 — Assembly hall | Fourteen conveyor/press islands arranged into interrupted parallel lines, directional floor marks | Travel along production lanes, then cut through crossovers or use existing Flash over machinery to change lanes |
| 3 — Cooling plant | Twelve cooling banks/press islands, central court with four corner exits, outer circulation route and pipe/ring markings | Hold the spacious center or leave through a corner and circle outside; use the banks to separate approaching groups |

Each round retains its level identity with reflected/staggered placement or slight rotation. Fixed geometry is independent of player position, camera and RNG. All rounds start in a clear central arrival area. No sealed rooms, compulsory narrow doorways, new hazards, conveyor forces or damage/stat changes. Decorative floor paint is walkable. Existing terrain rules still apply: bodies block, projectiles pass through, E rebounds and Flash crosses terrain.

Level numbers remain primary; names and short route hints appear beneath them in the selector. Terrain appears on the minimap for route planning. Native factory assets from the preceding pass are reused. Current maps use fewer obstacles than the prior approximately 35-island grid, but this is not proof of overall rendering performance.

## Compatibility and verification

The controller enables factory31 only for new current campaigns. The checkpoint loadout carries the flag; validation rejects malformed types and requires demo27. Resume rebuilds deterministic geometry. Vanguard reset removes the flag. Practice and old checkpoints are unchanged. Behavior probe now exercises these current maps by default on current Levels.

All 42 check.ps1 suites passed, including 151 factory checks: clear arrival, bounds, deterministic generation without loot RNG changes, connected 80-unit sampled walkable grid with 40-unit clearance across all nine layouts, distinct levels, save/resume, malformed flag and Practice isolation. A malformed string initially raised a type-comparison engine error; explicit type validation fixed it before final verification. Final render and Vanguard checks also pass after minimap/reset additions. Both historical refined behavior probes complete without logged engine errors.

Artificial-health full-level probes: Level 1 won at 1075.2s, level21, 1634 kills, peak28; Level 2 at 1092.2s, level23, 2488 kills, peak99; Level 3 at 1196.8s, level21, 2774 kills, peak175. These establish route completion, not human difficulty/fun. Layout changes affect enemy approach and collection, so results are not expected to match previous geometry. Level 3's crowd peak remains a performance/pressure review concern.

Rendered all three starting areas and selector; ignored output/factory-level-*.png and factory-selector.png. The capture fixture does not persist rewards or settings. Native floor accents retain the same information in reduced effects; no new decorative motion. No player game restarted, no released download replaced.

Next human review: whether Assembly crossovers create useful decisions without frustrating blockage; whether Cooling's inner/outer routes are readable under crowd pressure; whether Loading stays welcoming. Optional interactive factory machinery can follow after validating these routes; none is represented as implemented here.
