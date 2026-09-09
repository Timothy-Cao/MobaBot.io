# MobaBot.io quality bar

Version 1 · 8 September 2026 · baseline: 0.15. This is an editable review contract, not another in-game menu. The owner's ratings and priorities override the assistant's taste. Preserve dated snapshots when changing a criterion so that moving the goalposts does not look like progress.

## North star

**Turn a small salvage robot into an outrageous machine through choices you can feel, while movement, aiming and danger remain readable.**

The desired rhythm is approach → aim or reposition → mechanical payoff → collect → choose an improvement → feel the difference. Automatic fire supplies continuity; it must not make positioning and active skills irrelevant. Low-execution builds should work, but intentional play should buy a visible advantage. Spectacle is earned by impact and growth, not by filling the screen with particles.

Three priorities, in order:

1. Agency and clarity: my input works, I understand what happened, and I have a useful response.
2. Power and reward: my machine changes substantially, its tools feel different, and collecting the result is satisfying.
3. Cohesion and restraint: machinery, motion, icons and menus belong together; details appear when needed.

## How to score

Use whole numbers, not false decimal precision. Scores are subjective judgments with evidence, not percentages complete. A large catalog and a high assertion count do not equal a good game. Do not average away a weak core loop.

| Score | Anchor |
| --- | --- |
| 0 | Missing |
| 2 | Present but unreliable, confusing or obstructive |
| 4 | Functional, visibly raw; needs substantial design/presentation work |
| 6 | Coherent, usable prototype; recognizable intent, important gaps remain |
| 8 | Strong demo quality, supported by repeated human playtests |
| 10 | Exceptional reference-quality execution, sustained across the game |

Keep three separate records: **implemented** (what exists), **verified** (what tests/inspection demonstrate), and **experienced** (what players actually felt). For experiential categories, do not award 8+ solely from code review, screenshots or bots. “Unrated” is better than inventing an audio or play-feel verdict. Confidence below means confidence in the assessment, not confidence that a feature is finished.

Release gates: no known save-loss bug; no repeatable stuck movement; no misleading damage boundary; no hidden critical damage tell; no UI trap; no recurring script errors. A failed gate blocks a demo recommendation regardless of scores. This is a target policy, not a claim that exhaustive testing has established zero bugs.

## 0.16 owner feedback and follow-up · 9 September 2026

### 0.17 follow-up · 9 September 2026

Owner feedback: Q and the channeled laser feel good; other actives lack impact and passive states are unclear. Rounds feel short, levels too frequent, collection ends too abruptly. Owner requests no classes, lasting skill ownership and an isolated Practice tool. This is direct evidence of remaining pacing/identity gaps, not a reason to raise scores.

Additional description-only feedback on 9 September proposes functional ability taxonomy research, fixed Q/W/E/R identities, learned-ability inventory/loadouts, a narrower initial test roster and specific direction for abilities 1–11. Preserve it separately in [ABILITY_FEEDBACK_17.md](ABILITY_FEEDBACK_17.md). It has not been playtested and does not change the current numeric baseline or implemented-behavior record.

Later control feedback on 9 September keeps Ghost drive as the default hold-to-use D movement-speed tool and asks for F to become a full responsive blink. The requested F behavior includes a sub-0.1-second post-cast buffer that moves an unreleased ability's origin to the blink destination, plus far-side correction when a blink endpoint passes the midpoint of thick terrain. Detailed edge cases and required prototype checks are preserved in [ABILITY_FEEDBACK_17.md](ABILITY_FEEDBACK_17.md). These desired mechanics are not yet implemented or human-verified.

The same later feedback asks for an afterimage and dedicated sound on D, and a teleport smoke-poof and dedicated sound on F. It also supersedes the assistant's earlier default module recommendation with an owner-proposed 1–4 row: two-mode orbiting tools, a targetable aggro-drawing attack summon, a stored-healing/overflow totem and a persistent paired-robot zap line. These concepts and their unresolved expiry/redeployment rules remain documented in [ABILITY_FEEDBACK_17.md](ABILITY_FEEDBACK_17.md); they do not raise skill impact, audio or build-depth scores before implementation and playtesting.

Further feedback on 9 September makes the player's autonomous machine gun a permanent, independently upgradable passive that is not learned or unequipped. Holding Ghost drive blocks active abilities and the manual basic attack while that gun and all other passives continue. Piston thrust is now the leading default E proposal: an approximately eight-second collision dash with ordinary-enemy push, base touch-only protection, rank-5 stun and rank-10 full immunity during the dash plus one second after impact. Damage-source typing and the alternative E comparison are recorded in [ABILITY_FEEDBACK_17.md](ABILITY_FEEDBACK_17.md); none is implemented or scored as experienced yet.

All 9 September owner directions are consolidated for the next development/playtest session in [OWNER_PLAYTEST_REQUEST_17.md](OWNER_PLAYTEST_REQUEST_17.md). Swarm-inspired hypotheses and their non-copying boundaries are researched separately in [SWARM_DESIGN_RESEARCH_17.md](SWARM_DESIGN_RESEARCH_17.md). These handoffs organize future work; they do not alter the retained scores or current implementation record.

Later owner feedback on 9 September requests research into a deliberately mediocre Robot AI mode for farming manually proven lower ascensions/easier stages. The intended build split is low-input reliability, magnets, drop rate and survivability for farming versus damage potential and manual outplay for level pushing. The owner has not selected visible autoplay, background repeat or offline simulation, nor an unlock gate or reward policy. Preserve the concept and research questions in [OWNER_PLAYTEST_REQUEST_17.md](OWNER_PLAYTEST_REQUEST_17.md); do not implement or raise progression scores before those economic and transactional choices are reviewed.

The owner subsequently locks the proposed first/default kit as a static all-rounder and defers cross-kit ability swapping. Three additional identities are requested for brainstorming: a summon-network kit with mirrored casts and position swaps, a geometric reaction/combo kit, and a speedster with intentionally partial high-speed uptime. The assistant proposals in [KIT_DESIGN_BRAINSTORM_17.md](KIT_DESIGN_BRAINSTORM_17.md) are not owner-approved specifications and do not raise build-depth or combat scores. The current playable build still follows `QA_17.md` until a migration is explicitly requested, implemented and tested.

The owner's next 9 September notes park the combo kit, name the summon-network character **Marshal** and simplify its kit. Relays normally acquire within X but can use a shared target out to their own 3X limit; player basics trigger substantial separate-clock relay shots; Q fires maximum-range exploding missiles from every body; W pulses EMPs at relays; E times shocks across relay pairs; and Overclock increases firing/missiles while body transfers sacrifice the abandoned relay with a 10-second redeploy wait. Slots 1–3 use one press plus left-click to reposition or a second key press to transfer control, and their compatible robot bodies carry distinct projectile tools. Preserve exact owner wording, assistant guardrails and unresolved cases in [RELAY_MARSHAL_DESIGN_17.md](RELAY_MARSHAL_DESIGN_17.md). None of this changes current scores before implementation and playtesting.

The owner then approves **Vanguard** as the default class name, removes its paired zap robots and reserves relay-pair geometry for Marshal. Vanguard slot 4 becomes a short-lived cooldown/energy totem, initially proposed at five seconds of doubled cooldown recovery and unlimited energy on a 15-second cooldown. Its own cooldown must not self-accelerate; aura requirements, cooldown start and charge behavior remain unresolved. The assistant recommends a simplified **Racer** speed-window concept as the third current class to explore, but that class is not locked or playtested. Preserve this direction without changing current quality scores.

Additional terrain feedback on 9 September says the current obstacles read as basic walls without enough substance or thickness. The owner wants a simple future exploration of thick long forms, partially natural/partially rigid clusters, corridors, more enclosed-feeling pockets and a possible large circular form with four entrances, using League's PvE maps and other top-down shooters as inspiration. Preserve the detailed direction and its unresolved alternatives in [ENVIRONMENT_FEEDBACK_17.md](ENVIRONMENT_FEEDBACK_17.md). This does not raise the current maps score or supersede `QA_17.md` before implementation and playtesting.

Implemented: longer phases, slower XP, collection grace, heavier commanded attacks, six close-range buffs, native cast/recoil changes, explicit passive states, three ranged threats, wider-spread cover, skill storage, Practice, toggle Tab and layered menu animation. Verified separately in QA_17. **Retain the numeric baseline below.** Most important unproven questions are whether three-minute rounds sustain interest and whether attack commitment earns its risk. A full-route artificial-health soak takes 74 simulated minutes, excluding menus. That is a warning to evaluate run length, not a retention success. The 49-skill review sheet gives the owner a way to prune weak skills.

### Retained 0.16 note

Owner feedback: the current enemy difficulty feels good; Stage 1's boss was reached. The requested changes prioritize flexible in-run skill placement, simpler forging, richer optional icons, smaller interruptions and immediate resource visibility. Treat this as positive evidence for the early challenge, not approval of all classes or the full expedition.

Implemented in this pass: keyboard placement/swapping, five-tier three-copy forging, 89 Painted icons with Base retained, compact power-up choices, reward reveals and above-player bars. Verified separately: checkpoint/transaction fixtures, key/rank/cooldown preservation, actual-size icon sheets, rendered menus and artificial combat probes. The 0.16 experience has not yet been reviewed by the owner. Keep the numeric baseline below unchanged until that feedback; more assets and assertions do not warrant higher fun scores.

Assistant judgment: the equipment presentation and high-level silhouettes are more coherent. Some neighboring skills still have similar silhouettes (Reactor drop/Core strike and Ghost drive/Veil dash), and the Painted-to-native-world detail gap remains. Keyboard placement adds one deliberate decision to discovery; whether that trade is pleasant needs timing in real play. Reward motion is an initial short native reveal, not a cinematic loot sequence. The full-route class probe strongly favors the Brawler under one deterministic policy; do not mistake this for calibrated human difficulty.

Next three review targets: (1) discover, place and swap a skill without instruction; (2) compare icon recognition in Painted/Base during a busy first boss; (3) record active combat time versus choice time and compare Gunner/Brawler/Engineer before changing enemy damage. Separately, test the long-term forge grind: 3:1 fusion implies 81 tier-1 copies for a tier-5 item if no higher-tier drops occur. Existing higher-tier drops shorten that, but a healthy retention loop is not yet demonstrated.

## 0.15 baseline assessment (retained)

These are assistant estimates following code review, deterministic render fixtures and regression tests. There has been **no new human playtest or listening session** in this pass. Leave the last column for the owner; it is intentionally not pre-filled.

| Aspect | Mine /10 | Confidence | Evidence and limiting factor | Yours /10 |
| --- | --- | --- | --- | --- |
| Controls and agency | 6 | Medium | Independent gun, commanded basics, stop, attack move, aimed/recast skills and camera controls exist and are tested. Tight-corner kiting and channel steering still need human judgment. | — |
| Skill motion and impact | 6 | Medium | Distinct blades, inward pulls, strike descent, cuts, dash trails and construct action. Several effects still rely on shared primitives; full-build clutter and perceived weight remain unproven. | — |
| Art identity and icon recognition | 6 | Medium | One native material family; this pass separates repeated skill silhouettes. Hero/enemies remain simple and the richer title painting is not identical to world rendering. | — |
| Combat readability | 6 | Medium | Ground geometry follows ranges; important impacts can displace cosmetic effects; hostile tells retain priority. Real players have not demonstrated reliable threat/death recognition in late combat. | — |
| Enemies and bosses | 5 | Medium | Different pressure roles and boss pattern configurations exist. Eight bosses reuse one industrial body; distinctive identities and memorable counterplay are insufficient. | — |
| Maps and encounter variety | 4 | High | Barriers, sectors and a complete route work. Three visual sectors repeat over eight stages; too much progression is numerical rather than environmental. | — |
| Build choices and skill depth | 6 | Medium | Aimed, timed, recast, movement and summon decisions support different play styles. Catalog breadth exceeds evidence for balance; dominant and dead choices likely remain. | — |
| Power growth and pickups | 6 | Low | Milestones change real geometry; chests, scattered rewards and collection feedback exist. Their emotional payoff and visual tier recognition need a player, not a formula. | — |
| Run pacing and permanent progression | 5 | Low | Abilities/mastery reset; equipment persists; route, shops and checkpoints work. Interrupt frequency, discovery pacing, grind pressure and run length are not validated. | — |
| Menus and information hierarchy | 6 | Medium | Pruned navigation, icon-first inspection and tested label widths. Long collections/tree navigation and small text still need unprompted usability testing. | — |
| Sound and music | Unrated | Low | Synthesized cues and supplied music are integrated. No listening verdict in this pass; voice limits alone do not prove a pleasant mix. | — |
| Performance and visual stability | 6 | Medium | Bounded effects and deterministic simulation tests; rendered fixtures on RTX 5070. No representative low-end GPU or crowded full-game frame-time certification. | — |
| Reliability, saves and delivery | 7 | Medium | Broad mechanics/UI regression, isolated fixtures and full-route soak. Packaged Windows export, clean-machine startup and extended manual save/reload testing remain. | — |

**Overall judgment: promising, coherent prototype; not yet a polished public demo.** No numeric average. The weakest structural areas are encounter identity and pacing, not missing abilities. The art pass improves communication and consistency; it does not create a new set of character animations or unique boss assets.

## Acceptance criteria for the next stronger version

The numbers below are our proposed project targets, **not industry benchmarks or measured results**. Adjust them after the first owner review. Use three fresh players for an initial signal, then broaden the sample; three people are not statistical proof.

| Aspect | Concrete acceptance exercise | Proposed bar |
| --- | --- | --- |
| Controls | Kite around barriers; cancel movement; aim Q; steer/cancel R; toggle gun; pan/recenter camera for ten minutes | No stuck/jittering movement or unintended casts; S never disables independent gun. Valid inputs show feedback within two rendered frames at 60 FPS, apart from intentional cast delays. |
| Skill identity | After a short introduction, show unlabeled combat clips at normal zoom | At least 8/10 correct identifications of pull, push, cut, delayed strike, movement and summon roles. Judge silhouette/motion, not color alone. |
| Impact hierarchy | Watch gun → Q → rank-5 active → ultimate in a crowd | All three players distinguish basic fire from active payoff and identify the strongest event without losing the player or threat. No full-screen white flashes. |
| Milestone growth | Compare rank 0, 5 and 10 with rank text hidden | Players identify the upgraded version in at least 8/10 pairs and can describe a functional difference. Cosmetic size may never exaggerate damage reach. Duration-only upgrades need truthful duration feedback, not a fake larger hitbox. |
| Threat fairness | Review ten damaging/death events, including boss overlaps | Players correctly explain at least nine; at least one reasonable avoidance/mitigation decision existed. An unavoidable burst is a defect, not “challenge.” |
| Boss identity | Play the first three boss encounters | Each earns a distinct mechanic description and asks for a different response; increasing HP or tint alone does not qualify. |
| Builds | Play aimed ranged, low-execution sustain and summon-centered starts | Each has a recognizable advantage, weakness and meaningful upgrade choice within the first three rounds. No mandatory single discovery or passive-only universal answer. Do not require equal win rates from a tiny sample. |
| Rewards | Compare collecting ordinary drops, an elite burst and a chest | All players recognize the reward tiers and enjoy at least one pickup event without an explanation. Magnet upgrades reduce collection friction without removing movement incentives. |
| Pacing | Record a first-stage session, then a complete A0 run | First clear power change within two minutes; first three rounds show substantial growth. Log combat vs paused choice time and repeated menu visits. Initial warning threshold: over 25% of experienced-player run time in mandatory choice screens. |
| Permanent progression | Start on an empty profile, then replay with modest gear | A0 is learnable without mandatory grinding; gear opens options and easier farming without invalidating danger. Do not tune this using artificial-health soak results. |
| UI | Ask “change a skill,” “compare boots,” “spend a tree point,” and “find controls,” without directions | Each task found within 20 seconds; no clipped cost, unlabeled lock or unexplained failed transaction. Inspect at intended window sizes, not only logical 960×540. |
| Audio | Headphone and speaker sessions: ordinary wave, elite burst, boss, menus | Clear cue hierarchy, no clipping/fatiguing pickup chatter, no accidental music restart; mute/volume work. Owner approves the mix before assigning a score. |
| Performance | Profile real rendered play with HUD, audio and a dense late build on a named baseline machine | Target 60 FPS: p95 frame interval ≤16.7 ms, p99 ≤25 ms during a defined ten-minute sample; investigate sustained misses. Headless simulation timings are not GPU frame timings. |
| Reliability | Fresh export, full run, checkpoint resume, malformed-save recovery, inventory transactions | Zero known crashes, irreversible save loss or softlocks; transactions preserve funds/items on failure. Test on a clean Windows machine before public distribution. |

## Per-skill art and animation checklist

Review at actual HUD size (32/48/64 px), default combat zoom and maximum zoom-out, then with overlapping enemies and Reduced effects. A magnified screenshot is not acceptance. A shared style does not mean the same drawing with a new color.

1. **Identity:** one recognizable function silhouette; distinguish closest neighbors before adding detail.
2. **Motion sentence:** direction/setup → contact or activation → readable follow-through → clean disappearance. Instant skills get immediate response, not an added gameplay windup to make art prettier.
3. **Geometry honesty:** range, width, inner/outer payoff and lifetime come from the simulation. Decorative trails are not target previews. No camera/actor-center shake that separates bodies from collision.
4. **Material consistency:** teal housing, steel working parts, cream edges, limited brass emphasis, graphite seams. Hostile coral/plum remain readable above friendly effects.
5. **Weight:** a selected hard edge, recoil/opening/cut or directional burst sells impact. Avoid solving every attack with a bigger opaque disc.
6. **Growth:** show the actual milestone through geometry, timing or functional attachments. Do not add decorative visual power to a negligible upgrade.
7. **Accessibility:** Reduced effects removes secondary trails/flash and keeps functional information. Inspect motion sensitivity and color-only dependencies manually.
8. **Budget:** bounded effect pools; major feedback displaces expendable hit/pickup particles. Rendering consumes no combat randomness and does not alter gameplay state.

Use four states per skill: needs identity / needs motion / technically verified / player-approved. This pass technically exercises all 34 catalog actives at ranks 0, 5 and 10 in normal/reduced modes. It does **not** certify every passive combination, frame or human recognition criterion.

## Work order after owner feedback

1. Validate the first three rounds: control feel, energy pressure, Q/auto distinction, upgrade payoff and understandable damage.
2. Give the first bosses distinct behavior/silhouettes; improve repeated spaces with encounter-specific geometry. Fewer strong encounters before more catalog entries.
3. Tune discovery/choice interruptions and the first full run. Confirm permanent gear is attractive but not required grinding.
4. Crowd-test VFX; refine weak skill identities and listen/tune the audio mix.
5. Export and clean-machine test only after the above reaches an agreed demo bar.

Do not expand menus to display this scorecard. Do not build a telemetry service, more stages or new progression systems simply to raise an implementation count.

## Owner review

For each aspect, fill **Yours /10** and give one concrete example. A brief play session can answer:

- Which action felt best? Which felt weak or unclear?
- When did you first feel noticeably stronger?
- What hit you that you did not understand?
- Which choice was interesting, and which was a chore?
- What should we improve next: impact, challenge, variety or interface?

Record build, class, ascension and approximate round/time. Disagreement is useful: keep both scores, update the criterion if it missed the intended experience, then retest the same scenario. A score increases only with a named improvement and fresh evidence; tests staying green maintain confidence rather than automatically increasing quality.

## Reference principles

Riot's VFX guide organizes effects around gameplay meaning, shape, color/value and timing, with visual prominence tied to gameplay importance. This informs our family-specific motion and restrained impact hierarchy—not copying League artwork. [League's VFX Style Guide, 2017](https://nexus.leagueoflegends.com/en-us/2017/10/dev-leagues-vfx-style-guide/).

Riot's clarity discussion emphasizes recognition, information hierarchy and avoiding noise, including meaningful silhouettes and truthful hit areas. This supports our small-icon comparisons and collision-aligned boundaries. The numerical acceptance targets and current scores above are our own proposals. [Clarity in League, 2021](https://www.leagueoflegends.com/en-us/news/dev/clarity-in-league/).
