# MobaBot.io development

Read README.md, docs/design/QA_14.md and docs/design/EXPEDITION_RESEARCH_14.md for current controls, scope and handoff. Older iteration documents are historical.

- The normal entry point is expedition.tscn: eight stages, 22 rounds, three classes, chest discovery, 48-node run mastery, 40 persistent equipment items and A0–A5. workshop.tscn is a legacy three-round regression fixture. Eight boss configurations reuse one body and three world sectors; do not describe these as eight new maps or unique boss assets. Multiplayer is not in scope.
- Preserve the player's equipment/settings files and user-provided music. Never award permanent loot from automated tests or fixtures.
- ExpeditionGear owns the separate mobabot_expedition.json profile/checkpoint. Legacy mobabot_equipment.json is read-only migration input. Validate before writing, roll back failed transactions and preserve corrupt saves. Continue resumes a cleared-round checkpoint, not an exact combat frame. Equipment/credits/ascension persist; mastery and abilities reset for a new run.
- Keep simulation independent of presentation. Detached camera position must not relocate spawns. Rendered ability ranges must match their actual collision geometry.
- Follow docs/design/ART_STYLE_SCHEMA.md. New bitmap assets require provenance, alpha validation and actual-size visual inspection.
- The user requested ongoing commits for changes. Commit coherent verified implementation milestones, not every keystroke. Run relevant tests before committing. Push at an authorized handoff; never force-push or rewrite shared history.
- Do not commit .tools, .godot, tmp, output, private player records or secrets. Keep source, assets, user music and reproducible tests in Git.
- Run scripts/check.ps1 for final regression. Use both behavior probes with -- --refined to compare passive-only, naive casting and adaptive play in current combat. Human feel is not established by a passing bot. Mastery is run-only; main-menu previews cannot spend points.
- Also run expedition_behavior_probe.gd for current classes. Its --soak mode uses artificial health to validate full-route completion/performance, never human balance. check.ps1 includes expedition mechanics and all new upgrade/milestone UI checks and treats logged engine errors as failures even when Godot exits 0.
- Autonomous gun is independent of commands: S stops walking and commanded basic attacks, never the auto toggle. Preserve separate cooldown clocks. Poison trail has energy upkeep only while on and never self-damages.
- UI is intentionally pruned: Home has five actions; Build has Overview/Mastery; Loadout has Abilities/Passives; Settings has Options/Controls. Do not restore legacy inspection pages, repeated tutorials or extra dashboards without a concrete user need. Keep details on demand and transaction failures visible.
