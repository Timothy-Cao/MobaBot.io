extends SceneTree
var checks := 0
var failures := 0

func _init() -> void: call_deferred("_run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func key(code: int, pressed: bool = true) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	return event
func fresh(precision: bool = false) -> SalvageRun:
	var run := SalvageRun.new()
	run.enable_moba(MobaKit.preset(precision))
	run.enable_demo()
	run.pickups.clear()
	run.spawn_clock = 999
	run.invincible = 999 # Movement-only fixture, not difficulty evidence.
	return run

func _run() -> void:
	# Arrival and stop must not depend on physics rate, direction, or short targets.
	for hz in [30, 60, 120, 144]:
		for distance in [0.0, 0.1, 5.0, 90.0, 400.0]:
			for direction in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2(1, 1).normalized()]:
				var run := fresh()
				var target: Vector2 = run.player + direction * distance
				run.command_move(target)
				var last_distance: float = distance
				var monotonic := true
				for tick in range(hz * 3):
					run.step(1.0 / hz, Vector2.ZERO)
					var remaining := run.player.distance_to(target)
					monotonic = monotonic and remaining <= last_distance + 0.001
					last_distance = remaining
					run.events.clear()
				check(monotonic and run.player.is_equal_approx(target), "Arrival never overshoots or oscillates at %d Hz" % hz)
				check(not run.moving and run.velocity == Vector2.ZERO, "Arrival clears velocity and movement latch")
		for id in ["dash", "lunge", "blink"]:
			for r in [0, 5, 10]:
				var run := fresh(id != "blink")
				var slot := "e" if id == "lunge" else "f"
				run.kit.ranks[slot] = r
				var origin := run.player
				var target := origin + Vector2(130, -70)
				var expected := run.kit.target_point(run, slot, target)
				check(run.kit.cast(run, slot, target), "Mobility casts at each milestone")
				for tick in range(hz): run.step(1.0 / hz, Vector2.ZERO)
				check(run.player.is_equal_approx(expected) and run.kit.dash_left == 0 and run.velocity == Vector2.ZERO, "Mobility ends precisely without drift at %d Hz" % hz)
	for precision in [false, true]:
		for corner in [SalvageRun.ARENA.position + Vector2.ONE * 16, SalvageRun.ARENA.end - Vector2.ONE * 16]:
			var run := fresh(precision)
			run.player = corner
			var outward: Vector2 = (corner - SalvageRun.ARENA.get_center()).normalized()
			var before: int = run.kit.charges.f
			check(not run.kit.cast(run, "f", corner + outward * 200), "Zero-travel edge mobility is rejected")
			check(run.kit.charges.f == before and run.kit.recharge.f == 0, "Blocked mobility preserves charges and cooldown")
			check(not run.kit.preview_ready(run, "f", corner + outward * 200), "Blocked movement preview agrees with cast rejection")
			run.command_move(corner + outward * 500)
			for i in range(20): run.step(1.0 / 60, Vector2.ZERO)
			check(run.player == corner and not run.moving, "Out-of-bounds click does not jitter against arena edge")
	var run := fresh(true)
	run.kit.energy = 0
	check(not run.kit.preview_ready(run, "q", run.player + Vector2.RIGHT * 100), "Aim preview includes energy affordability")
	run.kit.energy = 100
	check(run.kit.cast(run, "w", run.player) and run.kit.zones.back().pos == run.player, "Ground mortar supports a deliberate self-centered cast")
	run = fresh()
	check(run.kit.cast(run, "t", run.player) and run.kit.summon.pos == run.player, "Stationary summon can deploy at the player's feet")
	run = fresh()
	run.player = SalvageRun.ARENA.end - Vector2(16, 210)
	DemoCampaign.spawn_special(run, "rammer")
	var boss: Dictionary = run.enemies.back()
	boss.pos = run.player - Vector2(120, 100)
	boss.clock = 0
	DemoCampaign.enemy_step(run, boss, 0.01)
	check(Vector2(boss.dir).is_equal_approx((Vector2(boss.target) - Vector2(boss.pos)).normalized()), "Arena-edge charge direction matches its clamped travel path")
	boss.pos = run.player + Vector2(600, 900)
	DemoCampaign.spawn_special(run, "artillery")
	run.enemies.back().pos = boss.pos + Vector2(1, 1)
	var markers := CombatReadability.markers(run)
	check(markers.size() == 2 and markers.all(func(m: Dictionary) -> bool: return m.label_pos.y < 365), "Coincident lower-edge objective labels stay above boss HUD")
	check(absf(markers[0].label_pos.y - markers[1].label_pos.y) >= 18, "Coincident objective labels do not overlap each other")
	var game := load("res://src/salvage/workshop.tscn").instantiate() as Node2D
	root.add_child(game)
	await process_frame
	game.persist_settings = false
	game.camera_locked = true
	game.r_quickcast = false
	game.set_physics_process(false)
	game.key_setting = MobaKit.DEFAULT_BINDS.duplicate()
	game.loadout_setting = MobaKit.preset()
	game.start_run()
	check(game.camera.process_callback == Camera2D.CAMERA2D_PROCESS_PHYSICS, "Camera uses the same update phase as simulation")
	for zoom in [0.65, 0.8, 1.0]:
		game._set_zoom(zoom, false)
		for corner in [Vector2(480, 300), SalvageRun.ARENA.position + Vector2.ONE * 16, SalvageRun.ARENA.end - Vector2.ONE * 16, Vector2(SalvageRun.ARENA.position.x + 16, SalvageRun.ARENA.end.y - 16), Vector2(SalvageRun.ARENA.end.x - 16, SalvageRun.ARENA.position.y + 16)]:
			game.model.player = corner
			game._update_camera()
			var screen_point: Vector2 = (game.model.player - game.model.camera_origin()) * zoom
			check(screen_point.x >= 48 and screen_point.x <= 912 and screen_point.y >= 96 and screen_point.y <= 345, "Player remains clear of clipping and opaque HUD at every tested edge/zoom")
			for pixel in [Vector2(60, 110), Vector2(480, 280), Vector2(900, 380)]:
				var world: Vector2 = game.get_canvas_transform().affine_inverse() * pixel
				check(world.is_equal_approx(game.model.camera_origin() + pixel / zoom), "Cursor mapping is exact at zoom and world edges")
	# Steering gestures end at interruptions; a deliberate one-click path survives.
	for interruption in ["pause", "settings", "build", "focus"]:
		game.start_run()
		game.model.command_move(game.model.player + Vector2.RIGHT * 200)
		game.mouse_moving = true
		game.pending_cast_slot = "q"
		match interruption:
			"pause": game._pause_toggle()
			"settings": game._open_settings()
			"build": game._open_build()
			"focus": game._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		check(not game.mouse_moving and not game.model.moving and game.pending_cast_slot.is_empty(), "Interruption releases held steering and pending aim: " + interruption)
		var before: Vector2 = game.model.player
		var time_before: float = game.model.time
		game._physics_process(1)
		check(game.model.player == before and game.model.time == time_before, "Interrupted screen freezes movement and encounter clocks")
	game.start_run()
	game.model.command_move(game.model.player + Vector2.RIGHT * 200)
	game._open_build()
	check(game.model.moving, "Inspection preserves deliberate click-to-move destination")
	game._close_build()
	game._input(key(KEY_S))
	check(not game.model.moving and not game.mouse_moving, "S cancels resumed click path immediately")
	game.tab_held = true
	game.start_run()
	check(not game.tab_held, "Restart cannot retain an old held-Tab latch")
	game.art.reduced_effects = false
	game.art.shake = 0
	for i in range(60): game.art.receive({"kind": "pulse", "pos": game.model.player, "radius": 150})
	check(game.art.shake == 0, "Automatic pulse spam causes no persistent shake")
	game.art.receive({"kind": "hurt", "pos": game.model.player})
	game.art.visual_time = 0.03
	check(absf(game.art.impact_bank()) > 0 and absf(game.art.impact_bank()) <= 0.04, "Hull impact has small bounded player-only recoil")
	game.art.reduced_effects = true
	check(game.art.impact_bank() == 0, "Reduced effects disables recoil immediately")
	game.art._process(0.5)
	check(game.art.shake == 0, "Recoil fully settles instead of accumulating")
	# Every ability preview agrees with a real cast on an equivalent isolated state.
	for id in MobaKit.ABILITIES:
		var slot: String = {"active": "q", "ultimate": "r", "speed": "d", "mobility": "f", "summon": "t"}[MobaKit.ABILITIES[id].category]
		for energy in [0.0, 100.0]:
			run = fresh()
			run.kit.loadout[slot] = id
			run.kit.charges[slot] = MobaKit.ABILITIES[id].max
			run.kit.energy = energy
			run.spawn_enemy(run.player + Vector2(100, 0), 0)
			run.enemies.back().warmup = 0
			var cursor := run.player + Vector2(160, -50)
			check(run.kit.preview_ready(run, slot, cursor) == run.kit.cast(run, slot, cursor), "Aim readiness agrees with cast: " + id)
	# Repeated inspection/settings transitions must not retain old control trees.
	game.start_run()
	game._open_build()
	game._close_build()
	await process_frame
	var initial_nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	for cycle in range(30):
		game._open_build()
		game._close_build()
		game._open_settings()
		game._close_settings()
		await process_frame
	check(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) <= initial_nodes + 5, "Repeated menu transitions do not accumulate orphaned UI nodes")
	game.queue_free()
	await process_frame
	await create_timer(0.1).timeout
	print("MOTION QA TESTS: ", checks, " checks; ", failures, " failures")
	quit(0 if failures == 0 else 1)
