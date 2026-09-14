# Browser rendering pass

13 September 2026. Owner reports roughly 30–40 FPS in the browser and wants to target 60 while retaining native behavior. Authoritative game checkout: `Timothy-Cao/MobaBot.io`, main, base `49c6a88f323252e0ba22d21fe57cb153f13494de`. Portfolio last imported game source: `84bc6c0314a12d20da875ce007000234cb3caedd`. Followed the portfolio game-development playbook's standalone exception; its wrapper/adapters and production deployment are outside this change.

## Change

Only Web enables a small GPU-generated atlas for the repeated basic-blob body, its hit flash, two pickup appearances and their shadows. Six 64-world-unit cells are rendered at 2x resolution once; existing geometry, colors and shape code are retained in the painter. Shadows, positions, bobbing, rotation, bundle scales and elite rings still follow the original values. Warmup bodies keep the original transparent drawing path. Other enemies, bosses, projectiles, attack tells, status markers, HUD and terrain are untouched. Nothing is culled or removed from simulation.

The temporary transparent viewport produces premultiplied alpha, so a second one-time GPU pass resolves straight alpha for use with ordinary canvas drawing. Both retained RGBA targets together are about 0.75 MiB. No CPU readback, generated asset file, dependency, save key, gameplay setting or global hosting header is added. Native defaults to its existing procedural renderer and never allocates the atlas. The atlas painter must be kept in sync if blob/pickup artwork changes; the visual regression catches divergence.

This addresses repeated geometry submission and tessellation costs, not enemy AI. Profiling showed the floor and HUD were comparatively small costs, so those systems were left alone. No threaded export, runtime rewrite or visual-resolution reduction was needed.

## Evidence and limits

The isolated release probe uses in-memory starter equipment, fixed seeds and a moving camera. First three cases render frozen bodies/pickups, then the final case runs a moving/casting player against 60 mixed enemies including five ranged specialists. Mixed combat uses test-only immortal enemies and Practice god mode to hold the workload; it cannot establish balance or normal survivability. It runs no audio, profile reads/writes, external services or permanent rewards.

Initial repeated-render baseline: 40 bodies/80 pickups about 59–65 reported FPS; 120/240 about 15–17. After caching bodies/pickups (before caching shadows), the 120/240 case reached about 60. Caching the repeated shadows removed the remaining major cost. Matched mixed-combat comparison: original 20.21 ms mean / 26.2 ms p95 per frame, optimized pre-alpha-correction 8.37 / 12.3 ms. Simulation stayed about 2.8 ms per physics sample; the gain came from rendering. Final corrected-build values are recorded in QA_18.

These are local in-app Chromium measurements at 1280x720. Its uncapped engine loop can report above the display refresh rate; numbers are workload/frame-throughput evidence, not proof of 120/200 Hz presentation or a universal browser FPS guarantee. Timing is sensitive to other active applications. No sustained final-boss test, real Chrome/Firefox/Safari matrix, audio-latency test or live-site acceptance is claimed. Human testing on timcao.com's actual wrapper is still needed, especially effect-heavy later stages and zoomed views.

Rendered native-versus-cache checks cover normal/reduced effects, flash, warmup, elite outline and three pickup sizes. Alpha correction removed a dark-shadow artifact caught during visual review. Original and cached actual-size captures were inspected; mean normalized RGB differences over the fixture were approximately 0.00052/0.00047, with minor raster-edge differences. The renderer preserves model enemies, loot and RNG. Full regression includes web_render_test; no new quality/fun score is inferred.

## Reproduce

Install matching templates via `scripts/setup_web.py` if necessary. Export independent probe builds:

```powershell
.\scripts\export_web_probe.ps1 -Name before -Uncached
.\scripts\export_web_probe.ps1 -Name after
```

Serve each `output/web-probes/<name>/web` on an unused loopback port. Open one at a time at the same viewport, let all four cases complete without other builds running, and collect `WEB_RENDER_PROBE` console records. Each case excludes two warmup seconds and samples six seconds. Do not pass a different scene path to a release Web binary: official templates disable runtime path overrides; the exporter selects the fixture in an isolated project copy instead. Probe source is excluded from normal Windows/Web exports.

Native visual check: run Godot with `--path . --script tests/web_render_test.gd -- --render`. Headless `scripts/check.ps1` checks native defaults/state preservation. Normal game Web export remains `scripts/export_web.ps1 -Release`; default debug builds remain available for development.

## Integration boundary

Deliver a new immutable, checksummed release snapshot and filled portfolio handoff. Receiving agents update their snapshot pin, metadata, versioned paths and generated-asset preparation together, preserving `apps/mobabot`'s shared exit, policies, device gate, saves, preload/retry and cache behavior. Never replace its generated PCK/JS directly or silently publish. Keep the prior snapshot/deployment for rollback and test browser storage across the version change. Native release/version branding remains unchanged.

Reference for transparent viewport alpha: [Godot issue 99715](https://github.com/godotengine/godot/issues/99715). The fix here is confined to the one-time cache resolve, preserving the main canvas's existing blend behavior.
