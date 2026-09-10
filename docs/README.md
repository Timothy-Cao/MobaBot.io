# MobaBot.io documentation

The current playable version is **0.18 Vanguard**, with two-minute survival rounds. Root SESSION_HANDOFF.md routes current work; QA_18 and its latest pressure/audio addenda supersede the 0.17 shared-pool build. Older iteration documents are history/regression context, not instructions to implement every proposal.

## Start here

- [Project README](../README.md) — setup, controls, game scope, progression, saves and verification commands.
- [Current session handoff](../SESSION_HANDOFF.md) — first read: actual build, next action, verification and risks.
- [Gameplay vision](design/GAMEPLAY_VISION_18.md) — current owner north star for full-kit decisions, contextual power, progression, variance and Vanguard module reconsideration.
- [Playtest protocol](design/PLAYTEST_PROTOCOL.md) — frozen-build testing, read-only logs, targeted questions and reusable review notes.
- [0.18 QA](design/QA_18.md) and [pressure/audio audit](design/PRESSURE_AUDIO_18.md) — current implementation evidence and limits.
- [0.17 QA](design/QA_17.md) and [archived brief](design/NEXT_SESSION_BRIEF_17.md) — compatibility behavior and earlier planning context.
- [Quality bar](design/QUALITY_BAR.md) — editable acceptance contract, dated owner feedback and human-review gates.
- [Ability review](review/abilities.html) — interactive catalog for the 49 current ability icons.

The shortest safe instruction for another session is: **“Read SESSION_HANDOFF.md and follow the playtest protocol. Inspect Git status; don't change the build while I test.”**

## Focused proposals and historical direction (not automatic next tasks)

- [Practice sandbox redesign research](design/PRACTICE_SANDBOX_RESEARCH_17.md) — owner-requested cleanup direction informed by League Practice Tool, BTD6 Sandbox and Warframe Simulacrum: a persistent left dock, complete build/stat controls, mouse enemy placement, a small substantial-rock greybox, measurement and strict save isolation.
- [Vanguard and ability direction](design/ABILITY_FEEDBACK_17.md) — locked Vanguard slots, non-modal fixed-kit progression, permanent gun, hammer, D/F, body-slam E, rank milestones and current 1–4 module rules. Earlier alternatives are retained and labeled.
- [Marshal focused kit](design/RELAY_MARSHAL_DESIGN_17.md) — current owner-revised design for X/3X shared targeting, commanded relay shots, missiles, EMPs, pair pulses, three robot bodies, reposition/transfer and Overclock sacrifices.
- [Racer experimental kit brief](design/RACER_EXPERIMENT_17.md) — movement-first two-speed route fighter proposal, mouse-steering requirements, coherent core interactions, anti-degenerate rules, presentation direction and explicit prototype stop gates.
- [Robot AI and offline salvage](design/ROBOT_AI_MODE_17.md) — selected visible 75%-strength/simple-pilot model and slow offline accrual capped at 48 hours/about three last-cleared-level runs, with transactional and economy guardrails.
- [Terminology and class presentation](design/TERMINOLOGY_PRESENTATION_17.md) — consistent player-facing language, release/prototype/legacy states and starting visual/audio identities for Vanguard, Marshal and experimental Racer.
- [Environment and terrain direction](design/ENVIRONMENT_FEEDBACK_17.md) — substantial thick forms, clustered pockets, broad corridors and simple multi-entrance greybox questions.

## Detailed record and research background

- [Design gaps research](design/DESIGN_GAPS_RESEARCH_17.md) — **current cross-game study of the six underexplored areas:** encounter grammar/pacing, progression and offline economy, onboarding, accessibility/camera, art-animation production and a repeatable playtest method. Includes prototype order, measurements and stop gates; it is not implemented behavior.
- [Owner implementation and playtest record](design/OWNER_PLAYTEST_REQUEST_17.md) — detailed consolidated owner directions and test scripts. Use the next-session brief for order and this file when implementation needs the fuller wording.
- [Ability taxonomy and roster research](design/ABILITY_TAXONOMY_RESEARCH_17.md) — multi-axis taxonomy and audit of abilities 12–49. Its initial 1–4 recommendation is superseded by Vanguard's locked modules but remains useful for old alternatives.
- [Swarm design research](design/SWARM_DESIGN_RESEARCH_17.md) — source-backed transferable principles and explicit non-copying boundaries.
- [Static-kit brainstorm history](design/KIT_DESIGN_BRAINSTORM_17.md) — retained first Marshal sketch, parked Circuit Weaver concept and superseded Racer sketches. Focused class files win where they differ.

## Current supporting specifications

- [Balance study](design/BALANCE_16.md) — damage model, latest tuning addenda and measurement limits; current QA_18/pressure notes override older baselines.
- [Expedition design research](design/EXPEDITION_RESEARCH_14.md) — systems intent, progression boundaries and source-backed design reasoning.
- [Art style schema](design/ART_STYLE_SCHEMA.md) — current visual language, gameplay-readability requirements and asset acceptance rules.
- [Godot workflow](GODOT_WORKFLOW.md) — project-development and engine workflow.
- [Painted-icon provenance](../assets/painted/PROVENANCE.md) and [layered-menu provenance](../assets/menu/LAYERS_PROVENANCE.md) — current generated-bitmap sources and review records.

## Recent implementation records

- [0.16 keyboard, forge and painted icons](design/QA_16.md)
- [0.15 skill presentation and quality baseline](design/QA_15.md)
- [0.14 expedition implementation](design/QA_14.md)

These documents explain how systems arrived; the [current handoff](../SESSION_HANDOFF.md), latest QA_18 sections, root README and AGENTS.md establish today's scope.

## Historical material

`QA_08.md` through `QA_13.md`, the numbered iteration notes, `IMPLEMENTATION_STATUS.md`, `MVP_TASK_BOARD.md` and the early design/research documents are retained for provenance and regression context. Their version-specific menus, classes, pacing and feature status should not be presented as current behavior.

## Verification dependencies

- Windows game checks: run `scripts/setup.ps1`, then `scripts/check.ps1`. The setup script downloads the pinned Godot 4.7.2 console executable and verifies its checksum.
- Ability-catalog browser check: run `npm install`, then `npm run check:catalog`. The current check launches Microsoft Edge through Playwright and writes its ignored capture to `output/`.
- Research PDF scripts: create a virtual environment, install `requirements-dev.txt`, then run `docs/research/build_report.py` or `docs/research/verify_report.py` as needed. PDF generation currently expects the Windows Arial font files named in the build script.

Local dependency directories and generated output remain ignored; do not commit `.tools`, `.godot`, `node_modules`, `.venv`, `tmp` or `output`.
