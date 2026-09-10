# MobaBot.io quality bar

## Human review · 10 September 2026 · commit 02ac283

Follow-through: owner approved the proposed chest/gate policy, every-round run-only module shop and D/F/1234 EMP scope. The resulting 0.19 pass is technically verified (QA_18, REVIEW_COMBAT_19) and awaits another owner review. No fun ratings increased. In particular, early ordinary bots still lose quickly and the long artificial-health soak remains incomplete; fresh human pacing/mobility judgment is essential. Broad mastery branching and new equipment regeneration remain explicitly deferred.

Owner tested the clean `vanguard-18-pressure-audio` build and reports "so far so great, i like it." Real boss HP is subsequently approved: "I think the HP is good." The earlier one-shot boss concern must not justify another blanket boss-HP increase. Owner finds sustained boss attacking boring, early power growth excessive, orbit too reliable for AFK farming, and fast pursuers the strongest current source of challenge. No numerical quality ratings changed.

Requested next direction, in priority order:

1. **Deliberate progression:** three-times-slower leveling with three paused choose-one-of-three upgrade picks, drawn from QWERDF/MG/hammer. Buy and upgrade the four existing 1234 modules with field credits. Chest-point policy, specialization gate and shop cadence are final clarification items; 71 logged chests make XP-only tuning insufficient. Weaken early orbit; reduce early D endurance toward five seconds and improve toward roughly 80% late uptime; F starts at one charge and gains its second at rank five.
2. **Earned combat openings:** preserve real boss HP; improve movement, offensive pressure and readable projectiles/bombs/turning laser. Explore W-center stun and brief vulnerability, E-to-hammer follow-up and delayed R; tune their combined burst rather than blindly stacking every suggested multiplier. Differentiate fragile swarms, praised fast pursuers, faster lunges, melee tanks and durable/evasive ranged units. Favor thicker Practice-style terrain. Boss atmosphere, adds and pursuit are desired; arena enclosure is optional. A slow tanky EMP emitter should have a clear warning/source and roughly three-second suppression; exact affected tools awaits clarification.
3. **Less inspection, clearer payoff:** peer Round clear / Build / Mastery / Equipment tabs and multiple reward columns. Owner finds mastery/equipment visually overwhelming but stats underwhelming. Defer the broad mastery rewrite (one entry, gradual two/three-way branching) until this combat review; preserve equipment and assess noticeable same-slot tier improvements and regeneration benefits.

Evidence: two new finalized results after the visible 01:55 PDT launch. The later A0 result ended at Stage 1 round 3, level 17, 766 kills, 71 chests, with Q/W/E/R/orbit at earned rank 10. Orbit accounts for about 24% of recorded source damage. This supports investigating reward acceleration and passive contribution; it does not establish per-round DPS or causal skill superiority. Fresh versus Continue was not confirmed, so cumulative time/damage must not be presented as fresh-run DPS. The owner supplied a round-clear screenshot showing a narrow scrolling reward column beside substantial unused width.

Acceptance for next owner review: upgrades are manageable without losing intended growth; mobile bosses reward aimed combo setup and force purposeful escapes; fodder remains satisfying while specialists survive or evade appropriately; camp rewards are readable without routine scrolling. Repeated impact polygon rendering errors were observed in this human session and require a technical fix independently of these subjective goals. Owner ended feedback and authorized implementation after the final directional questions; no gameplay changes were made during the test.

10 September 2026, pressure/audio owner request: survival felt too long at three minutes; stronger enemies and clearer health/resource feedback were requested. Now testing two minutes, three specialist roles, round-based growth and distinct injury/supply/rejection sounds. Acceptance: can the owner identify and respond to each specialist; do later rounds stay threatening without excessive health padding; can low energy be recognized without looking away; do pickup chains remain satisfying beneath injury/telegraph cues? Automated behavior/PCM/voice-limit checks and rendered inspection are separate from listening and human fun judgments. Dated ratings remain unchanged.

10 September 2026, reward-clarity owner feedback: chest opening appeared to show only the box, with no outcomes; field-credit purpose and shop timing were unclear. Implemented exact reward receipts, gear-first icon/count presentation, skippable/reduced-effects reveal, and a shop after each Vanguard stage. Acceptance questions: can the player identify their item/point/credit gains without opening another menu; do reveals avoid concealing threats; is the stage shopping cadence useful without becoming a chore? Automated accounting/UI checks and actual-size inspection pass separately from these still-pending human judgments. Existing numeric ratings are unchanged.

Version 1 · 8 September 2026 · baseline: 0.15. This is an editable review contract, not another in-game menu. The owner's ratings and priorities override the assistant's taste. Preserve dated snapshots when changing a criterion so that moving the goalposts does not look like progress.

## North star

9 September 2026, owner playtest: Stage 1 is reported as very fun; Stage 2 suddenly too easy and bosses too weak. Build played was not independently confirmed. Preserve this positive human observation rather than treating earlier naive bot losses as a verdict on fun. New stage-scaling coverage and a requested ×50 boss-health experiment need human review for pressure versus excessive fight length. Equipment gains clearer names and tier glow/pips. No numeric ratings inferred from this feedback or from passing tests.

9 September 2026, tower/progression follow-up: owner requests visible and functional 5/10 milestones, freer point spending, slower XP and broad rank-five progression before specialization. Native tower hardware and mobility/support milestones are implemented and technically checked. One-third XP plus the gate causes a severe regression in the simple fixed-seed Vanguard bot's early survival; retain this warning for the next human test rather than increasing a balance/fun score. Pickup coalescing has a synthetic CPU benefit; no rendered FPS improvement is yet established.

9 September 2026, owner feedback: painted icons currently feel too detailed/high-quality relative to the game world. Trial 32px pixel sampling with gently muted color, without deleting originals. Also requests smaller adjustable HUD and activity cues instead of module status text. Implementation and rendered checks are complete; owner judgment of the new style and readability is pending. Existing numeric ratings remain unchanged.

9 September 2026, Vanguard-only animation review: owner requests an explicit maturity assessment and a polished style candidate before other kits. `VANGUARD_ANIMATION_REVIEW_18.md` records qualitative per-animation judgments, preserved strengths, implemented motion and remaining gaps. Q/orbit were relatively mature; W/R identity, E contact and static support units needed more work. Reserve/Overclock clarity and directional chassis posing still need maturation. Fresh tests/captures do not raise the numeric baseline or imply owner approval.

9 September 2026, rank-power owner feedback: rank 5 should feel roughly twice as capable as rank 1, and rank 10 another two-to-three times stronger including reach and ease of use. Implemented a measured Vanguard curve, separate hammer progression, milestone geometry/mobility and native animation accents. Review questions: can the player recognize 1/5/10 without reading a number; does rank-10 moving hammer feel responsive; do hostile attacks remain legible during upgraded impacts? Automated tests and screenshot inspection do not establish these answers. All dated numeric ratings remain unchanged.

9 September 2026, post-Vanguard owner feedback: current presentation feels mobile-like. Follow-up direction is a restrained PC-first HUD refinement, not a wholesale art replacement. The owner also requests optional Practice hit numbers and per-dummy burst/DPS with a three-second no-hit reset. Technical verification is separate from whether these changes feel clearer; all existing numeric ratings remain unchanged pending playtesting.

### 0.18 integrated rewrite · 9 September 2026

Owner authorized a larger integrated build before the next review. Implemented Vanguard's fixed kit, non-modal learn/upgrade queue and isolated dock/placement Practice workflow. Verification is recorded in QA_18 separately from human experience. **All historical numeric ratings below remain unchanged.** No new human review or listening session has occurred. The highest-priority questions are hammer exposure versus reward, D's held lockout, blink corner outcomes, noticing pending upgrades without distraction, and learning modules without a modal explanation. Current native effects establish timing and geometry but are not an artist-polished animation pack; Practice obstacles remain deliberately greybox. Marshal/Racer/economy work cannot inflate the delivered scope.

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

The same later feedback asks for an afterimage and dedicated sound on D, and a teleport smoke-poof and dedicated sound on F. At that point it also proposed a 1–4 row with a paired-robot zap line; later same-day direction moved relay-pair geometry exclusively to Marshal and replaced Vanguard slot 4 with the cooldown/energy totem recorded below. This dated sequence remains in [ABILITY_FEEDBACK_17.md](ABILITY_FEEDBACK_17.md); none of it raises skill impact, audio or build-depth scores before implementation and playtesting.

Further feedback on 9 September makes the player's autonomous machine gun a permanent, independently upgradable passive that is not learned or unequipped. Holding Ghost drive blocks active abilities and the manual basic attack while that gun and all other passives continue. Piston thrust is now the leading default E proposal: an approximately eight-second collision dash with ordinary-enemy push, base touch-only protection, rank-5 stun and rank-10 full immunity during the dash plus one second after impact. Damage-source typing and the alternative E comparison are recorded in [ABILITY_FEEDBACK_17.md](ABILITY_FEEDBACK_17.md); none is implemented or scored as experienced yet.

All 9 September owner directions are consolidated for the next development/playtest session in [OWNER_PLAYTEST_REQUEST_17.md](OWNER_PLAYTEST_REQUEST_17.md). Swarm-inspired hypotheses and their non-copying boundaries are researched separately in [SWARM_DESIGN_RESEARCH_17.md](SWARM_DESIGN_RESEARCH_17.md). These handoffs organize future work; they do not alter the retained scores or current implementation record.

Later owner feedback on 9 September requests research into a deliberately mediocre Robot AI mode for farming manually proven lower ascensions/easier stages. The intended build split is low-input reliability, magnets, drop rate and survivability for farming versus damage potential and manual outplay for level pushing. At that point the owner had not selected visible autoplay, background repeat or offline simulation, nor an unlock gate or reward policy; the subsequent same-day paragraph below records the later selection. Preserve the concept and research questions in [OWNER_PLAYTEST_REQUEST_17.md](OWNER_PLAYTEST_REQUEST_17.md); do not implement or raise progression scores before those economic and transactional choices are reviewed.

The owner subsequently locks the proposed first/default kit as a static all-rounder and defers cross-kit ability swapping. Three additional identities are requested for brainstorming: a summon-network kit with mirrored casts and position swaps, a geometric reaction/combo kit, and a speedster with intentionally partial high-speed uptime. The assistant proposals in [KIT_DESIGN_BRAINSTORM_17.md](KIT_DESIGN_BRAINSTORM_17.md) are not owner-approved specifications and do not raise build-depth or combat scores. The current playable build still follows `QA_17.md` until a migration is explicitly requested, implemented and tested.

The owner's next 9 September notes park the combo kit, name the summon-network character **Marshal** and simplify its kit. Relays normally acquire within X but can use a shared target out to their own 3X limit; player basics trigger substantial separate-clock relay shots; Q fires maximum-range exploding missiles from every body; W pulses EMPs at relays; E times shocks across relay pairs; and Overclock increases firing/missiles while body transfers sacrifice the abandoned relay with a 10-second redeploy wait. Slots 1–3 use one press plus left-click to reposition or a second key press to transfer control, and their compatible robot bodies carry distinct projectile tools. Preserve exact owner wording, assistant guardrails and unresolved cases in [RELAY_MARSHAL_DESIGN_17.md](RELAY_MARSHAL_DESIGN_17.md). None of this changes current scores before implementation and playtesting.

The owner then approves **Vanguard** as the default class name, removes its paired zap robots and reserves relay-pair geometry for Marshal. Vanguard slot 4 becomes a short-lived cooldown/energy totem, initially proposed at five seconds of doubled cooldown recovery and unlimited energy on a 15-second cooldown. At that point its aura requirements, cooldown start and charge behavior remained unresolved; the subsequent same-day paragraph below records the later aura/cooldown decisions. The assistant recommends a simplified **Racer** speed-window concept as the third current class to explore, but that class is not locked or playtested. Preserve this direction without changing current quality scores.

The owner also bookmarks a later visual-direction discussion: compare the current robot perspective with a true top-down presentation and explore a small directional animation set, potentially using Astra on the home computer. This is not approval to replace current assets or evidence that generated animation is coherent. Review representative motion at actual combat size and Reduced effects, preserve provenance and retain the current art/animation scores until the owner selects and playtests a direction.

The owner additionally requests a Practice cleanup informed by League of Legends, BTD6 and other sandbox modes: a live left-side UI for complete loadouts, focused stats and enemy selection; mouse placement; and one small test map with a few substantial large and medium rocks. Research and a phased proposal are recorded in [PRACTICE_SANDBOX_RESEARCH_17.md](PRACTICE_SANDBOX_RESEARCH_17.md). This is not implemented and does not raise UI, maps, build-depth or reliability scores. Preserve the current Practice isolation contract while prototyping, and require a fresh owner usability test before scoring the redesign.

Subsequent same-day owner decisions narrow several open branches. Practice normally selects a fixed class; legacy and unreleased content stays labeled and confined to Practice until explicitly released. Vanguard's cooldown/energy totem requires standing in its aura and begins cooldown after expiry; moving its healing totem resets stored healing. Aggro-drawing constructs are tanky and destructible, while non-aggro constructs are untargetable and expire. Racer is approved only for careful experimental exploration with a movement-first stop gate. Visible Robot AI is selected at approximately 75% strength with simplistic play, alongside separate slow offline salvage capped at 48 hours/about three last-cleared-level runs. These decisions and the future `C` consumable bookmark are documented in [OWNER_PLAYTEST_REQUEST_17.md](OWNER_PLAYTEST_REQUEST_17.md), [RACER_EXPERIMENT_17.md](RACER_EXPERIMENT_17.md), [ROBOT_AI_MODE_17.md](ROBOT_AI_MODE_17.md) and [TERMINOLOGY_PRESENTATION_17.md](TERMINOLOGY_PRESENTATION_17.md). They remain unimplemented and do not change any current score.

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

9 September, interface follow-up: the owner chooses Painted-only, requests painterly MOBA-inspired Vanguard QWER icons and prefers 128px or smaller runtime assets. Four generated paintings replace Vanguard's UI mappings; imports are 128px, with source provenance and actual-size normal/reduced HUD captures. Q/W have the clearest directional separation; E/R are denser and remain pending owner review. Settings/Practice are further pruned and minimap/locked-edge camera controls are tested independently. These are implementation/inspection observations, **not a new human quality score**. Physical mouse sensitivity/confinement across different DPI and monitors still needs hands-on testing.

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

9 September 2026: owner says the generated QWER icons are much better and selects this painterly Dota/LoL-inspired direction for the rest of Vanguard. This is positive art-direction feedback, not a numeric score for combat motion or the whole game. Eight additional UI paintings extend the approved style; their individual recognition/preference remains pending. Retain prior numeric ratings.

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
# 10 September 2026 · queued progression feedback and 0.19.1 follow-up

Owner's further direction: introduce enemies gradually, retain the good feel of the previously tested Stage 1, simplify cards to changed numbers, and separate short-lived combat builds from slow equipment growth. Numbered replayable chapters, 2–5-round attempts, separate currencies, crates, permanent mastery and carried potions were brainstorming; the owner explicitly expressed uncertainty about the overall structure. Requested research of Vampire Survivors, Survivor.io and Swarm and completion of the remaining feedback work.

Implemented independently: numerical card deltas; 13-node mastery with one starting point and three branches; mid-tier helmet/chest regeneration; EMP delayed to Stage 2; visible boss overload; bounded interval progression samples. Research and a concrete Chapter/Operation proposal are in PROGRESSION_RESEARCH_20. One directional question remains unanswered about replacing the route/reset/economy structure. No invented approval or claim that speculative systems are playable.

Theoretical damage work corrected a missed 1.2 W multiplier in the prior reference table. Current unchanged long-route boss HP receives a five-minute deadline before escalating physical threats, not a scripted game-over. Tests pass, but the artificial-health soak still stops at its budget in round 21. Early normal bots still die quickly. No new human playthrough, improvement to fun scores or audio verdict is implied. Previous dated ratings and owner approval of real-boss HP remain intact.
# 10 September 2026 · Chapter Operations working implementation

Owner requested status and said to keep going. Continued with the explicitly stated Chapter/Operation recommendation as the working review version, following the request to complete feedback and research. No selected answer to the earlier optional direction question is claimed. Current rules are in OPERATIONS_20; research links remain in PROGRESSION_RESEARCH_20.

Implemented: eight replayable numbered Chapters, three-round build resets, separately named Field credits/Salvage, outside-run equipment crates, transactional first-clear unlocks/rewards, and a short-run XP/boss budget. Core leveling now reaches final-boss entry at levels 23 and 24 in the fixed-seed Chapter 1/8 artificial-health probes, with completion levels 25 and 26. This meets a prototype pacing target in those policies; it does not establish a human distribution. Later-Chapter overload remains a specific human-review risk, and ordinary-health bots still die early.

The earlier positive Stage 1 feedback remains about the previous tested build. Do not claim it applies to 0.20 or increase existing ratings from test success. No additional human playtest, audio approval or fun verdict has occurred. Optional potions, permanent mastery, random ability permissions and additional unique enemy/boss assets remain future design choices rather than silently expanding the reward pool.
