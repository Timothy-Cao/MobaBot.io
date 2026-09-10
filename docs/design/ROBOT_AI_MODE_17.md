# Robot AI and Offline Salvage Direction

Status: **owner direction plus implementation guardrails, 9 September 2026; not implemented.** Exact reward tables, eligibility, failure handling and UI still require research and owner review.

Routing: this is later Phase 7 in [`NEXT_SESSION_BRIEF_17.md`](NEXT_SESSION_BRIEF_17.md), after the core classes and playtesting foundation. Do not pull it into the first implementation milestone.

## Owner decisions

MobaBot may support two separate low-input systems:

1. **Visible Robot AI:** the real combat simulation runs on screen. The robot operates at approximately 75% strength and uses intentionally simple movement/ability logic, so a capable player remains substantially better.
2. **Offline salvage:** elapsed time produces a small return while the game is closed. Accrual caps at 48 hours, and a full 48-hour claim should be worth only about three runs of the last cleared level.

The offline return may include ordinary resources and loot-box progress for equipment, decorative loot, charms with bonus effects and money used for boxes or consumables. This is a direction for later economy design, not approval of those unimplemented item systems.

Consumables are parked for later. A possible `C` input would access simple items such as hull-repair and energy-regeneration potions; do not add a consumable inventory, drop table or combat menu during the first AI/offline pass.

## Keep the two systems distinct

| Property | Visible Robot AI | Offline salvage |
| --- | --- | --- |
| Runs combat simulation | Yes | No; calculate a bounded claim |
| Player can watch/take over | Yes | No |
| Build matters | Actual equipped farming build | Later decision; begin with last-cleared-stage baseline |
| Intended efficiency | About 75% raw strength plus weaker decisions | About one run-equivalent per 16 offline hours, capped near three |
| Can first-clear content | No | No |
| Main appeal | Watch a reliable low-input build farm | Return after sleep/travel to modest accumulated progress |

Visible autoplay should not secretly guarantee success. Offline salvage should not simulate thousands of hidden combat frames or pretend that its rewards prove a build could complete the content.

## Visible Robot AI proposal

### Meaning of 75% strength

Treat **75% strength** as one explicit AI-mode effectiveness modifier, not dozens of hidden nerfs. The cleanest first hypothesis is 75% outgoing damage/healing/shielding while player defenses, enemy tuning and cooldown clocks remain honest. The intentionally simple pilot already loses efficiency through movement, targeting and timing; reducing survivability too may create random deaths rather than understandable inferiority.

This exact interpretation is assistant guidance and needs owner confirmation. Whatever implementation is chosen must appear in the start summary and result screen.

### Deliberately simple pilot

- moves toward nearby pickups when local danger is low;
- maintains a basic preferred distance instead of predicting paths;
- avoids the clearest telegraphed zones with a late, imperfect response;
- casts Q/W/E from simple range and cooldown rules;
- reserves R for a minimum enemy count or boss window;
- uses D/F only for immediate danger, not advanced animation buffering or wall tricks;
- never receives hidden aim, vision, reaction-time or collision privileges;
- favors reliable passive/summon/magnet/sustain builds naturally, without artificial bonuses to those items.

Use deterministic priorities and expose a short post-run breakdown of deaths, missed pickups and unused abilities. Do not build a learning AI or make behavior silently scale to the encounter.

### Eligibility and takeover

- Only manually cleared stage/ascension combinations are eligible.
- Robot AI cannot claim a first clear, unlock new content or complete execution-based achievements.
- A separate farming-loadout slot should eventually prevent overwriting the push build.
- Taking control pauses reward resolution, switches off the 75% modifier cleanly and continues the same run; define one atomic result owner so takeover cannot duplicate loot.
- A visible `ROBOT AI · 75%` state must remain on screen.

Whether the highest manually cleared level itself is eligible for visible AI remains open. The earlier conservative hypothesis restricted AI below the highest clear; the latest owner wording does not explicitly settle that boundary.

## Offline salvage proposal

### Rate and cap

Use the owner's target as an easily audited baseline:

`run equivalents = min(offline elapsed, 48 hours) / 16 hours`

Thus eight hours is roughly half a run, 16 hours is one run, and 48 hours reaches the cap of roughly three runs. “Roughly” matters: item rarity and box fragments may use expected value rather than promising three exact copies of a run result.

### Eligible reference

Begin from the last **manually cleared** level and ascension. An AI clear must never raise the offline reference. If that level's reward table later changes, record the table/version used when accrual began or convert time into a stable salvage budget before rolling rewards.

### Claim contents

Keep the initial claim readable:

- ordinary currency/resources;
- bounded equipment-box progress or rolls already available from that cleared level;
- decorative-box progress when the system exists;
- charm progress only after charms and their bonus policy are designed;
- no first-clear reward, quest item, achievement, unlock, mastery choice or unique boss guarantee.

Do not add all future reward categories merely to make the first screen look full. One currency plus one familiar box track is enough to validate the loop.

### Transaction and time safety

- Store last-claim time, accrual baseline and reward-table version together.
- On claim, calculate once, validate inventory capacity, write one transaction and roll back the whole claim if any write fails.
- Mark the accrual as claimed only in the same successful transaction as the rewards.
- Preserve corrupt saves and never replace the original during repair.
- Handle clock rollback conservatively without deleting already accumulated valid time.
- Cap elapsed time before reward rolling so extreme clock changes cannot create unbounded work or loot.
- Automated tests use isolated fixtures and never grant permanent rewards to the real player profile.

## Economy questions still requiring research

- Is “three runs” based on expected total value, exact box count or separate per-resource rates?
- Does visible AI receive the same drop table with its 75% combat modifier, or a separate reward multiplier?
- Is the last manually cleared level always eligible, or must farming remain one stage/ascension below it?
- Do drop-rate and magnet stats affect offline rewards? The safer initial answer is no, because otherwise an offline-only equipment set becomes compulsory.
- Are decorative rewards allowed offline, and can an offline roll grant rarity-protected cosmetics?
- What do charms modify, how many equip, and can their bonuses create another mandatory idle multiplier?
- Does `C` open a small consumable selector, use a selected quick item, or both? Do not reserve final interaction behavior until the control layout is tested.

## Minimum implementation sequence

1. Research and approve the eligibility/reward policy; do not code rewards first.
2. Prototype visible AI in Practice with no permanent loot and a fixed build.
3. Compare manual and AI completion on already-cleared content; confirm the AI is understandable, weaker and interruptible.
4. Add transactional visible-run rewards only after takeover/failure cannot duplicate them.
5. Prototype offline accrual with one currency in a disposable fixture.
6. Add one box track, then run clock rollback, 48-hour cap, corrupted-save and double-claim tests.
7. Add equipment/decorative/charm categories only as their own systems become real and reviewed.

## Owner review questions

- Does watching the simple pilot feel satisfying, or does its avoidable movement look broken rather than intentionally mediocre?
- Is 75% outgoing effectiveness the intended meaning of “75% strength”?
- May visible AI farm the highest manually cleared level?
- Should offline loot use expected value with fractional box progress, or roll discrete boxes only at claim time?
- Is a 48-hour cap communicated clearly enough that missing a claim never feels punitive?
