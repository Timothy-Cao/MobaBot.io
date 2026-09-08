# A practical process for making games with Godot

Research snapshot: 2026-08-18. This project targets **Godot 4.7.2 stable**, the current stable Windows release on that date. It uses the standard x86_64 editor and typed GDScript. The standard build avoids a .NET SDK dependency and keeps Web export available; Godot 4 C# projects still cannot export to the Web.

## The Godot mental model

Godot games are trees of **nodes** grouped into reusable **scenes**. Scenes are instanced into a larger **scene tree**. Nodes and scenes communicate through **signals**, which keeps features from depending too tightly on one another.

In this starter:

- `Player` is a `CharacterBody2D` scene responsible for input and movement.
- `Collectible` and `Hazard` are `Area2D` scenes responsible for overlap events.
- `Hud` is a `CanvasLayer` scene responsible only for presentation.
- `Main` instances those scenes, connects their signals, and owns the round rules.

That pattern scales well: a door, weapon, enemy, menu, or level can each become a scene with a focused responsibility.

## The development loop

### 1. Define the promise and constraints

Write one sentence describing what the player repeatedly does and why it is interesting. Then choose the first target platform, input device, 2D or 3D, and a scope small enough to finish.

For a first game, choose 2D and one central mechanic. Examples: dodge for 60 seconds, deliver five packages, solve ten single-screen puzzles, or survive one arena. Godot's official beginner material also recommends starting in 2D because it removes much of 3D's additional complexity.

### 2. Build a gray-box prototype

Use rectangles, circles, labels, and placeholder sounds. Implement only:

1. input;
2. the main player action;
3. one obstacle or opposing rule;
4. a win/lose condition;
5. immediate restart.

The question is not “does it look finished?” but “is the repeated action understandable and promising?” This starter intentionally draws its art in code so that question can be answered before an asset pipeline exists.

### 3. Make a vertical slice

A vertical slice is one tiny portion at near-final quality: one character, one short level, representative UI, audio, feedback, pause/restart, and a build another person can play. It exposes production risks early without requiring all the game's content.

Treat the slice as a decision gate. If the loop is not fun or the content is too expensive to produce, change the design while the project is still small.

### 4. Stabilize feature boundaries

Organize around features, keeping a scene, its script, and its local assets near each other. Use snake_case file and folder names and PascalCase node names. Prefer signals for events that cross feature boundaries. Add an Autoload only for state or services that truly must live across scene changes; ordinary scene nodes are easier to reason about and test.

Use typed GDScript consistently. It catches more mistakes before running, improves completion and documentation in the editor, and makes collaborative code easier to read.

### 5. Add content through a repeatable pipeline

Place source images, audio, fonts, and models inside the project. Godot imports them automatically and stores generated cache data under `.godot/`. Commit source assets and their `.import` metadata, but never commit the `.godot/` cache.

Decide naming, resolution, origin/pivot, collision, and import settings before producing dozens of assets. For a larger art-heavy project, configure Git LFS before the first asset commit.

### 6. Playtest in short loops

After every meaningful change:

1. run the smallest relevant scene with F6;
2. run the complete game with F5;
3. test the failure path as well as success;
4. write down observed behavior rather than arguing from intention;
5. keep, revise, or cut the change.

Ask outside testers where they hesitated, what they believed their goal was, and what they wanted to try next. Do not explain the controls until after observing their first attempt; confusion is useful data.

### 7. Add production safeguards

Commit small, playable increments. Keep main scenes loadable, add headless smoke checks for critical resources and rules, and test on the weakest intended device. Use Godot's debugger and profiler before optimizing—measure frame time, physics, draw calls, and memory, then address the actual bottleneck.

For this repository, `.\scripts\check.ps1` imports the project and instantiates the complete game headlessly. It verifies the main nodes, initial spawns, and input actions.

### 8. Export early, release deliberately

Export templates are separate from the editor. Install them through **Editor > Manage Export Templates**, add a platform preset under **Project > Export**, and create a development build early. Desktop builds have the fewest platform prerequisites. Web needs browser testing and WebGL 2.0/WebAssembly support; Android and iOS require their platform SDK/toolchain; consoles require approved platform access and a porting path.

Before release, test a clean exported build, save-data migration, different displays/controllers, pause/focus behavior, licensing/credits, store assets, crash recovery, and a rollback plan.

## A focused learning path

Use this order instead of trying to learn the whole engine:

1. **Editor and scenes:** scene tree, Inspector, FileSystem, F5 versus F6.
2. **GDScript:** variables, functions, typed parameters/returns, `_ready`, `_process`, `_physics_process`.
3. **Input and movement:** Input Map, vectors, frame-rate independence, `CharacterBody2D`.
4. **Interaction:** collision layers/masks, `Area2D`, signals.
5. **Game state and UI:** rounds, score, timers, `Control` layout and `CanvasLayer`.
6. **Assets and feel:** animation, audio, particles, camera motion, hit feedback.
7. **Data:** resources, settings, saves under `user://`.
8. **Shipping:** debugger, profiler, export presets/templates, platform testing.

Godot's official “Step by step” series covers items 1–4; its “Your first 2D game” tutorial then combines them into a complete game.

## How to turn this starter into our game

First, decide three things: the player fantasy, the repeated action, and the smallest complete level. Then we can replace one layer at a time:

- keep the technical shell and change the movement/interaction mechanic;
- replace code-drawn shapes with art without changing collision or rules;
- turn `Main` into a level scene and add a menu/level coordinator;
- extract tunable rules into custom `Resource` files;
- add audio, animation, saving, and platform exports only when the core loop earns them.

The most useful things you can provide are a one-paragraph game idea, 2–3 reference games, the target platform/input, and blunt playtest notes (“I expected X, but Y happened”). If you have art or audio, include the source and its license/provenance.

## Official references

- [Download Godot for Windows](https://godotengine.org/download/windows/)
- [Godot key concepts](https://docs.godotengine.org/en/stable/getting_started/introduction/key_concepts_overview.html)
- [Step by step](https://docs.godotengine.org/en/stable/getting_started/step_by_step/)
- [Your first 2D game](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/)
- [Static typing in GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html)
- [Project organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)
- [Version control systems](https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html)
- [Import process](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/import_process.html)
- [Exporting projects](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html)
- [Command-line tutorial](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
