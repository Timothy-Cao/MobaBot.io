# Chest results and stage shops

10 September 2026. Scope: current Vanguard expeditions. No paid loot boxes or new currency.

## Diagnosis

Vanguard's simulation opened chests automatically, adding a skill point, 20 field credits and sometimes equipment. The old camp screen drew an opening box without showing those awards. The player was not missing a claim button. Shops existed only after stages 2, 5 and 7, which made early field credits hard to understand.

## Current design

- During combat: a five-second, non-modal receipt names the exact rewards. Multiple chests resolved in one simulation step are grouped. A newer notification replaces the previous one; the full round ledger retains all outcomes.
- At camp: opening lid → short scale/fade of actual icons and counts → stable results. Click the receipt to finish the reveal immediately. Reduced effects is immediate. No roulette, fake near-misses, click-to-claim gate or combat pause.
- Equipment appears before routine points/credits. Existing tier colors/pips and item artwork are reused. A normal three-row result fits; large batches scroll. The compact combat notice shows up to three result categories/items; camp has the complete list.
- Field credits buy equipment after each **stage**, not each round. Three existing-price offers; purchase never auto-equips or replaces a skill. Money resets with the run; banked gear persists. The balance's hover text explains this without adding a permanent paragraph.
- Stage 8 also has a final shopping opportunity before Finish, so remaining run money can become lasting gear.

The receipt covers chests, clear bonuses and loot-round gear, not every XP/supply pickup or purchase. A failed banking transaction leaves rewards pending with an error; the receipt is evidence of the rolled outcome, not proof of a successful disk write. Old checkpoints without receipts show that rewards were already collected; unknown historical outcomes are never invented.

## Reference research and adaptation

[Riot's client-animation engineering article](https://www.riotgames.com/en/news/animation-league-legends-client) discusses coordinated animation timelines, opacity/transform animation, and static fallbacks for low-spec clients. Our adaptation uses small native Godot tweens and an immediate Reduced effects path. Its browser performance details do not establish Godot performance.

[Thomas Corvée's original lootbox VFX study](https://realtimevfx.com/t/thomas-corvee-sketch-64-lootbox/27596) is a useful opening/reveal motion reference, not an asset source. We reuse our salvage chest and gear art. The short duration, exact-outcome receipt and no-claim-button policy are our design judgments, not claims that these references prove player satisfaction.

## Implementation and safety

`RewardLedger` is plain simulation/save data; `LootReceipt` is display-only. The simulation records rewards once. Animation, redraw, skipping and Continue cannot roll or claim them. Checkpoints optionally retain the ledger; validation rejects malformed item IDs/counts. Shop stock is generated before saving; reopening/resuming cannot reroll it, and sold slots remain sold. Existing Forge transaction rollback remains authoritative. No player save format version bump or destructive migration.

## Verification and remaining review

`tests/loot_receipt_test.gd` uses fixed loot seed 17918, in-memory collection fixtures, actual-content assertions, shop boundaries, checkpoint roundtrips, malformed receipts, capped-point compensation, failed-purchase rollback, repeated bank/purchase prevention, normal/reduced UI, skip behavior and three-row fit. `-- --render` captures normal/reduced stage results, a one-chest result, a between-round result and a combat notification in ignored `output/` files. These are synthetic reward fixtures, not real earned collection items.

Run `scripts/check.ps1` for the full regression. Both refined behavior probes and the expedition class probe remain compatibility checks; they do not establish Vanguard reward feel. Owner review still needed: notice duration during a real fight, opening impact, shop frequency, and long-term collection growth from five additional shops. No fun or visual-quality rating is raised solely by passing tests.
