# MobaBot.io documentation

The current playable version is **0.17 Field Test**. `QA_17.md` supersedes earlier class, pacing, skill-replacement and hold-Tab rules. Older iteration documents remain useful as implementation history and regression context, but are not the current game contract unless a current document carries a decision forward.

## Start here

- [Project README](../README.md) — setup, controls, game scope, progression, saves and verification commands.
- [0.17 QA and handoff](design/QA_17.md) — authoritative current behavior, measurements, verification evidence and open limits.
- [Quality bar](design/QUALITY_BAR.md) — editable acceptance contract, dated owner feedback and human-review gates.
- [Ability review](review/abilities.html) — interactive catalog for the 49 current ability icons.

## Active owner direction

- [Owner implementation and playtest request](design/OWNER_PLAYTEST_REQUEST_17.md) — consolidated pull-and-work handoff covering the proposed default kit, progression, D/F/E behavior, modules, terrain, a future Robot AI/low-input-farming research request, implementation order and focused owner tests. Owner direction and assistant Swarm findings are labeled separately.
- [Ability direction and owner feedback](design/ABILITY_FEEDBACK_17.md) — current owner notes for fixed slots, non-modal progression, a permanent autonomous gun, default D/F mechanics, the leading body-slam E proposal, and the proposed 1–4 row of orbiting tools plus three summon concepts. These are future design inputs, not current implemented behavior.
- [Ability taxonomy and roster research](design/ABILITY_TAXONOMY_RESEARCH_17.md) — source-backed multi-axis taxonomy, Q/W/E/R/D/F/module slot proposal, design-purpose audit of abilities 12–49, recommended default summon and four powered toggles, and a focused Practice test plan. Recommendations are hypotheses, not implemented behavior or proven fun.
- [Environment and terrain owner feedback](design/ENVIRONMENT_FEEDBACK_17.md) — direction away from thin basic walls toward substantial thick forms, clustered pockets, corridors and simple multi-entrance macro-shapes, with reference and greybox questions for a later terrain pass.
- [Swarm design research](design/SWARM_DESIGN_RESEARCH_17.md) — source-backed analysis of Swarm's baseline offense, map destinations, evolutions, optional objectives, wave authoring, progression and technical constraints, translated into non-copying MobaBot hypotheses.
- [Static-kit design brainstorm](design/KIT_DESIGN_BRAINSTORM_17.md) — records the locked default-kit composition and clearly labeled assistant proposals for summon-network, geometric-combo and intermittent-speed kits. Only the default is owner-locked; the other kits remain concepts to prototype and review.
- [Marshal focused kit research](design/RELAY_MARSHAL_DESIGN_17.md) — current owner-revised, source-backed design for the summon character: X/3X shared targeting, separate commanded relay shots, maximum-range missiles, relay EMPs and pair pulses, three compatible robot bodies, reposition/control-transfer inputs and Overclock sacrifices. The combo-kit concept is parked; Vanguard is only a proposed default-kit name.

## Current supporting specifications

- [Balance study](design/BALANCE_16.md) — damage model and measurement limits carried into the current pass where `QA_17.md` does not override them.
- [Expedition design research](design/EXPEDITION_RESEARCH_14.md) — systems intent, progression boundaries and source-backed design reasoning.
- [Art style schema](design/ART_STYLE_SCHEMA.md) — current visual language, gameplay-readability requirements and asset acceptance rules.
- [Godot workflow](GODOT_WORKFLOW.md) — project-development and engine workflow.
- [Painted-icon provenance](../assets/painted/PROVENANCE.md) and [layered-menu provenance](../assets/menu/LAYERS_PROVENANCE.md) — current generated-bitmap sources and review records.

## Recent implementation records

- [0.16 keyboard, forge and painted icons](design/QA_16.md)
- [0.15 skill presentation and quality baseline](design/QA_15.md)
- [0.14 expedition implementation](design/QA_14.md)

These documents explain how current systems arrived, but `QA_17.md`, the root README and [`AGENTS.md`](../AGENTS.md) win if descriptions conflict.

## Historical material

`QA_08.md` through `QA_13.md`, the numbered iteration notes, `IMPLEMENTATION_STATUS.md`, `MVP_TASK_BOARD.md` and the early design/research documents are retained for provenance and regression context. Their version-specific menus, classes, pacing and feature status should not be presented as current behavior.

## Verification dependencies

- Windows game checks: run `scripts/setup.ps1`, then `scripts/check.ps1`. The setup script downloads the pinned Godot 4.7.2 console executable and verifies its checksum.
- Ability-catalog browser check: run `npm install`, then `npm run check:catalog`. The current check launches Microsoft Edge through Playwright and writes its ignored capture to `output/`.
- Research PDF scripts: create a virtual environment, install `requirements-dev.txt`, then run `docs/research/build_report.py` or `docs/research/verify_report.py` as needed. PDF generation currently expects the Windows Arial font files named in the build script.

Local dependency directories and generated output remain ignored; do not commit `.tools`, `.godot`, `node_modules`, `.venv`, `tmp` or `output`.
