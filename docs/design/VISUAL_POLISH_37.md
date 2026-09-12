# Factory and camp polish review

12 September 2026. Owner authorized critique and iteration against a polished survivors game in the existing cartoony foundry style. Entry commit: `5d77581`; clean checkout. Presentation milestone only, no new gameplay rule family or release version.

## Critique and implemented passes

| Weakness in the reviewed build | Refinement | Assessment from renders |
| --- | --- | --- |
| The same dense grid, large numbers and vents repeat across all three worlds. The floor attracts attention without making the factories convincing. | Replace current factory floors with quiet concrete slabs/tyre scuffs, riveted assembly decking/service grilles, and recessed cooling hatches/conduits. Deterministic sparse wear; smaller, less frequent stencils. | Less competition with small enemies and laser warnings. Each material family now has a distinct motif. These remain native geometry, not painted environments. |
| Helpful machinery looks like a wire diagram or an unexplained circle. | Magnetic crane trolley and rail bed, segmented press workbed, recessed turbine grille. Orthogonal inset power cables and a treaded activation pedal. Preserve ready, arming, active and cooldown rings. | More recognizable mechanical function. Warning boundaries remain exact: 40-unit pedal, 210-unit press, 300-unit cooling field. Walkable parts are flush; raised capsule obstacles are unchanged. Human discovery of these devices still needs testing. |
| The camp has a large empty field and four shallow module buttons, with weak purchase/rank hierarchy. | Larger module cards with framed hotkeys, icon, ten rank slots, current rank, and a separate price footer. Gray unaffordable/maxed controls including child content. Compact three-column receipt uses the actual available width. | All four purchases remain on one row. Six receipt entries fit in two rows without scrolling. Existing long historical receipts retain scrolling. Next round stays visible across tabs. |
| Bonus upgrade cards do not line up with ability cards; XP uses a medical cross. | Align titles, icons, levels and rank tracks. Give XP a native gold progression-chip icon. Fix singular point/copy labels. | Clearer comparison and less healing/XP ambiguity. Existing Q badge, ten-slot milestones and compact paused-world overlay retained. |

Pass one established floor materials, functional machinery and the shop proportions. Pass two checked actual rendered scenes, then framed module hotkeys, improved disabled child contrast, aligned upgrade rows, replaced the XP cross and fitted six receipt entries. No explanatory paragraphs were added to the game.

## Verification

- `scripts/check.ps1`: all 44 suites passed. Final icon follow-up also ran `skill_visual_test.gd`; final receipt/icon geometry was inspected with the render fixture after adjustment.
- `tests/design_polish_capture.gd`: 24 basic enemies plus an actual aiming lancer over each map, four machine states, active machinery in reduced effects, affordable/unaffordable shops, six rewards, mastery and mixed upgrade cards. Asserts rendering leaves walls, enemies, machinery and loot RNG unchanged, and module affordability remains correct. Uses in-memory collection, disables persistence and simulation ticking. Screenshots are ignored `output/polish37-*.png` at 1600×900.
- `tests/discovery35_test.gd -- --render`: 117 checks passed, including machinery effects/clear paths. `foundry_controls_capture.gd` interactions passed. Final normal/reduced cards inspected.
- Both historical behavior probes with `-- --refined` and the current `expedition_behavior_probe.gd -- --vanguard --discovery` completed without engine errors. No balance conclusions follow from those bots. No gameplay parameters or collision geometry were edited.
- Native geometry and one native icon; existing generated source masters, manifests and pixelation retained. No third-party asset dependency. No player game restarted or automated permanent rewards.

## Remaining critique

1. Actor finish is now the largest cohesion gap: ability portraits have rich material work while common enemies and the robot have simple bodies and limited pose changes. The next art pass should focus on attack anticipation, recoil and recovery silhouettes at actual combat size, while keeping the familiar cartoon identity.
2. Level identity still needs occasional authored landmarks beyond repeated industrial modules. Add visual landmarks within existing collision footprints before increasing floor detail or adding more systems. Preserve a quiet, walkable combat field.
3. Mastery still reads as three button lists. Distinct endpoint shapes and stronger owned/available/locked hierarchy would do more than generating another batch of near-identical icons. Its point economy and tree structure are outside this visual pass.

These are review judgments, not new owner ratings or evidence of human approval. Current visual checks do not establish dense-crowd frame rate or whether the machinery is understood without instruction. This source milestone does not update the existing Windows ZIP.
