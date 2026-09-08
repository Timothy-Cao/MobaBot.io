# Research working record

As of 2026-09-07, America/Los_Angeles. Research only; no gameplay changes, purchases or service installation authorized in this pass.

## Scope and decisions

- User requests comprehensive Godot/AI-assisted 2D survivor-roguelite research, especially art/animation, power fantasy, differentiation and low-friction production.
- Windows-first confirmed by user during research. Single-player, offline prototype proposed, not a final commercial-platform commitment.
- Existing local Neon Collector is an introductory sample, not a survivor combat prototype.
- Deep Research skill used. Planning API was unavailable after discovery and a failed attempt; phases maintained here instead.

## Phases

1. Scope and discovery: complete.
2. Evidence collection and contradiction checks: complete.
3. Synthesis and prototype recommendation: complete.
4. Citation audit, PDF creation and visual verification: complete.

## Gap matrix

| Question | Evidence | Confidence / contradiction | Next action |
|---|---|---|---|
| Godot fits this genre | Official Brotato showcase, Godot 2D/CLI/performance docs, GDQuest survivor tutorial | High for feasibility; no performance promise for our game | Specify staged stress test and Windows export gate |
| Why power feels good | Developer interviews/AMAs, StS GDC slides, SDT original study and critique, player discussion | Strong process evidence; exact cadence is a hypothesis | Separate findings from proposed timing |
| AI solves sprite animation | Positive and negative r/aigamedev workflows; official PixelLab/Scenario repair instructions | Mixed; repeatability remains unmeasured | Golden-set pilot with pack/procedural fallback |
| Distinctive concept | User archives + design synthesis; Void Scrappers/Orbital Survivor/Junkyard Saints listings | Not proven novel. Scrapstorm already in a nearby title | Use descriptive salvage prototype, no final name claim |
| Best assistant workflow | OpenAI official best practices; firsthand Godot project account and complete-game workflow discussion | Agreement on bounded tasks/tests/captures; public release claims not audited | Plan inspectable loops and living implementation record |
| Licenses / release blockers | Creator asset pages; PixelLab terms; Scenario pricing; Steam survey; GDQuest tutorial license labels | Primary claims, but tutorial page/video asset labels conflict and Scenario billing toggle ambiguous | No spending; do not ship tutorial assets without exact archive license |
| How game actually feels | No prototype yet | Unknown, cannot resolve through more web search | Paired 90-second test before content production |

## Search record and stopping rule

- Discovery: r/aigamedev homepage, top-year and new feeds; targeted searches for complete-game workflows, Godot, sprite consistency, sprite-sheet generation, video-to-sheet cleanup, animations and failures.
- Follow-up: read selected threads and comments, including the latest Sept 2026 consistency failure and 18-month Godot project account; distinguish commercial promotion and unfinished demos from measured outcomes.
- Independent lanes permitted by research skill: developer/gameplay sources and art-production sources. Their findings were cross-checked against official docs and folded into one recommendation.
- Adjacent communities: r/godot performance and art bottlenecks; r/gamedev large-sprite limitations; r/gamedesign upgrade-slot disagreement; r/roguelites small-upgrade, grind and late-run boredom complaints.
- Primary technical checks: Godot servers, CPU/GPU optimization, MultiMesh, CLI, Windows export, cutout animation, official showcase; GDQuest course license.
- Primary production checks: Kenney, 0x72, Aseprite CLI, PixelLab docs/API/terms, Scenario guide/pricing, Steamworks content survey.
- Counterevidence: animation success required multi-tool repair; existing game names/themes overlap; optimal amount of late-run dominance disputed; SDT measurement/theory has critiques; no phone benchmark needed after Windows-first confirmation.
- Boundaries: no private Discord access, no full Reddit archive census, no paid-tool output benchmark, no source claims about gameplay videos whose content/transcript could not be inspected.
- Stop broad discovery when the same workflow/failure themes recur across sources. Remaining high-value uncertainty is empirical gameplay/art throughput, which requires a prototype or pilot rather than additional opinion searches.

## Verification caveats

- Web capture time in UTC crossed September 8; local research date remains September 7.
- Reddit cached relative timestamps vary; only use explicit dates where reliably exposed, otherwise record retrieval date.
- The Godot MultiMesh tutorial itself warns it has not yet been updated for 4.7. Treat it as architectural guidance; verify exact APIs in pinned-version class docs when coding.
- Read-only local source inspection refreshed Super Wizard Tactics README, Pet Painters README, Misconfigured types and starter scripts. Fling-Thing README is generic scaffolding; use its actual design/spec/code rather than README for mechanics.

## Final QA

- Delivered artifact: output/pdf/godot-survivor-research.pdf, 14 pages, 42 distinct linked sources.
- All 14 pages rendered with Poppler and visually inspected at 1200px: no clipping, overlapping elements, broken tables, missing glyphs or footer collisions.
- verify_report.py passed: every section's normalized source text retained, hyperlink target set matches source, all cited URLs in source ledger, page numbering and text bounds valid.
- Canonical content: report-source.md. Provenance: source-ledger.md. Reproducible renderer/check scripts retained in this directory.
- No game implementation, dependency installation, paid account connection, purchase, archive edit or publication was performed. Only research artifacts, their build/QA scripts and Godot-ignore markers for artifact directories were added.
- Remaining uncertainty requires user playtests and a bounded art pilot, not another broad research pass.
