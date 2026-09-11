# Combos, compact upgrades and Conductor Practice · 0.24

11 September 2026. Owner authorized all changes in this slice. Boss overload remains unchanged: standard Operation bosses begin escalating after 180 seconds; there is no instant scripted loss.

## Vanguard combinations

Current `support23` runs and primary Practice gain these controls. Earlier rules without that flag keep their cast restrictions. Hammer base damage, reach, cadence and the existing E follow-up multipliers are unchanged.

- Left click during E buffers one hammer swing. On arrival it becomes a 360-degree hit with the normal inner/head distance bands, existing E-combo multiplier and one hit per enemy. The robot and hammer visibly rotate. Clicking within the existing 1.2-second arrival window also produces the spin. Ordinary swings retain their cone.
- Q during E consumes all currently stored Q charges and adds **110 units per charge** to the remaining travel. It fires no rocket and has no additional energy charge. One fuel action per E; recharge begins normally. Rebounds still use the existing collision sweep and one-rebound limit. No tutorial paragraph was added.
- Flash works during D and E. It ends D/E at the legal Flash destination. E's impact (including rank-five stun/rank-ten shield) occurs there, and a buffered hammer resolves immediately if ready. E → Flash → click retains the arrival combo. Flash during an already-started spin windup resolves it at the new destination. Existing Flash charges, energy and EMP restrictions remain.
- A buffered swing cannot bypass hammer cooldown. If still cooling down at arrival, it waits within the combo window. No repeated swings or automatic Q refueling.

## Compact paused upgrade overlay

Three 224×244 logical cards sit over a 38%-darkened paused arena; HUD and world remain visible. Cards retain only a small icon/name, next rank out of ten, rounded numerical changes and a separate colored milestone line. Values below ten retain at most one decimal to keep cooldown/speed changes useful; larger values round to integers. Ten rank cells show owned ranks, the offered rank and empty ranks; fifth and tenth outlines are gold and purple. Milestone offers gain matching card borders. Full mechanics remain on hover. No save or simulation mutation comes from previews.

## Utility capstone correction

`charge` remains the stable node ID but is now **Head start**, not Spare chamber. It no longer increases Q capacity. Reaching it and banking at camp permanently unlocks **E learned at rank one at the start of future runs**. This was the stated working interpretation of the owner's extra-starting-ability request; the optional clarification received no reply during implementation. Mastery points still reset. Starting E was chosen because it enables the class's movement/attack identity immediately. The new optional profile boolean defaults false for old profiles, validates type, and participates in snapshot/rollback. Practice never grants it. A continued checkpoint retains its learned abilities rather than receiving an extra rank.

## Broader art pass

Native obstacle capsules now have recessed panel seams, vents, circular end hardware and restrained brass markings within the collision silhouette. Energy cells and green repair canisters use distinct reusable silhouettes instead of similar circular glyphs. No wall collision or projectile-cover rule changed. Conductor relays have remaining-life arcs, a faint link preview, delayed discharge boundary lines and cyan/cream strikes. The test body has a muted violet chassis. Existing generated icon masters are reused through the same 32×32 shader; no new generated bitmap claims or provenance entries are needed for code-native geometry.

## Playable second-class experiment

Home → Practice → Build → **Conductor experiment**. Return to Vanguard is in the same place; Reset and rank 1/5/10 selection preserve the experimental selection. It cannot enter a campaign save and cannot earn permanent rewards.

- Q hits a 650-unit electrical line. Crossing one relay forks a 350-unit line at 0.55 radians; a shared hit set prevents double damage to the same enemy.
- W places at most two 12-second relays, replacing the oldest. No passive damage.
- E uses the current collision-safe dash with a departure pulse; passing within 65 units of a relay relocates that relay to the departure point once.
- R consumes two relays and strikes between them after 0.65 seconds; with fewer than two, it uses a 320-unit aimed fallback line. Each discharge hits once.

This is a playable QWER prototype, not a finished campaign class. Hammer, D/F, gun, support modules and rank costs reuse Vanguard's foundation. Dedicated baton design, distinct animations, full per-rank balance and campaign selection remain later class work. The future grapple class is still recorded separately, not implemented. Test whether placing routes produces worthwhile choices before expanding class-specific art.

## Verification and next review

`combo24_test.gd` covers fuel, buffering, rear hits, immediate and post-Flash combos, preview readiness, drive cancellation, Conductor relay bounds and delayed damage, actual Practice selection/reset, capstone malformed-save rejection/rollback and future-run startup. `-- --render` writes ignored card/Practice captures. Full regression and behavior evidence are recorded in QA_18. Human feel remains unverified for this slice. Watch spin coverage, Q-fueled wall rebounds, Flash timing and relay visibility during moving combat.
