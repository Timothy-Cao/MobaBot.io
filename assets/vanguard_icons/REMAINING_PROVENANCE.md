# Remaining Vanguard icon provenance

9 September 2026. Eight new icons generated using the built-in image-generation tool. The owner approved the QWER direction; these extend it, with Q as a style-only reference. No third-party game artwork input. Original generated paintings, not hand-authored illustrations. All sources are opaque squares; runtime imports are 128×128 with mipmaps. Existing QWER is unchanged.

## Exact prompts

Shared prompt followed by each subject:

> Use case: stylized-concept. Create ONE new square opaque full-bleed MOBA ability icon. Reference image is style/material reference only; replace subject entirely. Match approved Vanguard rocket's painterly digital brushwork and dramatic values, leaning into Dota 2 / League of Legends ability illustration style. Original salvage-tech design, not copied game assets. Broad hand-painted planes, strong silhouette and graphic action, medium detail, graphite navy shadows, teal enamel steel machinery, warm brass, cream highlights, function-specific restrained energy hue. Intended import 128x128 and display 48px: prioritize big shapes, no tiny detail. No text, letters, frame, logos, watermark, UI, photoreal chrome, ornamental greebles. Subject: 

Reference: `assets/vanguard_icons/vanguard_q.png`, SHA-256 `28BCD708D3EA2C290904BC9806F8E1DCB4B860503E822C3281D46EF6742B3880`.

### d

Ghost drive: ONE heavy teal armored mechanical BOOT in side profile, bent ankle, blunt squared toe pointing right, steel sole, brass heel-mounted thruster blasting pale cyan exhaust toward left and two fading boot-shaped spectral afterimages. Clearly a boot with ankle and sole, NOT a missile, no pointy nose, no fins, no rocket-shaped objects. Sweeping cyan brush strokes convey sustained speed.

Source: `vanguard_d.png`; original: `exec-466ddd9f-58d6-466f-bd63-713a2d842eb9.png`; SHA-256: `51B374D58FEF377EB649F2CDB9FB18E6C91AC581D9E30D719EEF72F64C704E4B`.

### f

Phase hop: a small teal armored core instantaneously appearing through a sharply split violet-blue spatial rift, two separated luminous crescent endpoints, cream flash in destination. Conveys teleportation, no long exhaust trail.

Source: `vanguard_f.png`; original: `exec-e71be074-25d4-418d-aafe-016e39792bd2.png`; SHA-256: `BFFFEE02F021BFF361C2E5C44767B1EEA138F4109CDE5A86DB22023D14F327A5`.

### p1

Orbit tools: three large sharp steel razor blades whirling around a small teal hub in a tight tilted circular orbit, cream cutting edges and controlled brass curved motion strokes. Clearly three separated blades with negative space, not one circular saw.

Source: `vanguard_p1.png`; original: `exec-e522a2cd-9780-43cd-9a9b-990c49e61f4d.png`; SHA-256: `52A80523E634D6BD3B9C925D4757D0640B93ADAC45B8BAB5E76B5EA79DBDEF78`.

### x1

Bulwark: one squat heavy armored teal gun turret braced on three steel legs, broad shield-like chest plate and short protruding barrel firing a small warm flash. Low viewpoint, weighty grounded silhouette, brass joints, restrained blue rim light. Conveys defensive deployable gun.

Source: `vanguard_x1.png`; original: `exec-5decf78b-9c78-4a39-8607-49266e937091.png`; SHA-256: `D4DBCE371FE6E41939ACC0A4657006EC04FA9F8BA06254303769A1C4E45FC2BB`.

### x2

Reserve totem: a grounded teal and brass repair reservoir with a large luminous mint green glass chamber storing energy, a single bright branching upward repair spark and a gentle green transfer ribbon. Wide tank silhouette, no gun, no letter or medical cross.

Source: `vanguard_x2.png`; original: `exec-ff766247-d183-46aa-bcbb-998ef5378633.png`; SHA-256: `BB8FCB2337614A4B13F8946BC714107303F109AAF3CDF1605F3C4D5817BC0975`.

### x3

Overclock well: a low teal mechanical pedestal beneath two raised brass tuning prongs, crackling electric blue lightning jumping between them, one concentrated cream spark and a blue circular ground pulse. Open fork silhouette, no reservoir tank, no gun. Conveys energy and accelerated recharge.

Source: `vanguard_x3.png`; original: `exec-8b2c2630-e745-4c06-b99e-d0359ad1bf88.png`; SHA-256: `A166042879BE7F586E8812D661B08EB0E37A224FB82B31A0F854065637A4AE51`.

### hammer

Commanded hammer: one massive rectangular steel hammer head with teal casing and brass collar, thick handle angled down left, swinging across frame with a broad cream-gold impact crescent. Hard heavy planes, no hand, sharp kinetic contact, not a spear.

Source: `vanguard_hammer.png`; original: `exec-10a48401-2ba8-4767-8aae-7465c36b6e7b.png`; SHA-256: `D667512D918ED69A19D96CD25A4C9F9A969792E37690A2363A73AE6064D6BB05`.

### gun

Autonomous machine gun: one compact teal steel machine gun with a short cluster of three stout barrels pointing upper right, brass cartridge feeding its side, a small hot orange muzzle flash and two tiny bullet streaks. Broad readable silhouette, no hands or character, no giant rocket.

Source: `vanguard_gun.png`; original: `exec-5cb0859a-8572-4a18-9693-dee91b79f715.png`; SHA-256: `98262A1B993DDD433928F287AD73E901F9C6685AB227C449CA7078ED940040AD`.

## Revision and review

D's first draft resembled Q's rocket too closely and was rejected; final D uses a propulsion boot. Rejected source remains outside the project: `exec-cd800feb-8a04-400b-a996-50752f1dbc75.png`. The other eight accepted sources retain the material family while separating motion boot, teleport rift, orbit blades, armored turret, green reservoir, blue fork, hammer and multi-barrel gun.

Inspect using `tests/skill_visual_test.gd -- --icons` (54/40/32px, normal/reduced) and `tests/interface_polish_test.gd -- --render` (HUD/Practice). Alpha and import budgets are checked for all twelve icons. No balance, timing or world-animation changes. Owner approval of QWER is recorded; recognition/preference for the new eight remains pending.
