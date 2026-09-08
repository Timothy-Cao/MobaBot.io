# Slice 05 — rank milestones, free utility, pressure waves

Implemented September 8, 2026. Main staged mode only; legacy sample/regression mode retains its old progression formulas. Supersedes slice 04 rank limits, main-mode spawn pacing and loot counts.

## Upgrade structure

Build → Upgrades now has Skills, Weapons and Utility sections. Seven equipped cast slots and eight weapon/support tracks each have ten ranks. Click any rank to preview before/after numbers. Stars mark ranks 5 and 10. Rank choices are sequential, not separate permanent unlocks. One offered card continues an already-invested, uncapped track, helping focused builds reach milestones; the other choices remain randomized.

Damage/rate rank bonuses are +20/25/30/35/40/45/50/55/60/65%, relative to the base, not multiplicative per purchase. Ability recharge gets half that percentage reduction; damage abilities also gain the damage bonus. Rarity remains separate and multiplicative: `(1 + rarity × 0.15) × (1 + rank bonus)` for ability damage; recharge combines rank reduction and rarity reduction while preserving partial charge progress. Utility-only spells do not claim fictitious damage gains.

| Track / ability | Rank 5 milestone | Rank 10 milestone |
|---|---|---|
| Homing salvo | 7 bolts per one-second volley | 9 bolts |
| Shock ring / mortar / Overdrive | +25% radius | +50% radius |
| Foundry lance | +25% beam width | +50% beam width |
| Rail spike | 6 targets pierced | 8 targets pierced |
| Safety shell | Blocks 2 hits within its duration | Blocks 3 hits |
| Full throttle | 4-second duration | 5-second duration |
| Phase hop / Skate jets / Ram strike | +25% range | +50% range |
| Bolt sentry | +25% firing rate | +50% firing rate |
| Repair beacon | 150 px healing radius | 200 px healing radius |
| Emergency cell | 70 energy for one hull | 85 energy for one hull |
| Heavy bolts | Additional +25% base damage, 1 pierce | Additional +50% base damage, 2 pierces |
| Fire rate | Additional +25% base firing rate | Additional +50% base firing rate |
| Grinder | Larger orbit/tools, 2 hits/tool | Larger again, 3 hits/tool |
| Ricochet | 2 extra bounces | 4 extra bounces |
| Pulse coil | +25% radius | +50% radius |
| Tool rack | 2 additional slots | 4 additional slots |
| Reactor / energy cell | +2 regen / +20 capacity | +4 regen / +40 capacity |

Passive weapon damage/rate curves add 25 percentage points per milestone beyond the ordinary rank bonus. Capacity, reactor and cell use explicit absolute stat ladders instead of pretending every property is a damage percentage. All actual next-rank numbers appear in the browser. Milestones use larger functional effects, stronger gold cast accents and starred HUD ranks, retaining the original action icon. Telegraph widths/radii and movement indicators follow the evolved mechanics. No new animation-sheet dependency.

## Utility is not a combat slot

Magnet is always equipped, costs no energy and never appears in the combat offer pool. It has its own Loadout → Utility page and Build → Utility section. Start at rank 1; gain one rank every three level-up purchases, capped at rank 5 after twelve purchases. Radius: 250/350/450/550/650 px. Maximum pull speed: 980/1160/1340/1520/1700 px/s, with stronger acceleration. Rank 5 attracts all existing scrap every 15 seconds; it does not invent XP or remove the visible travel to the player.

This is a generous QoL reward, but not entirely power-neutral: collected scrap feeds Orbit and Collection pulse. Energy capacity/regen and protection remain combat investments because they directly increase spell throughput or survivability.

Old saved passive loadouts containing Magnet migrate to Recoil shell, preserving the other abilities and keybinds. Recoil shell is a free defensive combat passive: a nonlethal hull hit emits a six-damage, 100-radius ring; its damage is attributed to Active. It does not activate on blocked hits or resurrect a lethally hit player. Four combat slots remain, with six passive options including Reactive plating. The default preset is unchanged.

## Loot and encounters

Ordinary enemies drop 3 real scrap dots, chargers 10, tanks 20, bosses 72. Pressure elites add 5. XP/object count is real, not decorative fake currency. Up to 360 scrap objects are retained; overflow merges into existing scrap without discarding earned XP. Charged cells are teal lightning discs, repair drops coral crosses; both reuse existing palette and geometry. Chargers/tanks drop 18 energy; bosses drop 50 and one hull patch. Every third-kill-aligned tank also drops a patch. Separate pools reserve up to twenty objects per supply type, merging within each type. Full bars clamp excess recovery; cells and patches do not become XP. Stage banking claims remaining earned rewards once.

Main waves spawn groups of 3/4/5 by stage every 0.72 seconds. At stage times 18, 36 and 54 seconds, a warned surge adds 11/14/17 mixed elites from a side. Warning precedes the pack by two seconds. After each surge, five seconds of slower reinforcements (one per 1.2 seconds) provide breathing room. Elite runners move at 218/226/234 px/s, slightly faster than unboosted player movement; ordinary enemies remain slower. Chargers retain their directional windup and dash. Gold outlines and streaks distinguish the stronger pressure pack. Enemies have stage-scaled health; pressure elites gain a further ×1.65 health.

Spawn points are outside the entire camera rectangle with a 70 px margin, including at world corners and both zoom limits. Only open arena sides are eligible—clamping a point from a closed side must not make an enemy appear on-screen. Required bosses also spawn off-screen and retain a reserved place at the enemy cap. Boss HP is now 350/440/530. Waves stop for the boss as before. Player resources, invulnerability, enemy/projectile caps, charge timers and pause semantics remain bounded.

More loot needs a slower level curve: after the initial threshold, each next threshold adds `12 + level × 8` XP. Full test runs reached about level 33 rather than opening roughly 46 rank menus. The main model still banks boss scrap; a few consecutive choices can remain after a stage.

## Verification / limits

Original smoke test plus 165 salvage, 102 MOBA, 55 slice-04 and 476 slice-05 checks passed: 798 checks. The salvage count is lower because the new icon-based Skills browser contains fewer TextureRects; no simulation assertions were removed. Updated old hard-coded 180-pickup expectations to the actual 360 cap and changed the obsolete passive-Magnet assertion to migration validation.

New tests cover every purchased rank and current/next stat consistency, caps, rare promotion charge progress, milestone casts, free utility cadence, 1,500 candidate spawn positions across center/corners/two zooms, one-time surges, resource-type conservation at capacity, actual recovery, and lethal Recoil safety. A stationary/no-cast player lost after 29.5 seconds. Moving model bots completed both presets with ordinary health and no forced boss kills (about 214 seconds, 898 kills). Bots are biased and do not establish fun or final balance.

Actual rendered Relaxed run: won at 217.27s, 898 kills, 4,864 scrap, level 33, eight hull hits. RTX 5070/GL compatibility: sampled first 20,000 gameplay frame intervals, discarded 60 warmup samples; median 5.043ms / p95 8.034ms, peak 40 enemies within that sampling window. This is not an all-hardware or full-run worst-case guarantee. The run preceded final preview-text refinements, additional summary fields and a Recoil lethal-hit guard (Recoil was not equipped). Nine small-window fixtures plus large-window layouts and actual result reviewed. Settings/run storage readback passed. Captures: `output/playtest-v05`.

Still one arena and one boss archetype. No permanent skill tree, randomized affix loot, new music or animation pack. Visual distinction uses size/shape plus restrained gold accents, not new drawings for every rank. Next human check: does reaching rank 5 feel like a real payoff, is the magnet generous enough, and are fast packs tense without feeling unavoidable?
