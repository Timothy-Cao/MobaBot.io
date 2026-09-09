# MobaBot.io development

Read README.md, docs/design/QA_12.md and docs/design/SYSTEMS_REFINEMENT_12.md for current controls, scope and handoff. Older iteration documents are historical.

- The creator authorized an eight-stage roguelite direction. The playable slice remains Stage 1, Levels 1–3 until the planned chest/stat/campaign milestones are implemented and tested; do not describe planned content as shipped. Multiplayer is not in scope.
- Preserve the player's equipment/settings files and user-provided music. Never award permanent loot from automated tests or fixtures.
- Keep simulation independent of presentation. Detached camera position must not relocate spawns. Rendered ability ranges must match their actual collision geometry.
- Follow docs/design/ART_STYLE_SCHEMA.md. New bitmap assets require provenance, alpha validation and actual-size visual inspection.
- The user requested ongoing commits for changes. Commit coherent verified implementation milestones, not every keystroke. Run relevant tests before committing. Push at an authorized handoff; never force-push or rewrite shared history.
- Do not commit .tools, .godot, tmp, output, private player records or secrets. Keep source, assets, user music and reproducible tests in Git.
- Run scripts/check.ps1 for final regression. Use both behavior probes with -- --refined to compare passive-only, naive casting and adaptive play in current combat. Human feel is not established by a passing bot. Mastery is run-only; main-menu previews cannot spend points.
- Autonomous gun is independent of commands: S stops walking and commanded basic attacks, never the auto toggle. Preserve separate cooldown clocks. Poison trail has energy upkeep only while on and never self-damages.
