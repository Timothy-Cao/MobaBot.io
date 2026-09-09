# Painted icon experiment · 0.16

89 original AI-generated bitmap assets: 49 skills/toggles and 40 equipment items. Generated with the built-in OpenAI image-generation tool for this project, one image per asset. No third-party game art was downloaded or used as a visual reference. The selected rocket establishes this pack's material/style reference. Generation originals are retained outside the repository in this task's generated-images folder.

`manifest.json` records the shared reusable style prompt, reference asset and subject descriptions. Those descriptions are historical generation briefs, not authoritative current balance data. `provenance.json` records each selected file's SHA-256 and matching generation-source basename, plus the laser revision prompt. Matching hashes establish an unmodified copy from generation output; runtime resizing is Godot importer configuration, not a destructive source edit.

The first laser resembled a circular saw. Its replacement explicitly calls for a compact open-fork emitter and long continuous cream/gold beam. The original rocket reference unexpectedly had fractional alpha across its full canvas; a separate opacity-correction edit preserves its design with an opaque navy background. Both revision prompts and the original reference hash are recorded. Other selected icons use the shared medium-detail cel/gouache treatment. Generated interpretation varies; the pack is offered as **Painted**, with the code-drawn **Base** skin retained intact for comparison.

Source canvases have intentional opaque navy backgrounds. Import size is capped at 256 px with mipmaps. Run `tests/painted_art_test.gd -- --render` for source validation and 128/64/32 px comparison pages. Text, tier numbers, borders, cooldowns and key labels are rendered by Godot, never baked into the images.

This document describes provenance and process, not a guarantee of exclusivity or a claim that these were hand-painted by a human artist.
