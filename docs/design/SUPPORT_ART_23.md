# Support and reusable art · 0.23

11 September 2026. Owner selected an ordinary-enemy aggro anchor and an energy version of Reserve. The healing Reserve remains unchanged. New runs and primary Practice use `support23`; older saved runs retain their original module behavior/ranks and images. No stationary siege transformation or second playable class is introduced.

## Support mechanics

- Slot 2 **Anchor** replaces Bulwark's shooting/pulse behavior. Same purchase/rank/cost/recharge framework, 35-second lifetime, 135 × rank-power HP. Attraction radius is 340 units and its drawn ring matches. Ordinary monsters, melee tanks and ranged specialists approach it and damage it at contact. Bosses/guardians ignore it. It neither shoots nor deals pulse damage. Existing enemy projectiles are not deleted or redirected. EMP disables attraction; destruction, expiry and redeployment remove its value. The temporary pursuit override interrupts ordinary specialists' own attack cycle while attracted; this is a balance-sensitive crowd-control benefit, not merely a cosmetic target marker.
- Slot 3 **Reserve** retains the owner's approved health/energy/overflow mechanics, including its rank-ten behavior. No support detonation.
- Slot 4 **Energy reserve** replaces Overclock. Lives 35 seconds. Outside its circle, stores 6 × rank-power energy/sec up to 86 × rank-power. Inside, transfers up to 45 × sqrt(rank-power) per second, bounded by stored amount and missing energy. It holds the remaining store when energy is full. No healing, damage, free casting or cooldown acceleration. Redeploy clears storage. It stays untargetable, as the existing support construct did. EMP pauses charging/transfer while lifetime continues. Its high ranks increase storage/transfer and area; they do not remove the leave-and-return requirement.

The native anchor has a signal mast rather than a gun and a health meter. Both reserves have stored-value meters, with green cross versus blue lightning. Reduced effects preserves range, store and health information. New icons appear in the dock, camp shop and build inspection; old saves keep their old icons. Internal save IDs remain stable (`guard_bot`/`reserve_totem`/`recovery_totem`) to preserve module ownership.

## Reusable art and quality pass

Five original generated PNG masters: Utility wrench/cell, Looting salvage chest, Pet helper, Anchor beacon and blue Energy reserve. The first three are independent semantic emblems, not a baked-in tree layout; reuse them as headers, shop categories or inspectors after future redesigns. Native node connectors, states and rank labels stay editable code. No generated text is embedded.

The owner's subsequent efficiency suggestion is implemented: each modern node reuses its branch emblem with an 18px code-drawn badge extending beyond the top-right corner. Twelve independent symbols cover health, energy, range, resistance, extra charge, XP, loot, supplies, double rewards, damage, magnet and stun. Shape plus color carries the distinction; names/ranks and hover text remain authoritative. `MasteryBadge.attach` accepts any base asset and semantic badge, independent of the current tree layout. Wider node cards preserve full names. No extra bitmap generation is needed for new combinations. Badges remain crisp native shapes beside the pixelated base art.

All share the existing teal enamel, steel, brass and cream painted family. Source files remain unchanged; 128px Godot imports with mipmaps feed the existing reversible **32×32 pixel shader**, saturation 0.85 and brightness 0.97. No second pixelation pipeline. Opaque dark backgrounds are deliberate; source alpha validation expects opacity. Exact prompts, source filenames and SHA-256 hashes: `assets/mastery_icons/manifest.json`. This manifest also covers the two new Vanguard module icons. Generated art is not a claim of human authorship.

Inspected rendered icon scales 64/40/32 logical pixels and native modules in normal/reduced effects. The images read as wrench, chest, helper, beacon and battery at small size; owner preference remains untested. New symbols improve category and module recognition without redesigning the whole menu.

Next high-value asset candidates, in order:

1. **Pickup silhouettes:** paired energy cell / repair capsule, matching the new reserves. Reuse in drops, mastery descriptions and reward receipts. Test recognition while moving, not just in a contact sheet.
2. **Terrain kit:** straight wall body, end cap, corner and damaged variant for the three existing sectors. Keep collision-driven geometry native; apply low-contrast materials under enemy tells. Do not generate random wall shapes that diverge from collision.
3. **Enemy role accents:** reusable plow, shield, signal mast and mortar housing. First show them on the current native bodies at gameplay scale; avoid making every foe brass-bright like the player.
4. **Class-two icons:** only after the Practice mechanics stabilize. Generate broad subject silhouettes, preserve the same pixel treatment, and avoid expensive final animation sheets while the kit is still changing.

This pass is five UI illustrations plus native support readability, not new environment maps or a complete sprite pack. The future grapple-class request is recorded in SECOND_CLASS_24.md.

## Verification

`support_art_test.gd`: energy/anchor behavior, EMP, boss immunity, dead-anchor release, checkpoint compatibility, opaque source validation, bounded imports, actual new-run/Practice routing and rendered assets. `-- --render` writes ignored captures under `output/support23`. Full check suite includes it and skill_visual_test. Artificial-health probe results and final suite evidence are recorded in QA_18; they do not establish fun or normal-health balance.
