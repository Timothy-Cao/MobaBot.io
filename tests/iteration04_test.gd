extends SceneTree
var checks := 0
var failures := 0

func _init() -> void:
	call_deferred("_run")

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func fresh() -> SalvageRun:
	var run := SalvageRun.new()
	run.enable_moba()
	run.pickups.clear()
	run.spawn_clock = 999
	return run

func key(code: int, pressed: bool = true) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code as Key
	e.pressed = pressed
	return e

func _run() -> void:
	var legacy := MobaKit.DEFAULT_BINDS.duplicate()
	for slot in ["p1", "p2", "p3", "p4"]:
		legacy.erase(slot)
	legacy.q = KEY_1
	var migrated := MobaKit.resolve_bindings(legacy)
	check(migrated.q == KEY_1 and migrated.p1 == KEY_Q and MobaKit.valid_bindings(migrated), "Migration preserves the old number-key ability and relocates its toggle")
	var run := fresh()
	check(run.kit.toggles == [true, true, true, true], "Four toggles start enabled")
	check(run.kit.toggle(0) and not run.passive_enabled("bolt"), "Toggle disables automatic gun")
	run.spawn_enemy(run.player + Vector2(70, 0))
	run.enemies[0].warmup = 0
	run._weapon_step(1)
	check(run.projectiles.is_empty(), "Disabled gun stops firing")
	run.kit.toggle(0)
	run._weapon_step(1)
	check(run.projectiles.size() == 1, "Re-enabled gun fires normally")
	run.kit.toggle(1)
	check(not run.passive_enabled("orbit") and not run.passive_enabled("ricochet"), "Disabling orbit also suspends dependent ricochet")
	check(run.upgrade_available("grinder") and run.upgrade_available("ricochet"), "Toggle state cannot manipulate the eligible upgrade pool")
	run.kit.toggle(2)
	run.pending_pulses = 4
	run._pulse_step(1)
	check(run.pending_pulses == 0, "Disabled pulse cannot fire a queued burst")
	run = fresh()
	run.kit.energy = 40
	run.kit.step(run, 1)
	check(is_equal_approx(run.kit.energy, 46), "Energy regenerates net of powered passive upkeep")
	run.kit.toggle(2)
	run.kit.step(run, 1)
	check(is_equal_approx(run.kit.energy, 54), "Switching off an energy passive frees its upkeep")
	run.kit.energy = 100
	run.kit.step(run, 1)
	check(run.kit.energy == 100, "Energy clamps to the maximum")
	run.kit.energy = 0
	var charges: Dictionary = run.kit.charges.duplicate()
	check(not run.kit.cast(run, "w", run.player) and run.kit.charges == charges, "Insufficient energy never consumes a charge")
	check(run.kit.cast(run, "d", run.player), "Speed boost remains available at zero energy")
	check(run.kit.cast(run, "f", run.player + Vector2.RIGHT * 100), "Blink remains available at zero energy")
	run.command_move(run.player + Vector2.RIGHT * 100)
	var start := run.player
	run.step(0.01, Vector2.ZERO)
	check(run.player != start, "Movement is not resource-gated")
	var config := MobaKit.preset()
	config.e = "sacrifice"
	run = fresh()
	run.enable_moba(config)
	run.kit.energy = 0
	run.health = 2
	run.kit.shield = 5
	check(run.kit.cast(run, "e", run.player) and run.health == 1 and run.kit.energy == 55, "Health-for-energy pays exactly one hull even through a shield")
	run.kit.charges.e = 1
	check(not run.kit.cast(run, "e", run.player) and run.health == 1, "Health cost cannot kill the player")
	run.health = 3
	run.kit.energy = run.kit.energy_max()
	check(not run.kit.cast(run, "e", run.player) and run.health == 3, "Full energy cannot waste hull")
	run = fresh()
	run.kit.cast(run, "w", run.player)
	check(run.kit.promote("w") and is_equal_approx(run.kit.cooldown("w"), 6.44), "Rare ability has eight-percent faster recovery")
	check(is_equal_approx(run.kit.recharge.w, 6.44), "Promotion preserves recharge percentage instead of resetting charges")
	check(is_equal_approx(run.kit.damage_scale("w"), 1.15), "Rare damage multiplier is fifteen percent")
	run.kit.promote("w")
	check(run.kit.tiers.w == 2 and not run.kit.promote("w"), "Epic is the rarity cap")
	run = fresh()
	run.state = "upgrade"
	run.offers.assign(["reactor"])
	run.choose_upgrade(0)
	check(run.kit.energy_regen() == 10 and run.upgrade_values("reactor")[0].value == 10, "Reactor rank and stat preview match actual regeneration")
	run.state = "upgrade"
	run.offers.assign(["cell"])
	run.choose_upgrade(0)
	check(run.kit.energy_max() == 120 and run.upgrade_values("cell")[0].value == 120, "Cell rank and stat preview match actual capacity")
	run.enable_stages()
	run.stage_time = 59.99
	run._spawn_step(0.01)
	check(not run.boss_spawned, "Stage boss does not arrive before its minute")
	run.stage_time = 60
	while run.enemies.size() < SalvageRun.MAX_ENEMIES:
		run.spawn_enemy(run.player + Vector2(400, 0))
	run._spawn_step(0.01)
	check(run.boss_spawned and run.enemies.back().kind == 2, "Stage boss arrives on schedule")
	check(run.enemies.size() <= SalvageRun.MAX_ENEMIES, "Required boss can arrive at enemy capacity without breaking the cap")
	# Isolate boss loot from the saturated encounter used above.
	var saved_boss: Dictionary = run.enemies.back()
	run.enemies.assign([saved_boss])
	var boss: Dictionary = run.enemies.back()
	run.hit_enemy(boss, 99999, "active")
	run.invincible = 999
	run.total_xp = 0
	for i in range(90):
		run.step(1.0 / 60, Vector2.ZERO)
	check(run.state == "stage_reward" and run.stage_rewards.size() == 3, "Boss kill leads to a three-card stage reward")
	check(run.total_xp == 72, "Stage clear banks the whole expanded boss shower exactly once")
	var reward: Dictionary = run.stage_rewards[0].duplicate()
	var energy_before := run.kit.energy
	run.step(5, Vector2.ZERO)
	check(run.kit.energy == energy_before, "Stage reward pauses resources and simulation")
	check(not run.choose_stage_reward(-1), "Invalid reward index is rejected")
	check(run.choose_stage_reward(0) and run.stage == 2 and run.stage_time == 0 and not run.boss_spawned, "Reward advances the stage and resets the encounter")
	check(run.kit.tiers[reward.slot] == 1 and run.stage_history.size() == 1, "Selected reward actually promotes the selected equipped ability")
	check(not run.choose_stage_reward(0), "A reward cannot be claimed twice")
	check(run.kit.energy == run.kit.energy_max(), "Inter-stage cache refills energy")
	run.state = "stage_reward"
	run.make_stage_rewards()
	var regen_before := run.kit.energy_regen()
	run.choose_stage_reward(run.stage_rewards.size() - 1)
	check(run.kit.energy_regen() == regen_before + 2 and run.stage == 3, "Reactor cache permanently improves the current run")
	run.boss_defeated = true
	run.stage_clear_wait = 0
	run.step(0.016, Vector2.ZERO)
	check(run.state == "won", "Final boss ends the run without an unusable post-victory upgrade choice")
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game.zoom_value = 1
	game.key_setting = MobaKit.DEFAULT_BINDS.duplicate()
	game.loadout_setting = MobaKit.preset()
	game.start_run()
	game.model.spawn_clock = 999
	game.model.pickups.clear()
	var initial_width: float = game.model.view_size.x
	game._set_zoom(9, false)
	check(game.zoom_value == game.MAX_ZOOM, "Zoom cannot go closer than the original view")
	game._set_zoom(-9, false)
	check(game.zoom_value == game.MIN_ZOOM, "Zoom cannot exceed the wide-view limit")
	check(is_equal_approx(game.camera.zoom.x, 0.65) and game.model.view_size.x > initial_width * 1.5, "Maximum zoom-out shows over fifty percent more world width")
	game.model.player = SalvageRun.ARENA.position + Vector2.ONE * 16
	game._update_camera()
	check(game.model.camera_origin().is_equal_approx(SalvageRun.ARENA.position - Vector2(48, 96) / 0.65), "Zoomed demo camera preserves HUD-safe top-left clearance")
	game.model.player = SalvageRun.ARENA.end - Vector2.ONE * 16
	game._update_camera()
	check((game.model.camera_origin() + game.model.view_size).is_equal_approx(SalvageRun.ARENA.end + Vector2(48, 200) / 0.65), "Zoomed demo camera preserves HUD-safe bottom-right clearance")
	var pixel := Vector2(600, 200)
	check((game.get_canvas_transform().affine_inverse() * pixel).is_equal_approx(game.model.camera_origin() + pixel / 0.65), "Mouse casting and movement coordinates remain accurate after zoom")
	game._input(key(KEY_TAB))
	check(game.screen == "build" and game.tab_held and game.ui.build_page == "abilities", "Holding Tab opens loadout inspection")
	var before: float = game.model.time
	game._physics_process(1)
	check(game.model.time == before, "Held inspection pauses the solo game")
	game._input(key(KEY_TAB, false))
	check(game.screen == "running" and not game.tab_held, "Releasing Tab immediately restores gameplay")
	game.model.state = "upgrade"
	game.model.offers.assign(["power", "reactor", "cell"])
	game.screen = "upgrade"
	game._input(key(KEY_TAB))
	game._input(key(KEY_TAB, false))
	check(game.screen == "upgrade" and game.model.offers.size() == 3, "Hold inspection preserves a pending upgrade screen")
	game._unhandled_key_input(key(KEY_ESCAPE))
	check(game.screen == "settings", "Escape opens settings from an upgrade screen")
	game._unhandled_key_input(key(KEY_ESCAPE))
	check(game.screen == "upgrade", "Escape restores the exact previous screen")
	game._choose(0)
	game._input(key(KEY_1))
	check(not game.model.kit.toggles[0], "Default 1 key toggles passive slot one in combat")
	game._input(key(KEY_TAB))
	game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(game.screen == "paused" and not game.tab_held, "Focus loss while holding Tab cannot leave a stuck inspection")
	game.queue_free()
	await process_frame
	# Real three-stage simulation with normal health and no forced kills.
	for precision in [false, true]:
		run = SalvageRun.new(2407)
		run.enable_moba(MobaKit.preset(precision))
		run.enable_stages()
		for tick in range(30000):
			if run.state == "upgrade":
				run.choose_upgrade(0)
			elif run.state == "stage_reward":
				run.choose_stage_reward(0)
			if run.state in ["won", "lost"]:
				break
			var target := Vector2(480, 300) + Vector2(cos(run.time * 0.1) * 270, sin(run.time * 0.1) * 125)
			for foe in run.enemies:
				if foe.kind == 2 and not foe.dead:
					target = foe.pos + Vector2(110, 0)
			var desired := (target - run.player).normalized()
			for foe in run.enemies:
				var offset: Vector2 = run.player - foe.pos
				if offset.length() < 85:
					desired += offset.normalized() * (1 - offset.length() / 85) * 3
			run.command_move(run.player + desired.normalized() * 80)
			if tick % 66 == 0:
				var foe := run.nearest_enemy(run.player)
				if not foe.is_empty():
					for slot in ["q", "w", "e", "r", "t"]:
						run.kit.cast(run, slot, foe.pos)
			run.step(1.0 / 60, Vector2.ZERO)
			run.events.clear()
		check(run.state in ["won", "lost"], "Three-stage simulation reaches a terminal state")
		check(run.kit.energy >= 0 and run.kit.energy <= run.kit.energy_max() and run.pickups.size() <= 180, "Staged simulation conserves resource bounds and pickup cap")
		print("STAGED_SIM ", JSON.stringify(run.summary()))
	await create_timer(0.1).timeout
	print("ITERATION 04 TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
