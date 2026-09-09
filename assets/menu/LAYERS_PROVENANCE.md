# Layered foundry menu · 0.17

Created September 9, 2026 with the built-in image-generation tool. Both edits reference our own `foundry-bay-v1.png`; no third-party artwork was supplied. Original generated files were preserved and selected outputs copied unchanged into this directory.

- `foundry-empty-v2.png`: source `exec-42a204ad-df47-467b-bf2d-0f2df2555997.png`; SHA-256 `6D3C16B3C9ECAE6B7FF696C6846A4BAD005B53C40E437351212BF9C7BD253F2E`.
- `menu-bot-v2.png`: source `exec-c72df377-15f3-400d-b748-152f8763c97e.png`; SHA-256 `DF5A74A6ED0A72970CFAFFC28F9A33C0DAFDD52DE4126439C5E9BCB6349909E2`.

Validation: robot PNG has genuine alpha, fully transparent exterior samples and an opaque central subject. Inspected against the foundry at the actual 1600×900 game render. Robot hover is ±4 logical pixels; two native exhaust shapes vary in length. Reduced effects stops hover and exhaust variation. Import mipmaps are enabled; no generated animation or baked UI text is used. The robot is a static cutout, not a rigged character or frame-by-frame animation pack. Existing v1 artwork remains available.

## Exact prompts

### foundry-empty-v2

Use case: precise-object-edit. Edit target is the supplied MobaBot.io main-menu foundry illustration. Remove ONLY the hovering robot, its magnet, side barrel and two jet exhaust plumes. Reconstruct the foundry architecture and air behind it. Keep the launch platform, floor, foreground objects, rails, background light, dark empty left half and exact wide composition. Same restrained cel-painted graphite/teal/brass art. No characters, no text, no new objects, no lettering. Fully opaque background. Preserve original camera and warm light. This will be the stationary background layer for a separately animated robot.

### menu-bot-v2

Use case: background-extraction. Edit target is the supplied MobaBot.io foundry artwork. Extract ONLY its hovering robot into a genuinely transparent PNG with alpha. Preserve the exact cream rounded face, black screen with two turquoise eyes and turquoise mouth, teal shell, red horseshoe magnet, silver side barrel, two lower thruster housings, camera angle, broad cel-painted material planes and warm upper-left light. Remove ALL background/platform/shadow and remove the cyan jet exhaust flames; those jets will animate in code. Do not redesign or add parts. Single whole robot centered on a square transparent canvas with 12% empty margin around complete silhouette, no crop, no checkerboard painted in, no text.

