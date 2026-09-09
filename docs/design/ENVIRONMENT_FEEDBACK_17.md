# Environment and terrain owner feedback · 9 September 2026

Status: **owner direction for future research, design and playtesting; not implemented behavior.** `QA_17.md` continues to describe the current terrain until a later implementation is reviewed and verified.

## Current concern

The owner does not like the present terrain. The obstacles read as basic walls without enough substance, thickness or environmental presence. A map made from thin wall segments is not the desired long-term look, even if collision and routing work correctly.

## Desired direction

Keep the first redesign structurally simple, but make each obstacle or obstacle group feel like a substantial place rather than a line drawn across the floor.

Possible forms to explore:

- Thick, long masses that read as solid structures rather than rails.
- Somewhat natural blob-like silhouettes combined with partially rigid or industrial edges.
- Several nearby pieces clumped into a single recognizable terrain section.
- Short corridor spaces created between substantial masses.
- More enclosed-feeling local areas without necessarily creating sealed rooms.
- A simple large circular mass or enclosure with four clear entrances.
- A few strong macro-shapes repeated or varied carefully instead of many thin, arbitrary walls.

The owner has not selected one final shape language. “Natural blobs with rigid parts,” “long thick walls,” “corridors,” and “a large circle with four entrances” are exploration prompts, not requirements to combine every idea into every sector.

## Reference direction

Use the maps from League of Legends' PvE mode, especially Swarm, as one inspiration source. Also study other top-down shooter and survivor-style games for how they use thick terrain, corridors, clustered obstacles, open combat pockets and multiple entrances.

Extract principles rather than copying a map, layout, art asset or visual identity. Relevant questions include:

- How a large obstacle reads as having volume at the normal gameplay camera distance.
- How corridors and pockets change kiting, escape routes and enemy approach directions.
- How many entrances prevent a pocket from becoming a trap or an exploit.
- How macro-shapes help the player recognize location and navigate without a minimap.
- How terrain remains quieter than enemies, pickups and dangerous telegraphs.

The existing expedition research already identifies Riot's Swarm as a relevant survivor-mode precedent: [official Anima Squad and Swarm overview](https://www.leagueoflegends.com/en-us/news/game-updates/anima-squad-2024-everything-you-need-to-know/). That reference supports further study; it is not evidence that its exact layouts will work with MobaBot.io's mouse movement, collision sizes or enemy routing.

## Gameplay constraints for a future prototype

- “More closed off” should initially mean shaped pockets and corridors with several readable exits, not sealed rooms that trap the player or permanently disable enemies.
- Preserve a clear starting area and enough open space for the proposed hammer arc, aimed abilities, bosses and dense waves.
- Ordinary enemies must route around thick geometry without snagging. Large bosses need an explicit break, bypass or routing rule.
- Detached camera movement must not relocate spawns or simulation geometry.
- Wall and obstacle art must match actual collision thickness. Decorative mass cannot imply cover where none exists, and invisible collision cannot extend beyond the visible structure.
- Projectiles, dashes, deployables, ground targeting and ability previews need explicit behavior at corridor corners and entrances.
- Avoid narrow passages that become mandatory choke exploits or make body clearance unreliable.
- Preserve visual hierarchy: terrain supplies place and structure but stays below hostile tells, the player and pickups.

## Small first exploration

The first prototype does not need a complete environment-art replacement. A useful comparison would keep the same enemies and combat rules while testing three simple greybox arrangements:

1. Two or three long, thick terrain masses that create broad corridors.
2. Several clustered blob/rigid hybrid masses that create open pockets with multiple approaches.
3. One large circular structure or enclosure with four wide entrances and useful combat space both inside and outside.

Compare these with the current distributed thin-wall layout using the same player size, enemy groups and fixed test paths. Check path completion and collision first, then inspect whether the forms feel substantial at the actual gameplay camera scale. Human playtesting should answer whether the layouts create useful positioning decisions or merely add travel friction.

No current terrain should be deleted solely from this note. Preserve the existing version as a regression/reference layout until a replacement satisfies pathing, combat readability and owner review.
