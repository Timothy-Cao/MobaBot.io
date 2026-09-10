# Gameplay vision — owner direction

10 September 2026. This is the current owner-authored north star for evaluating combat, progression and future kits. It describes the intended experience, not what automated tests prove and not a command to rebalance the frozen playtest build immediately. Where older notes emphasize isolated power or a particular implementation, use this vision to judge the result.

## The intended experience

**Power should create more good decisions, not remove the need to make them.** The player grows from a scrappy robot into a powerful machine while still reading threats, choosing the right part of the kit and changing plans as the fight changes.

1. **Use the whole kit situationally.** Combat alternates between repositioning, retreating, sustained damage, kiting and burst. Varied immediate threats change the useful action order: the same tools may be sequenced or aimed differently against a boss, a crowd, a ranged threat or a dangerous approach. One repeated rotation should not solve every encounter.
2. **Different tools solve different problems.** Players may focus upgrades temporarily, but one skill, combo or item must not overshadow the rest of the kit. Easy-to-execute, high-impact, boss-focused, crowd-focused, close-range and long-range tools can all be strong in their intended contexts without being universal answers.
3. **Both sides visibly grow.** The player should feel stronger within a round and after every stage. Enemies should keep pace through readable new pressure and mechanics, not health inflation alone. Progress may come from tactical understanding, ability upgrades, mastery or—when appropriate—replaying cleared content for equipment.
4. **Support active and passive play without confusing their roles.** Frontier progression emphasizes active decisions and outplay. Cleared or lower-difficulty content may support reliable low-input/AFK builds, and a fortunate run may temporarily overpower the current round. Controlled variance should create struggle, relief and occasional dominant highs without making outcomes arbitrary. Effort and choices should leave the player with some useful progress even when a run is not a full clear.
5. **Every ability needs a reason and a cost.** Each tool should feel meaningful, interesting or fun and create some decision about timing, target, position or resource. A tool that is always pressed whenever available needs a tradeoff or a more specific purpose. A tool that is consistently ignored needs a clearer use, stronger payoff or replacement. Alternatives do not need identical power, but they should be close enough in total value that the player briefly considers which solution fits the moment.

## Desired combat rhythm

Read the immediate threat → select a response → position and execute → take the payoff or recover → reassess.

This rhythm may produce short damage windows, defensive retreats, collection windows and moments of overwhelming power. The encounter should keep asking a new question before the previous answer becomes an automatic loop. Passive damage supplies continuity; it should not erase aiming, movement, timing or target selection when the player is pushing difficult content.

## Design tests for abilities and encounters

Use these questions before changing numbers:

- In what situation is this tool the best answer, and in what situation is it a poor answer?
- What does the player give up by using it now: position, time, energy, safety, future cooldowns or another opportunity?
- Does another part of the kit provide a credible alternative, setup or follow-up?
- Can enemy composition or behavior change the useful cast order?
- Does an upgrade make the tool more expressive or applicable without erasing its weakness?
- If players use it constantly, is that intentional passive continuity or an active button with no real decision?
- If players avoid it, is the problem power, clarity, execution burden, opportunity cost or lack of a relevant encounter?

Equal usage is not the goal. Situational purpose, understandable tradeoffs and multiple viable responses are the goal.

## Progression and variance guardrails

- Let players focus a few tools for a period, while ensuring the full kit continues to progress and remains relevant.
- Introduce enemy mechanics that reward different answers. Avoid solving difficulty mainly by extending health bars.
- Preserve meaningful run variance: some runs should be tense and some should produce an exciting power spike. Avoid a single rare roll that makes every later decision irrelevant.
- Reward partial progress proportionally. Persistent gains should make another attempt feel worthwhile without making grinding mandatory for a learnable baseline difficulty.
- Low-input farming should be safest on content the player has already demonstrated they can clear. Level-pushing builds should retain a meaningful advantage from active execution.

## Vanguard modules to reconsider

These are owner hypotheses for the next design discussion, not locked replacements and not approval to change the current playtest build before feedback.

### Reserve — preserve the distinct idea

The stored-repair module is promising because it asks the player to leave its area, let it accumulate value and deliberately return. Preserve that leave-and-return identity. Test whether the stored amount, readiness and hull → energy → overflow conversion are understandable and whether returning creates a real route/positioning decision.

### Bulwark — question the free value

The turret currently appears strictly beneficial once deployed. Reconsider it if placement does not create a meaningful cost, risk or timing choice. Possible directions include a more conditional defensive tool, a deployable with a real commitment, or a different module entirely. Do not remove it solely from description-level feedback; first measure whether target selection, placement and aggro actually create enough decisions in play.

### Overclock — explore a committed burst stance instead of a free aura

Candidate concept: replace the deployable well with a toggle or activation that anchors the player for roughly two seconds. During that committed window, the player receives dramatically faster cooldown recovery (initial thought: about 75% reduction), rapid/full energy recovery and roughly half energy costs. Afterward, impose a temporary active-ability lockout while preserving escape dashes, creating a burst-now/recover-later choice.

The exact interpretation and values remain open. Before prototyping, decide:

- whether the player may cast while rooted or the root is a preparation channel;
- which abilities—including R, D, F and modules—receive the benefit;
- the post-window lockout duration and whether it blocks the hammer;
- whether taking damage interrupts it and whether it grants any protection;
- whether early cancellation is allowed and what cost it retains;
- how to prevent a solved, mandatory rotation while keeping the burst satisfying.

The intended identity is **voluntary commitment for exceptional output followed by vulnerability**, not a universally correct cooldown button.

## Evidence needed from future tests

Current completion logs and cast totals cannot establish this vision by themselves. Future playtests should pair player comments with:

- successful casts, hit rate, targets hit and damage by source;
- healing, damage prevented, aggro diverted and cooldown time saved for utility tools;
- energy spent, time ready-but-unused and time active for toggles/stances;
- common ability sequences by threat type rather than one global usage total;
- deaths or major damage shortly after a committed action;
- the player's stated reason for using or withholding each tool.

Treat an ability as a balance concern when its measured behavior and the player's explanation agree. A low cast count alone may mean the relevant situation never appeared; a high count alone may reflect short cooldown rather than meaningful value.

## Current decision boundary

Use this document to interpret the next Vanguard playtest. Do not tune every ability toward equal damage or equal cast count, and do not implement every module alternative at once. First identify which current actions are automatic, which are ignored, and which threat patterns genuinely change the player's plan. Then prototype one tradeoff at a time in Practice before changing campaign progression.
