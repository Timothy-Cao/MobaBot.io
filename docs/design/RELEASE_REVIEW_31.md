# Windows playtest 0.31.0-test.1 — readiness review

12 September 2026. Owner authorized pushing all changes and publishing a newer Windows release before an official human playtest. Source includes the three factory layouts, five-minute rounds, encounter changes, pickups and foundry visual pass. Packaging uses the established export_windows.ps1 workflow.

## Fixed during release review

Menu version now comes from project release metadata (0.31.0-test.1), matching Windows executable metadata 0.31.0.0. Result records include release_version and current factory31 build identity. Removed the legacy “0 / 2 wardens” HUD objective from expedition campaigns. Export smoke now verifies the current factory rule and all three map layouts in addition to Practice, icons, music and projectile loading. No balance changes.

## Remaining weaknesses / official playtest focus

1. Level 3 crowd pressure and rendering cost: latest artificial-health run reached 175 enemies. Prior synthetic 180-enemy rendered frame cadence was about 48ms median on this desktop; those measurements include script/engine/frame pacing and predate the lower-prop factory layouts. They do not establish a GPU limit or current human FPS. Review late-round hitching and readable tells.
2. New route behavior is not human-approved: coarse connectivity and all-level completion pass, but lane corners may bunch enemies or make some ranged attacks awkward. Test Assembly crossovers and Cooling inner/outer routes, including Flash/E around machines. Projectiles intentionally pass through walls; machinery is not projectile cover.
3. Pacing and durability remain uncertain: five-minute survival rounds can feel sparse early or punitive later. The latest local untagged-as-automated result (2026-09-12 01:37:05, older vanguard-27 rules) lost Level 1 at 212.93s, player level3. It predates factory31 and cannot validate or condemn this release; equipment and player intent were not assessed. Other recent historical records include Level1 victories and an early Level3 loss. Do not tune from those aggregates alone.
4. Save expectations: Continue retains previous rule/map families. Start a new Level1 run to review the new maps. Existing gear persists, so record the tester's equipment; no automated rewards are written.
5. Distribution: unsigned Windows build and private repository remain. Testers need repository access or the shared ZIP. Extract the whole ZIP, run MobaBot.exe, optionally create a desktop shortcut. No installer or automatic updater.

Verification: full 42-suite regression plus focused release diagnostics/interface/HUD checks; exported-pack and real EXE startup results recorded in QA_18 after packaging. Existing test-only PNG import and Vanguard exit-instance warnings are not game crashes; no logged engine errors accepted. Automated full-Level1/2/3 reliability was already completed on factory31, with artificially inflated health, not human balance proof.

No new fun/quality score. Before play record release/source commit and result-log baseline, freeze code/assets, and follow PLAYTEST_PROTOCOL. No player session is restarted by release work.
