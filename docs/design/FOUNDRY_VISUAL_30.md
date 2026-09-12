# Foundry visual pass — 12 September 2026

Owner authorized executing the strongest recommendations from VISUAL_AUDIT_29. This pass implements terrain identity, miniboss silhouettes/state presentation, shared camp framing, and a small mastery readability improvement. Gameplay values, collision, saves and rewards are unchanged.

- Thick obstacle capsules now read as conveyors, cooling units or press beds, selected deterministically from existing IDs. Contact shadows and inset surfaces convey height. The solid footing matches the existing collision capsule; shadows are decorative. Offscreen props are culled using the render camera.
- Drifter has a wedge plow and long tracked body. Bulwark has broad shoulders and a central rotor; shoulder spacing and shield arcs expose recovery. Animation reads existing state/time and respects reduced effects. Attack tells and timings are unchanged.
- All four camp tabs share cut-corner steel framing, a brass divider and recessed content tray. Tabs have clearer selected states. Existing next-stage action, controls, focus and text remain real UI controls.
- Mastery labels no longer dim with the entire button. Purchased/available/future states use casing and connection colors while preserving hover descriptions and the existing reusable emblems/badges.

No new bitmaps were generated. Equipment style normalization, populated reward-tray redesign, new combat effects, floor decal expansion and build-label metadata remain separate work. The cartoony game remains the reference presentation.

## Verification and review

All 41 check.ps1 suites pass. Both historical refined probes complete. The current Vanguard artificial-health Level 1 route finishes at 1052.7 seconds, level 21, 1609 kills, peak 26 enemies; stage arrivals and cast totals exactly match the preceding field-pickup milestone. This is reliability evidence, not human difficulty proof.

Run tests/foundry_visual_capture.gd with rendered Godot to produce ignored output/foundry-*.png previews. The fixture disables persistence/physics/audio, checks draw-time enemy/terrain/loot RNG preservation, renders normal/reduced states and all camp tabs, and measures a synthetic 180-enemy scene. Optional --baseline loads ignored output/foundry_baseline.gd, extracted from 67d23bc's expedition_art.gd with its class_name declaration removed.

Paired frame-cadence medians/p95: previous renderer 44.455/50.448 ms; current 48.233/57.458 ms. These desktop process-frame-to-post-draw samples include engine/script/pacing overhead, are not isolated GPU measurements and do not establish human-play FPS. Added rendering cost is an unresolved review consideration. Inspect crowded combat on the target machine before expanding native detail further.

Fresh terrain, crowded scene, miniboss recovery and camp previews were inspected at 1600×900, including reduced-effects miniboss presentation. Header overlap and an initial fixture focus-loss pause were corrected before final captures. Human visual approval remains pending. No player session was restarted or release uploaded.
