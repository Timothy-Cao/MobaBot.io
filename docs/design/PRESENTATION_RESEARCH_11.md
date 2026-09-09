# A foundry, not a dashboard

MobaBot.io presentation research · 8 September 2026

Audience: the creator and future project contributors. Scope: the existing Windows-first, three-level demo; menu, gameplay hierarchy, equipment, mastery and upgrade presentation.

## Recommendation

Give the game one recognizable place: a salvage launch bay. Let the robot and foundry establish the fantasy; keep navigation short and native. Carry the same materials into assembly-style equipment, a compact circuit-like mastery tree and clear upgrade cards. Preserve the MOBA movement/active-ability distinction. Do not import the systems or commercial clutter of much larger games.

This is a design inference from reference observations and this project's constraints. It is not evidence that a particular menu causes sales, retention or enjoyment.

## What the references actually show

### Title screens: composition before decoration

Three inspected historical title screens use different layouts but commit to one thematic composition. Brotato spotlights an armed protagonist beneath a large custom logo; DRG Survivor uses a diagonal planetary scene with compact left navigation; Vampire Survivors frames central controls with characters and atmospheric art. Their lesson here is coherent staging, not identical button placement. [Brotato capture, Alex Rowe, 7 February 2024](https://xander51.medium.com/i-just-keep-playing-brotato-0f39fecc00e4), [DRG Survivor guide, Sid Natividad, 16 February 2024](https://thenerdstash.com/deep-rock-galactic-survivor-starter-guide/), [Vampire Survivors capture, Nivrae, 14 March 2025](https://www.we-are-girlz.com/2025/03/vampire-survivors-le-jeu-ultra-addictif-que-jai-voulu-evite/).

MobaBot adaptation: a full-bleed original robot/foundry illustration with quiet left space, a deliberate title lockup, Play as the primary action and a small three-sector route. No floating equipment stickers, tutorial paragraph, fake announcements or promotional badges.

### Survivor.io: fast visual choices, distinct inventory roles

Habby's current store gallery shows bold combat silhouettes and icon-led, three-card skill choices with ranks and a compact current-build strip. The page displays 50M+ downloads; that establishes broad adoption, not why it succeeded. Promotional characters obscure some interface areas, so hidden controls were not inferred. [Habby on Google Play, updated 8 September 2026](https://play.google.com/store/apps/details?id=com.dxx.firenow).

A secondary equipment capture separates fitted slots around a character from the collection below. Its date/build are unknown. We could not verify a first-party equipment capture, so this is a bounded visual reference, not a claim about today's interface. [MiniReview equipment screenshot](https://minireview.io/common/uploads/review/5f957c2f76d8ca8a5d42dc55ea443947.jpg).

MobaBot adaptation: three existing equipment slots beside an assembly schematic, six items grouped by slot, one selected inspector, explicit base/bonus separation and signed comparisons with the fitted item. No additional currencies, entry-energy timers, daily rewards or portrait-mobile layout.

### Mastery: meaningful nodes, understandable investment

An EHG developer describes why Last Epoch replaced an unfamiliar grid and two point types: communication difficulty and excessive planning friction. It retained thematic groups and nodes that change mechanics. That is historical 2018 design reasoning, not a current rules guide. [Mitch, Remastering Masteries, 17 August 2018](https://forum.lastepoch.com/t/remastering-masteries-overhauling-the-passive-system/1607).

Last Epoch's official marketing tree emphasizes linked icon nodes and rank counts; its item examples separate identity, inherent values and affixes. Hades's early-access Mirror screenshot uses compact icon/name/value/cost rows inside a thematic frame, with selected detail outside the list. [EHG Skills](https://lastepoch.com/skills/), [EHG Items & Loot](https://lastepoch.com/items/), [Hades Mirror archive, visible v0.27191](https://interfaceingame.com/screenshots/hades-mirror-of-night/).

MobaBot adaptation: retain all nine nodes and one point pool on a single screen. Three clear routes, visible ranks, larger endpoints and a stable hover/focus detail pane. Show current → next effects. Spending should preserve focus, not send the cursor or selection elsewhere. No zoomable forest or empty travel nodes.

### Combat UI: preserve the play area

Official Brotato gameplay imagery gives bright pickups and outlined enemies a quiet ground plane. DRG Survivor uses compact mission progression and a grouped combat HUD. These are gallery observations, not usability experiments. [Blobfish Steam gallery](https://store.steampowered.com/app/1942280/Brotato/), [Funday/Ghost Ship Steam gallery](https://store.steampowered.com/app/2321470/Deep_Rock_Galactic_Survivor/).

MobaBot adaptation: keep health, energy and XP together; keep QWER primary and DF/T secondary. Add a small three-sector progress rail, remove redundant objective prose, reduce the dock's vertical footprint and give consumables actual icons. Modal screens must cover every HUD element. Do not conceal useful cooldown, charge, energy or threat information in the name of minimalism.

### Craft is also interaction correctness

Microsoft's guidelines emphasize readable text and contrast, consistent navigation and predictable focus. We use them as review criteria, not a claim of compliance or accessibility certification. The cited PC text guidance measures visible letter-body height, not merely a font-size property. [XAG 101: text](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/101), [XAG 102: contrast](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/102), [XAG 112: navigation](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/112).

MobaBot adaptation: live text rather than lettering baked into art; stable hit targets; visible focus; signed stat changes; bounded tooltips; reduced-motion respect; test the smallest supported window as well as 1600×900. Important state must not depend only on color.

## Art production decision

Use one original generated background to establish the foundry. It references only our own robot, not third-party game imagery. Keep all interactive content and icon families code-native. A title illustration may use richer staging than small combat sprites, but the palette and silhouette must remain recognizable. Source prompt and provenance belong in the asset folder. A good prompt is not acceptance: inspect the actual rendered game, identify defects, and iterate only on those defects.

## Limits and stopping point

Reference captures are a mix of promotional, historical console and early-access screenshots. We did not play those reference games during this research or test their current interfaces. Their commercial reception does not isolate menu quality as a cause. The first-party Survivor.io equipment gap remains explicitly bounded.

Research stopped when the independent lanes converged and remaining generic searching was unlikely to change the implementation. The next evidence is our own rendered screens, navigation tests and the creator's playtest. No fourth level, larger equipment system, new progression economy or broad combat rebalance is justified by this presentation request.
