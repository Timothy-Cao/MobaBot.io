# MobaBot.io development

Read README.md and docs/design/QA_09.md for the current controls, scope and handoff. Older iteration documents are historical.

- Keep the demo focused on Stage 1, Levels 1–3. No expanded campaign or multiplayer without user direction.
- Preserve the player's equipment/settings files and user-provided music. Never award permanent loot from automated tests or fixtures.
- Keep simulation independent of presentation. Detached camera position must not relocate spawns. Rendered ability ranges must match their actual collision geometry.
- Follow docs/design/ART_STYLE_SCHEMA.md. New bitmap assets require provenance, alpha validation and actual-size visual inspection.
- The user requested ongoing commits for changes. Commit coherent verified implementation milestones, not every keystroke. Run relevant tests before committing. Push at an authorized handoff; never force-push or rewrite shared history.
- Do not commit .tools, .godot, tmp, output, private player records or secrets. Keep source, assets, user music and reproducible tests in Git.
- Run scripts/check.ps1 for final regression. Use the optional v0.9 behavior probe to compare movement and stationary play. Human feel is not established by a passing bot.
