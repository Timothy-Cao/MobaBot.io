# Interface and exploration pass — 0.2

## Research and decisions

The old screen repeated slogans, used vague promises and spent space explaining itself. Those are concrete copy problems; no individual wording pattern reliably proves AI authorship. Wikipedia's community-maintained AI-writing guide documents promotional language, formulaic contrasts and repeated three-part phrasing, but includes detection caveats. We use it as an editing checklist, not a detector. [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing).

NN/g's study supports concise, scannable, objective copy and documents dislike of promotional fluff. It studied websites, not game enjoyment; the transfer to game UI is our design judgment. [Morkes and Nielsen, Concise, Scannable, and Objective](https://www.nngroup.com/articles/concise-scannable-and-objective-how-to-write-for-the-web/).

Brotato's level-up interface combines recognizable item illustrations with explicit numerical effects and a stats panel. Borrow that hierarchy, not its assets or exact layout. [Brotato level-up screenshot and review](https://tryhardguides.com/brotato-review/); [developer's official Steam listing](https://store.steampowered.com/app/1942280/Brotato/).

Halls of Torment separates character values from traits/abilities and exposes base/current values. Borrow inspectability and grouping. [Official PlayStation listing and character-screen imagery](https://store.playstation.com/en-ca/product/EP1592-PPSA32065_00-0704306198430471); [developer's Steam listing](https://store.steampowered.com/app/2218750/Halls_of_Torment/).

These references support UI patterns, not a claim that icons produce a measured dopamine response or that commercial success is caused by a specific menu. The player's requested direction is more visually rewarding choices with less reading; it still needs playtesting.

## Copy rules for future changes

- Main-menu actions use normal verbs/nouns: Play, Upgrades, Settings, Quit.
- No stacked taglines, vague transformation promises or three-fragment slogans in functional UI.
- Use short item names. Show actual changes, including units and rank limits.
- Keep implementation claims, procedural-art credits and experiment explanations in documentation/credits, not the first screen.
- Flavor is allowed when it adds character; it should not compete with an action or a number.
- Do not replace readable labels with mysterious icons. Illustration attracts attention; concise text explains the choice.

## Delivered scope

- Seven generated illustrations with transparent corners, preserved originals, mipmapped UI import and local project copies. The image-generation skill's built-in path was used; the reference-image batch failed, while independent generation succeeded. No CLI/API-key fallback. Prompts and paths: `assets/upgrades/PROVENANCE.md`.
- Illustrated three-choice cards: weapon identity, rank pips, description, exact before/after values and a build-inspection button. Restrained hover scaling respects reduced-effects settings.
- Read-only upgrade graph: three weapon lanes with three sequential ranks each, plus four support upgrades. These are combinable paths, not exclusive branches. All seven types existed before this visual pass; a separate permanent skill tree has not been added.
- Stats page: base/current numbers, sources and damage contribution bars. No fictional critical chance, armor, speed upgrade or spendable stat points.
- World expanded from 888x400 to 5360x3400 (about 51 times its previous area). A following camera preserves character size; floor landmarks, eight one-time caches and a minimap support orientation and movement. Ordinary enemies spawn around the current camera, distant ordinary enemies retire without rewards, and earned scrap is retained.
- Tab opens/closes the build inspector. It pauses play and restores the precise previous screen, including pending level-up choices. Main-menu Upgrades uses an empty build instead of treating the decorative preview as owned equipment.

## Limits and next tuning

The large floor is an exploration test, not finished level design. It needs more distinctive destinations if traversal becomes repetitive. Walking away is easier than in the old enclosure, so encounter pressure and collection pacing need further player feedback. No permanent progression, skill points, procedural dungeon rooms, new weapon families or guaranteed behavioral evolution at max rank is implied by the graph.

The player/enemies remain simpler than the new item illustrations. The image set solves this card-art scope, not every future animation or art-consistency requirement. Inspect future art at gameplay size before increasing detail.
