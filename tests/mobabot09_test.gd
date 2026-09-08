extends SceneTree
var checks := 0
var failures := 0
func _init() -> void: call_deferred("_run")
func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(description)
func fresh() -> SalvageRun:
	var run := SalvageRun.new(901)
	run.enable_moba(MobaKit.demo_preset())
	run.enable_demo()
	run.kit.onboarding = true
	run.kit.elapsed = 120
	run.pickups.clear()
	run.enemies.clear()
	run.kit.loadout.pet = "none"
	return run
func enemy(run: SalvageRun, offset: Vector2) -> Dictionary:
	run.spawn_enemy(run.player + offset)
	var foe: Dictionary = run.enemies.back()
	foe.warmup = 0
	foe.hp = 100
	return foe
func key(code: int, pressed: bool = true) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	return event
func mouse(button: int) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	return event
func _run() -> void:
	check(MobaKit.valid_loadout(MobaKit.demo_preset()), "New default loadout is valid")
	var run := fresh()
	run.kit.elapsed = 0
	for slot in MobaKit.BIND_SLOTS:
		check(run.kit.unlocked(slot) == (slot in ["q", "d", "f"]), "Initial unlock: " + slot)
	check(not run.kit.cast(run, "w", run.player + Vector2.RIGHT * 100), "Locked cast rejected")
	check(run.kit.energy == 100 and run.kit.charges.w == 1, "Locked cast is free")
	for slot in MobaKit.UNLOCKS:
		run.kit.elapsed = float(MobaKit.UNLOCKS[slot])
		check(run.kit.unlocked(slot), "Unlock boundary: " + slot)
	for hz in [30, 60, 120, 144]:
		run = fresh()
		var direct := enemy(run, Vector2(150, 0))
		var splash := enemy(run, Vector2(150, 50))
		var missed := enemy(run, Vector2(150, 130))
		check(run.kit.cast(run, "q", run.player + Vector2.RIGHT * 500), "Rocket cast")
		for tick in range(hz): run._projectile_step(1.0 / hz)
		check(is_equal_approx(direct.hp, 77), "Rocket direct + splash exactly once %d Hz" % hz)
		check(is_equal_approx(splash.hp, 92) and missed.hp == 100, "Blast area respects radius")
		check(run.projectiles.is_empty(), "Rocket expires after contact")
		run = fresh()
		var at_end := enemy(run, Vector2(580, 0))
		run.kit.cast(run, "q", run.player + Vector2.RIGHT * 600)
		for tick in range(hz): run._projectile_step(1.0 / hz)
		check(at_end.hp == 92, "Maximum range blast is not a direct hit")
		run = fresh()
		var front := enemy(run, Vector2(100, 0))
		var behind := enemy(run, Vector2(-100, 0))
		run.kit.cast(run, "w", run.player + Vector2.RIGHT * 150)
		for tick in range(hz * 2 + 1): run.kit.step(run, 1.0 / hz)
		check(is_equal_approx(front.hp, 76), "Flame total damage 24 at %d Hz" % hz)
		check(behind.hp == 100, "Flame excludes rear hemisphere")
		run = fresh()
		var blast := enemy(run, Vector2(100, 0))
		run.kit.cast(run, "r", blast.pos)
		run.kit.step(run, 0.64)
		check(blast.hp == 100, "Nuke waits for warning")
		run.kit.step(run, 0.02)
		check(blast.hp == 15 and run.kit.zones.is_empty(), "Nuke strikes once")
		run.kit.step(run, 0.5)
		check(blast.hp == 15, "Nuke cannot repeat damage")
	run = fresh()
	check(run.magnet_radius() == 88, "Starting magnet leaves collection decisions")
	run.upgrades.magnet = 5
	check(run.magnet_radius() == 180, "Magnet generous but not screen-wide")
	run._drop(run.player + Vector2(700, 0), 1)
	run._pickup_step(16)
	check(not run.pickups[0].pull, "No full-map vacuum")
	var close := run.orbit_radius()
	run.kit.toggle(1)
	check(run.kit.passive_active("orbit") and run.orbit_radius() > close * 2, "Orbit toggles radius without disabling")
	run.kit.toggle(1)
	check(run.orbit_radius() == close, "Orbit returns to close protection")
	check(not run.use_consumable(0) and run.consumables[0] == 2, "No waste at full health")
	run.health = 1
	check(run.use_consumable(0) and run.health == 3 and run.consumables[0] == 1, "Repair item")
	run.kit.energy = 0
	check(run.use_consumable(1) and run.kit.energy == 50, "Energy item")
	run.state = "upgrade"
	check(not run.use_consumable(0), "Paused consumables reject input")
	run.state = "running"
	run._drop_supply(run.player, "coins", 25)
	run._collect_supply(run.supply_drops.back())
	check(run.coins == 25, "Money is separate from XP")
	run._collect_supply(run.supply_drops.back())
	check(run.coins == 25, "Collected money cannot be collected twice")
	run.kit.charges.q = 0
	run.kit.charges.r = 0
	run._drop_supply(run.player, "reset", 1)
	run._collect_supply(run.supply_drops.back())
	check(run.kit.charges.q == 2 and run.kit.charges.r == 0, "Cooldown drop refreshes QWE, not R")
	run._drop_supply(run.player, "speed", 1)
	run._collect_supply(run.supply_drops.back())
	check(run.kit.boost_speed == 6 and run.kit.speed() > 205, "Speed boost is temporary")
	var gear := BotEquipment.new()
	var initial := gear.snapshot()
	check(gear.valid(initial), "Starter profile valid")
	check(gear.transact("star", "coil", false), "Star with duplicate succeeds")
	check(gear.inventory.coil.copies == 1 and gear.inventory.coil.stars == 1 and gear.credits == 125, "Star consumes spare and credits")
	check(not gear.transact("star", "coil", false), "Cannot consume equipped final copy")
	var stars: int = gear.inventory.coil.stars
	check(gear.transact("reroll", "coil", false) and gear.inventory.coil.stars == stars, "Reroll preserves stars")
	check(not gear.transact("equip", "reactor", false), "Cannot equip unowned replacement")
	gear.inventory.reactor.copies = 1
	check(gear.transact("equip", "reactor", false) and gear.equipped.Core == "reactor", "Replacement occupies same slot")
	run = fresh()
	gear.apply_to(run)
	check(run.kit.gear_damage >= 0.08 and run.kit.energy_max() == 110 and run.kit.speed() > 205, "Equipment affects actual stats")
	var test_path := "res://tmp/mobabot09-equipment.json"
	check(gear.save_profile(test_path), "Equipment save succeeds")
	check(gear.save_profile(test_path), "Equipment save atomically replaces existing file")
	var reloaded := BotEquipment.new()
	reloaded.load_profile(test_path)
	check(reloaded.snapshot() == gear.snapshot(), "Equipment round trip")
	var invalid := gear.snapshot()
	invalid.inventory.coil.stars = 900
	check(not gear.valid(invalid), "Invalid profile rejected")
	var before := gear.snapshot()
	gear.save_blocked = true
	check(not gear.transact("reroll", "coil") and gear.snapshot() == before, "Blocked save never spends")
	var legacy := MobaKit.DEFAULT_BINDS.duplicate()
	legacy.q = KEY_L
	var migrated := MobaKit.resolve_bindings(legacy)
	check(MobaKit.valid_bindings(migrated) and KEY_L not in migrated.values(), "Old camera-key bind safely migrates")
	for reserved in [KEY_L, KEY_5, KEY_6]:
		var keys := MobaKit.DEFAULT_BINDS.duplicate()
		keys.q = reserved
		check(not MobaKit.valid_bindings(keys), "New reserved key protected")
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game.persist_settings = false
	game.auto_play = true
	game.set_physics_process(false)
	game.loadout_setting = MobaKit.demo_preset()
	game.key_setting = MobaKit.DEFAULT_BINDS.duplicate()
	game.r_quickcast = false
	game.start_run()
	game.model.kit.elapsed = 120
	var energy: float = game.model.kit.energy
	game._input(key(KEY_R))
	game._input(key(KEY_R, false))
	check(game.pending_cast_slot == "r" and game.model.kit.energy == energy, "Default R press and release only previews")
	game._input(key(KEY_ESCAPE))
	check(game.pending_cast_slot.is_empty() and game.screen == "running" and game.model.kit.charges.r == 1, "Esc cancels without charge")
	game._input(key(KEY_R))
	game._input(mouse(MOUSE_BUTTON_RIGHT))
	check(game.pending_cast_slot.is_empty() and game.model.kit.energy == energy, "Right-click cancels without energy")
	game._input(key(KEY_R))
	game._unhandled_input(mouse(MOUSE_BUTTON_LEFT))
	check(game.model.kit.charges.r == 0 and game.pending_cast_slot.is_empty() and game.model.kit.zones.size() == 1, "Left-click confirms once")
	game._unhandled_input(mouse(MOUSE_BUTTON_LEFT))
	check(game.model.kit.zones.size() == 1, "Repeated click cannot duplicate nuke")
	game._set_camera_lock(false)
	game.free_center += Vector2(400, 200)
	game._update_camera()
	var detached: Vector2 = game.camera.position
	game.model.player += Vector2(80, 0)
	game._update_camera()
	check(game.camera.position == detached, "Free camera does not follow movement")
	check(game.model.camera_origin() != game.model.follow_origin(), "Presentation origin independent of spawn origin")
	game.model.spawn_rng.seed = 17
	var spawned: Vector2 = game.model._offscreen_point()
	game.model.detached_origin += Vector2(1000, 0)
	game.model.spawn_rng.seed = 17
	check(spawned == game.model._offscreen_point(), "Panning does not relocate spawns")
	game._input(key(KEY_SPACE))
	game._update_camera()
	check(not game.model.detached_camera and game.camera.position == game.model.follow_origin() + game.model.view_size / 2, "Holding Space follows exactly")
	game._input(key(KEY_SPACE, false))
	game._update_camera()
	check(game.model.detached_camera, "Release Space restores free camera")
	game._input(key(KEY_L))
	check(game.camera_locked, "L toggles lock")
	game._input(key(KEY_TAB))
	check(game.screen == "build", "Tab opens inspection")
	game._input(key(KEY_TAB, false))
	check(game.screen == "running", "Tab release returns")
	check(not game.ui.help_label.visible and not game.ui.load_label.visible, "Gameplay hints and tools counter removed")
	game.queue_free()
	await process_frame
	await create_timer(0.2).timeout
	print("MOBABOT 09 TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
