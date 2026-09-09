# MobaBot.io documentation

The current playable version is **0.17 Field Test**. `QA_17.md` supersedes earlier class, pacing, skill-replacement and hold-Tab rules. Older iteration documents remain useful as implementation history and regression context, but are not the current game contract unless a current document carries a decision forward.

## Start here

- [Project README](../README.md) — setup, controls, game scope, progression, saves and verification commands.
- [0.17 QA and handoff](design/QA_17.md) — authoritative current behavior, measurements, verification evidence and open limits.
- [Quality bar](design/QUALITY_BAR.md) — editable acceptance contract, dated owner feedback and human-review gates.
- [Ability review](review/abilities.html) — interactive catalog for the 49 current ability icons.

## Active owner direction

- [Ability direction and owner feedback](design/ABILITY_FEEDBACK_17.md) — description-based notes for abilities 1–11, a functional-taxonomy research request, proposed fixed slot identities, a focused test roster and a learned-ability loadout direction. These are future design inputs, not current implemented behavior.

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
