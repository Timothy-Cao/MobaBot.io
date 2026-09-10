# Pressure and sound audit

10 September 2026. Implements the owner's latest playtest request; not a new map or ability rewrite.

## Enemy roles

| Enemy | Base HP before campaign scaling | Behavior and answer |
| --- | ---: | --- |
| Breacher | 55 | Approaches quickly; locks direction for .65s, rushes 288 units at 480/sec, then recovers 1.7s. Side-step or use cover; swept contact hits once per rush. Thick walls stop it. |
| Mender | 32 | Keeps distance; telegraphs a repair then heals up to three nearby damaged allies within 230 units. Each gets 8% max HP, capped at 12 × stage-health factor. Cannot heal itself, other Menders, dummies or bosses/guardians. Kill this fragile support first. |
| Scattergun | 45 | .65s locked-direction warning, then seven bullets across a 60° fan. 280/sec, two-second lifetime, one hull-unit base damage each. Three-second recovery. Reposition through the gaps or flank during recovery. |

All three are in Practice → Enemies. Campaign introduces specialists offscreen relative to the **player**, not the detached camera; attacks start only inside the player-centered area. Three specialists early, up to five late; one Mender maximum. Existing Arc lancer, Burst battery and Bomb carrier remain. Materials and native animation follow the salvage-machine style; no downloaded/generated sprite pack.

## Round pressure

120 seconds of survival, then the guardian/boss; 12-second collection unchanged. Full route: 22 rounds / 44 survival minutes, excluding encounters and menus. See BALANCE_16 for exact formulas. Health and damage now grow every route step rather than only at stage boundaries. Speed and specialist count have ceilings. Timed surges retain valleys between pressure peaks; no adaptive director or hidden difficulty compensation was added.

The earlier ×50 main-boss HP setting is unchanged. More pressure plus less farming time is a substantive difficulty increase. No XP/drop inflation is bundled with this request. Review later guardian HP and boss duration especially; automated survival is not a target human win rate.

## Sound audit

| Event | Outcome of this pass |
| --- | --- |
| Player hit | Existing cue retained above half; layered descending motifs below half and quarter. Higher priority/volume than ordinary hits. Post-hit fraction matches visual severity. |
| Empty-energy Q/W/E/R/F/totems or D | Previously some Vanguard paths failed silently. New distinct two-note rejection, at most once per .65s. No charge/energy consumption on failure. |
| Empty charge | Shorter, quieter tick, capped at once per .35s. Intentionally different from empty energy. |
| XP | Existing ascending pickup chain retained; value ≥8 has a short two-note reward cue. Both remain rate-limited. |
| Special supplies | Separate repair, energy, coin and temporary-boost motifs. Removed the second generic equipped sound on collection; its visual event remains. |
| Chest | Dedicated latch/chime sequence plays with actual content notification, replacing generic equipped sound. Receipt/reveal still cannot grant loot. |
| Orbit / gun toggle | Brief mode-change chirp; no ongoing loop. |
| Construct placement | Mechanical latch/rising confirmation for Bulwark, Reserve and Overclock. |
| Specialist tell/fire/heal | Restrained warning/fire/repair cues. Threat-start cues are protected and capped at once per .45s. Ordinary enemy attacks keep visual tells. |
| Guardian kill / round clear | Guardian kill maps to the existing boss-down cue. Actual camp transition now emits the existing clear cue. |
| Q/E/W/R impacts, hammer, gun, blink, drive | Existing differentiated cues retained. No blanket volume boost. |
| UI focus/confirm, death, boss phases, milestones | Existing cues retained. |
| Music | User-provided music and context selection unchanged. No new soundtrack or extra settings. |

Injury, energy failure, boss/milestone and threat-start cues use three reserved voices; ordinary hit/kill/pickup sounds use the other nine. Mute stops every voice. Critical injury uses −9 dB player gain, ordinary injury −11 dB, autonomous gun remains −27 dB; these gains are implementation values, not calibrated perceived loudness. Short tones use attack/release envelopes and bounded PCM amplitude; sample clipping tests do not prove the complete music/SFX mix cannot mask a cue.

Deliberately deferred until listening: optional bus ducking, positional stereo threats, subtle ability-ready cues, distinct shield-break/construct-destruction cues, and richer recorded impact layers. Adding a cue to every cooldown or ongoing aura would risk constant noise. No promise that the synthetic motifs are final production audio.

## Health visuals

Below .5 after damage: brief amber edge/corner accent. Below .25: stronger coral edge plus heavier hit sound; small critical corner marks remain until healed. Exact .5 is normal and exact .25 is the lower warning tier. Reduced effects removes glow and reduces stroke width, but preserves the information. No added camera shake, zoom, strobe, blur or central text. Feedback ignores input and clears in menus.

## Research rationale

[Riot's sound-design primer](https://www.riotgames.com/en/artedu/sound-design) emphasizes audio as information about actions and the surrounding game. [Riot's clarity discussion](https://www.leagueoflegends.com/en-us/news/dev/ask-riot-let-s-talk-clarity/) also acknowledges that loud or frequently repeated sounds can distract players, and that player feedback drives mix revisions. Our adaptation is distinct event families, reserved critical voices and repeat limits—not copying their sounds or treating loudness as quality.

[Valve's Left 4 Dead AI presentation](https://cdn.fastly.steamstatic.com/apps/valve/2009/ai_systems_of_l4d_mike_booth.pdf) is a pacing reference for alternating pressure rather than an ever-growing constant crowd. We retain scheduled surges; this is not an implementation of Valve's adaptive AI Director.

## Verification and owner review

`pressure_feedback_test.gd`: per-round monotonicity, 120s boundary, specialist phase/collision/heal limits, Practice/camera isolation, projectile capacity, actual damage payload, failed-cast conservation, exact threshold mapping, PCM duration/peaks, protected voices, cooldown throttling and mute. `-- --render` produces ignored actual-size normal/reduced screenshots. Existing skill visual tests still protect ability geometry.

`expedition_behavior_probe.gd -- --vanguard`: fixed-seed ordinary policies remain a comparative diagnostic. `-- --vanguard --soak` now explicitly adds 100,000 test-only max health and refills it; previous normal-health refill could die to multiple same-frame hits. AI/damage/terrain/resource logic stays active, no equipment collection is written, and the output flags artificial health. A successful soak proves route exercise, not human balance.

Final evidence: all 27 `check.ps1` suites pass; pressure/audio fixture has 145 checks. Both refined compatibility probes and the legacy class probe complete without engine errors. The amended A5 Vanguard soak **does not complete the full route**: it reaches round 20 (Stage 7 boss) at its 7,999.4-second simulation cap, state `running`, 15,247 kills, level 76, peak 180 enemies. p95 simulation step 1.794 ms, maximum 21.553 ms on this machine; not a rendered FPS guarantee. No engine error is logged, but a complete uninterrupted 22-round soak remains unverified. The existing 50× boss HP budget and this limited bot's damage uptime make late boss duration a major pacing risk. We did not silently reduce boss HP in a request for stronger enemies.

For owner testing: try each specialist in Practice, then one new expedition. Report whether Breacher feels dodgeable, whether Mender is recognizable, what killed you, whether low-energy and pickup cues are distinct, and whether the first two stages now require useful decisions without becoming exhausting. The assistant has inspected rendered output and automated audio properties; perceptual listening and fun ratings remain open.
