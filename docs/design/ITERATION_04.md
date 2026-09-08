# Slice 04 — camera, resources and stage rewards

Implemented September 8, 2026. Windows keyboard/mouse; this supersedes the 90-second main-mode rules in MOBA_MODE_03.md. The original sample and legacy model mode remain intact.

## Direction and research

Keep the MOBA decisions—position, aim, spend, recover—inside a short survivor run. League's [official introduction](https://www.leagueoflegends.com/en-us/how-to-play/) describes experience-driven ability/stat growth, health/mana management and major objective rewards. Those are useful design principles, not a requirement to reproduce its champion kits or competitive economy. Mouse-wheel zoom, held inspection and toggle slots are direct user requirements. Our stage structure, energy numbers and rarity formula below are original prototype choices, not claims about League mechanics or proven balance.

Do not make every action compete for energy. Free baseline combat and mobility keep a depleted player functional. Costs should create choices, not turn the game into waiting for a bar. Keep precise targeting optional through the Relaxed and Precision loadouts.

## Controls

| Input | Behaviour |
|---|---|
| Right-click / hold | Move / continuously steer; S immediately stops |
| Wheel | 5-percentage-point zoom steps, clamped to 65–100%; original view is closest |
| Hold Tab | Pause and inspect Abilities, Stats or Upgrades; release restores the previous screen and pending choice |
| Esc | Cancel targeting or close inspection first; otherwise settings |
| 1–4 | Toggle equipped passive slots during combat; in reward menus 1–3 select cards |
| Q/W/E, R | Three regular actives, one ultimate |
| D/F, T | Free speed/mobility abilities; one replaceable summon |

All eleven ability/toggle keys support conflict-swapping letter/number bindings. Legacy saves with an active on a number retain that binding; the displaced toggle moves safely. S/M/Tab/Esc remain reserved. Zoom, sound, effects, loadout and keys save locally. Loadout changes apply next run. Tab pauses the solo game intentionally; it is not a live competitive scoreboard.

At 65% the world view is approximately 1477×831 instead of 960×540; HUD size is unchanged. World edges, cursor coordinates, spawn visibility, minimap and floor rendering account for zoom. Wider views currently also push ordinary enemy spawns farther away: arrival pressure may need compensation after human testing.

## Resource contract

| System | Initial rule |
|---|---|
| Energy | 100 maximum, 8/second regeneration before upkeep |
| Free toggles | Auto bolt, Scrap orbit, Ricochet; Ricochet requires Orbit enabled |
| Powered toggles | Collection pulse 2/second; Long reach and Reinforced shell 1/second each |
| Active costs | Salvo 14, ring 16, shell 20, rail 12, mortar 18, ram 12 |
| Ultimate / summon | Both ultimates 30; sentry 20, repair beacon 24 |
| Mobility | D/F cost no energy; charges and recharge still apply |
| Emergency cell | Optional regular active: 1 hull → 55 energy, 16-second recharge, cannot spend the last hull or cast at full energy |
| XP upgrades | Reactor +2 regen/second per rank; cell +20 capacity per rank; each has three ranks |

Powered toggles switch off when energy cannot cover upkeep. They do not silently switch back on. Invalid targets, insufficient resources and invalid health costs do not consume charges. The health trade is explicit and bypasses shielding; it is not ordinary incoming damage. All timers pause in menus. Toggling a passive off does not manipulate the upgrade offer pool.

## Levels, stages and rarity

XP levels keep offering the existing illustrated rank choices, now with reactor and cell upgrades. The graph shows current ranks and next-rank values; it is not a permanent branching unlock tree.

Three stages share the workshop. Each has 60 seconds of ordinary waves, then a required Foreman. Boss health scales 135/170/205. New waves stop during the boss fight. Boss drops retain the 48-dot burst; after a short collection beat, remaining earned scrap is banked exactly once. Surviving ordinary enemies are cleared without extra rewards.

After stages 1 and 2, choose one of three cards: two equipped-ability promotions or a reactor cache (+20 capacity, +2 regeneration for this run). The cache choice also repairs one hull and all choices refill energy; the boss itself repairs one hull. Ability promotions prefer to offer a damaging ability and can revisit a Rare ability for an Epic second-stage reward. Stage 3 ends in victory, not an upgrade with no remaining combat to use it in.

Common → Rare → Epic. Per tier: +15% base damage where applicable, −8% base recharge time. Thus Epic damage is ×1.30, recharge ×0.84, not compounded multipliers. Utility-only abilities gain recharge speed, not invented damage. Costs, targeting, silhouettes and effects remain unchanged. Promotion preserves recharge progress rather than granting free charges. All tiers reset on a new run. No Legendary tier, randomized rarity on every XP card, persistent loot economy or unlock grind in this pass.

## Art strategy

The new square action icons are original code-native drawings in `src/salvage/ability_icon.gd`: 64-unit construction, shared slate/teal bevels, steel or cream functional silhouette, brass accents, generous negative space. The same icon is reused on the HUD, loadout, inspection and promotion cards. Rarity changes the border and label, not the icon. This avoids generating and reconciling separate art for every power tier.

Prioritize readable action shapes: diagonal bolts for volley/rail, concentric rings for radial damage, broad shield, mortar crosshair, paired portals for blink, chevrons for speed, gear-lightning for overdrive. Animation remains reusable motion, trails, rings, beams, recoil and impact fragments. No bespoke frame-by-frame spell animation dependency. Equipment/passive PNGs remain more detailed than the action-icon family; shared materials tie them together, but identical rendering styles are not claimed. Full vocabulary and future asset prompt: ART_STYLE_SCHEMA.md.

## Verification and remaining decisions

Original smoke test, 175 salvage checks, 102 MOBA checks, and 55 iteration checks passed. Includes held-Tab return states, focus loss, old key migration, energy/health rules, rarity formulas, stage rewards, enemy-cap boss spawning and zoom bounds/coordinates. Two complete model-driven three-stage runs won without forced boss kills or infinite player health: Relaxed 199.25s and Precision 201.90s, seed 2407. These are biased bots, not balance evidence.

Full GPU-rendered run: won at 201.48s, 558 kills, 1987 scrap, level 27, four hull hits. 19,940 frame intervals: median 5.639ms, p95 11.888ms, peak enemies 34, RTX 5070. One machine/run only. Nine 1280×720 fixtures and six 960×540 fixtures visually reviewed; storage integration passed. Captures: `output/playtest-v04`. The completed-run image is organic autoplay; menu fixtures are constructed states.

Human test priorities: zoomed-out readability/pressure, whether upkeep feels worth managing, how often the energy bar blocks a desired cast, stopping and aiming feel, and whether boss rewards feel distinct. Stage banking currently creates several consecutive XP choices after a boss; consolidate that reward sequence if it interrupts momentum. One arena and one boss archetype are intentional prototype limits. No missing credentials or assets block local play.
