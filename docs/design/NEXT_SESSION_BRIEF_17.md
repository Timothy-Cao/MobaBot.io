# Next Session Brief · 9 September 2026

Status: **start here for the latest owner direction.** This is the concise routing and priority document for the next development session. It does not claim that future designs are already implemented.

Suggested kickoff prompt:

> Pull `main`, read `docs/design/NEXT_SESSION_BRIEF_17.md`, and begin Phase 0. Work in small verified milestones and stop for owner playtesting at each gate.

## Read order and precedence

Use this order when documents appear to disagree:

1. **Safety/workflow:** [`AGENTS.md`](../../AGENTS.md).
2. **What exists now:** root [`README.md`](../../README.md) and [`QA_17.md`](QA_17.md).
3. **What the owner wants next:** this brief.
4. **Focused current specifications:** the task-specific documents routed below.
5. **Detailed owner record:** [`OWNER_PLAYTEST_REQUEST_17.md`](OWNER_PLAYTEST_REQUEST_17.md).
6. **Research and brainstorm history:** taxonomy, Swarm and the superseded sections of the kit brainstorm.
7. **Old implementation history:** `QA_08.md`–`QA_16.md`, iteration notes and old status/task-board files.

When current implementation and future direction differ, do not rewrite the current contract in advance. Implement and verify a milestone first, then update `README.md`/`QA_17.md` or create the next QA record.

## Current build versus future direction

| Topic | Current 0.17 implementation | Latest owner direction |
| --- | --- | --- |
| Character model | One shared skill pool; old class fields are compatibility-only | Fixed coherent classes/kits; Vanguard first, Marshal next, Racer experimental |
| Skill selection | Flexible Q/W/E/R/T/1–4 plus D/F movement pair; storage and camp refitting | No cross-class swapping for now; learn/rank only abilities belonging to the chosen fixed kit |
| Practice | Large setup overlay; one skill fit at a time; automatic spiral enemy spawn | Class-first left dock, focused stats, mouse placement and a small rock greybox; prototypes/legacy tools remain Practice-only |
| Vanguard combat | Existing shared-pool 0.17 actions | Locked static kit summarized below |
| Progression | Modal numerical XP choices and the current discovery/storage rules | Alternate non-modal learn and upgrade opportunities within the fixed kit; no ability popup |
| Terrain | Mostly open distributed rail-cover islands | Substantial thick forms, broad lanes/pockets and simple multi-entrance shapes; prototype before art |
| Automation | None | Later visible Robot AI plus separate slow offline salvage |

This distinction is essential: `QA_17.md` is truthful about the game today; this file is authoritative for the next prototype direction.

## Latest owner decisions

### Classes

- **Vanguard is locked** as the default static class. It uses individually strong mid-range actions and does the work itself.
- **Marshal** is the focused summon/network class. Its relays share target acquisition and coordinated fire; the player can reposition or transfer between robot bodies.
- **Racer** is approved for careful experimental exploration, not as a locked full kit. Prove fast mouse steering first.
- **Circuit Weaver/combo class is parked.** Preserve the notes; do not implement it now.
- Cross-class ability swapping is deferred. Old and unreleased abilities are preserved in Practice only until the owner explicitly releases them.

### Vanguard fixed kit

| Input | Tool | Latest rule |
| --- | --- | --- |
| Permanent system | Autonomous machine gun | Always owned, independently upgradeable and not unequipped |
| Left click | Hammer swing | Committed roughly 90° melee arc; head deals high damage/push/stun, handle is weak |
| Q | Impact bolt | Reliable bread-and-butter DPS |
| W | Core strike | Long-range burst/center payoff; charges at later ranks |
| E | Body slam/Piston thrust | Short collision dash; base touch protection, rank-5 stun, rank-10 full shield |
| R | Reactor drop | Highest-impact area event with rank-5 self benefit and rank-10 double/stun payoff |
| D | Ghost drive | Hold for speed; blocks basics/active abilities while permanent passives continue |
| F | Phase hop | True blink with buffered cast origin and predictable thick-wall correction |
| 1 | Orbiting tools | Close/fast versus far/slow positioning modes |
| 2 | Aggressive summon | Tanky, destructible, weak gun/local pulse and limited aggro draw |
| 3 | Healing totem | Stores value while away; overflow order hull → energy → small shock wave; moving resets storage |
| 4 | Cooldown/energy totem | About five seconds; benefits only inside aura; doubled recovery/unlimited energy; cooldown begins after expiry |

Detailed mechanics and open tuning: [`ABILITY_FEEDBACK_17.md`](ABILITY_FEEDBACK_17.md).

### Construct durability

- A construct that intentionally draws aggro is targetable, destructible and visibly tanky enough to matter.
- A construct that does not draw aggro is untargetable/indestructible and leaves through timeout, repositioning, transfer or explicit sacrifice.
- Which Marshal relay types draw aggro remains open; do not guess for the full roster before the one-relay prototype.

### Progression and controls

- Within a fixed kit, alternate opportunities to upgrade an owned ability and learn a locked rank-0 ability.
- Never mix learn and upgrade candidates in the same choice.
- Do not interrupt combat with an ability popup. Indicate eligible slots; support Ctrl + assigned key and a small clickable upgrade affordance.
- Replacements and cross-kit loadout changes remain deferred; between-phase class/loadout behavior must be redesigned explicitly before returning them.
- Keep damage source types separate: touch, projectile, poison/DoT and ground/enemy ability. Body slam's base protection affects touch only.
- `C` consumables are only a bookmark. Repair/energy potions, inventory, economy and exact C interaction are not part of the next milestone.

### Practice

- Primary selection is the **class**, which loads its fixed kit.
- Prototype, old and legacy tools remain available for testing only in a clearly labeled Practice area; they do not become released content.
- Use a collapsible left dock with Build, Player, Enemies and Session controls.
- Place enemies with a paused world preview and left click; Point, Line, Ring and Cluster are the first useful formations.
- Use one small deterministic test map with open center, a few large/medium substantial rocks, a long lane, broad choke and thick blink/pathing obstacle.
- Preserve byte-for-byte campaign/checkpoint isolation. Practice never grants loot.
- Mark measurement as modified when god mode, frozen AI, free energy, instant recharge, custom stats or non-1× time is active.

Detailed design and source research: [`PRACTICE_SANDBOX_RESEARCH_17.md`](PRACTICE_SANDBOX_RESEARCH_17.md).

### Marshal

- Relays acquire locally within X and may attack within their own roughly 3X range when the target is seen by another relay or the player's attack range.
- Player basics trigger a substantial separate-clock relay shot.
- Q launches long-range missiles from player and relays and explodes at maximum range.
- W produces a medium EMP pulse at each relay.
- E pulses damage along each active relay pair.
- Overclock greatly increases relay firing/missiles; transferring during it sacrifices the abandoned body in a large explosion and starts a 10-second redeploy wait.
- Slots 1–3 place distinct robot relay bodies. One press arms left-click repositioning; pressing the key again while armed transfers control.
- Prototype only one relay, Command Fire, Q, reposition and transfer first.

Detailed rules and open cases: [`RELAY_MARSHAL_DESIGN_17.md`](RELAY_MARSHAL_DESIGN_17.md).

### Racer

- Two states: capable precise **Cruise** and brief committed **Overdrive**.
- The skill test is route choice and deliberate near-passes, not direct body collision or permanent speed.
- First prototype contains movement, truthful side-hit bands and Handbrake only. Add Q after steering/camera/terrain contact feel good.
- Stop or simplify if the player fights the cursor, loses the chassis, repeatedly snags terrain, optimally circles one boss or experiences Cruise as dead time.
- Do not build modules or Ghost lap before the movement gate passes.

Detailed experimental brief: [`RACER_EXPERIMENT_17.md`](RACER_EXPERIMENT_17.md).

### Robot AI and offline salvage — later

- **Visible Robot AI:** real on-screen simulation, approximately 75% strength and deliberately simplistic movement/casting. It farms already-cleared content and cannot first-clear or unlock content.
- **Offline salvage:** no hidden combat simulation; accrue slowly for at most 48 hours. A full cap is worth about three runs of the last cleared level, or roughly one run-equivalent per 16 hours.
- The focused note recommends that only manual clears set the offline reference; owner confirmation is still required.
- Start with no-reward AI in Practice. Later validate one transactional currency before any boxes.
- Equipment/decorative boxes, bonus charms and money/consumables are future reward categories, not dependencies for the first prototype.

Detailed economy and integrity guardrails: [`ROBOT_AI_MODE_17.md`](ROBOT_AI_MODE_17.md).

### Presentation and terminology

- Use **class** for the selected robot identity, **kit** for its complete loadout, **core ability** for Q/W/E/R, **mobility ability** for D/F and **module** for 1–4.
- A **construct** is the umbrella; summon, relay and totem are specific types. A passive requires no activation.
- Label content Released, Prototype, Legacy, Research or Parked.
- Vanguard is heavy/direct/industrial; Marshal is coordinated/tactical/networked; Racer is light/aerodynamic/kinetic.
- Astra can explore a small representative animation set later; inspect actual combat size and Reduced effects before replacing assets.

Full glossary and presentation briefs: [`TERMINOLOGY_PRESENTATION_17.md`](TERMINOLOGY_PRESENTATION_17.md).

## Work order: go slowly and test

Do not attempt every owner note in one branch or one playtest build.

| Phase | Small milestone | Stop gate |
| --- | --- | --- |
| **0** | Pull `main`; read required docs; run the existing baseline checks; write a short implementation plan for Practice only | Do not alter saves, progression or game balance |
| **1A** | Practice left dock, safe pause/reset/clear and small test greybox | Render/input/isolation checks; owner can show/hide and reset |
| **1B** | Class-first build controls and mouse enemy placement | Owner places/replaces groups without instructions; campaign snapshot unchanged |
| **2A** | Vanguard permanent gun, hammer, Q/W and body-slam E in Practice | Owner feel test before R/D/F/modules |
| **2B** | Ghost drive and Phase hop rules/effects | Owner tests lockout, buffering and wall cases |
| **2C** | R and one module at a time, ending with combined static kit | Owner decides tuning and whether each module earns its slot |
| **3** | Non-modal fixed-kit learn/upgrade flow | Owner tests reward rhythm before any XP increase |
| **4** | Marshal one-relay slice only | Add relay two only if placement, Command Fire and transfer are fun/readable |
| **5** | Racer movement/Handbrake experimental slice only | Continue only if steering and camera pass the explicit stop gate |
| **6** | Campaign terrain greyboxes and selected wave/synergy ideas | No finished art until pathing and owner layout choice pass |
| **7** | Visible Robot AI research/prototype, then offline fixture | No permanent AI/offline rewards until transaction policy is approved and verified |

After each phase, commit a coherent verified milestone, report Implemented/Verified/Experienced separately and wait for the owner's test where the stop gate calls for it.

## Do not do yet

- Do not delete old abilities, regression scenes, migration fixtures, user saves or user music.
- Do not expose prototype/legacy tools in normal progression.
- Do not reintroduce cross-class skill swapping or the parked combo class.
- Do not build Racer's full 1–4 row before movement earns it.
- Do not implement charms, decorative loot boxes or consumables as side work.
- Do not give Robot AI/offline mode permanent rewards before duplicate-claim, takeover and rollback behavior is designed and tested.
- Do not turn the Practice map into a campaign map or the Practice controls into an internal-debug-variable wall.
- Do not raise quality/fun scores because automated tests pass.
- Do not update current-behavior docs as if a proposal already exists.

## Open decisions that may require the owner

These are the highest-impact unresolved choices; leave the others until their prototype exists:

1. Which Marshal relay types draw aggro and therefore become destructible?
2. During Marshal transfer, do health and cooldowns follow the control software or the physical chassis?
3. Does visible Robot AI use 75% outgoing effectiveness only, and may it farm the highest manually cleared level?
4. Must offline salvage reference a manual clear, and how does its three-run expected value divide between currency and boxes?
5. During Racer Overdrive, should W/R remain available, or should the first version limit inputs to movement, Q and E?

Ask these only when the relevant phase is close. The owner explicitly wants to proceed slowly and direct changes after testing.

## Task routing

| If working on… | Read after this brief |
| --- | --- |
| Current controls/saves/tests | [`README.md`](../../README.md), [`QA_17.md`](QA_17.md), [`BALANCE_16.md`](BALANCE_16.md) |
| Practice | [`PRACTICE_SANDBOX_RESEARCH_17.md`](PRACTICE_SANDBOX_RESEARCH_17.md) |
| Vanguard/ability rules/progression | [`ABILITY_FEEDBACK_17.md`](ABILITY_FEEDBACK_17.md), then relevant taxonomy sections |
| Marshal | [`RELAY_MARSHAL_DESIGN_17.md`](RELAY_MARSHAL_DESIGN_17.md) |
| Racer | [`RACER_EXPERIMENT_17.md`](RACER_EXPERIMENT_17.md) |
| Robot AI/offline | [`ROBOT_AI_MODE_17.md`](ROBOT_AI_MODE_17.md) |
| Terrain | [`ENVIRONMENT_FEEDBACK_17.md`](ENVIRONMENT_FEEDBACK_17.md) |
| Player-facing language/art direction | [`TERMINOLOGY_PRESENTATION_17.md`](TERMINOLOGY_PRESENTATION_17.md), [`ART_STYLE_SCHEMA.md`](ART_STYLE_SCHEMA.md) |
| Unreviewed old abilities | [`ABILITY_TAXONOMY_RESEARCH_17.md`](ABILITY_TAXONOMY_RESEARCH_17.md), [`docs/review/abilities.html`](../review/abilities.html) |
| Swarm-derived hypotheses | [`SWARM_DESIGN_RESEARCH_17.md`](SWARM_DESIGN_RESEARCH_17.md) |
| Full dated owner/research trail | [`OWNER_PLAYTEST_REQUEST_17.md`](OWNER_PLAYTEST_REQUEST_17.md), [`KIT_DESIGN_BRAINSTORM_17.md`](KIT_DESIGN_BRAINSTORM_17.md) |
