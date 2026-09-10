# Vanguard QWER icon provenance

9 September 2026. Generated with the built-in image-generation tool, one original image per ability. No third-party game artwork used as input. LoL/Dota were requested as broad painterly ability-icon references, not copied assets. These are AI-generated images, not claims of human authorship.

Official current Vanguard icons; existing Painted icons remain for other abilities/equipment. The previous artwork remains archived in assets/painted, not exposed as a skin selection. Full-resolution opaque square source PNGs are retained for future replacement; Godot imports each at **128×128 with mipmaps**. No world animation change.

## Exact prompt set

Each prompt is the following shared text followed by `Subject: ` and its subject below.

> Use case: stylized-concept. Asset type: single square full-bleed opaque MOBA ability icon for MobaBot.io Vanguard, designed to read at 54 pixels. Original hand-painted digital game art in the high-contrast painterly ability-icon tradition of Dota 2 and League of Legends, not copied existing spell artwork. Medium detail, bold silhouette, broad brush planes, dramatic directional composition, graphite navy background, teal enamel salvage machinery, steel and warm brass, cream impact light. No text, letters, borders, logos, watermarks, UI mockup, photorealism or tiny ornamental details. One clear action fills frame.

### Q

A chunky finned teal-and-steel rocket accelerating diagonally toward upper right, broad warm orange exhaust streaming lower left, sharp cream nose. Read as a fast aimed explosive missile.

- Workspace source: `vanguard_q.png`
- Generated original: `exec-c3178d7a-0f01-441c-93b8-fadcd5e9bfcb.png`
- SHA-256: `28BCD708D3EA2C290904BC9806F8E1DCB4B860503E822C3281D46EF6742B3880`

### W

A slim steel targeting dart plunging vertically into a tight blue-white ground impact, one clear circular shock ripple below, teal fins and brass collar. Read as precise descending artillery, not a rocket flying sideways.

- Workspace source: `vanguard_w.png`
- Generated original: `exec-89337bea-7447-4fd4-8d54-78701b3f3dba.png`
- SHA-256: `593BBBD28475667078FCCDD0202426CB52A65E9088DC84DE7FE744713877093A`

### E

A compact teal robot shoulder chassis smashing forward to the right through a cream and brass wedge-shaped impact burst. Heavy steel shoulder plate, compressed kinetic energy, directional motion streaks. Read as a body slam, no humanoid face or hands.

- Workspace source: `vanguard_e.png`
- Generated original: `exec-78ecf210-c64e-4801-bd76-ec2db739e460.png`
- SHA-256: `3431B4F7367D291996A7A8E3D6E0E400B9B74374D99DFB3F7E9CF0D745AC9F94`

### R

A huge caged teal reactor drum plunging down into an explosive golden radial blast. Heavy brass braces opening around a brilliant cream core, wide circular shockwave below. Read as a massive ultimate reactor detonation; broad drum silhouette unlike the narrow precision dart.

- Workspace source: `vanguard_r.png`
- Generated original: `exec-d80050d7-51a7-469d-b17c-b82e9835b6a2.png`
- SHA-256: `6E98CBA825A2A3DC82EB73B91859C0E440F4058396A5C5D9A0733E787B8850EB`

## Validation

`tests/interface_polish_test.gd` checks source decoding, square dimensions, opaque alpha and imported 128×128 dimensions. Rendered Practice/HUD captures inspect actual 40/54px logical tiles, normal and Reduced effects. Q is diagonal; W narrow vertical/blue; E broad horizontal/brass; R broad vertical/gold. E/R remain denser than Q/W; owner preference is pending. `tests/skill_visual_test.gd` retains combat-size normal/reduced geometry checks. No quality score was raised.
