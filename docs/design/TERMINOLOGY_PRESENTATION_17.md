# Terminology and Class Presentation Guide

Status: **working language and visual-direction guide, 9 September 2026; future-facing where it describes static kits.** Use these terms consistently in new owner notes, UI and implementation. Existing code identifiers and historical documents do not need a risky bulk rename.

## Player-facing terminology

| Term | Meaning | Examples / boundary |
| --- | --- | --- |
| **Class** | A selectable robot identity with one fixed coherent kit | Vanguard, Marshal, experimental Racer |
| **Kit** | Everything a class brings into a run | Permanent systems, basic, Q/W/E/R, D/F and 1–4 |
| **Ability** | Broad umbrella for a player-triggered combat action | Use a more specific label below when possible |
| **Core ability** | Q/W/E/R combat action | Q is reliable damage; R is normally the highest-impact action |
| **Mobility ability** | D or F | Sustained movement, dash or blink |
| **Module** | One of the class's 1–4 equipped systems | May be a toggle, construct or attached mechanism |
| **Basic attack** | Player-commanded left-click attack | Vanguard hammer; distinct from automatic fire |
| **Permanent system** | Always installed, upgradeable class feature that cannot be unequipped | Vanguard autonomous machine gun |
| **Passive** | Effect requiring no direct activation | Avoid using it as a synonym for every summon or toggle |
| **Powered toggle** | On/off module that consumes or redirects energy while active | A powered trail or coil |
| **Construct** | Umbrella for a deployed non-player object | Summons, relays and totems are specific construct types |
| **Summon** | Autonomous construct/robot that attacks, moves or draws aggro | Vanguard's aggressive helper |
| **Relay** | Marshal-specific robot body participating in shared targeting, casts and transfers | Needle, Blast and Arc Relay |
| **Totem** | Stationary support construct with an area or stored effect | Healing totem, cooldown/energy totem |
| **Rank** | Run-scoped ability/module level | Rank 0 is locked/unlearned where that progression model applies; milestones at 5/10 |
| **Equipment** | Persistent chassis gear managed through the Forge | Eight slots, tiered pieces |
| **Consumable** | Future expendable combat item | Repair or energy-regeneration potion; system is parked |
| **Practice prototype** | Unreleased content available only for isolated testing | Never enters campaign rewards until owner release |
| **Legacy tool** | Older preserved content retained for regression/testing | Not deleted and not presented as a released class option |

Prefer **ability** in ordinary conversation, then use **core ability**, **mobility ability** or **module** where the distinction affects controls. Prefer **class** for the user-facing selection and **kit** for its complete loadout. Keep `skill` in internal identifiers where renaming would create risk, but do not alternate between “skill” and “ability” in one screen.

## Content-state labels

Every concept should carry one of these states in notes and Practice:

| State | Meaning |
| --- | --- |
| **Released** | Approved, implemented, verified and intentionally present in normal play |
| **Prototype** | Available in Practice for focused evaluation; not normal progression content |
| **Legacy** | Preserved old implementation for regression/reference; not a current design promise |
| **Research** | Written hypothesis only; no implication that code exists |
| **Parked** | Intentionally not being pursued now, but preserved for possible later review |

“Locked” means the owner has approved the design direction, not that implementation or tuning is finished. “Verified” means technical evidence exists, not that the feature is fun. “Player-approved” requires an actual owner/player experience report.

## Class presentation sentences

### Vanguard

**Heavy, direct and dependable.** A compact industrial robot that wins by personally aiming substantial tools from mid range, then stepping into a brief totem-powered output window.

- Shape: broad torso, square/forged silhouettes, visible hammer mass and stable planted poses.
- Motion: deliberate anticipation, strong recoil, brief movement commitment and firm recovery.
- Effects: compact brass/steel impacts, readable shock rings and little decorative drift.
- Sound: weighty mechanical clacks, low impacts and a contained reactor surge.
- Avoid: making support constructs visually louder than the robot or giving every action fast weightless movement.

### Marshal

**Coordinated, tactical and networked.** A commander chassis that turns several related robot bodies into one distributed weapon system.

- Shape: shared family silhouette across player and relays, differentiated by unmistakable weapon attachments.
- Motion: synchronized aim snaps, staged pulses and clean software-transfer handoffs.
- Effects: range/state indicators, thin relay links and simultaneous impacts with strict hierarchy.
- Sound: short command cue followed by staggered mechanical acknowledgements; Overclock becomes a unified rising sequence.
- Avoid: mystical teleport language, recursive particle webs or relays that look unrelated to the controllable body.

### Racer — experimental

**Light, aerodynamic and kinetic.** A two-speed chassis that authors damaging routes through acceleration, near-passes and sharp correction.

- Shape: swept panels, runners/wheels/stabilizers and a forward-weighted silhouette.
- Motion: readable acceleration, banking, Handbrake compression and a clear return to stable Cruise.
- Effects: narrow speed lines, side-hit sparks and a clean path echo; no opaque speed aura.
- Sound: motor/air rise, lateral scrape accents and a strong brake/decompression transition.
- Avoid: permanent speed, fire/nitro cliché as the only identity, camera shake or trails that conceal threats.

These are starting briefs for Astra/animation exploration, not final art approvals. Compare a tiny representative set at actual combat size, normal/reduced effects and the intended camera before replacing existing assets.

## Future consumable language

The owner has floated `C` for simple consumables such as hull repair or energy regeneration. Keep this parked. Before implementation, decide whether `C` uses the selected quick item, opens a compact selector, or uses tap/hold for both. Call the category **Consumables**, use concrete item names, display remaining count, and never hide a real-money or permanent-currency spend behind an immediate combat key.

